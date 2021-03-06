## 20/10/18 - Sergio
## Estudos de Probabilidade

# replicate function and Monte Carlo Simulation
B <- 10000
beads <- rep(c("red", "blue"), times=c(2,3))
beads
events <- replicate(B, sample(beads, 1))
tab <- table(events)
tab
prop.table(tab)


# using the function paste

number <- "three"
suit <- "hearts"
paste(number, suit)

paste(letters[1:5], as.character(1:5))

# using the function expand.grid => gives us all the COMBINATION of 2 lists
expand.grid(pants = c("blue", "black"), shirt = c("white", "grey", "red"))


# generating a deck of cards
suits <- c("Diamonds", "Clubs", "Hearts", "Spades")
numbers <- c("Ace", "Deuce", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King")
deck1 <- expand.grid(number=numbers, suit=suits)
deck1
deck <- paste(deck1$number, deck1$suit)
deck

# Probability of King in the first card
Kings <- paste("King", suits)
Kings
deck %in% Kings
mean(deck %in% Kings)

# =========== Functions combinations() and permutations() ==========

## permutations => computes for any list of size n all the different ways we 
##                can select R itens. LOOK OUT: Order matters

library(gtools)
permutations(5, 2)

# seing 5 random 7-digit phone numbers out of all possible phone numbers 
# (without repeated numbers)

all_phone_numbers <- permutations(10, 7, v = 0:9)
n <- nrow(all_phone_numbers)
n
index <- sample(n, 5)
all_phone_numbers[index,]

# choosing two cards
hands <- permutations(52, 2, v = deck)
nrow(hands)
hands
first_card <- hands[,1]
second_card <- hands[,2]
first_card
second_card

# how many cases have a first card that is a king?
sum(first_card %in% Kings)

# What fraction of the cases with a king as the first card have also a king in 
# the second card?
sum(first_card %in% Kings & second_card %in% Kings) / sum(first_card %in% Kings)


## Now, if orders not matter? => Combinations()
# example: blackjack, if you get an ace and a face card, it's called a natural 21, 
# and you win automatically. The order doesn't matter

permutations(3,2)
combinations(3,2)

# what's the probability of a natural 21 in blackjack?
aces <- paste("Ace", suits)

facecard <- c("King", "Queen", "Jack", "Ten")
facecard <- expand.grid(number=facecard, suit=suits)
facecard <- paste(facecard$number, facecard$suit)

hands <- combinations(52, 2, v = deck)
hands
nrow(hands)

mean(hands[,1] %in% aces & hands[,2] %in% facecard | hands[,2] %in% aces & hands[,1] %in% facecard)

# using Monte Carlo Simulation

B <- 10000
results <- replicate(B, {
  hand <- sample(deck, 2)
  (hand[1] %in% aces & hand[2] %in% facecard  | 
   hand[2] %in% aces & hand[1] %in% facecard)
})
mean(results)

# ---------------------------------------------------------
# ===========  The Birthday Problem   =====================

# Supposing you're in a clasroom with 50 people. If we assume this is a randomly 
# selected group, what is the chance that at least two people have the same 
# birthday?

n <- 50
bdays <- sample(1:365, n, replace=TRUE)

# using duplicated to check

# example:
duplicated(c(1,2,3,1,4,3,5))

duplicated(bdays)
# Checking if there's at least two birthdays are the same
any(duplicated(bdays))

# Using Monte Carlo
B <- 10000
results <- replicate(B, {
  bdays <- sample(1:365, n, replace=TRUE)
  any(duplicated(bdays))
})
mean(results)

# -------------------------------------------
# ===========  Sapply   =====================

# When are the chances larger then 50%? Larger than 75%?

# Creating a function to compute fot any group
compute_prob <- function(n, B=10000){
  same_day <- replicate(B, {
    bdays <- sample(1:365, n, replace=TRUE)
    any(duplicated(bdays))
  })
  mean(same_day)
}

n <- seq(1,60)

# To execute compute_prob for n, we could use a for loop, but it's rarely the 
# preferred aproach in R

# We can perform operations on entire vectors
x <- 1:10
sqrt(x)
y <- 1:10
x * y

# Using sapply
sapply(x, sqrt)

# So...
prob <- sapply(n, compute_prob)
plot(n, prob)

# Now, instead of computing the probability of it happening, we'll compute
# the probability of it not happening

# probability of n people DON'T have the same birthday
# 1 * 364/365 * 363/365 ... (365 - n + 1) / 365

exact_prob <- function(n){
  prob_unique <- seq(365, 365 - n + 1)/365
  1 - prod(prob_unique)
  # prod => returns the product of all the values present in its arguments.
}

eprob <- sapply(n, exact_prob)
plot(n, prob)
lines(n, eprob, col = "red")

# --------------------------------------------------------------------------
# ===========  How Many Monte Carlo  Experiments Are Enough   ==============

# This is actually a challenge question. One prectical approach is to check the 
# stability of the estimate

B <- 10 ^ seq(1, 5, len = 100)


# Cheking the stability of a MOnte Carlo Simulation with the Birthday Problem 
# for 22 people
compute_prob <- function(B, n=22){
  same_day <- replicate(B, {
    bdays <- sample(1:365, n, replace=TRUE)
    any(duplicated(bdays))
  })
  mean(same_day)
}

prob <- sapply(B, compute_prob)
plot(log10(B), prob, type = "l")

# As B gets bigger and bigger, eventually it starts to stabilize

# --------------------------------------------------------------------------
# ===========  The Addition Rule   =========================================

# Exemple, to get 21 in the blackjack. Two ways, you can get an ace and a 
# facecard (A) OR you can get a facecard and an ace (B). A OR B.

# Pr(A or B) = Pr(A) + Pr(B) - Pr(A and B)

#  0.048 = (1/13 * 16/51) + (16/52 * 4/51) - 0


# --------------------------------------------------------------------------
# ===========  The Monty Hall Problem   =======================================

# Simulating the strategy of sticking to same door
B <- 10000
stick <- replicate(B, {
  doors <- as.character(1:3)
  prize <- sample(c("car", "goat", "goat"))
  prize_door <- doors[prize == "car"]
  my_pick <- sample(doors, 1)
  show <- sample(doors[!doors %in% c(my_pick, prize_door)], 1)
  stick <- my_pick
  stick == prize_door
})

mean(stick)

# Now changing the strategy, switch the door

switch <- replicate(B, {
  doors <- as.character(1:3)
  prize <- sample(c("car", "goat", "goat"))
  prize_door <- doors[prize == "car"]
  my_pick <- sample(doors, 1)
  show <- sample(doors[!doors %in% c(my_pick, prize_door)], 1)
  stick <- my_pick
  switch <- doors[!doors %in% c(my_pick, show)]
  switch == prize_door
})

mean(switch)

# You are switching from the original that had a 1 in 3 chances of being the
# one to whatever is the other option, which has to have a 2 in 3 chance.

# =================== CONTINUOUS PROBABILITY ============================

# In a list of numeric values such heights, it's not useful to construct a 
# distribution that assigns a proportion to each possible outcome


# When using distributions to summarize numeric data, it is more practical to 
# define a function that operates on intervals rather than single values =>
# emprical cumulative distribution function - eCDF

library(tidyverse)
library(dslabs)
data(heights)

x <- heights %>% filter(sex=="Male") %>% .$height
F <- function(a) mean(x <= a)

# What is the chance that a student is taller than 70? (proportion of students 
# taller than 70)
1 - F(70)

# We can use the CDF to compute the probability of any subset. Example: the
# probability of a student being between the height a an the height b
# F(b) - F(a)

# --------------------------------------------------------------------------
# ===========  Theoretical Distribution ====================================

# The CDF for the normal distribution is defined by a mathematical formula,
# which in R is obtained with the function pnorm

# F(a) = pnorm(a, avg, s)

x <- heights %>% filter(sex=="Male") %>% .$height
1 - pnorm(70.5, mean(x), sd(x))

plot(prop.table(table(x)), xlab = "a = Heights in inches", ylab = "Pr(x = a)")

# => It's much more useful for data analytic purposes to treat this outcome as
#    a continuous numeric variable

# What's the probability that someone is between 67.5 and 68.5? 68.5 and 69.5? 
# 69.5 and 70.5

   # Using the data, the actual data
mean(x <= 68.5) - mean(x <= 67.5)
mean(x <= 69.5) - mean(x <= 68.5)
mean(x <= 70.5) - mean(x <= 69.5)

   # Now using approximation

pnorm(68.5, mean(x), sd(x)) - pnorm(67.5, mean(x), sd(x))
pnorm(69.5, mean(x), sd(x)) - pnorm(68.5, mean(x), sd(x))
pnorm(70.5, mean(x), sd(x)) - pnorm(69.5, mean(x), sd(x))

# For this intervals, the normal approximation is quite useful
# For others intervals, those that don't include an integer for exemple, is not
# that useful

mean(x <= 70.9) - mean(x <= 70.1)
pnorm(70.9, mean(x), sd(x)) - pnorm(70.1, mean(x), sd(x))

    # => DISCRETIZATION


