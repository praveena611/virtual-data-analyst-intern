# ==============================================================================
# Script: 04_visualization.R
# Project: NYC Taxi Trip Data Analysis and Predictive Modeling Using R
# Author: praveena611 (YuvaIntern Virtual R Data Analyst Internship)
# Seed: 12345
# ==============================================================================

set.seed(12345)
cat("======================================================================\n")
cat("STEP 4: EXPLORATORY DATA VISUALIZATION (11 PUBLICATION-GRADE PLOTS)\n")
cat("======================================================================\n")

suppressPackageStartupMessages({
  library(nanoparquet)
  library(data.table)
  library(dplyr)
  library(ggplot2)
  library(scales)
  library(corrplot)
})

# Load cleaned analysis dataset
cat("[INFO] Loading cleaned analysis sample dataset...\n")
dt <- as.data.table(nanoparquet::read_parquet("data/cleaned/cleaned_taxi_sample.parquet"))

# Custom clean aesthetic theme
theme_taxi <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14, color = "#1a252f", margin = margin(b = 6)),
      plot.subtitle = element_text(size = 11, color = "#566573", margin = margin(b = 10)),
      plot.caption = element_text(size = 9, color = "#7f8c8d", face = "italic"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#eaeded", linewidth = 0.5),
      axis.title = element_text(face = "bold", size = 11, color = "#2c3e50"),
      axis.text = element_text(color = "#34495e"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = 10),
      plot.margin = margin(15, 15, 15, 15)
    )
}

plot_dir <- "outputs/plots"

# ------------------------------------------------------------------------------
# Plot 1: Hourly Demand Distribution
# ------------------------------------------------------------------------------
cat("[PLOT 1/11] Generating Hourly Trip Demand Distribution...\n")
hourly_dt <- dt[, .(trip_count = .N), by = .(pickup_hour)][order(pickup_hour)]

p1 <- ggplot(hourly_dt, aes(x = pickup_hour, y = trip_count)) +
  geom_col(aes(fill = trip_count), show.legend = FALSE, width = 0.8) +
  scale_fill_gradient(low = "#85c1e9", high = "#1b4f72") +
  scale_x_continuous(breaks = 0:23) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Hourly NYC Yellow Taxi Trip Demand Distribution",
    subtitle = "Aggregated pickup counts across 24 hours highlighting morning & evening peak mobility",
    x = "Hour of the Day (0-23)",
    y = "Total Trip Volume",
    caption = "Source: NYC TLC Yellow Taxi Trip Records (2024 Q1 Sample)"
  ) +
  theme_taxi()

ggsave(file.path(plot_dir, "plot_01_hourly_demand.png"), p1, width = 9, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# Plot 2: Day of Week Trends (Weekday vs Weekend)
# ------------------------------------------------------------------------------
cat("[PLOT 2/11] Generating Day of Week Trip Volume Trends...\n")
dow_dt <- dt[, .(trip_count = .N, is_weekend = max(is_weekend)), by = .(pickup_day)]

p2 <- ggplot(dow_dt, aes(x = pickup_day, y = trip_count, fill = factor(is_weekend))) +
  geom_col(width = 0.7, show.legend = TRUE) +
  scale_fill_manual(values = c("0" = "#2980b9", "1" = "#e67e22"), labels = c("Weekday", "Weekend"), name = "Day Type") +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Weekly Taxi Ride Volume Distribution",
    subtitle = "Comparison of total pickups across days of the week",
    x = "Day of the Week",
    y = "Trip Count",
    caption = "Source: NYC TLC Yellow Taxi Trip Records"
  ) +
  theme_taxi()

ggsave(file.path(plot_dir, "plot_02_day_of_week_trends.png"), p2, width = 8.5, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# Plot 3: Trip Distance Distribution
# ------------------------------------------------------------------------------
cat("[PLOT 3/11] Generating Trip Distance Distribution...\n")
med_dist <- median(dt$trip_distance)

p3 <- ggplot(dt[trip_distance <= 15], aes(x = trip_distance)) +
  geom_histogram(aes(y = after_stat(density)), bins = 40, fill = "#3498db", color = "white", alpha = 0.8) +
  geom_density(color = "#154360", linewidth = 1.1) +
  geom_vline(xintercept = med_dist, linetype = "dashed", color = "#c0392b", linewidth = 1) +
  annotate("text", x = med_dist + 2.5, y = 0.22, label = sprintf("Median Distance: %.1f miles", med_dist),
           color = "#c0392b", fontface = "bold", size = 4) +
  labs(
    title = "Trip Distance Distribution (Trips <= 15 Miles)",
    subtitle = "Right-skewed distribution showing high concentration of short urban trips in Manhattan",
    x = "Trip Distance (Miles)",
    y = "Probability Density",
    caption = "Source: NYC TLC Yellow Taxi Data"
  ) +
  theme_taxi()

ggsave(file.path(plot_dir, "plot_03_trip_distance_distribution.png"), p3, width = 8.5, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# Plot 4: Trip Duration vs Trip Distance Scatter
# ------------------------------------------------------------------------------
cat("[PLOT 4/11] Generating Trip Duration vs Distance Scatter Plot...\n")
set.seed(12345)
scatter_sample <- dt[sample(.N, 15000)][trip_distance <= 25 & trip_duration_min <= 60]

p4 <- ggplot(scatter_sample, aes(x = trip_distance, y = trip_duration_min)) +
  geom_point(alpha = 0.15, color = "#2c3e50", size = 1.2) +
  geom_smooth(method = "gam", color = "#e74c3c", linewidth = 1.2, se = FALSE) +
  labs(
    title = "Relationship Between Trip Distance and Duration",
    subtitle = "GAM smoothing curve capturing urban speed variations and highway cruising segments",
    x = "Trip Distance (Miles)",
    y = "Trip Duration (Minutes)",
    caption = "Sample: 15,000 trips | Source: NYC TLC Data"
  ) +
  theme_taxi()

ggsave(file.path(plot_dir, "plot_04_duration_vs_distance.png"), p4, width = 8.5, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# Plot 5: Fare Amount by Passenger Count
# ------------------------------------------------------------------------------
cat("[PLOT 5/11] Generating Fare Amount by Passenger Count Boxplot...\n")
p5 <- ggplot(dt[fare_amount <= 60], aes(x = factor(passenger_count), y = fare_amount, fill = factor(passenger_count))) +
  geom_boxplot(outlier.alpha = 0.05, outlier.size = 0.8, show.legend = FALSE) +
  scale_fill_brewer(palette = "Blues") +
  labs(
    title = "Fare Amount Variation by Passenger Count",
    subtitle = "Stable median base fares across passenger occupancy levels (1 to 6 riders)",
    x = "Passenger Count",
    y = "Fare Amount ($)",
    caption = "Outliers truncated at $60 for visualization | Source: NYC TLC Data"
  ) +
  theme_taxi()

ggsave(file.path(plot_dir, "plot_05_fare_by_passenger_count.png"), p5, width = 8.5, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# Plot 6: Payment Type Market Share & Tip Percentage
# ------------------------------------------------------------------------------
cat("[PLOT 6/11] Generating Payment Type & Tip Percentage Plot...\n")
p6 <- ggplot(dt[payment_type == 1 & tip_percentage <= 50], aes(x = tip_percentage)) +
  geom_histogram(bins = 50, fill = "#27ae60", color = "white", alpha = 0.85) +
  geom_vline(xintercept = 20, linetype = "dashed", color = "#d35400", linewidth = 1) +
  annotate("text", x = 27, y = 35000, label = "Standard 20% Tip Preset", color = "#d35400", fontface = "bold") +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Tip Percentage Distribution for Credit Card Payments",
    subtitle = "Prominent spikes at default in-cab POS tip presets (15%, 20%, 25%, 30%)",
    x = "Tip Percentage of Fare (%)",
    y = "Number of Trips",
    caption = "Source: NYC TLC Yellow Taxi Data"
  ) +
  theme_taxi()

ggsave(file.path(plot_dir, "plot_06_payment_type_tips.png"), p6, width = 8.5, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# Plot 7: Average Speed (mph) Variation across 24 Hours
# ------------------------------------------------------------------------------
cat("[PLOT 7/11] Generating Hourly Speed Variations Plot...\n")
speed_hourly <- dt[, .(mean_speed = mean(speed_mph, na.rm = TRUE),
                       median_speed = median(speed_mph, na.rm = TRUE)),
                   by = .(pickup_hour, is_weekend)][order(pickup_hour)]

p7 <- ggplot(speed_hourly, aes(x = pickup_hour, y = mean_speed, color = factor(is_weekend), group = is_weekend)) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 3) +
  scale_color_manual(values = c("0" = "#c0392b", "1" = "#27ae60"), labels = c("Weekday", "Weekend"), name = "Day Type") +
  scale_x_continuous(breaks = 0:23) +
  labs(
    title = "NYC Traffic Congestion Curve: Average Speed by Hour of Day",
    subtitle = "Severe daytime speed drop to <9 mph during business rush hours (8 AM - 6 PM)",
    x = "Hour of Day (0-23)",
    y = "Average Speed (Miles per Hour)",
    caption = "Source: NYC TLC Yellow Taxi Data"
  ) +
  theme_taxi()

ggsave(file.path(plot_dir, "plot_07_speed_by_hour.png"), p7, width = 9, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# Plot 8: Fare per Mile by Hour
# ------------------------------------------------------------------------------
cat("[PLOT 8/11] Generating Fare Yield (Per Mile) by Hour Plot...\n")
yield_hourly <- dt[trip_distance >= 0.5, .(mean_yield = mean(fare_per_mile, na.rm = TRUE)), by = .(pickup_hour)][order(pickup_hour)]

p8 <- ggplot(yield_hourly, aes(x = pickup_hour, y = mean_yield)) +
  geom_area(fill = "#85929e", alpha = 0.3) +
  geom_line(color = "#2c3e50", linewidth = 1.3) +
  geom_point(color = "#e67e22", size = 3) +
  scale_x_continuous(breaks = 0:23) +
  labs(
    title = "Fare Yield ($ per Mile) Variation Across 24 Hours",
    subtitle = "Elevated yield during congested peak hours due to time-based idle meter increments",
    x = "Hour of Day (0-23)",
    y = "Average Fare per Mile ($/Mile)",
    caption = "Source: NYC TLC Yellow Taxi Data"
  ) +
  theme_taxi()

ggsave(file.path(plot_dir, "plot_08_fare_per_mile_by_hour.png"), p8, width = 8.5, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# Plot 9: Top 10 Busiest Pickup Locations
# ------------------------------------------------------------------------------
cat("[PLOT 9/11] Generating Top 10 Pickup Locations Chart...\n")
top_pu <- dt[, .(trip_count = .N), by = .(PULocationID)][order(-trip_count)][1:10]
top_pu[, PULocation_Label := factor(paste("Zone", PULocationID), levels = rev(paste("Zone", PULocationID)))]

p9 <- ggplot(top_pu, aes(x = trip_count, y = PULocation_Label)) +
  geom_col(fill = "#16a085", width = 0.7) +
  geom_text(aes(label = comma(trip_count)), hjust = -0.15, size = 3.5, fontface = "bold", color = "#16a085") +
  scale_x_continuous(labels = comma, expand = expansion(mult = c(0, 0.18))) +
  labs(
    title = "Top 10 Busiest NYC Taxi Pickup Zones",
    subtitle = "High trip density concentrated in core Midtown, Upper East/West Side, and JFK Airport zones",
    x = "Total Sampled Pickups",
    y = "TLC Location Zone ID",
    caption = "Source: NYC TLC Yellow Taxi Data"
  ) +
  theme_taxi()

ggsave(file.path(plot_dir, "plot_09_top_pickup_locations.png"), p9, width = 8.5, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# Plot 10: Correlation Heatmap Matrix
# ------------------------------------------------------------------------------
cat("[PLOT 10/11] Generating Correlation Heatmap Matrix...\n")
cor_vars <- c("trip_distance", "trip_duration_min", "fare_amount", "speed_mph", "tip_amount", "total_amount")
cor_mat <- cor(dt[, ..cor_vars], use = "complete.obs")
colnames(cor_mat) <- c("Distance", "Duration", "Fare", "Speed", "Tip", "Total")
rownames(cor_mat) <- c("Distance", "Duration", "Fare", "Speed", "Tip", "Total")

png(file.path(plot_dir, "plot_10_correlation_heatmap.png"), width = 2400, height = 2100, res = 300)
corrplot(cor_mat, method = "color", type = "upper", order = "hclust",
         addCoef.col = "black", tl.col = "#2c3e50", tl.srt = 45,
         col = colorRampPalette(c("#e74c3c", "#ecf0f1", "#2980b9"))(200),
         title = "Correlation Heatmap Matrix of Taxi Numerical Attributes",
         mar = c(0, 0, 2, 0))
dev.off()

# ------------------------------------------------------------------------------
# Plot 11: High Fare Probability by Pickup Hour & Weekend Status
# ------------------------------------------------------------------------------
cat("[PLOT 11/11] Generating High-Fare Probability by Hour Plot...\n")
prob_dt <- dt[, .(high_fare_prob = mean(high_fare)), by = .(pickup_hour, is_weekend)][order(pickup_hour)]

p11 <- ggplot(prob_dt, aes(x = pickup_hour, y = high_fare_prob, color = factor(is_weekend), group = is_weekend)) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 3) +
  scale_color_manual(values = c("0" = "#8e44ad", "1" = "#d35400"), labels = c("Weekday", "Weekend"), name = "Day Type") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_x_continuous(breaks = 0:23) +
  labs(
    title = "High-Fare Trip Probability (Fare >= $25) Across 24 Hours",
    subtitle = "Peak probability during early morning hours (4 AM - 6 AM) due to airport departures",
    x = "Hour of Day (0-23)",
    y = "High Fare Probability (%)",
    caption = "Source: NYC TLC Yellow Taxi Data"
  ) +
  theme_taxi()

ggsave(file.path(plot_dir, "plot_11_high_fare_probability.png"), p11, width = 9, height = 5.5, dpi = 300)

cat("[SUCCESS] All 11 publication-ready ggplot2 visualizations exported to outputs/plots/\n")
