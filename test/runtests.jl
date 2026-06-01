using GiantFtr
using Test

@testset "GiantFtr.jl" begin
    @test_skip size(GiantFtr.get_ftr_hosp("../credenciales.json")) == (9304, 16) 
    @test GiantFtr.categoria_barthel(144350628, "../credenciales.json") == "Dependencia severa"
    @test GiantFtr.categoria_barthel(143182955, "../credenciales.json") == "Dependencia leve"
    @test GiantFtr.categoria_barthel(143155772, "../credenciales.json") == "Dependencia moderada"
end
