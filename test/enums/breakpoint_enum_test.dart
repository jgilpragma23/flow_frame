import 'package:flow_frame/responsive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('orders breakpoints by increasing screen width', () {
    expect(BreakpointEnum.xs < BreakpointEnum.sm, isTrue);
    expect(BreakpointEnum.sm <= BreakpointEnum.sm, isTrue);
    expect(BreakpointEnum.md > BreakpointEnum.sm, isTrue);
    expect(BreakpointEnum.xl >= BreakpointEnum.lg, isTrue);
    expect(BreakpointEnum.md < BreakpointEnum.xs, isFalse);
    expect(BreakpointEnum.sm > BreakpointEnum.xl, isFalse);
  });
}
