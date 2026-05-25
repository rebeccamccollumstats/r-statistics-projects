# 03_visualizations.R
# Project 4: Magic: The Gathering Draft Card Ratings Analysis
# Purpose: Create visualizations for OTJ draft card performance.

library(tidyverse)

# Load cleaned data
mtg_clean <- read_csv("data/cleaned/mtg_otj_card_ratings_clean.csv")

# Create figures folder if it does not exist
dir.create("figures", showWarnings = FALSE)

# ---------------------------------------------------------
# 1. Distribution of Games-in-Hand Win Rate
# ---------------------------------------------------------

gih_distribution_plot <- mtg_clean %>%
  filter(!is.na(gih_wr)) %>%
  ggplot(aes(x = gih_wr)) +
  geom_histogram(bins = 30) +
  scale_x_continuous(labels = scales::percent) +
  labs(
    title = "Distribution of Games-in-Hand Win Rate",
    subtitle = "Magic: The Gathering OTJ Draft Card Ratings",
    x = "Games-in-Hand Win Rate",
    y = "Number of Cards"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/gih_wr_distribution.png",
  plot = gih_distribution_plot,
  width = 8,
  height = 5
)

# ---------------------------------------------------------
# 2. Top 15 Cards by Games-in-Hand Win Rate
# ---------------------------------------------------------

top_gih_wr_plot <- mtg_clean %>%
  filter(!is.na(gih_wr), number_gih >= 1000) %>%
  arrange(desc(gih_wr)) %>%
  slice_head(n = 15) %>%
  ggplot(aes(x = reorder(name, gih_wr), y = gih_wr)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Top 15 Cards by Games-in-Hand Win Rate",
    subtitle = "Cards filtered to at least 1,000 games-in-hand",
    x = "Card Name",
    y = "Games-in-Hand Win Rate"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/top_15_gih_wr_cards.png",
  plot = top_gih_wr_plot,
  width = 10,
  height = 6
)

# ---------------------------------------------------------
# 3. Top 15 Cards by Improvement When Drawn
# ---------------------------------------------------------

top_iwd_plot <- mtg_clean %>%
  filter(!is.na(iwd), number_gih >= 1000) %>%
  arrange(desc(iwd)) %>%
  slice_head(n = 15) %>%
  ggplot(aes(x = reorder(name, iwd), y = iwd)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 15 Cards by Improvement When Drawn",
    subtitle = "Cards filtered to at least 1,000 games-in-hand",
    x = "Card Name",
    y = "Improvement When Drawn, in Percentage Points"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/top_15_iwd_cards.png",
  plot = top_iwd_plot,
  width = 10,
  height = 6
)

# ---------------------------------------------------------
# 4. Average GIH WR by Rarity
# ---------------------------------------------------------

gih_by_rarity_plot <- mtg_clean %>%
  group_by(rarity_full) %>%
  summarise(
    average_gih_wr = mean(gih_wr, na.rm = TRUE),
    card_count = n()
  ) %>%
  ggplot(aes(x = reorder(rarity_full, average_gih_wr), y = average_gih_wr)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Average Games-in-Hand Win Rate by Rarity",
    x = "Rarity",
    y = "Average Games-in-Hand Win Rate"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/average_gih_wr_by_rarity.png",
  plot = gih_by_rarity_plot,
  width = 8,
  height = 5
)

# ---------------------------------------------------------
# 5. Average GIH WR by Color Group
# ---------------------------------------------------------

gih_by_color_group_plot <- mtg_clean %>%
  group_by(color_group) %>%
  summarise(
    average_gih_wr = mean(gih_wr, na.rm = TRUE),
    card_count = n()
  ) %>%
  ggplot(aes(x = reorder(color_group, average_gih_wr), y = average_gih_wr)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Average Games-in-Hand Win Rate by Color Group",
    x = "Color Group",
    y = "Average Games-in-Hand Win Rate"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/average_gih_wr_by_color_group.png",
  plot = gih_by_color_group_plot,
  width = 8,
  height = 5
)

# ---------------------------------------------------------
# 6. Average GIH WR by Individual Color
# ---------------------------------------------------------

gih_by_color_plot <- mtg_clean %>%
  group_by(color) %>%
  summarise(
    average_gih_wr = mean(gih_wr, na.rm = TRUE),
    card_count = n()
  ) %>%
  filter(card_count >= 3) %>%
  ggplot(aes(x = reorder(color, average_gih_wr), y = average_gih_wr)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Average Games-in-Hand Win Rate by Color",
    subtitle = "Only color labels with at least 3 cards included",
    x = "Color",
    y = "Average Games-in-Hand Win Rate"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/average_gih_wr_by_color.png",
  plot = gih_by_color_plot,
  width = 8,
  height = 6
)

# ---------------------------------------------------------
# 7. Draft Pick Timing vs Performance
# ---------------------------------------------------------

ata_vs_gih_plot <- mtg_clean %>%
  filter(!is.na(ata), !is.na(gih_wr)) %>%
  ggplot(aes(x = ata, y = gih_wr)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Draft Pick Timing vs Card Performance",
    subtitle = "Lower ATA means the card was picked earlier",
    x = "Average Taken At",
    y = "Games-in-Hand Win Rate"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/ata_vs_gih_wr.png",
  plot = ata_vs_gih_plot,
  width = 8,
  height = 5
)

# ---------------------------------------------------------
# 8. Improvement When Drawn vs Games-in-Hand Win Rate
# ---------------------------------------------------------

iwd_vs_gih_plot <- mtg_clean %>%
  filter(!is.na(iwd), !is.na(gih_wr)) %>%
  ggplot(aes(x = iwd, y = gih_wr)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Improvement When Drawn vs Games-in-Hand Win Rate",
    x = "Improvement When Drawn, in Percentage Points",
    y = "Games-in-Hand Win Rate"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/iwd_vs_gih_wr.png",
  plot = iwd_vs_gih_plot,
  width = 8,
  height = 5
)