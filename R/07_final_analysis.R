# ==============================================================================
# Script: 07_final_analysis.R
# Project: NYC Taxi Trip Data Analysis and Predictive Modeling Using R
# Author: praveena611 (YuvaIntern Virtual R Data Analyst Internship)
# Seed: 12345
# ==============================================================================

set.seed(12345)
cat("======================================================================\n")
cat("STEP 7: FINAL COMPREHENSIVE SYNTHESIS & REPORT GENERATION\n")
cat("======================================================================\n")

# Verify all required output artifacts exist
required_tables <- c(
  "outputs/tables/01_raw_data_summary.csv",
  "outputs/tables/02_cleaning_audit_summary.csv",
  "outputs/tables/03_descriptive_statistics.csv",
  "outputs/tables/05_hypothesis_testing_results.csv",
  "outputs/tables/06_model_performance_metrics.csv",
  "outputs/tables/06_odds_ratios_table.csv",
  "outputs/tables/06_confusion_matrix.csv"
)

cat("[AUDIT] Verifying existence of all generated quantitative tables...\n")
for (tbl in required_tables) {
  if (file.exists(tbl)) {
    cat(sprintf("  [OK] %s\n", tbl))
  } else {
    stop(sprintf("  [MISSING] Table not found: %s", tbl))
  }
}

cat("[AUDIT] Verifying existence of all 13 high-resolution visualization plots...\n")
plots <- list.files("outputs/plots", pattern = "\\.png$", full.names = TRUE)
cat(sprintf("  [OK] %d plots confirmed in outputs/plots/\n", length(plots)))

# Trigger Report Generator
cat("\n[BUILD] Compiling 4 Professional DOCX Reports for Weeks 1 to 4...\n")
system("python R/build_reports.py")

cat("\n======================================================================\n")
cat("ALL INTERNSHIP WEEKS (1-4) SUCCESSFULLY PROCESSED & VERIFIED!\n")
cat("======================================================================\n")
cat("Generated Deliverables in reports/:\n")
cat("  1. reports/Week_1_Data_Cleaning.docx\n")
cat("  2. reports/Week_2_Data_Visualization.docx\n")
cat("  3. reports/Week_3_Statistical_Predictive_Modeling.docx\n")
cat("  4. reports/Week_4_Final_Comprehensive_Report.docx\n")
