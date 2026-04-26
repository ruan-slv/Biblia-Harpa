import 'dart:convert';
import "package:biblia_e_harpa/src/components/appBarComponent.dart";
import "package:biblia_e_harpa/src/config.dart";
import "package:biblia_e_harpa/src/screens/text_harp_screen.dart";
import "package:biblia_e_harpa/src/controllers/fontSizeController.dart";
import "package:biblia_e_harpa/src/keys/harpkey.dart";
import 'package:biblia_e_harpa/src/models/audio/dataAudioModel.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:shared_preferences/shared_preferences.dart";

class HarpaList extends StatefulWidget {
  const HarpaList({super.key});

  @override
  _HarpaListState createState() => _HarpaListState();
}

class _HarpaListState extends State<HarpaList>
    with SingleTickerProviderStateMixin {

  List<String> filteredHarps = [];
  Set<String> favoriteHarps = {};
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<DataAudioModel> _audioList = [];

  @override
  void initState() {
    super.initState();
    filteredHarps = harps;
    _searchController.addListener(_filterHarps);
    _loadFavorites();

    // Carrega os áudios usando a lógica do seu arquivo HarpaAudioScreen
    _fetchAudioHarpa();

    _tabController = TabController(length: 2, vsync: this);
  }

  // Lógica trazida da sua HarpaAudioScreen
  Future<void> _fetchAudioHarpa() async {
    try {
      final String response = await rootBundle.loadString("assets/json/audiosHarpa.json");
      final Map<String, dynamic> jsonData = json.decode(response);

      // Acessa a chave "audios" conforme seu arquivo original
      final List data = jsonData["audios"];

      if (mounted) {
        setState(() {
          _audioList = data.map((audio) => DataAudioModel.fromJson(audio)).toList();
        });
      }
    } catch (e) {
      // print("Erro ao carregar audiosHarpa.json: $e");
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteHarps = prefs.getStringList("favoriteHarps")?.toSet() ?? {};
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("favoriteHarps", favoriteHarps.toList());
  }

  void _toggleFavorite(String hino) {
    setState(() {
      if (favoriteHarps.contains(hino)) {
        favoriteHarps.remove(hino);
      } else {
        favoriteHarps.add(hino);
      }
    });
    _saveFavorites();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterHarps);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _filterHarps() {
    setState(() {
      filteredHarps = harps
          .where(
            (hino) => hino.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        ),
      )
          .toList();
    });
  }

  // Extrai o número do hino (ex: "1 - Chuvas..." retorna 1)
  int _getHymnNumber(String hinoString) {
    try {
      final match = RegExp(r'^(\d+)').firstMatch(hinoString.trim());
      if (match != null) {
        return int.parse(match.group(0)!);
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildHarpList(List<String> harpList) {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 4, left: 10, right: 10),
        itemCount: harpList.length,
        itemBuilder: (context, index) {
          final hino = harpList[index];
          final isFavorite = favoriteHarps.contains(hino);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: ValueListenableBuilder<double>(
                valueListenable: FontSizeController.fontSizeNotifier,
                builder: (context, fontSize, _) {
                  return Text(
                    hino,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: fontSize,
                    ),
                  );
                },
              ),
              trailing: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                  color: isFavorite ? redColor : cinzaClaro,
                ),
                onPressed: () => _toggleFavorite(hino),
              ),
              onTap: () {
                String? audioUrl;

                if (_audioList.isNotEmpty) {
                  int hymnNumber = _getHymnNumber(hino);
                  if (hymnNumber > 0 && hymnNumber <= _audioList.length) {
                    audioUrl = _audioList[hymnNumber - 1].hinoURL;
                  }
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HarpContentScreen(
                      harp: hino,
                      audioUrl: audioUrl,
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        centerTitle: false,
        automaticallyImplyLeading: true,
        title: "Harpa Cristã",
        tabBar: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.secondary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
              indicatorColor: Theme.of(context).colorScheme.secondary,
              tabs: const [
                Tab(text: "Todos"),
                Tab(text: "Favoritos"),
              ],
        ),
      ),
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Pesquisar Hino",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  prefixIcon: Icon(Icons.search,
                      color: Theme.of(context).colorScheme.secondary),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear,
                        color: Theme.of(context).colorScheme.secondary),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        filteredHarps = harps;
                      });
                    },
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
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHarpList(filteredHarps),
                  _buildHarpList(favoriteHarps.toList()),
                ],
              ),
            ),
          ],
        ),

    );
  }
}
