import 'dart:convert'; // Não parece ser usado diretamente neste arquivo
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // Não parece ser usado diretamente neste arquivo
import 'package:share_plus/share_plus.dart';

class Textbiblescreen extends StatefulWidget {
  final String bookName;
  final String jsonPath; // jsonPath não está sendo usado neste widget, considerar remover se não for necessário
  final int initialChapterNumber;
  final List<List<dynamic>> allBookChapters;

  const Textbiblescreen({
    super.key,
    required this.bookName,
    required this.jsonPath,
    required this.initialChapterNumber,
    required this.allBookChapters,
  });

  @override
  State<Textbiblescreen> createState() => _TextbiblescreenState();
}

class _TextbiblescreenState extends State<Textbiblescreen> {
  late int currentChapterNumber;
  late List<dynamic> currentVerses;
  final ScrollController _scrollController = ScrollController(); // 1. Criar o ScrollController

  @override
  void initState() {
    super.initState();
    currentChapterNumber = widget.initialChapterNumber;
    // Garante que o capítulo inicial não esteja fora dos limites
    if (currentChapterNumber < 1) currentChapterNumber = 1;
    if (currentChapterNumber > widget.allBookChapters.length && widget.allBookChapters.isNotEmpty) {
      currentChapterNumber = widget.allBookChapters.length;
    }

    if (widget.allBookChapters.isNotEmpty && currentChapterNumber -1 < widget.allBookChapters.length) {
      currentVerses = widget.allBookChapters[currentChapterNumber - 1];
    } else {
      currentVerses = []; // Capítulo inicial inválido ou lista de capítulos vazia
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 4. Descartar o Controller
    super.dispose();
  }

  void _navigateToChapter(int newChapterNumber) {
    if (newChapterNumber >= 1 && newChapterNumber <= widget.allBookChapters.length) {
      setState(() {
        currentChapterNumber = newChapterNumber;
        currentVerses = widget.allBookChapters[currentChapterNumber - 1];
      });
      // 3. Animar/pular para o topo
      if (_scrollController.hasClients) { // Verifica se o controller está anexado a um scroll view
        _scrollController.animateTo(
          0.0, // Posição do scroll (topo)
          duration: const Duration(milliseconds: 300), // Duração da animação
          curve: Curves.easeInOut, // Curva de animação
        );
        // Ou, para pular instantaneamente sem animação:
        // _scrollController.jumpTo(0.0);
      }
    }
  }

  void _nextChapter() {
    if (currentChapterNumber < widget.allBookChapters.length) {
      _navigateToChapter(currentChapterNumber + 1);
    }
  }

  void _previousChapter() {
    if (currentChapterNumber > 1) {
      _navigateToChapter(currentChapterNumber - 1);
    }
  }

  String _getDataForSharing() {
    StringBuffer shareText = StringBuffer(); // Variável local com minúscula
    shareText.writeln("${widget.bookName} - Capítulo $currentChapterNumber");
    shareText.writeln(); // Uma linha em branco é suficiente

    for (int i = 0; i < currentVerses.length; i++) {
      final String verseText = currentVerses[i].toString();
      final int verseNumber = i + 1;
      shareText.writeln("$verseNumber. $verseText");
    }
    return shareText.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Adiciona um tratamento para o caso de allBookChapters estar vazio
    if (widget.allBookChapters.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.bookName),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.secondary,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Text(
            'Nenhum capítulo disponível para este livro.',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${widget.bookName} - Cap. $currentChapterNumber'), // Abreviação para caber melhor
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          IconButton(
            onPressed: () {
              if (currentVerses.isNotEmpty) { // Só compartilha se houver versículos
                final String chapterText = _getDataForSharing();
                Share.share(
                  chapterText,
                  subject: "${widget.bookName} - Capítulo $currentChapterNumber",
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Não há versículos para compartilhar neste capítulo.')),
                );
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: currentVerses.isEmpty
          ? Center(
        child: Text(
          'Nenhum versículo encontrado para este capítulo.',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        controller: _scrollController, // 2. Associar o Controller ao ListView
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: currentVerses.length,
        itemBuilder: (context, index) {
          final String verseText = currentVerses[index].toString();
          final int verseNumber = index + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0), // Aumenta o espaçamento inferior entre os versos
            child: Row( // Usa Row para alinhar número e texto
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$verseNumber ", // Adiciona um espaço após o número
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold, // Destaca o número do versículo
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                  ),
                ),
                Expanded( // Permite que o texto do versículo quebre a linha corretamente
                  child: Text(
                    verseText,
                    style: TextStyle(
                      fontSize: 17, // Tamanho de fonte consistente
                      color: Theme.of(context).colorScheme.secondary,
                      height: 1.4, // Melhora a legibilidade com espaçamento entre linhas
                    ),
                    textAlign: TextAlign.left, // Alinhamento à esquerda é mais comum para texto bíblico
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: Theme.of(context).colorScheme.background.withOpacity(0.95), // Leve transparência ou cor sólida
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Melhor distribuição
          children: [
            ElevatedButton(
              onPressed: currentChapterNumber > 1 ? _previousChapter : null, // Desabilita se for o primeiro capítulo
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 2,
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: Theme.of(context).colorScheme.secondary),
            ),
            // Opcional: Mostrar o número do capítulo atual / total de capítulos
            Text(
              "Capítulo $currentChapterNumber de ${widget.allBookChapters.length}",
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
            ),
            ElevatedButton(
              onPressed: currentChapterNumber < widget.allBookChapters.length ? _nextChapter : null, // Desabilita se for o último
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 2,
              ),
              child: Icon(Icons.arrow_forward_ios, size: 20, color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
