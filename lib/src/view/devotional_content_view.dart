/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:convert';
import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/view/component/bottombar.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:biblia_e_harpa/src/view_model/service/continue_reading_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevotionalTextModel {
  final String versiculo;
  final String texto;
  final String oracao;

  DevotionalTextModel(
      {required this.versiculo, required this.texto, required this.oracao});

  factory DevotionalTextModel.fromJson(Map<String, dynamic> json) {
    return DevotionalTextModel(
      versiculo: json['versiculo'] ?? json['Versiculo'] ?? 'versiculo não encontrado',
      texto: json['texto'] ?? json['Texto'] ?? 'Texto não encontrado',
      oracao: json['Oração'] ?? json['oracao'] ?? 'Oração não encontrada',
    );
  }
}

class DevotionalContentView extends StatefulWidget {
  const DevotionalContentView(
      {super.key, required this.devo, this.initialIndex = 0});

  final String devo;
  final int initialIndex;

  @override
  State<DevotionalContentView> createState() => _DevotionalContentViewState();
}

class _DevotionalContentViewState extends State<DevotionalContentView> {
  static const _continueReadingService = ContinueReadingService();
  List<DevotionalTextModel> devocionais = [];
  int currentIndex = 0;
  bool isRead = false;
  bool isLoading = true;
  String? loadError;
  String? activeTopic;

  @override
  void initState() {
    super.initState();
    loadDevocionais();
  }

  Future<void> loadDevocionais() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/newDevocionalModel.json');
      final decoded = jsonDecode(jsonString);
      final jsonResponse = Map<String, dynamic>.from(decoded as Map);
      final resolvedTopic = _resolveTopic(jsonResponse, widget.devo);
      final topicDevocionais = resolvedTopic == null
          ? const <dynamic>[]
          : List<dynamic>.from(
              jsonResponse[resolvedTopic] as List? ?? const []);

      final loadedDevocionais = topicDevocionais
          .where((json) => json is Map)
          .map((json) => DevotionalTextModel.fromJson(
                Map<String, dynamic>.from(json),
              ))
          .toList();

      int idx = widget.initialIndex;
      if (idx < 0) {
        idx = 0;
      }
      if (loadedDevocionais.isNotEmpty && idx >= loadedDevocionais.length) {
        idx = loadedDevocionais.length - 1;
      }
      if (!mounted) return;
      setState(() {
        devocionais = loadedDevocionais;
        currentIndex = loadedDevocionais.isNotEmpty ? idx : 0;
        activeTopic = resolvedTopic;
        isLoading = false;
        if (loadedDevocionais.isEmpty) {
          loadError = 'Nenhum conteúdo encontrado para este devocional.';
        }
      });

      if (loadedDevocionais.isNotEmpty) {
        await _saveLastIndex();
        await _checkReadStatus();
        final prefs = await SharedPreferences.getInstance();
        final int lastReadForTopic =
            prefs.getInt('devocional_last_read_${_topicKey}') ?? -1;
        await _addOrUpdateHistory(lastReadForTopic);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        devocionais = [];
        isLoading = false;
        activeTopic = null;
        loadError = 'Não foi possível carregar este devocional.';
      });
    }
  }

  String get _topicKey => activeTopic ?? widget.devo;

  String? _resolveTopic(Map<String, dynamic> jsonResponse, String requested) {
    final exactContent = jsonResponse[requested];
    if (exactContent is List && exactContent.isNotEmpty) {
      return requested;
    }

    final normalizedRequest = _normalizeTopic(requested);
    for (final topic in jsonResponse.keys) {
      final content = jsonResponse[topic];
      if (content is List &&
          content.isNotEmpty &&
          _normalizeTopic(topic) == normalizedRequest) {
        return topic;
      }
    }

    return null;
  }

  String _normalizeTopic(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }

  Future<void> _checkReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'devocional_read_${_topicKey}_$currentIndex';
    if (!mounted) return;
    setState(() {
      isRead = prefs.getBool(key) ?? false;
    });
  }

  Future<void> _toggleReadStatus() async {
    if (devocionais.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'devocional_read_${_topicKey}_$currentIndex';

    if (!mounted) return;
    setState(() {
      isRead = !isRead;
    });

    await prefs.setBool(key, isRead);
    if (isRead) {
      await prefs.setInt('devocional_last_read_${_topicKey}', currentIndex);
      await _addOrUpdateHistory(currentIndex);
    } else {
      await prefs.remove('devocional_last_read_${_topicKey}');
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

    sb.writeln("Tópico do Devocional: $_topicKey");
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
    });
    _saveLastIndex();
    _checkReadStatus();
  }

  Future<void> _saveLastIndex() async {
    if (devocionais.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastDevocionalIndex', currentIndex);
    await prefs.setString('lastDevocionalTopic', _topicKey);
    await _continueReadingService.saveDevotional(
      topic: _topicKey,
      index: currentIndex,
    );
  }

  Future<void> _addOrUpdateHistory(int lastReadIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final String? histStr = prefs.getString('devocional_history');
    List<dynamic> list =
        histStr != null ? jsonDecode(histStr) as List<dynamic> : [];

    list.removeWhere((e) => e['topic'] == _topicKey);

    list.insert(0, {
      'topic': _topicKey,
      'lastReadIndex': lastReadIndex,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (list.length > 50) list = list.sublist(0, 50);

    await prefs.setString('devocional_history', jsonEncode(list));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || devocionais.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      final title = loadError ?? 'Devocional não encontrado.';

      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: CustomAppBar(
          title: _topicKey,
          centerTitle: false,
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 48,
                        color: colorScheme.secondary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Verifique se há conteúdo disponível no arquivo de devocionais.',
                        style: TextStyle(
                          color: colorScheme.secondary.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    final devocional = devocionais[currentIndex];
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: _topicKey,
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () async {
              final String devocionalText = _getDataForSharing();
              await SharePlus.instance.share(
                ShareParams(
                  text: devocionalText,
                  subject: "Devocional: $_topicKey - ${devocional.versiculo}",
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
            padding: const EdgeInsets.all(10.0),
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
                        Text(
                          devocional.versiculo,
                          style: TextStyle(
                            fontSize: settings.fontSize,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Reflexão',
                          style: TextStyle(
                            fontSize: settings.fontSize + 2,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          devocional.texto,
                          style: TextStyle(
                            fontSize: settings.fontSize,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Oração',
                          style: TextStyle(
                            fontSize: settings.fontSize + 2,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          devocional.oracao,
                          style: TextStyle(
                            fontSize: settings.fontSize,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
