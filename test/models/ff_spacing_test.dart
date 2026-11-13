import 'package:flow_frame/styling.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FFSpacing.resolve', () {
    test('uses the most specific side and breakpoint values', () {
      const spacing = FFSpacing(
        all: FFValue(xs: 1, lg: 4),
        horizontal: FFValue(md: 2),
        vertical: FFValue(sm: 3),
        left: FFValue(sm: 5),
        top: FFValue(md: 6),
      );

      expect(spacing.resolve(BreakpointEnum.xs), const EdgeInsets.all(1));
      expect(
        spacing.resolve(BreakpointEnum.md),
        const EdgeInsets.fromLTRB(2, 6, 2, 3),
      );
      expect(
        spacing.resolve(BreakpointEnum.xl),
        const EdgeInsets.all(4),
      );
      expect(const FFSpacing().resolve(BreakpointEnum.md), EdgeInsets.zero);
    });

    test('falls back to the closest earlier breakpoint for each side', () {
      const spacing = FFSpacing(
        all: FFValue(xs: 2, md: 8),
        horizontal: FFValue(sm: 4, lg: 12),
        top: FFValue(md: 16),
      );

      expect(
        spacing.resolve(BreakpointEnum.sm),
        const EdgeInsets.fromLTRB(4, 2, 4, 2),
      );
      expect(
        spacing.resolve(BreakpointEnum.xl),
        const EdgeInsets.fromLTRB(12, 16, 12, 8),
      );
    });
  });

  group('FFSpacing.merge', () {
    test('combines values per side and preserves base definitions', () {
      const base = FFSpacing(
        all: FFValue<double>(xs: 8),
        top: FFValue(md: 12),
        right: FFValue(lg: 20),
      );
      const override = FFSpacing(
        all: FFValue<double>(md: 16),
        left: FFValue<double>(xs: 4),
        right: FFValue<double>(xl: 24),
      );

      expect(base.merge(null), base);
      final merged = base.merge(override);
      expect(merged.all, const FFValue<double>(xs: 8, md: 16));
      expect(merged.top, base.top);
      expect(merged.left, const FFValue<double>(xs: 4));
      expect(merged.right, const FFValue<double>(lg: 20, xl: 24));
    });

    test('supports equality and hashing for spacing definitions', () {
      const spacing = FFSpacing(
        all: FFValue<double>(xs: 8),
        horizontal: FFValue<double>(md: 12),
      );

      expect(spacing, const FFSpacing(
        all: FFValue<double>(xs: 8),
        horizontal: FFValue<double>(md: 12),
      ));
      expect(
        spacing.hashCode,
        const FFSpacing(
          all: FFValue<double>(xs: 8),
          horizontal: FFValue<double>(md: 12),
        ).hashCode,
      );
      expect(
        spacing,
        isNot(const FFSpacing(all: FFValue<double>(xs: 8))),
      );
    });
  });
}
