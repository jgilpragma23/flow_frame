# web_responsive

Herramientas para hacer interfaces responsive en Flutter con una idea parecida a Bootstrap: breakpoints mobile-first, estilos reutilizables y colores que cambian con el modo claro u oscuro.

> En desarrollo. Ya están los breakpoints, `WRValue`, `WRSpacing`, `WRStyle`, los colores con modo oscuro, `WRContainer`, `WRFlex` y `WRItem`.

## Ejemplo completo

```dart
WRContainer(
  maxSize: 1280,
  style: const WRStyle(padding: WRSpacing(horizontal: WRValue(xs: 16, md: 24))),
  child: WRFlex(
    // Sidebar arriba en móvil, a la izquierda desde md
    direction: const WRValue(xs: Axis.vertical, md: Axis.horizontal),
    gap: const WRValue(xs: 16, md: 24),
    children: [
      WRItem(
        flex: const WRValue(md: 1),
        style: const WRStyle(visible: WRValue(xs: false, sm: true)),
        child: Sidebar(),
      ),
      WRItem(flex: const WRValue(md: 3), child: Content()),
    ],
  ),
)
```

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

## `WRValue`: un valor por breakpoint

Cada valor aplica desde su breakpoint hacia arriba hasta que otro lo reemplace (mobile-first).

```dart
const gap = WRValue(xs: 8, md: 16); // 8 en xs/sm, 16 en md/lg/xl
const flex = WRValue(md: 1);        // null en xs/sm, 1 desde md
const same = WRValue.all(12);       // 12 en todos

gap.resolve(context.breakpoint);
context.responsive(xs: 1, md: 2, xl: 4); // atajo
```

## `WRSpacing`: padding y margin

```dart
const WRSpacing(
  all: WRValue(xs: 8, md: 16, xl: 24),
  horizontal: WRValue(lg: 32),
  vertical: WRValue(sm: 12),
  top: WRValue(md: 20),
)
```

Para cada lado:
1. Gana el breakpoint más cercano al actual.
2. Si empatan, gana el más específico: el lado (`top`) sobre el eje (`vertical`), y el eje sobre `all`.

Con el ejemplo de arriba, el `top` vale 8 en `xs`, 12 en `sm`, 20 en `md` y `lg`, y 24 en `xl`.

## `WRStyle`: estilos reutilizables

Funciona como una clase de CSS. Todo es opcional.

```dart
const card = WRStyle(
  padding: WRSpacing(all: WRValue(xs: 12, md: 16)),
  margin: WRSpacing(bottom: WRValue(xs: 8)),

  // Texto: textStyle es la base, lo demás va encima
  textStyle: WRValue(
    xs: TextStyle(fontSize: 14, fontFamily: 'Inter'),
    md: TextStyle(fontSize: 16),
  ),
  color: WRColor.text,
  fontWeight: WRValue(md: FontWeight.w600),
  fontSize: WRValue(xl: 18),
  lineHeight: WRValue(xs: 1.4),
  textAlign: WRValue(xs: TextAlign.center, md: TextAlign.start),

  backgroundColor: WRColor.surface,

  width: WRValue(md: 480),
  minWidth: WRValue(md: 320),
  maxWidth: WRValue(lg: 640),
  height: WRValue(md: 200),

  visible: WRValue(xs: false, md: true), // como d-none d-md-block
);
```

- **`textStyle` se combina en cascada:** en `md` se juntan los `TextStyle` de `xs`, `sm` y `md`, y en cada propiedad gana el mayor. En el ejemplo, la fuente `Inter` definida en `xs` se mantiene en `md`.
- **`color`, `fontWeight`, `fontSize` y `lineHeight` ganan sobre `textStyle`.** `color` va aparte porque un `TextStyle` no sabe del modo oscuro.
- **`merge`** combina dos estilos; el segundo gana donde define algo:

```dart
final hiddenCard = card.merge(const WRStyle(visible: WRValue(xs: false, lg: true)));
```

### Texto

Para un texto suelto, `toTextStyle(context)` devuelve un `TextStyle` normal de Flutter:

```dart
Text('Título', style: title.toTextStyle(context))
TextField(style: title.toTextStyle(context))
```

Para varios textos, pon el estilo en un contenedor y los `Text` de adentro lo heredan:

```dart
WRContainer(
  style: const WRStyle(
    textStyle: WRValue(xs: TextStyle(fontSize: 14)),
    color: WRColor.textMuted,
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

Un `WRColor` se resuelve al pintar, según el modo actual:

```dart
WRColor.primary                                   // de la paleta del tema
WRColor.adaptive(light: Color(0xFFFFF7E6), dark: Color(0xFF3A2E14))
WRColor.fixed(Color(0xFFFFFFFF))                  // no cambia
```

Colores de la paleta: `primary`, `secondary`, `background`, `surface`, `text`, `textMuted`, `border`, `error`, `success`, `warning`.

Colores propios, sin tocar la librería:

```dart
class AppColors {
  static const brand = WRColor.adaptive(light: Color(0xFF7C3AED), dark: Color(0xFFA78BFA));
}
```

Fuera de un estilo:

```dart
AppColors.brand.resolve(context);
context.wrColors.primary;
```

**¿Cómo se sabe si está en modo oscuro?**
1. Si `WRThemeData.themeMode` es `light`, `dark` o `system`, se usa eso.
2. Si no está definido, se sigue al `Theme` de Material, que ya respeta el `themeMode` del `MaterialApp`.

## Tema

`WRTheme` es opcional. Sin él se usan los valores por defecto.

```dart
WRTheme(
  data: WRThemeData(
    breakpoints: const WRBreakpoints(sm: 600, md: 840, lg: 1200, xl: 1600),
    colors: WRColorScheme(
      light: WRPalette.light.copyWith(primary: const Color(0xFF7C3AED)),
      dark: WRPalette.dark.copyWith(primary: const Color(0xFFA78BFA)),
    ),
    textStyle: const WRValue(
      xs: TextStyle(fontFamily: 'Inter', fontSize: 14),
      md: TextStyle(fontSize: 16),
    ),
    themeMode: null, // seguir al MaterialApp
  ),
  child: ...,
)
```

`WRTheme` aplica su `textStyle` y el color `text` de la paleta a todos los textos de abajo.

## `WRContainer`

Ocupa todo el ancho hasta `maxSize` y se centra en pantallas más anchas. El `style` se aplica por dentro de ese ancho.

```dart
WRContainer(
  maxSize: 1280,
  style: const WRStyle(
    padding: WRSpacing(horizontal: WRValue(xs: 16, md: 24)),
  ),
  child: ...,
)
```

Sin `maxSize` ocupa todo el ancho.

## `WRFlex` y `WRItem`

`WRFlex` es una fila o columna que cambia por breakpoint (como `d-flex flex-column flex-md-row`). `WRItem` es cada elemento.

```dart
WRFlex(
  direction: const WRValue(xs: Axis.vertical, md: Axis.horizontal),
  gap: const WRValue(xs: 12, md: 16),
  mainAxisAlignment: const WRValue(md: MainAxisAlignment.spaceBetween),
  crossAxisAlignment: const WRValue(md: CrossAxisAlignment.center),
  style: const WRStyle(padding: WRSpacing(all: WRValue(xs: 8))),
  children: [
    WRItem(flex: const WRValue(md: 1), style: card, child: Card1()),
    WRItem(flex: const WRValue(md: 2), style: card, child: Card2()),
    WRItem(
      order: const WRValue(xs: -1, md: 0), // primero en móvil, en su lugar desde md
      child: Image(...),
    ),
  ],
)
```

**`WRFlex`**
- `direction`: por defecto vertical.
- `gap`: separación entre elementos.
- `mainAxisAlignment`: por defecto `start`.
- `crossAxisAlignment`: por defecto `stretch` en vertical (los elementos ocupan todo el ancho) y `start` en horizontal.
- `style`: un `WRStyle` para el contenedor.
- `children`: pueden ser `WRItem` o cualquier widget.

**`WRItem`**
- `flex`: parte del espacio libre que ocupa. Sin valor en un breakpoint, toma su tamaño natural.
- `order`: posición dentro del `WRFlex`; los menores van primero (por defecto 0).
- `style`: un `WRStyle`. Con `visible: false` el elemento se quita y no deja separación.

**Detalles:**
- Si el `WRFlex` está en un eje sin límite (por ejemplo, vertical dentro de un `SingleChildScrollView`), `flex` se ignora en vez de dar error.
- Cambiar `order` o ocultar un elemento no hace perder el estado de los demás.
- Fuera de un `WRFlex`, `WRItem` ignora `flex` y `order` y solo aplica su `style`. Sirve como un `div` con clases.
