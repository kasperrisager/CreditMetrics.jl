using CreditMetrics
using Test

using StatsFuns

@testset "ProbabilityVector" begin
    # Test ProbabilityVector basics
    @test probabilities(ProbabilityVector([1.0])) == [1.0]
    @test probabilities(ProbabilityVector([0.25, 0.0, 0.5, 0.25])) == [0.25, 0.0, 0.5, 0.25]
    @test probabilities(ProbabilityVector([1])) == [1]
    @test probabilities(ProbabilityVector([Float32(1.0)])) == [Float32(1.0)]
    @test probabilities(ProbabilityVector([Float32(0.25), 0.75])) == [Float32(0.25), 0.75]

    # Test ProbabilityVector from AbstractProbabilityVector using ProbabilityVector
    @test probabilities(ProbabilityVector(ProbabilityVector([1.0]))) == [1.0]
    @test probabilities(ProbabilityVector(ProbabilityVector([0.25, 0.0, 0.5, 0.25]))) == [0.25, 0.0, 0.5, 0.25]
    @test probabilities(ProbabilityVector(ProbabilityVector([1]))) == [1]
    @test probabilities(ProbabilityVector(ProbabilityVector([Float32(1.0)]))) == [Float32(1.0)]
    @test probabilities(ProbabilityVector(ProbabilityVector([Float32(0.25), 0.75]))) == [Float32(0.25), 0.75]

    # Test ProbabilityVector errors
    @test_throws DomainError ProbabilityVector([])
    @test_throws DomainError ProbabilityVector([0.2])
    @test_throws DomainError ProbabilityVector([1.2])
    @test_throws DomainError ProbabilityVector([0.3, 0.6])
    @test_throws DomainError ProbabilityVector([0.7, 0.6])
    @test_throws DomainError ProbabilityVector([1.75, -0.75])

    # Test conversion from AbstractUnitIntervalThresholds to ProbabilityVector
    @test probabilities(ProbabilityVector(UnitIntervalThresholds(Float64[]))) == [1.0]
    @test probabilities(ProbabilityVector(UnitIntervalThresholds([0.0]))) == [0.0, 1.0]
    @test probabilities(ProbabilityVector(UnitIntervalThresholds([1.0]))) == [1.0, 0.0]
    @test probabilities(ProbabilityVector(UnitIntervalThresholds([0.25]))) == [0.25, 0.75]
    @test probabilities(ProbabilityVector(UnitIntervalThresholds([0.25, 0.5]))) == [0.25, 0.25, 0.5]
end

@testset "UnitIntervalThresholds" begin
    # Test UnitIntervalThresholds basics
    @test thresholds(UnitIntervalThresholds([])) == []
    @test thresholds(UnitIntervalThresholds([0.25])) == [0.25]
    @test thresholds(UnitIntervalThresholds([0.25, 0.75, 0.875])) == [0.25, 0.75, 0.875]
    @test thresholds(UnitIntervalThresholds([0.25, 0.25, 0.875])) == [0.25, 0.25, 0.875]
    @test thresholds(UnitIntervalThresholds([0, 0, 1, 1])) == [0, 0, 1, 1]
    @test thresholds(UnitIntervalThresholds([0.2, 1])) == [0.2, 1]

    # Test UnitIntervalThresholds from AbstractUnitIntervalThresholds via UnitIntervalThresholds
    @test thresholds(UnitIntervalThresholds(UnitIntervalThresholds([]))) == []
    @test thresholds(UnitIntervalThresholds(UnitIntervalThresholds([0.25]))) == [0.25]
    @test thresholds(UnitIntervalThresholds(UnitIntervalThresholds([0.25, 0.75, 0.875]))) == [0.25, 0.75, 0.875]
    @test thresholds(UnitIntervalThresholds(UnitIntervalThresholds([0.25, 0.25, 0.875]))) == [0.25, 0.25, 0.875]
    @test thresholds(UnitIntervalThresholds(UnitIntervalThresholds([0, 0, 1, 1]))) == [0, 0, 1, 1]
    @test thresholds(UnitIntervalThresholds(UnitIntervalThresholds([0.2, 1]))) == [0.2, 1]

    # Test UnitIntervalThresholds errors
    @test_throws DomainError UnitIntervalThresholds([-0.5])
    @test_throws DomainError UnitIntervalThresholds([-0.5, 0.5])
    @test_throws DomainError UnitIntervalThresholds([1.5])
    @test_throws DomainError UnitIntervalThresholds([0.5, 1.5])
    @test_throws DomainError UnitIntervalThresholds([0.75, 0.25])

    # Test conversions from AbstractProbabilityVector to UnitIntervalThresholds
    @test thresholds(UnitIntervalThresholds(ProbabilityVector([1.0]))) == Float64[]
    @test thresholds(UnitIntervalThresholds(ProbabilityVector([0.25, 0.75]))) == [0.25]
    @test thresholds(UnitIntervalThresholds(ProbabilityVector([0.25, 0.0, 0.75]))) == [0.25, 0.25]
end

@testset "RealLineThresholds" begin
    # Test RealLineTrhesholds basics
    @test thresholds(RealLineThresholds([])) == []
    @test thresholds(RealLineThresholds([-1.3])) == [-1.3]
    @test thresholds(RealLineThresholds([-1.3, 1.5])) == [-1.3, 1.5]
end

@testset "DeformedRealLineThresholds" begin
    # Test DeformedRealLineThresholds
    @test thresholds(DeformedRealLineThresholds(RealLineThresholds([-0.5, 0.75]), 1.75, 1.0)) == [1.25, 2.5]
end

@testset "NormalThresholdLink" begin
    # NormalThresholdLink basic
    @test cdf(NormalThresholdLink{Float64}())(1.5) == normcdf(1.5)
    @test cdf(NormalThresholdLink{Float32}())(Float32(1.5)) == normcdf(Float32(1.5))
    @test invcdf(NormalThresholdLink{Float64}())(0.3) == norminvcdf(0.3)
    @test invcdf(NormalThresholdLink{Float32}())(Float32(0.3)) == norminvcdf(Float32(0.3))

    # NormalThresholdLink errors
    @test_throws TypeError NormalThresholdLink{String}()
    @test_throws TypeError NormalThresholdLink{Int}()
end
