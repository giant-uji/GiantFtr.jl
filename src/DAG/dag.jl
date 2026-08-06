export DAG

#Directed Acyclic Graph (Grafo dirigido acíclico)
#Es un motor de ejecucion de funciones que tiene en cuenta las dependencias
mutable struct DAG
    contexto::Dict{Tabla,DataFrame}
    ejecutadas::Set{Function}

    function DAG()

        if DEBUG
            detectar_ciclos!()
        end

        new(
            Dict{Tabla,DataFrame}(),
            Set{Function}()
        )
    end
end

#Funcion recursiva llama a las dependencias ANTES de ejecutar el codigo
#Utiliza "contexto" para almacenar cache (Memoization)
export ejecutar!

#Llamada con una sola funcion
function ejecutar!(dag::DAG, funcion::Function)
    ejecutar!(dag, [funcion])

    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end

#Llamada con lista de funciones
function ejecutar!(dag::DAG, funciones::AbstractVector{<:Function})

    VACIAR_DAG_ANTES_EJECUTAR && empty!(dag.contexto)
    VACIAR_DAG_ANTES_EJECUTAR && empty!(dag.ejecutadas)

    for f in funciones
        VERBOSE && println("Intenta ejecutar: $(nameof(f))")
        resolver!(dag, f)
    end

    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end

#Funcion recursiva que se encarga de resolver las dependencias
function resolver!(dag::DAG, funcion::Function)

    if funcion in dag.ejecutadas    #MEMOIZATION
        VERBOSE && println("Cache: $(nameof(funcion))")
        return
    end

    nodo = REGISTRO[Symbol(nameof(funcion))]

    #Resolver dependencias de forma RECURSIVA
    for dep in nodo.dependencias
        VERBOSE && println("Dependencia: $(nameof(funcion))")
        resolver!(dag, dep)
    end

    #Ejecuta la funcion
    ejecutar_funcion(dag, funcion)
    push!(dag.ejecutadas, funcion)

    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end

#Se encarga de ejecutar la funcion gestionando todo el contexto
function ejecutar_funcion(dag::DAG, funcion::Function)
    VERBOSE && println("Ejecutando: $(nameof(funcion))")

    nodo = REGISTRO[Symbol(nameof(funcion))]

    #Almacena informacion sobre los DataFrame ANTES de ejecutar
    if DEBUG && !isnothing(nodo.usa) && isnothing(nodo.anyade)
        estado = [
            (
                nrow(dag.contexto[tabla]),
                names(dag.contexto[tabla])
            )
            for tabla in nodo.usa
        ]
    end

    if isnothing(nodo.usa)
        resultado = nodo.funcion()
    else
        parametros = [dag.contexto[x] for x in nodo.usa]
        resultado = nodo.funcion(parametros...)
    end

    #Comprueba que los DataFrame NO se han modificado al ejecutar
    if DEBUG && !isnothing(nodo.usa) && isnothing(nodo.anyade)
        for (i, tabla) in enumerate(nodo.usa)

            filas, columnas = estado[i]

            if nrow(dag.contexto[tabla]) != filas
                error("La función $(nameof(funcion)) ha modificado el número de filas de $(tabla)")
            end

            if names(dag.contexto[tabla]) != columnas
                error("La función $(nameof(funcion)) ha modificado las columnas de $(tabla)")
            end
        end
    end

    if !isnothing(nodo.produce)
        dag.contexto[nodo.produce] = resultado
    elseif !isnothing(nodo.extiende)
        tabla, pk = nodo.extiende

        leftjoin!(
            dag.contexto[tabla],
            resultado;
            on=pk
        )
    else    #Anyade
        append!(
        dag.contexto[nodo.anyade],
        resultado
        )
    end
    
    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end

#Funcion para TESTING detecta ciclos de dependencias entre funciones
#Codigo implementado por IA
#Es un algoritmo de busqueda de ciclos en grafos dirigidos utilizando busqueda en profundidad desde cada nodo
function detectar_ciclos!()
    VERBOSE && println("Detectando ciclos...")

    visitadas = Set{Function}()
    visitando = Set{Function}()
    camino = Function[]

    for nodo in values(REGISTRO)
        detectar_ciclos!(
            nodo.funcion,
            visitadas,
            visitando,
            camino
        )
    end

    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end

function detectar_ciclos!(
    funcion::Function,
    visitadas::Set{Function},
    visitando::Set{Function},
    camino::Vector{Function})

    if funcion in visitadas
        return
    end

    if funcion in visitando

        inicio = findfirst(==(funcion), camino)

        ciclo = join(string.(nameof.(camino[inicio:end])), " -> ")
        error("Dependencia cíclica detectada: $ciclo -> $(nameof(funcion))")

        return
    end

    push!(visitando, funcion)
    push!(camino, funcion)

    nombre = Symbol(nameof(funcion))

    #Detecta cuando una dependencia no ha sido registrada
    if !haskey(REGISTRO, nombre)
        error("La funcion $nombre no no esta registrada")
    end

    nodo = REGISTRO[nombre]

    for dep in nodo.dependencias
        detectar_ciclos!(dep, visitadas, visitando, camino)
    end

    pop!(camino)
    delete!(visitando, funcion)
    push!(visitadas, funcion)

    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end