import 'package:biblia_e_harpa/src/screens/bibleAudiosScreen.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../controllers/fontSizeController.dart';

class BibleAudioWrapper extends StatefulWidget {
  const BibleAudioWrapper({super.key});

  @override
  State<BibleAudioWrapper> createState() => _BibleAudioWrapperState();
}

class _BibleAudioWrapperState extends State<BibleAudioWrapper> {
  // Usamos um FutureBuilder para lidar com o estado de carregamento da verificação
  late final Future<List<ConnectivityResult>> _connectivityFuture;

  @override
  void initState() {
    super.initState();
    // Inicia a verificação de conectividade assim que o widget é criado
    _connectivityFuture = Connectivity().checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConnectivityResult>>(
      future: _connectivityFuture,
      builder: (context, snapshot) {
        // 1. Enquanto a verificação está em andamento, mostramos um indicador de progresso
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Se a verificação falhou (o que é raro, mas possível)
        if (snapshot.hasError) {
          return _buildErrorWidget(
              context, "Erro ao verificar a conexão. Tente novamente.");
        }

        // 3. Se a verificação foi concluída com sucesso
        if (snapshot.hasData) {
          final connectivityResult = snapshot.data!;
          // Verifica se o resultado NÃO contém 'none', ou seja, está conectado
          if (!connectivityResult.contains(ConnectivityResult.none)) {
            // Se tem conexão, carrega a tela principal dos áudios da Bíblia
            return const Bibleaudiosscreen();
          }
        }

        // 4. Se chegou aqui, significa que não tem conexão (ou o snapshot não tem dados)
        return _buildErrorWidget(
            context, "Sem conexão com a internet. Por favor, verifique sua rede e tente novamente.");
      },
    );
  }

  // Widget auxiliar para exibir mensagens de erro de forma padronizada
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
            ValueListenableBuilder<double>(
              valueListenable: FontSizeController.fontSizeNotifier,
              builder: (context, fontSize, _) {
                return Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    // 3. Usa o valor do controller, com um pequeno ajuste se desejar
                    fontSize: fontSize,
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
