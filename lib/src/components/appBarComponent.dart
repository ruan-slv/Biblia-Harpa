import 'package:flutter/material.dart';
import '../config.dart'; // Importa as constantes de cores e tamanhos

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool? showBackButton;
  final VoidCallback? onBackPressed;
  final List<PopupMenuItem<String>>? menuItems;
  final Function(String)? onMenuItemSelected;
  final List<double>? menuButtonSize;
  final Color? iconThemeColor;

  const CustomAppBar({
    Key? key,
    this.title,
    this.backgroundColor,
    this.titleColor,
    this.showBackButton = false,
    this.onBackPressed,
    this.menuItems,
    this.onMenuItemSelected,
    this.menuButtonSize,
    this.iconThemeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? begeClaro,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton ?? false,
      iconTheme: IconThemeData(color: iconThemeColor ?? cinzaEscuro),
      title: title != null
          ? Text(
        title!,
        style: TextStyle(
          color: titleColor ?? cinzaEscuro,
          fontWeight: FontWeight.normal,
        ),
      )
          : null,
      actions: [
        if (menuItems != null)
          SizedBox(
            width: menuButtonSize?[0] ?? sizeBtnOptions[0],
            height: menuButtonSize?[1] ?? sizeBtnOptions[1],
            child: PopupMenuButton<String>(
              onSelected: onMenuItemSelected,
              itemBuilder: (BuildContext context) => menuItems!,
            ),
          ),
      ],
      elevation: 0, // Ajuste conforme o design original
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}