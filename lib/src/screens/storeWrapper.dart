// C:/Users/ruan/Documents/Biblia-Harpa/lib/src/screens/storeWrapper.dart

import 'package:flutter/material.dart';
import 'package:biblia_e_harpa/src/services/api_service.dart'; // Verifique o caminho
import '../models/produtoModel.dart'; // Verifique o caminho
import 'StoreScreen.dart'; // Importa a tela da loja

class StoreWrapper extends StatefulWidget {
  const StoreWrapper({super.key});

  @override
  State<StoreWrapper> createState() => _StoreWrapperState();
}

class _StoreWrapperState extends State<StoreWrapper> {
  // O wrapper não precisa mais buscar os dados,
  // pois a própria StoreScreen já faz isso em seu initState.
  // Isso simplifica o wrapper consideravelmente.

  @override
  Widget build(BuildContext context) {
    // A única responsabilidade do Wrapper agora é renderizar a StoreScreen.
    return const StoreScreen();
  }
}
