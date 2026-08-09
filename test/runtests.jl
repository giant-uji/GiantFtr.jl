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

    #PRUEBA BASICA
    df_entrada = DataFrame([
    (1, 100, DIURESIS,              100.0,  DateTime(2026, 9, 7, 8, 30)),
    (2, 100, DIURESIS,              200.0,  DateTime(2026, 9, 7, 18, 57)),
    (3, 100, DIURESIS,              300.0,  DateTime(2026, 9, 7, 23, 50))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.diuresis24h(df_entrada)

    #Si se usa condicion && condicion NO MUESTRA EL ERROR
    @test resultado.id_anonim_episodio == [100]
    @test resultado.valor_campo == [600] 
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 23, 50)]

    #PRUEBA CON DATOS QUE NO SON DIURESIS
    df_entrada = DataFrame([
    (1, 100, DIURESIS,             100.0,   DateTime(2026, 9, 7, 8, 30)),
    (2, 100, DIURESIS,             200.0,   DateTime(2026, 9, 7, 18, 57)),
    (3, 100, FRECUENCIA_CARDIACA,  300.0,   DateTime(2026, 9, 7, 23, 50))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.diuresis24h(df_entrada)

    @test resultado.id_anonim_episodio == [100]
    @test resultado.valor_campo == [300]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 18, 57)]


    #PRUEBA CON DOS EPISODIOS
    df_entrada = DataFrame([
    (1, 100, DIURESIS,              100.0,  DateTime(2026, 9, 7, 8, 30)),
    (2, 100, DIURESIS,              200.0,  DateTime(2026, 9, 7, 18, 57)),
    (3, 100, DIURESIS,              300.0,  DateTime(2026, 9, 7, 23, 50)),
    (4, 999, DIURESIS,              800.0,  DateTime(2026, 9, 8, 12, 00))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.diuresis24h(df_entrada)

    @test resultado.id_anonim_episodio == [100, 999]
    @test resultado.valor_campo == [600, 800]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 23, 50), DateTime(2026, 9, 8, 12, 00)]


   #PRUEBA CON DOS DIAS
    df_entrada = DataFrame([
    (1, 100, DIURESIS,              100.0,  DateTime(2026, 9, 7, 8, 30)),
    (2, 100, DIURESIS,              200.0,  DateTime(2026, 9, 7, 18, 57)),
    (3, 100, DIURESIS,              450.0,  DateTime(2026, 9, 8, 12, 00))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.diuresis24h(df_entrada)

    @test resultado.id_anonim_episodio == [100, 100]
    @test resultado.valor_campo == [300, 450]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 18, 57), DateTime(2026, 9, 8, 12, 00)]

    #PRUEBA EN DIA CLINICO (cambia a las 8:00)
    df_entrada = DataFrame([
    (1, 100, DIURESIS,              100.0,  DateTime(2026, 9, 7, 10, 30)),
    (2, 100, DIURESIS,              200.0,  DateTime(2026, 9, 8, 7, 59)),
    (3, 100, DIURESIS,              450.0,  DateTime(2026, 9, 8, 8, 00))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.diuresis24h(df_entrada)

    @test resultado.id_anonim_episodio == [100, 100]
    @test resultado.valor_campo == [300, 450]
    @test resultado.fecha_toma == [DateTime(2026, 9, 8, 7, 59), DateTime(2026, 9, 8, 8, 00)]
end


@testset "shock_index" begin

    #PRUEBA BASICA CON DOS ENTRADAS
    df_entrada = DataFrame([
    (1, 100, FRECUENCIA_CARDIACA,   90.0,   DateTime(2026, 9, 7, 10, 30)), 
    (2, 100, TA_SISTOLICA,          120.0,  DateTime(2026, 9, 7, 10, 30)),
    (3, 100, FRECUENCIA_CARDIACA,   100.0,  DateTime(2026, 9, 7, 10, 31)),
    (4, 100, TA_SISTOLICA,          100.0,  DateTime(2026, 9, 7, 10, 31))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.shock_index(df_entrada)

    @test resultado.id_anonim_episodio == [100, 100]
    @test resultado.valor_campo ≈ [0.75, 1]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 10, 30), DateTime(2026, 9, 7, 10, 31)]

    #PRUEBA CON FC SIN TAS
    df_entrada = DataFrame([
    (1, 100, FRECUENCIA_CARDIACA,   90.0,   DateTime(2026, 9, 7, 10, 30)), 
    (2, 100, TA_SISTOLICA,          120.0,  DateTime(2026, 9, 7, 10, 30)),
    (3, 100, FRECUENCIA_CARDIACA,   100.0,  DateTime(2026, 9, 7, 10, 31))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.shock_index(df_entrada)

    @test resultado.id_anonim_episodio == [100]
    @test resultado.valor_campo ≈ [0.75]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 10, 30)]

    #PRUEBA CON TAS SIN FC
    df_entrada = DataFrame([
    (1, 100, FRECUENCIA_CARDIACA,   90.0,   DateTime(2026, 9, 7, 10, 30)), 
    (2, 100, TA_SISTOLICA,          120.0,  DateTime(2026, 9, 7, 10, 30)),
    (3, 100, TA_SISTOLICA,          100.0,  DateTime(2026, 9, 7, 10, 31))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.shock_index(df_entrada)

    @test resultado.id_anonim_episodio == [100]
    @test resultado.valor_campo ≈ [0.75]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 10, 30)]

    #PRUEBA BASICA CON DOS EPISODIOS
    df_entrada = DataFrame([
    (1, 100, FRECUENCIA_CARDIACA,   90.0,   DateTime(2026, 9, 7, 10, 30)), 
    (2, 100, TA_SISTOLICA,          120.0,  DateTime(2026, 9, 7, 10, 30)),
    (3, 200, FRECUENCIA_CARDIACA,   100.0,  DateTime(2026, 9, 7, 10, 31)),
    (4, 200, TA_SISTOLICA,          100.0,  DateTime(2026, 9, 7, 10, 31))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.shock_index(df_entrada)

    @test resultado.id_anonim_episodio == [100, 200]
    @test resultado.valor_campo ≈ [0.75, 1]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 10, 30), DateTime(2026, 9, 7, 10, 31)]

    #PRUEBA SIN PAREJAS FC TAS EN EL MISMO EPISODIO
    df_entrada = DataFrame([
    (1, 100, FRECUENCIA_CARDIACA,   90.0,   DateTime(2026, 9, 7, 10, 30)), 
    (2, 200, TA_SISTOLICA,          120.0,  DateTime(2026, 9, 7, 10, 30)),
    (3, 100, FRECUENCIA_CARDIACA,   100.0,  DateTime(2026, 9, 7, 10, 31)),
    (4, 200, TA_SISTOLICA,          100.0,  DateTime(2026, 9, 7, 10, 31))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.shock_index(df_entrada)

    @test nrow(resultado) == 0

end


@testset "ta_media" begin

    #PRUEBA BASICA CON DOS ENTRADAS
    df_entrada = DataFrame([
    (1, 100, TA_SISTOLICA,          120.0,  DateTime(2026, 9, 7, 10, 30)), 
    (2, 100, TA_DISTOLICA,          90.0,   DateTime(2026, 9, 7, 10, 30)),
    (3, 100, TA_SISTOLICA,          100.0,  DateTime(2026, 9, 7, 10, 31)),
    (4, 100, TA_DISTOLICA,          90.0,  DateTime(2026, 9, 7, 10, 31))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.ta_media(df_entrada)

    @test resultado.id_anonim_episodio == [100, 100]
    @test resultado.valor_campo ≈ [100, 93.33333333333333]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 10, 30), DateTime(2026, 9, 7, 10, 31)]

    #PRUEBA CON TAS SIN TAD
    df_entrada = DataFrame([
    (1, 100, TA_SISTOLICA,          120.0,  DateTime(2026, 9, 7, 10, 30)), 
    (2, 100, TA_DISTOLICA,          90.0, DateTime(2026, 9, 7, 10, 30)),
    (3, 100, TA_SISTOLICA,          110.0, DateTime(2026, 9, 7, 10, 31))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.ta_media(df_entrada)

    @test resultado.id_anonim_episodio == [100]
    @test resultado.valor_campo ≈ [100]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 10, 30)]

    #PRUEBA CON TAD SIN TAS
    df_entrada = DataFrame([
    (1, 100, TA_SISTOLICA,          120.0,  DateTime(2026, 9, 7, 10, 30)), 
    (2, 100, TA_DISTOLICA,          90.0, DateTime(2026, 9, 7, 10, 30)),
    (3, 100, TA_DISTOLICA,          100.0, DateTime(2026, 9, 7, 10, 31))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.ta_media(df_entrada)

    @test resultado.id_anonim_episodio == [100]
    @test resultado.valor_campo ≈ [100]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 10, 30)]

    #PRUEBA BASICA CON DOS EPISODIOS
    df_entrada = DataFrame([
    (1, 100, TA_SISTOLICA,          120.0,  DateTime(2026, 9, 7, 10, 30)), 
    (2, 100, TA_DISTOLICA,          90.0, DateTime(2026, 9, 7, 10, 30)),
    (3, 200, TA_SISTOLICA,          100.0, DateTime(2026, 9, 7, 10, 31)),
    (4, 200, TA_DISTOLICA,          90.0, DateTime(2026, 9, 7, 10, 31))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.ta_media(df_entrada)

    @test resultado.id_anonim_episodio == [100, 200]
    @test resultado.valor_campo ≈ [100, 93.33333333333333]
    @test resultado.fecha_toma == [DateTime(2026, 9, 7, 10, 30), DateTime(2026, 9, 7, 10, 31)]

    #PRUEBA SIN PAREJAS FC TAS EN EL MISMO EPISODIO
    df_entrada = DataFrame([
    (1, 100, TA_SISTOLICA,          120.0,  DateTime(2026, 9, 7, 10, 30)), 
    (2, 200, TA_DISTOLICA,          90.0, DateTime(2026, 9, 7, 10, 30)),
    (3, 100, TA_SISTOLICA,          100.0, DateTime(2026, 9, 7, 10, 31)),
    (4, 200, TA_DISTOLICA,          90.0, DateTime(2026, 9, 7, 10, 31))],
    [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

    resultado = GiantFtr.ta_media(df_entrada)

    @test nrow(resultado) == 0

end