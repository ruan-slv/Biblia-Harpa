import 'dart:convert';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../keys/devocionalkey.dart';
import 'devocionalScreen.dart';

class DevocionalList extends StatefulWidget {
  const DevocionalList({super.key});

  @override
  _DevocionalListState createState() => _DevocionalListState();
}

class _DevocionalListState extends State<DevocionalList> with SingleTickerProviderStateMixin {
  List<String> filteredDevocionalTopic = [];
  final TextEditingController _filterController = TextEditingController();
  String _jsonPath = "assets/json/devocional.json";
  late TabController _tabController;
  int index = 0;
  List<dynamic> devocionais = [];

  @override
  void initState() {
    super.initState();
    filteredDevocionalTopic = topicos;
    _filterController.addListener(_filterDevocional);
    _tabController = TabController(length: 2, vsync: this);
    _loadLastIndex();
    loadDevocionais();
  }

  @override
  void dispose() {
    _filterController.removeListener(_filterDevocional);
    _filterController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      index = prefs.getInt('lastDevocionalIndex') ?? 0;
    });
  }

  Future<void> _saveLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastDevocionalIndex', index);
  }

  Future<void> loadDevocionais() async {
    final String response = await rootBundle.loadString(_jsonPath);
    final data = json.decode(response);
    setState(() {
      devocionais = data["devocionais"];
    });
  }

  void proximoDevocional() {
    setState(() {
      index = (index + 1) % devocionais.length;
      _saveLastIndex();
    });
  }

  void anteriorDevocional() {
    setState(() {
      index = (index - 1 + devocionais.length) % devocionais.length;
      _saveLastIndex();
    });
  }

  void initialDevocional() {
    setState(() {
      index = 0;
      _saveLastIndex();
    });
    loadDevocionais();
  }

  void _filterDevocional() {
    setState(() {
      filteredDevocionalTopic = topicos
          .where((devo) => devo.toLowerCase().contains(_filterController.text.toLowerCase()))
          .toList();
    });
  }

  Widget _buildAleatoriosTab() {
    if (devocionais.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final devocional = devocionais[index];
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    devocional["texto"],
                    style:  TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.secondary),
                  ),
                  Text(
                    '- ${devocional["versiculo"]}',
                    style:  TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 20),
                   Text(
                    'Reflexão',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    devocional["reflexao"],
                    style:  TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 20),
                   Text(
                    'Oração',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    devocional["oracao"],
                    style:  TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0.5,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: anteriorDevocional,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child:  Icon(Icons.arrow_back, size: 24, color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0.5,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: proximoDevocional,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child:  Icon(Icons.arrow_forward, size: 24, color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemasTab(List<String> devoList) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _filterController,
            decoration: InputDecoration(
              labelText: "Pesquisar temas ex: Fé, Adoração",
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.secondary),
                onPressed: () {
                  _filterController.clear();
                  setState(() {
                    filteredDevocionalTopic = topicos;
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
          child: ListView.builder(
            itemCount: devoList.length,
            itemBuilder: (context, index) {
              final devocional = devoList[index];
              return ListTile(
                leading: const Icon(Icons.menu_book_rounded),
                title: Text(devocional, style:  TextStyle(color: Theme.of(context).colorScheme.secondary)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DevocionalContentScreen(devo: devocional),
                    ),
                  );
                },
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title:  Text("Devocional", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        actions: [
          SizedBox(
            width: sizeBtnOptions[0],
            height: sizeBtnOptions[1],
            child: IconButton(
              onPressed: initialDevocional,
              icon: const Icon(Icons.refresh),
              color: Theme.of(context).colorScheme.secondary,
              tooltip: "Reiniciar o devocional",
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46.0),
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.secondary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
              indicatorColor: Theme.of(context).colorScheme.secondary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              tabs: const [
                Tab(text: "Aleatórios"),
                Tab(text: "Temas"),
              ],
            ),
          ),
        ),
      ),
      body: devocionais.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAleatoriosTab(),
          _buildTemasTab(filteredDevocionalTopic),
        ],
      ),
    );
  }
}