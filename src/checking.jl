"""Type to indicate the depth of runtime checking"""
abstract type CheckLevel end

"""Check for consistency at runtime"""
struct Checked <: CheckLevel end

"""Do not check for consistency at runtime - I know what I'm doing"""
struct Unchecked <: CheckLevel end

"""
    verify_probabilities(ps)

Verify that `ps` is a vector of probabilities.
"""
function verify_probabilities(ps::AbstractVector{T}) where {T}
    if length(ps) == 0
        throw(DomainError(ps, "Vector of probabilites cannot be empty."))
    end
    if sum(ps) != one(T)
        throw(DomainError(ps, "Vector of probabilities must sum to one."))
    end
    for p in ps
        if p < zero(T)
            throw(DomainError(ps, "A probability was negative."))
        end
    end
end

"""
    to_thresholds(ps, ::Checked)

Execute `to_thresholds(ps)` but first verify that `ps` is
a proper vector of probabilities.
"""
function to_thresholds(probabilites::AbstractVector{T}, ::Checked) where {T}
    verify_probabilities(probabilites)
    to_thresholds(probabilites)
end

"""
    verify_thresholds(thrs)

Verify that `thrs` is a proper vector of thresholds.
"""
function verify_thresholds(thresholds::AbstractVector)
    n = length(thresholds)
    @inbounds if n <= 1
        return
    else
        prev_threshold = thresholds[1]
        for thr in thresholds[2:end]
            if thr < prev_threshold
                throw(DomainError(thresholds, "Thresholds are decreasing"))
            end
            prev_threshold = thr
        end
    end
end

"""
    to_probabilities(thr, ::Checked)

Execute `to_probabilities(thr)` but first verify that `thr` is indeed a proper
vector of thresholds.
"""
function to_probabilities(thresholds::AbstractVector, ::Checked)
    verify_thresholds(thresholds)
    to_probabilities(thresholds)
end
