import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:flutter/material.dart';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ValueListenableBuilder<double>(
            valueListenable: FontSizeController.fontSizeNotifier,
            builder: (context, fontSize, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: fontSize + 5,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: colorScheme.secondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
