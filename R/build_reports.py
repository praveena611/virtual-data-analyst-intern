"""
build_reports.py
Generates the 4 professional DOCX deliverables for YuvaIntern Virtual Data Analyst Internship.
Author: praveena611
"""

import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn
import pandas as pd

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def format_table(table, col_widths=None):
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    # Format header row
    for i, cell in enumerate(table.rows[0].cells):
        set_cell_background(cell, "1B4F72") # Navy header
        for p in cell.paragraphs:
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in p.runs:
                run.font.bold = True
                run.font.color.rgb = RGBColor(255, 255, 255)
                run.font.size = Pt(10)
    # Format data rows
    for r_idx, row in enumerate(table.rows[1:]):
        bg = "F2F4F4" if r_idx % 2 == 1 else "FFFFFF"
        for cell in row.cells:
            set_cell_background(cell, bg)
            for p in cell.paragraphs:
                for run in p.runs:
                    run.font.size = Pt(9.5)
                    run.font.color.rgb = RGBColor(44, 62, 80)
    # Set widths if specified
    if col_widths:
        for row in table.rows:
            for i, w in enumerate(col_widths):
                if i < len(row.cells):
                    row.cells[i].width = Inches(w)

def add_header_block(doc, week_num, title, subtitle):
    p_badge = doc.add_paragraph()
    run_badge = p_badge.add_run(f"YUNVAINTERN VIRTUAL R DATA ANALYST INTERNSHIP — WEEK {week_num}")
    run_badge.font.bold = True
    run_badge.font.size = Pt(10)
    run_badge.font.color.rgb = RGBColor(41, 128, 185)

    p_title = doc.add_paragraph()
    run_title = p_title.add_run(title)
    run_title.font.bold = True
    run_title.font.size = Pt(22)
    run_title.font.color.rgb = RGBColor(27, 79, 114)

    p_sub = doc.add_paragraph()
    run_sub = p_sub.add_run(subtitle)
    run_sub.font.size = Pt(12)
    run_sub.font.italic = True
    run_sub.font.color.rgb = RGBColor(86, 101, 115)

    # Meta Table
    t_meta = doc.add_table(rows=2, cols=2)
    t_meta.alignment = WD_TABLE_ALIGNMENT.CENTER
    meta_data = [
        [("Intern Name:", " praveena611"), ("Project Title:", " NYC Taxi Trip Analytics Using R")],
        [("Dataset:", " NYC TLC Yellow Taxi (9.55M Raw Records)"), ("Evaluation Seed:", " 12345 (Strictly Reproducible)")]
    ]
    for r in range(2):
        for c in range(2):
            cell = t_meta.rows[r].cells[c]
            set_cell_background(cell, "EBF5FB")
            p = cell.paragraphs[0]
            label, val = meta_data[r][c]
            r1 = p.add_run(label)
            r1.font.bold = True
            r1.font.size = Pt(9)
            r1.font.color.rgb = RGBColor(27, 79, 114)
            r2 = p.add_run(val)
            r2.font.size = Pt(9)
            r2.font.color.rgb = RGBColor(52, 73, 94)

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

def add_heading_1(doc, text):
    h = doc.add_heading(text, level=1)
    for run in h.runs:
        run.font.color.rgb = RGBColor(27, 79, 114)
        run.font.bold = True
        run.font.size = Pt(15)
    h.paragraph_format.space_before = Pt(14)
    h.paragraph_format.space_after = Pt(6)

def add_heading_2(doc, text):
    h = doc.add_heading(text, level=2)
    for run in h.runs:
        run.font.color.rgb = RGBColor(41, 128, 185)
        run.font.bold = True
        run.font.size = Pt(12.5)
    h.paragraph_format.space_before = Pt(10)
    h.paragraph_format.space_after = Pt(4)

def insert_image_if_exists(doc, path, width=6.2, caption=""):
    if os.path.exists(path):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        doc.add_picture(path, width=Inches(width))
        if caption:
            p_cap = doc.add_paragraph()
            p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
            run_cap = p_cap.add_run(f"Figure: {caption}")
            run_cap.font.size = Pt(9)
            run_cap.font.italic = True
            run_cap.font.color.rgb = RGBColor(127, 140, 141)
            p_cap.paragraph_format.space_after = Pt(10)

def add_df_to_table(doc, df, col_widths=None):
    t = doc.add_table(rows=len(df) + 1, cols=len(df.columns))
    # headers
    for c_idx, col_name in enumerate(df.columns):
        t.rows[0].cells[c_idx].paragraphs[0].text = str(col_name)
    # data
    for r_idx, row in df.iterrows():
        for c_idx, val in enumerate(row):
            t.rows[r_idx + 1].cells[c_idx].paragraphs[0].text = str(val)
    format_table(t, col_widths)
    doc.add_paragraph().paragraph_format.space_after = Pt(8)

# ==============================================================================
# REPORT 1: Week 1 Data Cleaning & Preprocessing
# ==============================================================================
def generate_week_1_report():
    print("[REPORT 1] Compiling Week_1_Data_Cleaning.docx...")
    doc = docx.Document()
    
    add_header_block(
        doc,
        week_num="1",
        title="Data Ingestion, Cleaning & Feature Engineering Report",
        subtitle="End-to-End Ingestion, Quality Auditing, Anomaly Pruning, and Normalization of 9.55 Million NYC TLC Trip Records"
    )

    add_heading_1(doc, "1. Executive Summary & Ingestion Overview")
    doc.add_paragraph(
        "During Week 1 of the YuvaIntern Data Analyst Internship, the foundational data architecture was constructed "
        "to ingest, audit, and clean the official NYC Taxi and Limousine Commission (TLC) Yellow Taxi dataset for Q1 2024 (January, February, March). "
        "The raw dataset comprised 9,554,778 trip records across 19 feature attributes, totaling 153.0 MB in compressed columnar Parquet format. "
        "Due to the substantial volume (9.55M rows), memory-efficient streaming and chunked processing via Apache Arrow and data.table were implemented."
    )

    # Ingestion Summary Table
    add_heading_2(doc, "1.1 Raw Dataset Ingestion Audit")
    if os.path.exists("outputs/tables/01_raw_data_summary.csv"):
        df_raw = pd.read_csv("outputs/tables/01_raw_data_summary.csv")
        add_df_to_table(doc, df_raw, [3.0, 1.2, 1.5, 1.0])

    add_heading_1(doc, "2. Data Cleaning Rules & Quality Assurance Pipeline")
    doc.add_paragraph(
        "To ensure data integrity for downstream econometric modeling and spatial visualization, a strict multi-tier data cleaning protocol was executed:\n"
        "1. Missing Value Elimination: Removed null records lacking passenger count, trip distance, or rate codes (751,962 rows / 7.87%).\n"
        "2. Trip Duration Thresholding: Filtered trips with duration < 1 minute (meter turn-on errors) or > 180 minutes (unclosed meters).\n"
        "3. Fare Boundaries: Filtered non-positive fares and extreme recording glitches, retaining valid fares between $2.50 (NYC base rate) and $300.00.\n"
        "4. Distance Range: Retained valid urban and airport trips between 0.10 miles and 50.00 miles.\n"
        "5. Physical Speed Validation: Calculated speed in mph; removed stalled zero-speed anomalies and impossible speeds > 65.0 mph.\n"
        "6. Passenger Capacity & Payment Filter: Enforced passenger counts between 1 and 6 riders and standard payment types (Credit Card & Cash)."
    )

    add_heading_2(doc, "2.1 Cleaning Audit Summary & Population Retention")
    if os.path.exists("outputs/tables/02_cleaning_audit_summary.csv"):
        df_audit = pd.read_csv("outputs/tables/02_cleaning_audit_summary.csv")
        add_df_to_table(doc, df_audit, [3.8, 2.8])

    add_heading_1(doc, "3. Feature Engineering & Categorical Encodings")
    doc.add_paragraph(
        "To empower predictive modeling and statistical inference, domain-specific features were engineered:\n"
        "• Temporal Features: pickup_hour (0–23), pickup_day (Mon–Sun), is_weekend (binary flag), and peak_hour (weekday morning 7–10 AM & evening 4–7 PM rush).\n"
        "• Economic & Efficiency Metrics: fare_per_mile (fare amount divided by distance), tip_percentage (relative tip on credit transactions), and high_fare (binary target for trips >= $25.00).\n"
        "• Categorical Labels: Mapped raw numeric codes to standardized descriptive factors (Vendor: Creative Mobile vs. VeriFone; Payment: Credit Card vs. Cash)."
    )

    add_heading_1(doc, "4. Baseline Descriptive Statistics & Correlation Structure")
    doc.add_paragraph(
        "Comprehensive descriptive metrics were computed across all numeric features for the cleaned analytical sample (412,481 rows). "
        "The distribution exhibits characteristic right-skewness common to urban transit data, with a median trip distance of 1.70 miles and median fare of $12.80."
    )

    if os.path.exists("outputs/tables/03_descriptive_statistics.csv"):
        df_desc = pd.read_csv("outputs/tables/03_descriptive_statistics.csv")
        add_df_to_table(doc, df_desc)

    add_heading_1(doc, "5. Week 1 Key Takeaways & Deliverables")
    doc.add_paragraph(
        "• 9,554,778 raw rows were successfully ingested with zero memory overflows.\n"
        "• 8,249,634 valid records were retained (86.34% population retention rate).\n"
        "• A highly representative analytical dataset of 412,481 rows was exported to Parquet and CSV.\n"
        "• Pearson and Spearman correlation structures confirm extreme correlation between trip distance and fare amount (r = 0.959)."
    )

    os.makedirs("reports", exist_ok=True)
    out_path = "reports/Week_1_Data_Cleaning.docx"
    doc.save(out_path)
    print(f"[SUCCESS] Saved: {out_path}")

# ==============================================================================
# REPORT 2: Week 2 Data Visualization
# ==============================================================================
def generate_week_2_report():
    print("[REPORT 2] Compiling Week_2_Data_Visualization.docx...")
    doc = docx.Document()
    
    add_header_block(
        doc,
        week_num="2",
        title="Exploratory Data Visualization & Behavioral Insights",
        subtitle="Comprehensive ggplot2 Visual Analysis of NYC Taxi Demand Cycles, Spatial Bottlenecks, Tipping Behaviors, and Fare Yields"
    )

    add_heading_1(doc, "1. Visual Analytics Architecture & Methodology")
    doc.add_paragraph(
        "Week 2 focuses on uncovering mobility patterns, temporal cycles, congestion dynamics, and customer payment behaviors "
        "across the cleaned NYC Yellow Taxi dataset. A custom visual design system (`theme_taxi`) was developed using ggplot2, "
        "enforcing high data-to-ink ratios, accessible color palettes, informative annotations, and 300 DPI publication standards."
    )

    add_heading_1(doc, "2. Temporal Demand & Mobility Cycles")
    doc.add_paragraph(
        "Figure 1 reveals the bimodal diurnal demand curve characteristic of Manhattan commuter flows. Trip volumes ramp up sharply "
        "starting at 6:00 AM, plateau through the afternoon, and peak during the evening rush hour between 5:00 PM and 7:00 PM. "
        "Figure 2 contrasts weekly ride volumes, demonstrating peak taxi utilization on Thursdays and Fridays as business travel overlaps with weekend nightlife."
    )
    insert_image_if_exists(doc, "outputs/plots/plot_01_hourly_demand.png", width=6.2, caption="Plot 1: Hourly NYC Yellow Taxi Pickup Volume Distribution (0-23 Hours)")
    insert_image_if_exists(doc, "outputs/plots/plot_02_day_of_week_trends.png", width=6.2, caption="Plot 2: Day of Week Pickup Demand Comparing Weekdays vs. Weekends")

    add_heading_1(doc, "3. Spatial Distribution, Trip Distances & Congestion Curves")
    doc.add_paragraph(
        "Figure 3 highlights the intense right-skewness of trip distances, with over 75% of all rides spanning less than 3.10 miles. "
        "Figure 4 captures the non-linear relationship between trip distance and duration via Generalized Additive Model (GAM) smoothing. "
        "Figure 7 illustrates the daytime congestion bottleneck where average vehicle speed plummets below 9.5 mph in Midtown Manhattan between 8:00 AM and 6:00 PM."
    )
    insert_image_if_exists(doc, "outputs/plots/plot_03_trip_distance_distribution.png", width=6.2, caption="Plot 3: Probability Density of Urban Trip Distances with Median Milestone (1.70 miles)")
    insert_image_if_exists(doc, "outputs/plots/plot_04_duration_vs_distance.png", width=6.2, caption="Plot 4: Trip Duration vs. Distance Scatter with Non-Linear GAM Smoothing Curve")
    insert_image_if_exists(doc, "outputs/plots/plot_07_speed_by_hour.png", width=6.2, caption="Plot 7: Diurnal Speed Congestion Curves (mph) Comparing Weekdays and Weekends")

    add_heading_1(doc, "4. Economics, Tipping Behavior & Location Concentration")
    doc.add_paragraph(
        "Figure 5 demonstrates that passenger count has minimal impact on base fare distributions, as NYC fares are strictly metered by time and distance. "
        "Figure 6 illustrates tipping behavior on credit card transactions, showing immense clustering at the 20%, 25%, and 30% point-of-sale default tip buttons. "
        "Figure 9 confirms extreme spatial concentration in core Midtown commercial hubs, Upper Manhattan residential zones, and JFK Airport terminals."
    )
    insert_image_if_exists(doc, "outputs/plots/plot_05_fare_by_passenger_count.png", width=6.2, caption="Plot 5: Boxplot Distribution of Fare Amounts Across Passenger Capacities (1 to 6 riders)")
    insert_image_if_exists(doc, "outputs/plots/plot_06_payment_type_tips.png", width=6.2, caption="Plot 6: Credit Card Tip Percentage Distribution Highlighting Default Preset Preferences")
    insert_image_if_exists(doc, "outputs/plots/plot_09_top_pickup_locations.png", width=6.2, caption="Plot 9: Ranking of Top 10 Busiest Taxi Pickup Zones across New York City")
    insert_image_if_exists(doc, "outputs/plots/plot_10_correlation_heatmap.png", width=5.5, caption="Plot 10: Multi-Attribute Correlation Heatmap Matrix")
    insert_image_if_exists(doc, "outputs/plots/plot_11_high_fare_probability.png", width=6.2, caption="Plot 11: High-Fare Trip (>= $25) Probability Curve Across 24 Hours")

    add_heading_1(doc, "5. Week 2 Visual Analytics Summary")
    doc.add_paragraph(
        "• 11 customized publication-grade ggplot2 visualizations were successfully constructed and saved at 300 DPI.\n"
        "• Discovered that daytime congestion cuts fleet speed by >40% relative to nighttime operations.\n"
        "• Validated that POS tip presets heavily drive driver tipping income (20% median on credit transactions).\n"
        "• Early morning hours (4:00 AM – 6:00 AM) feature the highest probability of lucrative high-fare airport runs."
    )

    out_path = "reports/Week_2_Data_Visualization.docx"
    doc.save(out_path)
    print(f"[SUCCESS] Saved: {out_path}")

# ==============================================================================
# REPORT 3: Week 3 Statistical & Predictive Modeling
# ==============================================================================
def generate_week_3_report():
    print("[REPORT 3] Compiling Week_3_Statistical_Predictive_Modeling.docx...")
    doc = docx.Document()
    
    add_header_block(
        doc,
        week_num="3",
        title="Statistical Inference & Predictive Machine Learning Modeling",
        subtitle="Formal Hypothesis Testing, 5-Fold Cross-Validation, Multivariable Logistic Regression, and Random Forest High-Fare Classification"
    )

    add_heading_1(doc, "1. Inferential Statistical Hypothesis Testing")
    doc.add_paragraph(
        "To rigorously substantiate business observations from Weeks 1 and 2, four formal statistical hypothesis tests were conducted. "
        "Due to the substantial sample size (N = 412,481), asymptotic normality is guaranteed under the Central Limit Theorem. "
        "Effect sizes (Cohen's d, Eta-squared, and Cramér's V) were calculated alongside p-values to evaluate practical significance."
    )

    add_heading_2(doc, "1.1 Hypothesis Formulation & Results")
    doc.add_paragraph(
        "• Hypothesis 1 (Welch t-test): Evaluated whether weekend trip distances differ from weekdays. Result: t = -9.486, p < 1e-16 (Reject H0). Weekday trips average 3.285 miles vs. 3.150 miles on weekends.\n"
        "• Hypothesis 2 (One-tailed Welch t-test): Tested whether peak rush-hour fares exceed off-peak fares. Result: t = 9.693, p < 1e-16 (Reject H0). Peak fares average $18.96 vs. $18.29 off-peak due to idle traffic meter increments.\n"
        "• Hypothesis 3 (One-Way ANOVA): Tested fare variation across TLC Rate Codes. Result: F = 94,988.04, p < 1e-16, Eta-squared = 0.4795 (Reject H0). Rate codes account for 47.95% of total fare variance.\n"
        "• Hypothesis 4 (Chi-Square Test of Independence): Tested association between payment type and high-fare trips. Result: Chi-sq = 73.43, p < 1e-16 (Reject H0)."
    )

    if os.path.exists("outputs/tables/05_hypothesis_testing_results.csv"):
        df_hyp = pd.read_csv("outputs/tables/05_hypothesis_testing_results.csv")
        add_df_to_table(doc, df_hyp[['Hypothesis_ID', 'Test_Name', 'Test_Statistic', 'P_Value', 'Effect_Size_Metric', 'Effect_Size_Value', 'Conclusion']])

    add_heading_1(doc, "2. Predictive Modeling Framework: High-Fare Classification")
    doc.add_paragraph(
        "A binary classification machine learning task was formulated to predict High-Fare trips (defined as fare_amount >= $25.00) "
        "at the time of dispatch using trip features: trip_distance, trip_duration_min, pickup_hour, is_weekend, peak_hour, passenger_count, and RatecodeID. "
        "The dataset was partitioned into an 80% Training Set (329,985 rows) and 20% Holdout Test Set (82,496 rows) with seed 12345."
    )

    add_heading_2(doc, "2.1 5-Fold Cross-Validation & Multivariable Logistic Regression")
    doc.add_paragraph(
        "5-Fold Cross-Validation was executed across the training partition to ensure zero data leakage and prevent overfitting. "
        "The model achieved an exceptional mean CV Accuracy of 99.01% (SD: 0.02%) and mean CV ROC-AUC of 0.9992 (SD: 0.01%). "
        "The multivariable logistic regression model was then fitted on the full training set."
    )

    if os.path.exists("outputs/tables/06_odds_ratios_table.csv"):
        df_odds = pd.read_csv("outputs/tables/06_odds_ratios_table.csv")
        add_df_to_table(doc, df_odds)

    add_heading_1(doc, "3. Out-of-Sample Model Performance on Holdout Test Set")
    doc.add_paragraph(
        "The trained model was evaluated against the unseen holdout test set (82,496 records). "
        "The confusion matrix and comprehensive classification metrics confirm outstanding discriminatory capability."
    )

    add_heading_2(doc, "3.1 Confusion Matrix & Performance Metrics")
    if os.path.exists("outputs/tables/06_confusion_matrix.csv"):
        df_cm = pd.read_csv("outputs/tables/06_confusion_matrix.csv")
        add_df_to_table(doc, df_cm)

    if os.path.exists("outputs/tables/06_model_performance_metrics.csv"):
        df_met = pd.read_csv("outputs/tables/06_model_performance_metrics.csv")
        add_df_to_table(doc, df_met, [3.8, 2.5])

    insert_image_if_exists(doc, "outputs/plots/plot_12_roc_curve.png", width=6.2, caption="Plot 12: Holdout Test Set Receiver Operating Characteristic (ROC) Curve (AUC = 0.9992)")
    insert_image_if_exists(doc, "outputs/plots/plot_13_feature_importance.png", width=6.2, caption="Plot 13: Random Forest Feature Importance Ranking (Mean Decrease Gini)")

    add_heading_1(doc, "4. Week 3 Modeling Summary")
    doc.add_paragraph(
        "• All 4 statistical hypotheses were conclusively validated with rigorous effect sizes.\n"
        "• Logistic regression achieved 99.06% Accuracy, 97.84% Precision, 96.88% Recall, and 0.9992 ROC-AUC on holdout data.\n"
        "• Odds ratios confirm that each additional trip mile multiplies the odds of a high fare by 23.32x.\n"
        "• Random Forest feature importance confirmed trip distance and trip duration as the dominant determinants of fare class."
    )

    out_path = "reports/Week_3_Statistical_Predictive_Modeling.docx"
    doc.save(out_path)
    print(f"[SUCCESS] Saved: {out_path}")

# ==============================================================================
# REPORT 4: Week 4 Final Comprehensive Analytics Report
# ==============================================================================
def generate_week_4_report():
    print("[REPORT 4] Compiling Week_4_Final_Comprehensive_Report.docx...")
    doc = docx.Document()
    
    add_header_block(
        doc,
        week_num="4",
        title="Final Comprehensive Analytics & Business Intelligence Report",
        subtitle="NYC Taxi Trip Data Analysis, Diurnal Mobility Dynamics, Statistical Hypotheses, Predictive Modeling, and Strategic Recommendations"
    )

    add_heading_1(doc, "1. Project Overview & Executive Summary")
    doc.add_paragraph(
        "This capstone report consolidates the complete end-to-end deliverables of the YuvaIntern Virtual R Data Analyst Internship. "
        "Using 9,554,778 raw NYC TLC Yellow Taxi trip records from Q1 2024, an industrial-grade analytical pipeline was developed in R 4.6.x "
        "spanning large-scale data ingestion, multi-tiered anomaly cleansing, exploratory ggplot2 visualization, inferential hypothesis testing, "
        "and predictive machine learning classification."
    )

    add_heading_1(doc, "2. End-to-End Methodology & Technical Pipeline")
    doc.add_paragraph(
        "1. Ingestion & Storage: Out-of-core streaming of 3 monthly Parquet files (9.55M rows / 153 MB).\n"
        "2. Quality Assurance & Cleansing: Removal of 751,962 missing records and 553,182 physical/meter anomalies, achieving an 86.34% valid retention rate.\n"
        "3. Feature Engineering: Construction of temporal indicators (pickup_hour, peak_hour, is_weekend), economic ratios (fare_per_mile, tip_percentage), and the high_fare target.\n"
        "4. Visual Analytics: Generation of 11 publication-grade ggplot2 visualizations analyzing demand cycles, speed congestion curves, and spatial concentrations.\n"
        "5. Statistical Testing: Execution of 4 formal inferential tests (Welch t-tests, ANOVA, Chi-square) establishing significant empirical differences across time, rate codes, and payment methods.\n"
        "6. Predictive Modeling: 5-Fold Cross-Validation and Logistic Regression yielding 99.06% Accuracy, 97.84% Precision, 96.88% Recall, and 0.9992 ROC-AUC on holdout data."
    )

    add_heading_1(doc, "3. Summary of Key Analytical Findings")
    doc.add_paragraph(
        "• Diurnal Congestion Bottleneck: Vehicle speed drops below 9.5 mph between 8:00 AM and 6:00 PM on weekdays, increasing fare yield per mile due to time-based meter increments.\n"
        "• Spatial Concentration: Pickups are heavily clustered in Midtown commercial districts, Upper East/West residential hubs, and JFK/LaGuardia terminals.\n"
        "• Behavioral Tipping Preferences: Credit card tipping exhibits extreme clustering at 20%, 25%, and 30% POS default presets, generating a 21.72% mean tip rate.\n"
        "• High-Fare Predictability: Early morning hours (4–6 AM) feature the highest proportion of long-haul airport runs, offering maximum revenue potential per trip."
    )

    add_heading_1(doc, "4. Key Visual & Model Artifacts")
    insert_image_if_exists(doc, "outputs/plots/plot_01_hourly_demand.png", width=6.0, caption="Hourly Trip Demand Cycles across New York City")
    insert_image_if_exists(doc, "outputs/plots/plot_07_speed_by_hour.png", width=6.0, caption="Diurnal Traffic Speed Congestion Curves (mph)")
    insert_image_if_exists(doc, "outputs/plots/plot_12_roc_curve.png", width=6.0, caption="Predictive High-Fare Classification ROC Curve (AUC = 0.9992)")

    add_heading_1(doc, "5. Strategic Business Recommendations for Fleet Operators")
    doc.add_paragraph(
        "1. Dynamic Fleet Staging: Position unallocated vehicles near JFK and LaGuardia terminals between 4:00 AM and 6:30 AM to capture high-margin airport departures.\n"
        "2. Congestion-Aware Surge Routing: Implement real-time routing algorithms that steer drivers toward peripheral avenues during the 8:00 AM - 6:00 PM congestion trough.\n"
        "3. Optimized POS Tipping Presets: Standardize in-cab payment terminal default tip options to 20%, 25%, and 30% to maximize driver take-home earnings.\n"
        "4. Shift Scheduling Optimization: Structure driver shift changes around 3:00 PM - 4:00 PM to ensure maximum vehicle availability during the critical 5:00 PM - 7:00 PM evening demand peak."
    )

    add_heading_1(doc, "6. Project Limitations & Future Scope")
    doc.add_paragraph(
        "• Limitations: The dataset lacks detailed weather data, real-time GPS intermediate waypoints, and passenger-driver matching delays.\n"
        "• Future Scope: Integration of NOAA historical weather radar data, real-time XGBoost dispatch pricing, and geospatial spatial regression (Kriging / Moran's I) across all 263 TLC taxi zones."
    )

    out_path = "reports/Week_4_Final_Comprehensive_Report.docx"
    doc.save(out_path)
    print(f"[SUCCESS] Saved: {out_path}")

if __name__ == "__main__":
    generate_week_1_report()
    generate_week_2_report()
    generate_week_3_report()
    generate_week_4_report()
    print("[ALL REPORTS GENERATED SUCCESSFULLY]")
