function get_ftr_hosp_lab_resultados_DEFAULT(contexto::ContextoOpcional)::DataFrame
    if ANALITICAS_CON_URGENCIAS
        VERBOSE && println("get_ftr_hosp_lab_resultados con URGENCIAS")
        return get_ftr_hosp_lab_resultados_ALL(contexto)
    end

    return get_ftr_hosp_lab_resultados(contexto)
end

export get_ftr_hosp_lab_resultados_DEFAULT
registrar!(get_ftr_hosp_lab_resultados_DEFAULT;produce = :lab_resultados)


function get_ftr_hosp_lab_resultados_ALL(contexto::ContextoOpcional)::DataFrame
    return append!(get_ftr_hosp_lab_resultados(contexto), get_ftr_hosp_lab_URG_resultados(contexto))
end

export get_ftr_hosp_lab_resultados_ALL


function get_ftr_hosp_lab_resultados_RAW(contexto::ContextoOpcional)::DataFrame
    return get_table("ftr_hosp_lab_resultados")
end

export get_ftr_hosp_lab_resultados_RAW


function get_ftr_hosp_lab_resultados(contexto::ContextoOpcional)::DataFrame
    df_lab_resultados = get_table("ftr_hosp_lab_resultados")

    #0- Añadir id_anonim_episodio
    df_lab = get_table("ftr_hosp_lab")
    select!(df_lab, [:id_anonim_episodio, :id_solicitud])
    df_lab_resultados = leftjoin(df_lab_resultados, df_lab, on=:id_solicitud)

    #Reordenamos columnas
    select!(df_lab_resultados, [:id, :id_solicitud, :id_anonim_episodio, :fecha_resultados, :fecha_validacion, :parametro_pk, :valor_parametro])

    #1- Filtrado de columnas
    #2- Renombrado de columnas
    #3- Convertir tipos de columnas

    #Todas las fechas con el mismo formato
    #Por defecto las cargaba como String
    transform!(df_lab_resultados, [:fecha_resultados, :fecha_validacion] .=> ByRow(x -> ismissing(x) ? missing : DateTime(x)), renamecols=false)

    #Tipos categoricos
    #Ayuda a optimizar cuando hay muchos tipos de datos
    transform!(df_lab_resultados, [:parametro_pk] .=> categorical, renamecols=false)

    return df_lab_resultados
end

export get_ftr_hosp_lab_resultados


function get_ftr_hosp_lab_URG_resultados_RAW(contexto::ContextoOpcional)::DataFrame
    return get_table("ftr_hosp_lab_urg_resultados")
end

export get_ftr_hosp_lab_URG_resultados_RAW


function get_ftr_hosp_lab_URG_resultados(contexto::ContextoOpcional)::DataFrame
    df_lab_resultados = get_table("ftr_hosp_lab_urg_resultados")

    #0- Añadir id_anonim_episodio
    df_lab = get_ftr_hosp_lab_URG(contexto) #Necesita transformar urgencias
    select!(df_lab, [:id_anonim_episodio, :id_solicitud])

    #id_solicitud_urg -> id_solicitud: Consistencia con ftr_hosp_lab_resultados
    rename!(df_lab_resultados, :id_solicitud_urg => :id_solicitud)

    df_lab_resultados = leftjoin(df_lab_resultados, df_lab, on=:id_solicitud)

    #Reordenamos columnas
    select!(df_lab_resultados, [:id, :id_solicitud, :id_anonim_episodio, :fecha_resultados, :fecha_validacion, :parametro_pk, :valor_parametro])

    #1- Filtrado de columnas
    #2- Renombrado de columnas
    #3- Convertir tipos de columnas

    #Todas las fechas con el mismo formato
    #Por defecto las cargaba como String
    transform!(df_lab_resultados, [:fecha_resultados, :fecha_validacion] .=> ByRow(x -> ismissing(x) ? missing : DateTime(x)), renamecols=false)

    #Tipos categoricos
    #Ayuda a optimizar cuando hay muchos tipos de datos
    transform!(df_lab_resultados, [:parametro_pk] .=> categorical, renamecols=false)

    return df_lab_resultados
end

export get_ftr_hosp_lab_URG_resultados