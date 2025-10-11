import 'package:flutter/material.dart';

import '../controllers/fontSizeController.dart';

class InformacaoScreen extends StatelessWidget {
  const InformacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: ValueListenableBuilder<double>(
          valueListenable: FontSizeController.fontSizeNotifier,
            builder: (context, fontSize, _) {
              return Text(
                "Informações",
                style: TextStyle(
                  fontSize: fontSize,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              );
            }
        ),
      ),
    );
  }
}
