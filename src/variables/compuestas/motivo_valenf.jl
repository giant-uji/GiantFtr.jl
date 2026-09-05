using DataFrames
using Dates

"""
    motivo_evaluacion(df_valenf, df_ftr, df_qui) -> DataFrame

Identifica el motivo de la evaluación.

Posibles motivos: Ingreso, Alta, PostQui24, PostQui48, 
Protocolo_2, Protocolo_3, Error_umbral, Desconocido

Devuelve DataFrame con columna :motivo_FINAL que contiene el motivo del valenf
"""
function motivo_evaluacion(df_valenf::DataFrame, df_ftr::DataFrame, df_qui::DataFrame)::DataFrame

    df_result = select(df_valenf, [:id, :id_anonim_episodio, :fecha_valoracion, :valor_valenf_rlpp, :error_umbral, :horas_valenf_previa])

    # Unir con fechas de ingreso y alta
    df_result = leftjoin(df_result, select(df_ftr, [:id_anonim_episodio, :fecha_ingreso, :fecha_alta]),
                          on = :id_anonim_episodio)

    # Se ordena los valenf por episodio y fecha
    # EL ORDEN ES IMPORTANTE PARA motivo_X asi que no tocar
    sort!(df_result, [:id_anonim_episodio, :fecha_valoracion])

    # Braden previo: sobre df_result ya ordenado
    transform!(groupby(df_result, :id_anonim_episodio),
               :valor_valenf_rlpp => (x -> vcat(missing, x[1:end-1])) => :braden_previo)

    # Valor por defecto: un vector propio por fila
    df_result.posible_motivo = [String[] for _ in 1:nrow(df_result)]

    # Marcamos 'Error_umbral' — operación por fila
    df_result.posible_motivo = [
        row.error_umbral === true ? ["Error_umbral"] : row.posible_motivo
        for row in eachrow(df_result)
    ]

    df_result = motivo_ingreso(df_result, df_ftr)
    df_result = motivo_postqui(df_result, df_qui)
    df_result = motivo_protocolo(df_result)

    # Si hay algun motivo que sea DESPUES de la fecha de alta se quita porque solo puede ser Alta o Error_umbral
    df_result.posible_motivo = [
        (!ismissing(row.fecha_alta) && row.fecha_valoracion > row.fecha_alta && !("Error_umbral" in row.posible_motivo)) ?
            String[] : row.posible_motivo
        for row in eachrow(df_result)
    ]

    df_result = motivo_alta(df_result, df_ftr)

    df_result.motivo_FINAL = ajustar_motivo.(df_result.posible_motivo)

    df_result = select(df_result, [:id, :posible_motivo, :motivo_FINAL])

    return df_result
end

export motivo_evaluacion
registrar!(motivo_evaluacion;dependencias = [get_ftr_hosp_valenf, get_ftr_hosp, get_ftr_hosp_int_quirurgicas, error_umbral, horas_valenf_previa], usa = [VALENF, EPISODIOS, INTERVENCIONES], extiende = (VALENF, :id))


"""
    primer_valenf(df_valenf, episodio, fecha, rango_horas)

Devuelve el id del primer VALENF a partir de `fecha` dentro del rango
"""
function primer_valenf(df_valenf::DataFrame, episodio, fecha, rango_horas)
    df_filtrado = df_valenf[(df_valenf.id_anonim_episodio .== episodio) .&
                             (df_valenf.fecha_valoracion .>= fecha), :]

    diferencia_horas = (df_filtrado.fecha_valoracion .- fecha) ./ Dates.Hour(1)
    df_filtrado = df_filtrado[diferencia_horas .<= rango_horas, :]

    if !isempty(df_filtrado)
        return primer_valenf_no_error(df_valenf, df_filtrado[1, :id])
    end

    return nothing
end

"""
    primer_valenf_no_error(df_valenf, id)

Devuelve el id del primer valenf a partir de este que no sea error_umbral
"""
function primer_valenf_no_error(df_valenf::DataFrame, id)
    fila = df_valenf[df_valenf.id .== id, :]
    error_umbral = fila.error_umbral[1]

    if error_umbral !== true
        return id
    end

    episodio = fila.id_anonim_episodio[1]
    fecha = fila.fecha_valoracion[1]

    df_filtrado = df_valenf[(df_valenf.id_anonim_episodio .== episodio) .&
                             (df_valenf.fecha_valoracion .> fecha) .&
                             (df_valenf.error_umbral .== false), :]

    # df_filtrado NUNCA puede estar vacío
    return df_filtrado[1, :id]
end

"""
    ultimo_valenf(df_valenf, episodio, fecha, rango_horas)

Devuelve el id del último VALENF antes de `fecha` dentro del rango
"""
function ultimo_valenf(df_valenf::DataFrame, episodio, fecha, rango_horas)
    mask_base = (df_valenf.id_anonim_episodio .== episodio) .& (df_valenf.fecha_valoracion .<= fecha)

    diferencia_horas = (fecha .- df_valenf.fecha_valoracion) ./ Dates.Hour(1)

    df_filtrado = df_valenf[mask_base .& (diferencia_horas .<= rango_horas), :]

    if !isempty(df_filtrado)
        return df_filtrado[end, :id]
    end

    return nothing
end

function motivo_ingreso(df_valenf::DataFrame, df_ftr::DataFrame)::DataFrame

    for row_ftr in eachrow(df_ftr)
        episodio = row_ftr.id_anonim_episodio
        fecha_ingreso = row_ftr.fecha_ingreso

        valenf_fuera_episodio = df_valenf[(df_valenf.id_anonim_episodio .== episodio) .&
                                           (df_valenf.fecha_valoracion .<= fecha_ingreso), :]

        if !isempty(valenf_fuera_episodio)
            id = valenf_fuera_episodio[end, :id]
            id = primer_valenf_no_error(df_valenf, id)
            idx = findfirst(==(id), df_valenf.id)
            df_valenf[idx, :posible_motivo] = ["Ingreso"]
        else
            id = primer_valenf(df_valenf, episodio, fecha_ingreso, 24)

            if id !== nothing
                idx = findfirst(==(id), df_valenf.id)
                df_valenf[idx, :posible_motivo] = vcat(df_valenf[idx, :posible_motivo], "Ingreso")
            end
        end
    end

    return df_valenf
end

function motivo_postqui(df_valenf::DataFrame, df_qui::DataFrame)::DataFrame

    for row_qui in eachrow(df_qui)
        ismissing(row_qui.fecha_fin) && continue
        
        episodio = row_qui.id_anonim_episodio
        fecha_intervencion = row_qui.fecha_fin

        if coalesce(row_qui.codigo_destino == 7, false)  # UCI
            tiempo_max = 48
            etiqueta = "PostQui48"
        else
            tiempo_max = 24
            etiqueta = "PostQui24"
        end

        id = primer_valenf(df_valenf, episodio, fecha_intervencion, tiempo_max)

        if id !== nothing
            idx = findfirst(==(id), df_valenf.id)
            df_valenf[idx, :posible_motivo] = vcat(df_valenf[idx, :posible_motivo], etiqueta)
        end
    end

    return df_valenf
end

function motivo_alta(df_valenf::DataFrame, df_ftr::DataFrame)::DataFrame

    for row_ftr in eachrow(df_ftr)
        ismissing(row_ftr.fecha_alta) && continue
        
        episodio = row_ftr.id_anonim_episodio
        fecha_alta = row_ftr.fecha_alta

        valenf_fuera_episodio = df_valenf[(df_valenf.id_anonim_episodio .== episodio) .&
                                           (df_valenf.fecha_valoracion .> fecha_alta), :]

        if !isempty(valenf_fuera_episodio)
            id = valenf_fuera_episodio[end, :id]
            idx = findfirst(==(id), df_valenf.id)
            df_valenf[idx, :posible_motivo] = ["Alta"]
        else
            id = ultimo_valenf(df_valenf, episodio, fecha_alta, 24)

            if id !== nothing
                idx = findfirst(==(id), df_valenf.id)
                df_valenf[idx, :posible_motivo] = vcat(df_valenf[idx, :posible_motivo], "Alta")
            end
        end
    end

    return df_valenf
end

function motivo_protocolo(df_valenf::DataFrame)::DataFrame

    protocolo2 = coalesce.(
        (df_valenf.braden_previo .>= 14.640001) .& (df_valenf.braden_previo .<= 17.42) .&
        (df_valenf.horas_valenf_previa .>= 168) .& (df_valenf.horas_valenf_previa .<= 192),
        false)

    protocolo3 = coalesce.(
        (df_valenf.braden_previo .>= 6) .& (df_valenf.braden_previo .<= 14.64) .&
        (df_valenf.horas_valenf_previa .>= 72) .& (df_valenf.horas_valenf_previa .<= 96),
        false)

    for id in df_valenf.id[protocolo2]
        id_resuelto = primer_valenf_no_error(df_valenf, id)
        idx = findfirst(==(id_resuelto), df_valenf.id)
        df_valenf[idx, :posible_motivo] = vcat(df_valenf[idx, :posible_motivo], "Protocolo_2")
    end

    for id in df_valenf.id[protocolo3]
        id_resuelto = primer_valenf_no_error(df_valenf, id)
        idx = findfirst(==(id_resuelto), df_valenf.id)
        df_valenf[idx, :posible_motivo] = vcat(df_valenf[idx, :posible_motivo], "Protocolo_3")
    end

    return df_valenf
end

"""
    ajustar_motivo(motivo_lista) -> String

Resuelve el motivo final cuando un valenf tiene varios posibles motivos
"""
function ajustar_motivo(motivo_lista::Vector{String})::String
    if isempty(motivo_lista)
        return "Desconocido"
    end

    if length(motivo_lista) < 2
        return motivo_lista[1]
    end

    if "Error_umbral" in motivo_lista
        return "ERROR_UMBRAL: Contactad con los informaticos"
    end

    if "Ingreso" in motivo_lista && ("Protocolo_2" in motivo_lista || "Protocolo_3" in motivo_lista)
        return "ERROR_PROTOCOLO: Contactad con los informaticos"
    end

    if "PostQui24" in motivo_lista
        return "PostQui24"
    end

    if "PostQui48" in motivo_lista
        return "PostQui48"
    end

    if "Ingreso" in motivo_lista
        return "Ingreso"
    end

    if "Protocolo_2" in motivo_lista
        return "Protocolo_2"
    end

    if "Protocolo_3" in motivo_lista
        return "Protocolo_3"
    end

    return "ERROR_FIN: Contactad con los informaticos"
end