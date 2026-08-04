function get_ftr_hosp_ctes_RAW()::DataFrame
    return get_table("ftr_hosp_ctes")
end

export get_ftr_hosp_ctes_RAW

function get_ftr_hosp_ctes()::DataFrame
    df_ctes = get_table("ftr_hosp_ctes")

    #1- Filtrado de columnas
    #2- Renombrado de columnas
    #3- Convertir tipos de columnas

    #Todas las fechas con el mismo formato
    #Por defecto las cargaba como String
    transform!(df_ctes, :fecha_toma .=> ByRow(x -> ismissing(x) ? missing : DateTime(x)), renamecols=false)

    #Tipos categoricos
    #Ayuda a optimizar cuando hay muchos tipos de datos
    transform!(df_ctes, :tipo_valor_pk .=> categorical, renamecols=false)


    #4- Transformaciones basicas necesarias

    #Se elimina la simultanedad usando ID
    eliminar_simultanedad_ctes!(df_ctes)

    return df_ctes
end

export get_ftr_hosp_ctes
registrar!(get_ftr_hosp_ctes;produce = CONSTANTES)


function eliminar_simultanedad_ctes!(df::DataFrame)::DataFrame

    #OPTIMIZACION: Con el codigo de VALENF tardaba > 15 minutos
    #Se han eliminado variables intermedias

    #Ordenamos por episodio fecha e ID
    #ID es para desempatar en fechas
    sort!(df, [:id_anonim_episodio, :fecha_toma, :id])

    #Para cada columna se calcula el nuevo tiempo de forma proporcional
    # 2 tomas en el minuto 01:00 sera 01:00 y 01:30
    # 3 tomas en el minuto 01:00 sera 01:00, 01:20 y 01:40
    # 4 tomas en el minuto 01:00 sera 01:00, 01:15, 01:30 y 01:45
    for group in groupby(df, [:id_anonim_episodio, :tipo_valor_pk, :fecha_toma])
        n = nrow(group)

        if n > 1
            #Si se descomenta tarda 3.5 veces mas
            #DEBUG && group.count = 0:n-1
            #DEBUG && group.total .= n

            group.fecha_toma .+=
                Millisecond.(round.(Int, (0:(n-1)) .* (60_000 / n)))
        end
    end

    return df
end