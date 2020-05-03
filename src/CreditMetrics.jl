"""Implements the CreditMetrics model for portfolio credit risk"""
module CreditMetrics

using StatsFuns

"""
    to_thresholds(ps)

Convert a vector of probabilities `ps` to a vector of normal distribution
thresholds.
"""
function to_thresholds(probabilities::AbstractVector)
    n = length(probabilities) - 1
    thr = Vector{Float64}(undef, n)
    p_accumulated = 0.0
    @inbounds for idx in 1:n
        p_accumulated += probabilities[idx]
        thr[idx] = norminvcdf(p_accumulated)
    end
    return thr
end

"""
    to_probabilities(thr)

Convert a vector of normal distribution thresholds `thr` to a vector of
probabilities.
"""
function to_probabilities(thresholds::AbstractVector)
    n = length(thresholds)
    probabilities = Vector{Float64}(undef, n + 1)
    p_previous = 0.0
    @inbounds for idx in 1:n
        p = normcdf(thresholds[idx])
        probabilities[idx] = p - p_previous
        p_previous = p
    end
    @inbounds probabilities[n + 1] = 1.0 - p_previous
    return probabilities
end

include("checking.jl")

export CheckLevel, Checked, Unchecked
export to_thresholds, to_probabilities

end # module
