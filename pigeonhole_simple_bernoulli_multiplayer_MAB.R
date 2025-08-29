# pigeronhole - deterministic multiplayer MAB with collision-dependent Bernoulli rewards -
# if collide, 0 ; else 1
  
library(ggplot2)

N <- seq(2, 20, by = 1)
M <- seq(1, 50, by = 1)

len_N <- length(N)

len_M <- length(M)

len1 <- len_N * len_M

round_reward_df <- data.frame(
  num_users = rep(-1, len1),
  num_arms = rep(-1, len1),
  tot_reward = rep(-1, len1)
)

ctr <- 1

for (n in N) {
  for (m in M) {
    
    fv <- floor(n / m)
    
    if (fv == 0) {
      # more arms than users, all users get a reward 1
      rew <- 1
      tot_rew <- rew * n
    } else if (fv > 1) {
      # each arm has at least two users, implying all users get reward 0
      rew <- 0
      tot_rew <- 0
    } else {
      if (m == n) {
        rew <- 1
        tot_rew <- rew * n
      } else {
        rew <- 1
        tot_rew <- rew * (m - n + m*fv) # those arms that have only one user on them, only those users get a rew 1
      }
    }
    
    round_reward_df[ctr, 1] <- n
    round_reward_df[ctr, 2] <- m
    round_reward_df[ctr, 3] <- tot_rew / n # normalized rweward
    
    ctr <- ctr + 1
  }
}

# plot
ggplot(
  data = round_reward_df,
  aes(x = num_arms,
      y = tot_reward)
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")


## part 2v: now we let users choose from the set of arms at random ; again if they collide with another
# user, their reward is 0. if not - reward is 1

# for each combo of N. M we know what the pigeonhole gives, so we can at the least compare this to that

T <- 5000

random_strat_round_reward_df <- data.frame(
  num_users = rep(-1, len1),
  num_arms = rep(-1, len1),
  tot_reward = rep(-1, len1)
)

ctr <- 1
for (n in N) {
  cat("num users = ", n, "\n")
  for (m in M) {
    sum1 <- 0.0
    for (t in 1:T) {
      random_choice_arms <- sample(c(1:m), n, replace = TRUE)
      
      # how much reward 
      rew <- length(which(table(random_choice_arms) == 1)) #which users had no collisions
      rew <- rew / n # normalize
      sum1 <- sum1 + rew
    }
    
    sum1 <- sum1 / T
    
    random_strat_round_reward_df[ctr,1] <- n
    random_strat_round_reward_df[ctr,2] <- m
    random_strat_round_reward_df[ctr,3] <- sum1
    
    ctr <- ctr + 1
    
    
  }
}

# plot just this

# plot
ggplot(
  data = random_strat_round_reward_df,
  aes(x = num_arms,
      y = tot_reward)
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")

# plot above but with num_users / num_arms

EPSILON <- 1.0e-10

# plot
ggplot(
  data = random_strat_round_reward_df,
  aes(x = log(num_users / num_arms),
      #y = log(tot_reward+EPSILON))
      y = tot_reward)
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")

# join pigeonhole strat df and random strat df on users, arms

join1 <- merge(
  round_reward_df,
  random_strat_round_reward_df,
   by = c("num_users", "num_arms")
)

colnames(join1) <- c("num_users", "num_arms", "pigeonhole_strat_reward", "random_strat_reward")

EPSILON <- 1.0e-10
join1$random_v_pigeonhole_perf <- (join1$random_strat_reward)/ (join1$pigeonhole_strat_reward)

# remove Infs and NANs - meaningless

join1 <- join1[complete.cases(join1), ]
join1 <- join1[is.finite(rowSums(join1)), ]

#join1$random_v_pigeonhole_perf <- log(join1$random_v_pigeonhole_perf)

# plot
ggplot(
  data = join1,
  aes(x = num_arms,
      y = log(random_v_pigeonhole_perf))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")


# a final plot -- perf versus ratio of num_users / num_arms

ggplot(
  data = join1,
  aes(x = num_users / num_arms,
      y = log(random_v_pigeonhole_perf))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")


