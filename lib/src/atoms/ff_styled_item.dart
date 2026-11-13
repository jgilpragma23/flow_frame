import 'package:flutter/widgets.dart';

import '../models/ff_decoration_style.dart';
import '../models/ff_layout_style.dart';
import '../models/ff_style.dart';
import '../models/ff_text_style.dart';
import '../models/ff_value.dart';
import 'ff_item.dart';
import 'ff_styled.dart';

/// An [FFItem] with optional style composition.
///
/// Use [FFItem] from the grid library when styling is not needed.
class FFStyledItem extends FFItem {
  const FFStyledItem({
    super.key,
    super.col,
    super.fill,
    super.order,
    super.visible,
    required this.style,
    required super.child,
  });

  FFStyledItem.compose({
    super.key,
    super.col,
    super.fill,
    super.order,
    super.visible,
    FFTextStyle text = const FFTextStyle(),
    FFDecorationStyle decoration = const FFDecorationStyle(),
    FFLayoutStyle layout = const FFLayoutStyle(),
    required super.child,
  }) : style = FFStyle.compose(
         text: text,
         decoration: decoration,
         layout: layout,
       );

  final FFStyle style;

  @override
  FFValue<bool>? get visible => super.visible ?? style.visible;

  @override
  Widget build(BuildContext context) {
    final resolved = style.resolve(context);
    final child = resolved.width == null && resolved.maxWidth == null
        ? this.child
        : SizedBox(width: double.infinity, child: this.child);
    final styled = FFStyled(style: style, child: child);
    if (resolved.width == null && resolved.maxWidth == null) return styled;
    return Align(
      alignment: AlignmentDirectional.topStart,
      heightFactor: 1,
      child: styled,
    );
  }
}
