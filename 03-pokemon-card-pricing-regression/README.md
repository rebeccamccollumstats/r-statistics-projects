## Project 3: Pokémon Card Price Prediction

**Project Type:** Regression Modeling  
**Primary Tool:** R  
**Project Status:** In Progress  

### Project Overview

Project 3 is a regression modeling project titled **Pokémon Card Price Prediction: An E-Commerce Pricing Analysis in R**. This project uses a Pokémon card sales/listing dataset to examine which card and listing features are associated with market price.

The main response variable for this project is `price_usd` because it standardizes all prices into the same currency. The original `price` column is still useful for reference, but it depends on the listing’s original currency. For modeling and comparison, `price_usd` is the cleaner and more consistent target variable.

---

## Step 1: Data Cleaning and Preparation

The first step of this project focused on importing the raw dataset, inspecting its structure, identifying missing values, cleaning variable names, preparing important variables, and saving a cleaned version of the data for later analysis.

### 1a. Packages Used

| Package | Purpose |
|---|---|
| `tidyverse` | A collection of packages used for data cleaning, transformation, visualization, and importing data. This includes `dplyr`, `readr`, `ggplot2`, `tidyr`, `tibble`, and more. |
| `janitor` | Used for `clean_names()`, which standardizes column names into clean `snake_case` format. |
| `skimr` | Used for `skim()`, which gives a detailed summary of variables, missing values, and distributions. |

### 1b. Important Functions Used

| Package | Functions Used |
|---|---|
| `readr` | Used to read CSV files. The function `read_csv()` comes from `readr`, which is included in the `tidyverse`. |
| `dplyr` | Used for data cleaning verbs such as `filter()`, `mutate()`, `distinct()`, `summarise()`, and `arrange()`. |
| `tidyr` | Used for reshaping data. The function `pivot_longer()` was used to convert the missing value summary into a readable format. |
| `ggplot2` | Not heavily used in Step 1, but it will be used in later visualization steps. |

### 1c. Loading the Data

The dataset successfully loaded with **542 rows** and **32 columns**. This is enough data for a regression modeling project. The dataset includes card features, listing features, price variables, and sale-related fields.

### 1d. Cleaning Column Names

The function `clean_names()` was used to make column names easier to use in R. This function converts names into consistent `snake_case` formatting.

This step helps prevent problems caused by spaces, capital letters, punctuation, and inconsistent naming conventions.

### 1e. Important Variables

| Variable | Description |
|---|---|
| `price_usd` | Main target variable for modeling. This is the standardized card price in U.S. dollars. |
| `log_price_usd` | Created variable. This is the log-transformed version of `price_usd`, which may be better for regression modeling. |
| `rarity_class` | Card rarity category. This is a useful predictor. |
| `condition_std` | Standardized card condition. This is a useful predictor. |
| `is_graded` | Indicates whether a card is graded. This is a useful predictor. |
| `numeric_grade` | Numeric grade for graded cards. This is missing for most ungraded cards. |
| `grading_company` | Company that graded the card. This is missing for most ungraded cards. |
| `language` | Card language. This is a useful predictor. |
| `seller_country` | Seller location. This may be a useful listing-related predictor. |
| `seller_listing_count` | Number of listings from the seller. This may represent seller activity. |
| `is_holo`, `is_full_art`, `is_promo`, etc. | Binary card feature indicators. These are useful predictors. |

### 1f. Creating a Missing Value Summary

Before modeling, it is important to understand where values are missing. Missing data affects how the dataset should be cleaned and which variables can be safely used in modeling.

The object `missing_summary` shows which variables have missing values and how many values are missing for each variable.

### 1g. Results of `missing_summary`

| Variable | Missing Count | Interpretation |
|---|---:|---|
| `numeric_grade` | 512 | Most cards are not graded, so missing numeric grades are expected. |
| `grading_company` | 503 | Most cards are ungraded, so missing grading companies are expected. |
| `card_number` | 131 | Some listings do not include a card number. This column can be kept, but it should not be used as a main predictor. |
| `days_since_sold` | 4 | Only 4 values are missing. It is reasonable to fill these with the median for this project. |
| `sale_month` | 4 | Only 4 values are missing. It is reasonable to fill these with the median. |
| `sale_year` | 4 | Only 4 values are missing. It is reasonable to fill these with the median. |

Rows should not be deleted just because `numeric_grade` or `grading_company` is missing. In this dataset, those missing values usually mean the card is ungraded, not that the data is unusable.

### 1h. Removing Duplicate Rows

Duplicate rows can cause repeated listings to be counted more than once. I used the function `distinct()` to remove exact duplicate rows.

This helps ensure that repeated records do not distort summary statistics, visualizations, or regression results.

### 1i. Choosing the Target Variable

The modeling target for this project is `price_usd`. This is better than using the original `price` column because the original price depends on the listing currency. Since the dataset includes multiple currencies, `price_usd` creates a fairer and more consistent comparison across listings.

I also created `log_price_usd` because collectible card prices are usually right-skewed. This means many cards have lower prices, while a smaller number of cards are much more expensive. A log transformation can make the distribution easier to model with linear regression.

### 1j. Handling Missing Values

Missing values were handled based on what they likely mean in the real world, rather than deleting rows automatically.

#### Grading Variables

For `grading_company`, missing values were changed to `"Ungraded"`. This preserves useful information because an ungraded card is meaningfully different from a graded card in terms of price and collectibility.

For `numeric_grade`, missing values were changed to `0`. This tells the model that ungraded cards do not have a numeric grade. This works because the dataset also includes `is_graded`, which separates graded cards from ungraded cards.

#### Date-Related Variables

For `days_since_sold`, `sale_month`, and `sale_year`, only 4 values were missing from the dataset. Filling these values with the median is reasonable for this project because it avoids losing rows over a very small amount of missing data.

### 1k. Converting Variable Types

Some columns are categories, not true numeric measurements. For example, `rarity_class`, `language`, `condition_std`, and `seller_country` should be treated as categorical variables.

Binary indicators such as `is_holo`, `is_promo`, `is_full_art`, and `is_graded` were also converted to factors for easier modeling and interpretation.

### 1l. Checking That Missing Value Fixes Worked

After handling missing values, I checked that key variables no longer had missing values. These checks returned `0`, which means the cleaning process worked for those variables.

The variables checked were:

- `numeric_grade`
- `grading_company`
- `days_since_sold`

### Step 1 Output

At the end of Step 1, the cleaned dataset was saved as:

```text
data/cleaned/pokemon_card_pricing_cleaned_initial.csv


