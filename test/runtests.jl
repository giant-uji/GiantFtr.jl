using Test
using DataFrames
using LibPQ                             #Acceder a DB
using JSON                              #Leer fichero de credenciales
using CSV                               #Cargar fichero CSV
using Base.Filesystem: isfile           #Comprobar si existe fichero
using Dates                             #Columnas tipo Fecha
using CategoricalArrays: categorical    #Columnas tipo Categorica (optimizacion)
include("../src/GiantFtr.jl")
using .GiantFtr


@testset "diuresis24h" begin

    df = DataFrame(
        id = Int64[1, 2, 3, 4, 5],
        id_anonim_episodio = Int64[100, 100, 100, 100, 100],
        tipo_valor_pk = Int64[
            DIURESIS,
            DIURESIS,
            DIURESIS,
            FRECUENCIA_CARDIACA,
            DIURESIS
        ],
        valor_campo = Float64[500, 300, 200, 80, 100],
        fecha_toma = DateTime[
            DateTime(2025, 1, 10, 7, 30),   #Dia 9 por ser < 8
            DateTime(2025, 1, 10, 9, 0),    #Dia 10
            DateTime(2025, 1, 10, 15, 0),   #Dia 10
            DateTime(2025, 1, 10, 12, 0),   #Dia 10 #IGNORADO POR SER FC
            DateTime(2025, 1, 11, 8, 0)     #Dia 11 por ser >=8
        ]
    )

    resultado = diuresis24h(df)

    #Se esperan 3: dia 9, dia 10 y dia 11
    @test nrow(resultado) == 3

    #El DataFrame generado solo tiene DIURESIS24H
    @test all(resultado.tipo_valor_pk .== DIURESIS24H)

    #Se espera los siguientes resultados:
    #Dia 9: 500
    #Dia 10: 300+200 = 500
    #Dia 11: 100
    #El orden viene dado por fecha_toma
    @test resultado.valor_campo == [500.0, 500.0, 100.0]

    #La fecha debe ser igual a la fecha de la ultima diuresis
    @test sort(resultado.fecha_toma) == [
        DateTime(2025, 1, 10, 7, 30),
        DateTime(2025, 1, 10, 15, 0),
        DateTime(2025, 1, 11, 8, 0)
    ]
end


@testset "shock_index" begin

    df = DataFrame(
        id = Int64[1, 2, 3, 4, 5],
        id_anonim_episodio = Int64[
            100, 100,
            100, 100,
            100
        ],
        tipo_valor_pk = Int64[
            FRECUENCIA_CARDIACA,
            TA_SISTOLICA,
            FRECUENCIA_CARDIACA,
            TA_SISTOLICA,
            FRECUENCIA_CARDIACA
        ],
        valor_campo = Float64[
            90, 120,      # 90 / 120 = 0.75
            100, 100,     # 100 / 100 = 1.0
            80            # Sin TAS -> no resultado
        ],
        fecha_toma = DateTime[
            DateTime(2025, 1, 10, 10),
            DateTime(2025, 1, 10, 10),

            DateTime(2025, 1, 10, 12),
            DateTime(2025, 1, 10, 12),

            DateTime(2025, 1, 10, 14)
        ]
    )

    resultado = shock_index(df)

    #Se esperan 2: 0.75 y 1.0
    @test nrow(resultado) == 2

    #El DataFrame generado solo tiene SHOCK_INDEX
    @test all(resultado.tipo_valor_pk .== SHOCK_INDEX)


    #Se espera los siguientes resultados:
    # 90 / 120 = 0.75
    # 100 / 100 = 1.0
    #El orden viene dado por fecha_toma
    @test resultado.valor_campo ≈ [0.75, 1.0]

    @test sort(resultado.fecha_toma) == [
        DateTime(2025, 1, 10, 10),
        DateTime(2025, 1, 10, 12)
    ]
end


@testset "ta_media" begin

    df = DataFrame(
        id = Int64[1, 2, 3, 4],
        id_anonim_episodio = Int64[100, 100, 100, 100],
        tipo_valor_pk = Int64[
            TA_SISTOLICA,
            TA_DISTOLICA,
            FRECUENCIA_CARDIACA,
            TA_DISTOLICA
        ],
        valor_campo = Float64[
            120,
            80,
            200,
            99
        ],
        fecha_toma = DateTime[
            DateTime(2025, 1, 10, 10),
            DateTime(2025, 1, 10, 10),
            DateTime(2025, 1, 10, 11),
            DateTime(2025, 1, 10, 11)
        ]
    )

    resultado = ta_media(df)

    #Deberia dar un unico resultado
    #Como hay un TAD sin pareja NO calcula 2
    @test nrow(resultado) == 1

    #El DataFrame generado solo tiene TA_MEDIA
    @test all(resultado.tipo_valor_pk .== TA_MEDIA)

    # (120 + 2* 80)/3 = 93.33...
    @test resultado.valor_campo[1] ≈ 93.33333333333333
end