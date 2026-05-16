# 06_make_prediction_example.R
# Project 3: Pokemon Card Price Prediction
# Purpose: Demonstrate how to use the final Ridge model to predict the price of a new card listing.

library(tidyverse)
library(tidymodels)

# ---------------------------------------------------------
# Load final trained model
# ---------------------------------------------------------

final_ridge_fit <- readRDS("~/Desktop/03-pokemon-card-pricing-regression/models/final_ridge_model.rds")

# ---------------------------------------------------------
# Create a new example card listing
# ---------------------------------------------------------
# Important:
# The new listing must include the same predictor columns used during model training.
# Do not include price, price_usd, price_tier_usd, currency, title, or card_number.

new_card <- tibble(
  pokemon_name = "Charizard",
  set_name = "Unknown",
  rarity_class = "Rare Holo",
  language = "English",
  category = "Single Cards",
  condition_std = "Near Mint",
  is_graded = 0,
  grading_company = "Ungraded",
  numeric_grade = 0,
  is_holo = 1,
  is_full_art = 0,
  is_v_card = 0,
  is_ex_card = 0,
  is_gx_card = 0,
  is_promo = 0,
  is_shadowless = 0,
  is_1st_edition = 0,
  is_rainbow = 0,
  is_gold = 0,
  seller_country = "United States",
  seller_listing_count = 25,
  ships_worldwide = 0,
  image_count = 4,
  days_since_sold = 3,
  sale_month = 5,
  sale_year = 2026
)

# ---------------------------------------------------------
# Predict log price and convert back to USD
# ---------------------------------------------------------

prediction <- predict(final_ridge_fit, new_data = new_card) %>%
  mutate(
    predicted_price_usd = exp(.pred)
  )

print(prediction)

