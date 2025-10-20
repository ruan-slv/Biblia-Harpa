// lib/src/screens/storeWrapper.dart

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:biblia_e_harpa/src/models/produtoModel.dart';
import 'package:biblia_e_harpa/src/services/api_service.dart';
import 'package:biblia_e_harpa/src/screens/StoreScreen.dart';

class StoreWrapper extends StatefulWidget {
  const StoreWrapper({super.key});

  @override
  State<StoreWrapper> createState() => _StoreWrapperState();
}

class _StoreWrapperState extends State<StoreWrapper> {
  late Future<List<ConnectivityResult>> _connectivityFuture;

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
      builder: (context, connectivitySnapshot) {
        // 1. Enquanto verifica a conexão, mostra um loading
        if (connectivitySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Se a verificação de conexão falhou
        if (connectivitySnapshot.hasError) {
          return _buildErrorWidget(
              context, "Erro ao verificar a conexão. Tente novamente.");
        }

        // 3. Se não há conexão com a internet
        if (connectivitySnapshot.hasData &&
            connectivitySnapshot.data!.contains(ConnectivityResult.none)) {
          return _buildErrorWidget(context,
              "Sem conexão com a internet. Por favor, verifique sua rede e tente novamente.");
        }

        // 4. Se HÁ conexão, busca os produtos da API
        return FutureBuilder<List<ProdutoModel>>(
          future: ApiServiceProduto.fetchProdutos(),
          builder: (context, productSnapshot) {
            // Enquanto busca os produtos, mostra um loading
            if (productSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Se a busca de produtos deu erro
            if (productSnapshot.hasError) {
              return _buildErrorWidget(context,
                  "Erro ao carregar os produtos. Tente novamente mais tarde.");
            }

            // Se a busca foi bem-sucedida, mas não retornou dados
            if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
              return _buildErrorWidget(context, "Nenhum produto encontrado.");
            }

            // Se tudo deu certo, exibe a StoreScreen com os produtos carregados
            return StoreScreen(produtos: productSnapshot.data!);
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
              // Ícone muda dependendo da mensagem
              message.contains("internet") ? Icons.wifi_off : Icons.error_outline,
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
