function get_ftr_hosp_lab()::DataFrame
    if ANALITICAS_CON_URGENCIAS
        VERBOSE && println("ftr_hosp_lab con URGENCIAS")
        return get_ftr_hosp_lab_ALL()
    end

    return get_ftr_hosp_lab_HOSP()
end

export get_ftr_hosp_lab
registrar!(get_ftr_hosp_lab;produce = LABORATORIO)


function get_ftr_hosp_lab_ALL()::DataFrame
    return append!(get_ftr_hosp_lab_HOSP(), get_ftr_hosp_lab_URG())
end

export get_ftr_hosp_lab_ALL


function get_ftr_hosp_lab_RAW()::DataFrame
    return get_table("ftr_hosp_lab")
end

export get_ftr_hosp_lab_RAW


function get_ftr_hosp_lab_HOSP()::DataFrame
    df_lab = get_table("ftr_hosp_lab")

    #1- Filtrado de columnas
    #2- Renombrado de columnas
    #3- Convertir tipos de columnas

    #Todas las fechas con el mismo formato
    #Por defecto las cargaba como String
    transform!(df_lab, [:fecha_peticion, :fecha_conciliacion] .=> ByRow(x -> ismissing(x) ? missing : DateTime(x)), renamecols=false)

    return df_lab
end

export get_ftr_hosp_lab_HOSP


function get_ftr_hosp_lab_URG_RAW()::DataFrame
    return get_table("ftr_hosp_lab_urg")
end

export get_ftr_hosp_lab_URG_RAW


function get_ftr_hosp_lab_URG()::DataFrame
    df_lab = get_table("ftr_hosp_lab_urg")

    #0- URGENCIAS: transformar id_anonim_episodio_URG a id_anonim_episodio
    df_urg = get_table("ftr_hosp_urg")
    select!(df_urg, [:id_anonim_episodio_urg, :id_anonim_episodio])
    df_lab = leftjoin(df_lab, df_urg, on=:id_anonim_episodio_urg)

    #1- Filtrado de columnas
    #Filtramos Y reordenamos columnas igual que ftr_hosp_lab
    select!(df_lab, [:id_anonim_episodio, :id_solicitud_urg, :fecha_peticion, :fecha_conciliacion, :texto_parametros])

    #2- Renombrado de columnas
    #id_solicitud_urg -> id_solicitud: Consistencia con ftr_hosp_lab
    rename!(df_lab, :id_solicitud_urg => :id_solicitud)

    #3- Convertir tipos de columnas

    #Todas las fechas con el mismo formato
    #Por defecto las cargaba como String
    transform!(df_lab, [:fecha_peticion, :fecha_conciliacion] .=> ByRow(x -> ismissing(x) ? missing : DateTime(x)), renamecols=false)

    return df_lab
end

export get_ftr_hosp_lab_URG