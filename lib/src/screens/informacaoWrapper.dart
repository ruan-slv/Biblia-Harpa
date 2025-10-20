// lib/src/screens/informacaoWrapper.dart

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:biblia_e_harpa/src/models/avisoModel.dart';
import 'package:biblia_e_harpa/src/services/aviso_api_service.dart';
import 'package:biblia_e_harpa/src/screens/informacaoScreen.dart';

class InformacaoWrapper extends StatefulWidget {
  const InformacaoWrapper({super.key});

  @override
  State<InformacaoWrapper> createState() => _InformacaoWrapperState();
}

class _InformacaoWrapperState extends State<InformacaoWrapper> {
  late final Future<List<ConnectivityResult>> _connectivityFuture;

  @override
  void initState() {
    super.initState();
    _connectivityFuture = Connectivity().checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConnectivityResult>>(
      future: _connectivityFuture,
      builder: (context, connectivitySnapshot) {
        if (connectivitySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (connectivitySnapshot.hasError) {
          return _buildErrorWidget(
              context, "Erro ao verificar a conexão. Tente novamente.");
        }

        if (connectivitySnapshot.hasData &&
            connectivitySnapshot.data!.contains(ConnectivityResult.none)) {
          return _buildErrorWidget(context,
              "Sem conexão com a internet. Por favor, verifique sua rede e tente novamente.");
        }

        // Se há conexão, busca os avisos
        return FutureBuilder<List<AvisoModel>>(
          future: AvisoServiceAPI.fetchAvisos(),
          builder: (context, avisoSnapshot) {
            if (avisoSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (avisoSnapshot.hasError) {
              return _buildErrorWidget(context,
                  "Erro ao carregar os avisos. Tente novamente mais tarde.");
            }

            if (!avisoSnapshot.hasData || avisoSnapshot.data!.isEmpty) {
              return _buildErrorWidget(context, "Nenhum aviso encontrado.");
            }

            // Se tudo deu certo, exibe a InformacaoScreen com os dados
            return InformacaoScreen(avisos: avisoSnapshot.data!);
          },
        );
      },
    );
  }

  // Widget auxiliar para exibir mensagens de erro
  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              message.contains("internet")
                  ? Icons.wifi_off
                  : Icons.info_outline,
              size: 60,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
