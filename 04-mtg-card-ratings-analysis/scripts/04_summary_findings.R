# 04_summary_findings.R
# Project 4: Magic: The Gathering Draft Card Ratings Analysis
# Purpose: Create final summary tables for README interpretation.

library(tidyverse)

# Load cleaned data
mtg_clean <- read_csv("data/cleaned/mtg_otj_card_ratings_clean.csv")

# Create outputs folder if needed
dir.create("outputs", showWarnings = FALSE)

# ---------------------------------------------------------
# 1. Final project summary
# ---------------------------------------------------------

final_summary <- mtg_clean %>%
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

print(final_summary)

# ---------------------------------------------------------
# 2. Best overall card by GIH WR
# ---------------------------------------------------------

best_gih_card <- mtg_clean %>%
  filter(!is.na(gih_wr), number_gih >= 1000) %>%
  arrange(desc(gih_wr)) %>%
  select(name, color, rarity_full, number_gih, gih_wr, iwd, ata, alsa) %>%
  slice_head(n = 1)

print(best_gih_card)

# ---------------------------------------------------------
# 3. Best card by IWD
# ---------------------------------------------------------

best_iwd_card <- mtg_clean %>%
  filter(!is.na(iwd), number_gih >= 1000) %>%
  arrange(desc(iwd)) %>%
  select(name, color, rarity_full, number_gih, gih_wr, iwd, ata, alsa) %>%
  slice_head(n = 1)

print(best_iwd_card)

# ---------------------------------------------------------
# 4. Best rarity group
# ---------------------------------------------------------

best_rarity_group <- mtg_clean %>%
  group_by(rarity_full) %>%
  summarise(
    card_count = n(),
    average_gih_wr = mean(gih_wr, na.rm = TRUE),
    average_iwd = mean(iwd, na.rm = TRUE),
    average_ata = mean(ata, na.rm = TRUE)
  ) %>%
  arrange(desc(average_gih_wr)) %>%
  slice_head(n = 1)

print(best_rarity_group)

# ---------------------------------------------------------
# 5. Best color group
# ---------------------------------------------------------

best_color_group <- mtg_clean %>%
  group_by(color_group) %>%
  summarise(
    card_count = n(),
    average_gih_wr = mean(gih_wr, na.rm = TRUE),
    average_iwd = mean(iwd, na.rm = TRUE),
    average_ata = mean(ata, na.rm = TRUE)
  ) %>%
  arrange(desc(average_gih_wr)) %>%
  slice_head(n = 1)

print(best_color_group)

# ---------------------------------------------------------
# 6. Correlations between draft behavior and performance
# ---------------------------------------------------------

correlation_summary <- mtg_clean %>%
  select(alsa, ata, percent_gp, gp_wr, gih_wr, gns_wr, iwd) %>%
  cor(use = "pairwise.complete.obs") %>%
  as.data.frame() %>%
  rownames_to_column("metric")

print(correlation_summary)

# ---------------------------------------------------------
# 7. Save final outputs
# ---------------------------------------------------------

write_csv(final_summary, "outputs/final_summary.csv")
write_csv(best_gih_card, "outputs/best_gih_card.csv")
write_csv(best_iwd_card, "outputs/best_iwd_card.csv")
write_csv(best_rarity_group, "outputs/best_rarity_group.csv")
write_csv(best_color_group, "outputs/best_color_group.csv")
write_csv(correlation_summary, "outputs/correlation_summary.csv")