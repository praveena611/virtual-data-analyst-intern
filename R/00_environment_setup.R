# ==============================================================================
# Script: 00_environment_setup.R
# Project: NYC Taxi Trip Data Analysis and Predictive Modeling Using R
# Author: praveena611 (YuvaIntern Virtual R Data Analyst Internship)
# Seed: 12345
# ==============================================================================

# Ensure strict reproducibility
set.seed(12345)

cat("[INFO] Initializing Project Environment...\n")

# Required Packages
required_packages <- c(
  "data.table",
  "dplyr",
  "ggplot2",
  "pROC",
  "corrplot",
  "nanoparquet",
  "arrow",
  "randomForest",
  "e1071",
  "officer",
  "flextable",
  "renv"
)

# Install missing packages if any
installed <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!pkg %in% installed) {
    cat(sprintf("[INFO] Installing package: %s\n", pkg))
    install.packages(pkg, repos = "https://cloud.r-project.org", type = "binary")
  }
}

# Load packages
suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(ggplot2)
  library(pROC)
  library(corrplot)
  library(nanoparquet)
  library(officer)
  library(flextable)
})

# Create Directory Hierarchy
dirs <- c(
  "data/raw",
  "data/cleaned",
  "R",
  "outputs/tables",
  "outputs/plots",
  "outputs/model",
  "outputs/environment",
  "reports",
  "screenshots"
)

for (d in dirs) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
    cat(sprintf("[INFO] Created directory: %s\n", d))
  }
}

# Save Environment Session Info
session_file <- "outputs/environment/session_info.txt"
sink(session_file)
cat("======================================================================\n")
cat("NYC Taxi Trip R Analytics - Environment & Session Information\n")
cat(sprintf("Timestamp: %s\n", Sys.time()))
cat(sprintf("R Version: %s\n", R.version.string))
cat(sprintf("Platform: %s\n", R.version$platform))
cat("======================================================================\n\n")
print(sessionInfo())
sink()

cat(sprintf("[SUCCESS] Environment initialized. Session info written to: %s\n", session_file))
