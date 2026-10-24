import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/devotional_of_the_day.dart';
import '../image_share_view.dart';

/// Card da home que apresenta o "Devocional do Dia".
///
/// Segue a mesma lógica do [DailyWordCard]: um conteúdo por dia com as
/// opções de compartilhamento em texto, sobre uma imagem da galeria ou como
/// imagem gerada a partir do próprio card.
class DevotionalOfTheDayCard extends StatefulWidget {
  final DevotionalOfTheDay devotional;

  const DevotionalOfTheDayCard({
    super.key,
    required this.devotional,
  });

  @override
  State<DevotionalOfTheDayCard> createState() =>
      _DevotionalOfTheDayCardState();
}

class _DevotionalOfTheDayCardState extends State<DevotionalOfTheDayCard> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;
  // Esconde o botão de compartilhar para que ele não apareça na imagem.
  bool _hideShareButton = false;

  Future<void> _shareAsImage() async {
    if (_isSharing) return;
    setState(() {
      _isSharing = true;
      _hideShareButton = true;
    });

    try {
      // Aguarda o próximo quadro para garantir que o botão foi removido
      // da árvore antes de capturar a imagem.
      await WidgetsBinding.instance.endOfFrame;

      final image = await _screenshotController.capture(pixelRatio: 2.0);
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/devocional_do_dia.png');
      await file.writeAsBytes(image);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Devocional do Dia - ${widget.devotional.versiculo}',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
          _hideShareButton = false;
        });
      }
    }
  }

  String _buildShareText() {
    final devotional = widget.devotional;
    return 'Tópico do Devocional: ${devotional.topic}\n\n'
        '📖 Versículo:\n${devotional.versiculo}\n\n'
        '✝️ Reflexão:\n${devotional.texto}\n\n'
        '🙏 Oração:\n${devotional.oracao}\n\n'
        'Devocional do Dia • Bíblia e Harpa';
  }

  Future<void> _shareAsText() async {
    await SharePlus.instance.share(
      ShareParams(
        text: _buildShareText(),
        subject: 'Devocional do Dia - ${widget.devotional.topic}',
      ),
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

      // Abre a tela de composição: o Devocional do Dia é desenhado sobre a
      // imagem escolhida e o resultado pode ser compartilhado como PNG.
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImageShareView(
              imageFile: picked,
              content: ImageShareContent(
                label: 'DEVOCIONAL DO DIA',
                quote: widget.devotional.texto,
                reference: widget.devotional.versiculo,
              ),
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
    final devotional = widget.devotional;

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
                  'Devocional do Dia',
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_hideShareButton)
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
            if (devotional.topic.isNotEmpty) ...[
              Text(
                devotional.topic,
                style: TextStyle(
                  color: colorScheme.secondary.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (devotional.versiculo.isNotEmpty) ...[
              Text(
                devotional.versiculo,
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              devotional.texto,
              style: TextStyle(
                color: colorScheme.secondary,
                fontSize: 16,
                height: 1.5,
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
                  'Gera uma imagem com o Devocional do Dia',
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
