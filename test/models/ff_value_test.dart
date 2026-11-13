import 'package:flow_frame/responsive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FFValue', () {
    test('resolves exact and cascading breakpoint values', () {
      const value = FFValue<int>(xs: 1, md: 3, xl: 5);

      expect(value.at(BreakpointEnum.xs), 1);
      expect(value.at(BreakpointEnum.sm), isNull);
      expect(value.at(BreakpointEnum.md), 3);
      expect(value.at(BreakpointEnum.lg), isNull);
      expect(value.at(BreakpointEnum.xl), 5);
      expect(value.resolve(BreakpointEnum.xs), 1);
      expect(value.resolve(BreakpointEnum.sm), 1);
      expect(value.resolve(BreakpointEnum.md), 3);
      expect(value.resolve(BreakpointEnum.lg), 3);
      expect(value.resolve(BreakpointEnum.xl), 5);
      expect(const FFValue<int>().resolve(BreakpointEnum.xl), isNull);
      expect(const FFValue<int>.all(8).resolve(BreakpointEnum.lg), 8);
    });

    test('merges with right-side precedence and supports nullable combine', () {
      const base = FFValue<int>(xs: 1, md: 3);
      const override = FFValue<int>(sm: 2, md: 4, xl: 5);

      expect(base.merge(null), base);
      expect(
        base.merge(override),
        const FFValue<int>(xs: 1, sm: 2, md: 4, xl: 5),
      );
      expect(FFValue.combine<int>(null, override), override);
      expect(FFValue.combine<int>(base, null), base);
      expect(FFValue.combine<int>(base, override), base.merge(override));
    });

    test('compares values and hashes their breakpoint contents', () {
      const value = FFValue<int>(xs: 1, md: 3);

      expect(value, const FFValue<int>(xs: 1, md: 3));
      expect(value.hashCode, const FFValue<int>(xs: 1, md: 3).hashCode);
      expect(value, isNot(const FFValue<int>(xs: 2, md: 3)));
      expect(value, isNot(FFValue<String>(xs: '1')));
    });
  });

  group('FFValue<TextStyle>', () {
    test('merges text fields across breakpoints', () {
      const value = FFValue<TextStyle>(
        xs: TextStyle(fontSize: 12, color: Color(0xFFFF0000)),
        md: TextStyle(fontWeight: FontWeight.w700),
        lg: TextStyle(fontSize: 20),
      );

      final xs = value.resolveMerged(BreakpointEnum.xs);
      expect(xs?.fontSize, 12);
      expect(xs?.color, const Color(0xFFFF0000));
      expect(value.resolveMerged(BreakpointEnum.sm)?.fontSize, 12);

      final md = value.resolveMerged(BreakpointEnum.md);
      expect(md?.fontSize, 12);
      expect(md?.fontWeight, FontWeight.w700);
      expect(value.resolveMerged(BreakpointEnum.xl)?.fontSize, 20);
      expect(const FFValue<TextStyle>().resolveMerged(BreakpointEnum.md), isNull);
    });

    test('merges text values per breakpoint, preserving unset properties', () {
      const base = FFValue<TextStyle>(
        xs: TextStyle(fontSize: 12, color: Color(0xFFFF0000)),
        md: TextStyle(fontWeight: FontWeight.w700),
      );
      const override = FFValue<TextStyle>(
        xs: TextStyle(color: Color(0xFF0000FF)),
        md: TextStyle(fontSize: 20),
      );

      expect(base.mergeStyles(null), base);
      final merged = base.mergeStyles(override);
      expect(merged.xs?.fontSize, 12);
      expect(merged.xs?.color, const Color(0xFF0000FF));
      expect(merged.md?.fontSize, 20);
      expect(merged.md?.fontWeight, FontWeight.w700);
      expect(merged.lg, isNull);
    });
  });
}
