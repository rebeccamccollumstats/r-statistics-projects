# 02_exploratory_analysis.R
# Project 3: Pokemon Card Price Prediction
# Purpose: Explore cleaned Pokemon card pricing data before modeling.

library(tidyverse)
library(janitor)
library(skimr)
library(scales)
library(corrplot)

# Load cleaned data
pokemon_clean <- read_csv("~/Desktop/03-pokemon-card-pricing-regression/data/cleaned/pokemon_card_pricing_cleaned_initial.csv")

# Inspect data
glimpse(pokemon_clean)
names(pokemon_clean)
skim(pokemon_clean)

# ---------------------------------------------------------
# Price Distribution
# ---------------------------------------------------------

pokemon_clean <- pokemon_clean %>%
  filter(!is.na(price_usd)) %>%
  filter(price_usd > 0) %>%
  mutate(log_price_usd = log(price_usd))

ggplot(pokemon_clean, aes(x = price_usd)) +
  geom_histogram(bins = 50) +
  scale_x_continuous(labels = dollar_format()) +
  labs(
    title = "Distribution of Pokemon Card Prices",
    x = "Price in USD",
    y = "Count"
  )

ggplot(pokemon_clean, aes(x = log_price_usd)) +
  geom_histogram(bins = 50) +
  labs(
    title = "Distribution of Log-Transformed Pokemon Card Prices",
    x = "Log Price in USD",
    y = "Count"
  )

# ---------------------------------------------------------
# Summary Statistics
# ---------------------------------------------------------

price_summary <- pokemon_clean %>%
  summarise(
    min_price_usd = min(price_usd, na.rm = TRUE),
    q1_price_usd = quantile(price_usd, 0.25, na.rm = TRUE),
    median_price_usd = median(price_usd, na.rm = TRUE),
    mean_price_usd = mean(price_usd, na.rm = TRUE),
    q3_price_usd = quantile(price_usd, 0.75, na.rm = TRUE),
    max_price_usd = max(price_usd, na.rm = TRUE),
    sd_price_usd = sd(price_usd, na.rm = TRUE)
  )

print(price_summary)

# ---------------------------------------------------------
# Rarity and Price
# ---------------------------------------------------------

rarity_price_summary <- pokemon_clean %>%
  group_by(rarity_class) %>%
  summarise(
    count = n(),
    median_price_usd = median(price_usd, na.rm = TRUE),
    mean_price_usd = mean(price_usd, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(median_price_usd))

print(rarity_price_summary)

ggplot(pokemon_clean, aes(x = reorder(rarity_class, price_usd, median), y = price_usd)) +
  geom_boxplot(outlier.alpha = 0.2) +
  coord_flip() +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Pokemon Card Price by Rarity Class",
    x = "Rarity Class",
    y = "Price in USD"
  )

# ---------------------------------------------------------
# Condition and Price
# ---------------------------------------------------------

condition_price_summary <- pokemon_clean %>%
  group_by(condition_std) %>%
  summarise(
    count = n(),
    median_price_usd = median(price_usd, na.rm = TRUE),
    mean_price_usd = mean(price_usd, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(median_price_usd))

print(condition_price_summary)

ggplot(pokemon_clean, aes(x = reorder(condition_std, price_usd, median), y = price_usd)) +
  geom_boxplot(outlier.alpha = 0.2) +
  coord_flip() +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Pokemon Card Price by Condition",
    x = "Condition",
    y = "Price in USD"
  )

# ---------------------------------------------------------
# Grading and Price
# ---------------------------------------------------------

grading_price_summary <- pokemon_clean %>%
  group_by(is_graded) %>%
  summarise(
    count = n(),
    median_price_usd = median(price_usd, na.rm = TRUE),
    mean_price_usd = mean(price_usd, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(median_price_usd))

print(grading_price_summary)

ggplot(pokemon_clean, aes(x = factor(is_graded), y = price_usd)) +
  geom_boxplot(outlier.alpha = 0.2) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Pokemon Card Price by Graded Status",
    x = "Is Graded",
    y = "Price in USD"
  )

# ---------------------------------------------------------
# Special Card Feature Summaries
# ---------------------------------------------------------

special_card_summary <- pokemon_clean %>%
  summarise(
    holo_rate = mean(is_holo),
    full_art_rate = mean(is_full_art),
    v_card_rate = mean(is_v_card),
    ex_card_rate = mean(is_ex_card),
    gx_card_rate = mean(is_gx_card),
    promo_rate = mean(is_promo),
    shadowless_rate = mean(is_shadowless),
    first_edition_rate = mean(is_1st_edition),
    rainbow_rate = mean(is_rainbow),
    gold_rate = mean(is_gold)
  ) %>%
  pivot_longer(
    cols = everything(),
    names_to = "feature",
    values_to = "proportion"
  ) %>%
  arrange(desc(proportion))

print(special_card_summary)

# ---------------------------------------------------------
# Numeric Feature Correlations
# ---------------------------------------------------------

numeric_data <- pokemon_clean %>%
  select(
    log_price_usd,
    is_graded,
    numeric_grade,
    is_holo,
    is_full_art,
    is_v_card,
    is_ex_card,
    is_gx_card,
    is_promo,
    is_shadowless,
    is_1st_edition,
    is_rainbow,
    is_gold,
    seller_listing_count,
    ships_worldwide,
    image_count,
    days_since_sold
  )

correlation_matrix <- cor(numeric_data)

print(correlation_matrix)

corrplot(
  correlation_matrix,
  method = "color",
  type = "upper",
  tl.cex = 0.7
)

# ---------------------------------------------------------
# Save EDA-ready dataset
# ---------------------------------------------------------

write_csv(pokemon_clean, "data/cleaned/pokemon_cards_eda.csv")
