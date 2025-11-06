// lib/src/screens/informacaoWrapper.dart

import 'package:flutter/material.dart';
import 'package:biblia_e_harpa/src/screens/informacaoScreen.dart';

class InformacaoWrapper extends StatefulWidget {
  const InformacaoWrapper({super.key});

  @override
  State<InformacaoWrapper> createState() => _InformacaoWrapperState();
}

class _InformacaoWrapperState extends State<InformacaoWrapper> {
  @override
  Widget build(BuildContext context) {
    // A única responsabilidade do Wrapper agora é renderizar a InformacaoScreen.
    // A própria InformacaoScreen cuidará de buscar os dados.
    return const InformacaoScreen();
  }
}
