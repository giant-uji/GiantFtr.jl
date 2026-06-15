using GiantFtr
using Test

@testset "GiantFtr.jl" begin
    @test_skip size(get_ftr_hosp("../credenciales.json")) == (9304, 16) 
    @test categoria_barthel(144350628, "../credenciales.json") == "Dependencia severa"
    @test categoria_barthel(143182955, "../credenciales.json") == "Dependencia leve"
    @test categoria_barthel(143155772, "../credenciales.json") == "Dependencia moderada"
end
