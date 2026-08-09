import 'dart:convert';
import 'dart:io';

import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/models/dataAudioModel.dart';
import 'package:biblia_e_harpa/src/screens/harpaFileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class HarpaAudioScreen extends StatefulWidget {
  final bool isOffline;

  const HarpaAudioScreen({
    super.key,
    this.isOffline = false,
  });

  @override
  State<HarpaAudioScreen> createState() => _HarpaAudioScreenState();
}

class _HarpaAudioScreenState extends State<HarpaAudioScreen> {

  List<DataAudioModel> _allHarpas = [];
  List<DataAudioModel> _filtrarHarpa = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchAudioHarpa();
    _searchController.addListener(_filtrarAudioHarpa);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarAudioHarpa);
    _searchController.dispose();
    super.dispose();
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

  void _filtrarAudioHarpa() {
    final query = _searchController.text;
    setState(() {
      _filtrarHarpa = _allHarpas.where((audio) => _normalize(audio.titulo).contains(_normalize(query))).toList();
    });
  }

  // Retorna o caminho padrão para um hino da harpa
  Future<String> _getLocalFilePath(String hinoTitle) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/harpa_audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    final safeName = hinoTitle.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    return '${audioDir.path}/$safeName.mp3';
  }

  Future<void> _fetchAudioHarpa() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final String response = await rootBundle.loadString("assets/json/audiosHarpa.json");
      final Map<String, dynamic> jsonData = json.decode(response);
      final List data = jsonData["audios"];
      List<DataAudioModel> harpaAudio = data.map((audio) => DataAudioModel.fromJson(audio)).toList();

      // LÓGICA DE FILTRO OFFLINE
      if (widget.isOffline) {
        List<DataAudioModel> offlineHinos = [];
        for (var hino in harpaAudio) {
          final path = await _getLocalFilePath(hino.titulo);
          if (await File(path).exists()) {
            offlineHinos.add(hino);
          }
        }
        harpaAudio = offlineHinos;
      }

      if (mounted) {
        setState(() {
          _allHarpas = harpaAudio;
          _filtrarHarpa = harpaAudio;
          isLoading = false;

          if (widget.isOffline && harpaAudio.isEmpty) {
            error = "Nenhum hino foi baixado para ser acessado offline.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = "Houve um problema ao carregar os áudios.";
          isLoading = false;
        });
      }
    }
  }

  PreferredSizeWidget? _showAppBarIfOffline() {
    if (widget.isOffline) {
      return AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: true,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          "Hinos Baixados (Offline)",
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _showAppBarIfOffline(),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Carregando..."),
          ],
        ),
      );
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Pesquisar hino",
                hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary),
                prefixIcon:
                Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.secondary),
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
            )
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filtrarHarpa.length,
            itemBuilder: (context, index) {
              final harpa = _filtrarHarpa[index];
              return ListTile(
                trailing: Icon(
                  Icons.list,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: ValueListenableBuilder(
                  valueListenable: FontSizeController.fontSizeNotifier,
                  builder: (context, fontSize, _) {
                    return Text(
                      harpa.titulo,
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
                      builder: (_) => Harpafilescreen(
                        allHarpas: _filtrarHarpa,
                        initialIndex: index,
                      ),
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
}
