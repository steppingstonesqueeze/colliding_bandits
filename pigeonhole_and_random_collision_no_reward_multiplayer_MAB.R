# pigeronhole - deterministic multiplayer MAB with collision-dependent Bernoulli rewards -
# if collide, 0 ; else 1

# this is very deterministic pigeonhole - if say N players M arms, N > M
# we fill M arms first; then fill remaining N-M players one by one in each arm

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

EPSILON <- 1.e-10
# plot
ggplot(
  data = round_reward_df,
  aes(x = num_arms,
      y = tot_reward)
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")

# log reward plot and normalized users / arms
xggplot(
  data = round_reward_df,
  aes(x = num_users / num_arms,
      y = log(tot_reward + EPSILON))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")


####B Clever pigeonhole ####

# The above pigeonhole is very nAive. We can simply do the follopwing for clever pigeonhole : 
# when N > M, put first M one in each arm, then remainder N-M all on ANY one arm! That way
# we get a total reward of (M-1) when N > M and an average reward per user of (M-1)/N
# Moreover, when M >= N, we still get the reward of 1 per user or a total reward of N


clever_pigeonhole_round_reward_df <- data.frame(
  num_users = rep(-1, len1),
  num_arms = rep(-1, len1),
  tot_reward = rep(-1, len1)
)

ctr <- 1

for (n in N) {
  for (m in M) {
    
    if (n > m) {
      rew <- (m-1) / n # all arms get 1, then any one arm gets remainder so ONLY those users get zero reward
      # and remainder m-1 get reward of 1 !
      tot_rew <- n * rew
    } else if (m >= n) {
      rew <- 1
      tot_rew <- n * rew
    }
    
    clever_pigeonhole_round_reward_df[ctr, 1] <- n
    clever_pigeonhole_round_reward_df[ctr, 2] <- m
    clever_pigeonhole_round_reward_df[ctr, 3] <- tot_rew / n # normalized rweward
    
    ctr <- ctr + 1
  }
}

# plot
ggplot(
  data = clever_pigeonhole_round_reward_df,
  aes(x = num_arms,
      y = tot_reward)
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")


# log reward plot and normalized users / arms
ggplot(
  data = clever_pigeonhole_round_reward_df,
  aes(x = num_users / num_arms,
      y = log(tot_reward + EPSILON))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")


## part 2v: now we let users choose from the set of arms at random ; again if they collide with another
# user, their reward is 0. if not - reward is 1

# for each combo of N. M we know what the pigeonhole gives, so we can at the least compare this to that

T <- 1000

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

#for completeness, plot with the log reward as well
ggplot(
  data = random_strat_round_reward_df,
  aes(x = log(num_users / num_arms),
      y = log(tot_reward+EPSILON))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")


# join pigeonhole strat df and random strat df on users, arms

join1 <- merge(
  round_reward_df,
  random_strat_round_reward_df,
   by = c("num_users", "num_arms")
)

colnames(join1) <- c("num_users", "num_arms", "pigeonhole_strat_reward", "random_strat_reward")

# now join with the clever pigeonhole

join2 <- merge(
  join1,
  clever_pigeonhole_round_reward_df,
  xby = c("num_users", "num_arms")
)

colnames(join2) <- c("num_users", "num_arms", "pigeonhole_strat_reward", "random_strat_reward", "clever_pigeonhole_strat_reward")


EPSILON <- 1.0e-10
join2$random_v_clever_pigeonhole_perf <- (join2$random_strat_reward)/ (join2$clever_pigeonhole_strat_reward)
join2$pigeonhole_v_clever_pigeonhole_perf <- join2$pigeonhole_strat_reward / join2$clever_pigeonhole_strat_reward

# remove Infs and NANs - meaningless

join2 <- join2[complete.cases(join2), ]
join2 <- join2[is.finite(rowSums(join2)), ]

#join1$random_v_pigeonhole_perf <- log(join1$random_v_pigeonhole_perf)

# plot
ggplot(
  data = join2,
  aes(x = num_arms,
      y = log(random_v_clever_pigeonhole_perf+EPSILON))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")


# a final plot -- perf versus ratio of num_users / num_arms

ggplot(
  data = join2,
  aes(x = num_users / num_arms,
      y = log(random_v_clever_pigeonhole_perf+EPSILON))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")

# lets do both log-log 


ggplot(
  data = join2,
  aes(x = log(num_users / num_arms),
      y = log(random_v_clever_pigeonhole_perf+EPSILON))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")


# and now against pigeonhole


ggplot(
  data = join2,
  aes(x = num_users / num_arms,
      y = log(pigeonhole_v_clever_pigeonhole_perf+EPSILON))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")

# log-log
ggplot(
  data = join2,
  aes(x = log(num_users / num_arms),
      y = log(pigeonhole_v_clever_pigeonhole_perf+EPSILON))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")

# two final plots trhat are more illuminating as we do floor(num_arms /num_users)


ggplot(
  data = join2,
  aes(x = floor(num_users / num_arms),
      y = log(random_v_clever_pigeonhole_perf+EPSILON))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")

# and now against pigeonhole


ggplot(
  data = join2,
  aes(x = floor(num_users / num_arms),
      y = log(pigeonhole_v_clever_pigeonhole_perf+EPSILON))
) + geom_point(aes(colour = factor(num_users))) + geom_line(aes(colour = factor(num_users))) + theme(legend.position = "none")


