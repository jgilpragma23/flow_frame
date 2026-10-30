import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../atoms/ff_item.dart';
import '../models/breakpoint.dart';
import '../models/ff_direction.dart';
import '../models/ff_style.dart';
import '../models/ff_value.dart';
import '../utils/context_extensions.dart';
import '../utils/ff_style_builder.dart';

/// Una fila o columna cuya dirección, separación y alineación cambian según
/// el breakpoint (equivale a `d-flex flex-column flex-md-row`). La dirección
/// también puede invertir el orden de los hijos ([FFDirection]).
///
/// Por defecto es horizontal y funciona como un `row` de Bootstrap: cada
/// [FFItem] ocupa su `col` (de 12), lo que sobra en la fila (`fill: true`)
/// o su tamaño natural (`fill: false`), y lo que no cabe baja a la
/// siguiente fila. Un hijo sin `col` ni `fill`, o que no es un [FFItem],
/// ocupa la fila completa, así que sin `col` los hijos quedan apilados.
///
/// En vertical los apila siempre; sirve cuando importa el alto: `fill`
/// reparte la altura que sobra y `mainAxisAlignment` alinea en vertical.
///
/// Los [FFItem] también pueden cambiar de posición con `order` y ocultarse
/// con `visible`; los ocultos no dejan separación.
class FFFlex extends StatelessWidget {
  const FFFlex({
    super.key,
    this.direction = const FFValue.all(FFDirection.horizontal),
    this.gap,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.style,
    required this.children,
  });

  /// Por defecto [FFDirection.horizontal] en todos los breakpoints. Con
  /// `horizontalReverse` o `verticalReverse` los hijos van en orden inverso.
  final FFValue<FFDirection> direction;

  /// Separación entre elementos y, en horizontal, también entre filas.
  final FFValue<double>? gap;

  /// Por defecto `start`. En horizontal se aplica a cada fila.
  final FFValue<MainAxisAlignment>? mainAxisAlignment;

  /// Por defecto `stretch` en vertical (los elementos ocupan todo el ancho)
  /// y `start` en horizontal. En horizontal se aplica dentro de cada fila.
  /// `baseline` se trata como `start`.
  final FFValue<CrossAxisAlignment>? crossAxisAlignment;
  final FFStyle? style;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final dir = direction.resolve(breakpoint) ?? FFDirection.horizontal;
    final axis = dir.axis;

    return buildFFStyle(
      context,
      style,
      _WRFlexLayout(
        direction: axis,
        gap: gap?.resolve(breakpoint) ?? 0,
        mainAxisAlignment:
            mainAxisAlignment?.resolve(breakpoint) ?? MainAxisAlignment.start,
        crossAxisAlignment:
            crossAxisAlignment?.resolve(breakpoint) ??
            (axis == Axis.vertical
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.start),
        textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
        children: _slots(breakpoint, reverse: dir.isReverse),
      ),
    );
  }

  /// Quita los ocultos, ordena por `order` (y lo invierte con [reverse]) y
  /// le dice al layout cómo medir
  /// cada hijo. Cada hijo lleva una key con su índice original para que no
  /// pierda su estado al reordenarse u ocultarse otro.
  List<Widget> _slots(Breakpoint breakpoint, {required bool reverse}) {
    final entries = <({int index, int order, Widget child})>[];
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      var order = 0;
      if (child is FFItem) {
        if (child.style?.visible?.resolve(breakpoint) == false) continue;
        order = child.order?.resolve(breakpoint) ?? 0;
      }
      entries.add((index: i, order: order, child: child));
    }
    entries.sort(
      (a, b) => a.order != b.order
          ? a.order.compareTo(b.order)
          : a.index.compareTo(b.index),
    );

    return [
      for (final e in reverse ? entries.reversed : entries)
        _WRSlot(
          key: _SlotKey(e.index),
          size: e.child is FFItem
              ? _sizeOf(e.child as FFItem, breakpoint)
              : _SlotSize.row,
          child: e.child,
        ),
    ];
  }

  /// Entre `col` y `fill` gana el breakpoint más cercano; en el mismo
  /// breakpoint gana `col`. Sin ninguno, la fila completa.
  static _SlotSize _sizeOf(FFItem item, Breakpoint breakpoint) {
    for (var i = breakpoint.index; i >= 0; i--) {
      final b = Breakpoint.values[i];
      final col = item.col?.at(b);
      if (col != null) return _SlotSize.col(col);
      final fill = item.fill?.at(b);
      if (fill != null) return fill ? _SlotSize.fill : _SlotSize.natural;
    }
    return _SlotSize.row;
  }
}

class _SlotKey extends ValueKey<int> {
  const _SlotKey(super.value);
}

/// Cómo se mide un hijo en el eje principal.
@immutable
class _SlotSize {
  const _SlotSize._(this.kind, this.col);
  const _SlotSize.col(int col) : this._(_SlotKind.col, col);

  static const natural = _SlotSize._(_SlotKind.natural, 0);
  static const fill = _SlotSize._(_SlotKind.fill, 0);

  /// La fila completa, como `col: 12`.
  static const row = _SlotSize._(_SlotKind.col, 12);

  final _SlotKind kind;
  final int col;

  @override
  bool operator ==(Object other) =>
      other is _SlotSize && other.kind == kind && other.col == col;

  @override
  int get hashCode => Object.hash(kind, col);
}

enum _SlotKind { natural, fill, col }

class _WRSlotParentData extends ContainerBoxParentData<RenderBox> {
  _SlotSize size = _SlotSize.natural;
}

class _WRSlot extends ParentDataWidget<_WRSlotParentData> {
  const _WRSlot({super.key, required this.size, required super.child});

  final _SlotSize size;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as _WRSlotParentData;
    if (parentData.size != size) {
      parentData.size = size;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _WRFlexLayout;
}

class _WRFlexLayout extends MultiChildRenderObjectWidget {
  const _WRFlexLayout({
    required this.direction,
    required this.gap,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.textDirection,
    super.children,
  });

  final Axis direction;
  final double gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection textDirection;

  @override
  _RenderWRFlex createRenderObject(BuildContext context) => _RenderWRFlex(
    direction: direction,
    gap: gap,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    textDirection: textDirection,
  );

  @override
  void updateRenderObject(BuildContext context, _RenderWRFlex renderObject) {
    renderObject
      ..direction = direction
      ..gap = gap
      ..mainAxisAlignment = mainAxisAlignment
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = textDirection;
  }
}

class _RenderWRFlex extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _WRSlotParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _WRSlotParentData> {
  _RenderWRFlex({
    required Axis direction,
    required double gap,
    required MainAxisAlignment mainAxisAlignment,
    required CrossAxisAlignment crossAxisAlignment,
    required TextDirection textDirection,
  }) : _direction = direction,
       _gap = gap,
       _mainAxisAlignment = mainAxisAlignment,
       _crossAxisAlignment = crossAxisAlignment,
       _textDirection = textDirection;

  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  double get gap => _gap;
  double _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  MainAxisAlignment _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment == value) return;
    _mainAxisAlignment = value;
    markNeedsLayout();
  }

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _WRSlotParentData) {
      child.parentData = _WRSlotParentData();
    }
  }

  _SlotSize _sizeOf(RenderBox child) =>
      (child.parentData! as _WRSlotParentData).size;

  @override
  void performLayout() {
    size = _layout(constraints, ChildLayoutHelper.layoutChild, place: true);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      _layout(constraints, ChildLayoutHelper.dryLayoutChild, place: false);

  Size _layout(
    BoxConstraints constraints,
    ChildLayouter layoutChild, {
    required bool place,
  }) {
    final children = getChildrenAsList();
    return direction == Axis.horizontal
        ? _layoutRows(children, constraints, layoutChild, place)
        : _layoutColumn(children, constraints, layoutChild, place);
  }

  /// Horizontal: arma filas de izquierda a derecha y baja lo que no cabe.
  Size _layoutRows(
    List<RenderBox> children,
    BoxConstraints constraints,
    ChildLayouter layoutChild,
    bool place,
  ) {
    final maxWidth = constraints.maxWidth;
    final bounded = maxWidth.isFinite;
    final sizes = List<Size>.filled(children.length, Size.zero);
    // Sin ancho límite no hay columnas que calcular ni espacio que llenar.
    final isFill = [
      for (final child in children)
        bounded && _sizeOf(child).kind == _SlotKind.fill,
    ];

    // 1. Medir los que no son fill: col con su fracción, el resto natural.
    for (var i = 0; i < children.length; i++) {
      if (isFill[i]) continue;
      final slot = _sizeOf(children[i]);
      if (bounded && slot.kind == _SlotKind.col) {
        // Así `12 / col` elementos con sus gaps llenan la fila exacta.
        final width = (slot.col.clamp(1, 12) / 12 * (maxWidth + gap) - gap)
            .clamp(0.0, maxWidth);
        sizes[i] = layoutChild(
          children[i],
          BoxConstraints(minWidth: width, maxWidth: width),
        );
      } else {
        sizes[i] = layoutChild(children[i], BoxConstraints(maxWidth: maxWidth));
      }
    }

    // 2. Cortar filas: si el siguiente no cabe, empieza una fila nueva.
    // Los fill cuentan como 0 porque toman lo que sobre.
    final rows = <List<int>>[];
    var row = <int>[];
    var used = 0.0;
    for (var i = 0; i < children.length; i++) {
      final width = isFill[i] ? 0.0 : sizes[i].width;
      final needed = row.isEmpty ? width : used + gap + width;
      if (row.isNotEmpty && needed > maxWidth + _epsilon) {
        rows.add(row);
        row = [i];
        used = width;
      } else {
        row.add(i);
        used = needed;
      }
    }
    if (row.isNotEmpty) rows.add(row);

    // 3. En cada fila, repartir lo que sobra entre los fill y, con
    // stretch, igualar la altura de todos.
    final rowHeights = <double>[];
    var contentWidth = 0.0;
    for (final row in rows) {
      final fills = row.where((i) => isFill[i]).toList();
      if (fills.isNotEmpty) {
        final taken =
            row.fold(0.0, (sum, i) => sum + sizes[i].width) +
            gap * (row.length - 1);
        final each = math.max(0.0, (maxWidth - taken) / fills.length);
        for (final i in fills) {
          sizes[i] = layoutChild(
            children[i],
            BoxConstraints(minWidth: each, maxWidth: each),
          );
        }
      }
      final height = row.fold(0.0, (h, i) => math.max(h, sizes[i].height));
      if (crossAxisAlignment == CrossAxisAlignment.stretch) {
        for (final i in row) {
          sizes[i] = layoutChild(
            children[i],
            BoxConstraints.tightFor(width: sizes[i].width, height: height),
          );
        }
      }
      rowHeights.add(height);
      contentWidth = math.max(
        contentWidth,
        row.fold(0.0, (sum, i) => sum + sizes[i].width) +
            gap * (row.length - 1),
      );
    }

    final width = bounded ? maxWidth : contentWidth;
    final height =
        rowHeights.fold(0.0, (sum, h) => sum + h) +
        gap * math.max(0, rows.length - 1);
    final result = constraints.constrain(Size(width, height));

    if (place) {
      var y = 0.0;
      for (var r = 0; r < rows.length; r++) {
        final row = rows[r];
        final rowWidth =
            row.fold(0.0, (sum, i) => sum + sizes[i].width) +
            gap * (row.length - 1);
        final (leading, between) = _distribute(
          math.max(0.0, result.width - rowWidth),
          row.length,
        );
        var x = leading;
        for (final i in row) {
          final dy = _crossOffset(rowHeights[r], sizes[i].height);
          final dx = textDirection == TextDirection.rtl
              ? result.width - x - sizes[i].width
              : x;
          (children[i].parentData! as _WRSlotParentData).offset = Offset(
            dx,
            y + dy,
          );
          x += sizes[i].width + gap + between;
        }
        y += rowHeights[r] + gap;
      }
    }
    return result;
  }

  /// Vertical: apila; los fill se reparten la altura que sobra si hay límite.
  Size _layoutColumn(
    List<RenderBox> children,
    BoxConstraints constraints,
    ChildLayouter layoutChild,
    bool place,
  ) {
    final maxWidth = constraints.maxWidth;
    final maxHeight = constraints.maxHeight;
    final boundedHeight = maxHeight.isFinite;
    final stretch =
        crossAxisAlignment == CrossAxisAlignment.stretch && maxWidth.isFinite;
    final sizes = List<Size>.filled(children.length, Size.zero);
    final isFill = [
      for (final child in children)
        boundedHeight && _sizeOf(child).kind == _SlotKind.fill,
    ];

    BoxConstraints childConstraints({double? height}) => stretch
        ? BoxConstraints.tightFor(width: maxWidth, height: height)
        : BoxConstraints(
            maxWidth: maxWidth,
            minHeight: height ?? 0,
            maxHeight: height ?? double.infinity,
          );

    var used = gap * math.max(0, children.length - 1);
    for (var i = 0; i < children.length; i++) {
      if (isFill[i]) continue;
      sizes[i] = layoutChild(children[i], childConstraints());
      used += sizes[i].height;
    }
    final fillCount = isFill.where((f) => f).length;
    if (fillCount > 0) {
      final each = math.max(0.0, (maxHeight - used) / fillCount);
      for (var i = 0; i < children.length; i++) {
        if (!isFill[i]) continue;
        sizes[i] = layoutChild(children[i], childConstraints(height: each));
        used += sizes[i].height;
      }
    }

    final contentWidth = sizes.fold(0.0, (w, s) => math.max(w, s.width));
    final result = constraints.constrain(
      Size(stretch ? maxWidth : contentWidth, boundedHeight ? maxHeight : used),
    );

    if (place) {
      final (leading, between) = _distribute(
        math.max(0.0, result.height - used),
        children.length,
      );
      var y = leading;
      for (var i = 0; i < children.length; i++) {
        var dx = _crossOffset(result.width, sizes[i].width);
        if (textDirection == TextDirection.rtl) {
          dx = result.width - dx - sizes[i].width;
        }
        (children[i].parentData! as _WRSlotParentData).offset = Offset(dx, y);
        y += sizes[i].height + gap + between;
      }
    }
    return result;
  }

  /// Espacio antes del primer hijo y extra entre hijos, según
  /// [mainAxisAlignment].
  (double, double) _distribute(double free, int count) {
    if (count == 0) return (0, 0);
    return switch (mainAxisAlignment) {
      MainAxisAlignment.start => (0, 0),
      MainAxisAlignment.end => (free, 0),
      MainAxisAlignment.center => (free / 2, 0),
      MainAxisAlignment.spaceBetween => (0, count > 1 ? free / (count - 1) : 0),
      MainAxisAlignment.spaceAround => (free / count / 2, free / count),
      MainAxisAlignment.spaceEvenly => (free / (count + 1), free / (count + 1)),
    };
  }

  double _crossOffset(double available, double childSize) =>
      switch (crossAxisAlignment) {
        CrossAxisAlignment.end => available - childSize,
        CrossAxisAlignment.center => (available - childSize) / 2,
        _ => 0,
      };

  @override
  double computeMinIntrinsicWidth(double height) {
    var result = 0.0;
    for (final child in getChildrenAsList()) {
      result = math.max(result, child.getMinIntrinsicWidth(double.infinity));
    }
    return result;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final children = getChildrenAsList();
    if (direction == Axis.vertical) {
      return children.fold(
        0.0,
        (w, c) => math.max(w, c.getMaxIntrinsicWidth(double.infinity)),
      );
    }
    return children.fold(
          0.0,
          (w, c) => w + c.getMaxIntrinsicWidth(double.infinity),
        ) +
        gap * math.max(0, children.length - 1);
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      getDryLayout(BoxConstraints(maxWidth: width)).height;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      getDryLayout(BoxConstraints(maxWidth: width)).height;

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

const _epsilon = 1e-6;
