import 'dart:convert';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/screens/text_devocional_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../keys/devocionalkey.dart';

/// Exibe os temas devocionais e o progresso de leitura de cada um.
class DevocionalList extends StatefulWidget {
  const DevocionalList({super.key});

  @override
  _DevocionalListState createState() => _DevocionalListState();
}

/// Carrega os temas, calcula seu progresso e aplica o filtro de pesquisa.
class _DevocionalListState extends State<DevocionalList> {
  List<String> filteredDevocionalTopic = [];
  final TextEditingController _filterController = TextEditingController();
  final String _jsonPath =
      "assets/json/newDevocionalModel.json"; // Certifique-se que é o JSON correto

  // Armazena a estrutura completa do JSON para saber quantos itens tem em cada tópico
  Map<String, dynamic> fullDevocionalData = {};

  // Armazena o progresso de cada tópico (0.0 a 1.0)
  Map<String, double> topicsProgress = {};

  @override
  void initState() {
    super.initState();
    filteredDevocionalTopic = topicos;
    _filterController.addListener(_filterDevocional);
    _loadDataAndProgress();
  }

  // Quando voltar da tela de leitura, atualiza o progresso
  void _refreshProgress() {
    _calculateAllProgress();
  }

  @override
  void dispose() {
    _filterController.removeListener(_filterDevocional);
    _filterController.dispose();
    super.dispose();
  }

  // Carrega o JSON e depois calcula o progresso
  Future<void> _loadDataAndProgress() async {
    try {
      final String response = await rootBundle.loadString(_jsonPath);
      final data = json.decode(response);

      if (mounted) {
        setState(() {
          fullDevocionalData = data;
        });
        await _calculateAllProgress();
      }
    } catch (e) {
      print("Erro ao carregar JSON para progresso: $e");
    }
  }

  // Calcula o progresso para todos os tópicos
  Future<void> _calculateAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, double> tempProgress = {};

    for (String topic in topicos) {
      List<dynamic> items = fullDevocionalData[topic] ?? [];
      if (items.isEmpty) {
        tempProgress[topic] = 0.0;
        continue;
      }

      int readCount = 0;
      for (int i = 0; i < items.length; i++) {
        // Usa a mesma chave definida na tela de conteúdo
        bool isRead = prefs.getBool('devocional_read_${topic}_$i') ?? false;
        if (isRead) readCount++;
      }

      tempProgress[topic] = readCount / items.length;
    }

    if (mounted) {
      setState(() {
        topicsProgress = tempProgress;
      });
    }
  }

  void _filterDevocional() {
    setState(() {
      filteredDevocionalTopic = topicos
          .where((devo) =>
              devo.toLowerCase().contains(_filterController.text.toLowerCase()))
          .toList();
    });
  }

  Widget _buildTemasTab(List<String> devoList) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _filterController,
            // keyboardType: TextInputType.number, // Removido pois busca é por texto
            decoration: InputDecoration(
              hintText: "Pesquisar Tema",
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
              prefixIcon: Icon(Icons.search,
                  color: Theme.of(context).colorScheme.secondary),
              suffixIcon: IconButton(
                onPressed: () => _filterController.clear(),
                icon: Icon(Icons.clear,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            cursorColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: devoList.length,
            itemBuilder: (context, index) {
              final devocionalTopic = devoList[index];
              final double progress = topicsProgress[devocionalTopic] ?? 0.0;
              final int percentage = (progress * 100).toInt();

              return Card(
                // Usando Card para ficar visualmente melhor com a barra
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Theme.of(context)
                    .colorScheme
                    .background, // Transparente ou cor de fundo
                elevation: 0,
                child: InkWell(
                  onTap: () async {
                    // Aguarda o retorno para atualizar a barra
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DevocionalContentScreen(
                            devo: devocionalTopic, initialIndex: 0),
                      ),
                    );
                    _refreshProgress(); // Atualiza ao voltar
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            progress >= 1.0
                                ? Icons.check_circle
                                : Icons.menu_book_rounded,
                            color: progress >= 1.0
                                ? Colors.green
                                : Theme.of(context).colorScheme.secondary,
                          ),
                          title: ValueListenableBuilder<double>(
                            valueListenable:
                                FontSizeController.fontSizeNotifier,
                            builder: (context, fontSize, _) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      devocionalTopic,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "$percentage%",
                                    style: TextStyle(
                                      fontSize: fontSize * 0.8,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        // Barra de Progresso
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1.0
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.secondary),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(
                            height: 1,
                            color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text("Devocional",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
      ),
      body: _buildTemasTab(filteredDevocionalTopic),
    );
  }
}
