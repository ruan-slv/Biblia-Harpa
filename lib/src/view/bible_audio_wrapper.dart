/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'bible_audio_list_view.dart';
import 'component/connectivity_error_view.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<List<ConnectivityResult>>(
        future: _connectivityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const ConnectivityErrorView(
              message: "Erro ao verificar a conexão. Tente novamente.",
            );
          }

          if (snapshot.hasData && !snapshot.data!.contains(ConnectivityResult.none)) {
            return const BibleAudioListView(isOffline: false);
          }

          return ConnectivityErrorView(
            message:
                "Sem conexão com a internet. Conecte-se para ouvir áudios online ou acesse seus downloads.",
            onOfflinePressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BibleAudioListView(isOffline: true),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
