# Guía de Instalación y Ejecución - Parte 4 y 5 (MongoDB)

Esta carpeta contiene la solución para la **Parte 4 (Schema y Datos)** y la **Parte 5 (Consultas)** del obligatorio utilizando MongoDB.

## Requisitos Previos

Para ejecutar la solución, solo necesitas tener instalado **Node.js** en tu sistema (versión 16 o superior). No es necesario tener un servidor de MongoDB instalado localmente, ya que el script utiliza `mongodb-memory-server` para levantar uno temporal en memoria durante la ejecución.

## Instalación de Dependencias

Antes de ejecutar los scripts por primera vez, debes instalar las dependencias necesarias. Abre tu terminal, colócate dentro de esta carpeta (`parte4`) y ejecuta:

```bash
npm install
```

Esto instalará:
- `mongodb`: El driver nativo de Node.js para conectarse y operar con la base de datos.
- `mongodb-memory-server`: Para levantar el servidor MongoDB temporal en memoria.

## Ejecución del Proyecto

Para correr la creación de colecciones, la carga de datos de prueba y las consultas, simplemente ejecuta:

```bash
node ejecutar_todo.js
```

### ¿Qué hace este comando?

1. Levanta un servidor de MongoDB local en memoria.
2. Ejecuta la lógica de **`parte4_schema_mongodb.js`**: Crea las colecciones `eventos` y `agentes_analytics` con sus respectivos validadores avanzados e índices.
3. Ejecuta la lógica de **`parte4_datos_prueba.js`**: Carga datos coherentes con la base en Oracle, insertando documentos variados y eventos simulados (decisiones e interacciones).
4. Ejecuta la lógica de **`parte5_consultas_mongodb.js`**: Realiza y muestra el output de los 3 requerimientos del obligatorio (top de agentes, eventos críticos, desglose por franjas horarias).
5. Finalmente, apaga el servidor en memoria.

> **Nota Técnica:** Se reescribió el archivo ejecutor original (`ejecutar_todo.js`) para que utilice el driver nativo de Node.js (`MongoClient`) en lugar de invocar a `mongosh` como un subproceso. Esto soluciona un problema conocido donde `mongosh` se colgaba (Timeout) al intentar procesar validadores complejos (`$jsonSchema`) directamente en memoria.
