import 'dart:convert';
import "package:biblia_e_harpa/src/view/component/app_bar_component.dart";
import "package:biblia_e_harpa/src/utils/config.dart";
import "package:biblia_e_harpa/src/view/harp_content_view.dart";
import "package:biblia_e_harpa/src/view_model/settings_view_model.dart";
import "package:biblia_e_harpa/src/keys/harp_key.dart";
import 'package:biblia_e_harpa/src/model/data_audio_model.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

class HarpListView extends StatefulWidget {
  const HarpListView({super.key});

  @override
  State<HarpListView> createState() => _HarpListViewState();
}

class _HarpListViewState extends State<HarpListView>
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
    _fetchAudioHarpa();

    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _fetchAudioHarpa() async {
    try {
      final String response =
          await rootBundle.loadString("assets/json/audiosHarpa.json");
      final Map<String, dynamic> jsonData = json.decode(response);

      final List data = jsonData["audios"];

      if (mounted) {
        setState(() {
          _audioList =
              data.map((audio) => DataAudioModel.fromJson(audio)).toList();
        });
      }
    } catch (_) {}
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
    final settings = context.watch<SettingsViewModel>();
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
            title: Text(
              hino,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: settings.fontSize,
              ),
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
                  builder: (context) => HarpContentView(
                    harp: hino,
                    audioUrl: audioUrl,
                    audioHymns: _audioList,
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
