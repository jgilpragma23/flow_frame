## Sin publicar

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
