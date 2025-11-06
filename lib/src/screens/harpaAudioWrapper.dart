import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/screens/harpaAudioScreen.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
    return FutureBuilder<List<ConnectivityResult>>(
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

        // 3. Se a verificação foi concluída
        if (snapshot.hasData) {
          final connectivityResult = snapshot.data!;
          // Verifica se está conectado a qualquer rede
          if (!connectivityResult.contains(ConnectivityResult.none)) {
            // Se tem conexão, carrega a tela da Harpa
            return const HarpaAudioScreen();
          }
        }

        // 4. Se não tem conexão
        return _buildErrorWidget(
            context, "Sem conexão com a internet. Por favor, verifique sua rede e tente novamente.");
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 60,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: FontSizeController.fontSizeNotifier,
              builder: (context, fontSize, _) {
                return Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
