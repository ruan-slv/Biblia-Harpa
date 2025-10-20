import 'dart:convert';

import 'package:biblia_e_harpa/src/models/dataAudioModel.dart';
import 'package:biblia_e_harpa/src/screens/harpaFileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HarpaAudioScreen extends StatefulWidget {
  const HarpaAudioScreen({super.key});

  @override
  State<HarpaAudioScreen> createState() => _HarpaAudioScreenState();
}

class _HarpaAudioScreenState extends State<HarpaAudioScreen> {

  List<DataAudioModel> _allHarpas = [];
  List<DataAudioModel> _filtrarHarpa = [];
  final TextEditingController _buscar_harpa_contriller = TextEditingController();
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchAudioHarpa();
    _buscar_harpa_contriller.addListener(_filtrarAudioHarpa);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _buscar_harpa_contriller.removeListener(_filtrarAudioHarpa);
    _buscar_harpa_contriller.dispose();
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
    final query = _buscar_harpa_contriller.text;
    setState(() {
      _filtrarHarpa = _allHarpas.where((audio) => _normalize(audio.titulo).contains(_normalize(query))).toList();
    });
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
      setState(() {
        _allHarpas = harpaAudio;
        _filtrarHarpa = harpaAudio;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Houve um problema ao carregar os áudios.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text("Carregando..."),
        ],
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
            controller: _buscar_harpa_contriller, // Conecta o controller
            decoration: InputDecoration(
              labelText: "Pesquisar hino", // Texto atualizado
              labelStyle:
              TextStyle(color: Theme.of(context).colorScheme.secondary),
              border: const OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.secondary,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  _buscar_harpa_contriller.clear(); // Limpa o campo de pesquisa
                },
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).colorScheme.secondary,
                ),
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
            itemCount: _filtrarHarpa.length,
            itemBuilder: (context, index) {
              final harpa = _filtrarHarpa[index];
              return ListTile(
                trailing: Icon(
                  Icons.list,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  harpa.titulo,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Harpafilescreen(harpa: harpa),
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
