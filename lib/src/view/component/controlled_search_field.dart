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
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        prefixIcon:
            Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
        suffixIcon: IconButton(
          onPressed: () {
            controller.clear();
            onChanged('');
          },
          icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.secondary),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      cursorColor: Theme.of(context).colorScheme.secondary,
    );
  }
}

