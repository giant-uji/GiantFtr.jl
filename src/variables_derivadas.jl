using DataFrames

include("conexion_bbdd.jl")

export hay_exitus_episodio, hay_exitus_paciente

function hay_exitus_episodio(tabla::DataFrame)::DataFrame
    resultado = DataFrame()
    # Se copia tal cual la columna de id_anonim_episodio
    resultado.id_anonim_episodio = tabla.id_anonim_episodio
    # Se escribe 0 (falso) o 1 (verdadero) según si ha habido exitus o no
    resultado.hay_exitus = Int.(tabla.motivo_alta_pk .== 4)
    return resultado
end


function hay_exitus_paciente(df_ftr::DataFrame) :: DataFrame

	df_result = DataFrame(
		id_anonim_episodio = df_ftr.id_anonim_episodio,
		#El . permite que se haga el [!e1, !e2]
		hay_exitus_paciente = .!ismissing.(df_ftr.fecha_exitus)
	)

	return df_result
end