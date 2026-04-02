import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class ListTileMd extends StatelessWidget {

  final String title;
  final IconData? icon;
  final ValueListenable<double> fontSizeListenable;
  final VoidCallback onTap;

  const ListTileMd({super.key, required this.title, this.icon, required this.fontSizeListenable, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: ValueListenableBuilder<double>(
        valueListenable: fontSizeListenable,
        builder: (context, fontSize, _) {
          return Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: fontSize,
            ),
          );
        },
      ),
      onTap: onTap,
    );
  }
}