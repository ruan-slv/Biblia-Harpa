import 'package:biblia_e_harpa/src/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('applies the visual palette in light mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightMode,
        home: Builder(
          builder: (context) {
            expect(
              Theme.of(context).scaffoldBackgroundColor,
              const Color(0xFFF3F6FA),
            );
            expect(AppTheme.superficie(context), Colors.white);
            expect(AppTheme.superficieSuave(context), const Color(0xFFF7F9FC));
            expect(AppTheme.corPrimaria, const Color(0xFF00BFA6));
            expect(
              Theme.of(context).colorScheme.primary,
              const Color(0xFF046B5C),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('applies the visual palette in dark mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: darkMode,
        home: Builder(
          builder: (context) {
            expect(
              Theme.of(context).scaffoldBackgroundColor,
              const Color(0xFF0B0F14),
            );
            expect(AppTheme.superficie(context), const Color(0xFF141B23));
            expect(AppTheme.superficieSuave(context), const Color(0xFF1A232D));
            expect(
              Theme.of(context).colorScheme.primary,
              const Color(0xFF84D6C3),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}
