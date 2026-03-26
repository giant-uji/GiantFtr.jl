using LibPQ
using JSON
using DataFrames

export get_ftr_hosp()

function get_conexion(ruta_credenciales::String)
    credenciales_json = JSON.parsefile(ruta_credenciales);
    credenciales = "dbname=" * credenciales_json["dbname"] *
        " host=" * credenciales_json["host"] * 
        " user=" * credenciales_json["user"] * 
        " password=" * credenciales_json["password"];
    return LibPQ.Connection(credenciales);
end

function get_ftr_hosp(ruta_credenciales::String)
    conexion = get_conexion(ruta_credenciales)
    resultado = DataFrame(execute(conexion, "select * from ftr_hosp", not_null=false))
    close(conexion)
    return resultado
end


