export categoria_barthel

function categoria_barthel(id_anonim_episodio::Int64, ruta_credenciales::String)::String
    resultado = "Dependencia leve"
    df =  get_ftr_hosp_valenf(ruta_credenciales)
    valor_barthel = df[df.id_anonim_episodio .== id_anonim_episodio, :valor_barthel][1]
    if valor_barthel >= 0 && valor_barthel <= 34.101630
        resultado = "Dependencia severa"
    elseif valor_barthel >= 34.101631 && valor_barthel <= 78.270630
        resultado = "Dependencia moderada"
    end
    return resultado
end
