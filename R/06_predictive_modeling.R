# ==============================================================================
# Script: 06_predictive_modeling.R
# Project: NYC Taxi Trip Data Analysis and Predictive Modeling Using R
# Author: praveena611 (YuvaIntern Virtual R Data Analyst Internship)
# Seed: 12345
# ==============================================================================

set.seed(12345)
cat("======================================================================\n")
cat("STEP 6: PREDICTIVE MACHINE LEARNING MODELING & VALIDATION\n")
cat("======================================================================\n")

suppressPackageStartupMessages({
  library(nanoparquet)
  library(data.table)
  library(dplyr)
  library(pROC)
  library(ggplot2)
  library(randomForest)
})

cat("[INFO] Loading cleaned analysis dataset...\n")
dt <- as.data.table(nanoparquet::read_parquet("data/cleaned/cleaned_taxi_sample.parquet"))

# Prepare modeling dataset
model_dt <- dt[, .(
  high_fare,
  trip_distance,
  trip_duration_min,
  pickup_hour,
  is_weekend,
  peak_hour,
  passenger_count,
  RatecodeID = factor(RatecodeID)
)]

# ------------------------------------------------------------------------------
# 1. Train / Test Split (80% Train, 20% Test)
# ------------------------------------------------------------------------------
set.seed(12345)
n_total <- nrow(model_dt)
train_idx <- sample(seq_len(n_total), size = round(0.80 * n_total))
train_dt <- model_dt[train_idx]
test_dt <- model_dt[-train_idx]

cat(sprintf("[SPLIT] Training Set: %s rows (80%%) | Test Set: %s rows (20%%)\n",
            format(nrow(train_dt), big.mark = ","), format(nrow(test_dt), big.mark = ",")))

# ------------------------------------------------------------------------------
# 2. 5-Fold Cross-Validation on Training Data
# ------------------------------------------------------------------------------
cat("\n[CV] Executing 5-Fold Cross-Validation on Training Set...\n")
k_folds <- 5
folds <- sample(rep(1:k_folds, length.out = nrow(train_dt)))
cv_accuracies <- numeric(k_folds)
cv_aucs <- numeric(k_folds)

for (k in 1:k_folds) {
  val_idx <- which(folds == k)
  fold_train <- train_dt[-val_idx]
  fold_val <- train_dt[val_idx]
  
  fold_glm <- glm(
    high_fare ~ trip_distance + trip_duration_min + pickup_hour + is_weekend + peak_hour + passenger_count + RatecodeID,
    data = fold_train,
    family = binomial(link = "logit")
  )
  
  preds_prob <- predict(fold_glm, newdata = fold_val, type = "response")
  preds_class <- fifelse(preds_prob >= 0.5, 1, 0)
  
  cv_accuracies[k] <- mean(preds_class == fold_val$high_fare)
  roc_k <- roc(fold_val$high_fare, preds_prob, quiet = TRUE)
  cv_aucs[k] <- as.numeric(auc(roc_k))
  
  cat(sprintf("  Fold %d: Accuracy = %.4f | AUC = %.4f\n", k, cv_accuracies[k], cv_aucs[k]))
}

cat(sprintf("[CV RESULT] Mean 5-Fold CV Accuracy: %.4f (SD: %.4f) | Mean AUC: %.4f (SD: %.4f)\n",
            mean(cv_accuracies), sd(cv_accuracies), mean(cv_aucs), sd(cv_aucs)))

# ------------------------------------------------------------------------------
# 3. Fit Final Multivariable Logistic Regression Model
# ------------------------------------------------------------------------------
cat("\n[MODEL] Fitting Final Logistic Regression Model on Full Training Set...\n")
final_logit <- glm(
  high_fare ~ trip_distance + trip_duration_min + pickup_hour + is_weekend + peak_hour + passenger_count + RatecodeID,
  data = train_dt,
  family = binomial(link = "logit")
)

# Extract Coefficients and Odds Ratios
coef_summary <- summary(final_logit)$coefficients
odds_ratios <- exp(coef_summary[, "Estimate"])
ci_lower <- exp(coef_summary[, "Estimate"] - 1.96 * coef_summary[, "Std. Error"])
ci_upper <- exp(coef_summary[, "Estimate"] + 1.96 * coef_summary[, "Std. Error"])

odds_ratio_dt <- data.table(
  Feature = rownames(coef_summary),
  Estimate_Beta = round(coef_summary[, "Estimate"], 4),
  Std_Error = round(coef_summary[, "Std. Error"], 4),
  z_value = round(coef_summary[, "z value"], 2),
  p_value = format.pval(coef_summary[, "Pr(>|z|)"], eps = 1e-16),
  Odds_Ratio = round(odds_ratios, 4),
  CI_95_Lower = round(ci_lower, 4),
  CI_95_Upper = round(ci_upper, 4)
)

cat("\n--- LOGISTIC REGRESSION ODDS RATIOS ---\n")
print(odds_ratio_dt)

# ------------------------------------------------------------------------------
# 4. Holdout Test Set Performance Evaluation
# ------------------------------------------------------------------------------
cat("\n[EVALUATION] Scoring Unseen Test Set...\n")
test_probs <- predict(final_logit, newdata = test_dt, type = "response")
test_preds <- fifelse(test_probs >= 0.5, 1, 0)
actuals <- test_dt$high_fare

# Confusion Matrix Elements
tp <- sum(test_preds == 1 & actuals == 1)
tn <- sum(test_preds == 0 & actuals == 0)
fp <- sum(test_preds == 1 & actuals == 0)
fn <- sum(test_preds == 0 & actuals == 1)

accuracy <- (tp + tn) / (tp + tn + fp + fn)
precision <- tp / (tp + fp)
recall <- tp / (tp + fn) # Sensitivity
specificity <- tn / (tn + fp)
f1_score <- 2 * (precision * recall) / (precision + recall)
balanced_acc <- (recall + specificity) / 2

# ROC and AUC Calculation
roc_obj <- roc(actuals, test_probs, quiet = TRUE)
auc_val <- as.numeric(auc(roc_obj))

cat(sprintf("  Accuracy:          %.4f (%.2f%%)\n", accuracy, accuracy * 100))
cat(sprintf("  Precision (PPV):   %.4f (%.2f%%)\n", precision, precision * 100))
cat(sprintf("  Recall (Sens):     %.4f (%.2f%%)\n", recall, recall * 100))
cat(sprintf("  Specificity:       %.4f (%.2f%%)\n", specificity, specificity * 100))
cat(sprintf("  F1-Score:          %.4f\n", f1_score))
cat(sprintf("  Balanced Accuracy: %.4f\n", balanced_acc))
cat(sprintf("  ROC-AUC Score:     %.4f\n", auc_val))

# Confusion Matrix Table
cm_dt <- data.table(
  Actual_Class = c("Actual Negative (Fare < $25)", "Actual Positive (Fare >= $25)"),
  Pred_Negative = c(tn, fn),
  Pred_Positive = c(fp, tp)
)

# Metrics Summary Table
metrics_dt <- data.table(
  Metric = c(
    "Accuracy", "Sensitivity (Recall)", "Specificity",
    "Precision (PPV)", "F1-Score", "Balanced Accuracy",
    "Area Under ROC Curve (AUC)", "5-Fold CV Accuracy Mean", "5-Fold CV AUC Mean"
  ),
  Value = c(
    round(accuracy, 4), round(recall, 4), round(specificity, 4),
    round(precision, 4), round(f1_score, 4), round(balanced_acc, 4),
    round(auc_val, 4), round(mean(cv_accuracies), 4), round(mean(cv_aucs), 4)
  )
)

# ------------------------------------------------------------------------------
# 5. Complementary Random Forest Benchmark Model
# ------------------------------------------------------------------------------
cat("\n[BENCHMARK] Training Complementary Random Forest Classifier...\n")
set.seed(12345)
rf_sample_idx <- sample(nrow(train_dt), 25000)
rf_train_dt <- copy(train_dt[rf_sample_idx])
rf_train_dt[, high_fare := factor(high_fare, levels = c(0, 1), labels = c("Low", "High"))]

rf_model <- randomForest(
  high_fare ~ trip_distance + trip_duration_min + pickup_hour + is_weekend + peak_hour + passenger_count + RatecodeID,
  data = rf_train_dt,
  ntree = 100,
  importance = TRUE
)

rf_imp <- importance(rf_model)
rf_imp_dt <- data.table(
  Feature = rownames(rf_imp),
  MeanDecreaseGini = round(rf_imp[, "MeanDecreaseGini"], 2)
)[order(-MeanDecreaseGini)]

cat("--- RANDOM FOREST FEATURE IMPORTANCE (GINI) ---\n")
print(rf_imp_dt)

# ------------------------------------------------------------------------------
# 6. Save Model Artifacts, Tables & Plots
# ------------------------------------------------------------------------------
saveRDS(final_logit, "outputs/model/logistic_regression_model.rds")
saveRDS(rf_model, "outputs/model/random_forest_model.rds")
write.csv(metrics_dt, "outputs/tables/06_model_performance_metrics.csv", row.names = FALSE)
write.csv(odds_ratio_dt, "outputs/tables/06_odds_ratios_table.csv", row.names = FALSE)
write.csv(cm_dt, "outputs/tables/06_confusion_matrix.csv", row.names = FALSE)

# Plot 12: ROC Curve Plot
cat("\n[PLOT 12] Generating ROC Curve Visualization...\n")
roc_df <- data.frame(
  Specificity = 1 - roc_obj$specificities,
  Sensitivity = roc_obj$sensitivities
)

p12 <- ggplot(roc_df, aes(x = Specificity, y = Sensitivity)) +
  geom_line(color = "#2980b9", linewidth = 1.4) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "#7f8c8d", linewidth = 0.8) +
  annotate("text", x = 0.65, y = 0.25, label = sprintf("Logistic Regression AUC = %.4f", auc_val),
           color = "#2980b9", fontface = "bold", size = 4.5) +
  labs(
    title = "Receiver Operating Characteristic (ROC) Curve",
    subtitle = "Predictive performance of High-Fare classification model on holdout test set",
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)",
    caption = "Source: NYC TLC Yellow Taxi Predictive Analytics Pipeline"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#1a252f"),
    axis.title = element_text(face = "bold", size = 11, color = "#2c3e50")
  )

ggsave("outputs/plots/plot_12_roc_curve.png", p12, width = 8.5, height = 5.5, dpi = 300)

# Plot 13: Feature Importance Plot
cat("[PLOT 13] Generating Random Forest Feature Importance Chart...\n")
p13 <- ggplot(rf_imp_dt, aes(x = reorder(Feature, MeanDecreaseGini), y = MeanDecreaseGini)) +
  geom_col(fill = "#34495e", width = 0.7) +
  coord_flip() +
  labs(
    title = "Predictive Feature Importance (Mean Decrease Gini)",
    subtitle = "Ranking of trip determinants driving High-Fare probability",
    x = "Predictor Variable",
    y = "Mean Decrease in Gini Impurity",
    caption = "Derived from Random Forest Benchmark Model (ntree = 100)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#1a252f"),
    axis.title = element_text(face = "bold", size = 11, color = "#2c3e50")
  )

ggsave("outputs/plots/plot_13_feature_importance.png", p13, width = 8.5, height = 5.5, dpi = 300)

cat("[SUCCESS] Predictive modeling completed. Models, tables, and ROC plots exported.\n")
