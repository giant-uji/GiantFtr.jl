using LibPQ
using JSON
using DataFrames

export get_ftr_hosp, get_table_bd

const ruta_fichero_credenciales = "./credenciales.json"

function get_conexion()
    credenciales_json = JSON.parsefile(ruta_fichero_credenciales);
    credenciales = "dbname=" * credenciales_json["dbname"] *
        " host=" * credenciales_json["host"] * 
        " user=" * credenciales_json["user"] * 
        " password=" * credenciales_json["password"];
    return LibPQ.Connection(credenciales);
end

function get_ftr_hosp()
    conexion = get_conexion()
    resultado = DataFrame(execute(conexion, "select * from ftr_hosp", not_null=false))
    close(conexion)
    return resultado
end

function get_table_bd(table_name::String)
    conexion = get_conexion()
    resultado = DataFrame(execute(conexion, "select * from " + table_name, not_null=false))
    close(conexion)
    return resultado
end

