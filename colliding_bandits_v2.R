# Enhanced Multiplayer Multi-Armed Bandit with Collision-Dependent Rewards
# Comparing Naive Pigeonhole, Clever Pigeonhole, and Random Strategies

# Load required libraries
library(ggplot2)
library(dplyr)
library(reshape2)
library(gridExtra)
library(viridis)

# Set random seed for reproducibility
set.seed(42)

# Configuration parameters
CONFIG <- list(
  N_USERS = seq(2, 20, by = 1),           # Number of users
  M_ARMS = seq(1, 50, by = 1),            # Number of arms
  SIMULATION_ROUNDS = 5000,                # Monte Carlo simulations
  EPSILON = 1e-10,                         # Small constant to avoid log(0)
  PLOT_THEME = theme_minimal() + theme(
    legend.position = "right",
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 11)
  )
)

# Helper function to create standardized plots
create_strategy_plot <- function(data, x_var, y_var, title, x_label, y_label, 
                                color_var = "factor(num_users)") {
  ggplot(data, aes_string(x = x_var, y = y_var, color = color_var)) +
    geom_point(alpha = 0.7, size = 1.5) +
    geom_line(alpha = 0.6, linewidth = 0.8) +
    scale_color_viridis_d(name = "Users", option = "plasma") +
    labs(title = title, x = x_label, y = y_label) +
    CONFIG$PLOT_THEME
}

# Initialize results dataframe
n_combinations <- length(CONFIG$N_USERS) * length(CONFIG$M_ARMS)

results_df <- data.frame(
  num_users = integer(n_combinations),
  num_arms = integer(n_combinations),
  naive_pigeonhole_reward = numeric(n_combinations),
  clever_pigeonhole_reward = numeric(n_combinations),
  random_strategy_reward = numeric(n_combinations)
)

cat("Computing strategy rewards for", n_combinations, "parameter combinations...\n")

# Main computation loop
idx <- 1
for (n in CONFIG$N_USERS) {
  cat("Processing", n, "users...\n")
  
  for (m in CONFIG$M_ARMS) {
    results_df$num_users[idx] <- n
    results_df$num_arms[idx] <- m
    
    # === NAIVE PIGEONHOLE STRATEGY ===
    # Distribute users evenly across arms, collisions result in 0 reward
    floor_ratio <- floor(n / m)
    
    if (floor_ratio == 0) {
      # More arms than users: all users get reward 1
      naive_reward <- 1
    } else if (floor_ratio > 1) {
      # Multiple users per arm: all collisions, reward 0
      naive_reward <- 0
    } else {
      # Mixed case: some arms have 1 user, others have more
      if (m == n) {
        naive_reward <- 1
      } else {
        # Users on arms with exactly 1 user get reward 1
        single_user_arms <- m - (n - m)
        naive_reward <- single_user_arms / n
      }
    }
    
    # === CLEVER PIGEONHOLE STRATEGY ===
    # When N > M: put one user on each of first M arms, rest on any single arm
    # This maximizes reward by ensuring M-1 users get reward 1
    if (n > m) {
      clever_reward <- (m - 1) / n
    } else {
      # When M >= N: one user per arm, all get reward 1
      clever_reward <- 1
    }
    
    # === RANDOM STRATEGY ===
    # Monte Carlo simulation of random arm selection
    total_reward <- 0
    for (trial in 1:CONFIG$SIMULATION_ROUNDS) {
      arm_choices <- sample(1:m, n, replace = TRUE)
      # Count arms with exactly one user (no collisions)
      single_user_count <- sum(table(arm_choices) == 1)
      total_reward <- total_reward + (single_user_count / n)
    }
    random_reward <- total_reward / CONFIG$SIMULATION_ROUNDS
    
    # Store results
    results_df$naive_pigeonhole_reward[idx] <- naive_reward
    results_df$clever_pigeonhole_reward[idx] <- clever_reward
    results_df$random_strategy_reward[idx] <- random_reward
    
    idx <- idx + 1
  }
}

# === PERFORMANCE ANALYSIS ===
cat("Computing performance metrics...\n")

# Add derived metrics
results_df <- results_df %>%
  mutate(
    user_arm_ratio = num_users / num_arms,
    log_user_arm_ratio = log(user_arm_ratio),
    floor_user_arm_ratio = floor(user_arm_ratio),
    
    # Performance comparisons (handle division by zero)
    random_vs_naive_ratio = ifelse(naive_pigeonhole_reward > CONFIG$EPSILON,
                                  random_strategy_reward / naive_pigeonhole_reward, NA),
    random_vs_clever_ratio = ifelse(clever_pigeonhole_reward > CONFIG$EPSILON,
                                   random_strategy_reward / clever_pigeonhole_reward, NA),
    naive_vs_clever_ratio = ifelse(clever_pigeonhole_reward > CONFIG$EPSILON,
                                  naive_pigeonhole_reward / clever_pigeonhole_reward, NA),
    
    # Log performance ratios (with epsilon to handle zeros)
    log_random_vs_naive = log(random_vs_naive_ratio + CONFIG$EPSILON),
    log_random_vs_clever = log(random_vs_clever_ratio + CONFIG$EPSILON),
    log_naive_vs_clever = log(naive_vs_clever_ratio + CONFIG$EPSILON)
  ) %>%
  filter(complete.cases(.)) %>%  # Remove rows with NA values
  filter(is.finite(rowSums(select(., where(is.numeric)))))  # Remove infinite values

cat("Analysis complete! Generating visualizations...\n")

# === VISUALIZATION SUITE ===

# 1. Strategy Performance Overview
p1 <- create_strategy_plot(
  results_df, "num_arms", "clever_pigeonhole_reward",
  "Clever Pigeonhole Strategy Performance", "Number of Arms", "Average Reward per User"
)

p2 <- create_strategy_plot(
  results_df, "num_arms", "random_strategy_reward",
  "Random Strategy Performance", "Number of Arms", "Average Reward per User"
)

p3 <- create_strategy_plot(
  results_df, "user_arm_ratio", "random_vs_clever_ratio",
  "Random vs Clever Pigeonhole Performance Ratio", "Users/Arms Ratio", "Performance Ratio"
)

p4 <- create_strategy_plot(
  results_df, "log_user_arm_ratio", "log_random_vs_clever",
  "Log Performance: Random vs Clever (Log-Log Scale)", 
  "Log(Users/Arms)", "Log(Random/Clever Ratio)"
)

# 2. Strategy Comparison Heatmap
comparison_data <- results_df %>%
  select(num_users, num_arms, naive_pigeonhole_reward, 
         clever_pigeonhole_reward, random_strategy_reward) %>%
  melt(id.vars = c("num_users", "num_arms"), 
       variable.name = "strategy", value.name = "reward")

p5 <- ggplot(comparison_data, aes(x = num_arms, y = num_users, fill = reward)) +
  geom_tile() +
  facet_wrap(~strategy, labeller = labeller(strategy = c(
    "naive_pigeonhole_reward" = "Naive Pigeonhole",
    "clever_pigeonhole_reward" = "Clever Pigeonhole", 
    "random_strategy_reward" = "Random Strategy"
  ))) +
  scale_fill_viridis_c(name = "Reward", option = "plasma") +
  labs(title = "Strategy Performance Heatmap", 
       x = "Number of Arms", y = "Number of Users") +
  CONFIG$PLOT_THEME

# 3. Performance Ratio Analysis
p6 <- create_strategy_plot(
  results_df, "floor_user_arm_ratio", "log_random_vs_clever",
  "Performance vs User Density", "Floor(Users/Arms)", "Log(Random/Clever Ratio)"
)

# Display plots
print("=== MULTIPLAYER MULTI-ARMED BANDIT ANALYSIS RESULTS ===")
print(p1)
print(p2)
print(p3)
print(p4)
print(p5)
print(p6)

# === SUMMARY STATISTICS ===
cat("\n=== STRATEGY PERFORMANCE SUMMARY ===\n")
summary_stats <- results_df %>%
  summarise(
    across(c(naive_pigeonhole_reward, clever_pigeonhole_reward, random_strategy_reward),
           list(mean = mean, median = median, min = min, max = max, sd = sd),
           .names = "{.col}_{.fn}")
  )

print(summary_stats)

# Optimal strategy analysis
optimal_analysis <- results_df %>%
  mutate(
    best_strategy = case_when(
      clever_pigeonhole_reward >= naive_pigeonhole_reward & 
      clever_pigeonhole_reward >= random_strategy_reward ~ "Clever Pigeonhole",
      naive_pigeonhole_reward >= random_strategy_reward ~ "Naive Pigeonhole",
      TRUE ~ "Random"
    )
  ) %>%
  count(best_strategy) %>%
  mutate(percentage = n / sum(n) * 100)

cat("\n=== OPTIMAL STRATEGY DISTRIBUTION ===\n")
print(optimal_analysis)

cat("\nAnalysis complete! Check the generated plots for detailed insights.\n")