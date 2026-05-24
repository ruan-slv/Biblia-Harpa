import 'dart:convert';
import 'package:biblia_e_harpa/src/components/app_bar_component.dart';
import 'package:biblia_e_harpa/src/components/bottombar.dart';
import 'package:biblia_e_harpa/src/controllers/font_size_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool isRead = false;

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

      int idx = widget.initialIndex;
      if (idx < 0) idx = 0;
      if (devocionais.isNotEmpty && idx >= devocionais.length)
        idx = devocionais.length - 1;
      setState(() {
        currentIndex = devocionais.isNotEmpty ? idx : 0;
      });

      await _saveLastIndex();
      _checkReadStatus();

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

  Future<void> _checkReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'devocional_read_${widget.devo}_$currentIndex';
    setState(() {
      isRead = prefs.getBool(key) ?? false;
    });
  }

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
      _checkReadStatus();
    }
  }

  void previousDevocional() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _saveLastIndex();
      _checkReadStatus();
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

  Future<void> _addOrUpdateHistory(int lastReadIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final String? histStr = prefs.getString('devocional_history');
    List<dynamic> list =
        histStr != null ? jsonDecode(histStr) as List<dynamic> : [];

    list.removeWhere((e) => e['topic'] == widget.devo);

    list.insert(0, {
      'topic': widget.devo,
      'lastReadIndex': lastReadIndex,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (list.length > 50) list = list.sublist(0, 50);

    await prefs.setString('devocional_history', jsonEncode(list));
  }

  @override
  Widget build(BuildContext context) {
    if (devocionais.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final devocional = devocionais[currentIndex];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: widget.devo,
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () async {
              final String devocionalText = _getDataForSharing();
              await SharePlus.instance.share(
                ShareParams(
                  text: devocionalText,
                  subject: "Devocional: ${widget.devo} - ${devocional.versiculo}",
                ),
              );
            },
            icon: const Icon(Icons.share),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        canGoBack: currentIndex > 0,
        canGoNext: currentIndex < devocionais.length - 1,
        onPrevious: previousDevocional,
        onNext: nextDevocional,
        topChild: InkWell(
          onTap: _toggleReadStatus,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isRead
                  ? Colors.green.withValues(alpha: 0.16)
                  : colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRead
                    ? Colors.green.withValues(alpha: 0.45)
                    : colorScheme.secondary.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: isRead ? Colors.green : colorScheme.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isRead
                        ? Icons.check_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isRead ? Colors.white : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isRead ? "Devocional concluído" : "Marcar como lido",
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRead
                            ? "Toque para marcar como não lido."
                            : "Toque para marcar como lido.",
                        style: TextStyle(
                          color: colorScheme.secondary.withValues(alpha: 0.72),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            "Devocional ${currentIndex + 1} de ${devocionais.length}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.6),
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
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ]),
            ), padding: EdgeInsetsGeometry.all(10.0),
          ),
        ],
      ),
    );
  }
}
