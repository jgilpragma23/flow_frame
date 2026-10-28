## Sin publicar

* `WRScaffold`: se quitó la línea entre el rail o sidebar y el contenido.
* `WRNavStyle`: `shadow` y `shadowColor` para una sombra opcional que separa la navegación del contenido.

## 0.0.1 - 2026-10-28

* Breakpoints `xs`/`sm`/`md`/`lg`/`xl`, configurables con `WRBreakpoints.current`.
* `WRValue<T>`: valores por breakpoint con cascada mobile-first.
* `WRSpacing`: padding y margin responsive con `all`, ejes y lados.
* `WRStyle`: estilos reutilizables con `merge`, `toTextStyle` y `resolve`.
* `WRColor`: colores fijos o con versión clara y oscura, según el `Theme` de la app.
* `WRContainer`: contenedor con ancho máximo centrado.
* `WRFlex`: fila o columna con dirección, separación y alineación por breakpoint; en horizontal arma filas y baja lo que no cabe.
* `WRItem`: elemento con `col`, `fill`, `order` y `style`; los ocultos no dejan separación.
* `WRScaffold`: `Scaffold` con navegación por breakpoint (barra abajo, rail, drawer o enlaces en el app bar con grupos en dropdown), ruta por `id` (`currentRoute`/`onRouteSelected`), subrutas en acordeón, destinos con `visible` por breakpoint y `WRNavStyle` en cascada para tipo, menú del rail encima (`overlay`) o como `sidebar`, grupos siempre abiertos y colores; el menú se abre desde código con `WRScaffold.of(context)`.
* `WRActions` y `WRAction`: acciones que por breakpoint se ven con ícono y texto, solo ícono, dentro del menú ⋮ u ocultas.
