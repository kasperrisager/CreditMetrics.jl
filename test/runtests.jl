using CreditMetrics
using Test

@testset "CreditMetrics.jl" begin
    @test to_thresholds([0.5, 0.5]) == [0.0]
    @test to_thresholds([1.0]) == []
    @test to_probabilities([0.0]) == [0.5, 0.5]
    @test to_probabilities([]) == [1.0]
end

@testset "checking.jl" begin
    # Test standard throw situations
    @test_throws DomainError CreditMetrics.verify_probabilities([])
    @test_throws DomainError CreditMetrics.verify_probabilities([0.1, 0.4])
    @test_throws DomainError CreditMetrics.verify_probabilities([-0.5, 1.5])
    @test_throws DomainError CreditMetrics.verify_thresholds([0.0, 1.0, -1.0])

    # Test that correct data does not result in errors
    @test to_thresholds([0.5, 0.5], Checked()) == [0.0]
    @test to_thresholds([1.0], Checked()) == []
    @test to_probabilities([0.0], Checked()) == [0.5, 0.5]
    @test to_probabilities([], Checked()) == [1.0]

    # Test that requiring checking does in fact cause verification
    @test_throws DomainError to_thresholds([], Checked())
    @test_throws DomainError to_probabilities([0.0, -1.0], Checked())
end
