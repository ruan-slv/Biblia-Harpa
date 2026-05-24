import "package:biblia_e_harpa/src/controllers/font_size_controller.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class ListTileMd extends StatelessWidget {

  final String title;
  final String? subTitle;
  final IconData? icon;
  final VoidCallback? onTap;

  const ListTileMd({super.key, required this.title, this.subTitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: ValueListenableBuilder<double>(
        valueListenable: FontSizeController.fontSizeNotifier,
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
      subtitle: ValueListenableBuilder<double>(
        valueListenable: FontSizeController.fontSizeNotifier,
        builder: (context, fontSize, _) {
          return Text(
            subTitle ?? "",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: fontSize - 2,
            ),
          );
        },
      ),
      onTap: onTap,
    );
  }
}