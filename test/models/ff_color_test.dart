import 'package:flow_frame/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FFColor', () {
    testWidgets('resolves the matching theme brightness', (tester) async {
      const adaptive = FFColor.adaptive(
        light: Color(0xFF123456),
        dark: Color(0xFFABCDEF),
      );
      late Color light;
      late Color dark;

      await tester.pumpWidget(
        MaterialApp(
          home: Theme(
            data: ThemeData(brightness: Brightness.light),
            child: Builder(
              builder: (context) {
                light = adaptive.resolve(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Theme(
            data: ThemeData(brightness: Brightness.dark),
            child: Builder(
              builder: (context) {
                dark = adaptive.resolve(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(light, const Color(0xFF123456));
      expect(dark, const Color(0xFFABCDEF));
    });

    test(
      'fixed colors stay equal to adaptive colors with matching variants',
      () {
        const fixed = FFColor.fixed(Color(0xFF123456));
        const sameAdaptive = FFColor.adaptive(
          light: Color(0xFF123456),
          dark: Color(0xFF123456),
        );

        expect(fixed, sameAdaptive);
        expect(fixed.hashCode, sameAdaptive.hashCode);
        expect(fixed, isNot(const FFColor.fixed(Color(0xFF654321))));
        expect(fixed == Object(), isFalse);
      },
    );
  });
}
