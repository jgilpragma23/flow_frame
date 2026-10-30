# flow_frame

Herramientas para hacer interfaces responsive en Flutter con una idea parecida a Bootstrap: breakpoints mobile-first, estilos reutilizables, colores con modo claro u oscuro y una navegación que cambia sola según el ancho de la pantalla.

![La misma pantalla de pedidos en teléfono, tablet y escritorio](doc/app.png)

## Qué trae

| | Para qué sirve | |
|---|---|---|
| [Breakpoints](#breakpoints) | `xs` `sm` `md` `lg` `xl`, mobile-first | |
| [`FFValue`](#ffvalue-un-valor-por-breakpoint) | Un valor distinto por breakpoint, en cascada | |
| [`FFSpacing`](#ffspacing-padding-y-margin) | Padding y margin por breakpoint | [imagen](#ffspacing-padding-y-margin) |
| [`FFStyle`](#ffstyle-estilos-reutilizables) | Estilos reutilizables tipo clase de CSS: texto, color, tamaño, visible | [imagen](#ffstyle-estilos-reutilizables) |
| [Colores](#colores-y-modo-oscuro) | `FFColor` con versión clara y oscura | [imagen](#colores-y-modo-oscuro) |
| [`FFContainer`](#ffcontainer) | Contenedor centrado con ancho máximo | [imagen](#ffcontainer) |
| [`FFFlex` y `FFItem`](#ffflex-y-ffitem) | Grilla de 12 columnas, filas o columnas que cambian por breakpoint | [imagen](#ffflex-y-ffitem) |
| [`FFScaffold`](#ffscaffold-navegación-según-el-breakpoint) | Barra abajo, rail, sidebar, drawer o enlaces en el app bar, según el ancho | [GIF](#ffscaffold-navegación-según-el-breakpoint) |
| [`FFBrand`](#ffscaffold-navegación-según-el-breakpoint) | Logo y nombre de la app junto al ☰ | |
| [`FFAppBar`](#ffappbar-app-bar-sin-el-layout) | App bar responsive que se usa solo, en cualquier `Scaffold`: marca, título, enlaces y acciones, y se oculta por breakpoint | [imagen](#ffappbar-app-bar-sin-el-layout) |
| [`FFActions`](#ffactions-acciones-del-app-bar) | Acciones del app bar: con texto, solo ícono, en el menú ⋮ u ocultas | [imagen](#ffactions-acciones-del-app-bar) |

## Instalación

```yaml
dependencies:
  flow_frame:
    git:
      url: https://github.com/jgilpragma23/flow_frame.git
      ref: v0.0.7
```

```dart
import 'package:flow_frame/flow_frame.dart';
```

## Ejemplo completo

Una app con navegación responsive, marca, acciones y una página en grilla. Es una versión resumida de la pantalla de la imagen de arriba; el código completo está en [`example/`](example/lib/main.dart).

```dart
class AppColors {
  static const surface = FFColor.adaptive(light: Color(0xFFF5F5F5), dark: Color(0xFF1E1E1E));
  static const primary = FFColor.adaptive(light: Color(0xFF2563EB), dark: Color(0xFF60A5FA));
  static const primarySoft = FFColor.adaptive(light: Color(0xFFDBEAFE), dark: Color(0xFF1E3A5F));
  static const muted = FFColor.adaptive(light: Color(0xFF666666), dark: Color(0xFF9E9E9E));
}

const card = FFStyle(
  padding: FFSpacing(all: FFValue(xs: 12, md: 20)),
  backgroundColor: FFValue(xs: AppColors.surface),
);

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  String _route = 'ventas/pedidos';

  @override
  Widget build(BuildContext context) {
    return FFScaffold(
      currentRoute: _route,
      onRouteSelected: (id) => setState(() => _route = id),
      destinations: const [
        FFDestination(id: 'inicio', icon: Icon(Icons.home_outlined), label: 'Inicio'),
        FFDestination(
          id: 'ventas',
          icon: Icon(Icons.storefront_outlined),
          label: 'Ventas',
          children: [
            FFDestination(id: 'ventas/pedidos', icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
            FFDestination(id: 'ventas/clientes', icon: Icon(Icons.people_outline), label: 'Clientes'),
          ],
        ),
        FFDestination(
          id: 'reportes',
          icon: Icon(Icons.bar_chart_outlined),
          label: 'Reportes',
          visible: FFValue(xs: false, md: true), // no cabe en la barra de abajo
        ),
      ],
      // Barra abajo en el teléfono, rail en tablet y sidebar en escritorio
      responsive: const FFValue(
        xs: FFNavStyle(
          type: FFNavigation.bottom,
          selectedIconColor: AppColors.primary,
          selectedBackgroundColor: AppColors.primarySoft,
        ),
        md: FFNavStyle(type: FFNavigation.rail, shadow: true),
        lg: FFNavStyle(expandMode: WRRailExpand.sidebar, expanded: true),
      ),
      brand: const FFBrand(
        logo: Icon(Icons.storefront),
        title: Text('Mi Tienda'),
        subtitle: Text('Admin'),
      ),
      appBar: FFAppBar(
        title: const Text('Pedidos'),
        actions: [
          FFAction(
            icon: const Icon(Icons.add),
            label: 'Nuevo pedido',
            onPressed: () {},
            display: const FFValue(xs: FFActionDisplay.icon, md: FFActionDisplay.full),
          ),
          FFAction(
            icon: const Icon(Icons.download_outlined),
            label: 'Exportar',
            onPressed: () {},
            display: const FFValue(xs: FFActionDisplay.menu, lg: FFActionDisplay.full),
          ),
        ],
      ),
      body: const PedidosPage(),
    );
  }
}

class PedidosPage extends StatelessWidget {
  const PedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FFContainer(
        maxSize: 1280,
        style: const FFStyle(padding: FFSpacing(all: FFValue(xs: 16, md: 32))),
        child: FFFlex(
          gap: const FFValue(xs: 16, md: 24),
          children: [
            // Resumen: 1 por fila en xs, 2 en sm, 4 desde lg
            FFFlex(
              gap: const FFValue(xs: 12, md: 16),
              children: [
                for (final (title, value) in [('Hoy', '24'), ('Semana', '183'), ('Pendientes', '7'), ('Ingresos', '\$4.2k')])
                  FFItem(
                    col: const FFValue(xs: 12, sm: 6, lg: 3),
                    style: card,
                    child: Text('$value  $title'),
                  ),
              ],
            ),
            // Lista y detalle: uno debajo del otro en xs/sm, lado a lado desde md
            FFFlex(
              direction: const FFValue(xs: FFDirection.vertical, md: FFDirection.horizontal),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                const FFItem(col: FFValue(md: 7, xl: 8), style: card, child: ListaDePedidos()),
                FFItem(
                  fill: const FFValue(md: true),
                  style: card.merge(const FFStyle(
                    backgroundColor: FFValue(xs: AppColors.primarySoft),
                    visible: FFValue(xs: false, md: true), // el detalle no se ve en el teléfono
                  )),
                  child: const DetalleDelPedido(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

Lo mismo en modo oscuro, sin cambiar nada del código (los `FFColor` eligen su versión según el `Theme`):

![La pantalla de pedidos en modo oscuro](doc/app-oscuro.png)

### Ver el ejemplo

```bash
cd example && flutter run -d chrome
```

En el menú **Librería** hay una página por tema (estilos, espaciado, colores y contenedor); de ahí salen las imágenes de este README. Achica la ventana para ver cómo cambia cada cosa.

## Breakpoints

| Nombre | Desde (px) | Uso típico |
|---|---|---|
| `xs` | 0 | Teléfono |
| `sm` | 600 | Teléfono horizontal / tablet pequeña |
| `md` | 840 | Tablet |
| `lg` | 1200 | Escritorio |
| `xl` | 1600 | Pantalla grande |

El breakpoint se calcula con el ancho de la pantalla.

```dart
if (context.breakpoint >= Breakpoint.md) { ... }
```

Para cambiar las medidas, asígnalas una vez antes de `runApp`:

```dart
void main() {
  WRBreakpoints.current = const WRBreakpoints(sm: 600, md: 900, lg: 1200, xl: 1600);
  runApp(const MyApp());
}
```

## `FFValue`: un valor por breakpoint

Cada valor aplica desde su breakpoint hacia arriba hasta que otro lo reemplace (mobile-first).

```dart
const gap = FFValue(xs: 8, md: 16); // 8 en xs/sm, 16 en md/lg/xl
const fill = FFValue(md: true);     // null en xs/sm, true desde md
const same = FFValue.all(12);       // 12 en todos

gap.resolve(context.breakpoint);
context.responsive(xs: 1, md: 2, xl: 4); // atajo
```

## `FFSpacing`: padding y margin

![Padding y margin en xs, md y lg: naranja es el margin, verde el padding y azul el contenido](doc/espaciado.png)

```dart
const FFSpacing(
  all: FFValue(xs: 8, md: 16, xl: 24),
  horizontal: FFValue(lg: 32),
  vertical: FFValue(sm: 12),
  top: FFValue(md: 20),
)
```

Para cada lado:
1. Gana el breakpoint más cercano al actual.
2. Si empatan, gana el más específico: el lado (`top`) sobre el eje (`vertical`), y el eje sobre `all`.

Con el ejemplo de arriba, el `top` vale 8 en `xs`, 12 en `sm`, 20 en `md` y `lg`, y 24 en `xl`.

## `FFStyle`: estilos reutilizables

![Texto, variantes con merge y tamaños en xs y lg](doc/estilos.png)

Funciona como una clase de CSS. Todo es opcional.

```dart
const card = FFStyle(
  padding: FFSpacing(all: FFValue(xs: 12, md: 16)),
  margin: FFSpacing(bottom: FFValue(xs: 8)),

  // Texto: textStyle es la base, lo demás va encima
  textStyle: FFValue(
    xs: TextStyle(fontSize: 14, fontFamily: 'Inter'),
    md: TextStyle(fontSize: 16),
  ),
  color: AppColors.text,
  fontWeight: FFValue(md: FontWeight.w600),
  fontSize: FFValue(xl: 18),
  lineHeight: FFValue(xs: 1.4),
  textAlign: FFValue(xs: TextAlign.center, md: TextAlign.start),

  backgroundColor: FFValue(xs: AppColors.surface, lg: AppColors.primarySoft),
  backgroundImage: FFValue(
    xs: DecorationImage(image: AssetImage('assets/fondo_movil.jpg'), fit: BoxFit.cover),
    md: DecorationImage(image: AssetImage('assets/fondo.jpg'), fit: BoxFit.cover),
  ),
  shadow: FFValue(xs: FFShadow.sm, md: FFShadow.lg), // como shadow-sm / shadow-lg
  borderRadius: FFValue(xs: 8, md: 16),
  borderWidth: FFValue(xs: 1),
  borderColor: AppColors.border, // por defecto outlineVariant del tema

  width: FFValue(md: 480),
  minWidth: FFValue(md: 320),
  maxWidth: FFValue(lg: 640),
  height: FFValue(md: 200),
  maxHeight: FFValue(xs: 240, lg: 400),

  visible: FFValue(xs: false, md: true), // como d-none d-md-block
);
```

- **`textStyle` se combina en cascada:** en `md` se juntan los `TextStyle` de `xs`, `sm` y `md`, y en cada propiedad gana el mayor. En el ejemplo, la fuente `Inter` definida en `xs` se mantiene en `md`.
- **`color`, `fontWeight`, `fontSize` y `lineHeight` ganan sobre `textStyle`.** `color` va aparte porque un `TextStyle` no sabe del modo oscuro.
- **`shadow`** recibe una `List<BoxShadow>` por breakpoint. `FFShadow` trae `sm`, `md` y `lg` (los de Bootstrap) y `none` para quitarla en un breakpoint mayor. La sombra va alrededor del fondo y del padding.
- **`backgroundColor`** es un `FFValue<FFColor>`: cambia por breakpoint y cada color sigue al modo claro/oscuro.
- **`backgroundImage`** recibe un `DecorationImage` por breakpoint (imagen, `fit`, `alignment`, opacidad…) y va encima de `backgroundColor`. Sirve para usar una imagen más liviana en el móvil.
- **`borderRadius`** redondea el fondo, la sombra y el borde, y recorta el contenido a esa forma, así una imagen sin padding queda con las esquinas redondeadas.
- **`borderWidth`** se dibuja por dentro de la caja y se suma al padding, así el contenido no queda debajo del borde.
- **`maxHeight` limita el alto pero no agrega scroll:** si el contenido es más alto, se desborda. Para una lista o un texto largo, pon adentro un `ListView` o un `SingleChildScrollView`:

```dart
FFContainer(
  style: const FFStyle(maxHeight: FFValue(xs: 240, lg: 400)),
  child: ListView(shrinkWrap: true, children: [...]),
)
```

- **`merge`** combina dos estilos; el segundo gana donde define algo:

```dart
final hiddenCard = card.merge(const FFStyle(visible: FFValue(xs: false, lg: true)));
```

### Texto

Para un texto suelto, `toTextStyle(context)` devuelve un `TextStyle` normal de Flutter:

```dart
Text('Título', style: title.toTextStyle(context))
TextField(style: title.toTextStyle(context))
```

Para varios textos, pon el estilo en un contenedor y los `Text` de adentro lo heredan:

```dart
FFContainer(
  style: const FFStyle(
    textStyle: FFValue(xs: TextStyle(fontSize: 14)),
    color: AppColors.muted,
  ),
  child: Column(
    children: [
      const Text('Línea 1'),                               // hereda
      Text('Título', style: title.toTextStyle(context)),   // hereda y title cambia lo suyo
    ],
  ),
)
```

`toTextStyle` solo trae lo que define ese estilo, por eso se combina con lo del contenedor. `TextField` no hereda el estilo del contenedor (así funciona Flutter); usa `toTextStyle` con él.

### Todos los valores calculados

`resolve(context)` devuelve un `WRResolvedStyle` con valores normales de Flutter (`EdgeInsets`, `TextStyle`, `Color`, etc.) para usar con cualquier widget:

```dart
final s = card.resolve(context);
Padding(padding: s.padding, child: ...)
```

## Colores y modo oscuro

![La misma paleta en modo claro y oscuro](doc/colores.png)

La librería no tiene tema ni paleta propia: los colores se definen en tu código. Un `FFColor` puede tener versión clara y oscura:

```dart
FFColor.adaptive(light: Color(0xFFFFF7E6), dark: Color(0xFF3A2E14))
FFColor.fixed(Color(0xFFFFFFFF)) // no cambia
```

Lo práctico es juntarlos en una clase y usarlos en los estilos:

```dart
class AppColors {
  static const surface = FFColor.adaptive(light: Color(0xFFF5F5F5), dark: Color(0xFF1E1E1E));
  static const text = FFColor.adaptive(light: Color(0xFF111111), dark: Color(0xFFF5F5F5));
  static const muted = FFColor.adaptive(light: Color(0xFF666666), dark: Color(0xFF9E9E9E));
  static const primary = FFColor.adaptive(light: Color(0xFF2563EB), dark: Color(0xFF60A5FA));
  static const primarySoft = FFColor.adaptive(light: Color(0xFFDBEAFE), dark: Color(0xFF1E3A5F));
}

const card = FFStyle(backgroundColor: FFValue(xs: AppColors.surface), color: AppColors.text);
```

Fuera de un estilo, `resolve` devuelve el `Color` del modo actual:

```dart
Scaffold(backgroundColor: AppColors.surface.resolve(context))
```

El modo claro u oscuro se lee del `Theme` de la app, así que sigue al `themeMode` de tu `MaterialApp` sin configurar nada.

## `FFContainer`

![Contenedores con maxSize 480, 800 y 1100 en xs y lg: en pantalla ancha se centran](doc/contenedor.png)

Ocupa todo el ancho hasta `maxSize` y se centra en pantallas más anchas. El `style` se aplica por dentro de ese ancho.

```dart
FFContainer(
  maxSize: 1280,
  style: const FFStyle(
    padding: FFSpacing(horizontal: FFValue(xs: 16, md: 24)),
  ),
  child: ...,
)
```

Sin `maxSize` ocupa todo el ancho.

## `FFFlex` y `FFItem`

`FFFlex` es un `row` de Bootstrap: una fila que reparte 12 columnas y baja a la siguiente fila lo que no cabe. `FFItem` es cada elemento. También puede ser vertical, en todos o en algunos breakpoints.

### Grilla: filas que se acomodan solas

![La grilla en xs, md y lg: 1, 2 y 3 productos por fila](doc/flex.png)

Por defecto es horizontal: cada hijo dice cuánto ocupa y lo que no cabe baja a la siguiente fila.

```dart
FFFlex(
  gap: const FFValue.all(16), // entre elementos y entre filas
  children: [
    for (final p in products)
      FFItem(col: const FFValue(xs: 12, md: 6, lg: 4), child: ProductCard(p)),
  ],
)
```

| Breakpoint | `col` | Resultado con 5 productos |
|---|---|---|
| `xs`, `sm` | 12 | 1 por fila, 5 filas |
| `md` | 6 | 2 por fila: 1-2, 3-4, 5 |
| `lg`, `xl` | 4 | 3 por fila: 1-2-3, 4-5 |

Cada hijo puede medirse de tres formas:

| `FFItem` | Ancho | En Bootstrap |
|---|---|---|
| `col: FFValue(md: 6)` | 6 de 12 columnas | `col-md-6` |
| `fill: FFValue(md: true)` | Lo que sobra en su fila | `col` |
| `fill: FFValue(md: false)` | Su tamaño natural | `col-auto` |
| Ninguno | La fila completa | Hijo de `.row` sin `col` |

Como un hijo sin `col` ocupa la fila completa, un `FFFlex` con hijos sin `col` los apila uno debajo del otro. Así funciona para una página, un formulario o una lista de secciones sin escribir nada más.

Se pueden mezclar en la misma fila:

```dart
FFFlex(
  gap: const FFValue.all(16),
  children: [
    FFItem(col: const FFValue(xs: 12, md: 3), child: Filtros()),
    FFItem(fill: const FFValue.all(true), child: Buscador()),
    FFItem(
      fill: const FFValue.all(false), // tamaño natural
      child: IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
    ),
  ],
)
```

Un ejemplo común: imagen al lado del texto en el teléfono y una debajo de la otra desde `md`:

```dart
FFFlex(
  children: [
    FFItem(col: const FFValue(xs: 4, md: 12), child: Imagen()),
    FFItem(col: const FFValue(xs: 8, md: 12), child: Texto()),
  ],
)
```

En `md` van los tres en una fila: filtros en 3/12, el ícono con su tamaño y el buscador con el resto. En `xs` los filtros ocupan la fila completa y el buscador y el ícono bajan a la siguiente.

Si un `FFItem` tiene `col` y `fill`, gana el que esté definido en el breakpoint más cercano al actual. Con `col: FFValue(xs: 12)` y `fill: FFValue(md: true)`: fila completa en `xs`/`sm` y lo que sobra desde `md`. Si están en el mismo breakpoint, gana `col`.

### Vertical

Con `direction: FFDirection.vertical` los elementos se apilan, ocupan todo el ancho y `col` se ignora. Úsalo cuando importa el alto:

- `fill` reparte la altura que sobra, como un `Expanded` en un `Column` (solo si el `FFFlex` tiene un alto limitado).
- `mainAxisAlignment` alinea en vertical, por ejemplo un login centrado en la pantalla o un pie empujado hasta abajo.
- Con `crossAxisAlignment: center` apila elementos de tamaño natural centrados.

```dart
FFFlex(
  direction: const FFValue.all(FFDirection.vertical),
  children: [
    const Encabezado(),
    FFItem(fill: const FFValue.all(true), child: ListView(...)), // toma el alto libre
    const BotonGuardar(),
  ],
)
```

La dirección también cambia por breakpoint, por ejemplo `FFValue(xs: FFDirection.vertical, md: FFDirection.horizontal)`.

### Invertir el orden

`FFDirection` tiene cuatro valores, como las clases de Bootstrap:

| `FFDirection` | Bootstrap | Resultado |
|---|---|---|
| `horizontal` (por defecto) | `flex-row` | Filas de 12 columnas |
| `horizontalReverse` | `flex-row-reverse` | Igual, con los hijos en orden inverso |
| `vertical` | `flex-column` | Apilados de arriba hacia abajo |
| `verticalReverse` | `flex-column-reverse` | Apilados de abajo hacia arriba |

Por ejemplo, la imagen a la izquierda en el teléfono y a la derecha desde `md`:

```dart
FFFlex(
  direction: const FFValue(xs: FFDirection.horizontal, md: FFDirection.horizontalReverse),
  children: [
    FFItem(col: const FFValue(xs: 4), child: Imagen()),
    FFItem(col: const FFValue(xs: 8), child: Texto()),
  ],
)
```

Se invierte la lista completa: en una fila el último queda a la izquierda y, si están apilados, el último queda arriba. Primero se aplica `order` y después se invierte. Al invertir, los elementos no pierden su estado.

### Referencia

**`FFFlex`**
- `direction`: un `FFDirection` por breakpoint: `horizontal` (por defecto), `horizontalReverse`, `vertical` o `verticalReverse`.
- `gap`: separación entre elementos y, en horizontal, también entre filas.
- `mainAxisAlignment`: por defecto `start`. En horizontal se aplica a cada fila.
- `crossAxisAlignment`: por defecto `stretch` en vertical (los elementos ocupan todo el ancho) y `start` en horizontal. En horizontal se aplica dentro de cada fila; `stretch` iguala la altura de la fila.
- `style`: un `FFStyle` para el contenedor.
- `children`: pueden ser `FFItem` o cualquier widget. En horizontal, un widget que no es `FFItem` ocupa la fila completa.

**`FFItem`**
- `col`: cuántas de las 12 columnas ocupa (de 1 a 12). Solo en horizontal. Sin `col` ni `fill`, ocupa la fila completa.
- `fill`: `true` hace que ocupe el espacio que sobra en su fila; si varios lo tienen, se lo reparten en partes iguales. `false`: toma su tamaño natural (`col-auto`). Puede cambiar por breakpoint, por ejemplo `FFValue(xs: false, sm: true, lg: false)`.
- `order`: posición dentro del `FFFlex`; los menores van primero (por defecto 0).
- `style`: un `FFStyle`. Con `visible: false` el elemento se quita y no deja separación.

**Detalles:**
- Cada hijo se mide una vez, como en un `Row` o un `Wrap`, así que no pesa más que ellos. Como ellos, construye todos sus hijos aunque no se vean; para listas de cientos de elementos conviene `GridView.builder`.
- Si el `FFFlex` no tiene un límite en su eje (por ejemplo, vertical dentro de un `SingleChildScrollView`), `fill` y `col` se ignoran en vez de dar error.
- Cambiar `order` o ocultar un elemento no hace perder el estado de los demás.
- Respeta `TextDirection.rtl`.
- Fuera de un `FFFlex`, `FFItem` ignora `col`, `fill` y `order` y solo aplica su `style`. Sirve como un `div` con clases.

## `FFScaffold`: navegación según el breakpoint

Funciona como un `Scaffold` (recibe `appBar`, `body`, `floatingActionButton`, `floatingActionButtonLocation` y `backgroundColor`), pero además arma la navegación según el breakpoint. El `appBar` puede ser un `AppBar` o un [`FFAppBar`](#ffappbar-app-bar-sin-el-layout).

![La app de ejemplo de 400 a 1800 px: barra abajo, rail y sidebar, con la grilla reacomodándose](doc/responsive.gif)

```dart
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _route = 'inicio';

  @override
  Widget build(BuildContext context) {
    return FFScaffold(
      appBar: AppBar(title: const Text('Mi app')),
      currentRoute: _route,
      onRouteSelected: (id) => setState(() => _route = id),
      destinations: const [
        FFDestination(id: 'inicio', icon: Icon(Icons.home_outlined), label: 'Inicio'),
        FFDestination(
          id: 'ventas',
          icon: Icon(Icons.storefront_outlined),
          label: 'Ventas',
          children: [
            FFDestination(id: 'ventas/pedidos', icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
            FFDestination(id: 'ventas/clientes', icon: Icon(Icons.people_outline), label: 'Clientes'),
          ],
        ),
        // Solo desde md
        FFDestination(
          id: 'reportes',
          icon: Icon(Icons.bar_chart_outlined),
          label: 'Reportes',
          visible: FFValue(xs: false, md: true),
        ),
        // Grupo siempre abierto, sin flecha
        FFDestination(
          id: 'config',
          icon: Icon(Icons.settings_outlined),
          label: 'Configuración',
          alwaysOpen: true,
          children: [
            FFDestination(id: 'config/perfil', icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
        ),
      ],

      // Cada breakpoint pone solo lo que cambia; el resto lo hereda
      responsive: const FFValue(
        xs: FFNavStyle(
          type: FFNavigation.bottom,
          backgroundColor: AppColors.surface,
          iconColor: AppColors.muted,
          labelColor: AppColors.muted,
          selectedBackgroundColor: AppColors.primarySoft,
          selectedIconColor: AppColors.primary,
          selectedLabelColor: AppColors.primary,
        ),
        md: FFNavStyle(type: FFNavigation.rail, expandMode: WRRailExpand.overlay),
        lg: FFNavStyle(expandMode: WRRailExpand.sidebar, expanded: true),
      ),

      body: pages[_route]!,
    );
  }
}
```

| Breakpoint | Con el ejemplo de arriba |
|---|---|
| `xs`, `sm` | Barra abajo con los colores de `xs`, sin Reportes |
| `md` | Rail de íconos; ☰ abre el menú completo encima del contenido |
| `lg`, `xl` | Menú completo abierto como sidebar, que empuja el contenido |

**`FFNavStyle`**

| Campo | Qué hace |
|---|---|
| `type` | `FFNavigation.bottom`, `rail`, `drawer` o `appBar` |
| `expandMode` | Con rail, cómo se abre el menú completo: `WRRailExpand.overlay` o `sidebar` |
| `expanded` | Con `sidebar`, si el menú empieza abierto |
| `subRoutesAlwaysVisible` | Todos los grupos siempre abiertos, sin flecha |
| `backgroundColor` | Fondo de la barra, el rail y el menú; con `appBar`, fondo del app bar si este no tiene uno |
| `iconColor`, `labelColor` | Íconos y textos sin seleccionar |
| `selectedBackgroundColor` | Fondo del destino seleccionado |
| `selectedIconColor`, `selectedLabelColor` | Ícono y texto del destino seleccionado |
| `shadow` | Sombra que separa la navegación del contenido: a la derecha del rail y del sidebar, y arriba de la barra. Por defecto no hay |
| `shadowColor` | Color de la sombra; por defecto uno suave según el modo claro u oscuro |

- `responsive` funciona en cascada, como `FFStyle`: `lg` del ejemplo sigue siendo `rail` y usa los colores de `xs`.
- Los colores son `FFColor`, así que cambian solos en modo oscuro. Los que no pongas usan los del `Theme`.
- Lo que no definas sale de `FFScaffold.defaults`: barra abajo en `xs`/`sm`, rail con `overlay` en `md` y `sidebar` abierto desde `lg`.

**Tipos de navegación (`FFNavigation`)**
- `bottom`: barra abajo con íconos y textos (`NavigationBar`).
- `rail`: barra lateral de íconos con un botón ☰ arriba que abre el menú completo (íconos, textos y subrutas).
- `drawer`: menú oculto que sale desde el lado al tocar ☰ en el app bar; se cierra al elegir una opción. Si no pasas `appBar`, se pone uno vacío para que exista el botón.
- `appBar`: enlaces dentro del app bar, después del título, como en un sitio web. Un grupo es un botón con ▾ que abre un dropdown con sus subrutas. Pensado para `md` en adelante: en pantallas angostas los enlaces que no caben se desplazan de lado. Tu `AppBar` conserva su título, `leading` y `actions`; si pasas otro `PreferredSizeWidget`, los enlaces van en una franja debajo.

```dart
responsive: const FFValue(
  xs: FFNavStyle(type: FFNavigation.bottom),
  md: FFNavStyle(type: FFNavigation.appBar),
),
```

**Cómo se abre el menú desde el rail (`WRRailExpand`)**
- `overlay`: el menú sale encima del contenido, como un drawer, con fondo oscuro. Se cierra al elegir una opción o al tocar fuera.
- `sidebar`: el rail se ensancha y empuja el contenido. Queda abierto hasta cerrarlo con ☰.

**Subrutas (`children`)**
- Un destino con `children` es un grupo: no es una página, solo agrupa. Un solo nivel.
- En el menú completo (sidebar, overlay y drawer) se muestra como acordeón. El grupo que tiene la ruta actual se abre solo.
- `alwaysOpen: true` deja ese grupo abierto y sin flecha; tiene prioridad sobre `subRoutesAlwaysVisible`.
- En el app bar, cada grupo es un dropdown con sus subrutas.
- En la barra abajo y en el rail cerrado solo se ven los grupos. En la barra, tocar un grupo lleva a su última subruta visitada (o a la primera). En el rail cerrado, abre el menú con ese grupo desplegado.

**Destinos por breakpoint**
- `visible: FFValue(...)` oculta un destino o una subruta en los breakpoints que digas. Un grupo sin subrutas visibles se oculta.

**Marca: logo y nombre junto al ☰**

```dart
FFScaffold(
  brand: FFBrand(
    logo: Image.asset('assets/logo.png'),
    title: const Text('Mi Tienda'),
    subtitle: const Text('Admin'),       // opcional, solo en el menú
    onTap: () => context.go('/'),        // opcional
  ),
  ...
)
```

Se define una vez y cada navegación la acomoda:

| Navegación | Dónde va |
|---|---|
| sidebar y overlay | `☰ [logo] Mi Tienda / Admin` en el encabezado del menú |
| rail cerrado | solo el logo, debajo del ☰ |
| drawer | `☰ [logo] Mi Tienda` en el app bar, y la marca completa arriba del drawer (`showInDrawer: false` la quita de ahí) |
| appBar | `[logo] Mi Tienda` antes de los enlaces |
| bottom | `[logo] Mi Tienda` en el app bar |

En el app bar solo se usa si el `AppBar` no tiene `title`: el título propio siempre manda. El logo se ajusta a 28 px (32 en el rail y arriba del drawer).

**Abrir el menú desde código**
- `FFScaffold.of(context)` da `openMenu()`, `closeMenu()`, `toggleMenu()` e `isMenuOpen`. Sirve para el rail y el drawer.

**Detalles**
- Se usa un solo tipo por breakpoint.
- El rail y el sidebar ocupan toda la altura de la pantalla, desde arriba. El `appBar` queda solo sobre el contenido, a su lado, y el ☰ se alinea con su título. El overlay se abre encima de todo, app bar incluido.
- Si el usuario abre o cierra el menú con ☰, se respeta mientras siga en el mismo breakpoint. Al cambiar de breakpoint vuelve al valor de `expanded`.
- La ruta actual (`currentRoute`) no cambia al cambiar de navegación.

## `FFActions`: acciones del app bar

![El app bar en xs, md y lg: las acciones pasan de ícono a texto y al menú ⋮](doc/acciones.png)

Cada acción decide por breakpoint si se ve con ícono y texto, solo con ícono, dentro del menú ⋮ o si no aparece. Va en `AppBar.actions` (con o sin `FFScaffold`) o en cualquier fila.

```dart
AppBar(
  title: const Text('Pedidos'),
  actions: [
    FFActions(
      actions: [
        FFAction(
          icon: const Icon(Icons.add),
          label: 'Nuevo pedido',
          onPressed: _nuevo,
          display: const FFValue(xs: FFActionDisplay.icon, md: FFActionDisplay.full),
        ),
        FFAction(
          icon: const Icon(Icons.download_outlined),
          label: 'Exportar',
          onPressed: _exportar,
          display: const FFValue(xs: FFActionDisplay.menu, lg: FFActionDisplay.full),
        ),
        FFAction(
          icon: const Icon(Icons.print_outlined),
          label: 'Imprimir',
          onPressed: _imprimir,
          display: const FFValue(xs: FFActionDisplay.hidden, md: FFActionDisplay.menu),
        ),
      ],
    ),
  ],
)
```

| | Nuevo pedido | Exportar | Imprimir |
|---|---|---|---|
| `xs`, `sm` | Ícono | En ⋮ | No aparece |
| `md` | Ícono y texto | En ⋮ | En ⋮ |
| `lg`, `xl` | Ícono y texto | Ícono y texto | En ⋮ |

**`FFActionDisplay`**
- `full`: ícono y texto, como botón.
- `icon`: solo el ícono; el texto queda como tooltip.
- `menu`: dentro del menú ⋮, con ícono y texto.
- `hidden`: no se muestra.

**Detalles**
- `display` funciona en cascada. Sin `display`, la acción se muestra solo con el ícono.
- El ⋮ aparece solo si alguna acción está en `menu` en ese breakpoint. `menuIcon` y `menuTooltip` cambian su ícono y su tooltip.
- `onPressed: null` muestra la acción deshabilitada.

## `FFAppBar`: app bar sin el layout

![Tres FFAppBar en xs, md y lg: marca y enlaces, título con marca y uno que se oculta en xs](doc/app-bar.png)

Un app bar responsive que va en el `appBar` de cualquier `Scaffold`, sin `FFScaffold`. Sirve si ya tienes tu propio layout (por ejemplo con go_router) y solo quieres que el app bar se adapte al ancho.

```dart
Scaffold(
  appBar: FFAppBar(
    brand: const FFBrand(logo: Icon(Icons.storefront), title: Text('Mi Tienda')),
    title: const Text('Pedidos'),
    destinations: links,              // opcional: enlaces y grupos con dropdown
    currentRoute: 'inicio',
    onRouteSelected: (id) => context.go('/$id'),
    actions: [
      FFAction(icon: const Icon(Icons.search), label: 'Buscar', onPressed: _buscar),
      FFAction(
        icon: const Icon(Icons.shopping_cart),
        label: 'Carrito',
        onPressed: _carrito,
        display: const FFValue(xs: FFActionDisplay.icon, lg: FFActionDisplay.full),
      ),
    ],
    responsive: const FFValue(
      xs: FFAppBarStyle(showBrand: false, centerTitle: true),
      md: FFAppBarStyle(showBrand: true, centerTitle: false),
    ),
  ),
  body: ...,
)
```

| Parámetro | Para qué |
|---|---|
| `brand` | Logo y nombre de la app, al inicio |
| `title` | Después de la marca, separado por una línea. Por ejemplo, el nombre de la página |
| `actions` | `FFAction` que cambian de forma por breakpoint, como en [`FFActions`](#ffactions-acciones-del-app-bar) |
| `trailing` | Widgets después de las acciones, por ejemplo un avatar |
| `destinations`, `currentRoute`, `onRouteSelected` | Enlaces después del título, con grupos en dropdown. Respetan `FFDestination.visible`. Sin `onRouteSelected` no se muestran |
| `leading`, `automaticallyImplyLeading`, `bottom`, `toolbarHeight` | Como en `AppBar` |
| `responsive` | `FFValue<FFAppBarStyle>`, en cascada |

**`FFAppBarStyle`**

| Propiedad | Qué cambia |
|---|---|
| `visible` | `false` oculta el app bar completo y el contenido sube |
| `showBrand`, `showTitle` | `false` oculta la marca o el título |
| `centerTitle` | Marca y título al centro. Por defecto a la izquierda en todas las plataformas; con enlaces, siempre a la izquierda |
| `backgroundColor`, `foregroundColor` | Fondo; color del título y los íconos (`FFColor`) |
| `elevation` | Sombra |
| `linkColor`, `selectedLinkColor`, `selectedLinkBackgroundColor` | Colores de los enlaces y del enlace de la ruta actual |

**Dentro de `FFScaffold`**

Si lo pasas como `appBar` de un `FFScaffold`, toma de él lo que no definas:
- La marca del scaffold, si el `FFAppBar` no tiene `brand` ni `title` y la navegación no es rail.
- Con `FFNavigation.appBar`, los destinos y la ruta para los enlaces, y el fondo de la navegación.
- Los colores de los enlaces, desde el `FFNavStyle`.

Lo que pongas en `responsive` siempre gana. Si lo ocultas con `visible: false` y la navegación es drawer, se va también el ☰.

