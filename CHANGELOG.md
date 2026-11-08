## 0.0.11 - 2026-10-30

* **Breaking change**: `FFStyle.borderRadius` now accepts a `BorderRadiusGeometry` per breakpoint instead of a number, allowing each corner to be configured independently (`BorderRadius.only`, `.vertical`, `BorderRadiusDirectional`, etc.). When a border is present, each corner clips using its inner radius. To migrate, replace `FFValue(xs: 12)` with `FFValue(xs: BorderRadius.all(Radius.circular(12)))`.

## 0.0.10 - 2026-10-30

* `FFStyle.clip`: clips overflowing content per breakpoint, like `overflow: hidden`, following the `borderRadius` corners. Also available in `FFResolvedStyle`.
* `borderRadius` now clips content inside the border, using the inner radius.

## 0.0.9 - 2026-10-30

* Fix: `FFStyle.maxWidth` and `width` had no effect in an `FFContainer` or in an `FFItem` inside an `FFFlex` column. They now constrain the box: it is centered in `FFContainer` and aligned to the start of its column in `FFItem`, which still occupies its allocated space.

## 0.0.8 - 2026-10-30

* **Breaking change**: `FFStyle.backgroundColor` is now an `FFValue<FFColor>`, allowing the background to change per breakpoint. To migrate, wrap the color: `backgroundColor: AppColors.surface` becomes `backgroundColor: FFValue(xs: AppColors.surface)`.

## 0.0.7 - 2026-10-30

* `FFStyle.shadow`: shadows per breakpoint (`List<BoxShadow>`), also available in `FFResolvedStyle`. `FFShadow` provides `sm`, `md`, `lg`, and `none`, similar to Bootstrap's `shadow-sm`, `shadow`, and `shadow-lg`.
* `FFStyle.backgroundImage`: background image per breakpoint (`DecorationImage`), painted over `backgroundColor`.
* `FFStyle.borderRadius`, `borderWidth`, and `borderColor`: corners and border per breakpoint. The radius clips content, and the border is added to the padding; without `borderColor`, the theme's `outlineVariant` is used.

## 0.0.6 - 2026-10-30

* **Breaking change**: `FFFlex.direction` now accepts an `FFDirection` instead of an `Axis`: `horizontal`, `horizontalReverse`, `vertical`, and `verticalReverse` (like `flex-row`, `flex-row-reverse`, `flex-column`, and `flex-column-reverse`). To migrate, replace `Axis.horizontal` with `FFDirection.horizontal` and `Axis.vertical` with `FFDirection.vertical`.

## 0.0.5 - 2026-10-30

* `FFStyle.maxHeight`: maximum height per breakpoint, also available in `FFResolvedStyle`.
* **Breaking change**: `FFFlex` is now horizontal by default, like a Bootstrap `row`, and a child without `col` or `fill` (or a child that is not an `FFItem`) occupies the full row. This lets `col` work without specifying `direction`, while `FFFlex` instances without `col` still stack their children. To size an item to its natural width in a row, use `fill: FFValue(...: false)` (`col-auto`). Use vertical layout when height matters: `fill` applies to height and alignment is vertical.

## 0.0.4 - 2026-10-29

* `FFAppBar`: a responsive app bar that can be used in any `Scaffold`, without `FFScaffold`. It supports branding, a title, links with dropdown groups, and actions (`FFAction`), with `FFAppBarStyle` per breakpoint: `visible`, `showBrand`, `showTitle`, `centerTitle`, colors, and elevation. Inside `FFScaffold`, it inherits any unspecified branding, destinations, and colors.
* README: feature index, installation instructions, a complete example, and images at xs, md, and lg for each topic.
* Example: a "Library" section with pages for styles, spacing, colors, containers, and the app bar.

## 0.0.3 - 2026-10-29

* `FFScaffold`: the rail and sidebar occupy the full height, and the app bar appears only above the content. The ☰ button and menu header align with the app bar.

## 0.0.2 - 2026-10-29

* **Rename**: the package is now `flow_frame` (`import 'package:flow_frame/flow_frame.dart'`), and classes use the `FF` prefix instead of `WR` (`FFScaffold`, `FFValue`, `FFNavStyle`, etc.).
* `FFScaffold`: removed the divider between the rail or sidebar and the content.
* `FFNavStyle`: added `shadow` and `shadowColor` for an optional shadow separating navigation from content.
* `FFBrand` and `FFScaffold.brand`: app logo and name next to ☰, positioned according to the navigation type (menu header, rail, drawer, or app bar).

## 0.0.1 - 2026-10-28

* `xs`/`sm`/`md`/`lg`/`xl` breakpoints, configurable with `FFBreakpoints.current`.
* `FFValue<T>`: values per breakpoint with mobile-first cascading.
* `FFSpacing`: responsive padding and margin with `all`, axes, and sides.
* `FFStyle`: reusable styles with `merge`, `toTextStyle`, and `resolve`.
* `FFColor`: fixed colors or light and dark variants based on the app's `Theme`.
* `FFContainer`: centered container with a maximum width.
* `FFFlex`: row or column with direction, spacing, and alignment per breakpoint; horizontal layouts create rows and wrap overflowing content.
* `FFItem`: item with `col`, `fill`, `order`, and `style`; hidden items do not leave gaps.
* `FFScaffold`: `Scaffold` with breakpoint-based navigation (bottom bar, rail, drawer, or app bar links with dropdown groups), routes by `id` (`currentRoute`/`onRouteSelected`), accordion subroutes, destinations with `visible` per breakpoint, and cascading `FFNavStyle` for navigation type, rail menu overlay or sidebar, always-open groups, and colors. The menu can be opened in code with `FFScaffold.of(context)`.
* `FFActions` and `FFAction`: actions that can show an icon and text, an icon only, appear in the ⋮ menu, or be hidden depending on the breakpoint.
