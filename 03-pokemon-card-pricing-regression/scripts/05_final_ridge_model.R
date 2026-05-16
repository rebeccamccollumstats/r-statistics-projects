# 05_final_ridge_model.R
# Project 3: Pokemon Card Price Prediction
# Purpose: Fit the final selected Ridge regression model and save final outputs.

library(tidyverse)
library(tidymodels)
library(scales)

set.seed(123)

# ---------------------------------------------------------
# Load data
# ---------------------------------------------------------

pokemon_model_data <- read_csv("~/Desktop/03-pokemon-card-pricing-regression/data/cleaned/pokemon_cards_eda.csv")

# ---------------------------------------------------------
# Prepare modeling data
# ---------------------------------------------------------

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

# ---------------------------------------------------------
# Train/Test Split
# ---------------------------------------------------------

pokemon_split <- initial_split(model_data, prop = 0.80, strata = log_price_usd)

pokemon_train <- training(pokemon_split)
pokemon_test <- testing(pokemon_split)

# ---------------------------------------------------------
# Final Ridge Recipe
# ---------------------------------------------------------

ridge_recipe <- recipe(log_price_usd ~ ., data = pokemon_train) %>%
  step_other(all_nominal_predictors(), threshold = 0.01) %>%
  step_unknown(all_nominal_predictors()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_zv(all_predictors()) %>%
  step_normalize(all_numeric_predictors())

# ---------------------------------------------------------
# Final Ridge Model
# ---------------------------------------------------------

final_ridge_model <- linear_reg(
  penalty = 0.418,
  mixture = 0
) %>%
  set_engine("glmnet")

final_ridge_workflow <- workflow() %>%
  add_recipe(ridge_recipe) %>%
  add_model(final_ridge_model)

final_ridge_fit <- final_ridge_workflow %>%
  fit(data = pokemon_train)

# ---------------------------------------------------------
# Predictions
# ---------------------------------------------------------

ridge_predictions <- predict(final_ridge_fit, pokemon_test) %>%
  bind_cols(pokemon_test) %>%
  mutate(
    predicted_price_usd = exp(.pred),
    actual_price_usd = exp(log_price_usd),
    residual_usd = actual_price_usd - predicted_price_usd
  )

# ---------------------------------------------------------
# Metrics
# ---------------------------------------------------------

ridge_log_metrics <- ridge_predictions %>%
  metrics(truth = log_price_usd, estimate = .pred)

ridge_price_metrics <- ridge_predictions %>%
  summarise(
    rmse_usd = sqrt(mean((actual_price_usd - predicted_price_usd)^2)),
    mae_usd = mean(abs(actual_price_usd - predicted_price_usd)),
    mean_actual_price_usd = mean(actual_price_usd),
    median_actual_price_usd = median(actual_price_usd)
  )

print(ridge_log_metrics)
print(ridge_price_metrics)

# ---------------------------------------------------------
# Save outputs
# ---------------------------------------------------------

dir.create("outputs", showWarnings = FALSE)
dir.create("visuals", showWarnings = FALSE)

write_csv(ridge_predictions, "outputs/final_ridge_predictions.csv")
write_csv(ridge_log_metrics, "outputs/final_ridge_log_metrics.csv")
write_csv(ridge_price_metrics, "outputs/final_ridge_price_metrics.csv")

# ---------------------------------------------------------
# Final Visuals
# ---------------------------------------------------------

actual_vs_predicted_price <- ggplot(ridge_predictions, aes(x = actual_price_usd, y = predicted_price_usd)) +
  geom_point(alpha = 0.4) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  scale_x_continuous(labels = dollar_format()) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Actual vs Predicted Pokemon Card Prices",
    subtitle = "Final Ridge Regression Model",
    x = "Actual Price in USD",
    y = "Predicted Price in USD"
  )

actual_vs_predicted_log <- ggplot(ridge_predictions, aes(x = log_price_usd, y = .pred)) +
  geom_point(alpha = 0.4) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(
    title = "Actual vs Predicted Log Prices",
    subtitle = "Final Ridge Regression Model",
    x = "Actual Log Price",
    y = "Predicted Log Price"
  )

ridge_residual_plot <- ggplot(ridge_predictions, aes(x = predicted_price_usd, y = residual_usd)) +
  geom_point(alpha = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_x_continuous(labels = dollar_format()) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Residual Plot for Final Ridge Regression Model",
    x = "Predicted Price in USD",
    y = "Residual in USD"
  )

print(actual_vs_predicted_price)
print(actual_vs_predicted_log)
print(ridge_residual_plot)

ggsave(
  filename = "visuals/final_ridge_actual_vs_predicted_price.png",
  plot = actual_vs_predicted_price,
  width = 9,
  height = 6,
  dpi = 300
)

ggsave(
  filename = "visuals/final_ridge_actual_vs_predicted_log.png",
  plot = actual_vs_predicted_log,
  width = 9,
  height = 6,
  dpi = 300
)

ggsave(
  filename = "visuals/final_ridge_residual_plot.png",
  plot = ridge_residual_plot,
  width = 9,
  height = 6,
  dpi = 300
)

