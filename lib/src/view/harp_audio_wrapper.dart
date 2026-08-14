/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:biblia_e_harpa/src/view/harp_audio_view.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:provider/provider.dart';

class HarpAudioWrapper extends StatefulWidget {
  const HarpAudioWrapper({super.key});

  @override
  State<HarpAudioWrapper> createState() => _HarpAudioWrapperState();
}

class _HarpAudioWrapperState extends State<HarpAudioWrapper> {
  late final Future<List<ConnectivityResult>> _connectivityFuture;

  @override
  void initState() {
    super.initState();
    _connectivityFuture = Connectivity().checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<List<ConnectivityResult>>(
        future: _connectivityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(
                context, "Erro ao verificar a conexão. Tente novamente.");
          }

          if (snapshot.hasData && !snapshot.data!.contains(ConnectivityResult.none)) {
            return const HarpAudioView(isOffline: false);
          }

          return _buildErrorWidget(
            context,
            "Sem conexão com a internet. Conecte-se para baixar novos hinos ou acesse seus downloads.",
            showOfflineButton: true,
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message, {bool showOfflineButton = false}) {
    final settings = context.watch<SettingsViewModel>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: Theme.of(context).colorScheme.secondary.withValues(alpha:0.7),
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
            if (showOfflineButton) ...[
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HarpAudioView(isOffline: true),
                    ),
                  );
                },
                icon: Icon(
                  Icons.download_done_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                label: Text(
                  "Hinos Baixados",
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
            ]
          ],
        ),
      ),
    );
  }
}
