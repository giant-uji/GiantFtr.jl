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

#Test generados con Claude Sonnet 5 esfuerzo medio
@testset "m_shock_index" begin

    @testset "DataFrame de entrada vacío" begin
        df_in = DataFrame(
            id_anonim_episodio = Int64[],
            tipo_valor_pk = Int64[],
            valor_campo = Float64[],
            fecha_toma = DateTime[]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        @test nrow(df_out) == 0
        @test names(df_out) == ["id", "id_anonim_episodio", "tipo_valor_pk", "valor_campo", "fecha_toma"]
        @test eltype(df_out.id) == Int64
        @test eltype(df_out.id_anonim_episodio) == Int64
        @test eltype(df_out.tipo_valor_pk) == Int64
        @test eltype(df_out.valor_campo) == Float64
        @test eltype(df_out.fecha_toma) == DateTime
    end

    @testset "FC y TAM presentes en el mismo instante -> calcula shock index" begin
        fecha = DateTime(2024, 1, 1, 10, 0, 0)
        df_in = DataFrame(
            id_anonim_episodio = Int64[1, 1],
            tipo_valor_pk = Int64[FRECUENCIA_CARDIACA, TA_MEDIA],
            valor_campo = Float64[90.0, 60.0],
            fecha_toma = DateTime[fecha, fecha]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        @test nrow(df_out) == 1
        @test df_out.id_anonim_episodio[1] == 1
        @test df_out.tipo_valor_pk[1] == M_SHOCK_INDEX
        @test df_out.valor_campo[1] ≈ 90.0 / 60.0
        @test df_out.fecha_toma[1] == fecha

        id_esperado = GiantFtr.get_ctes_id(fecha, M_SHOCK_INDEX, 1)
        @test df_out.id[1] == id_esperado
    end

    @testset "Solo FC, sin TAM en el mismo instante -> no genera fila" begin
        fecha = DateTime(2024, 1, 1, 10, 0, 0)
        df_in = DataFrame(
            id_anonim_episodio = Int64[1],
            tipo_valor_pk = Int64[FRECUENCIA_CARDIACA],
            valor_campo = Float64[90.0],
            fecha_toma = DateTime[fecha]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        @test nrow(df_out) == 0
    end

    @testset "Solo TAM, sin FC en el mismo instante -> no genera fila" begin
        fecha = DateTime(2024, 1, 1, 10, 0, 0)
        df_in = DataFrame(
            id_anonim_episodio = Int64[1],
            tipo_valor_pk = Int64[TA_MEDIA],
            valor_campo = Float64[60.0],
            fecha_toma = DateTime[fecha]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        @test nrow(df_out) == 0
    end

    @testset "FC y TAM en instantes distintos -> no se emparejan" begin
        fecha1 = DateTime(2024, 1, 1, 10, 0, 0)
        fecha2 = DateTime(2024, 1, 1, 11, 0, 0)
        df_in = DataFrame(
            id_anonim_episodio = Int64[1, 1],
            tipo_valor_pk = Int64[FRECUENCIA_CARDIACA, TA_MEDIA],
            valor_campo = Float64[90.0, 60.0],
            fecha_toma = DateTime[fecha1, fecha2]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        @test nrow(df_out) == 0
    end

    @testset "Otros tipos de constante distintos de FC/TAM se ignoran" begin
        fecha = DateTime(2024, 1, 1, 10, 0, 0)
        otro_tipo = 999  # cualquier tipo_valor_pk que no sea FC ni TAM
        df_in = DataFrame(
            id_anonim_episodio = Int64[1, 1, 1],
            tipo_valor_pk = Int64[FRECUENCIA_CARDIACA, TA_MEDIA, otro_tipo],
            valor_campo = Float64[90.0, 60.0, 36.5],
            fecha_toma = DateTime[fecha, fecha, fecha]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        @test nrow(df_out) == 1
        @test df_out.valor_campo[1] ≈ 90.0 / 60.0
    end

    @testset "Múltiples instantes para el mismo episodio -> una fila por instante válido" begin
        fecha1 = DateTime(2024, 1, 1, 10, 0, 0)
        fecha2 = DateTime(2024, 1, 1, 12, 0, 0)
        df_in = DataFrame(
            id_anonim_episodio = Int64[1, 1, 1, 1],
            tipo_valor_pk = Int64[FRECUENCIA_CARDIACA, TA_MEDIA, FRECUENCIA_CARDIACA, TA_MEDIA],
            valor_campo = Float64[90.0, 60.0, 100.0, 50.0],
            fecha_toma = DateTime[fecha1, fecha1, fecha2, fecha2]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        @test nrow(df_out) == 2
        sort!(df_out, :fecha_toma)
        @test df_out.fecha_toma == [fecha1, fecha2]
        @test df_out.valor_campo[1] ≈ 90.0 / 60.0
        @test df_out.valor_campo[2] ≈ 100.0 / 50.0
    end

    @testset "Múltiples episodios -> se calculan de forma independiente" begin
        fecha = DateTime(2024, 1, 1, 10, 0, 0)
        df_in = DataFrame(
            id_anonim_episodio = Int64[1, 1, 2, 2],
            tipo_valor_pk = Int64[FRECUENCIA_CARDIACA, TA_MEDIA, FRECUENCIA_CARDIACA, TA_MEDIA],
            valor_campo = Float64[80.0, 80.0, 120.0, 40.0],
            fecha_toma = DateTime[fecha, fecha, fecha, fecha]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        @test nrow(df_out) == 2
        sort!(df_out, :id_anonim_episodio)
        @test df_out.id_anonim_episodio == [1, 2]
        @test df_out.valor_campo[1] ≈ 80.0 / 80.0
        @test df_out.valor_campo[2] ≈ 120.0 / 40.0
    end

    @testset "Mismo instante, distintos episodios con una sola medición cada uno" begin
        # Verifica que el agrupado por (id_anonim_episodio, fecha_toma) no mezcla episodios
        fecha = DateTime(2024, 1, 1, 10, 0, 0)
        df_in = DataFrame(
            id_anonim_episodio = Int64[1, 2],
            tipo_valor_pk = Int64[FRECUENCIA_CARDIACA, TA_MEDIA],
            valor_campo = Float64[90.0, 60.0],
            fecha_toma = DateTime[fecha, fecha]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        # Ningún episodio tiene ambas mediciones -> no debe generarse ninguna fila
        @test nrow(df_out) == 0
    end

    @testset "Valor de shock index calculado correctamente (división FC/TAM, no al revés)" begin
        fecha = DateTime(2024, 1, 1, 10, 0, 0)
        df_in = DataFrame(
            id_anonim_episodio = Int64[1, 1],
            tipo_valor_pk = Int64[FRECUENCIA_CARDIACA, TA_MEDIA],
            valor_campo = Float64[100.0, 25.0],
            fecha_toma = DateTime[fecha, fecha]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        @test df_out.valor_campo[1] ≈ 4.0  # 100/25, no 25/100
    end

    @testset "El resultado solo contiene filas de tipo M_SHOCK_INDEX" begin
        fecha = DateTime(2024, 1, 1, 10, 0, 0)
        df_in = DataFrame(
            id_anonim_episodio = Int64[1, 1],
            tipo_valor_pk = Int64[FRECUENCIA_CARDIACA, TA_MEDIA],
            valor_campo = Float64[90.0, 60.0],
            fecha_toma = DateTime[fecha, fecha]
        )

        df_out = GiantFtr.m_shock_index(df_in)

        @test all(df_out.tipo_valor_pk .== M_SHOCK_INDEX)
    end

end

#Test generados con Claude Sonnet 5 esfuerzo medio

@testset "agrupador_generico" begin

    @testset "caso básico, sin rango_fisiologico ni rangos_anomalos" begin
        df_entrada = DataFrame([
            (1, 100, DIURESIS, 100.0, DateTime(2026, 9, 7, 8, 30)),
            (2, 100, DIURESIS, 200.0, DateTime(2026, 9, 7, 18, 57)),
            (3, 100, DIURESIS, 300.0, DateTime(2026, 9, 7, 23, 50)),
            (4, 999, DIURESIS, 800.0, DateTime(2026, 9, 8, 12, 0))],
            [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

        df_ftr = DataFrame(id_anonim_episodio=[100, 999])

        resultado = GiantFtr.agrupador_generico(
            df_entrada, df_ftr, DIURESIS, "diur",
            :id, :tipo_valor_pk, :valor_campo, :fecha_toma
        )

        # Nombres de columna: prefijo aplicado salvo a la clave de episodio
        @test names(resultado) == [
            "id_anonim_episodio", "diur_existe_valor", "diur_recuento",
            "diur_primero", "diur_ultimo", "diur_minimo", "diur_maximo",
            "diur_any_alterada", "diur_recuento_alterada", "diur_prop_alterada",
            "diur_delta_descenso", "diur_delta_aumento"
        ]

        fila_100 = resultado[resultado.id_anonim_episodio .== 100, :][1, :]
        @test fila_100.diur_recuento == 3
        @test fila_100.diur_primero == 100.0
        @test fila_100.diur_ultimo == 300.0
        @test fila_100.diur_minimo == 100.0
        @test fila_100.diur_maximo == 300.0
        @test fila_100.diur_delta_descenso == 0.0    # primero - minimo
        @test fila_100.diur_delta_aumento == 200.0    # maximo - primero
        @test fila_100.diur_existe_valor == 1
        @test fila_100.diur_any_alterada == 0
        @test fila_100.diur_prop_alterada == 0.0

        fila_999 = resultado[resultado.id_anonim_episodio .== 999, :][1, :]
        @test fila_999.diur_recuento == 1
        @test fila_999.diur_primero == fila_999.diur_ultimo == 800.0
        @test fila_999.diur_delta_descenso == 0.0
        @test fila_999.diur_delta_aumento == 0.0
    end

    @testset "episodio sin valoraciones del tipo buscado" begin
        # id 555 solo tiene un registro de otro tipo (FC) -> tras filtrar por
        # DIURESIS, el grupo queda vacío y el leftjoin debe rellenar con 0/missing
        df_entrada = DataFrame([
            (1, 555, FRECUENCIA_CARDIACA, 80.0, DateTime(2026, 9, 7, 9, 0))],
            [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

        df_ftr = DataFrame(id_anonim_episodio=[555])

        resultado = GiantFtr.agrupador_generico(
            df_entrada, df_ftr, DIURESIS, "diur",
            :id, :tipo_valor_pk, :valor_campo, :fecha_toma
        )

        fila = resultado[1, :]
        @test fila.diur_existe_valor == 0
        @test fila.diur_recuento == 0
        @test fila.diur_any_alterada == 0
        @test fila.diur_recuento_alterada == 0
        @test fila.diur_prop_alterada == 0.0
        # Estas NO se coalescen a propósito -> deben quedar missing
        @test ismissing(fila.diur_primero)
        @test ismissing(fila.diur_ultimo)
        @test ismissing(fila.diur_minimo)
        @test ismissing(fila.diur_maximo)
    end

    @testset "rango_fisiologico descarta valores fuera de rango" begin
        df_entrada = DataFrame([
            (1, 200, DIURESIS, 10.0,  DateTime(2026, 9, 7, 8, 0)),   # fuera (bajo)
            (2, 200, DIURESIS, 150.0, DateTime(2026, 9, 7, 9, 0)),   # dentro
            (3, 200, DIURESIS, 250.0, DateTime(2026, 9, 7, 10, 0)),  # dentro
            (4, 200, DIURESIS, 900.0, DateTime(2026, 9, 7, 11, 0))], # fuera (alto)
            [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

        df_ftr = DataFrame(id_anonim_episodio=[200])

        resultado = GiantFtr.agrupador_generico(
            df_entrada, df_ftr, DIURESIS, "diur",
            :id, :tipo_valor_pk, :valor_campo, :fecha_toma;
            rango_fisiologico=(50.0, 500.0)
        )

        fila = resultado[1, :]
        @test fila.diur_recuento == 2
        @test fila.diur_primero == 150.0
        @test fila.diur_ultimo == 250.0
        @test fila.diur_minimo == 150.0
        @test fila.diur_maximo == 250.0
    end

    @testset "rangos_anomalos cuenta correctamente" begin
        df_entrada = DataFrame([
            (1, 300, DIURESIS, 20.0,  DateTime(2026, 9, 7, 8, 0)),   # anómalo bajo
            (2, 300, DIURESIS, 150.0, DateTime(2026, 9, 7, 9, 0)),   # normal
            (3, 300, DIURESIS, 600.0, DateTime(2026, 9, 7, 10, 0))], # anómalo alto
            [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

        df_ftr = DataFrame(id_anonim_episodio=[300])

        resultado = GiantFtr.agrupador_generico(
            df_entrada, df_ftr, DIURESIS, "diur",
            :id, :tipo_valor_pk, :valor_campo, :fecha_toma;
            rangos_anomalos=Tuple{Float64,Float64}[(-Inf, 50.0), (500.0, Inf)]
        )

        fila = resultado[1, :]
        @test fila.diur_recuento == 3
        @test fila.diur_recuento_alterada == 2
        @test fila.diur_any_alterada == 1
        @test isapprox(fila.diur_prop_alterada, 2/3 * 100)
        @test fila.diur_delta_descenso == 0.0    # primero(20) - minimo(20)
        @test fila.diur_delta_aumento == 580.0   # maximo(600) - primero(20)
    end

    @testset "rango_fisiologico y rangos_anomalos combinados" begin
        df_entrada = DataFrame([
            (1, 400, DIURESIS, 5.0,   DateTime(2026, 9, 7, 8, 0)),   # fuera rango fisiológico
            (2, 400, DIURESIS, 40.0,  DateTime(2026, 9, 7, 9, 0)),   # dentro, anómalo bajo
            (3, 400, DIURESIS, 200.0, DateTime(2026, 9, 7, 10, 0)),  # dentro, normal
            (4, 400, DIURESIS, 480.0, DateTime(2026, 9, 7, 11, 0)),  # dentro, anómalo alto
            (5, 400, DIURESIS, 900.0, DateTime(2026, 9, 7, 12, 0))], # fuera rango fisiológico
            [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

        df_ftr = DataFrame(id_anonim_episodio=[400])

        resultado = GiantFtr.agrupador_generico(
            df_entrada, df_ftr, DIURESIS, "diur",
            :id, :tipo_valor_pk, :valor_campo, :fecha_toma;
            rango_fisiologico=(10.0, 500.0),
            rangos_anomalos=Tuple{Float64,Float64}[(-Inf, 50.0), (450.0, Inf)]
        )

        fila = resultado[1, :]
        @test fila.diur_recuento == 3           # 5.0 y 900.0 quedan fuera antes de agregar
        @test fila.diur_recuento_alterada == 2   # 40.0 y 480.0
        @test fila.diur_primero == 40.0
        @test fila.diur_ultimo == 480.0
        @test fila.diur_minimo == 40.0
        @test fila.diur_maximo == 480.0
    end

    @testset "múltiples episodios no se mezclan, y otros tipos se ignoran" begin
        df_entrada = DataFrame([
            (1, 10, DIURESIS, 50.0,  DateTime(2026, 9, 7, 8, 0)),
            (2, 10, FRECUENCIA_CARDIACA,     90.0,  DateTime(2026, 9, 7, 8, 5)),   # otro tipo, debe ignorarse
            (3, 20, DIURESIS, 300.0, DateTime(2026, 9, 7, 9, 0)),
            (4, 20, DIURESIS, 100.0, DateTime(2026, 9, 7, 10, 0))],
            [:id, :id_anonim_episodio, :tipo_valor_pk, :valor_campo, :fecha_toma])

        df_ftr = DataFrame(id_anonim_episodio=[10, 20])

        resultado = GiantFtr.agrupador_generico(
            df_entrada, df_ftr, DIURESIS, "diur",
            :id, :tipo_valor_pk, :valor_campo, :fecha_toma
        )

        fila_10 = resultado[resultado.id_anonim_episodio .== 10, :][1, :]
        @test fila_10.diur_recuento == 1
        @test fila_10.diur_primero == fila_10.diur_ultimo == 50.0

        fila_20 = resultado[resultado.id_anonim_episodio .== 20, :][1, :]
        @test fila_20.diur_recuento == 2
        @test fila_20.diur_primero == 300.0   # cronológicamente primero (9:00)
        @test fila_20.diur_ultimo == 100.0    # cronológicamente último (10:00)
        @test fila_20.diur_minimo == 100.0
        @test fila_20.diur_maximo == 300.0
        @test fila_20.diur_delta_descenso == 200.0  # primero(300) - minimo(100)
        @test fila_20.diur_delta_aumento == 0.0     # maximo(300) - primero(300)
    end

end