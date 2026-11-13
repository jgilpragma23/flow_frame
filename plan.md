# Plan de refactorizacion modular de Flow Frame

## Objetivo

Permitir que cada consumidor incorpore solo las capacidades que necesita
(por ejemplo, breakpoints y grilla, colores, navegacion o una combinacion),
sin que la API publica obligue a adoptar `FFStyle` ni el conjunto completo de
widgets. La refactorizacion se plantea como una nueva API con cambios
incompatibles, segun la decision del usuario.

## Diagnostico actual

- [lib/flow_frame.dart](lib/flow_frame.dart) exporta todos los modelos,
  widgets, utilidades y enums desde una sola entrada.
- [lib/src/models/ff_style.dart](lib/src/models/ff_style.dart) combina
  tipografia, color, padding/margin, decoracion, dimensiones y visibilidad.
- [lib/src/utils/ff_style_builder.dart](lib/src/utils/ff_style_builder.dart)
  traduce ese estilo compuesto en varios widgets Flutter.
- [lib/src/molecules/ff_flex.dart](lib/src/molecules/ff_flex.dart) consume
  `FFItem`, valores responsivos, extensiones de `BuildContext` y el constructor
  de estilos.
- [lib/src/atoms/ff_item.dart](lib/src/atoms/ff_item.dart) une las propiedades
  de grilla (`col`, `fill`, `order`) con `FFStyle`.
- [lib/src/models/ff_color.dart](lib/src/models/ff_color.dart) es un modelo de
  color reutilizable, pero su uso queda asociado a estilos y widgets compuestos.
- [lib/src/models/breakpoint.dart](lib/src/models/breakpoint.dart) y
  [lib/src/utils/context_extensions.dart](lib/src/utils/context_extensions.dart)
  proveen la base responsiva; la configuracion actual de breakpoints es global.
- La guia y las pruebas usan mayormente la entrada agregada
  `package:flow_frame/flow_frame.dart`, por lo que no verifican que cada
  capacidad se pueda importar de forma aislada.

## Direccion propuesta

Mantener inicialmente un solo paquete pub, con bibliotecas publicas por
capacidad. Esto desacopla imports y composicion sin introducir de inmediato
costos de versionado y publicacion de varios paquetes. Crear paquetes pub
separados seria una decision posterior si tambien se necesita instalar cada
capacidad como dependencia independiente.

Entradas publicas propuestas:

| Biblioteca | Responsabilidad | Dependencias permitidas |
|---|---|---|
| `responsive.dart` | Breakpoints, valores responsivos y acceso al contexto | Base Flutter |
| `grid.dart` | Layout de filas/columnas e items | `responsive.dart` |
| `colors.dart` | Colores fijos/adaptativos y su aplicacion independiente | Base Flutter |
| `containers.dart` | Contenedores y restricciones de ancho | Base Flutter |
| `styling.dart` | Composicion opcional de tipografia, espaciado y decoracion | `responsive.dart`, `colors.dart` |
| `navigation.dart` | Navegacion adaptable, app bar y acciones | Solo capacidades que use efectivamente |
| `flow_frame.dart` | Barrel de conveniencia que reexporta todo | Todas las capacidades |

Las dependencias deben fluir desde capacidades concretas hacia la base
responsiva; ninguna biblioteca de capacidad debe importar el barrel agregado.
La grilla y `FFContainer` deben poder usarse sin `FFStyle`, y `FFColor` debe
poder usarse sin `FFScaffold` ni `FFStyle`. Para combinar estilos con widgets
sin acoplar la grilla, se usan los adaptadores opcionales `FFStyled` y
`FFStyledItem`. El estilo compuesto puede seguir existiendo como una facilidad
opcional para quien quiera combinar todo.

Antes de implementar, decidir y documentar si los breakpoints se mantienen
globales o pasan a ser configurables por subarbol mediante un scope. Se
recomienda un scope para evitar estado global y facilitar pruebas/varias areas
de layout; los valores por defecto actuales deben permanecer como fallback.

## Fases y tareas

### Fase 1 — Inventario y contratos de modulos

- [x] Inventariar API publica, imports internos, ejemplos y usos de cada campo
  de `FFStyle`, `FFItem` y `FFScaffold`.
- [x] Definir los contratos de `responsive.dart`, `grid.dart`, `colors.dart`,
  `styling.dart` y `navigation.dart`, incluyendo dependencias permitidas.
- [x] Cerrar la decision sobre alcance de configuracion de breakpoints y
  documentar el impacto de la nueva API incompatible.

**Salida:** mapa de dependencias y lista final de simbolos exportados por cada
biblioteca.

### Fase 2 — Extraer la base responsiva

- [x] Aislar `BreakpointEnum`, `FFBreakpoints`, `FFValue` y el acceso al
  breakpoint en la biblioteca publica responsiva.
- [x] Evitar que estos tipos dependan de estilos, grilla, colores o navegacion.
- [x] Si se adopta configuracion por scope, implementar el scope y cambiar los
  consumidores internos para resolver breakpoints desde el mismo mecanismo.
- [x] Añadir pruebas unitarias para cascada, limites, configuracion y contexto.

**Salida:** un consumidor puede resolver breakpoints/valores responsivos sin
importar widgets compuestos.

### Fase 3 — Desacoplar grilla y colores

- [x] Separar de `FFItem` las responsabilidades de columna, relleno, orden y
  presentacion; la API de grilla no debe requerir un estilo.
- [x] Eliminar la dependencia de `FFFlex` con `buildFFStyle`; el layout conserva
  direccion, wrap, gap, alineacion, orden y ocultamiento propios de grilla.
- [x] Exponer `FFColor` en `colors.dart` y permitir aplicar colores sin
  construir `FFStyle`.
- [x] Mantener pruebas de layout y color en suites separadas y sumar pruebas de
  composicion cuando ambas capacidades se usan juntas.

**Salida:** importaciones independientes para grilla responsiva y colores.

### Fase 4 — Convertir estilo y widgets compuestos en opt-in

- [x] Dividir el modelo de estilo segun responsabilidades (texto, espaciado,
  decoracion/tamano) y definir una capa opcional que los combine.
- [x] Adaptar `FFContainer`, `FFAppBar`, `FFActions` y `FFScaffold` para que
  dependan solo de las capacidades que utilizan.
- [x] Mantener `FFStyle` solo como API de composicion si simplifica los casos
  existentes; no exigirlo en widgets de layout o color.
- [x] Crear los barrels por capacidad y ajustar `flow_frame.dart` para ser la
  entrada agregada de conveniencia.
- [x] Revisar los barrels internos para que no reexporten accidentalmente
  capacidades ajenas.

**Salida:** cada import publico refleja una capacidad clara, sin ciclos ni
dependencias del barrel general.

### Fase 5 — Verificacion, migracion y versionado

- [x] Convertir/añadir pruebas para cada biblioteca publica usando imports
  especificos, no solo el import agregado.
- [x] Validar mediante pruebas los tres escenarios: responsividad/grilla sin estilos,
  color sin navegacion y uso combinado.
- [x] Actualizar [README.md](README.md), el ejemplo y las instrucciones de
  migracion con las nuevas rutas de import y equivalencias de API.
- [x] Ejecutar `flutter analyze` y `flutter test`; corregir regresiones de
  comportamiento responsivo, colores, estilos y navegacion.
- [x] Dejar la version del paquete y `CHANGELOG.md` sin cambios; la API aun no
  esta publicada y su versionado se definira mas adelante.

**Salida:** ejemplos funcionales, suite completa verde y guia de migracion
validada contra la nueva API.

## Avance de ejecucion

- Implementados los imports por capacidad y el barrel agregado.
- `FFBreakpointScope` reemplaza la configuracion global `FFBreakpoints.current`;
  permite valores por subarbol y conserva los umbrales por defecto.
- `FFFlex`, `FFItem` y `FFContainer` ya no reciben `FFStyle`. La composicion se
  hace con `FFStyled`/`FFStyledItem`, y la visibilidad de grilla es una propiedad
  de `FFItem`.
- `FFTextStyle`, `FFDecorationStyle` y `FFLayoutStyle` separan tipografia,
  decoracion y layout; `FFStyle.compose` las agrega y `FFStyled` permite
  aplicarlas por separado. `FFStyledItem.compose` las combina con una columna.
- README y ejemplos migrados a las nuevas entradas y composicion.
- Verificadas con pruebas las importaciones publicas por separado, la
  aplicacion de componentes de estilo independientes y la composicion.
- `flutter test`: 219 pruebas pasan.
- `flutter analyze` no reporta errores de codigo; termina con 7 lints
  informativos en
  `ff_color.dart` y `ff_flex.dart`.
- El ejemplo se compilo y verifico en el navegador en escritorio y movil; las
  paginas principal y de colores no reportaron errores de runtime. Las pruebas
  cubren las capacidades aisladas y su composicion.
- En una ejecucion anterior se corrigio un desbordamiento de las tarjetas de
  ejemplo (80 px a 100 px). El hot reload de esta version en Web Server fue
  exitoso.
- No se modificaron `pubspec.yaml`, `pubspec.lock` ni `CHANGELOG.md`.

No quedan tareas de implementacion pendientes en el alcance de este plan. La
validacion visual del navegador se realizo en escritorio y movil; la cobertura
de imports y composicion se mantiene en las pruebas automatizadas.

## Criterios de aceptacion

1. Se puede importar grilla/responsividad sin importar la biblioteca de estilos
   o navegacion.
2. Se puede importar y aplicar colores sin `FFStyle` ni `FFScaffold`.
3. La entrada agregada permite combinar todas las capacidades y mantiene una
   experiencia de uso sencilla.
4. No hay ciclos entre bibliotecas publicas ni imports internos del barrel
   agregado.
5. Se conservan las reglas actuales de cascada y comportamiento visual salvo
   cambios documentados como parte de la nueva API.
6. Cada capacidad tiene pruebas que compilan contra su import publico
   independiente; `flutter test` pasa y `flutter analyze` no reporta errores
   (puede seguir mostrando los lints informativos ya existentes).
7. La reestructuración debe mantener prácticas de clean code y seguir los principios SOLID en donde haga falta.

## Riesgos y decisiones pendientes

- Separar modelos puede crear demasiadas abstracciones: dividir solo cuando
  exista una frontera de responsabilidad y un caso de uso independiente.
- Una importacion selectiva no reduce por si sola el numero de paquetes que
  pub descarga; si ese es un requisito, planificar paquetes pub separados como
  una iniciativa posterior.
- Cambiar la configuracion global de breakpoints a una configuracion por scope
  afecta a todos los widgets responsivos; resolverlo en la Fase 1 antes de
  modificar consumidores.
- La version mayor debe incluir migracion explicita para usos de `FFItem`,
  `FFStyle` y las importaciones actuales.

## Ampliacion del example (en curso)

Convertir el ejemplo en un recorrido multipantalla que sirva como catalogo
interactivo de las capacidades de la libreria, mostrando cuando se usan de
forma independiente y como se componen.

- [x] Añadir paginas dedicadas a breakpoints, grilla, tipografia y navegacion,
  manteniendo las demostraciones existentes de estilos, espaciado, colores,
  contenedores y app bar.
- [x] Explicar la diferencia entre `FFItem` y `FFStyledItem` y demostrar
  valores por breakpoint con ejemplos visibles y fragmentos de codigo.
- [x] Añadir una pagina de temas con cambio de tema claro/oscuro en vivo y
  ejemplos de `FFColor.adaptive` y `FFTextStyle`.
- [x] Hacer que la navegacion del ejemplo permita descubrir y cambiar entre
  las paginas de capacidades en escritorio y movil.
- [x] Ejecutar analisis y pruebas, y comprobar el ejemplo visualmente en mas
  de un tamano de pantalla y en ambos temas.

Resultado: `flutter test --no-pub` pasa con 219 pruebas, `flutter analyze
--no-pub` en `example/` no reporta problemas y la compilacion web finaliza.
El analisis del paquete principal conserva los 7 lints informativos ya
identificados. La verificacion en navegador cubrio grilla en escritorio,
tipografia en movil y cambio al tema oscuro; no se encontraron errores de
runtime. El hot reload fue exitoso.
