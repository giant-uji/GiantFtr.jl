function error_umbral(df_valenf::DataFrame)::DataFrame
    valenf_mod = select(df_valenf, :id, :id_anonim_episodio, :fecha_valoracion)

    sort!(valenf_mod, [:id_anonim_episodio, :fecha_valoracion])

    transform!(groupby(valenf_mod, :id_anonim_episodio),
        :fecha_valoracion => (x -> [diff(x) .<= Minute(T_UMBRAL_ERROR_VALENF); false]) => :error_umbral)

    return select(valenf_mod, :id, :error_umbral)
end

export error_umbral
registrar!(error_umbral;dependencias = [get_ftr_hosp_valenf], usa = [VALENF], extiende = (VALENF, :id))
