using Test
using DataFrames
using Dates                             #Columnas tipo Fecha
using GiantFtr


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