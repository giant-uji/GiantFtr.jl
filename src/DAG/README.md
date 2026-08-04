# DAG

Se ha creado un motor de ejecución con resolución automática de dependencias basado en un grafo dirigido acíclico, para los amigos, **DAG** (**D**irected **A**cyclic **G**raph).

A la hora de ejecutar funciones el DAG resuelve automáticamente las dependencias y las ejecuta en el orden correcto. Además, almacena los resultados intermedios para evitar recalcular funciones ya ejecutadas.

Se ha diseñado el DAG para que las funciones también puedan ejecutarse manualmente, sin necesidad de utilizar el propio DAG, si alguien lo prefiere. No obstante, no es recomendable, ya que, a medida que aumente el número de dependencias, gestionarlas manualmente resultará cada vez más complejo y tedioso.

**AVISO**: Es posible que en un futuro sea necesario evolucionar el DAG según las necesidades.

---

# Funcionamiento

El algoritmo es una función recursiva con **memoization**. Antes de ejecutar la función solicitada llama a las dependencias recursivamente.

Cuando se solicita la ejecución de una función, el DAG:

1. Resuelve recursivamente todas las dependencias reutilizando los resultados ya calculados (memoization)
2. Llama a la función que se quería llamar pasándole los resultados necesarios
3. Almacena los resultados en el **contexto** para reutilización en un futuro (memoization)
4. Registra las funciones ya ejecutadas para evitar ejecutarlas más de una vez

En modo **DEBUG** se valida el registro y se detectan dependencias cíclicas antes de la primera ejecución.

---

# Registrar una función

Cada función debe registrarse mediante `registrar!`

Una función que **produce** un nuevo `DataFrame`:

```julia
function get_ftr_hosp_codificacion()::DataFrame
    ...
end

registrar!(
    get_ftr_hosp_codificacion;  #Función que se registra
    produce = CODIFICACION      #Valor del enum Tabla
)
```

Una función que tiene **dependencias** de otras funciones y **extiende** datos:

```julia
function get_charlson(
    episodio::DataFrame,
    codificacion::DataFrame
)::DataFrame

    ...
end

registrar!(
    get_charlson; #Función que se registra
    dependencias = [get_ftr_hosp, get_ftr_hosp_codificacion], #Listado de funciones de las que se depende
    usa = [EPISODIOS, CODIFICACION],  #Listado de enum Tabla de entrada (el orden debe corresponder con los parámetros de la función)
    extiende = (EPISODIOS, :id_anonim_episodio) #Tabla a extender y clave primaria del JOIN
)
```

---

# Ejecutar el DAG

```julia
dag = DAG()

ejecutar!(dag, charlson)

episodios = dag.contexto[EPISODIOS]
```

También pueden ejecutarse varias funciones simultáneamente:

```julia
dag = DAG()

ejecutar!(
    dag,
    [
        charlson,
        edad,
        sexo
    ]
)

episodios = dag.contexto[EPISODIOS]
```

Las dependencias comunes únicamente se ejecutarán una vez.

---

# Flujo de ejecución

Supongamos el siguiente registro:

```text
get_charlson
    └── get_ftr_hosp
    └── get_ftr_hosp_codificacion
```

Al ejecutar:

```julia
ejecutar!(dag, get_charlson)
```

el DAG realiza automáticamente:

```text
get_ftr_hosp() -> Obtiene EPISODIOS
        ↓
get_ftr_hosp_codificacion() -> Obtiene CODIFICACION
        ↓
get_charlson(EPISODIOS, CODIFICACION)
```

Si posteriormente otra variable también depende de `get_ftr_hosp`, esta no volverá a ejecutarse durante la misma ejecución del DAG. En el fichero de **config.jl** hay una opción para evitar vaciar el DAG entre ejecuciones.

---

# Reglas

* Registrar mediante  `registrar!` aquellas funciones que se quieran usar para generar datasets
* Cada función debe indicar exactamente una salida (`produce` o `extiende`)
* No deben haber ciclos de dependencias se debe generar un DAG (existe validación en DEBUG)
* El orden de las tablas utilizadas como entrada (`usa`) debe ser el mismo que el de los parámetros de la función registrada
* Las funciones indicadas en `dependencias` deben generar o completar toda la información necesaria para las tablas indicadas en `usa`