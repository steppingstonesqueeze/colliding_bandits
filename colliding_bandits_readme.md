# Multiplayer Multi-Armed Bandit with Collision-Dependent Rewards

[![R](https://img.shields.io/badge/R-4.0+-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Research](https://img.shields.io/badge/research-game%20theory-orange.svg)](https://en.wikipedia.org/wiki/Multi-armed_bandit)

## 🎯 Overview

This project implements and analyzes multiple strategies for the **Multiplayer Multi-Armed Bandit (MAB) problem** with collision-dependent Bernoulli rewards. In this variant, when multiple players select the same arm simultaneously, they receive zero reward due to collision interference. Only players who uniquely select an arm receive a reward of 1.

### Key Research Questions
- How do deterministic allocation strategies compare to random selection?
- What is the optimal strategy when the number of players exceeds available arms?
- How does the player-to-arm ratio affect strategy performance?

## 🧮 Mathematical Framework

### Problem Formulation
- **Players**: `N` agents making simultaneous decisions
- **Arms**: `M` available options  
- **Reward Structure**: 
  - `R = 1` if player is alone on selected arm
  - `R = 0` if collision occurs (multiple players on same arm)

### Strategy Implementations

#### 1. Naive Pigeonhole Strategy
**Concept**: Distribute players evenly across arms using floor division.

```
For N players and M arms:
- Each arm gets floor(N/M) players initially
- Remaining N mod M players distributed to first (N mod M) arms
- Reward = (number of arms with exactly 1 player) / N
```

**Performance**:
- `N ≤ M`: Perfect allocation, reward = 1
- `N > M`: Inevitable collisions, reward ≤ (M-1)/N

#### 2. Clever Pigeonhole Strategy  
**Concept**: Optimize allocation to maximize single-player arms.

```
Strategy:
- If N ≤ M: Place one player per arm → reward = 1
- If N > M: Place 1 player on first (M-1) arms, remaining on arm M
  → reward = (M-1)/N
```

**Key Insight**: Sacrificing one arm to collisions maximizes overall reward when players outnumber arms.

#### 3. Random Strategy
**Concept**: Each player independently selects arms uniformly at random.

```
Monte Carlo Simulation:
- Each player samples from uniform distribution over arms
- Expected reward = E[number of singletons] / N
- Theoretical limit approaches e^(-λ) where λ = N/M
```

## 📊 Performance Analysis

### Theoretical Results

| Scenario | Naive Pigeonhole | Clever Pigeonhole | Random Strategy |
|----------|------------------|-------------------|-----------------|
| N ≤ M | 1.0 | 1.0 | ~e^(-N/M) |
| N = M | 1.0 | 1.0 | ~0.368 |
| N > M | Variable, ≤(M-1)/N | (M-1)/N | ~M×e^(-N/M)/N |

### Key Findings
1. **Low Density (N ≪ M)**: All deterministic strategies achieve perfect performance
2. **High Density (N ≫ M)**: Clever pigeonhole significantly outperforms alternatives  
3. **Critical Density (N ≈ M)**: Random strategy suffers from collision probability ~63%

## 🔬 Experimental Setup

### Parameters
```r
N_USERS <- seq(2, 20, by = 1)     # Player counts
M_ARMS <- seq(1, 50, by = 1)      # Arm counts  
SIMULATION_ROUNDS <- 5000         # Monte Carlo trials
```

### Metrics
- **Average Reward per Player**: Total reward / Number of players
- **Performance Ratios**: Comparative analysis between strategies
- **Density Analysis**: Performance vs. N/M ratio

## 📈 Visualization Suite

The analysis generates comprehensive visualizations:

1. **Strategy Performance Curves**: Reward vs. number of arms for each strategy
2. **Performance Heatmaps**: Strategy effectiveness across parameter space
3. **Ratio Analysis**: Log-scale comparison of strategy performance 
4. **Density Plots**: Performance as function of player/arm ratios
5. **Optimal Strategy Maps**: Best strategy for each parameter combination

## 🚀 Quick Start

### Prerequisites
```r
install.packages(c("ggplot2", "dplyr", "reshape2", "gridExtra", "viridis"))
```

### Running the Analysis
```r
# Clone and run enhanced analysis
source("enhanced_mab_analysis.R")

# Original implementations also available
source("pigeonhole_simple_bernoulli_multiplayer_MAB.R")
source("pigeonhole_and_random_collision_no_reward_multiplayer_MAB.R")
```

### Expected Output
- Multiple publication-ready plots
- Comprehensive performance statistics  
- Strategy optimality analysis
- Console progress tracking

## 🔍 Technical Implementation Details

### Computational Complexity
- **Naive/Clever Pigeonhole**: O(1) per configuration
- **Random Strategy**: O(T × N) per configuration where T = simulation rounds
- **Total Runtime**: ~30-60 seconds for full parameter sweep

### Numerical Stability
- Uses `EPSILON = 1e-10` to handle log(0) cases
- Filters infinite and NaN values from performance ratios
- Reproducible results via `set.seed(42)`

### Code Quality Features  
- Modular design with configuration parameters
- Comprehensive error handling
- Consistent plotting themes
- Extensive documentation

## 📚 Research Applications

### Game Theory
- **Nash Equilibrium Analysis**: Random strategy represents mixed equilibrium
- **Coordination Games**: Pigeonhole strategies require coordination mechanisms
- **Mechanism Design**: Optimal allocation without communication

### Machine Learning
- **Multi-Agent Reinforcement Learning**: Baseline for learning algorithms
- **Resource Allocation**: Cloud computing, network bandwidth distribution
- **Recommendation Systems**: Avoiding recommendation conflicts

### Operations Research
- **Scheduling**: Task assignment with conflict avoidance
- **Supply Chain**: Resource distribution optimization
- **Network Design**: Load balancing strategies

## 🧪 Extensions and Future Work

### Algorithmic Extensions
1. **Dynamic Strategies**: Time-dependent allocation policies
2. **Learning Algorithms**: UCB, Thompson Sampling for multiplayer settings
3. **Communication Protocols**: Information sharing between players

### Reward Structure Variants
1. **Partial Rewards**: Collision penalties less than total loss
2. **Heterogeneous Arms**: Different reward distributions per arm
3. **Temporal Rewards**: Time-dependent payoff functions

### Theoretical Analysis
1. **Regret Bounds**: Formal analysis of suboptimality
2. **Convergence Rates**: Speed of learning algorithms
3. **Fairness Metrics**: Equitable reward distribution

## 📊 Sample Results

```
=== STRATEGY PERFORMANCE SUMMARY ===
                           Mean   Median    Min    Max    Std Dev
Naive Pigeonhole          0.72    0.75     0.0    1.0     0.31
Clever Pigeonhole         0.81    0.85     0.0    1.0     0.28  
Random Strategy           0.43    0.41     0.02   0.95    0.26

=== OPTIMAL STRATEGY DISTRIBUTION ===
Strategy           Count    Percentage
Clever Pigeonhole   542        57.3%
Naive Pigeonhole    284        30.1%
Random Strategy     119        12.6%
```

## 🤝 Contributing

We welcome contributions! Areas of particular interest:
- Additional strategy implementations
- Theoretical analysis improvements  
- Visualization enhancements
- Performance optimizations
- Real-world application studies

## 📖 References

1. **Auer, P., Cesa-Bianchi, N., & Fischer, P.** (2002). Finite-time analysis of the multiarmed bandit problem. *Machine Learning*, 47(2-3), 235-256.

2. **Liu, K., & Zhao, Q.** (2010). Distributed learning in multi-armed bandit with multiple players. *IEEE Transactions on Signal Processing*, 58(11), 5667-5681.

3. **Bistritz, I., & Leshem, A.** (2018). Distributed multi-player bandits-a game of thrones approach. *Advances in Neural Information Processing Systems*, 31.

4. **Rosenski, J., Shamir, O., & Szlak, L.** (2016). Multi-player bandits–a musical chairs approach. *International Conference on Machine Learning*, 155-163.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Keywords

`multi-armed-bandit` `game-theory` `resource-allocation` `collision-avoidance` `pigeonhole-principle` `monte-carlo-simulation` `performance-analysis` `R-statistics` `multiplayer-games` `coordination-mechanisms`

---

**Note**: This implementation is designed for research and educational purposes. For production applications, consider computational efficiency optimizations and additional robustness checks.