function diuresis24h(df_ctes::DataFrame)::DataFrame

    #Filtramos diuresis
    df_diuresis = filter(:tipo_valor_pk => ==(DIURESIS), df_ctes)

    #Identificamos el dia de cada toma que comienza a las 08:00
    df_diuresis.dia_clinico = [
        hour(dt) < 8 ? Date(dt) - Day(1) : Date(dt)
        for dt in df_diuresis.fecha_toma
    ]

    #Agrupamos y calculamoss
    df_agrupado = combine(
        groupby(df_diuresis, [:id_anonim_episodio, :dia_clinico]),
        :valor_campo => sum => :valor_campo,
        :fecha_toma => maximum => :fecha_toma   #La HORA de la diuresis24h es la de la ultima toma
    )

    #Camos DataFrame de resultado
    df_resultado = DataFrame(
        id = [
                get_ctes_id(r.fecha_toma,DIURESIS24H, r.id_anonim_episodio)
                for r in eachrow(df_agrupado)
            ], # ID negativo determinista
        id_anonim_episodio = df_agrupado.id_anonim_episodio,
        tipo_valor_pk = fill(DIURESIS24H, nrow(df_agrupado)),
        valor_campo = df_agrupado.valor_campo,
        fecha_toma = df_agrupado.fecha_toma
    )

    return df_resultado
end

export diuresis24h
registrar!(diuresis24h;dependencias=[get_ftr_hosp_ctes], usa= [CONSTANTES],anyade = CONSTANTES)


function shock_index(df_ctes::DataFrame)::DataFrame

    #Fitramos las variables de FC y TAS que son las que usamos
    df_FC_TAS = filter(
        row -> row.tipo_valor_pk in [FRECUENCIA_CARDIACA, TA_SISTOLICA],
        df_ctes
    )

    #Generamos la estructura del DataFrame de salida
    df_resultado = DataFrame(
        id = Int64[],
        id_anonim_episodio = Int64[],
        tipo_valor_pk = Int64[],
        valor_campo = Float64[],
        fecha_toma = DateTime[]
    )

    #Agrupamos por episodio y toma
    df_agrupado = groupby(df_FC_TAS, [:id_anonim_episodio, :fecha_toma])


    for grupo in df_agrupado
        # Obtenemos FC y TAS en el mismo instante
        fc = filter(row -> row.tipo_valor_pk == FRECUENCIA_CARDIACA, grupo)
        tas = filter(row -> row.tipo_valor_pk == TA_SISTOLICA, grupo)

        #Calculamos si existen AMBAS
        if !isempty(fc) && !isempty(tas)

            valor = Float64(fc.valor_campo[1]) / Float64(tas.valor_campo[1])

            push!(df_resultado, (
                get_ctes_id(grupo.fecha_toma[1],SHOCK_INDEX, grupo.id_anonim_episodio[1]),
                grupo.id_anonim_episodio[1],
                SHOCK_INDEX,
                valor,
                grupo.fecha_toma[1]
            ))
        end
    end

    return df_resultado
end

export shock_index
registrar!(shock_index;dependencias = [get_ftr_hosp_ctes], usa = [CONSTANTES], anyade = CONSTANTES)