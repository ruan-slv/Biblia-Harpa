import 'dart:convert';
import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:biblia_e_harpa/src/view/devotional_content_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/config.dart';
import '../keys/devocional_key.dart';

class DevotionalListView extends StatefulWidget {
  const DevotionalListView({super.key});

  @override
  State<DevotionalListView> createState() => _DevotionalListViewState();
}

class _DevotionalListViewState extends State<DevotionalListView> {
  List<String> filteredDevocionalTopic = [];
  final TextEditingController _filterController = TextEditingController();
  final String _jsonPath = "assets/json/newDevocionalModel.json";

  Map<String, dynamic> fullDevocionalData = {};
  Map<String, double> topicsProgress = {};

  @override
  void initState() {
    super.initState();
    filteredDevocionalTopic = topicos;
    _filterController.addListener(_filterDevocional);
    _loadDataAndProgress();
  }

  void _refreshProgress() {
    _calculateAllProgress();
  }

  @override
  void dispose() {
    _filterController.removeListener(_filterDevocional);
    _filterController.dispose();
    super.dispose();
  }

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
    } catch (_) {}
  }

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
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsViewModel>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: _filterController,
            decoration: InputDecoration(
              hintText: "Pesquisar livro",
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
              prefixIcon: Icon(Icons.search,
                  color: Theme.of(context).colorScheme.secondary),
              suffixIcon: IconButton(
                onPressed: () {
                  _filterController.clear();
                },
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
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.only(top: 10, bottom: 4, left: 10, right: 10),
            itemCount: devoList.length,
            itemBuilder: (context, index) {
              final devocionalTopic = devoList[index];
              final double progress = topicsProgress[devocionalTopic] ?? 0.0;
              final int percentage = (progress * 100).toInt();

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await navigator.push(
                        MaterialPageRoute(
                          builder: (context) => DevotionalContentView(
                            devo: devocionalTopic,
                            initialIndex: 0,
                          ),
                        ),
                      );
                      _refreshProgress();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  progress >= 1.0
                                      ? Icons.check_circle_rounded
                                      : Icons.auto_stories_rounded,
                                  color: progress >= 1.0
                                      ? Colors.green
                                      : colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            devocionalTopic,
                                            style: TextStyle(
                                              fontSize: settings.fontSize,
                                              color: colorScheme.secondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "$percentage%",
                                          style: TextStyle(
                                            fontSize: settings.fontSize * 0.8,
                                            color: colorScheme.secondary
                                                .withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      progress >= 1.0
                                          ? "Tema concluído"
                                          : "Toque para iniciar ou continuar a leitura",
                                      style: TextStyle(
                                        color: colorScheme.secondary
                                            .withValues(alpha: 0.72),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: colorScheme.surface,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1.0
                                    ? Colors.green
                                    : gradienteDevocional.first,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(
        title: "Devocional",
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: _buildTemasTab(filteredDevocionalTopic),
    );
  }
}
