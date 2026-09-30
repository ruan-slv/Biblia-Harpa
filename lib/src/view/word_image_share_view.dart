import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../model/daily_word.dart';

/// Tela em tela cheia que compõe a Palavra do Dia sobre uma imagem escolhida
/// pela galeria e permite compartilhar o resultado como PNG.
class WordImageShareView extends StatefulWidget {
  final File imageFile;
  final DailyWord word;

  const WordImageShareView({
    super.key,
    required this.imageFile,
    required this.word,
  });

  @override
  State<WordImageShareView> createState() => _WordImageShareViewState();
}

class _WordImageShareViewState extends State<WordImageShareView> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _imageReady = false;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    // Garante que a imagem esteja carregada antes de permitir a captura.
    precacheImage(FileImage(widget.imageFile), context).then((_) {
      if (mounted) setState(() => _imageReady = true);
    });
  }

  Future<void> _share() async {
    if (!_imageReady || _sharing) return;
    setState(() => _sharing = true);

    try {
      final boundary = _boundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? data =
          await image.toByteData(format: ui.ImageByteFormat.png);

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/palavra_do_dia_compartilhar.png');
      if (data != null) {
        await file.writeAsBytes(data.buffer.asUint8List());
      } else {
        throw Exception('Falha ao converter a imagem.');
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(file.path, mimeType: 'image/png'),
          ],
          text: 'Palavra do Dia - ${widget.word.reference}',
        ),
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar imagem: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: const Text('Compartilhar Palavra do Dia'),
        actions: [
          IconButton(
            icon: _sharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            tooltip: 'Compartilhar imagem',
            onPressed: _imageReady ? _share : null,
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _boundaryKey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.cover,
              ),
            ),
            // Sombreamento para o texto ficar legível sobre qualquer imagem.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0x33000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PALAVRA DO DIA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '“${widget.word.text}”',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.word.reference.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        '— ${widget.word.reference}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Bíblia e Harpa',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
