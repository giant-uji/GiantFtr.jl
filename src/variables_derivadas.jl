using DataFrames

include("utilidades.jl")

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

#Carlos: Todas las agr_ son copiar y pegar. Esta hecho asi por OPTIMIZACION
export agr_frecuencia

function agr_frecuencia(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = GiantFtr.agr_generic(df_ctes, df_episodios,
            FRECUENCIA_CARDIACA, #Tipo valor
            "fc", #Prefijo
            (40, 130), #Rango de valores compatibles con la vida
            [(-Inf, 50),(100, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio, :fc_existe_valor, :fc_recuento, :fc_primero, :fc_ultimo, :fc_minimo, :fc_maximo,	:fc_any_alterada, :fc_recuento_alterada, :fc_prop_alterada, :fc_delta_descenso, :fc_delta_aumento)
    
    return df_result
end

export agr_TAS

function agr_TAS(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agr_generic(df_ctes, df_episodios,
            GiantFtr.TA_SISTOLICA, #Tipo valor
            "tas", #Prefijo
            (80, 180), #Rango de valores compatibles con la vida
            [(-Inf, 90),(120, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio, :tas_existe_valor, :tas_recuento, :tas_primero, :tas_ultimo, :tas_minimo, :tas_maximo,	:tas_any_alterada, :tas_recuento_alterada, :tas_prop_alterada, :tas_delta_descenso, :tas_delta_aumento)
    
    return df_result
end

export agr_TAD

function agr_TAD(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agr_generic(df_ctes, df_episodios,
            GiantFtr.TA_DISTOLICA, #Tipo valor
            "tas", #Prefijo
            (40, 110), #Rango de valores compatibles con la vida
            [(-Inf, 60),(80, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio, :tad_existe_valor, :tad_recuento, :tad_primero, :tad_ultimo, :tad_minimo, :tad_maximo,	:tad_any_alterada, :tad_recuento_alterada, :tad_prop_alterada, :tad_delta_descenso, :tad_delta_aumento)
    
    return df_result
end

export agr_temperatura

function agr_temperatura(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agr_generic(df_ctes, df_episodios,
            GiantFtr.TA_DISTOLICA, #Tipo valor
            "temp", #Prefijo
            (34, 40), #Rango de valores compatibles con la vida
            [(-Inf, 36),(37.5, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio, :temp_existe_valor, :temp_recuento, :temp_primero, :temp_ultimo, :temp_minimo, :temp_maximo,	:temp_any_alterada, :temp_recuento_alterada, :temp_prop_alterada, :temp_delta_descenso, :temp_delta_aumento)
    
    return df_result
end

export agr_glucemia

function agr_glucemia(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agr_generic(df_ctes, df_episodios,
            GiantFtr.GLUCEMIAS, #Tipo valor
            "glucemia", #Prefijo
            nothing, #Rango de valores compatibles con la vida
            [(-Inf, 70),(140, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio, :glucemia_existe_valor, :glucemia_recuento, :glucemia_primero, :glucemia_ultimo, :glucemia_minimo, :glucemia_maximo,	:glucemia_any_alterada, :glucemia_recuento_alterada, :glucemia_prop_alterada, :glucemia_delta_descenso, :glucemia_delta_aumento)
    
    return df_result
end

