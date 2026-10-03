# ==============================================================================
# Script: 05_statistical_analysis.R
# Project: NYC Taxi Trip Data Analysis and Predictive Modeling Using R
# Author: praveena611 (YuvaIntern Virtual R Data Analyst Internship)
# Seed: 12345
# ==============================================================================

set.seed(12345)
cat("======================================================================\n")
cat("STEP 5: STATISTICAL HYPOTHESIS TESTING & INFERENTIAL ANALYSIS\n")
cat("======================================================================\n")

suppressPackageStartupMessages({
  library(nanoparquet)
  library(data.table)
  library(dplyr)
})

cat("[INFO] Loading cleaned dataset for inferential tests...\n")
dt <- as.data.table(nanoparquet::read_parquet("data/cleaned/cleaned_taxi_sample.parquet"))

test_results_list <- list()

# ------------------------------------------------------------------------------
# Test 1: Weekend vs Weekday Trip Distance (Welch's t-test & Wilcoxon)
# ------------------------------------------------------------------------------
cat("\n[HYPOTHESIS TEST 1] Weekend vs. Weekday Trip Distance\n")
weekend_dist <- dt[is_weekend == 1, trip_distance]
weekday_dist <- dt[is_weekend == 0, trip_distance]

t1 <- t.test(weekend_dist, weekday_dist)
mean_diff_1 <- mean(weekend_dist) - mean(weekday_dist)
pooled_sd_1 <- sqrt((sd(weekend_dist)^2 + sd(weekday_dist)^2) / 2)
cohens_d_1 <- mean_diff_1 / pooled_sd_1

cat(sprintf("  Weekend Mean: %.3f mi | Weekday Mean: %.3f mi | Difference: %.3f mi\n",
            mean(weekend_dist), mean(weekday_dist), mean_diff_1))
cat(sprintf("  t-statistic: %.4f | df: %.1f | p-value: %e | Cohen's d: %.4f\n",
            t1$statistic, t1$parameter, t1$p.value, cohens_d_1))

test_results_list[[1]] <- data.table(
  Hypothesis_ID = "H1",
  Test_Name = "Two-Sample Welch t-test",
  Variables = "Trip Distance (Weekend vs Weekday)",
  Null_Hypothesis = "Mean trip distance is identical on weekends and weekdays (mu_wknd = mu_wkdy)",
  Alt_Hypothesis = "Mean trip distance differs between weekends and weekdays (mu_wknd != mu_wkdy)",
  Group_A_Mean = round(mean(weekend_dist), 3),
  Group_B_Mean = round(mean(weekday_dist), 3),
  Test_Statistic = round(as.numeric(t1$statistic), 4),
  Degrees_of_Freedom = round(as.numeric(t1$parameter), 1),
  P_Value = format.pval(t1$p.value, eps = 1e-16),
  Effect_Size_Metric = "Cohen's d",
  Effect_Size_Value = round(cohens_d_1, 4),
  Conclusion = ifelse(t1$p.value < 0.05, "Reject H0 (Statistically Significant)", "Fail to Reject H0")
)

# ------------------------------------------------------------------------------
# Test 2: Peak Hours vs Off-Peak Hours Fare Amount (Welch's t-test)
# ------------------------------------------------------------------------------
cat("\n[HYPOTHESIS TEST 2] Peak Hours vs. Off-Peak Hours Fare Amount\n")
peak_fare <- dt[peak_hour == 1, fare_amount]
offpeak_fare <- dt[peak_hour == 0, fare_amount]

t2 <- t.test(peak_fare, offpeak_fare, alternative = "greater")
mean_diff_2 <- mean(peak_fare) - mean(offpeak_fare)
pooled_sd_2 <- sqrt((sd(peak_fare)^2 + sd(offpeak_fare)^2) / 2)
cohens_d_2 <- mean_diff_2 / pooled_sd_2

cat(sprintf("  Peak Fare Mean: $%.2f | Off-Peak Mean: $%.2f | Diff: $%.2f\n",
            mean(peak_fare), mean(offpeak_fare), mean_diff_2))
cat(sprintf("  t-statistic: %.4f | df: %.1f | p-value: %e | Cohen's d: %.4f\n",
            t2$statistic, t2$parameter, t2$p.value, cohens_d_2))

test_results_list[[2]] <- data.table(
  Hypothesis_ID = "H2",
  Test_Name = "Two-Sample One-Tailed Welch t-test",
  Variables = "Fare Amount (Peak vs Off-Peak)",
  Null_Hypothesis = "Mean fare during peak hours <= off-peak hours",
  Alt_Hypothesis = "Mean fare during peak hours is significantly greater than off-peak",
  Group_A_Mean = round(mean(peak_fare), 3),
  Group_B_Mean = round(mean(offpeak_fare), 3),
  Test_Statistic = round(as.numeric(t2$statistic), 4),
  Degrees_of_Freedom = round(as.numeric(t2$parameter), 1),
  P_Value = format.pval(t2$p.value, eps = 1e-16),
  Effect_Size_Metric = "Cohen's d",
  Effect_Size_Value = round(cohens_d_2, 4),
  Conclusion = ifelse(t2$p.value < 0.05, "Reject H0 (Statistically Significant)", "Fail to Reject H0")
)

# ------------------------------------------------------------------------------
# Test 3: One-Way ANOVA across RatecodeID (Fare Amount Variation)
# ------------------------------------------------------------------------------
cat("\n[HYPOTHESIS TEST 3] One-Way ANOVA for Fare Amount Across Rate Codes\n")
anova_model <- aov(fare_amount ~ factor(RatecodeID), data = dt)
anova_summary <- summary(anova_model)[[1]]

f_stat <- anova_summary["factor(RatecodeID)", "F value"]
df_between <- anova_summary["factor(RatecodeID)", "Df"]
df_within <- anova_summary["Residuals", "Df"]
p_val_anova <- anova_summary["factor(RatecodeID)", "Pr(>F)"]
ss_between <- anova_summary["factor(RatecodeID)", "Sum Sq"]
ss_total <- sum(anova_summary[, "Sum Sq"])
eta_squared <- ss_between / ss_total

cat(sprintf("  F-statistic: %.2f | df: (%d, %d) | p-value: %e | Eta-squared: %.4f\n",
            f_stat, df_between, df_within, p_val_anova, eta_squared))

test_results_list[[3]] <- data.table(
  Hypothesis_ID = "H3",
  Test_Name = "One-Way ANOVA",
  Variables = "Fare Amount across Rate Codes (1=Standard, 2=JFK, 3=Newark, etc.)",
  Null_Hypothesis = "Mean fare amounts are identical across all Ratecode IDs (mu_1 = mu_2 = ... = mu_k)",
  Alt_Hypothesis = "At least one Ratecode ID has a significantly different mean fare",
  Group_A_Mean = round(mean(dt$fare_amount), 3),
  Group_B_Mean = NA_real_,
  Test_Statistic = round(as.numeric(f_stat), 4),
  Degrees_of_Freedom = df_between,
  P_Value = format.pval(p_val_anova, eps = 1e-16),
  Effect_Size_Metric = "Eta-squared (eta^2)",
  Effect_Size_Value = round(eta_squared, 4),
  Conclusion = ifelse(p_val_anova < 0.05, "Reject H0 (Statistically Significant)", "Fail to Reject H0")
)

# ------------------------------------------------------------------------------
# Test 4: Chi-Square Test of Independence (Payment Type vs High Fare)
# ------------------------------------------------------------------------------
cat("\n[HYPOTHESIS TEST 4] Chi-Square Test of Independence (Payment Type vs High Fare Target)\n")
contingency_tab <- table(dt$payment_label, dt$high_fare)
chi_test <- chisq.test(contingency_tab)
n_obs <- sum(contingency_tab)
cramers_v <- sqrt(chi_test$statistic / (n_obs * (min(dim(contingency_tab)) - 1)))

cat(sprintf("  Chi-Square Statistic: %.2f | df: %d | p-value: %e | Cramer's V: %.4f\n",
            chi_test$statistic, chi_test$parameter, chi_test$p.value, cramers_v))

test_results_list[[4]] <- data.table(
  Hypothesis_ID = "H4",
  Test_Name = "Pearson's Chi-Square Test of Independence",
  Variables = "Payment Type (Credit Card vs Cash) vs. High Fare Flag (>= $25)",
  Null_Hypothesis = "Payment Type and High-Fare trip status are statistically independent",
  Alt_Hypothesis = "Payment Type and High-Fare trip status are significantly associated",
  Group_A_Mean = NA_real_,
  Group_B_Mean = NA_real_,
  Test_Statistic = round(as.numeric(chi_test$statistic), 4),
  Degrees_of_Freedom = as.numeric(chi_test$parameter),
  P_Value = format.pval(chi_test$p.value, eps = 1e-16),
  Effect_Size_Metric = "Cramer's V",
  Effect_Size_Value = round(as.numeric(cramers_v), 4),
  Conclusion = ifelse(chi_test$p.value < 0.05, "Reject H0 (Statistically Significant)", "Fail to Reject H0")
)

results_table <- rbindlist(test_results_list)
cat("\n--- HYPOTHESIS TESTING SUMMARY TABLE ---\n")
print(results_table[, .(Hypothesis_ID, Test_Name, Test_Statistic, P_Value, Effect_Size_Metric, Effect_Size_Value, Conclusion)])

write.csv(results_table, "outputs/tables/05_hypothesis_testing_results.csv", row.names = FALSE)
cat("[SUCCESS] Hypothesis testing table written to outputs/tables/05_hypothesis_testing_results.csv\n")
