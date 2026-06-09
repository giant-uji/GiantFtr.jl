using DataFrames

include("conexion_bbdd.jl")

function hay_exitus_episodio(tabla::DataFrame)::DataFrame
    resultado = DataFrame()
    # Se copia tal cual la columna de id_anonim_episodio
    resultado.id_anonim_episodio = tabla.id_anonim_episodio
    # Se escribe 0 (falso) o 1 (verdadero) según si ha habido exitus o no
    resultado.hay_exitus = Int.(tabla.motivo_alta_pk .== 4)
    return resultado
end
