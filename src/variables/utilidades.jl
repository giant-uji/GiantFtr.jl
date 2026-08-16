function en_rango(valor::Float64, rangos::Vector{Tuple{Float64,Float64}})
    for (inicio, fin) in rangos
        if inicio < valor < fin
            return true
        end
    end

    return false
end


function agrupador_generico(
    df::DataFrame,
    df_ftr::DataFrame,
    tipo,
    prefijo::String,
    col_id::Symbol,
    col_tipo::Symbol,
    col_valor::Symbol,
    col_fecha::Symbol;
    rango_fisiologico::Union{Nothing,Tuple}=nothing,
    #Vector{_} requiere ser FUERTEMENTE TIPADO, un Vector{Tuple} lanza error
    rangos_anomalos::Union{Nothing,Vector{Tuple{Float64,Float64}}}=nothing,
    )::DataFrame

    #Solo queremos el listado de episodios
    df_ids = df_ftr[:, [:id_anonim_episodio]]

    #Filtramos entrada
    if isnothing(rango_fisiologico)
        df_filtrado = filter(
            row -> row[col_tipo] == tipo,
            df
        )
    else
        minimo, maximo = rango_fisiologico

        df_filtrado = filter(
            row ->
                row[col_tipo] == tipo &&
                minimo <= row[col_valor] <= maximo,#Rango compatible con la vida
            df
        )
    end

    #Ordenar por fecha e id, hace falta para identificar primero y ultimo
    #La ID es cuando hay multiples tomas en el mismo minuto
    sort!(df_filtrado, [col_fecha, col_id])

    calcular_anomalias = !isnothing(rangos_anomalos)

    #Agregacion
    df_agrupado = combine(
        groupby(df_filtrado, :id_anonim_episodio),
        col_valor => (grupo -> begin

            recuento = length(grupo)
            existe_valor = Int(recuento > 0)

            #Si el DataFrame de entrada esta vacio devolver missing
            primero = recuento == 0 ? missing : grupo[1]
            ultimo  = recuento == 0 ? missing : grupo[end]

            minimo = primero#Se calcula en el for por optimizacion
            maximo = primero#Se calcula en el for por optimizacion

            recuento_rango = 0

            # Un único recorrido
            for valor in grupo

                if valor < minimo
                    minimo = valor

                elseif valor > maximo
                    maximo = valor

                end

                if calcular_anomalias &&
                   en_rango(valor, rangos_anomalos)
                    recuento_rango += 1
                end
            end

            prop_alterada = 0.0 #Julia no transforma Int a Float...

            if recuento != 0 #Evita division por 0
                prop_alterada = recuento_rango / recuento * 100
            end

            (
                existe_valor = existe_valor,
                recuento = recuento,
                primero = primero,
                ultimo = ultimo,
                minimo = minimo,
                maximo = maximo,
                any_alterada = Int(recuento_rango > 0),
                recuento_alterada = recuento_rango,
                prop_alterada = prop_alterada,
                delta_descenso = primero - minimo,
                delta_aumento = maximo - primero
            )

        end) => AsTable
    )

    #Episodios sin valoraciones
    df_result = leftjoin(
        df_ids,
        df_agrupado,
        on=:id_anonim_episodio
    )

    #Eliminamos missing
    df_result.existe_valor = coalesce.(df_result.existe_valor, 0)
    df_result.recuento = coalesce.(df_result.recuento, 0)

    df_result.any_alterada = coalesce.(df_result.any_alterada, 0)
    df_result.recuento_alterada = coalesce.(df_result.recuento_alterada, 0)
    df_result.prop_alterada = coalesce.(df_result.prop_alterada, 0.0)

    #Anyadir prefijo
    #Se hace al final para simplificar el codigo de eliminar missing
    rename!(
    df_result,
    [
        c => (c == "id_anonim_episodio" ? c : "$(prefijo)_$c")
        for c in names(df_result)
    ])

    return df_result
end
