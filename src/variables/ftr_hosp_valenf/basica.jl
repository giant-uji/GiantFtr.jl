function error_umbral(df_valenf::DataFrame)::DataFrame
    valenf_mod = select(df_valenf, :id, :id_anonim_episodio, :fecha_valoracion)

    sort!(valenf_mod, [:id_anonim_episodio, :fecha_valoracion])

    transform!(groupby(valenf_mod, :id_anonim_episodio),
        :fecha_valoracion => (x -> [diff(x) .<= Minute(T_UMBRAL_ERROR_VALENF); false]) => :error_umbral)

    return select(valenf_mod, :id, :error_umbral)
end

export error_umbral
registrar!(error_umbral;dependencias = [get_ftr_hosp_valenf], usa = [VALENF], extiende = (VALENF, :id))


function horas_valenf_previa(df_valenf::DataFrame)::DataFrame
    valenf_mod = select(df_valenf, :id, :id_anonim_episodio, :fecha_valoracion)

    #Se ordena por episodio y fecha
    sort!(valenf_mod, [:id_anonim_episodio, :fecha_valoracion])

    transform!(groupby(valenf_mod, :id_anonim_episodio),
    :fecha_valoracion => (x -> [missing; Dates.value.(diff(x)) ./ 3_600_000]) => :horas_valenf_previa)

    return select(valenf_mod, :id, :horas_valenf_previa)
end

export horas_valenf_previa
registrar!(horas_valenf_previa;dependencias = [get_ftr_hosp_valenf], usa = [VALENF], extiende = (VALENF, :id))

function orden_valenf(df_valenf::DataFrame)::DataFrame
    valenf_mod = select(df_valenf, :id, :id_anonim_episodio, :fecha_valoracion)
    
    sort!(valenf_mod, [:id_anonim_episodio, :fecha_valoracion])
    
    transform!(groupby(valenf_mod, :id_anonim_episodio),
               :id_anonim_episodio => eachindex => :orden_valenf)
    
    return select(valenf_mod, :id, :orden_valenf)
end

export orden_valenf
registrar!(orden_valenf;dependencias = [get_ftr_hosp_valenf], usa = [VALENF], extiende = (VALENF, :id))


function categoria_valenf_cf(df_valenf::DataFrame)::DataFrame
    printstyled("[WARNING] categoria_valenf_cf: Enfermeria tiene que consensuar los rangos\n", color=:yellow, bold=true)

    select(df_valenf,
        :id,
        :valor_valenf_cf => (v -> ifelse.(v .<= 34.101630, DEPENDENCIA_SEVERA,
                                  ifelse.(v .<= 78.270630, DEPENDENCIA_MODERADA,
                                          DEPENDENCIA_LEVE))) => :categoria_valenf_cf
    )

    #Julia hace un return de lo ultimo ejecutado
end

export categoria_valenf_cf
registrar!(categoria_valenf_cf;dependencias = [get_ftr_hosp_valenf], usa = [VALENF], extiende = (VALENF, :id))


function categoria_valenf_rlpp(df_valenf::DataFrame)::DataFrame
    printstyled("[WARNING] categoria_valenf_rlpp: Enfermeria tiene que consensuar los rangos\n", color=:yellow, bold=true)
    
    select(df_valenf,
        :id,
        :valor_valenf_rlpp => (v -> ifelse.(v .> 17.42, SIN_RIESGO,
                                  ifelse.(v .> 14.64, RIESGO_MODERADO,
                                          RIESGO_ALTO))) => :categoria_valenf_rlpp
    )

    #Julia hace un return de lo ultimo ejecutado
end

export categoria_valenf_rlpp
registrar!(categoria_valenf_rlpp;dependencias = [get_ftr_hosp_valenf], usa = [VALENF], extiende = (VALENF, :id))


function categoria_valenf_rc(df_valenf::DataFrame)::DataFrame
    printstyled("[WARNING] categoria_downton: Enfermeria tiene que consensuar los rangos\n", color=:yellow, bold=true)
    
    select(df_valenf,
        :id,
        :valor_valenf_rc => (v -> ifelse.(v .< 2.084, SIN_RIESGO,
                                 ifelse.(v .< 3.46, RIESGO_MODERADO,
                                         RIESGO_ALTO))) => :categoria_valenf_rc
    )

    #Julia hace un return de lo ultimo ejecutado
end

export categoria_valenf_rc
registrar!(categoria_valenf_rc;dependencias = [get_ftr_hosp_valenf], usa = [VALENF], extiende = (VALENF, :id))