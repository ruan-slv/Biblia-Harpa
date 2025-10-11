import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/keys/biblekey.dart';
import 'package:biblia_e_harpa/src/sizelist/chapterlist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleList extends StatefulWidget {
  const BibleList({super.key});

  @override
  _BibleListState createState() => _BibleListState();
}

class _BibleListState extends State<BibleList> {
  List<String> filteredBible = [];
  final TextEditingController _searchController = TextEditingController();
  String _jsonPath = 'assets/json/acf.json';

  @override
  void initState() {
    super.initState();
    _loadSelectedVersion();
    filteredBible = books;
    _searchController.addListener(_filterBible);
  }

  Future<void> _loadSelectedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jsonPath =
          'assets/json/${prefs.getString('selectedVersion') ?? 'acf.json'}';
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.removeListener(_filterBible);
    _searchController.dispose();
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  void _filterBible() {
    setState(() {
      filteredBible = books
          .where(
            (book) =>
                _normalize(book).contains(_normalize(_searchController.text)),
          )
          .toList();
    });
  }

  void _onMenuItemSelected(String value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (value) {
      case "ACF":
        setState(() {
          _jsonPath = 'assets/json/acf.json';
        });
        await prefs.setString('selectedVersion', 'acf.json');
        break;
      case 'NVI':
        setState(() {
          _jsonPath = 'assets/json/nvi.json';
        });
        await prefs.setString('selectedVersion', 'nvi.json');
        break;
      case 'AA':
        setState(() {
          _jsonPath = 'assets/json/aa.json';
        });
        await prefs.setString('selectedVersion', 'aa.json');
        break;
      default:
        break;
    }
    filteredBible;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          'Biblia Cristã',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        actions: [
          SizedBox(
            width: sizeBtnOptions[0],
            height: sizeBtnOptions[1],
            child: Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  color: Theme.of(context).colorScheme.primary,
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onSelected: _onMenuItemSelected,
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: "ACF",
                      child: Text(
                        "Almeida Corrigida Fiel",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: "NVI",
                      child: Text(
                        "Nova Versão Internacional",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: "AA",
                      child: Text(
                        "Almeida Atualizada",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ];
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Pesquisar Livro",
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.secondary),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      filteredBible = books;
                    });
                  },
                  icon: Icon(Icons.clear,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBible.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.menu_book_rounded,
                      color: Theme.of(context).colorScheme.secondary),
                  title: ValueListenableBuilder<double>(
                    valueListenable: FontSizeController.fontSizeNotifier,
                    builder: (context, fontSize, _) {
                      return Text(
                        filteredBible[index],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: fontSize,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterListScreen(
                          name: filteredBible[index],
                          jsonPath: _jsonPath,
                        ),
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
