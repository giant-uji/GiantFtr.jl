using Test
using DataFrames
using GiantFtr
using GiantFtr: REGISTRO, DEBUG, VACIAR_DAG_ANTES_EJECUTAR


"""
Limpia el registro global entre testsets.
"""
limpiar_registro!() = empty!(REGISTRO)

# Silencia el println para no ensuciar la salida de test.
macro silenciar(ex)
    quote
        redirect_stdout(devnull) do
            $(esc(ex))
        end
    end
end

# ═══════════════════════════════════════════════════════════════════════
# 1. REGISTRO DE FUNCIONES
# ═══════════════════════════════════════════════════════════════════════
@testset "registrar!" begin

    @testset "registra correctamente con una única salida" begin
        limpiar_registro!()
        f() = DataFrame(id=[1])
        registrar!(f; produce=EPISODIOS)
        @test haskey(REGISTRO, :f)
        @test REGISTRO[:f].produce == EPISODIOS
    end

    @testset "no registra si no define ninguna salida" begin
        limpiar_registro!()
        sin_salida() = DataFrame()
        @silenciar registrar!(sin_salida)
        @test !haskey(REGISTRO, :sin_salida)
    end

    @testset "no permite registrar el mismo nombre dos veces" begin
        limpiar_registro!()
        dup() = DataFrame(id=[1])
        registrar!(dup; produce=EPISODIOS)
        original = REGISTRO[:dup]
        @silenciar registrar!(dup; produce=CODIFICACION)  # intento de pisar el registro
        @test REGISTRO[:dup] === original  # no se sobrescribió
    end

    @testset "salidas múltiples (produce + extiende) NO debería registrar el nodo" begin
        limpiar_registro!()
        ambigua() = DataFrame(id=[1])
        @silenciar registrar!(ambigua; produce=EPISODIOS, extiende=(TRASLADOS, :id))
        @test !haskey(REGISTRO, :ambigua)
    end

    @testset "dependencias se copian, no se referencian" begin
        limpiar_registro!()
        dep() = DataFrame(id=[1])
        principal() = DataFrame(id=[1])
        registrar!(dep; produce=EPISODIOS)
        lista_original = Function[dep]
        registrar!(principal; produce=CODIFICACION, dependencias=lista_original)
        push!(lista_original, dep)  # mutar la lista original tras registrar
        @test length(REGISTRO[:principal].dependencias) == 1  # no debe verse afectado
    end
end

# ═══════════════════════════════════════════════════════════════════════
# 2. RESOLUCIÓN DE DEPENDENCIAS Y EJECUCIÓN
# ═══════════════════════════════════════════════════════════════════════
@testset "resolver! / ejecutar!" begin

    @testset "las dependencias se ejecutan antes que la función que depende de ellas" begin
        limpiar_registro!()
        orden = Symbol[]
        paso_a() = (push!(orden, :a); DataFrame(id=[1]))
        paso_b() = (push!(orden, :b); DataFrame(id=[2]))
        registrar!(paso_a; produce=EPISODIOS)
        registrar!(paso_b; produce=CODIFICACION, dependencias=[paso_a])

        dag = @silenciar(DAG())
        @silenciar ejecutar!(dag, paso_b)

        @test orden == [:a, :b]
    end

    @testset "una dependencia compartida por dos funciones se ejecuta una sola vez" begin
        limpiar_registro!()
        contador = Ref(0)
        comun() = (contador[] += 1; DataFrame(id=[1]))
        rama_1() = DataFrame(id=[10])
        rama_2() = DataFrame(id=[20])
        registrar!(comun; produce=EPISODIOS)
        registrar!(rama_1; produce=CODIFICACION, dependencias=[comun])
        registrar!(rama_2; produce=VALENF, dependencias=[comun])

        dag = @silenciar(DAG())
        @silenciar ejecutar!(dag, [rama_1, rama_2])

        @test contador[] == 1  # memoization dentro de la misma llamada a ejecutar!
    end

    @testset "memoization entre llamadas sucesivas a ejecutar! (mismo DAG)" begin
        limpiar_registro!()
        contador = Ref(0)
        contar_ejec() = (contador[] += 1; DataFrame(id=[1]))
        registrar!(contar_ejec; produce=EPISODIOS)

        dag = @silenciar(DAG())
        @silenciar ejecutar!(dag, contar_ejec)
        @silenciar ejecutar!(dag, contar_ejec)

        # El resultado depende de VACIAR_DAG_ANTES_EJECUTAR: si está activo,
        # cada llamada limpia dag.ejecutadas y se re-ejecuta; si no, el cache
        # persiste entre llamadas. Se comprueba el valor real de la const
        # en vez de asumir uno, para que el test sea válido en ambos casos.
        if VACIAR_DAG_ANTES_EJECUTAR
            @test contador[] == 2
        else
            @test contador[] == 1
        end
    end

    @testset "dependencia no registrada lanza un error claro" begin
        limpiar_registro!()
        huerfana() = DataFrame(id=[1])
        # 'huerfana' nunca se registra, pero se declara como dependencia
        principal() = DataFrame(id=[1])
        registrar!(principal; produce=EPISODIOS, dependencias=[huerfana])

        if DEBUG
            # Con DEBUG=true, detectar_ciclos! recorre el grafo completo ya
            # en el constructor y encuentra la dependencia no registrada
            # ANTES de que se pueda ejecutar nada. El error sale aquí, no
            # en ejecutar!, y es un ErrorException (viene de error()), no
            # un KeyError.
            @test_throws ErrorException @silenciar(DAG())
        else
            # Sin DEBUG no hay detectar_ciclos!, así que el registro
            # "inválido" pasa sin más. El fallo aparece más tarde, dentro
            # de resolver!, como KeyError al buscar :huerfana en REGISTRO.
            dag = @silenciar(DAG())
            @test_throws KeyError @silenciar(ejecutar!(dag, principal))
        end
    end
end

# ═══════════════════════════════════════════════════════════════════════
# 3. GESTIÓN DE CONTEXTO: produce / anyade / extiende
# ═══════════════════════════════════════════════════════════════════════
@testset "gestión de contexto" begin

    @testset "produce crea la tabla en el contexto" begin
        limpiar_registro!()
        prod() = DataFrame(id=[1, 2, 3], edad=[30, 40, 50])
        registrar!(prod; produce=EPISODIOS)

        dag = @silenciar(DAG())
        @silenciar ejecutar!(dag, prod)

        @test nrow(dag.contexto[EPISODIOS]) == 3
        @test names(dag.contexto[EPISODIOS]) == ["id", "edad"]
    end

    @testset "anyade agrega filas a una tabla ya existente" begin
        limpiar_registro!()
        prod() = DataFrame(id=[1, 2])
        anyade_filas() = DataFrame(id=[3])
        registrar!(prod; produce=EPISODIOS)
        registrar!(anyade_filas; anyade=EPISODIOS, dependencias=[prod])

        dag = @silenciar(DAG())
        @silenciar ejecutar!(dag, anyade_filas)

        @test nrow(dag.contexto[EPISODIOS]) == 3
    end

    @testset "anyade sobre una tabla que no existe aún lanza KeyError" begin
        # Decision de disenyo: No hay comprobación automática,
        # es responsabilidad del desarrollador declarar bien las dependencias.
        # Este test confirma que en el caso de fallo lanza error (no es silencioso)
        limpiar_registro!()
        anyade_huerfano() = DataFrame(id=[1])
        registrar!(anyade_huerfano; anyade=LABORATORIO)

        dag = @silenciar(DAG())
        @test_throws KeyError @silenciar(ejecutar!(dag, anyade_huerfano))
    end

    @testset "extiende añade columnas vía leftjoin! preservando el número de filas" begin
        limpiar_registro!()
        prod() = DataFrame(id_episodio=[1, 2, 3], destino=["A", "B", "C"])
        extiende_f(df) = DataFrame(id_episodio=[1, 2, 3], duracion=[5, 10, 15])
        registrar!(prod; produce=TRASLADOS)
        registrar!(extiende_f; usa=[TRASLADOS], dependencias=[prod],
                    extiende=(TRASLADOS, :id_episodio))

        dag = @silenciar(DAG())
        @silenciar ejecutar!(dag, extiende_f)

        @test nrow(dag.contexto[TRASLADOS]) == 3
        @test "duracion" in names(dag.contexto[TRASLADOS])
    end
end

# ═══════════════════════════════════════════════════════════════════════
# 4. CHEQUEOS DE INMUTABILIDAD Y CICLOS — SOLO VÁLIDOS CON DEBUG = true
# ═══════════════════════════════════════════════════════════════════════
if DEBUG
    @testset "inmutabilidad de tablas usadas como entrada (requiere DEBUG=true)" begin

        @testset "modificar el número de filas de una tabla de entrada lanza error" begin
            limpiar_registro!()
            prod() = DataFrame(id=[1, 2])
            borra_filas(df) = (delete!(df, 1); DataFrame(x=[1]))
            registrar!(prod; produce=VALENF)
            registrar!(borra_filas; usa=[VALENF], dependencias=[prod], produce=CODIFICACION)

            dag = @silenciar(DAG())
            @test_throws ErrorException @silenciar(ejecutar!(dag, borra_filas))
        end

        @testset "modificar las columnas de una tabla de entrada lanza error" begin
            limpiar_registro!()
            prod() = DataFrame(id=[1, 2])
            renombra_cols(df) = (rename!(df, :id => :id_renombrado); DataFrame(x=[1]))
            registrar!(prod; produce=VALENF)
            registrar!(renombra_cols; usa=[VALENF], dependencias=[prod], produce=CODIFICACION)

            dag = @silenciar(DAG())
            @test_throws ErrorException @silenciar(ejecutar!(dag, renombra_cols))
        end

        @testset "una función que no toca su tabla de entrada no lanza error" begin
            limpiar_registro!()
            prod() = DataFrame(id=[1, 2])
            lee_sin_mutar(df) = DataFrame(total=[nrow(df)])
            registrar!(prod; produce=VALENF)
            registrar!(lee_sin_mutar; usa=[VALENF], dependencias=[prod], produce=CODIFICACION)

            dag = @silenciar(DAG())
            @silenciar ejecutar!(dag, lee_sin_mutar)  # no debe lanzar
            @test dag.contexto[CODIFICACION].total == [2]
        end
    end

    @testset "detección de ciclos (requiere DEBUG=true)" begin

        @testset "un grafo sin ciclos no lanza error al crear el DAG" begin
            limpiar_registro!()
            a() = DataFrame(id=[1])
            b() = DataFrame(id=[1])
            registrar!(a; produce=EPISODIOS)
            registrar!(b; produce=CODIFICACION, dependencias=[a])

            @test @silenciar(DAG()) isa Any  # no debe lanzar
        end

        @testset "un ciclo directo (A depende de B, B depende de A) lanza error" begin
            limpiar_registro!()
            ciclo_a() = DataFrame(id=[1])
            ciclo_b() = DataFrame(id=[1])
            registrar!(ciclo_a; produce=EPISODIOS, dependencias=[ciclo_b])
            registrar!(ciclo_b; produce=CODIFICACION, dependencias=[ciclo_a])

            @test_throws ErrorException @silenciar(DAG())
        end

        @testset "una dependencia nunca registrada lanza error específico al crear el DAG" begin
            limpiar_registro!()
            nunca_registrada() = DataFrame(id=[1])
            principal() = DataFrame(id=[1])
            registrar!(principal; produce=EPISODIOS, dependencias=[nunca_registrada])

            @test_throws ErrorException @silenciar(DAG())
        end
    end
else
    @warn "DEBUG = false: se omiten los tests de inmutabilidad y detección de ciclos. " *
          "Ejecuta este archivo con DEBUG = true para cubrir esa parte del código."
end