#Para la definicion de las funciones
const Contexto = Dict{Symbol,DataFrame}
const ContextoOpcional = Union{Nothing,Contexto}    #Permite no pasar contexto

#Nodo tiene que estar ANTES de REGISTRO
struct Nodo
    funcion::Function           #Funcion que se registra
    dependencias::Vector{Function}  #Listado de funciones de las que se depende
    produce::Union{Nothing,Symbol}  #La salida es un dataframe
    extiende::Union{Nothing,Tuple{Symbol,Symbol}}   #(dataframe, PK) La salida extiende un dataframe left join PK
end

#Constante donde se resgistran TODAS las funciones y dependencias
const REGISTRO = Dict{Symbol,Nodo}()


export registrar!

function registrar!(
    funcion::Function;
    dependencias::Vector{Function}=Function[],
    produce::Union{Nothing,Symbol}=nothing,
    extiende::Union{Nothing,Tuple{Symbol,Symbol}}=nothing)

    nombre = Symbol(nameof(funcion))

    if isnothing(produce) && isnothing(extiende)
        println("Falta la salida de $nombre, no registrada")
        return
    end

    if !isnothing(produce) && !isnothing(extiende)
        println("La función $nombre produce y extiende, no registrada")
        return
    end

    if haskey(REGISTRO, nombre)
        println("Ya se ha registrado la función $nombre, no registrada")
        return
    end

    REGISTRO[nombre] = Nodo(
        funcion,
        copy(dependencias),
        produce,
        extiende
    )

    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end


export DAG

#Directed Acyclic Graph (Grafo dirigido acíclico)
#Es un motor de ejecucion de funciones que tiene en cuenta las dependencias
mutable struct DAG
    contexto::Dict{Symbol,DataFrame}
    ejecutadas::Set{Function}

    function DAG()

        if DEBUG
            detectar_ciclos!()
        end

        new(
            Dict{Symbol,DataFrame}(),
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

    empty!(dag.contexto)
    empty!(dag.ejecutadas)

    for f in funciones
        VERBOSE && println("Intenta ejecutar: $(nameof(f))")
        resolver!(dag, f)
    end

    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end

#Funcion recursiva que se encarga de resolver las dependencias
function resolver!(dag::DAG, funcion::Function)

    if funcion in dag.ejecutadas
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
    resultado = nodo.funcion(dag.contexto)
    VERBOSE && println("Ejecutando: $(nameof(funcion))")

    if !isnothing(nodo.produce)
        dag.contexto[nodo.produce] = resultado
    else
        tabla, pk = nodo.extiende

        leftjoin!(
            dag.contexto[tabla],
            resultado;
            on=pk
        )

    end

    push!(dag.ejecutadas, funcion)

    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end

#Funcion para TESTING detecta cilos de dependencias entre funciones
#Codigo implementado por IA
#Es un algoritmo de busqueda de bucles en grafos dirigidos utilizando busqueda en profundidad desde cada nodo
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

    pop!(camino)
    delete!(visitando, funcion)
    push!(visitadas, funcion)

    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end