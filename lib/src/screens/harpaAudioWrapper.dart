// lib/src/screens/harpaAudioWrapper.dart

import 'package:biblia_e_harpa/src/screens/harpaAudioScreen.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controllers/fontSizeController.dart';

class HarpaAudioWrapper extends StatefulWidget {
  const HarpaAudioWrapper({super.key});

  @override
  State<HarpaAudioWrapper> createState() => _HarpaAudioWrapperState();
}

class _HarpaAudioWrapperState extends State<HarpaAudioWrapper> {
  late final Future<List<ConnectivityResult>> _connectivityFuture;

  @override
  void initState() {
    super.initState();
    // Inicia a verificação de conectividade
    _connectivityFuture = Connectivity().checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<List<ConnectivityResult>>(
        future: _connectivityFuture,
        builder: (context, snapshot) {
          // 1. Enquanto verifica, mostra um progresso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Se a verificação falhou
          if (snapshot.hasError) {
            return _buildErrorWidget(
                context, "Erro ao verificar a conexão. Tente novamente.");
          }

          // 3. Se a verificação foi concluída e TEM internet
          if (snapshot.hasData && !snapshot.data!.contains(ConnectivityResult.none)) {
            // Chama a tela da Harpa no modo ONLINE
            return const HarpaAudioScreen(isOffline: false);
          }

          // 4. Se não tem conexão, mostra a tela de erro com o botão de downloads
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
            ValueListenableBuilder<double>(
              valueListenable: FontSizeController.fontSizeNotifier,
              builder: (context, fontSize, _) {
                return Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: fontSize,
                  ),
                );
              },
            ),
            // Se showOfflineButton for true, mostra o botão
            if (showOfflineButton) ...[
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // Navega para a tela da Harpa no modo OFFLINE
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HarpaAudioScreen(isOffline: true),
                    ),
                  );
                },
                icon: Icon(
                  Icons.download_done_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                label: ValueListenableBuilder<double>(
                  valueListenable: FontSizeController.fontSizeNotifier,
                  builder: (context, fontSize, _) {
                    return Text(
                      "Hinos Baixados",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: fontSize * 0.9,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
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
