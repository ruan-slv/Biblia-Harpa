/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';

import 'action_info_card.dart';

Widget buildMenuCard(
    BuildContext context,
    {
      required String title,
      String? description,
      required IconData iconData,
      required List<Color> gradientColors,
      required VoidCallback onPressed,
      bool compact = false,
      bool centerContent = false,
    }) {
  return ActionInfoCard(
    title: title,
    description: description ?? '',
    icon: iconData,
    onTap: onPressed,
    gradientColors: gradientColors,
    compact: compact,
    centerContent: centerContent,
  );
}
