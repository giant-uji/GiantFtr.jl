function get_ftr_hosp_int_quirurgicas_RAW(contexto::ContextoOpcional)::DataFrame
    return get_table("ftr_hosp_int_quirurgicas")
end

export get_ftr_hosp_int_quirurgicas_RAW


function get_ftr_hosp_int_quirurgicas(contexto::ContextoOpcional)::DataFrame
    df_qui = get_table("ftr_hosp_int_quirurgicas")

    #1- Filtrado de columnas
    #2- Renombrado de columnas
    #3- Convertir tipos de columnas

    #Tipos categoricos
    #Por defecto las cargaba como String
    transform!(df_qui, [:fecha_inicio, :fecha_fin] .=> ByRow(x -> ismissing(x) ? missing : DateTime(x)), renamecols=false)

    #Tipos categoricos
    #Ayuda a optimizar cuando hay muchos tipos de datos
    transform!(df_qui, [:codigo_servicio, :tipo_intervencion, :codigo_tipo_anestesia, :codigo_destino, :abordaje_quirurgico, :categoria_intervencion] .=> categorical, renamecols=false)

    return df_qui
end

export get_ftr_hosp_int_quirurgicas
registrar!(get_ftr_hosp_int_quirurgicas;produce = :intervenciones)