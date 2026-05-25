# 01_data_cleaning.R
# Project 4: Magic: The Gathering Draft Card Ratings Analysis
# Purpose: Import, inspect, clean, and prepare the OTJ draft card ratings dataset.

library(tidyverse)
library(janitor)
library(skimr)

# Load raw data
mtg_raw <- read_csv("~/Desktop/04-mtg-card-ratings-analysis/MTG-OTJ-draft-card-ratings-2024-05-25.csv")

# Inspect raw data
glimpse(mtg_raw)
names(mtg_raw)
skim(mtg_raw)

# Clean column names and convert performance columns
mtg_clean <- mtg_raw %>%
  clean_names() %>%
  mutate(
    color = replace_na(color, "Colorless/Other"),
    
    percent_gp = parse_number(percent_gp) / 100,
    gp_wr = parse_number(gp_wr) / 100,
    oh_wr = parse_number(oh_wr) / 100,
    gd_wr = parse_number(gd_wr) / 100,
    gih_wr = parse_number(gih_wr) / 100,
    gns_wr = parse_number(gns_wr) / 100,
    
    iwd = parse_number(iwd)
  )

# Check cleaned column names
names(mtg_clean)

# Check missing values
missing_summary <- mtg_clean %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "missing_count"
  ) %>%
  arrange(desc(missing_count))

print(missing_summary)

# Check duplicate rows
duplicate_count <- mtg_clean %>%
  duplicated() %>%
  sum()

print(paste("Duplicate rows:", duplicate_count))

# Remove duplicate rows if any exist
mtg_clean <- mtg_clean %>%
  distinct()

# Create useful grouped color category
mtg_clean <- mtg_clean %>%
  mutate(
    color_group = case_when(
      color %in% c("W", "U", "B", "R", "G") ~ "Mono-color",
      color == "Colorless/Other" ~ "Colorless/Other",
      nchar(color) == 2 ~ "Two-color",
      nchar(color) >= 3 ~ "Three-plus-color",
      TRUE ~ "Other"
    ),
    rarity_full = case_when(
      rarity == "C" ~ "Common",
      rarity == "U" ~ "Uncommon",
      rarity == "R" ~ "Rare",
      rarity == "M" ~ "Mythic Rare",
      TRUE ~ rarity
    )
  )

# Final inspection
glimpse(mtg_clean)
skim(mtg_clean)

# Save cleaned dataset
dir.create("data", showWarnings = FALSE)
dir.create("data/cleaned", recursive = TRUE, showWarnings = FALSE)
write_csv(mtg_clean, "data/cleaned/mtg_otj_card_ratings_clean.csv")