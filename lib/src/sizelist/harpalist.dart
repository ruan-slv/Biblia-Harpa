import "package:biblia_e_harpa/src/config.dart";
import "package:biblia_e_harpa/src/content/harpContent.dart";
// import "package:biblia_e_harpa/src/initial/initial.dart";
import "package:biblia_e_harpa/src/keys/harpkey.dart";
import "package:flutter/material.dart";

class HarpaList extends StatefulWidget {
  const HarpaList({super.key});

  @override
  _HarpaListState createState() => _HarpaListState();
}

class _HarpaListState extends State<HarpaList> {
  List<String> filteredHarps = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    filteredHarps = harps;
    _searchController.addListener(_filterHarps);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterHarps);
    _searchController.dispose();
    super.dispose();
  }

  void _filterHarps() {
    setState(
      () {
        filteredHarps = harps
            .where(
              (hino) => hino.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ),
            )
            .toList();
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
                    setState(
                      () {
                        filteredHarps = harps;
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredHarps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.menu_book_rounded),
                  title: Text(filteredHarps[index], style: TextStyle(color: cinzaEscuro)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HarpContentScreen(harp: filteredHarps[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
