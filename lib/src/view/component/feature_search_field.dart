import 'package:flutter/material.dart';

class FeatureSearchField extends StatefulWidget {
  final String hintText;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  const FeatureSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<FeatureSearchField> createState() => _FeatureSearchFieldState();
}

class _FeatureSearchFieldState extends State<FeatureSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
        suffixIcon: IconButton(
          onPressed: () {
            _controller.clear();
            widget.onChanged('');
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

