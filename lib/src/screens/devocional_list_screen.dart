import 'dart:convert';
import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/screens/text_devocional_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/buildMenuCard.dart';
import '../config.dart';
import '../keys/devocionalkey.dart';

class DevocionalList extends StatefulWidget {
  const DevocionalList({super.key});

  @override
  _DevocionalListState createState() => _DevocionalListState();
}

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

  // Abre o próximo devocional não lido (mesma lógica anterior)
  Future<void> _openNextUnread() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastTopic = prefs.getString('lastDevocionalTopic');
    final int lastIndex = prefs.getInt('lastDevocionalIndex') ?? -1;

    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/json/newDevocionalModel.json');
      final Map<String, dynamic> jsonResponse = jsonDecode(jsonString);

      String? foundTopic;
      int foundIndex = -1;

      // Primeiro tenta continuar no mesmo tópico
      if (lastTopic != null && jsonResponse.containsKey(lastTopic)) {
        final List<dynamic> items = jsonResponse[lastTopic] ?? [];
        for (int i = lastIndex + 1; i < items.length; i++) {
          final bool isRead =
              prefs.getBool('devocional_read_${lastTopic}_$i') ?? false;
          if (!isRead) {
            foundTopic = lastTopic;
            foundIndex = i;
            break;
          }
        }
      }

      // Se não encontrou, procura pelo primeiro não lido em todos os tópicos
      if (foundTopic == null) {
        for (String topic in topicos) {
          final List<dynamic> items = jsonResponse[topic] ?? [];
          for (int i = 0; i < items.length; i++) {
            final bool isRead =
                prefs.getBool('devocional_read_${topic}_$i') ?? false;
            if (!isRead) {
              foundTopic = topic;
              foundIndex = i;
              break;
            }
          }
          if (foundTopic != null) break;
        }
      }

      if (foundTopic != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DevocionalContentScreen(
                devo: foundTopic!, initialIndex: foundIndex),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Nenhum devocional não lido encontrado'),
                duration: Duration(seconds: 2)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao localizar devocional: ${e.toString()}'),
              duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  // Mostra menu com opção automática e histórico de tópicos acessados
  Future<void> _continuarLendo() async {
    final prefs = await SharedPreferences.getInstance();
    final String? histStr = prefs.getString('devocional_history');
    List<dynamic> history =
    histStr != null ? jsonDecode(histStr) as List<dynamic> : [];

    // Carrega JSON para obter tamanhos dos tópicos
    Map<String, dynamic> jsonResponse = {};
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/json/newDevocionalModel.json');
      jsonResponse = jsonDecode(jsonString);
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  'Próximo não lido',
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'Avança para o próximo devocional não lido',
                  style: TextStyle(
                    color: colorScheme.secondary.withOpacity(0.72),
                  ),
                ),
                leading: Icon(Icons.auto_fix_high, color: colorScheme.secondary),
                onTap: () {
                  Navigator.pop(context);
                  _openNextUnread();
                },
              ),
              Divider(height: 1, color: colorScheme.secondary.withOpacity(0.08)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Histórico',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${history.length}',
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (history.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Text(
                    'Nenhum tópico acessado ainda',
                    style: TextStyle(
                      color: colorScheme.secondary.withOpacity(0.76),
                    ),
                  ),
                ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index] as Map<String, dynamic>;
                    final String topic = entry['topic'] ?? '';
                    final int lastRead = (entry['lastReadIndex'] ?? -1) as int;
                    final List<dynamic> items = jsonResponse[topic] ?? [];
                    final int nextIndex =
                    (lastRead >= 0 && lastRead < items.length - 1)
                        ? lastRead + 1
                        : (lastRead >= 0 ? lastRead : 0);
                    final bool completed =
                        items.isNotEmpty && lastRead >= items.length - 1;
                    return ListTile(
                      leading: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          completed
                              ? Icons.check_circle_rounded
                              : Icons.menu_book_rounded,
                          color: completed ? Colors.green : colorScheme.secondary,
                        ),
                      ),
                      title: Text(
                        topic,
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        completed
                          ? 'Concluído (${items.length}/${items.length})'
                          : 'Continuar em ${nextIndex + 1} de ${items.length}',
                        style: TextStyle(
                          color: colorScheme.secondary.withOpacity(0.72),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.secondary.withOpacity(0.55),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DevocionalContentScreen(
                                    devo: topic, initialIndex: nextIndex)));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemasTab(List<String> devoList) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _filterController,
            decoration: InputDecoration(
              hintText: "Pesquisar livro",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            cursorColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: buildMenuCard(
            context,
            title: 'Continuar lendo',
            description:
                'Abra o próximo devocional não lido ou retome rapidamente um tema recente.',
            iconData: Icons.read_more_rounded,
            gradientColors: gradienteDevocional,
            onPressed: _continuarLendo,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
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
                      color: colorScheme.secondary.withOpacity(0.05),
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
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DevocionalContentScreen(
                            devo: devocionalTopic, initialIndex: 0),
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
                              child: ValueListenableBuilder<double>(
                                valueListenable: FontSizeController.fontSizeNotifier,
                                builder: (context, fontSize, _) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              devocionalTopic,
                                              style: TextStyle(
                                                fontSize: fontSize,
                                                color: colorScheme.secondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "$percentage%",
                                            style: TextStyle(
                                              fontSize: fontSize * 0.8,
                                              color: colorScheme.secondary
                                                  .withOpacity(0.7),
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
                                              .withOpacity(0.72),
                                        ),
                                      ),
                                    ],
                                  );
                                },
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const CustomAppBar(
        title: "Devocional",
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: _buildTemasTab(filteredDevocionalTopic),
    );
  }
}
