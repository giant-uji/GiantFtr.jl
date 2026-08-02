export get_ftr_hosp_codificacion_RAW

function get_ftr_hosp_codificacion_RAW()::DataFrame
    return get_table("ftr_hosp_codificacion")
end


export get_ftr_hosp_codificacion

function get_ftr_hosp_codificacion()::DataFrame
    df_cod = get_table("ftr_hosp_codificacion")

    #1- Filtrado de columnas
    #2- Renombrado de columnas
    #3- Convertir tipos de columnas

    #Tipos categoricos
    #Ayuda a optimizar cuando hay muchos tipos de datos
    #NO se categoriza codigo_cie porque se necesita en String para capitulo / seccion
    transform!(df_cod, [:diagnostico_principal_sn] .=> categorical, renamecols=false)

    return df_cod
end