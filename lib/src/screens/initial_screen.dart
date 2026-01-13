// lib/src/screens/initial_screen.dart

import 'dart:convert';
import 'dart:math';

import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/screens/homeAudioScreen.dart';

import 'package:biblia_e_harpa/src/screens/settingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/screens/text_devocional_Screen.dart';
import 'package:biblia_e_harpa/src/keys/devocionalkey.dart';
import 'bible_list_screen.dart';
import 'devocional_list_screen.dart';
import 'harpa_list_screen.dart';

// Data class for Palavra do Dia
class Data {
  final int id;
  final String texto;
  final String versiculo;

  Data({required this.id, required this.texto, required this.versiculo});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"] ?? 0,
      texto: json["texto"] ?? "Texto indisponível",
      versiculo: json["versiculo"] ?? "versiculo indisponível",
    );
  }
}

class Initial extends StatefulWidget {
  const Initial({super.key});

  @override
  State<Initial> createState() => _InitialState();
}

class _InitialState extends State<Initial> {
  Data? palavraAtual;
  DateTime? ultimaAtualizacao;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPalavraDoDia();
  }

  Future<void> _loadPalavraDoDia() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastUpdate = prefs.getString("last_update");
    final String? palavraSalva = prefs.getString("palavra_atual");

    final now = DateTime.now();
    final precisaAtualizar = lastUpdate == null ||
        DateTime.parse(lastUpdate).difference(now).inDays.abs() >= 1;

    if (!precisaAtualizar && palavraSalva != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(palavraSalva);
        setState(() {
          palavraAtual = Data.fromJson(json);
          ultimaAtualizacao = DateTime.parse(lastUpdate);
        });
      } catch (e) {
        //_mostrarErro("Erro ao carregar palavra salva: ${e.toString()}");
      }
      return;
    }

    // --- AQUI COMEÇA A LÓGICA DE ATUALIZAÇÃO ---
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString("assets/json/palavraDoDia.json");
      final List<dynamic> jsonResponse = jsonDecode(jsonString)["palavraDoDia"];

      if (jsonResponse.isEmpty) {
        setState(() {
          palavraAtual = Data(
            id: 0,
            texto: "Nenhuma palavra disponível",
            versiculo: "",
          );
        });
        return;
      }

      final randomIndex = Random().nextInt(jsonResponse.length - 1);
      final selectedPalavra = jsonResponse[randomIndex];

      setState(() {
        palavraAtual = Data.fromJson(selectedPalavra);
        ultimaAtualizacao = now;
      });

      await prefs.setString("last_update", now.toIso8601String());
      await prefs.setString("palavra_atual", jsonEncode(selectedPalavra));

      // --- NOVO: Agenda a notificação para o dia seguinte ---
      // Como a palavra acabou de mudar, agendamos um lembrete para amanhã
      // para avisar que haverá uma NOVA palavra novamente.
    } catch (e) {
      //_mostrarErro("Erro ao carregar palavra salva: ${e.toString()}");
    }
  }

  void _compartilharPalavra() {
    if (palavraAtual != null) {
      Share.share("${palavraAtual!.texto} \n ${palavraAtual!.versiculo}");
    }
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
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Próximo não lido'),
                subtitle:
                    const Text('Avança para o próximo devocional não lido'),
                leading: const Icon(Icons.auto_fix_high),
                onTap: () {
                  Navigator.pop(context);
                  _openNextUnread();
                },
              ),
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Histórico',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${history.length}')
                  ],
                ),
              ),
              if (history.isEmpty)
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Nenhum tópico acessado ainda',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary))),
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
                      title: Text(topic),
                      subtitle: Text(completed
                          ? 'Concluído (${items.length}/${items.length})'
                          : 'Continuar em ${nextIndex + 1} de ${items.length}'),
                      trailing: completed
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
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

  @override
  Widget build(BuildContext context) {
    // ... (O resto do método build permanece exatamente o mesmo)
    final List<Widget> pages = [
      SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 150),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    palavraAtual?.versiculo.isNotEmpty == true
                                        ? palavraAtual!.versiculo
                                        : "versiculo não encontrado",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ValueListenableBuilder<double>(
                                    valueListenable:
                                        FontSizeController.fontSizeNotifier,
                                    builder: (context, fontSize, _) {
                                      return Text(
                                        palavraAtual?.texto ??
                                            "Palavra do dia não encontrada",
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          fontStyle: FontStyle.italic,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        textAlign: TextAlign.justify,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _compartilharPalavra,
                                    icon: Icon(
                                      Icons.share,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    label: Text(
                                      "Compartilhar",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .background,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildMenuCard(context, 'Continuar lendo',
                            Icons.read_more, gradienteAudios, _continuarLendo),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildMenuCard(
                                context,
                                'Bíblia',
                                Icons.menu_book_rounded,
                                gradienteAudios,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const BibleList()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMenuCard(
                                context,
                                'Harpa',
                                Icons.music_note,
                                gradienteAudios,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HarpaList()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildMenuCard(
                                context,
                                'Devocional',
                                Icons.auto_stories,
                                gradienteAudios,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DevocionalList()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMenuCard(
                                context,
                                'Áudios',
                                Icons.headphones_outlined,
                                gradienteAudios,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Homeaudioscreen()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            return SingleChildScrollView(
              child: content,
            );
          },
        ),
      ),
      SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Bíblia e Harpa sem anúncios",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.secondary,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.primary,
            ),
            icon: Icon(
              Icons.home_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: "Inicio",
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: "Configurações",
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData iconData,
    List<Color> gradientColors,
    VoidCallback onPressed, {
    double? height,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: height, // permite passar altura opcional
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors.length >= 2
                          ? gradientColors
                          : [gradientColors.first, gradientColors.first],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops:
                          gradientColors.length == 3 ? [0.0, 0.5, 1.0] : null,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: gradientColors.last.withOpacity(0.5),
                          blurRadius: 5,
                          offset: const Offset(0, 2))
                    ]),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
