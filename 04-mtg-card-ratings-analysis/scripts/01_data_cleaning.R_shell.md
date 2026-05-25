
---

# 01_data_cleaning.R Shell

```r
# 01_data_cleaning.R
# Project: [Project Name]
# Purpose: Import, inspect, clean, and prepare the raw dataset.

library(tidyverse)
library(janitor)
library(skimr)

# ---------------------------------------------------------
# 1. Load raw data
# ---------------------------------------------------------

raw_data <- read_csv("data/raw/[raw_file_name].csv")

# ---------------------------------------------------------
# 2. Inspect raw data
# ---------------------------------------------------------

glimpse(raw_data)
names(raw_data)
skim(raw_data)

# ---------------------------------------------------------
# 3. Clean column names
# ---------------------------------------------------------

clean_data <- raw_data %>%
  clean_names()

# ---------------------------------------------------------
# 4. Check missing values
# ---------------------------------------------------------

missing_summary <- clean_data %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "missing_count"
  ) %>%
  arrange(desc(missing_count))

print(missing_summary)

# ---------------------------------------------------------
# 5. Check duplicate rows
# ---------------------------------------------------------

duplicate_count <- clean_data %>%
  duplicated() %>%
  sum()

print(paste("Duplicate rows:", duplicate_count))

# Remove duplicate rows if needed
clean_data <- clean_data %>%
  distinct()

# ---------------------------------------------------------
# 6. Convert variable types if needed
# ---------------------------------------------------------

clean_data <- clean_data %>%
  mutate(
    # Example conversions:
    # numeric_column = as.numeric(numeric_column),
    # percent_column = parse_number(percent_column) / 100,
    # category_column = as.factor(category_column)
  )

# ---------------------------------------------------------
# 7. Create new analysis variables if needed
# ---------------------------------------------------------

clean_data <- clean_data %>%
  mutate(
    # Example:
    # category_group = case_when(
    #   category %in% c("A", "B") ~ "Group 1",
    #   category %in% c("C", "D") ~ "Group 2",
    #   TRUE ~ "Other"
    # )
  )

# ---------------------------------------------------------
# 8. Final inspection
# ---------------------------------------------------------

glimpse(clean_data)
skim(clean_data)

# ---------------------------------------------------------
# 9. Save cleaned data
# ---------------------------------------------------------

dir.create("data/cleaned", recursive = TRUE, showWarnings = FALSE)

write_csv(clean_data, "data/cleaned/cleaned_data.csv")
