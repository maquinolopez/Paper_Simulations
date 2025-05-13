###############################
# Authors:
# Marco A. Aquino-López 
# JASC
# Code:
# Plum comparison
###############################


rm(list = ls()) 	# clean R environment
# Read the three files
# crs <- read.table("CRS_error.txt", header = TRUE, stringsAsFactors = FALSE)
ecrs <- read.table("E_CRS.txt", header = TRUE, stringsAsFactors = FALSE)
plum <- read.table("Plum_errors_sd.txt", header = TRUE, stringsAsFactors = FALSE)

# Clean CRS
# crs <- subset(crs, !grepl("integer|numeric", crs$depth))
# crs$offset <- as.numeric(crs$offset)
# crs$core <- as.character(crs$core)
# crs$info_pct <- as.numeric(sub(".*_(\\d+)_.*", "\\1", crs$core))
# crs$interval_length <- as.numeric(crs$sd) *4
# crs$coverage_flag <- as.numeric(crs$N_offset)

# Clean Plum
plum$Accuracy <- as.numeric(plum$Accuracy)
plum$core <- as.character(plum$Names)
plum$offset <- plum$Accuracy  # For consistency
plum$info_pct <- plum$Information_percentage 
plum$coverage_flag <- as.numeric(plum$NormAccuracy)

# get crs variables
crs <- data.frame(
  info_pct = plum$info_pct,
  offset = plum$CRS_Accuracy,
  interval_length = plum$CRS_Precision,
  coverage_flag = plum$CRS_NormAccuracy
)



# Clean E-CRS
ecrs <- subset(ecrs, !grepl("integer|numeric", ecrs$depths))
ecrs$offset <- as.numeric(ecrs$offset)
ecrs$core <- as.character(ecrs$X)
ecrs$interval_length <- as.numeric(ecrs$sd) * 4
ecrs$coverage_flag <- as.numeric(ecrs$N_offset)



# Function to compute mean and 95% CI for each info_pct level
get_summary_var <- function(df, group_var = "info_pct", target_var) {
  # Ensure inputs are valid
  if (!all(c(group_var, target_var) %in% names(df))) {
    stop("Both group_var and target_var must be column names in df")
  }

  # Build grouping + target variable frame
  group_values <- df[[group_var]]
  target_values <- df[[target_var]]

  # Aggregate using quantiles
  summary_list <- aggregate(target_values, by = list(group = group_values), FUN = function(x) {
    m <- mean(x, na.rm = TRUE)
    q <- quantile(x, probs = c(0.025, 0.975), na.rm = TRUE)
    c(mean = m, lower = q[1], upper = q[2])
  })

  # Flatten the matrix output into columns
  summary_df <- do.call(data.frame, summary_list)
  colnames(summary_df) <- c("info_pct", "mean", "lower", "upper")

  return(summary_df)
}

# For Bias
crs_bias_summary <- get_summary_var(crs, target_var = "offset")
plum_bias_summary <- get_summary_var(plum, target_var = "Accuracy")
ecrs_bias_summary <- get_summary_var(ecrs, target_var = "offset")

# For Interval Length
crs_length_summary <- get_summary_var(crs, target_var = "interval_length")
plum_length_summary <- get_summary_var(plum, target_var = "Precision")
ecrs_length_summary <- get_summary_var(ecrs, target_var = "interval_length")

# For Coverage
crs_coverage_summary <- get_summary_var(crs, target_var = "coverage_flag")
plum_coverage_summary <- get_summary_var(plum, target_var = "coverage_flag")
ecrs_coverage_summary <- get_summary_var(ecrs, target_var = "coverage_flag")


plot_with_band <- function(summary_df, col, add = FALSE, main = "", ylab = "", xlab = "Information Percentage") {
  if (!add) {
    plot(NULL,
         xlim = range(summary_df$info_pct),
         ylim = range(c(summary_df$lower, summary_df$upper), na.rm = TRUE),
         xlab = xlab, ylab = ylab, main = main)
  }
  polygon(
    c(summary_df$info_pct, rev(summary_df$info_pct)),
    c(summary_df$lower, rev(summary_df$upper)),
    col = col, border = NA
  )
  lines(summary_df$info_pct, summary_df$mean, col = substr(col, 1, 7), lwd = 2)
}







par(mfrow = c(3, 1), mar = c(4, 4, 2, 1))

## 1. Bias plot
plot_with_band(crs_bias_summary, rgb(1, 0, 0, 0.2), main = "Bias", ylab = "Bias (Offset)")
plot_with_band(plum_bias_summary, rgb(0, 0, 1, 0.2), add = TRUE)
plot_with_band(ecrs_bias_summary, rgb(0, 1, 0, 0.2), add = TRUE)
legend("topright", legend = c("R−CRS", "Plum", "CI−CRS"), col = c("red", "blue", "green"), lwd = 2)

## 2. Interval length
plot_with_band(crs_length_summary, rgb(1, 0, 0, 0.2), main = "Interval Length", ylab = "Length")
plot_with_band(plum_length_summary, rgb(0, 0, 1, 0.2), add = TRUE)
plot_with_band(ecrs_length_summary, rgb(0, 1, 0, 0.2), add = TRUE)
# legend("topright", legend = c("R−CRS", "Plum", "CI−CRS"), col = c("red", "blue", "green"), lwd = 2)

## 3. Coverage
plot_with_band(crs_coverage_summary, rgb(1, 0, 0, 0.2), main = "Coverage", ylab = "Coverage [0,1]")
plot_with_band(plum_coverage_summary, rgb(0, 0, 1, 0.2), add = TRUE)
plot_with_band(ecrs_coverage_summary, rgb(0, 1, 0, 0.2), add = TRUE)
# legend("bottomright", legend = c("R−CRS", "Plum", "CI−CRS"), col = c("red", "blue", "green"), lwd = 2)
