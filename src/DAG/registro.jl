#Nodo tiene que estar ANTES de REGISTRO
struct Nodo
    funcion::Function                               #Funcion que se registra
    usa::Union{Nothing,Vector{Tabla}}               #Dataframes del contexto que se pasan como parámetros
    dependencias::Vector{Function}                  #Listado de funciones de las que se depende
    produce::Union{Nothing,Tabla}                   #La salida es un dataframe
    anyade::Union{Nothing,Tabla}                    #Anyade filas a un dataframe
    extiende::Union{Nothing,Tuple{Tabla,Symbol}}    #(dataframe, PK) La salida extiende un dataframe left join PK
end

#Constante donde se resgistran TODAS las funciones y dependencias
const REGISTRO = Dict{Symbol,Nodo}()


export registrar!

function registrar!(
    funcion::Function;
    usa::Union{Nothing,Vector{Tabla}}=nothing,
    dependencias::AbstractVector{<:Function}=Function[],
    produce::Union{Nothing,Tabla}=nothing,
    anyade::Union{Nothing,Tabla}=nothing,
    extiende::Union{Nothing,Tuple{Tabla,Symbol}}=nothing)

    nombre = Symbol(nameof(funcion))

    salidas = count(!isnothing, (produce, extiende, anyade))

    if salidas == 0
        println("Falta la salida de $nombre, no registrada")
        return
    elseif salidas > 1
        println("La función $nombre solo puede definir una salida: produce, extiende o anyade.")
    end

    if haskey(REGISTRO, nombre)
        println("Ya se ha registrado la función $nombre, no registrada")
        return
    end

    REGISTRO[nombre] = Nodo(
        funcion,
        usa,
        copy(dependencias),
        produce,
        anyade,
        extiende
    )

    #Si no se pone esto Julia devuelve el resultado de lo ultimo ejecutado
    return
end