using CreditMetrics
using Test

@testset "CreditMetrics.jl" begin
    @test to_thresholds([0.5, 0.5]) == [0.0]
    @test to_probabilities([0.0]) == [0.5, 0.5]
end
