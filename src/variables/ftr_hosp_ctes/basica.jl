function diuresis24h(df_ctes::DataFrame)

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
        id = -collect(1:nrow(df_agrupado)),     #ID negativa para evitar colisiones con DB
        id_anonim_episodio = df_agrupado.id_anonim_episodio,
        tipo_valor_pk = fill(DIURESIS24H, nrow(df_agrupado)),
        valor_campo = df_agrupado.valor_campo,
        fecha_toma = df_agrupado.fecha_toma
    )

    return df_resultado
end

export diuresis24h
registrar!(diuresis24h;dependencias=[get_ftr_hosp_ctes], usa= [CONSTANTES],anyade = CONSTANTES)
