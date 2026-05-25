# 02_exploratory_analysis.R
# Project 4: Magic: The Gathering Draft Card Ratings Analysis
# Purpose: Explore OTJ draft card performance by card, color, rarity, and draft behavior.

library(tidyverse)
library(janitor)
library(skimr)

# Load cleaned data
mtg_clean <- read_csv("data/cleaned/mtg_otj_card_ratings_clean.csv")

# Inspect cleaned data
glimpse(mtg_clean)
names(mtg_clean)
skim(mtg_clean)

# ---------------------------------------------------------
# 1. Basic dataset summary
# ---------------------------------------------------------

dataset_summary <- mtg_clean %>%
  summarise(
    total_cards = n(),
    unique_cards = n_distinct(name),
    average_gih_wr = mean(gih_wr, na.rm = TRUE),
    median_gih_wr = median(gih_wr, na.rm = TRUE),
    average_iwd = mean(iwd, na.rm = TRUE),
    median_iwd = median(iwd, na.rm = TRUE),
    average_ata = mean(ata, na.rm = TRUE),
    average_alsa = mean(alsa, na.rm = TRUE)
  )

print(dataset_summary)

# ---------------------------------------------------------
# 2. Card counts by rarity and color group
# ---------------------------------------------------------

rarity_counts <- mtg_clean %>%
  count(rarity_full, sort = TRUE)

print(rarity_counts)

color_group_counts <- mtg_clean %>%
  count(color_group, sort = TRUE)

print(color_group_counts)

color_counts <- mtg_clean %>%
  count(color, sort = TRUE)

print(color_counts)

# ---------------------------------------------------------
# 3. Top cards by games-in-hand win rate
# ---------------------------------------------------------

top_gih_wr_cards <- mtg_clean %>%
  filter(!is.na(gih_wr), number_gih >= 1000) %>%
  arrange(desc(gih_wr)) %>%
  select(
    name, color, rarity_full, number_gih,
    gih_wr, gp_wr, gns_wr, iwd, ata, alsa
  ) %>%
  slice_head(n = 15)

print(top_gih_wr_cards)

# ---------------------------------------------------------
# 4. Lowest cards by games-in-hand win rate
# ---------------------------------------------------------

lowest_gih_wr_cards <- mtg_clean %>%
  filter(!is.na(gih_wr), number_gih >= 1000) %>%
  arrange(gih_wr) %>%
  select(
    name, color, rarity_full, number_gih,
    gih_wr, gp_wr, gns_wr, iwd, ata, alsa
  ) %>%
  slice_head(n = 15)

print(lowest_gih_wr_cards)

# ---------------------------------------------------------
# 5. Top cards by improvement when drawn
# ---------------------------------------------------------

top_iwd_cards <- mtg_clean %>%
  filter(!is.na(iwd), number_gih >= 1000) %>%
  arrange(desc(iwd)) %>%
  select(
    name, color, rarity_full, number_gih,
    gih_wr, gns_wr, iwd, ata, alsa
  ) %>%
  slice_head(n = 15)

print(top_iwd_cards)

# ---------------------------------------------------------
# 6. Performance by rarity
# ---------------------------------------------------------

performance_by_rarity <- mtg_clean %>%
  group_by(rarity_full) %>%
  summarise(
    card_count = n(),
    average_gih_wr = mean(gih_wr, na.rm = TRUE),
    median_gih_wr = median(gih_wr, na.rm = TRUE),
    average_gp_wr = mean(gp_wr, na.rm = TRUE),
    average_iwd = mean(iwd, na.rm = TRUE),
    average_ata = mean(ata, na.rm = TRUE),
    average_alsa = mean(alsa, na.rm = TRUE)
  ) %>%
  arrange(desc(average_gih_wr))

print(performance_by_rarity)

# ---------------------------------------------------------
# 7. Performance by color group
# ---------------------------------------------------------

performance_by_color_group <- mtg_clean %>%
  group_by(color_group) %>%
  summarise(
    card_count = n(),
    average_gih_wr = mean(gih_wr, na.rm = TRUE),
    median_gih_wr = median(gih_wr, na.rm = TRUE),
    average_gp_wr = mean(gp_wr, na.rm = TRUE),
    average_iwd = mean(iwd, na.rm = TRUE),
    average_ata = mean(ata, na.rm = TRUE),
    average_alsa = mean(alsa, na.rm = TRUE)
  ) %>%
  arrange(desc(average_gih_wr))

print(performance_by_color_group)

# ---------------------------------------------------------
# 8. Performance by individual color label
# ---------------------------------------------------------

performance_by_color <- mtg_clean %>%
  group_by(color) %>%
  summarise(
    card_count = n(),
    average_gih_wr = mean(gih_wr, na.rm = TRUE),
    median_gih_wr = median(gih_wr, na.rm = TRUE),
    average_gp_wr = mean(gp_wr, na.rm = TRUE),
    average_iwd = mean(iwd, na.rm = TRUE),
    average_ata = mean(ata, na.rm = TRUE),
    average_alsa = mean(alsa, na.rm = TRUE)
  ) %>%
  filter(card_count >= 3) %>%
  arrange(desc(average_gih_wr))

print(performance_by_color)

# ---------------------------------------------------------
# 9. Relationship between draft behavior and performance
# ---------------------------------------------------------

draft_behavior_correlation <- mtg_clean %>%
  select(alsa, ata, number_picked, percent_gp, gp_wr, gih_wr, iwd) %>%
  cor(use = "pairwise.complete.obs")

print(draft_behavior_correlation)

# ---------------------------------------------------------
# 10. Save analysis outputs
# ---------------------------------------------------------

dir.create("outputs", showWarnings = FALSE)

write_csv(dataset_summary, "outputs/dataset_summary.csv")
write_csv(rarity_counts, "outputs/rarity_counts.csv")
write_csv(color_group_counts, "outputs/color_group_counts.csv")
write_csv(color_counts, "outputs/color_counts.csv")
write_csv(top_gih_wr_cards, "outputs/top_gih_wr_cards.csv")
write_csv(lowest_gih_wr_cards, "outputs/lowest_gih_wr_cards.csv")
write_csv(top_iwd_cards, "outputs/top_iwd_cards.csv")
write_csv(performance_by_rarity, "outputs/performance_by_rarity.csv")
write_csv(performance_by_color_group, "outputs/performance_by_color_group.csv")
write_csv(performance_by_color, "outputs/performance_by_color.csv")