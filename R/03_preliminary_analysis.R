# ==============================================================================
# Script: 03_preliminary_analysis.R
# Project: NYC Taxi Trip Data Analysis and Predictive Modeling Using R
# Author: praveena611 (YuvaIntern Virtual R Data Analyst Internship)
# Seed: 12345
# ==============================================================================

set.seed(12345)
cat("======================================================================\n")
cat("STEP 3: PRELIMINARY STATISTICAL SUMMARY & CORRELATION ANALYSIS\n")
cat("======================================================================\n")

suppressPackageStartupMessages({
  library(nanoparquet)
  library(data.table)
  library(dplyr)
  library(e1071)
})

cat("[INFO] Loading cleaned analysis sample dataset...\n")
dt <- as.data.table(nanoparquet::read_parquet("data/cleaned/cleaned_taxi_sample.parquet"))
cat(sprintf("[INFO] Successfully loaded %s rows and %d columns\n",
            format(nrow(dt), big.mark = ","), ncol(dt)))

num_cols <- c(
  "trip_distance", "trip_duration_min", "fare_amount",
  "speed_mph", "tip_amount", "tip_percentage", "total_amount", "fare_per_mile"
)

# Function for comprehensive descriptive metrics
calc_descriptives <- function(data, columns) {
  res_list <- list()
  for (col in columns) {
    x <- data[[col]]
    q1 <- quantile(x, 0.25, na.rm = TRUE)
    q3 <- quantile(x, 0.75, na.rm = TRUE)
    res_list[[col]] <- data.table(
      Variable = col,
      N = length(x),
      Mean = round(mean(x, na.rm = TRUE), 2),
      SD = round(sd(x, na.rm = TRUE), 2),
      Median = round(median(x, na.rm = TRUE), 2),
      Q1_25pct = round(q1, 2),
      Q3_75pct = round(q3, 2),
      IQR = round(q3 - q1, 2),
      Min = round(min(x, na.rm = TRUE), 2),
      Max = round(max(x, na.rm = TRUE), 2),
      Skewness = round(e1071::skewness(x, na.rm = TRUE), 2),
      Kurtosis = round(e1071::kurtosis(x, na.rm = TRUE), 2)
    )
  }
  return(rbindlist(res_list))
}

desc_table <- calc_descriptives(dt, num_cols)
cat("\n--- DESCRIPTIVE STATISTICS SUMMARY TABLE ---\n")
print(desc_table)

# Export descriptive statistics
write.csv(desc_table, "outputs/tables/03_descriptive_statistics.csv", row.names = FALSE)
cat("[SUCCESS] Descriptive statistics written to outputs/tables/03_descriptive_statistics.csv\n")

# Correlation Analysis
numeric_matrix <- na.omit(dt[, ..num_cols])
pearson_corr <- round(cor(numeric_matrix, method = "pearson"), 4)
spearman_corr <- round(cor(numeric_matrix, method = "spearman"), 4)

cat("\n--- PEARSON CORRELATION MATRIX ---\n")
print(pearson_corr)

write.csv(pearson_corr, "outputs/tables/03_correlation_matrix_pearson.csv")
write.csv(spearman_corr, "outputs/tables/03_correlation_matrix_spearman.csv")
cat("[SUCCESS] Correlation matrices exported to outputs/tables/\n")
