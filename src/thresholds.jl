export AbstractProbabilityVector, AbstractUnitIntervalThresholds, AbstractRealLineThresholds
export probabilities, thresholds, deformation, outcome, deformation_value, outcome_value, meanvalue
export ProbabilityVector, UnitIntervalThresholds, RealLineThresholds, DeformedRealLineThresholds

"Abstract type for probability vectors with entries of type 'T' summing to one"
abstract type AbstractProbabilityVector{T} end

"""
    probabilities(apv::AbstractProbabilityVector)

Get the probabilities of 'apv' in a raw format
"""
function probabilities(apv::AbstractProbabilityVector) end

"Abstract type for a weakly sorted vector of thresholds of type 'T' where values are between zero and one"
abstract type AbstractUnitIntervalThresholds{T} end

"""
    thresholds(auit::AbstractUnitIntervalThresholds)

Get the thresholds of 'auit' in a raw format
"""
function thresholds(auit::AbstractUnitIntervalThresholds) end

"Abstract type for a weakly sorted vector of thresholds of type 'T' where values are unconstrained"
abstract type AbstractRealLineThresholds{T} end

"""
    thresholds(arlt::AbstractRealLineThresholds)

Get the thresholds of 'arlt' in a raw format
"""
function thresholds(arlt::AbstractRealLineThresholds) end



"""
Vector of probabilities that sum to one

The ProbabilityVector type is used for checking that a vector of probabilities sums to one and using
    the type system to express that.
"""
struct ProbabilityVector{T, TVec <: AbstractVector{T}} <: AbstractProbabilityVector{T}
    probabilities::TVec
    
    """
        ProbabilityVector(ps::TVec) where {T, TVec<:AbstractVector{T}}

    Convert a raw vector 'ps' of probabilities of type 'T' to a ProbabilityVector
    """
    function ProbabilityVector(ps::TVec) where {T, TVec<:AbstractVector{T}}
        if length(ps) == 0
            throw(DomainError(ps, "Vector of probabilities was empty so could not possibly sum to one."))
        end
        if sum(ps) != one(T)
            throw(DomainError(ps, "Vector of probabilities did not sum to one."))
        end
        for p in ps
            if p < zero(T)
                throw(DomainError(ps, "At least one probability was negative"))
            end
        end
        return new{T, TVec}(ps)
    end

    """
        ProbabilityVector(apv::AbstractProbabilityVector{T}) where {T}

    Convert an AbstractProbabilityVector to a ProbabilityVector by extracting underlying probabilities
    """
    function ProbabilityVector(apv::AbstractProbabilityVector{T}) where {T}
        p = probabilities(apv)
        return new{T, typeof(p)}(p)
    end

    """
        ProbabilityVector(auit::AbstractUnitIntervalThresholds{T}) where {T}

    Convert an AbstractUnitIntervalThresholds 'auit' to a ProbabilityVector
    """
    function ProbabilityVector(auit::AbstractUnitIntervalThresholds{T}) where {T}
        thrs = thresholds(auit)
        n = length(thrs) + 1
        probabilities = Vector{T}(undef, n)
        @inbounds begin
            if n == 1
                probabilities[1] = one(T) - zero(T)
            else
                probabilities[1] = thrs[1] - zero(T)
                for i in 2:(n-1)
                    probabilities[i] = thrs[i] - thrs[i-1]
                end
                probabilities[n] = one(T) - thrs[n-1]
            end
        end
        return new{T, Vector{T}}(probabilities)
    end
end

"""
    probabilities(pv::ProbabilityVector)

Get the probabilities of 'pv' in a raw format
"""
function probabilities(pv::ProbabilityVector) 
    return pv.probabilities
end


"""
A weakly sorted vector of values on the interval from zero and one.

The UnitIntervalThresholds struct is used to check that values are in interval and weakly sorted, and using
    the type system to express that.
"""
struct UnitIntervalThresholds{T, TVec <: AbstractVector{T}} <: AbstractUnitIntervalThresholds{T}
    thresholds::TVec

    """
        UnitIntervalThresholds(thr::TVec) where {T, TVec <: AbstractVector{T}}

    Convert a vector 'thr' of thresholds of type 'T' to a UnitIntervalThresholds
    """
    function UnitIntervalThresholds(thr::TVec) where {T, TVec <: AbstractVector{T}}
        if length(thr) == 0
            return new{T, TVec}(thr)
        end
        if first(thr) < zero(T)
            throw(DomainError(thr, "Unit interval thresholds had a value less than zero."))
        end
        if last(thr) > one(T)
            throw(DomainError(thr, "Unit interval thresholds had a value greater than one."))
        end
        if !issorted(thr)
            throw(DomainError(thr, "Unit interval thresholds were not weakly sorted."))
        end
        return new{T, TVec}(thr)
    end

    """
        UnitIntervalThresholds(auit::AbstractUnitIntervalThresholds{T})

    Convert an AbstractUnitIntervalThresholds 'auit' to a UnitIntervalThresholds by extracting its thresholds
    """
    function UnitIntervalThresholds(auit::AbstractUnitIntervalThresholds{T}) where {T}
        thrs = thresholds(auit)
        return new{T, typeof(thrs)}(thrs)
    end

    """
        UnitIntervalThresholds(apv::AbstractProbabilityVector{T}) where {T}

    Convert an AbstractProbabilityVector to a UnitIntervalThresholds
    """
    function UnitIntervalThresholds(apv::AbstractProbabilityVector{T}) where {T}
        probs = probabilities(apv)
        n = length(probs)
        thresholds = Vector{T}(undef, n - 1)
    
        accumulated_probability = zero(T)
        @inbounds for i in 1:(n-1)
            accumulated_probability += probs[i]
            thresholds[i] = accumulated_probability
        end
        return new{T, Vector{T}}(thresholds)
    end
    
    """
        UnitIntervalThresholds(arlt::AbstractRealLineThresholds{TReal}, atl::AbstractThresholdLink{TUnit, TReal}) where {TUnit, TReal}

    Convert an AbstractRealLineThresholds 'arlt' to a UnitIntervalThresholds using the threshold link 'alt'
    """
    function UnitIntervalThresholds(arlt::AbstractRealLineThresholds{TReal}, atl::AbstractThresholdLink{TUnit, TReal}) where {TUnit, TReal}
        return new{TUnit, Vector{TUnit}}(cdf(atl).(thresholds(arlt)))
    end
end

"""
    thresholds(uit::UnitIntervalThresholds)

Extract raw thresholds from 'uit'
"""
function thresholds(uit::UnitIntervalThresholds)
    return uit.thresholds
end
    
"""
A weakly sorted vector of values on the real line.

The UnitIntervalThresholds struct is used to check that values are weakly sorted, and using
    the type system to express that.
"""
struct RealLineThresholds{T, TVec <: AbstractVector{T}} <: AbstractRealLineThresholds{T}
    thresholds::TVec

    """
        RealLineThresholds(rlt::TVec) where {T, TVec <: AbstractVector{T}}

    Convert a raw vector of thresholds 'rlt' of type 'T' to a RealLineThresholds
    """
    function RealLineThresholds(rlt::TVec) where {T, TVec <: AbstractVector{T}}
        if (!issorted(rlt, lt=(<=)))
            throw(DomainError(ps, "Thresholds were not weakly sorted"))
        end
        return new{T, TVec}(rlt)
    end

    """
        RealLineThresholds(arlt::AbstractRealLineThresholds{T}) where {T}
    
    Convert an AbstractRealLineThresholds 'arlt' to a RealLineThresholds by extracting the raw thresholds
    """
    function RealLineThresholds(arlt::AbstractRealLineThresholds{T}) where {T}
        thrs = thresholds(arlt)
        return new{T, typeof(thrs)}(thrs)
    end

    """
        RealLineThresholds(auit::AbstractUnitIntervalThresholds{TUnit}, atl::AbstractThresholdLink{TUnit, TReal}) where {TUnit, TReal}

    Convert an AbstractUnitIntervalThresholds 'auit' to a RealLineThresholds using the link 'atl'
    """
    function RealLineThresholds(auit::AbstractUnitIntervalThresholds{TUnit}, atl::AbstractThresholdLink{TUnit, TReal}) where {TUnit, TReal}
        return new{TReal, Vector{TReal}}(invcdf(atl).(thresholds(auit)))
    end
end

"""
    thresholds(rlt::RealLineThresholds)

Extract the raw thresholds from 'rlt'
"""
function thresholds(rlt::RealLineThresholds)
    return rlt.thresholds
end

"""
A weakly sorted vector of values on the real line that has been affinely deformed.

DeformedRealLineThresholds holds the specification of the affine deformation and defers calculation
of the deformed thresholds until they are needed.
"""
struct DeformedRealLineThresholds{T, TBase <: AbstractRealLineThresholds{T}} <: AbstractRealLineThresholds{T}
    undeformed::TBase
    push::T
    norm::T
end

"""
    thresholds(drlt::DeformedRealLineThresholds{T}) where {T}

Calculate the raw thresholds of 'drlt'
"""
function thresholds(drlt::DeformedRealLineThresholds{T}) where {T}
    return (thresholds(drlt.undeformed) .+ drlt.push) ./ drlt.norm
end


# Operations on the above types. Doc todo

function deformation(arlt::AbstractRealLineThresholds, push, norm)
    return DeformedRealLineThresholds(arlt, push, norm)
end

function deformation(auit::AbstractUnitIntervalThresholds, atl::AbstractThresholdLink, push, norm)
    return UnitIntervalThresholds(deformation(RealLineThresholds(auit, atl), push, norm), atl)
end

function deformation(apv::AbstractProbabilityVector, atl::AbstractThresholdLink, push, norm)
    return ProbabilityVector(deformation(UnitIntervalThresholds(apv), atl, push, norm))
end

function outcome(ths, z)
    return searchsortedfirst(thresholds(ths), z)
end

function outcome(ths, zs::AbstractVector)
    return [outcome(ths, z) for z in zs]
end


function meanvalue(apv::AbstractProbabilityVector, values::AbstractVector)
    ps = probabilities(apv)
    n = length(ps)
    if n != length(values)
        throw(DomainError(values, "Values did not have the same length as probablity vector"))
    end
    return sum(ps .* values)
end

function meanvalue(auit::AbstractUnitIntervalThresholds{T}, values::AbstractVector) where {T}
    thrs = thresholds(auit)
    n = length(thrs) + 1
    if n != length(values)
        throw(DomainError(values, "Values did not have length one greater than thresholds"))
    end
    @inbounds begin
        if n == 1
            return (one(T) - zero(T)) * values[1]
        else
            rv = (first(thrs) - zero(T)) * values[1]
            for i in 2:(n-1)
                rv += (thrs[i] - thrs[i-1]) * values[i]
            end
            rv += (one(T) - last(thrs)) * values[n]
            return rv
        end
    end
end


function deformation_value(auit::AbstractUnitIntervalThresholds, values::AbstractVector, atl::AbstractThresholdLink, push, norm)
    return meanvalue(deformation(auit, atl, push, norm), values)
end

function deformation_value(arlt::AbstractRealLineThresholds, values::AbstractVector, atl::AbstractThresholdLink, push, norm)
    return meanvalue(UnitIntervalThresholds(deformation(arlt, push, norm), atl), values)
end

function deformation_value(arlt::AbstractRealLineThresholds, values::AbstractVector, atl::AbstractThresholdLink, pushs::AbstractVector, norm)
    return [deformation_value(arlt, values, atl, push, norm) for push in pushs]
end

function outcome_value(auit::AbstractUnitIntervalThresholds, values::AbstractVector, p)
    return values[outcome(auit, p)]
end

function outcome_value(auit::AbstractUnitIntervalThresholds, values::AbstractVector, ps::AbstractArray)
    return [outcome_value(auit, values, p) for p in ps]
end

function outcome_value(auit::AbstractUnitIntervalThresholds, values::AbstractVector, atl::AbstractThresholdLink, z)
    return outcome_value(auit, values, cdf(atl)(z))
end

function outcome_value(auit::AbstractUnitIntervalThresholds, values::AbstractVector, atl::AbstractThresholdLink, zs::AbstractArray)
    return [outcome_value(auit, values, cdf(atl)(z)) for z in zs]
end

function outcome_value(apv::AbstractProbabilityVector, values::AbstractVector, p)
    return outcome_value(UnitIntervalThresholds(apv), values, p)
end

function outcome_value(arlt::AbstractRealLineThresholds, values::AbstractVector, z)
    return values[outcome(arlt, z)]
end

function outcome_value(arlt::AbstractRealLineThresholds, values::AbstractVector, zs::AbstractVector)
    return [outcome_value(arlt, values, z) for z in zs]
end
