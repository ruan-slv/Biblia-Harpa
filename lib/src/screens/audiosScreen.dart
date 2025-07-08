import 'dart:convert';

import 'package:biblia_e_harpa/src/config.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import '../keys/bibleAudios.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {

  final AudioPlayer _player = AudioPlayer();
  String? _currentTitle;
  List<dynamic> _audios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAudios();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _fetchAudios() async {
    try {
      final res = await http.get(Uri.parse("https://bible-api-nine.vercel.app/audios"), headers: { "Accept": "application/json" });
      final data = json.decode(res.body);

      if (res.statusCode != 200) throw Exception("Falha ao carregar áudios");
      setState(() {
        _audios = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _playAudio(String url, String title) async {
    try {

      //if(!url.startsWith("http")) throw Exception("Caminho de áudio inválido");

      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url))
      );

      _player.play();
      setState(() {
        _currentTitle = title;
      });
    } catch (e) {
      print("Erro ao reproduzir áudio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao reproduzir: ${e.toString()}"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Áudios da Bíblia",
          style: TextStyle(color: cinzaEscuro),
        ),
        backgroundColor: begeClaro,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: cinzaEscuro
        ),
      ),
      body: Column(
        children: [
          if (_currentTitle != null)
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Tocando agora: ${_currentTitle}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            Expanded(child: Center(child: Text("Erro: $_error")))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchAudios,
                child: ListView.builder(
                  itemCount: _audios.length,
                  itemBuilder: (context, index) {
                    final audio = _audios[index];
                    return ListTile(
                      title: Text(audio["title"]),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => _playAudio(audio["file"], audio["title"]),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}