# 01_data_cleaning.R
# Project 3: Pokemon Card Price Prediction
# Purpose: Import, inspect, clean, and prepare the raw Pokemon card pricing dataset.

# Load packages
library(tidyverse)
library(janitor)
library(skimr)

# Create output folders if they do not already exist
dir.create("data/cleaned", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

# Load raw data
pokemon_raw <- read_csv(
  "data/raw/pokemon_cards_ultimate_2026.csv",
  show_col_types = FALSE
)

# Inspect raw data structure
glimpse(pokemon_raw)
names(pokemon_raw)
skim(pokemon_raw)

# Clean column names
pokemon_clean <- pokemon_raw %>%
  clean_names()

# Check missing values before cleaning
missing_summary <- pokemon_clean %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "missing_count"
  ) %>%
  arrange(desc(missing_count))

print(missing_summary)

# Save missing value summary
write_csv(
  missing_summary,
  "outputs/tables/missing_value_summary.csv"
)

# Clean and prepare analysis dataset
pokemon_clean <- pokemon_clean %>%
  distinct() %>%
  filter(!is.na(price_usd)) %>%
  filter(price_usd > 0) %>%
  mutate(
    # Create transformed target variable for modeling
    log_price_usd = log(price_usd),

    # Handle missing grading information
    grading_company = if_else(is.na(grading_company), "Ungraded", grading_company),
    numeric_grade = if_else(is.na(numeric_grade), 0, numeric_grade),

    # Handle small number of missing sale date values
    days_since_sold = if_else(
      is.na(days_since_sold),
      median(days_since_sold, na.rm = TRUE),
      days_since_sold
    ),
    sale_month = if_else(
      is.na(sale_month),
      median(sale_month, na.rm = TRUE),
      sale_month
    ),
    sale_year = if_else(
      is.na(sale_year),
      median(sale_year, na.rm = TRUE),
      sale_year
    ),

    # Convert categorical variables
    rarity_class = as.factor(rarity_class),
    language = as.factor(language),
    category = as.factor(category),
    condition_std = as.factor(condition_std),
    grading_company = as.factor(grading_company),
    price_tier_usd = as.factor(price_tier_usd),
    seller_country = as.factor(seller_country),

    # Convert binary indicator variables
    is_graded = as.factor(is_graded),
    is_holo = as.factor(is_holo),
    is_full_art = as.factor(is_full_art),
    is_v_card = as.factor(is_v_card),
    is_ex_card = as.factor(is_ex_card),
    is_gx_card = as.factor(is_gx_card),
    is_promo = as.factor(is_promo),
    is_shadowless = as.factor(is_shadowless),
    is_1st_edition = as.factor(is_1st_edition),
    is_rainbow = as.factor(is_rainbow),
    is_gold = as.factor(is_gold),
    ships_worldwide = as.factor(ships_worldwide)
  )

# Confirm important missing values were handled
missing_value_checks <- tibble(
  variable = c("numeric_grade", "grading_company", "days_since_sold"),
  remaining_missing = c(
    sum(is.na(pokemon_clean$numeric_grade)),
    sum(is.na(pokemon_clean$grading_company)),
    sum(is.na(pokemon_clean$days_since_sold))
  )
)

print(missing_value_checks)

write_csv(
  missing_value_checks,
  "outputs/tables/missing_value_checks.csv"
)

# Save cleaned dataset
write_csv(
  pokemon_clean,
  "data/cleaned/pokemon_card_pricing_cleaned_initial.csv"
)

# Final inspection
glimpse(pokemon_clean)
summary(pokemon_clean$price_usd)
summary(pokemon_clean$log_price_usd)
