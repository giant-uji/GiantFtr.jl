module GiantFtr

using DataFrames
using LibPQ                             #Acceder a DB
using JSON                              #Leer fichero de credenciales
using CSV                               #Cargar fichero CSV
using Base.Filesystem: isfile           #Comprobar si existe fichero
using Dates                             #Columnas tipo Fecha
using CategoricalArrays: categorical    #Columnas tipo Categorica (optimizacion)
using SHA                               #Se utiliza generar id de forma determinista


#El orden de estos includes son importantes
include("config.jl")
include("constantes.jl")
include("DAG/tabla.jl")
include("DAG/registro.jl")
include("DAG/dag.jl")


#UTILIDADES (funciones comunes)
include("utilidades/conexion_bbdd.jl")


#PREPARACION (carga datos, tipo columnas y limpieza)
include("preparacion/ftr_hosp.jl")
include("preparacion/ftr_hosp_valenf.jl")
include("preparacion/ftr_hosp_codificacion.jl")
include("preparacion/ftr_hosp_interconsultas.jl")
include("preparacion/ftr_hosp_int_quirurgicas.jl")
include("preparacion/ftr_hosp_traslados.jl")
include("preparacion/ftr_hosp_ctes.jl")
include("preparacion/ftr_hosp_lab.jl")
include("preparacion/ftr_hosp_lab_resultados.jl")


#VARIABLES
include("variables/utilidades.jl")  #Utilidades comunes de variables


#Constantes
include("variables/ftr_hosp_ctes/generador_id.jl")
include("variables/ftr_hosp_ctes/basica.jl")
include("variables/ftr_hosp_ctes/agregacion.jl")


end
