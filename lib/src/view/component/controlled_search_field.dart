/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';

class ControlledSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const ControlledSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        suffixIcon: IconButton(
          onPressed: () {
            controller.clear();
            onChanged('');
          },
          icon: Icon(
            Icons.clear,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      cursorColor: Theme.of(context).colorScheme.primary,
    );
  }
}
