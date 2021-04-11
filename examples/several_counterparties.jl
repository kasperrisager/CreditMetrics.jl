using CreditMetrics
using Statistics

# Consider three counterparties
# Please be sure to understand the single counterparty example first.

# Probabilities of ending up in each rating class after a period
pvs = ProbabilityVector{Float64}[]
push!(pvs, ProbabilityVector([0.01, 0.04, 0.10, 0.20, 0.40, 1 - (0.01 + 0.04 + 0.10 + 0.20 + 0.40)]))
push!(pvs, ProbabilityVector([0.03, 0.07, 0.20, 0.40, 0.20, 1 - (0.03 + 0.07 + 0.20 + 0.40 + 0.20)]))
push!(pvs, ProbabilityVector([0.10, 0.20, 0.35, 0.20, 0.10, 1 - (0.10 + 0.20 + 0.35 + 0.20 + 0.10)]))

# Value of the exposure to each counterparty in each rating class after a period
vals = [10 * [-1.0, -0.2, -0.1, -0.05, 0.0, 0.03], 5 * [-1.0, -0.2, -0.05, 0.0, 0.03, 0.04], 8 * [-1.0, -0.15, 0.0, 0.05, 0.08, 0.1]]

# Consider these in a -2 sigma macroeconomic scenario

# Correlations to a single macro factor
rho = [0.3, 0.2, 0.4]

# Convert to z (Gauss) based thresholds
link = NormalThresholdLink{Float64}()
thrs = [RealLineThresholds(UnitIntervalThresholds(pv), link) for pv in pvs]

# Deform thresholds according to macroeconomic environment
dthrs = [deform(thrs[i], 2.0 * rho[i], sqrt(1 - rho[i]^2)) for i in 1:3]

# Now simulate idiosyncratic effects in this environment
my_stressed_outcomes = [outcome_value(dthrs[i], vals[i], randn(1_000_000)) for i in 1:3]

# Mean outcome is depressed
[mean(my_stressed_outcomes[i]) for i in 1:3]

# The three counterparties are independent given the macro environment
[cov(my_stressed_outcomes[i], my_stressed_outcomes[j]) for i in 1:3, j in 1:3]

# Oppositely, do a lot of macroeconomic scenarios, but mean over idiosyncratic effect.
zmacro = randn(1_000_000)
my_macro_outcomes = [deformation_value(thrs[i], vals[i], link, -rho[i] * zmacro, sqrt(1 - rho[i]^2)) for i in 1:3]

my_portfolio_macro_outcomes = [sum([my_macro_outcomes[i][j] for i in 1:3]) for j in 1:1_000_000]

# Expected loss
expeced_loss_macro = -mean(my_portfolio_macro_outcomes)

# Unexpected loss at 0.5%
unexpected_loss_macro = -quantile(my_portfolio_macro_outcomes, 0.005) - expeced_loss_macro



# Combine both, to do both macro and idiosyncratic
my_full_outcomes = [outcome_value(thrs[i], vals[i], rho[i] * zmacro + sqrt(1 - rho[i]^2) * randn(1_000_000)) for i in 1:3]
my_portfolio_full_outcomes = [sum([my_full_outcomes[i][j] for i in 1:3]) for j in 1:1_000_000]

# Expected loss
expeced_loss_full = -mean(my_portfolio_full_outcomes)

# Unexpected loss at 0.5%
unexpected_loss_full = -quantile(my_portfolio_full_outcomes, 0.005) - expeced_loss_full

# No difference in expected loss
expeced_loss_full - expeced_loss_macro

# Difference in unexpected loss due to idiosyncratic effects
unexpected_loss_full - unexpected_loss_macro