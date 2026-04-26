import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.canGoBack,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    this.previousLabel = 'ant.',
    this.nextLabel = 'próx.',
    this.topChild,
  });

  final bool canGoBack;
  final bool canGoNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String previousLabel;
  final String nextLabel;
  final Widget? topChild;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double buttonWidth = 220;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.secondary.withValues(alpha: 0.08),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (topChild != null) ...[
              topChild!,
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: canGoBack ? onPrevious : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: Text(previousLabel),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: canGoNext ? onNext : null,
                    label: Text(nextLabel),
                    icon: const Icon(Icons.chevron_right_rounded),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
