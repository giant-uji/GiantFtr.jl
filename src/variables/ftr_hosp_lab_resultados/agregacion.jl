function agrupar_albumina(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            ALBUMINA_SERICA, #Tipo valor
            "albumina") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :albumina_existe_valor,
        :albumina_recuento,
        :albumina_primero,
        #:albumina_ultimo,
        :albumina_minimo,
        #:albumina_maximo,
        #:albumina_any_alterada,
        #:albumina_recuento_alterada,
        #:albumina_prop_alterada,
        :albumina_delta_descenso,
        #:albumina_delta_aumento
    )
    
    return df_result
end

export agrupar_albumina
registrar!(agrupar_albumina;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_lactato(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            LACTATO, #Tipo valor
            "lactato") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :lactato_existe_valor,
        :lactato_recuento,
        :lactato_primero,
        :lactato_ultimo,
        #:lactato_minimo,
        :lactato_maximo,
        #:lactato_any_alterada,
        #:lactato_recuento_alterada,
        #:lactato_prop_alterada,
        #:lactato_delta_descenso,
        :lactato_delta_aumento
    )
    
    return df_result
end

export agrupar_lactato
registrar!(agrupar_lactato;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_vsg(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            VSG, #Tipo valor
            "vsg") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :vsg_existe_valor,
        :vsg_recuento,
        :vsg_primero,
        #:vsg_ultimo,
        #:vsg_minimo,
        :vsg_maximo,
        #:vsg_any_alterada,
        #:vsg_recuento_alterada,
        #:vsg_prop_alterada,
        #:vsg_delta_descenso,
        #:vsg_delta_aumento
    )
    
    return df_result
end

export agrupar_vsg
registrar!(agrupar_vsg;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)

function agrupar_pcr(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            PCR_PROTEINA_C_REACTIVA, #Tipo valor
            "pcr") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :pcr_existe_valor,
        :pcr_recuento,
        :pcr_primero,
        :pcr_ultimo,
        #:pcr_minimo,
        :pcr_maximo,
        #:pcr_any_alterada,
        #:pcr_recuento_alterada,
        #:pcr_prop_alterada,
        #:pcr_delta_descenso,
        :pcr_delta_aumento
    )
    
    return df_result
end

export agrupar_pcr
registrar!(agrupar_pcr;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_procalcitonina(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            PROCALCITONINA, #Tipo valor
            "procalcitonina") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :procalcitonina_existe_valor,
        :procalcitonina_recuento,
        :procalcitonina_primero,
        #:procalcitonina_ultimo,
        #:procalcitonina_minimo,
        :procalcitonina_maximo,
        #:procalcitonina_any_alterada,
        #:procalcitonina_recuento_alterada,
        #:procalcitonina_prop_alterada,
        #:procalcitonina_delta_descenso,
        :procalcitonina_delta_aumento
    )
    
    return df_result
end

export agrupar_procalcitonina
registrar!(agrupar_procalcitonina;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_urea(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            BUN_NITROGENO_UREICO, #Tipo valor
            "urea") #Prefijo

df_result = select(df_result, :id_anonim_episodio,
        :urea_existe_valor,
        :urea_recuento,
        :urea_primero,
        #:urea_ultimo,
        #:urea_minimo,
        :urea_maximo,
        #:urea_any_alterada,
        #:urea_recuento_alterada,
        #:urea_prop_alterada,
        #:urea_delta_descenso,
        :urea_delta_aumento
    )
    
    return df_result
end

export agrupar_urea
registrar!(agrupar_urea;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_hemoglobina(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            HEMOGLOBINA, #Tipo valor
            "hemoglobina") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :hemoglobina_existe_valor,
        :hemoglobina_recuento,
        :hemoglobina_primero,
        :hemoglobina_ultimo,
        :hemoglobina_minimo,
        #:hemoglobina_maximo,
        #:hemoglobina_any_alterada,
        #:hemoglobina_recuento_alterada,
        #:hemoglobina_prop_alterada,
        :hemoglobina_delta_descenso,
        #:hemoglobina_delta_aumento
    )
    
    return df_result
end

export agrupar_hemoglobina
registrar!(agrupar_hemoglobina;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_leucocitos(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            LEUCOCITOS, #Tipo valor
            "leucocitos"; #Prefijo
            #El tipado ES OBLIGATORIO porque Julia no transforma de Int a Float
            rangos_anomalos = Tuple{Float64,Float64}[(-Inf, 4.8),(11, Inf)]) #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :leucocitos_existe_valor,
        :leucocitos_recuento,
        :leucocitos_primero,
        #:leucocitos_ultimo,
        :leucocitos_minimo,
        :leucocitos_maximo,
        :leucocitos_any_alterada,
        #:leucocitos_recuento_alterada,
        #:leucocitos_prop_alterada,
        #:leucocitos_delta_descenso,
        #:leucocitos_delta_aumento
    )
    
    return df_result
end

export agrupar_leucocitos
registrar!(agrupar_leucocitos;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_plaquetas(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            PLAQUETAS, #Tipo valor
            "plaquetas") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :plaquetas_existe_valor,
        :plaquetas_recuento,
        :plaquetas_primero,
        #:plaquetas_ultimo,
        :plaquetas_minimo,
        #:plaquetas_maximo,
        #:plaquetas_any_alterada,
        #:plaquetas_recuento_alterada,
        #:plaquetas_prop_alterada,
        :plaquetas_delta_descenso,
        #:plaquetas_delta_aumento
    )
    
    return df_result
end

export agrupar_plaquetas
registrar!(agrupar_plaquetas;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_got(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            TRANSAMINASAS_GOT, #Tipo valor
            "got") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :got_existe_valor,
        :got_recuento,
        :got_primero,
        #:got_ultimo,
        #:got_minimo,
        :got_maximo,
        #:got_any_alterada,
        #:got_recuento_alterada,
        #:got_prop_alterada,
        #:got_delta_descenso,
        :got_delta_aumento
    )
    
    return df_result
end

export agrupar_got
registrar!(agrupar_got;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_gpt(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            TRANSAMINASAS_GPT, #Tipo valor
            "gpt") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :gpt_existe_valor,
        :gpt_recuento,
        :gpt_primero,
        #:gpt_ultimo,
        #:gpt_minimo,
        :gpt_maximo,
        #:gpt_any_alterada,
        #:gpt_recuento_alterada,
        #:gpt_prop_alterada,
        #:gpt_delta_descenso,
        :gpt_delta_aumento
    )
    
    return df_result
end

export agrupar_gpt
registrar!(agrupar_gpt;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_troponina(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            TROPONINA, #Tipo valor
            "troponina") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :troponina_existe_valor,
        :troponina_recuento,
        :troponina_primero,
        #:troponina_ultimo,
        #:troponina_minimo,
        :troponina_maximo,
        #:troponina_any_alterada,
        #:troponina_recuento_alterada,
        #:troponina_prop_alterada,
        #:troponina_delta_descenso,
        #:troponina_delta_aumento
    )
    
    return df_result
end

export agrupar_troponina
registrar!(agrupar_troponina;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_probnp(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            BNP_NT_PROBNP, #Tipo valor
            "probnp") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :probnp_existe_valor,
        :probnp_recuento,
        :probnp_primero,
        #:probnp_ultimo,
        #:probnp_minimo,
        :probnp_maximo,
        #:probnp_any_alterada,
        #:probnp_recuento_alterada,
        #:probnp_prop_alterada,
        #:probnp_delta_descenso,
        #:probnp_delta_aumento
    )
    
    return df_result
end

export agrupar_probnp
registrar!(agrupar_probnp;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_inr(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            INR, #Tipo valor
            "inr") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :inr_existe_valor,
        :inr_recuento,
        :inr_primero,
        #:inr_ultimo,
        #:inr_minimo,
        :inr_maximo,
        #:inr_any_alterada,
        #:inr_recuento_alterada,
        #:inr_prop_alterada,
        #:inr_delta_descenso,
        :inr_delta_aumento
    )
    
    return df_result
end

export agrupar_inr
registrar!(agrupar_inr;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)


function agrupar_protrombina(df_ctes::DataFrame, df_episodios::DataFrame) :: DataFrame
    
    df_result = agrupador_generico_lab_r(df_ctes, df_episodios,
            TP_TIEMPO_PROTROMBINA, #Tipo valor
            "tp") #Prefijo

    df_result = select(df_result, :id_anonim_episodio,
        :tp_existe_valor,
        :tp_recuento,
        :tp_primero,
        #:tp_ultimo,
        #:tp_minimo,
        :tp_maximo,
        #:tp_any_alterada,
        #:tp_recuento_alterada,
        #:tp_prop_alterada,
        #:tp_delta_descenso,
        :tp_delta_aumento
    )
    
    return df_result
end

export agrupar_protrombina
registrar!(agrupar_protrombina;
    dependencias = [get_ftr_hosp_lab_resultados, get_ftr_hosp],
    usa = [LAB_RESULTADOS, EPISODIOS],
    extiende = (EPISODIOS, :id_anonim_episodio)
)