function get_ftr_hosp_RAW()::DataFrame
    return get_table("ftr_hosp")
end

export get_ftr_hosp_RAW


function get_ftr_hosp()::DataFrame
    df_ftr = get_table("ftr_hosp")

    #1- Filtrado de columnas

    #Se elimina reingreso7d_sn porque viene mal de base (validado)
    #Ademas existe una variable derivada que la sustituye
    select!(df_ftr, Not(:reingreso7d_sn))


    #2- Renombrado de columnas

    #tipoproceso -> tipo_proceso: Consistencia a la hora de nombrar columnas
    rename!(df_ftr, :tipoproceso => :tipo_proceso)


    #3- Convertir tipos de columnas

    #Todas las fechas con el mismo formato
    #Por defecto las cargaba como String y fecha_exitus al no tener Time se transformaba mal
    transform!(df_ftr, [:fecha_ingreso, :fecha_alta, :fecha_exitus] .=> ByRow(x -> ismissing(x) ? missing : DateTime(x)), renamecols=false)

    #Tipos categoricos
    #Ayuda a optimizar cuando hay muchos tipos de datos
    transform!(df_ftr, [:sexo, :tipo_ingreso, :tipo_proceso, :cod_serv_ingreso, :cod_serv_alta, :motivo_alta_pk, :proceso_paliativo] .=> categorical, renamecols=false)

    return df_ftr
end

export get_ftr_hosp
registrar!(get_ftr_hosp;produce = EPISODIOS)