import 'package:flutter/material.dart';
import 'package:biblia_e_harpa/src/components/action_info_card.dart';

class ButtonComponent extends StatelessWidget {
  const ButtonComponent({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    required this.description,
  });

  final String title;
  final Icon icon;
  final String description;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ActionInfoCard(
        title: title,
        description: description,
        icon: icon.icon ?? Icons.widgets_outlined,
        onTap: onPressed,
      ),
    );
  }
}
