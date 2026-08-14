/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectivityErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onOfflinePressed;

  const ConnectivityErrorView({
    super.key,
    required this.message,
    this.onOfflinePressed,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 60,
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: settings.fontSize,
              ),
            ),
            if (onOfflinePressed != null) ...[
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: onOfflinePressed,
                icon: Icon(
                  Icons.offline_pin,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                label: Text(
                  "Áudios Baixados",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: settings.fontSize * 0.9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
