import 'package:biblia_e_harpa/src/screens/bibleAudioWrapper.dart';
import 'package:biblia_e_harpa/src/screens/harpaAudioScreen.dart';
import 'package:biblia_e_harpa/src/screens/bibleAudiosScreen.dart';
import 'package:biblia_e_harpa/src/screens/harpaAudioWrapper.dart';
import 'package:biblia_e_harpa/src/screens/playlistScreen.dart';
import 'package:flutter/material.dart';

/// Fornece a navegação principal entre os áudios da Bíblia e da Harpa.
class Homeaudioscreen extends StatefulWidget {
  const Homeaudioscreen({super.key});

  @override
  State<Homeaudioscreen> createState() => _Homeaudioscreen();
}

/// Sincroniza a aba selecionada com o conteúdo de áudio correspondente.
class _Homeaudioscreen extends State<Homeaudioscreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // aqui, apenas a aba "Personalizados" terá o botão flutuante
  Widget? _buildFab() {
    if (_tabController.index == 2) {
      return FloatingActionButton(
        onPressed: () {
          // acionando diretamente o método de PlaylistScreen com GlobalKey
          // OU você pode mover o botão para dentro do PlaylistScreen como já está
          // aqui fica só exemplo:
        },
        child: const Icon(Icons.library_music, color: Colors.black87),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(
            "Áudios",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context)
              .colorScheme
              .secondary, // Cor do texto da aba ativa
          unselectedLabelColor: Theme.of(context)
              .colorScheme
              .onSurface, // Cor do texto da aba inativa
          indicatorColor: Theme.of(context)
              .colorScheme
              .secondary, // Cor do indicador da aba ativa
          indicatorSize: TabBarIndicatorSize.tab, // Indicador ocupa toda a aba
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: "Bíblia"),
            Tab(text: "Harpa"),
            Tab(text: "Personalizados"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BibleAudioWrapper(),
          HarpaAudioWrapper(),
          PlaylistScreen()
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }
}
