using DataFrames

include("conexion_bbdd.jl")

export categoria_barthel
export hay_exitus_episodio

const DEPENDENCIA_LEVE = 1
const DEPENDENCIA_MODERADA = 2
const DEPENDENCIA_SEVERA = 3

function categoria_barthel(id_anonim_episodio::Int64)::Int64
    resultado = DEPENDENCIA_LEVE
    df =  get_ftr_hosp_valenf()
    valor_barthel = df[df.id_anonim_episodio .== id_anonim_episodio, :valor_barthel][1]
    if valor_barthel >= 0 && valor_barthel <= 34.101630
        resultado = DEPENDENCIA_SEVERA
    elseif valor_barthel >= 34.101631 && valor_barthel <= 78.270630
        resultado = DEPENDENCIA_MODERADA
    end
end

function hay_exitus_episodio(tabla::DataFrame)::DataFrame
    resultado = DataFrame()
    # Se copia tal cual la columna de id_anonim_episodio
    resultado.id_anonim_episodio = tabla.id_anonim_episodio
    # Se escribe 0 (falso) o 1 (verdadero) según si ha habido exitus o no
    resultado.hay_exitus = Int.(tabla.motivo_alta_pk .== 4)
    return resultado
end
