# GiantFtr

[![Build Status](https://github.com/giant-uji/GiantFtr.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/giant-uji/GiantFtr.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Estructura del proyecto

```text
src/
├── assets/
├── DAG/
├── preparacion/
├── utilidades/
└── variables/
    ├── ftr_hosp/
    │   ├── basica.jl
    │   └── agregacion.jl
    ├── ...
    └── compuestas/
        ├── motivo_valenf.jl
        └── reingresos.jl
```

## Organización

### `assets/`

Contiene archivos auxiliares necesarios para calcular algunas variables derivadas. Por ejemplo, tablas de correspondencia entre códigos CIE y su capítulo o sección.


### `DAG/`

Implementa el motor de ejecución basado en un **DAG** (**D**irected **A**cyclic **G**raph) para resolver automáticamente las dependencias entre variables.

Para más información consulta el [README de DAG](src/DAG/README.md).


### `preparacion/`

Se encarga de la **preparación** de todas las tablas antes de que sean utilizadas por el resto del proyecto.

1. Elimina columnas incorrectas (por ejemplo, reingreso7d_sn)
2. Renombra columnas para unificar la nomenclatura
3. Convierte los tipos de datos
4. Transformaciones básicas específicas de cada tabla (por ejemplo, resolver varias tomas en el mismo instante).
5. Añade `id_anonim_episodio` para que todas las tablas puedan relacionarse con el episodio.

Permite que todo el proyecto trabaje con tablas homogéneas limpias y con el mismo formato.


### `utilidades/`

Centraliza funciones comunes a todo el proyecto para evitar duplicar código.


### `variables/`

Las variables se organizan según la tabla de la base de datos de la que proceden.

```text
variables/
├── ftr_hosp/
├── ftr_hosp_codificacion/
└── ...
```

Cada carpeta suele contener dos ficheros principales:

- **`basica.jl`**: variables calculadas directamente a partir de una o pocas columnas.
- **`agregacion.jl`**: variables que requieren agrupaciones, resúmenes o cálculos sobre múltiples registros.

También pueden añadirse más ficheros para agrupar variables relacionadas o para implementar variables especialmente complejas basadas únicamente en esa tabla.


#### `variables/compuestas/`

Contiene variables que utilizan información procedente de varias tablas.


## Filosofía del proyecto

La idea es que añadir una nueva variable consista únicamente en implementar su lógica y declarar de qué otras variables depende. El sistema DAG se encarga automáticamente de calcular el orden de ejecución.

Esta organización permite mantener separadas las responsabilidades de preparación de datos, utilidades comunes y cálculo de variables.