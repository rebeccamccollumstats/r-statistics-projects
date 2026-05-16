# 03_baseline_regression_model.R
# Project 3: Pokemon Card Price Prediction
# Purpose: Build and evaluate a baseline regression model for predicting Pokemon card prices.

library(tidyverse)
library(tidymodels)
library(janitor)
library(scales)

set.seed(123)

# ---------------------------------------------------------
# Load EDA-ready data
# ---------------------------------------------------------

pokemon_model_data <- read_csv("~/Desktop/03-pokemon-card-pricing-regression/data/cleaned/pokemon_cards_eda.csv")

glimpse(pokemon_model_data)
names(pokemon_model_data)

# ---------------------------------------------------------
# Prepare modeling data
# ---------------------------------------------------------
# Target variable: log_price_usd
#
# Removed variables:
# - price and price_usd because they are the original price values
# - price_tier_usd because it is derived from price
# - currency because price_usd already standardizes currency
# - title because it is high-cardinality text
# - card_number because it has many missing/unique values and is not useful for the baseline model

model_data <- pokemon_model_data %>%
  select(
    -price,
    -price_usd,
    -price_tier_usd,
    -currency,
    -title,
    -card_number
  ) %>%
  drop_na(log_price_usd)

glimpse(model_data)

# ---------------------------------------------------------
# Train/Test Split
# ---------------------------------------------------------

pokemon_split <- initial_split(model_data, prop = 0.80)

pokemon_train <- training(pokemon_split)
pokemon_test <- testing(pokemon_split)

# ---------------------------------------------------------
# Preprocessing Recipe
# ---------------------------------------------------------

pokemon_recipe <- recipe(log_price_usd ~ ., data = pokemon_train) %>%
  step_other(all_nominal_predictors(), threshold = 0.01) %>%
  step_unknown(all_nominal_predictors()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_zv(all_predictors()) %>%
  step_normalize(all_numeric_predictors())

# ---------------------------------------------------------
# Baseline Linear Regression Model
# ---------------------------------------------------------

linear_model <- linear_reg() %>%
  set_engine("lm")

linear_workflow <- workflow() %>%
  add_recipe(pokemon_recipe) %>%
  add_model(linear_model)

linear_fit <- linear_workflow %>%
  fit(data = pokemon_train)

# View fitted model object
linear_fit

# ---------------------------------------------------------
# Make Predictions
# ---------------------------------------------------------

linear_predictions <- predict(linear_fit, pokemon_test) %>%
  bind_cols(pokemon_test) %>%
  mutate(
    predicted_price_usd = exp(.pred),
    actual_price_usd = exp(log_price_usd),
    residual_usd = actual_price_usd - predicted_price_usd
  )

head(linear_predictions)

# ---------------------------------------------------------
# Evaluate Model Performance
# ---------------------------------------------------------

log_metrics <- linear_predictions %>%
  metrics(truth = log_price_usd, estimate = .pred)

price_metrics <- linear_predictions %>%
  summarise(
    rmse_usd = sqrt(mean((actual_price_usd - predicted_price_usd)^2)),
    mae_usd = mean(abs(actual_price_usd - predicted_price_usd)),
    mean_actual_price_usd = mean(actual_price_usd),
    median_actual_price_usd = median(actual_price_usd)
  )

print(log_metrics)
print(price_metrics)

# ---------------------------------------------------------
# Visualization: Actual vs Predicted on Dollar Scale
# ---------------------------------------------------------

ggplot(linear_predictions, aes(x = actual_price_usd, y = predicted_price_usd)) +
  geom_point(alpha = 0.4) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  scale_x_continuous(labels = dollar_format()) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Actual vs Predicted Pokemon Card Prices",
    subtitle = "Baseline Linear Regression Model",
    x = "Actual Price in USD",
    y = "Predicted Price in USD"
  )

# ---------------------------------------------------------
# Visualization: Actual vs Predicted on Log Scale
# ---------------------------------------------------------

ggplot(linear_predictions, aes(x = log_price_usd, y = .pred)) +
  geom_point(alpha = 0.4) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(
    title = "Actual vs Predicted Log Prices",
    subtitle = "Baseline Linear Regression Model",
    x = "Actual Log Price",
    y = "Predicted Log Price"
  )

# ---------------------------------------------------------
# Visualization: Residual Plot
# ---------------------------------------------------------

ggplot(linear_predictions, aes(x = predicted_price_usd, y = residual_usd)) +
  geom_point(alpha = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_x_continuous(labels = dollar_format()) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Residual Plot for Baseline Linear Regression",
    x = "Predicted Price in USD",
    y = "Residual in USD"
  )

# ---------------------------------------------------------
# Save Outputs
# ---------------------------------------------------------

dir.create("outputs", showWarnings = FALSE)

write_csv(
  linear_predictions,
  "outputs/baseline_linear_regression_predictions.csv"
)
