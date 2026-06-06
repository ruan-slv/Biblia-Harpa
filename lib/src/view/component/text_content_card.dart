import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextContentCard extends StatelessWidget {
  const TextContentCard({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsViewModel>();

    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: settings.fontSize + 5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                body,
                style: TextStyle(
                  fontSize: settings.fontSize,
                  color: colorScheme.secondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
