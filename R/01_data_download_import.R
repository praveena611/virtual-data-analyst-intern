# ==============================================================================
# Script: 01_data_download_import.R
# Project: NYC Taxi Trip Data Analysis and Predictive Modeling Using R
# Author: praveena611 (YuvaIntern Virtual R Data Analyst Internship)
# Seed: 12345
# ==============================================================================

set.seed(12345)
cat("======================================================================\n")
cat("STEP 1: DATA INGESTION & METADATA PROFILING\n")
cat("======================================================================\n")

suppressPackageStartupMessages({
  library(nanoparquet)
  library(data.table)
  library(dplyr)
})

# Define raw files to ingest
raw_files <- list.files("data/raw", pattern = "\\.parquet$", full.names = TRUE)

if (length(raw_files) == 0) {
  cat("[INFO] No raw parquet files found. Downloading NYC TLC Yellow Taxi 2024 (Q1)...\n")
  urls <- c(
    "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-01.parquet",
    "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-02.parquet",
    "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-03.parquet"
  )
  for (u in urls) {
    dest <- file.path("data/raw", basename(u))
    if (!file.exists(dest)) {
      cat(sprintf("[DOWNLOAD] Downloading: %s\n", basename(u)))
      download.file(u, dest, mode = "wb")
    }
  }
  raw_files <- list.files("data/raw", pattern = "\\.parquet$", full.names = TRUE)
}

cat(sprintf("[INFO] Discovered %d raw parquet files in data/raw/\n", length(raw_files)))

summary_list <- list()
total_raw_rows <- 0

for (f in raw_files) {
  file_info <- file.info(f)
  file_size_mb <- round(file_info$size / (1024 * 1024), 2)
  
  # Read schema metadata
  meta <- nanoparquet::parquet_info(f)
  num_rows <- meta$num_rows
  num_cols <- meta$num_columns
  total_raw_rows <- total_raw_rows + num_rows
  
  summary_list[[length(summary_list) + 1]] <- data.table(
    file_name = basename(f),
    size_mb = file_size_mb,
    rows = num_rows,
    columns = num_cols
  )
  cat(sprintf("  -> File: %-32s | Size: %6.2f MB | Rows: %10s | Columns: %d\n",
              basename(f), file_size_mb, format(num_rows, big.mark = ","), num_cols))
}

raw_summary_dt <- rbindlist(summary_list)
cat(sprintf("\n[SUMMARY] Total Raw Ingested Records: %s rows across %d months\n",
            format(total_raw_rows, big.mark = ","), length(raw_files)))

# Export metadata summary
write.csv(raw_summary_dt, "outputs/tables/01_raw_data_summary.csv", row.names = FALSE)
cat("[SUCCESS] Raw data profiling exported to outputs/tables/01_raw_data_summary.csv\n")
