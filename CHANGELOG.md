## 0.0.8 - 2026-10-30

* **Cambio**: `FFStyle.backgroundColor` ahora es un `FFValue<FFColor>`, así el fondo cambia por breakpoint. Para migrar, envuelve el color: `backgroundColor: AppColors.surface` pasa a `backgroundColor: FFValue(xs: AppColors.surface)`.

## 0.0.7 - 2026-10-30

* `FFStyle.shadow`: sombra por breakpoint (`List<BoxShadow>`), también en `WRResolvedStyle`. `FFShadow` trae `sm`, `md`, `lg` y `none`, como `shadow-sm`, `shadow` y `shadow-lg` de Bootstrap.
* `FFStyle.backgroundImage`: imagen de fondo por breakpoint (`DecorationImage`), encima de `backgroundColor`.
* `FFStyle.borderRadius`, `borderWidth` y `borderColor`: esquinas y borde por breakpoint. El radio recorta el contenido y el borde se suma al padding; sin `borderColor` usa `outlineVariant` del tema.

## 0.0.6 - 2026-10-30

* **Cambio**: `FFFlex.direction` ahora recibe un `FFDirection` en vez de un `Axis`: `horizontal`, `horizontalReverse`, `vertical` y `verticalReverse` (como `flex-row`, `flex-row-reverse`, `flex-column` y `flex-column-reverse`). Para migrar, cambia `Axis.horizontal` por `FFDirection.horizontal` y `Axis.vertical` por `FFDirection.vertical`.

## 0.0.5 - 2026-10-30

* `FFStyle.maxHeight`: alto máximo por breakpoint, también en `WRResolvedStyle`.
* **Cambio**: `FFFlex` es horizontal por defecto, como un `row` de Bootstrap, y un hijo sin `col` ni `fill` (o que no es un `FFItem`) ocupa la fila completa. Así `col` funciona sin escribir `direction`, y los `FFFlex` sin `col` se siguen viendo apilados. Para que un elemento tome su tamaño natural en una fila, usa `fill: FFValue(...: false)` (`col-auto`). La vertical queda para cuando importa el alto: `fill` en altura y alineación vertical.

## 0.0.4 - 2026-10-29

* `FFAppBar`: app bar responsive que se usa en cualquier `Scaffold`, sin `FFScaffold`. Marca, título, enlaces con grupos en dropdown y acciones (`FFAction`), con `FFAppBarStyle` por breakpoint: `visible`, `showBrand`, `showTitle`, `centerTitle`, colores y elevación. Dentro de un `FFScaffold` recibe la marca, los destinos y los colores que no defina.
* README: índice de lo que trae la librería, instalación, ejemplo completo e imágenes en xs, md y lg de cada tema.
* Ejemplo: sección "Librería" con una página para estilos, espaciado, colores, contenedor y app bar.

## 0.0.3 - 2026-10-29

* `FFScaffold`: el rail y el sidebar ocupan toda la altura y el app bar queda solo sobre el contenido. El ☰ y el encabezado del menú se alinean con el app bar.

## 0.0.2 - 2026-10-29

* **Cambio de nombre**: el paquete ahora es `flow_frame` (`import 'package:flow_frame/flow_frame.dart'`) y las clases usan el prefijo `FF` en vez de `WR` (`FFScaffold`, `FFValue`, `FFNavStyle`...).
* `FFScaffold`: se quitó la línea entre el rail o sidebar y el contenido.
* `FFNavStyle`: `shadow` y `shadowColor` para una sombra opcional que separa la navegación del contenido.
* `FFBrand` y `FFScaffold.brand`: logo y nombre de la app junto al ☰, acomodados según la navegación (encabezado del menú, rail, drawer o app bar).

## 0.0.1 - 2026-10-28

* Breakpoints `xs`/`sm`/`md`/`lg`/`xl`, configurables con `WRBreakpoints.current`.
* `FFValue<T>`: valores por breakpoint con cascada mobile-first.
* `FFSpacing`: padding y margin responsive con `all`, ejes y lados.
* `FFStyle`: estilos reutilizables con `merge`, `toTextStyle` y `resolve`.
* `FFColor`: colores fijos o con versión clara y oscura, según el `Theme` de la app.
* `FFContainer`: contenedor con ancho máximo centrado.
* `FFFlex`: fila o columna con dirección, separación y alineación por breakpoint; en horizontal arma filas y baja lo que no cabe.
* `FFItem`: elemento con `col`, `fill`, `order` y `style`; los ocultos no dejan separación.
* `FFScaffold`: `Scaffold` con navegación por breakpoint (barra abajo, rail, drawer o enlaces en el app bar con grupos en dropdown), ruta por `id` (`currentRoute`/`onRouteSelected`), subrutas en acordeón, destinos con `visible` por breakpoint y `FFNavStyle` en cascada para tipo, menú del rail encima (`overlay`) o como `sidebar`, grupos siempre abiertos y colores; el menú se abre desde código con `FFScaffold.of(context)`.
* `FFActions` y `FFAction`: acciones que por breakpoint se ven con ícono y texto, solo ícono, dentro del menú ⋮ u ocultas.
