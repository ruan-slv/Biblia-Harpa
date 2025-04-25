import "package:biblia_e_harpa/src/config.dart";
import "package:biblia_e_harpa/src/content/harpContent.dart";
import "package:biblia_e_harpa/src/keys/harpkey.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class HarpaList extends StatefulWidget {
  const HarpaList({super.key});

  @override
  _HarpaListState createState() => _HarpaListState();
}

class _HarpaListState extends State<HarpaList> with SingleTickerProviderStateMixin {
  List<String> filteredHarps = [];
  Set<String> favoriteHarps = {};
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    filteredHarps = harps;
    _searchController.addListener(_filterHarps);
    _loadFavorites();
    _tabController = TabController(length: 2, vsync: this);
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

  Widget _buildHarpList(List<String> harpList) {
    return ListView.builder(
      itemCount: harpList.length,
      itemBuilder: (context, index) {
        final hino = harpList[index];
        final isFavorite = favoriteHarps.contains(hino);
        return ListTile(
          leading: const Icon(Icons.menu_book_rounded),
          title: Text(hino, style: const TextStyle(color: cinzaEscuro)),
          trailing: IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.yellow : Colors.grey,
            ),
            onPressed: () => _toggleFavorite(hino),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HarpContentScreen(harp: hino),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brancoNeve,
      appBar: AppBar(
        backgroundColor: azulSereno,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: brancoNeve),
        title: const Text(
          "Harpa Cristã",
          style: TextStyle(color: brancoNeve),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46.0), // Reduz a altura do TabBar
          child: Container(
            color: brancoNeve, // Fundo do TabBar igual ao Scaffold
            child: TabBar(
              controller: _tabController,
              labelColor: azulSereno, // Cor do texto da aba ativa
              unselectedLabelColor: cinzaEscuro, // Cor do texto da aba inativa
              indicatorColor: azulSereno, // Cor do indicador da aba ativa
              indicatorSize: TabBarIndicatorSize.tab, // Indicador ocupa toda a aba
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              tabs: const [
                Tab(text: "Todos"),
                Tab(text: "Favoritos"),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Pesquisar Hino",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      filteredHarps = harps;
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHarpList(filteredHarps), // Aba de todos os hinos
                _buildHarpList(favoriteHarps.toList()), // Aba de favoritos
              ],
            ),
          ),
        ],
      ),
    );
  }
}