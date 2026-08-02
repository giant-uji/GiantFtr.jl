export get_ftr_hosp_interconsultas_RAW

function get_ftr_hosp_interconsultas_RAW()::DataFrame
    return get_table("ftr_hosp_interconsultas")
end


export get_ftr_hosp_interconsultas

function get_ftr_hosp_interconsultas()::DataFrame
    df_inter = get_table("ftr_hosp_interconsultas")

    #1- Filtrado de columnas
    #2- Renombrado de columnas
    #3- Convertir tipos de columnas

    #Todas las fechas con el mismo formato
    #Por defecto las cargaba como String
    transform!(df_inter, :fecha_interconsulta .=> ByRow(x -> ismissing(x) ? missing : DateTime(x)), renamecols=false)

    #Tipos categoricos
    #Ayuda a optimizar cuando hay muchos tipos de datos
    transform!(df_inter, [:cod_servicio_solicitante, :cod_servicio_destino] .=> categorical, renamecols=false)

    return df_inter
end