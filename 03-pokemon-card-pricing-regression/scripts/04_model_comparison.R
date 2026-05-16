# 04_model_comparison.R
# Project 3: Pokemon Card Price Prediction
# Purpose: Compare multiple regression models for predicting Pokemon card prices.

library(tidyverse)
library(tidymodels)
library(janitor)
library(scales)
library(vip)
library(glmnet)
library(ranger)

set.seed(123)

# ---------------------------------------------------------
# Load EDA-ready data
# ---------------------------------------------------------

pokemon_model_data <- read_csv("~/Desktop/03-pokemon-card-pricing-regression/data/cleaned/pokemon_cards_eda.csv")

# ---------------------------------------------------------
# Prepare modeling data
# ---------------------------------------------------------
# Target: log_price_usd
# Remove variables that leak price or are not appropriate for modeling.

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
# Cross-validation folds
# ---------------------------------------------------------

pokemon_folds <- vfold_cv(pokemon_train, v = 5, strata = log_price_usd)

# ---------------------------------------------------------
# Shared preprocessing recipe
# ---------------------------------------------------------

pokemon_recipe <- recipe(log_price_usd ~ ., data = pokemon_train) %>%
  step_other(all_nominal_predictors(), threshold = 0.01) %>%
  step_unknown(all_nominal_predictors()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_zv(all_predictors()) %>%
  step_normalize(all_numeric_predictors())

# ---------------------------------------------------------
# Model Specifications
# ---------------------------------------------------------

linear_spec <- linear_reg() %>%
  set_engine("lm")

ridge_spec <- linear_reg(
  penalty = tune(),
  mixture = 0
) %>%
  set_engine("glmnet")

lasso_spec <- linear_reg(
  penalty = tune(),
  mixture = 1
) %>%
  set_engine("glmnet")

rf_spec <- rand_forest(
  mtry = tune(),
  trees = 500,
  min_n = tune()
) %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("regression")

# ---------------------------------------------------------
# Workflows
# ---------------------------------------------------------

linear_wf <- workflow() %>%
  add_recipe(pokemon_recipe) %>%
  add_model(linear_spec)

ridge_wf <- workflow() %>%
  add_recipe(pokemon_recipe) %>%
  add_model(ridge_spec)

lasso_wf <- workflow() %>%
  add_recipe(pokemon_recipe) %>%
  add_model(lasso_spec)

rf_wf <- workflow() %>%
  add_recipe(pokemon_recipe) %>%
  add_model(rf_spec)

# ---------------------------------------------------------
# Tune Grids
# ---------------------------------------------------------

penalty_grid <- grid_regular(
  penalty(range = c(-4, 1)),
  levels = 30
)

rf_grid <- grid_regular(
  mtry(range = c(2, 15)),
  min_n(range = c(2, 20)),
  levels = 5
)

# ---------------------------------------------------------
# Fit and tune models with cross-validation
# ---------------------------------------------------------

linear_res <- fit_resamples(
  linear_wf,
  resamples = pokemon_folds,
  metrics = metric_set(rmse, rsq, mae)
)

ridge_res <- tune_grid(
  ridge_wf,
  resamples = pokemon_folds,
  grid = penalty_grid,
  metrics = metric_set(rmse, rsq, mae)
)

lasso_res <- tune_grid(
  lasso_wf,
  resamples = pokemon_folds,
  grid = penalty_grid,
  metrics = metric_set(rmse, rsq, mae)
)

rf_res <- tune_grid(
  rf_wf,
  resamples = pokemon_folds,
  grid = rf_grid,
  metrics = metric_set(rmse, rsq, mae)
)

# ---------------------------------------------------------
# Collect cross-validation results
# ---------------------------------------------------------

linear_metrics <- collect_metrics(linear_res) %>%
  mutate(model = "Linear Regression")

ridge_metrics <- collect_metrics(ridge_res) %>%
  mutate(model = "Ridge Regression")

lasso_metrics <- collect_metrics(lasso_res) %>%
  mutate(model = "Lasso Regression")

rf_metrics <- collect_metrics(rf_res) %>%
  mutate(model = "Random Forest")

all_cv_metrics <- bind_rows(
  linear_metrics,
  ridge_metrics,
  lasso_metrics,
  rf_metrics
)

print(all_cv_metrics)

# ---------------------------------------------------------
# Select best tuned models
# ---------------------------------------------------------

best_ridge <- select_best(ridge_res, metric = "rmse")
best_lasso <- select_best(lasso_res, metric = "rmse")
best_rf <- select_best(rf_res, metric = "rmse")

print(best_ridge)
print(best_lasso)
print(best_rf)

# ---------------------------------------------------------
# Finalize workflows
# ---------------------------------------------------------

final_linear_wf <- linear_wf

final_ridge_wf <- finalize_workflow(ridge_wf, best_ridge)
final_lasso_wf <- finalize_workflow(lasso_wf, best_lasso)
final_rf_wf <- finalize_workflow(rf_wf, best_rf)

# ---------------------------------------------------------
# Fit final models on train and evaluate on test
# ---------------------------------------------------------

linear_final <- last_fit(final_linear_wf, pokemon_split, metrics = metric_set(rmse, rsq, mae))
ridge_final <- last_fit(final_ridge_wf, pokemon_split, metrics = metric_set(rmse, rsq, mae))
lasso_final <- last_fit(final_lasso_wf, pokemon_split, metrics = metric_set(rmse, rsq, mae))
rf_final <- last_fit(final_rf_wf, pokemon_split, metrics = metric_set(rmse, rsq, mae))

# ---------------------------------------------------------
# Compare test set results
# ---------------------------------------------------------

test_results <- bind_rows(
  collect_metrics(linear_final) %>% mutate(model = "Linear Regression"),
  collect_metrics(ridge_final) %>% mutate(model = "Ridge Regression"),
  collect_metrics(lasso_final) %>% mutate(model = "Lasso Regression"),
  collect_metrics(rf_final) %>% mutate(model = "Random Forest")
) %>%
  select(model, .metric, .estimate) %>%
  arrange(.metric, .estimate)

print(test_results)

# ---------------------------------------------------------
# Save model comparison results
# ---------------------------------------------------------

dir.create("outputs", showWarnings = FALSE)

write_csv(test_results, "outputs/model_comparison_results.csv")

# ---------------------------------------------------------
# Visualize model comparison
# ---------------------------------------------------------

ggplot(test_results, aes(x = reorder(model, .estimate), y = .estimate)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ .metric, scales = "free_x") +
  labs(
    title = "Model Comparison Results",
    subtitle = "Test set performance on log-transformed price",
    x = "Model",
    y = "Metric Value"
  )

# ---------------------------------------------------------
# Get predictions from best model candidate
# ---------------------------------------------------------
# Start with random forest as a likely strong nonlinear candidate.
# We can change this after reviewing test_results.

rf_predictions <- collect_predictions(rf_final) %>%
  mutate(
    predicted_price_usd = exp(.pred),
    actual_price_usd = exp(log_price_usd),
    residual_usd = actual_price_usd - predicted_price_usd
  )

write_csv(rf_predictions, "outputs/random_forest_predictions.csv")

# ---------------------------------------------------------
# Random Forest Diagnostic Plots
# ---------------------------------------------------------

ggplot(rf_predictions, aes(x = actual_price_usd, y = predicted_price_usd)) +
  geom_point(alpha = 0.4) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  scale_x_continuous(labels = dollar_format()) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Actual vs Predicted Pokemon Card Prices",
    subtitle = "Random Forest Regression",
    x = "Actual Price in USD",
    y = "Predicted Price in USD"
  )

ggplot(rf_predictions, aes(x = log_price_usd, y = .pred)) +
  geom_point(alpha = 0.4) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(
    title = "Actual vs Predicted Log Prices",
    subtitle = "Random Forest Regression",
    x = "Actual Log Price",
    y = "Predicted Log Price"
  )

ggplot(rf_predictions, aes(x = predicted_price_usd, y = residual_usd)) +
  geom_point(alpha = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_x_continuous(labels = dollar_format()) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Residual Plot for Random Forest Regression",
    x = "Predicted Price in USD",
    y = "Residual in USD"
  )

# ---------------------------------------------------------
# Variable Importance for Random Forest
# ---------------------------------------------------------

final_rf_fit <- extract_workflow(rf_final)

final_rf_fit %>%
  extract_fit_parsnip() %>%
  vip(num_features = 20) +
  labs(
    title = "Top 20 Variable Importance Scores",
    subtitle = "Random Forest Regression"
  ) 

print(test_results)
print(best_ridge)
print(best_lasso)
print(best_rf)
