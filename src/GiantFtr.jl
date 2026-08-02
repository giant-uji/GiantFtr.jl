module GiantFtr

using DataFrames
using LibPQ                             #Acceder a DB
using JSON                              #Leer fichero de credenciales
using CSV                               #Cargar fichero CSV
using Base.Filesystem: isfile           #Comprobar si existe fichero
using Dates: DateTime, Millisecond      #Columnas tipo Fecha
using CategoricalArrays: categorical    #Columnas tipo Categorica (optimizacion)

#DEBE SER el primer include
include("config.jl")

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

end
