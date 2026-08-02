#Constantes de CTES
const GLUCEMIAS = 2
const TA_SISTOLICA = 3
const TA_DISTOLICA = 4
const FRECUENCIA_CARDIACA = 5
const SATO2 = 6
const DIURESIS = 7
const TEMPERATURA = 8

export en_rango

function en_rango(v, rangos)
    for (inicio, fin) in rangos
        if inicio < v < fin
            return true
        end
    end

    return false
end

export agr_generic

function agr_generic(df::DataFrame, df_episodios::DataFrame, tipo_valor_pk, prefijo::String, rango_valido::Union{Nothing,Tuple}=nothing, rangos_anomalos::Union{Nothing,Vector}=nothing )::DataFrame

    #Filtramos entrada
    if isnothing(rango_valido)
        df_filtrado = filter(
            row -> row.tipo_valor_pk == tipo_valor_pk,
            df
        )
    else
        minimo, maximo = rango_valido

        df_filtrado = filter(
            row ->
                row.tipo_valor_pk == tipo_valor_pk &&
                minimo <= row.valor_campo <= maximo,#Rango compatible con la vida
            df
        )
    end

    #Ordenar por fecha e id, hace falta para identificar primero y ultimo
    #La ID es cuando hay multiples tomas en el mismo minuto
    sort!(df_filtrado, [:fecha_toma, :id])

    calcular_anomalias = !isnothing(rangos_anomalos)

    #Agregacion
    df_agrupado = combine(
        groupby(df_filtrado, :id_anonim_episodio),
        :valor_campo => (grupo -> begin

            recuento = length(grupo)
            existe_valor = Int(recuento > 0)

            primero = grupo[1]
            ultimo = grupo[end]

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

            prop_alterada = 0

            if recuento != 0#Evita division por 0
                prop_alterada = recuento_rango / recuento * 100
            end

            (
                existe_valor=existe_valor,
                recuento=recuento, primero=primero,
                ultimo=ultimo, minimo=minimo,
                maximo=maximo, any_alterada=Int(recuento_rango > 0),
                recuento_alterada=recuento_rango,
                prop_alterada=prop_alterada, delta_descenso=primero - minimo,
                delta_aumento=maximo - primero
            )

        end) => AsTable
    )

    #Episodios sin valoraciones
    df_result = leftjoin(
        df_episodios,
        df_agrupado,
        on=:id_anonim_episodio
    )

    #Eliminamos missing
    df_result.existe_valor = coalesce.(df_result.existe_valor, 0)
    df_result.recuento = coalesce.(df_result.recuento, 0)

    df_result.any_alterada = coalesce.(df_result.any_alterada, 0)
    df_result.recuento_alterada = coalesce.(df_result.recuento_alterada, 0)
    df_result.prop_alterada = coalesce.(df_result.prop_alterada, 0)

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

