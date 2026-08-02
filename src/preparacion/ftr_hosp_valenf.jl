export get_ftr_hosp_valenf_RAW

function get_ftr_hosp_valenf_RAW()::DataFrame
    return get_table("ftr_hosp_valenf")
end


export get_ftr_hosp_valenf

function get_ftr_hosp_valenf()::DataFrame
    df_valenf = get_table("ftr_hosp_valenf")

    #1- Filtrado de columnas
    #2- Renombrado de columnas

    #Renombramos columnas a peticion de enfermeria
    rename!(df_valenf, :valor_braden => :valor_valenf_rlpp)
    rename!(df_valenf, :valor_barthel => :valor_valenf_cf)
    rename!(df_valenf, :valor_downtown => :valor_valenf_rc)

    #3- Convertir tipos de columnas

    #Todas las fechas con el mismo formato
    #Por defecto las cargaba como String
    transform!(df_valenf, :fecha_valoracion .=> ByRow(x -> ismissing(x) ? missing : DateTime(x)), renamecols=false)

    #NO se combierten respuesta_pregunta? a categorical porque seguramente se necesiten en INT para los clasificadores

    #4- Transformaciones basicas necesarias

    #Se mapean las respuestas de valenf del valor categorico al valor real
    mapear_respuestas_valenf!(df_valenf)

    #Se elimina la simultanedad usando ID
    eliminar_simultanedad_valenf!(df_valenf)

    return df_valenf
end


function mapear_respuestas_valenf!(df::DataFrame)::DataFrame
    mapeos = Dict(
        :respuesta_pregunta1 => Dict(1=>15, 2=>10, 3=>5, 4=>0),
        :respuesta_pregunta6 => Dict(1=>1, 2=>0),
        :respuesta_pregunta7 => Dict(1=>1, 2=>0),
    )

    for (col, mapa) in mapeos
        df[!, col] = map(x -> ismissing(x) ? missing : mapa[x], df[!, col])
    end

    return df
end


function eliminar_simultanedad_valenf!(df::DataFrame)::DataFrame

    #Ordenamos por episodio fecha e ID
    #ID es para desempatar en fechas
    sort!(df, [:id_anonim_episodio, :fecha_valoracion, :id])

    #Se agrupa por episodio y fecha
    groups = groupby(df, [:id_anonim_episodio, :fecha_valoracion])

    #Creamos columna para posicion y total
    df.count = Vector{Int}(undef, nrow(df))
    df.total = Vector{Int}(undef, nrow(df))

    for group in groups
        n = nrow(group)

        group[!, :count] = 0:(n-1)
        group[!, :total] .= n
    end

    #Para cada columna se calcula el nuevo tiempo de forma proporcional
    # 2 valenf en el minuto 01:00 sera 01:00 y 01:30
    # 3 valenf en el minuto 01:00 sera 01:00, 01:20 y 01:40
    # 4 valenf en el minuto 01:00 sera 01:00, 01:15, 01:30 y 01:45
    df.fecha_valoracion .+=
        Millisecond.(round.(Int, df.count .* (60000 ./ df.total)))

    #Eliminamos las columnas extra
    select!(df, Not([:count, :total]))

    return df
end