module CreditMetrics

using StatsFuns

function to_thresholds(probabilities)
    thr = Vector{Float64}(undef, length(probabilities)-1)
    p_accumulated = 0.0
    for idx in 1:(length(probabilities)-1)
        p_accumulated += probabilities[idx]
        thr[idx] = norminvcdf(p_accumulated)
    end
    return thr
end

function to_probabilities(thresholds)
    n = length(thresholds)
    probabilities = Vector{Float64}(undef, n + 1)
    p_previous = 0.0
    for idx in 1:n
        p = normcdf(thresholds[idx])
        probabilities[idx] = p - p_previous
        p_previous = p
    end
    probabilities[n + 1] = 1.0 - p_previous
    return probabilities
end


export to_thresholds, to_probabilities

end # module
