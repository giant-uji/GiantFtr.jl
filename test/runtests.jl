using GiantFtr
using Test

@testset "GiantFtr.jl" begin
    @test size(GiantFtr.get_ftr_hosp("../credenciales.json")) == (9304, 16) skip = true
end
