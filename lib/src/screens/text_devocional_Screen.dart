// lib/src/screens/devocional_content_screen.dart

import 'dart:convert';

import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextModel {
  final String versiculo;
  final String texto;
  final String oracao;

  TextModel(
      {required this.versiculo, required this.texto, required this.oracao});

  factory TextModel.fromJson(Map<String, dynamic> json) {
    return TextModel(
      versiculo: json['versiculo'] ?? 'versiculo não encontrado',
      texto: json['texto'] ?? 'Texto não encontrado',
      oracao: json['Oração'] ?? 'Oração não encontrada',
    );
  }
}

class DevocionalContentScreen extends StatefulWidget {
  const DevocionalContentScreen(
      {super.key, required this.devo, this.initialIndex = 0});

  final String devo;
  final int initialIndex;

  @override
  _DevocionalContentScreenState createState() =>
      _DevocionalContentScreenState();
}

class _DevocionalContentScreenState extends State<DevocionalContentScreen> {
  List<TextModel> devocionais = [];
  int currentIndex = 0;
  bool isRead = false; // Variável para controlar se o atual foi lido

  @override
  void initState() {
    super.initState();
    loadDevocionais();
  }

  Future<void> loadDevocionais() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/newDevocionalModel.json');
      final Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
      final List<dynamic> topicDevocionais = jsonResponse[widget.devo] ?? [];
      setState(() {
        devocionais =
            topicDevocionais.map((json) => TextModel.fromJson(json)).toList();
      });

      // Aplica índice inicial (garantindo limites)
      int idx = widget.initialIndex;
      if (idx < 0) idx = 0;
      if (devocionais.isNotEmpty && idx >= devocionais.length)
        idx = devocionais.length - 1;
      setState(() {
        currentIndex = devocionais.isNotEmpty ? idx : 0;
      });

      // Salva a posição atual e verifica o status de leitura
      await _saveLastIndex();
      _checkReadStatus();

      // Atualiza histórico de tópicos acessados (usa último lido salvo)
      final prefs = await SharedPreferences.getInstance();
      final int lastReadForTopic =
          prefs.getInt('devocional_last_read_${widget.devo}') ?? -1;
      await _addOrUpdateHistory(lastReadForTopic);
    } catch (e) {
      setState(() {
        devocionais = [];
      });
    }
  }

  // Verifica se o devocional atual já foi lido
  Future<void> _checkReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Chave única: devocional_read_TEMA_INDEX
    final key = 'devocional_read_${widget.devo}_$currentIndex';
    setState(() {
      isRead = prefs.getBool(key) ?? false;
    });
  }

  // Alterna entre lido e não lido
  Future<void> _toggleReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'devocional_read_${widget.devo}_$currentIndex';

    setState(() {
      isRead = !isRead;
    });

    await prefs.setBool(key, isRead);
    if (isRead) {
      await prefs.setInt('devocional_last_read_${widget.devo}', currentIndex);
      await _addOrUpdateHistory(currentIndex);
    } else {
      await prefs.remove('devocional_last_read_${widget.devo}');
      await _addOrUpdateHistory(-1);
    }

    await _saveLastIndex();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isRead ? "Marcado como lido" : "Marcado como não lido"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void nextDevocional() {
    if (currentIndex < devocionais.length - 1) {
      setState(() {
        currentIndex++;
      });
      _saveLastIndex();
      _checkReadStatus(); // Verifica status ao mudar
    }
  }

  void previousDevocional() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _saveLastIndex();
      _checkReadStatus(); // Verifica status ao mudar
    }
  }

  String _getDataForSharing() {
    if (devocionais.isEmpty || currentIndex >= devocionais.length) {
      return "Nenhum conteúdo devocional para compartilhar no momento.";
    }
    final devocionalAtual = devocionais[currentIndex];
    StringBuffer sb = StringBuffer();

    sb.writeln("Tópico do Devocional: ${widget.devo}");
    sb.writeln("\n");
    sb.writeln("📖 versiculo:");
    sb.writeln(devocionalAtual.versiculo);
    sb.writeln("\n✝️ Reflexão:");
    sb.writeln(devocionalAtual.texto);
    sb.writeln("\n🙏 Oração:");
    sb.writeln(devocionalAtual.oracao);

    return sb.toString();
  }

  void initialDevocional() {
    setState(() {
      currentIndex = 0;
      _saveLastIndex();
    });
    loadDevocionais();
  }

  Future<void> _saveLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastDevocionalIndex', currentIndex);
    await prefs.setString('lastDevocionalTopic', widget.devo);
  }

  // Mantém histórico de tópicos acessados e do índice/último lido
  Future<void> _addOrUpdateHistory(int lastReadIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final String? histStr = prefs.getString('devocional_history');
    List<dynamic> list =
        histStr != null ? jsonDecode(histStr) as List<dynamic> : [];

    // Remove se já existir
    list.removeWhere((e) => e['topic'] == widget.devo);

    // Insere no topo
    list.insert(0, {
      'topic': widget.devo,
      'lastReadIndex': lastReadIndex,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Limita histórico razoavelmente
    if (list.length > 50) list = list.sublist(0, 50);

    await prefs.setString('devocional_history', jsonEncode(list));
  }

  @override
  Widget build(BuildContext context) {
    if (devocionais.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(widget.devo,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          actions: [
            IconButton(
              onPressed: initialDevocional,
              icon: const Icon(Icons.refresh),
              color: Theme.of(context).colorScheme.secondary,
              tooltip: "Reiniciar o devocional",
            ),
          ],
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Nenhum devocional encontrado para este tema'),
        ),
      );
    }

    final devocional = devocionais[currentIndex];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.devo,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        centerTitle: true,
        actions: [
          // Botão de marcar lido também na AppBar
          IconButton(
            onPressed: _toggleReadStatus,
            icon: Icon(
              isRead ? Icons.check_circle : Icons.check_circle_outline,
              color: isRead
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary,
            ),
            tooltip: isRead ? "Marcar como não lido" : "Marcar como lido",
          ),
          IconButton(
            onPressed: () {
              final String devocionalText = _getDataForSharing();
              Share.share(
                devocionalText,
                subject: "Devocional: ${widget.devo} - ${devocional.versiculo}",
              );
            },
            icon: const Icon(Icons.share),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Indicador visual de progresso dentro do tópico
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        "Devocional ${currentIndex + 1} de ${devocionais.length}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.6),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: FontSizeController.fontSizeNotifier,
                      builder: (context, fontSize, _) {
                        return Text(
                          devocional.versiculo,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<double>(
                      valueListenable: FontSizeController.fontSizeNotifier,
                      builder: (context, fontSize, _) {
                        return Text(
                          'Reflexão',
                          style: TextStyle(
                            fontSize: fontSize + 2,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<double>(
                      valueListenable: FontSizeController.fontSizeNotifier,
                      builder: (context, fontSize, _) {
                        return Text(
                          devocional.texto,
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<double>(
                      valueListenable: FontSizeController.fontSizeNotifier,
                      builder: (context, fontSize, _) {
                        return Text(
                          'Oração',
                          style: TextStyle(
                            fontSize: fontSize + 2,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<double>(
                      valueListenable: FontSizeController.fontSizeNotifier,
                      builder: (context, fontSize, _) {
                        return Text(
                          devocional.oracao,
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // --- BOTÕES DE NAVEGAÇÃO ---
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0,
                          bottom: 80), // Bottom extra por causa do FAB
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed:
                                currentIndex > 0 ? previousDevocional : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              elevation: 2,
                            ),
                            child: Text(
                              "Anterior",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: currentIndex < devocionais.length - 1
                                ? nextDevocional
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              elevation: 2,
                            ),
                            child: Text(
                              "Próximo",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botão Para marcar texto como lido
                    const SizedBox(height: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: FloatingActionButton.extended(
                        onPressed: _toggleReadStatus,
                        backgroundColor: isRead
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                        icon: Icon(
                          isRead ? Icons.check_circle : Icons.circle_outlined,
                          color: isRead
                              ? Colors.white
                              : Theme.of(context).colorScheme.secondary,
                        ),
                        label: Text(
                          isRead ? "Concluído" : "Marcar como lido",
                          style: TextStyle(
                            color: isRead
                                ? Colors.white
                                : Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
