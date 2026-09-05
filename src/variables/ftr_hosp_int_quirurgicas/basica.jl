function duracion_intervencion(df_qui::DataFrame)::DataFrame
    select(df_qui,
        :id,
        [:fecha_inicio, :fecha_fin] => ByRow((f_inicio, f_fin) -> begin
            if ismissing(f_inicio) || ismissing(f_fin)
                (duracion_intervencion_minutos = missing, duracion_intervencion_horas = missing)
            else
                ms = Dates.value(f_fin - f_inicio)
                (duracion_intervencion_minutos = ms / 60_000,       #60 x 1000 milisegundos
                 duracion_intervencion_horas = ms / 3_600_000)      #3600 x 1000 milisegundos
            end
        end) => AsTable
    )

    #Julia hace un return de lo ultimo ejecutado
end

export duracion_intervencion
registrar!(duracion_intervencion;dependencias = [get_ftr_hosp_int_quirurgicas], usa = [INTERVENCIONES], extiende = (INTERVENCIONES, :id))