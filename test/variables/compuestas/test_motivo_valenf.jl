using DataFrames
using Dates
using Test
using GiantFtr

@testset "ajustar_motivo - Tabla de verdad" begin
    # Casos base (un solo motivo)
    @test GiantFtr.ajustar_motivo(String[]) == "Desconocido"
    @test GiantFtr.ajustar_motivo(["Alta"]) == "Alta"
    @test GiantFtr.ajustar_motivo(["Ingreso"]) == "Ingreso"
    @test GiantFtr.ajustar_motivo(["Protocolo_2"]) == "Protocolo_2"
    @test GiantFtr.ajustar_motivo(["Protocolo_3"]) == "Protocolo_3"
    @test GiantFtr.ajustar_motivo(["PostQui24"]) == "PostQui24"
    @test GiantFtr.ajustar_motivo(["PostQui48"]) == "PostQui48"
    @test GiantFtr.ajustar_motivo(["Error_umbral"]) == "Error_umbral"

    # Desempates de negocio
    @test GiantFtr.ajustar_motivo(["Ingreso", "Alta"]) == "Ingreso"
    @test GiantFtr.ajustar_motivo(["Ingreso", "PostQui24"]) == "PostQui24"
    @test GiantFtr.ajustar_motivo(["Ingreso", "PostQui48"]) == "PostQui48"
    @test GiantFtr.ajustar_motivo(["Alta", "PostQui24"]) == "PostQui24"
    @test GiantFtr.ajustar_motivo(["Alta", "PostQui48"]) == "PostQui48"
    @test GiantFtr.ajustar_motivo(["Alta", "Protocolo_2"]) == "Protocolo_2"
    @test GiantFtr.ajustar_motivo(["Alta", "Protocolo_3"]) == "Protocolo_3"

    # Casos imposibles (Ingreso + Protocolo)
    @test GiantFtr.ajustar_motivo(["Ingreso", "Protocolo_2"]) == "ERROR_PROTOCOLO: Contactad con los informaticos"
    @test GiantFtr.ajustar_motivo(["Ingreso", "Protocolo_3"]) == "ERROR_PROTOCOLO: Contactad con los informaticos"

    # Error_umbral combinado
    @test GiantFtr.ajustar_motivo(["Error_umbral", "Alta"]) == "ERROR_UMBRAL: Contactad con los informaticos"
end

@testset "primer_valenf_no_error - Saltar errores de umbral" begin
    df_valenf = DataFrame([
        (1, 100, false, DateTime(2024, 1, 1)),
        (2, 100, false, DateTime(2024, 1, 2)),
        (3, 100, false, DateTime(2024, 1, 3))],
        [:id, :id_anonim_episodio, :error_umbral, :fecha_valoracion])
    sort!(df_valenf, [:id_anonim_episodio, :fecha_valoracion])

    @test GiantFtr.primer_valenf_no_error(df_valenf, 1) == 1

    df_valenf.error_umbral = [true, false, false]
    @test GiantFtr.primer_valenf_no_error(df_valenf, 1) == 2

    df_valenf.error_umbral = [true, true, false]
    @test GiantFtr.primer_valenf_no_error(df_valenf, 1) == 3
end

@testset "primer_valenf - Encontrar primer valenf en rango" begin
    df_valenf = DataFrame([
        (1, 100, false, DateTime(2024, 1, 1, 0)),
        (2, 100, false, DateTime(2024, 1, 1, 12)),
        (3, 100, false, DateTime(2024, 1, 2, 0)),
        (4, 200, false, DateTime(2024, 1, 1, 6))],
        [:id, :id_anonim_episodio, :error_umbral, :fecha_valoracion])
    sort!(df_valenf, [:id_anonim_episodio, :fecha_valoracion])

    @test GiantFtr.primer_valenf(df_valenf, 100, DateTime(2024, 1, 1, 0), 24) == 1
    @test GiantFtr.primer_valenf(df_valenf, 100, DateTime(2024, 1, 1, 0), 6) == 1
    @test GiantFtr.primer_valenf(df_valenf, 100, DateTime(2024, 1, 1, 1), 12) == 2
    @test GiantFtr.primer_valenf(df_valenf, 100, DateTime(2024, 1, 3, 0), 24) === nothing
    @test GiantFtr.primer_valenf(df_valenf, 999, DateTime(2024, 1, 1), 24) === nothing
end

@testset "ultimo_valenf - Encontrar último valenf en rango" begin
    df_valenf = DataFrame([
        (1, 100, DateTime(2024, 1, 1, 0)),
        (2, 100, DateTime(2024, 1, 1, 12)),
        (3, 100, DateTime(2024, 1, 2, 0))],
        [:id, :id_anonim_episodio, :fecha_valoracion])
    sort!(df_valenf, [:id_anonim_episodio, :fecha_valoracion])

    @test GiantFtr.ultimo_valenf(df_valenf, 100, DateTime(2024, 1, 1, 18), 24) == 2
    @test GiantFtr.ultimo_valenf(df_valenf, 100, DateTime(2024, 1, 1, 6), 6) == 1
    @test GiantFtr.ultimo_valenf(df_valenf, 100, DateTime(2023, 12, 31), 24) === nothing
end

@testset "motivo_ingreso - Primeras 24h desde ingreso" begin
    df_valenf = DataFrame([
        (1, 100, false, DateTime(2024, 1, 1, 0)),
        (2, 100, false, DateTime(2024, 1, 2, 0)),
        (3, 100, false, DateTime(2024, 1, 3, 0)),
        (4, 200, false, DateTime(2024, 1, 1, 6))],
        [:id, :id_anonim_episodio, :error_umbral, :fecha_valoracion])
    sort!(df_valenf, [:id_anonim_episodio, :fecha_valoracion])
    df_valenf.posible_motivo = [String[] for _ in 1:nrow(df_valenf)]

    df_ftr = DataFrame([
        (100, DateTime(2023, 12, 31, 12), DateTime(2024, 1, 5)),
        (200, DateTime(2024, 1, 1, 0),    DateTime(2024, 1, 5))],
        [:id_anonim_episodio, :fecha_ingreso, :fecha_alta])

    result = GiantFtr.motivo_ingreso(df_valenf, df_ftr)

    @test result[1, :posible_motivo] == ["Ingreso"]
    @test result[2, :posible_motivo] == String[]
    @test result[3, :posible_motivo] == String[]
    @test result[4, :posible_motivo] == ["Ingreso"]
end

@testset "motivo_ingreso - Transitividad a través de error_umbral" begin
    df_valenf = DataFrame([
        (1, 100, true,  DateTime(2024, 1, 1, 23, 55)),
        (2, 100, false, DateTime(2024, 1, 2, 0, 5)),
        (3, 100, false, DateTime(2024, 1, 3, 0))],
        [:id, :id_anonim_episodio, :error_umbral, :fecha_valoracion])
    sort!(df_valenf, [:id_anonim_episodio, :fecha_valoracion])
    df_valenf.posible_motivo = [String[] for _ in 1:nrow(df_valenf)]

    df_ftr = DataFrame([
        (100, DateTime(2024, 1, 1, 0), DateTime(2024, 1, 5))],
        [:id_anonim_episodio, :fecha_ingreso, :fecha_alta])

    result = GiantFtr.motivo_ingreso(df_valenf, df_ftr)

    @test result[1, :posible_motivo] == String[]
    @test "Ingreso" in result[2, :posible_motivo]
    @test result[3, :posible_motivo] == String[]
end

@testset "motivo_postqui - 24h/48h tras intervención" begin
    df_valenf = DataFrame([
        (1, 100, false, DateTime(2024, 1, 2, 0)),
        (2, 100, false, DateTime(2024, 1, 3, 0)),
        (3, 200, false, DateTime(2024, 1, 2, 12)),
        (4, 200, false, DateTime(2024, 1, 4, 0))],
        [:id, :id_anonim_episodio, :error_umbral, :fecha_valoracion])
    sort!(df_valenf, [:id_anonim_episodio, :fecha_valoracion])

    df_valenf.posible_motivo = [String[] for _ in 1:nrow(df_valenf)]

    df_qui = DataFrame([
        (100, DateTime(2024, 1, 1, 6), 3),
        (200, DateTime(2024, 1, 1, 0), 7)],
        [:id_anonim_episodio, :fecha_fin, :codigo_destino])

    result = GiantFtr.motivo_postqui(df_valenf, df_qui)

    @test "PostQui24" in result[1, :posible_motivo]
    @test result[2, :posible_motivo] == String[]
    @test "PostQui48" in result[3, :posible_motivo]
    @test result[4, :posible_motivo] == String[]
end

@testset "motivo_postqui - Transitividad a través de error_umbral" begin
    df_valenf = DataFrame([
        (1, 100, true,  DateTime(2024, 1, 1, 23, 55)),
        (2, 100, false, DateTime(2024, 1, 2, 0, 5))],
        [:id, :id_anonim_episodio, :error_umbral, :fecha_valoracion])
    sort!(df_valenf, [:id_anonim_episodio, :fecha_valoracion])
    df_valenf.posible_motivo = [String[] for _ in 1:nrow(df_valenf)]

    df_qui = DataFrame([
        (100, DateTime(2024, 1, 1, 0), 3)],
        [:id_anonim_episodio, :fecha_fin, :codigo_destino])

    result = GiantFtr.motivo_postqui(df_valenf, df_qui)

    @test result[1, :posible_motivo] == String[]
    @test "PostQui24" in result[2, :posible_motivo]
end

@testset "motivo_protocolo - Según Braden previo y horas previas" begin
    df_valenf = DataFrame([
        (1, 100, 15.0,  missing, missing, DateTime(2024, 1, 1), false),
        (2, 100, 15.5,  15.0, 168.0,      DateTime(2024, 1, 1), false),
        (3, 200, 10.0,  missing, missing, DateTime(2024, 1, 1), false),
        (4, 200, 10.5,  10.0, 72.0,       DateTime(2024, 1, 1), false)],
        [:id, :id_anonim_episodio, :valor_valenf_rlpp, :braden_previo, :horas_valenf_previa, :fecha_valoracion, :error_umbral])
    sort!(df_valenf, [:id_anonim_episodio, :fecha_valoracion])
    df_valenf.posible_motivo = [String[] for _ in 1:nrow(df_valenf)]

    result = GiantFtr.motivo_protocolo(df_valenf)

    @test result[1, :posible_motivo] == String[]
    @test "Protocolo_2" in result[2, :posible_motivo]
    @test result[3, :posible_motivo] == String[]
    @test "Protocolo_3" in result[4, :posible_motivo]
end

@testset "motivo_protocolo - Transitividad a través de error_umbral" begin
    df_valenf = DataFrame([
        (1, 100, 15.5, 15.0, 168.0, DateTime(2024, 1, 1), true),
        (2, 100, 14.0, missing, missing, DateTime(2024, 1, 2), false)],
        [:id, :id_anonim_episodio, :valor_valenf_rlpp, :braden_previo, :horas_valenf_previa, :fecha_valoracion, :error_umbral])
    sort!(df_valenf, [:id_anonim_episodio, :fecha_valoracion])
    df_valenf.posible_motivo = [String[] for _ in 1:nrow(df_valenf)]

    result = GiantFtr.motivo_protocolo(df_valenf)

    @test result[1, :posible_motivo] == String[]
    @test "Protocolo_2" in result[2, :posible_motivo]
end

@testset "motivo_alta - Últimas 24h antes del alta" begin
    df_valenf = DataFrame([
        (1, 100, false, DateTime(2024, 1, 1)),
        (2, 100, false, DateTime(2024, 1, 4, 12)),
        (3, 100, false, DateTime(2024, 1, 5, 0))],
        [:id, :id_anonim_episodio, :error_umbral, :fecha_valoracion])
    sort!(df_valenf, [:id_anonim_episodio, :fecha_valoracion])
    df_valenf.posible_motivo = [String[] for _ in 1:nrow(df_valenf)]

    df_ftr = DataFrame([
        (100, DateTime(2023, 12, 31), DateTime(2024, 1, 5))],
        [:id_anonim_episodio, :fecha_ingreso, :fecha_alta])

    result = GiantFtr.motivo_alta(df_valenf, df_ftr)

    @test "Alta" in result[3, :posible_motivo]
    @test !("Alta" in result[2, :posible_motivo])
end