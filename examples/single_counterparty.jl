using CreditMetrics
using Statistics

# ========================================================
# Using CreditMetrics for simulating a single counterparty
# ========================================================

# Probabilities of being in each rating class after a period
# Note that ProbabilityVector is very unforgiving when checking if probabilities sum to one
pv = ProbabilityVector([0.05, 0.15, 0.25, 0.25, 1.0 - (0.05 + 0.15 + 0.25 + 0.25)])

# Value of the exposure to the counterparty in each rating class after a period
vals = [-1.0, -0.2, -0.1, 0.0, 0.05]

# ---------------------------------------------
# Random outcomes without macroeconomic effects
# ---------------------------------------------

# Compute a vector of values in a number of scenarios
my_base_outcomes = outcome_value(pv, vals, rand(1_000_000))

# Analytically predicted mean value from probabilities and values
meanvalue(pv, vals)

# Observed mean value is the same
mean(my_base_outcomes)

# Observed standard deviation
std(my_base_outcomes)


# --------------------------------------------------------------
# Single counterparty, but in a -2 sigma macroeconomic scenarios
# --------------------------------------------------------------

# Correlation to macroeconomic environment
rho = 0.3

# Convert to z (Gauss) based thresholds
link = NormalThresholdLink{Float64}()
thr = RealLineThresholds(UnitIntervalThresholds(pv), link)

# Deform thresholds according to macroeconomic environment
dthr = deform(thr, 2.0 * rho, sqrt(1 - rho^2))

# At this time we can either convert back to unit interval thresholds or stay in transformed coordinates
# Normally, it will be more efficient to just procede in transformed coordinates
my_stressed_outcomes = outcome_value(dthr, vals, randn(1_000_000))

# Observed mean value differs from original mean due to macroeconomic stress
mean(my_stressed_outcomes)

# Observed standard deviation
std(my_stressed_outcomes)


# Simulating over macroeconomic scenarios, but taking mean wrt the idiosyncratic effect

# For each scenario, compute value after deformation
my_macro_outcomes = deformation_value(thr, vals, link, -rho * randn(1_000_000), sqrt(1 - rho^2))

# Observed mean corresponds to unstressed mean
mean(my_macro_outcomes)

# Observed unexpected loss at 0.05%
quantile(my_macro_outcomes, 0.0005) - mean(my_macro_outcomes)
