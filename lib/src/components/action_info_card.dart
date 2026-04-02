import 'package:flutter/material.dart';

class ActionInfoCard extends StatelessWidget {
  const ActionInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.gradientColors,
    this.compact = false,
    this.centerContent = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final bool compact;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = gradientColors ??
        [
          colorScheme.secondary,
          colorScheme.secondary.withOpacity(0.82),
        ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colorScheme.secondary.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 18 : 22),
            child: Column(
              crossAxisAlignment: centerContent
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  height: compact ? 48 : 58,
                  width: compact ? 48 : 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors.length >= 2
                          ? colors
                          : [colors.first, colors.first],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: Colors.white, size: compact ? 24 : 28),
                ),
                SizedBox(height: compact ? 14 : 18),
                Text(
                  title,
                  textAlign: centerContent ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontSize: compact ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.secondary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign:
                        centerContent ? TextAlign.center : TextAlign.start,
                    style: TextStyle(
                      color: colorScheme.secondary.withOpacity(0.8),
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
