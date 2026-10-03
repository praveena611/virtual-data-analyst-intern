# NYC Taxi Trip Data Analysis and Predictive Modeling Using R 🚕📊

[![R Version](https://img.shields.io/badge/R-4.4%2B-blue.svg)](https://cloud.r-project.org/)
[![YuvaIntern](https://img.shields.io/badge/Internship-YuvaIntern%20Virtual%20Analytics-orange.svg)](https://yuvaintern.com/)
[![Dataset](https://img.shields.io/badge/Dataset-NYC%20TLC%20Yellow%20Taxi-yellow.svg)](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)
[![Status](https://img.shields.io/badge/Status-Completed%20(Weeks%201--4)-brightgreen.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An industrial-grade, reproducible Data Analytics and Machine Learning project developed for the **YuvaIntern Virtual R Data Analyst Internship (Weeks 1–4)**. This project analyzes **9,554,778 raw trip records** from the NYC Taxi and Limousine Commission (TLC) using out-of-core streaming pipelines, statistical inference, publication-grade ggplot2 visualizations, and predictive classification modeling.

---

## 📌 Executive Project Highlights

* **Total Raw Data Volume**: **9,554,778 records** (153 MB compressed Parquet across Jan, Feb, Mar 2024).
* **Valid Cleaned Population**: **8,249,634 records** (**86.34% retention rate** after rigorous multi-tier anomaly filtering).
* **Analytical Sample**: **412,481 records** (Statistically representative stratified subsample evaluated with `set.seed(12345)`).
* **Visual Analytics**: **13 high-resolution ggplot2 plots** (300 DPI) examining temporal demand cycles, daytime congestion speed curves, tipping preset preferences, and spatial concentration.
* **Inferential Hypotheses**: **4 formal statistical tests** (Welch's two-sample $t$-tests, One-Way ANOVA, Chi-Square test of independence) with effect size calculations.
* **Predictive ML Classification**: Multivariable Logistic Regression and Random Forest models achieving **99.06% Accuracy**, **97.84% Precision**, **96.88% Recall**, and **0.9992 ROC-AUC** for predicting High-Fare trips ($\ge \$25$).
* **Professional Deliverables**: **4 formal DOCX internship reports** generated in `reports/`.

---

## 📁 Repository Structure

```text
NYC-Taxi-R-Analytics/
├── data/
│   ├── raw/                       # Immutable raw TLC Parquet files (tracked via .gitkeep)
│   └── cleaned/                   # Cleaned analysis datasets (CSV & Parquet)
├── R/                             # Sequential reproducible R scripts (Weeks 1–4)
│   ├── 00_environment_setup.R     # Environment initialization, seed (12345), directory creation
│   ├── 01_data_download_import.R  # Parquet ingestion, metadata auditing, schema extraction
│   ├── 02_data_cleaning.R         # Quality assurance, anomaly pruning, feature engineering
│   ├── 03_preliminary_analysis.R  # Descriptive statistics, skewness/kurtosis, correlation matrices
│   ├── 04_visualization.R         # 11 publication-grade ggplot2 visualization figures
│   ├── 05_statistical_analysis.R  # 4 formal hypothesis tests, assumptions, and effect sizes
│   ├── 06_predictive_modeling.R   # Logistic regression, 5-fold CV, Random Forest, ROC curve
│   ├── 07_final_analysis.R        # Synthesis, verification audit, and DOCX report compiler
│   └── build_reports.py           # DOCX document builder with embedded tables & plots
├── outputs/
│   ├── tables/                    # CSV quantitative analysis tables
│   │   ├── 01_raw_data_summary.csv
│   │   ├── 02_cleaning_audit_summary.csv
│   │   ├── 03_descriptive_statistics.csv
│   │   ├── 03_correlation_matrix_pearson.csv
│   │   ├── 03_correlation_matrix_spearman.csv
│   │   ├── 05_hypothesis_testing_results.csv
│   │   ├── 06_model_performance_metrics.csv
│   │   ├── 06_odds_ratios_table.csv
│   │   └── 06_confusion_matrix.csv
│   ├── plots/                     # 13 high-resolution visualization figures (300 DPI PNG)
│   │   ├── plot_01_hourly_demand.png
│   │   ├── plot_02_day_of_week_trends.png
│   │   ├── plot_03_trip_distance_distribution.png
│   │   ├── plot_04_duration_vs_distance.png
│   │   ├── plot_05_fare_by_passenger_count.png
│   │   ├── plot_06_payment_type_tips.png
│   │   ├── plot_07_speed_by_hour.png
│   │   ├── plot_08_fare_per_mile_by_hour.png
│   │   ├── plot_09_top_pickup_locations.png
│   │   ├── plot_10_correlation_heatmap.png
│   │   ├── plot_11_high_fare_probability.png
│   │   ├── plot_12_roc_curve.png
│   │   └── plot_13_feature_importance.png
│   ├── model/                     # Trained machine learning model artifacts (.rds)
│   │   ├── logistic_regression_model.rds
│   │   └── random_forest_model.rds
│   └── environment/               # Reproducibility audit & session metadata
│       └── session_info.txt
├── reports/                       # 4 Executive DOCX Reports for YuvaIntern
│   ├── Week_1_Data_Cleaning.docx
│   ├── Week_2_Data_Visualization.docx
│   ├── Week_3_Statistical_Predictive_Modeling.docx
│   └── Week_4_Final_Comprehensive_Report.docx
├── renv.lock                      # Locked dependency state for R
├── .renvignore                    # Renv scan optimization rules
├── .gitignore                     # Exclusion rules for large data/runtimes
└── README.md                      # Comprehensive documentation
```

---

## 🔄 Weekly Internship Breakdown

### 🗓️ Week 1: Data Ingestion, Cleaning & Feature Engineering
* **Data Sources**: Automated ingestion of NYC TLC Q1 2024 Parquet files (Jan, Feb, Mar).
* **Cleaning Rules**:
  * Filtered non-positive/extreme fares: $\$2.50 \le \text{fare\_amount} \le \$300.00$.
  * Filtered duration anomalies: $1.0 \text{ min} \le \text{trip\_duration} \le 180.0 \text{ min}$.
  * Distance validation: $0.10 \text{ mi} \le \text{trip\_distance} \le 50.0 \text{ mi}$.
  * Physical speed boundaries: $1.0 \text{ mph} \le \text{speed\_mph} \le 65.0 \text{ mph}$.
  * Enforced valid passenger counts ($1 \le n \le 6$) and standard rate codes.
* **Feature Engineering**: Created `pickup_hour`, `pickup_day`, `is_weekend`, `peak_hour`, `fare_per_mile`, `tip_percentage`, and `high_fare` ($\ge \$25$).

### 🗓️ Week 2: Exploratory Data Visualization (ggplot2)
* Built a unified custom theme (`theme_taxi`) with high-contrast accessible styling.
* Generated **11 publication-grade figures** covering:
  1. Diurnal demand curves (commuter morning & evening rush peaks).
  2. Day-of-week trends (Thursday–Saturday peak trip volume).
  3. Distance density distributions (median urban trip: 1.70 miles).
  4. GAM non-linear smoothing of trip duration vs. distance.
  5. Boxplots of fare amounts across passenger counts (1 to 6).
  6. Credit card tipping distribution (peaks at 20%, 25%, and 30% default POS buttons).
  7. Diurnal traffic speed congestion curves ($<9.5$ mph during 8 AM–6 PM business hours).
  8. Average fare yield ($\$ / \text{mile}$) across 24 hours.
  9. Spatial ranking of top 10 busiest TLC pickup zones.
  10. Correlation matrix heatmap of numerical attributes.
  11. High-fare trip probability curves.

### 🗓️ Week 3: Statistical Inference & Predictive Modeling
* **Hypothesis Testing**:
  * **H1 (Welch $t$-test)**: Weekend vs. Weekday Trip Distance ($t = -9.486, p < 10^{-16}$, Weekday $= 3.285$ mi vs Weekend $= 3.150$ mi).
  * **H2 (One-tailed $t$-test)**: Peak vs. Off-Peak Fares ($t = 9.693, p < 10^{-16}$, Peak $=\$18.96$ vs Off-Peak $=\$18.29$).
  * **H3 (One-Way ANOVA)**: Fare variation across TLC Rate Codes ($F = 94,988.04, p < 10^{-16}, \eta^2 = 0.4795$).
  * **H4 (Chi-Square Test)**: Payment Type vs. High-Fare association ($\chi^2 = 73.43, p < 10^{-16}$).
* **Predictive Classification**:
  * Stratified 80/20 train/test split with **5-Fold Cross-Validation** on 329,985 training records.
  * Fit multivariable Logistic Regression ($N = 412,481$) and Random Forest benchmark.
  * Achieved **99.06% Accuracy**, **97.84% Precision**, **96.88% Recall**, and **0.9992 ROC-AUC** on holdout test set.

### 🗓️ Week 4: Final Synthesis & Professional Reporting
* Compiled all empirical findings, methodology, and visualizations into **4 polished DOCX reports**:
  * `reports/Week_1_Data_Cleaning.docx`
  * `reports/Week_2_Data_Visualization.docx`
  * `reports/Week_3_Statistical_Predictive_Modeling.docx`
  * `reports/Week_4_Final_Comprehensive_Report.docx`
* Formulated actionable business strategies (dynamic airport staging, congestion-aware routing, POS tip preset optimization, and driver shift scheduling).

---

## 📊 Summary of Actual Quantitative Results

### 1. Data Cleaning Audit
| Metric | Count | Percentage |
| :--- | :--- | :--- |
| **Total Raw Ingested Records** | 9,554,778 | 100.00% |
| **Missing Values Removed** | 751,962 | 7.87% |
| **Anomalies & Outliers Pruned** | 553,182 | 5.79% |
| **Total Valid Cleaned Population** | 8,249,634 | **86.34% Retention** |
| **Analytical Sample Size** | 412,481 | Stratified (Seed 12345) |

### 2. Descriptive Statistics Summary
| Variable | Mean | Std Dev | Median | Q1 (25%) | Q3 (75%) | IQR | Min | Max |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Trip Distance (mi)** | 3.24 | 4.29 | 1.70 | 1.02 | 3.10 | 2.08 | 0.10 | 49.63 |
| **Trip Duration (min)** | 15.14 | 11.74 | 11.87 | 7.35 | 19.02 | 11.67 | 1.00 | 178.45 |
| **Fare Amount ($)** | 18.40 | 16.64 | 12.80 | 8.60 | 19.80 | 11.20 | 2.80 | 300.00 |
| **Speed (mph)** | 11.26 | 6.45 | 9.54 | 7.24 | 12.96 | 5.72 | 1.00 | 63.93 |
| **Tip Amount ($)** | 3.60 | 3.86 | 2.90 | 1.50 | 4.34 | 2.84 | 0.00 | 300.00 |
| **Total Amount ($)** | 27.56 | 21.44 | 20.30 | 15.60 | 28.90 | 13.30 | 4.50 | 414.74 |

### 3. Predictive Model Evaluation on Holdout Test Set ($N = 82,496$)
| Metric | Logistic Regression | Random Forest Benchmark |
| :--- | :--- | :--- |
| **Accuracy** | **99.06%** | **99.01%** |
| **Precision (PPV)** | **97.84%** | **97.60%** |
| **Sensitivity (Recall)** | **96.88%** | **96.75%** |
| **Specificity** | **99.53%** | **99.48%** |
| **F1-Score** | **0.9736** | **0.9717** |
| **Balanced Accuracy** | **0.9821** | **0.9812** |
| **ROC-AUC Score** | **0.9992** | **0.9989** |
| **5-Fold CV Accuracy Mean** | **0.9901 (SD: 0.0002)** | — |
| **5-Fold CV AUC Mean** | **0.9992 (SD: 0.0001)** | — |

---

## 🚀 Reproduction Instructions

### 1. Prerequisites
Ensure **R (version 4.4.x or 4.6.x)** and **Python 3.9+** are installed.

### 2. Clone Repository
```bash
git clone https://github.com/praveena611/virtual-data-analyst-intern.git
cd virtual-data-analyst-intern
```

### 3. Execute End-to-End Pipeline
Run the sequential scripts from the root directory:

```bash
# 1. Set up environment & directories
Rscript R/00_environment_setup.R

# 2. Ingest raw parquet datasets
Rscript R/01_data_download_import.R

# 3. Clean data & engineer features
Rscript R/02_data_cleaning.R

# 4. Compute preliminary descriptive statistics
Rscript R/03_preliminary_analysis.R

# 5. Generate 11 ggplot2 visual charts
Rscript R/04_visualization.R

# 6. Conduct statistical hypothesis tests
Rscript R/05_statistical_analysis.R

# 7. Train predictive models & evaluate metrics
Rscript R/06_predictive_modeling.R

# 8. Verify artifacts and build 4 DOCX reports
Rscript R/07_final_analysis.R
```

---

## 👤 Author

* **Intern **: **praveena611**
* **GitHub**: [@praveena611](https://github.com/praveena611)
* **Program**: YuvaIntern Virtual R Data Analyst Internship

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
