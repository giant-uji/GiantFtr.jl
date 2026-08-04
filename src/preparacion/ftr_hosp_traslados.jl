function get_ftr_hosp_traslados_RAW()::DataFrame
    return get_table("ftr_hosp_traslados")
end

export get_ftr_hosp_traslados_RAW


function get_ftr_hosp_traslados()::DataFrame
    df_tras = get_table("ftr_hosp_traslados")

    #1- Filtrado de columnas
    #2- Renombrado de columnas
    #3- Convertir tipos de columnas

    #Todas las fechas con el mismo formato
    #Por defecto las cargaba como String
    transform!(df_tras, [:fecha_desde, :fecha_hasta] .=> ByRow(x -> ismissing(x) ? missing : DateTime(x)), renamecols=false)

    #Tipos categoricos
    #Ayuda a optimizar cuando hay muchos tipos de datos
    transform!(df_tras, :codigo_servicio .=> categorical, renamecols=false)

    return df_tras
end

export get_ftr_hosp_traslados
registrar!(get_ftr_hosp_traslados;produce = TRASLADOS)