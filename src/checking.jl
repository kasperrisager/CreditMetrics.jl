abstract type CheckLevel end
struct Checked <: CheckLevel end
struct Unchecked <: CheckLevel end

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

function to_thresholds(probabilites::AbstractVector{T}, ::Checked) where {T}
    verify_probabilities(probabilites)
    to_thresholds(probabilites)
end

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

function to_probabilities(thresholds::AbstractVector, ::Checked)
    verify_thresholds(thresholds)
    to_probabilities(thresholds)
end
