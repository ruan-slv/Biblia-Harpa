import "package:biblia_e_harpa/src/config.dart";
import "package:biblia_e_harpa/src/content/harpContent.dart";
import "package:biblia_e_harpa/src/controllers/fontSizeController.dart";
import "package:biblia_e_harpa/src/keys/harpkey.dart";
import "package:flutter/material.dart";
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(
          "Harpa Cristã",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(46.0), // Reduz a altura do TabBar
          child: Container(
            color: Theme.of(context)
                .colorScheme
                .primary, // Fundo do TabBar igual ao Scaffold
            child: TabBar(
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
              indicatorSize:
                  TabBarIndicatorSize.tab, // Indicador ocupa toda a aba
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.normal),
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
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                border: const OutlineInputBorder(),
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
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              cursorColor: Theme.of(context).colorScheme.secondary,
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
