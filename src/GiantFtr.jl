module GiantFtr

using DataFrames
using LibPQ: Connection                 #Acceder a DB
using JSON: parsefile                   #Leer fichero de credenciales
using CSV                               #Cargar fichero CSV
using Base.Filesystem: isfile           #Comprobar si existe fichero
using Dates: DateTime, Millisecond      #Columnas tipo Fecha
using CategoricalArrays: categorical    #Columnas tipo Categorica (optimizacion)

include("utilidades/conexion_bbdd.jl")

#PREPARACION (carga datos, tipo columnas y limpieza)
include("preparacion/ftr_hosp.jl")
include("preparacion/ftr_hosp_valenf.jl")
include("preparacion/ftr_hosp_codificacion.jl")
include("preparacion/ftr_hosp_interconsultas.jl")
include("preparacion/ftr_hosp_int_quirurgicas.jl")
include("preparacion/ftr_hosp_traslados.jl")
include("preparacion/ftr_hosp_ctes.jl")

#FALTA: Laboratorio y resultados
#Falta: URGENCIAS (de lo anterior)

end
