import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/daily_word.dart';
import '../word_image_share_view.dart';

class DailyWordCard extends StatefulWidget {
  final DailyWord word;
  final VoidCallback onNewWord;

  const DailyWordCard({
    super.key,
    required this.word,
    required this.onNewWord,
  });

  @override
  State<DailyWordCard> createState() => _DailyWordCardState();
}

class _DailyWordCardState extends State<DailyWordCard> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareAsImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final image = await _screenshotController.capture(pixelRatio: 2.0);
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/palavra_do_dia.png');
      await file.writeAsBytes(image);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Palavra do Dia - ${widget.word.reference}',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _shareAsText() async {
    final text =
        '“${widget.word.text}”\n— ${widget.word.reference}\n\nPalavra do Dia • Bíblia e Harpa';
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Palavra do Dia'),
    );
  }

  Future<void> _pickImageAndShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // Pede permissão ao abrir a galeria (o file_picker solicita as
      // permissões de leitura de mídia automaticamente quando necessário).
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        dialogTitle: 'Escolha uma imagem para compartilhar',
      );
      final String? pickedPath =
          (result == null || result.paths.isEmpty) ? null : result.paths.first;
      final File? picked = pickedPath == null ? null : File(pickedPath);

      if (picked == null) {
        // Usuário cancelou a seleção.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma imagem selecionada.'),
            ),
          );
        }
        return;
      }

      // Abre a tela de composição: a Palavra do Dia é desenhada sobre a
      // imagem escolhida e o resultado pode ser compartilhado como PNG.
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WordImageShareView(
              imageFile: picked,
              word: widget.word,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir a galeria: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Screenshot(
      controller: _screenshotController,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Palavra do Dia',
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: colorScheme.secondary,
                    size: 22,
                  ),
                  onPressed: _isSharing ? null : _showShareOptions,
                  tooltip: 'Compartilhar',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.word.text,
              style: TextStyle(
                color: colorScheme.secondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '— ${widget.word.reference}',
              style: TextStyle(
                color: colorScheme.secondary.withValues(alpha: 0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showShareOptions() async {
    final colorScheme = Theme.of(context).colorScheme;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.text_snippet, color: colorScheme.secondary),
                title: Text(
                  'Compartilhar texto',
                  style: TextStyle(color: colorScheme.secondary),
                ),
                onTap: () => Navigator.pop(sheetContext, 'text'),
              ),
              ListTile(
                leading: Icon(Icons.image, color: colorScheme.secondary),
                title: Text(
                  'Compartilhar imagem da galeria',
                  style: TextStyle(color: colorScheme.secondary),
                ),
                subtitle: Text(
                  'Escolha uma imagem do seu dispositivo',
                  style: TextStyle(
                    color: colorScheme.secondary.withValues(alpha: 0.7),
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext, 'gallery'),
              ),
              ListTile(
                leading: Icon(Icons.screenshot, color: colorScheme.secondary),
                title: Text(
                  'Compartilhar como imagem',
                  style: TextStyle(color: colorScheme.secondary),
                ),
                subtitle: Text(
                  'Gera uma imagem com a Palavra do Dia',
                  style: TextStyle(
                    color: colorScheme.secondary.withValues(alpha: 0.7),
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext, 'image'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (choice == 'text') {
      await _shareAsText();
    } else if (choice == 'gallery') {
      await _pickImageAndShare();
    } else if (choice == 'image') {
      await _shareAsImage();
    }
  }
}
