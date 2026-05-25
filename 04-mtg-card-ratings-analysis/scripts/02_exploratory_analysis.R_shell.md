## Step 2: Exploratory Analysis Script Template

```r
# 02_exploratory_analysis.R
# Project: [Project Name]
# Purpose: Explore the cleaned dataset using summary statistics and grouped analysis.

library(tidyverse)
library(janitor)
library(skimr)

# ---------------------------------------------------------
# 1. Load cleaned data
# ---------------------------------------------------------

clean_data <- read_csv("data/cleaned/cleaned_data.csv")

# ---------------------------------------------------------
# 2. Inspect cleaned data
# ---------------------------------------------------------

glimpse(clean_data)
names(clean_data)
skim(clean_data)

# ---------------------------------------------------------
# 3. Basic dataset summary
# ---------------------------------------------------------

dataset_summary <- clean_data %>%
  summarise(
    total_rows = n(),
    total_unique_items = n_distinct(main_id_or_name_column),
    average_main_metric = mean(main_metric, na.rm = TRUE),
    median_main_metric = median(main_metric, na.rm = TRUE),
    min_main_metric = min(main_metric, na.rm = TRUE),
    max_main_metric = max(main_metric, na.rm = TRUE)
  )

print(dataset_summary)

# ---------------------------------------------------------
# 4. Count observations by category
# ---------------------------------------------------------

category_counts <- clean_data %>%
  count(category_column, sort = TRUE)

print(category_counts)

# ---------------------------------------------------------
# 5. Top observations by main metric
# ---------------------------------------------------------

top_observations <- clean_data %>%
  filter(!is.na(main_metric)) %>%
  arrange(desc(main_metric)) %>%
  select(main_id_or_name_column, category_column, main_metric, everything()) %>%
  slice_head(n = 15)

print(top_observations)

# ---------------------------------------------------------
# 6. Lowest observations by main metric
# ---------------------------------------------------------

lowest_observations <- clean_data %>%
  filter(!is.na(main_metric)) %>%
  arrange(main_metric) %>%
  select(main_id_or_name_column, category_column, main_metric, everything()) %>%
  slice_head(n = 15)

print(lowest_observations)

# ---------------------------------------------------------
# 7. Performance by category
# ---------------------------------------------------------

performance_by_category <- clean_data %>%
  group_by(category_column) %>%
  summarise(
    count = n(),
    average_main_metric = mean(main_metric, na.rm = TRUE),
    median_main_metric = median(main_metric, na.rm = TRUE),
    min_main_metric = min(main_metric, na.rm = TRUE),
    max_main_metric = max(main_metric, na.rm = TRUE)
  ) %>%
  arrange(desc(average_main_metric))

print(performance_by_category)

# ---------------------------------------------------------
# 8. Correlation analysis
# ---------------------------------------------------------

correlation_summary <- clean_data %>%
  select(where(is.numeric)) %>%
  cor(use = "pairwise.complete.obs")

print(correlation_summary)

# ---------------------------------------------------------
# 9. Save outputs
# ---------------------------------------------------------

dir.create("outputs", showWarnings = FALSE)

write_csv(dataset_summary, "outputs/dataset_summary.csv")
write_csv(category_counts, "outputs/category_counts.csv")
write_csv(top_observations, "outputs/top_observations.csv")
write_csv(lowest_observations, "outputs/lowest_observations.csv")
write_csv(performance_by_category, "outputs/performance_by_category.csv")
```

### Notes for Using This Template

Replace these placeholder names with the real column names from your dataset:

| Placeholder | Replace With |
|---|---|
| `main_id_or_name_column` | The main identifier, such as `name`, `product_name`, `customer_id`, or `title` |
| `main_metric` | The main numeric variable you are analyzing, such as `price`, `rating`, `win_rate`, or `sales` |
| `category_column` | The grouping variable, such as `rarity`, `color`, `region`, `category`, or `type` |
