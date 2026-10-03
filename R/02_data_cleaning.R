# ==============================================================================
# Script: 02_data_cleaning.R
# Project: NYC Taxi Trip Data Analysis and Predictive Modeling Using R
# Author: praveena611 (YuvaIntern Virtual R Data Analyst Internship)
# Seed: 12345
# ==============================================================================

set.seed(12345)
cat("======================================================================\n")
cat("STEP 2: DATA CLEANING, VALIDATION & FEATURE ENGINEERING\n")
cat("======================================================================\n")

suppressPackageStartupMessages({
  library(nanoparquet)
  library(data.table)
  library(dplyr)
})

raw_files <- list.files("data/raw", pattern = "\\.parquet$", full.names = TRUE)

total_raw_count <- 0
total_missing_dropped <- 0
total_outliers_dropped <- 0
total_valid_cleaned <- 0

sample_accumulator <- list()
sample_fraction_per_file <- 0.05 # Extract representative sample (300k+ rows)

for (f in raw_files) {
  cat(sprintf("\n[PROCESSING] Ingesting & streaming: %s\n", basename(f)))
  
  # Read selected columns
  dt <- as.data.table(nanoparquet::read_parquet(
    f,
    col_select = c(
      "VendorID", "tpep_pickup_datetime", "tpep_dropoff_datetime",
      "passenger_count", "trip_distance", "RatecodeID",
      "PULocationID", "DOLocationID", "payment_type",
      "fare_amount", "extra", "mta_tax", "tip_amount",
      "tolls_amount", "total_amount", "congestion_surcharge"
    )
  ))
  
  n_initial <- nrow(dt)
  total_raw_count <- total_raw_count + n_initial
  
  # 1. Handle missing values
  dt <- na.omit(dt, cols = c("passenger_count", "trip_distance", "fare_amount", "payment_type", "RatecodeID"))
  n_after_na <- nrow(dt)
  total_missing_dropped <- total_missing_dropped + (n_initial - n_after_na)
  
  # 2. Compute trip duration in minutes
  dt[, trip_duration_min := as.numeric(difftime(tpep_dropoff_datetime, tpep_pickup_datetime, units = "mins"))]
  
  # 3. Compute speed (mph)
  dt[, speed_mph := fifelse(trip_duration_min > 0, (trip_distance / (trip_duration_min / 60)), 0)]
  
  # 4. Outlier & Business Rule Filtering
  dt_clean <- dt[
    fare_amount >= 2.50 & fare_amount <= 300.00 &
    trip_distance >= 0.10 & trip_distance <= 50.00 &
    trip_duration_min >= 1.00 & trip_duration_min <= 180.00 &
    passenger_count >= 1 & passenger_count <= 6 &
    payment_type %in% c(1, 2) &
    RatecodeID %in% c(1, 2, 3, 4, 5) &
    speed_mph >= 1.0 & speed_mph <= 65.0
  ]
  
  n_clean <- nrow(dt_clean)
  total_outliers_dropped <- total_outliers_dropped + (n_after_na - n_clean)
  total_valid_cleaned <- total_valid_cleaned + n_clean
  
  # 5. Feature Engineering on sample
  set.seed(12345)
  sample_size <- round(n_clean * sample_fraction_per_file)
  sampled_idx <- sample(seq_len(n_clean), size = sample_size)
  dt_sampled <- dt_clean[sampled_idx]
  
  # Time Features
  dt_sampled[, pickup_hour := as.integer(format(tpep_pickup_datetime, "%H"))]
  dt_sampled[, pickup_day := factor(format(tpep_pickup_datetime, "%a"), levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))]
  dt_sampled[, is_weekend := as.integer(pickup_day %in% c("Sat", "Sun"))]
  dt_sampled[, peak_hour := as.integer((pickup_hour %in% c(7:10, 16:19)) & (is_weekend == 0))]
  
  # Metric Ratios & Targets
  dt_sampled[, fare_per_mile := round(fare_amount / trip_distance, 2)]
  dt_sampled[, tip_percentage := fifelse(payment_type == 1, round((tip_amount / fare_amount) * 100, 2), 0.0)]
  dt_sampled[, high_fare := as.integer(fare_amount >= 25.00)]
  dt_sampled[, payment_label := factor(fifelse(payment_type == 1, "Credit Card", "Cash"))]
  dt_sampled[, vendor_label := factor(fifelse(VendorID == 1, "Creative Mobile", "VeriFone"))]
  
  sample_accumulator[[length(sample_accumulator) + 1]] <- dt_sampled
}

cleaned_df <- rbindlist(sample_accumulator)

cat("\n======================================================================\n")
cat("DATA CLEANING AUDIT REPORT\n")
cat("======================================================================\n")
cat(sprintf("Total Raw Records Ingested:      %12s\n", format(total_raw_count, big.mark = ",")))
cat(sprintf("Records Dropped (Missing/NA):    %12s (%.2f%%)\n", format(total_missing_dropped, big.mark = ","), (total_missing_dropped/total_raw_count)*100))
cat(sprintf("Records Dropped (Anomalies):     %12s (%.2f%%)\n", format(total_outliers_dropped, big.mark = ","), (total_outliers_dropped/total_raw_count)*100))
cat(sprintf("Total Valid Population Records:  %12s (%.2f%% retention)\n", format(total_valid_cleaned, big.mark = ","), (total_valid_cleaned/total_raw_count)*100))
cat(sprintf("Analysis Sample Dataset Size:    %12s rows\n", format(nrow(cleaned_df), big.mark = ",")))

# Export Audit Table
audit_summary <- data.table(
  Metric = c("Total Raw Records", "Missing Values Removed", "Outliers & Anomalies Removed", "Total Cleaned Population", "Analytical Sample Rows", "Retention Rate (%)"),
  Value = c(
    format(total_raw_count, big.mark = ","),
    format(total_missing_dropped, big.mark = ","),
    format(total_outliers_dropped, big.mark = ","),
    format(total_valid_cleaned, big.mark = ","),
    format(nrow(cleaned_df), big.mark = ","),
    sprintf("%.2f%%", (total_valid_cleaned / total_raw_count) * 100)
  )
)

write.csv(audit_summary, "outputs/tables/02_cleaning_audit_summary.csv", row.names = FALSE)
write.csv(cleaned_df, "data/cleaned/cleaned_taxi_sample.csv", row.names = FALSE)
nanoparquet::write_parquet(cleaned_df, "data/cleaned/cleaned_taxi_sample.parquet")

cat("[SUCCESS] Cleaned analysis dataset saved to data/cleaned/cleaned_taxi_sample.parquet and .csv\n")
cat("[SUCCESS] Audit summary exported to outputs/tables/02_cleaning_audit_summary.csv\n")
