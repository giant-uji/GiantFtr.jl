function agrupar_FC(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico(df_ctes, df_episodios,
            FRECUENCIA_CARDIACA, #Tipo valor
            "fc", #Prefijo
            :id,
            :tipo_valor_pk,
            :valor_campo,
            :fecha_toma;
            rango_fisiologico = (40, 130), #Rango de valores compatibles con la vida
            #El tipado ES OBLIGATORIO porque Julia no transforma de Int a Float
            rangos_anomalos = Tuple{Float64,Float64}[(-Inf, 50),(100, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio,
        :fc_existe_valor,
        :fc_recuento,
        :fc_primero,
        :fc_ultimo,
        :fc_minimo,
        :fc_maximo,
        :fc_any_alterada,
        :fc_recuento_alterada,
        :fc_prop_alterada,
        :fc_delta_descenso,
        :fc_delta_aumento
    )
    
    return df_result
end

export agrupar_FC
registrar!(agrupar_FC;
    dependencias = [get_ftr_hosp_ctes, get_ftr_hosp],
    usa = [CONSTANTES, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_TAS(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agrupador_generico(df_ctes, df_episodios,
            TA_SISTOLICA, #Tipo valor
            "tas", #Prefijo
            :id,
            :tipo_valor_pk,
            :valor_campo,
            :fecha_toma;
            rango_fisiologico = (80, 180), #Rango de valores compatibles con la vida
            #El tipado ES OBLIGATORIO porque Julia no transforma de Int a Float
            rangos_anomalos = Tuple{Float64,Float64}[(-Inf, 90),(120, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio,
        :tas_existe_valor,
        :tas_recuento,
        :tas_primero,
        :tas_ultimo,
        :tas_minimo,
        :tas_maximo,
        :tas_any_alterada,
        :tas_recuento_alterada,
        :tas_prop_alterada,
        :tas_delta_descenso,
        :tas_delta_aumento
    )
    
    return df_result
end

export agrupar_TAS
registrar!(agrupar_TAS;
    dependencias = [get_ftr_hosp_ctes, get_ftr_hosp],
    usa = [CONSTANTES, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_TAD(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agrupador_generico(df_ctes, df_episodios,
            TA_DISTOLICA, #Tipo valor
            "tad", #Prefijo
            :id,
            :tipo_valor_pk,
            :valor_campo,
            :fecha_toma;
            rango_fisiologico = (40, 110), #Rango de valores compatibles con la vida
            rangos_anomalos = Tuple{Float64,Float64}[(-Inf, 60),(80, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio,
        :tad_existe_valor,
        :tad_recuento,
        :tad_primero,
        :tad_ultimo,
        :tad_minimo,
        :tad_maximo,
        :tad_any_alterada,
        :tad_recuento_alterada,
        :tad_prop_alterada,
        :tad_delta_descenso,
        :tad_delta_aumento
    )
    
    return df_result
end

export agrupar_TAD
registrar!(agrupar_TAD;
    dependencias = [get_ftr_hosp_ctes, get_ftr_hosp],
    usa = [CONSTANTES, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_temperatura(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agrupador_generico(df_ctes, df_episodios,
            TA_DISTOLICA, #Tipo valor
            "temp", #Prefijo
            :id,
            :tipo_valor_pk,
            :valor_campo,
            :fecha_toma;
            rango_fisiologico = (34, 40), #Rango de valores compatibles con la vida
            rangos_anomalos = Tuple{Float64,Float64}[(-Inf, 36),(37.5, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio,
        :temp_existe_valor,
        :temp_recuento,
        :temp_primero,
        :temp_ultimo,
        :temp_minimo,
        :temp_maximo,
        :temp_any_alterada,
        :temp_recuento_alterada,
        :temp_prop_alterada,
        :temp_delta_descenso,
        :temp_delta_aumento
    )
    
    return df_result
end

export agrupar_temperatura
registrar!(agrupar_temperatura;
    dependencias = [get_ftr_hosp_ctes, get_ftr_hosp],
    usa = [CONSTANTES, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_diuresis24h(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agrupador_generico(df_ctes, df_episodios,
            DIURESIS24H, #Tipo valor
            "diuresis24h",  #Prefijo
            :id,
            :tipo_valor_pk,
            :valor_campo,
            :fecha_toma)
            #SIN RANGO POR PETICION DE ENFERMERIA
            #(400, 3000), #Rango de valores compatibles con la vida
            #[(-Inf, 800),(2000, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio,
        :diuresis24h_existe_valor,
        :diuresis24h_recuento,
        :diuresis24h_primero,
        :diuresis24h_ultimo,
        :diuresis24h_minimo,
        :diuresis24h_maximo,
        :diuresis24h_any_alterada,
        :diuresis24h_recuento_alterada,
        :diuresis24h_prop_alterada,
        :diuresis24h_delta_descenso,
        :diuresis24h_delta_aumento
    )
    
    return df_result
end

export agrupar_diuresis24h
registrar!(agrupar_diuresis24h;
    dependencias = [get_ftr_hosp_ctes, get_ftr_hosp, diuresis24h],
    usa = [CONSTANTES, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_glucemia(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agrupador_generico(df_ctes, df_episodios,
            GLUCEMIAS, #Tipo valor
            "glucemia", #Prefijo
            :id,
            :tipo_valor_pk,
            :valor_campo,
            :fecha_toma;
            rangos_anomalos = Tuple{Float64,Float64}[(-Inf, 70),(140, Inf)]) #Rango de valores anomalos

    df_result = select(df_result, :id_anonim_episodio,
        :glucemia_existe_valor,
        :glucemia_recuento,
        :glucemia_primero,
        :glucemia_ultimo,
        :glucemia_minimo,
        :glucemia_maximo,
        :glucemia_any_alterada,
        :glucemia_recuento_alterada,
        :glucemia_prop_alterada,
        :glucemia_delta_descenso,
        :glucemia_delta_aumento
    )
    
    return df_result
end

export agrupar_glucemia
registrar!(agrupar_glucemia;
    dependencias = [get_ftr_hosp_ctes, get_ftr_hosp],
    usa = [CONSTANTES, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_shock_index(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agrupador_generico(df_ctes, df_episodios,
            SHOCK_INDEX, #Tipo valor
            "shock_index", #Prefijo
            :id,
            :tipo_valor_pk,
            :valor_campo,
            :fecha_toma) 

    df_result = select(df_result, :id_anonim_episodio,
        :shock_index_existe_valor,
        :shock_index_recuento,
        :shock_index_primero,
        :shock_index_ultimo,
        :shock_index_minimo,
        :shock_index_maximo,
        :shock_index_any_alterada,
        :shock_index_recuento_alterada,
        :shock_index_prop_alterada,
        :shock_index_delta_descenso,
        :shock_index_delta_aumento
    )
    
    return df_result
end

export agrupar_shock_index
registrar!(agrupar_shock_index;
    dependencias = [get_ftr_hosp_ctes, get_ftr_hosp, shock_index],
    usa = [CONSTANTES, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_ta_media(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agrupador_generico(df_ctes, df_episodios,
            TA_MEDIA, #Tipo valor
            "ta_media", #Prefijo
            :id,
            :tipo_valor_pk,
            :valor_campo,
            :fecha_toma)

    df_result = select(df_result, :id_anonim_episodio,
        :ta_media_existe_valor,
        :ta_media_recuento,
        :ta_media_primero,
        :ta_media_ultimo,
        :ta_media_minimo,
        :ta_media_maximo,
        :ta_media_any_alterada,
        :ta_media_recuento_alterada,
        :ta_media_prop_alterada,
        :ta_media_delta_descenso,
        :ta_media_delta_aumento
    )
    
    return df_result
end

export agrupar_ta_media
registrar!(agrupar_ta_media;
    dependencias = [get_ftr_hosp_ctes, get_ftr_hosp, ta_media],
    usa = [CONSTANTES, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)

function agrupar_m_shock_index(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame

    df_result = agrupador_generico(df_ctes, df_episodios,
            M_SHOCK_INDEX, #Tipo valor
            "m_shock_index",  #Prefijo
            :id,
            :tipo_valor_pk,
            :valor_campo,
            :fecha_toma)

    df_result = select(df_result, :id_anonim_episodio,
        :m_shock_index_existe_valor,
        :m_shock_index_recuento,
        :m_shock_index_primero,
        :m_shock_index_ultimo,
        :m_shock_index_minimo,
        :m_shock_index_maximo,
        :m_shock_index_any_alterada,
        :m_shock_index_recuento_alterada,
        :m_shock_index_prop_alterada,
        :m_shock_index_delta_descenso,
        :m_shock_index_delta_aumento
    )
    
    return df_result
end

export agrupar_m_shock_index
registrar!(agrupar_m_shock_index;
    dependencias = [get_ftr_hosp_ctes, get_ftr_hosp, m_shock_index],
    usa = [CONSTANTES, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)