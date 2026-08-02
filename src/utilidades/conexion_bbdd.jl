const ruta_fichero_credenciales = "./credenciales.json"

#DEBUG, comentar esta linea para produccion
#No quiero que NADIE pueda cargue tablas directamente, que pase siempre por PREPARACION
export get_table

function get_table(table_name::String)::DataFrame

    #Base de datos en LOCAL, para evitar haciendo peticiones todo el rato y evitar bloqueos
    #Trabajo en una VM cifrada de linux
    #El .gitignore incluye db_local
    ruta_csv = "GiantFtr.jl/assets/db_local/$table_name.csv"
    #@show ruta_csv


    if isfile(ruta_csv)
        VERBOSE && println("Tabla local: $table_name")
        return CSV.read(ruta_csv, DataFrame)
    else
        VERBOSE && println("Tabla remota: $table_name")
        return get_table_bd(table_name)
    end
end

function get_table_bd(table_name::String)::DataFrame
    conexion = get_conexion()
    resultado = DataFrame(execute(conexion, "SELECT * FROM $table_name", not_null=false))
    close(conexion)
    return resultado
end

function get_conexion()
    credenciales_json = JSON.parsefile(ruta_fichero_credenciales);
    credenciales = "dbname=" * credenciales_json["dbname"] *
        " host=" * credenciales_json["host"] * 
        " user=" * credenciales_json["user"] * 
        " password=" * credenciales_json["password"];
    return LibPQ.Connection(credenciales);
end
