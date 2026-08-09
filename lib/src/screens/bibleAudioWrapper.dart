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
  late final Future<List<ConnectivityResult>> _connectivityFuture;

  @override
  void initState() {
    super.initState();
    _connectivityFuture = Connectivity().checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      // Opcional: Se você quiser uma AppBar nesta tela de carregamento/erro
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

          if (snapshot.hasData) {
            final connectivityResult = snapshot.data!;
            // Se TEM internet
            if (!connectivityResult.contains(ConnectivityResult.none)) {
              // Aqui retornamos a tela principal.
              // OBS: A Bibleaudiosscreen provavelmente já tem seu próprio Scaffold,
              // então ela vai cobrir o Scaffold atual, o que é normal.
              return Bibleaudiosscreen(isOffline: false);
            }
          }

          // Se NÃO TEM internet
          return _buildErrorWidget(
            context,
            "Sem conexão com a internet. Conecte-se para baixar novos áudios ou acesse seus downloads.",
            showOfflineButton: true,
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message,
      {bool showOfflineButton = false}) {
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
                    fontSize: fontSize,
                  ),
                );
              },
            ),
            if (showOfflineButton) ...[
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Bibleaudiosscreen(isOffline: true),
                    ),
                  );
                },
                icon: Icon(
                  Icons.offline_pin,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                label: ValueListenableBuilder<double>(
                  valueListenable: FontSizeController.fontSizeNotifier,
                  builder: (context, fontSize, _) {
                    return Text(
                      "Áudios Baixados",
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
