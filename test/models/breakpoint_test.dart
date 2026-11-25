import 'package:flow_frame/responsive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FFBreakpoints', () {
    test('selects the breakpoint at each configured boundary', () {
      const breakpoints = FFBreakpoints(sm: 500, md: 700, lg: 900, xl: 1100);

      expect(breakpoints.of(0), BreakpointEnum.xs);
      expect(breakpoints.of(499), BreakpointEnum.xs);
      expect(breakpoints.of(500), BreakpointEnum.sm);
      expect(breakpoints.of(699), BreakpointEnum.sm);
      expect(breakpoints.of(700), BreakpointEnum.md);
      expect(breakpoints.of(899), BreakpointEnum.md);
      expect(breakpoints.of(900), BreakpointEnum.lg);
      expect(breakpoints.of(1099), BreakpointEnum.lg);
      expect(breakpoints.of(1100), BreakpointEnum.xl);
    });

    test('compares thresholds and exposes stable hashing', () {
      const thresholds = FFBreakpoints(sm: 500, md: 700, lg: 900, xl: 1100);

      expect(thresholds, const FFBreakpoints(sm: 500, md: 700, lg: 900, xl: 1100));
      expect(thresholds.hashCode, const FFBreakpoints(
        sm: 500,
        md: 700,
        lg: 900,
        xl: 1100,
      ).hashCode);
      expect(thresholds, isNot(FFBreakpoints.defaults));
    });
  });

  group('FFBreakpointScope', () {
    testWidgets('exposes local thresholds without changing outer scope', (
      tester,
    ) async {
      late FFBreakpoints outer;
      late FFBreakpoints inner;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              outer = FFBreakpointScope.of(context);
              return FFBreakpointScope(
                breakpoints: const FFBreakpoints(
                  sm: 500,
                  md: 700,
                  lg: 900,
                  xl: 1100,
                ),
                child: Builder(
                  builder: (context) {
                    inner = FFBreakpointScope.of(context);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(outer, FFBreakpoints.defaults);
      expect(inner.md, 700);
    });

    test('notifies only when thresholds differ', () {
      const defaults = FFBreakpointScope(child: SizedBox());
      const changed = FFBreakpointScope(
        breakpoints: FFBreakpoints(sm: 500, md: 700, lg: 900, xl: 1100),
        child: SizedBox(),
      );

      expect(defaults.updateShouldNotify(changed), isTrue);
      expect(defaults.updateShouldNotify(defaults), isFalse);
    });
  });
}
