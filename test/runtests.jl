using GiantFtr
using Test

@testset "GiantFtr.jl" begin
    @test_skip size(GiantFtr.get_ftr_hosp("../credenciales.json")) == (9304, 16) 
end
