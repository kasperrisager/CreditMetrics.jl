export AbstractThresholdLink
export cdf, invcdf
export NormalThresholdLink, StudentThresholdLink

"Abstract type for link functions between probabilities and values on the whole real line"
abstract type AbstractThresholdLink{TUnit, TReal} end

"""
    cdf(atl::AbstractThresholdLink)

Get the link function from real line to probability for the link specification 'atl'
"""
function cdf(atl::AbstractThresholdLink) end

"""
    invcdf(atl::AbstractThresholdLink)

Get the link function from probability to real line for the link specification 'atl'
"""
function invcdf(atl::AbstractThresholdLink) end

"Normal distribution link specification using StatsFuns implementation of normal cdf and invcdf"
struct NormalThresholdLink{T <: AbstractFloat} <: AbstractThresholdLink{T, T}
end

"""
    cdf(ntl::NormalThresholdLink)

Get the link function from real line to probability for 'ntl' which is always the normal cdf
"""
function cdf(ntl::NormalThresholdLink)
    return normcdf
end

"""
    invcdf(ntl::NormalThresholdLink)

Get the link function from probability to real line for 'ntl' which is always the normal inverse cdf
"""
function invcdf(ntl::NormalThresholdLink)
    return norminvcdf
end

"Student's distribution link specification using StatsFuns implementation of Student's cdf and invcdf"
struct StudentThresholdLink <: AbstractThresholdLink{Float64, Float64}
    df::Union{Float64, Int64}

    """
        StudentThresholdLink(df::Union{Float64, Int64})
    
    Construct a StudentThresholdLink with 'df' degrees of freedom    
    """
    function StudentThresholdLink(df::Union{Float64, Int64})
        if df <= 0
            throw(DomainError(df, "Degrees of freedom was not positive"))
        end
        return new(df)
    end
end

"""
    cdf(stl::StudentThresholdLink)

Get the link function from real line to probability for 'stl' which is the Student's cdf with degrees 
    of freedom specified by 'stl'
"""
function cdf(stl::StudentThresholdLink)
    return q -> tdistcdf(stl.df, q)
end

"""
    invcdf(stl::StudentThresholdLink)

Get the link function from probability to real line for 'stl' which is the Student's inverse cdf with degrees 
    of freedom specified by 'stl'
"""
function invcdf(stl::StudentThresholdLink)
    return p -> tdistinvcdf(stl.df, p)
end