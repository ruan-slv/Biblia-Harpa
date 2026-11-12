import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../controllers/daily_word_controller.dart';
import '../../controllers/devotional_of_the_day_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../model/daily_word.dart';
import '../../model/devotional_of_the_day.dart';
import '../image_share_view.dart';

/// Card da home que apresenta a "Palavra do Dia" e o "Devocional do Dia".
///
/// O card concentra a lógica de negócio (carregamento e compartilhamento dos
/// dois conteúdos diários) e permite alternar entre eles pelo botão do
/// cabeçalho, sem necessidade de um segundo card na tela inicial.
class DailyWordCard extends StatefulWidget {
  const DailyWordCard({super.key});

  @override
  State<DailyWordCard> createState() => _DailyWordCardState();
}

class _DailyWordCardState extends State<DailyWordCard> {
  final DailyWordController _wordController = DailyWordController();
  final DevotionalOfTheDayController _devotionalController =
      DevotionalOfTheDayController();
  final ScreenshotController _screenshotController = ScreenshotController();

  bool _showDevotional = false;
  bool _wordLoaded = false;
  bool _devotionalLoaded = false;
  bool _isSharing = false;
  // Esconde as ações do cabeçalho para que elas não apareçam na imagem.
  bool _hideShareButton = false;

  DailyWord? get _word => _wordController.currentWord;
  DevotionalOfTheDay? get _devotional => _devotionalController.current;

  @override
  void initState() {
    super.initState();
    unawaited(_loadWord());
    unawaited(_loadDevotional());
  }

  @override
  void dispose() {
    _wordController.dispose();
    _devotionalController.dispose();
    super.dispose();
  }

  Future<void> _loadWord() async {
    try {
      await _wordController.loadDailyWord();
    } catch (e) {
      debugPrint('Erro ao carregar a Palavra do Dia: $e');
    }
    if (mounted) {
      setState(() => _wordLoaded = true);
    }
  }

  Future<void> _loadDevotional() async {
    try {
      await _devotionalController.load();
    } catch (e) {
      debugPrint('Erro ao carregar o Devocional do Dia: $e');
    }
    if (mounted) {
      setState(() => _devotionalLoaded = true);
    }
  }

  void _toggleContent() {
    setState(() => _showDevotional = !_showDevotional);
  }

  Future<void> _shareAsImage() async {
    if (_isSharing) return;
    setState(() {
      _isSharing = true;
      _hideShareButton = true;
    });

    try {
      // Aguarda o próximo quadro para garantir que as ações foram removidas
      // da árvore antes de capturar a imagem.
      final shareText = _shareSubject(context);
      await WidgetsBinding.instance.endOfFrame;

      final image = await _screenshotController.capture(pixelRatio: 2.0);
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final fileName =
          _showDevotional ? 'devocional_do_dia.png' : 'palavra_do_dia.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(image);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: shareText,
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

  String _shareSubject(BuildContext context) {
    if (_showDevotional) {
      final reference = _devotional?.versiculo ?? '';
      return '${context.l10n.t('Devocional do Dia')} - $reference';
    }
    final reference = _word?.reference ?? '';
    return '${context.l10n.t('Palavra do Dia')} - $reference';
  }

  Future<void> _shareAsText() async {
    final String? text;
    final String subject;

    if (_showDevotional) {
      final devotional = _devotional;
      if (devotional == null) return;
      text = '${context.l10n.t('Tópico do Devocional: {topic}', {'topic': devotional.topic})}\n\n'
          '📖 ${context.l10n.t('Versículo')}:\n${devotional.versiculo}\n\n'
          '✝️ ${context.l10n.t('Reflexão')}:\n${devotional.texto}\n\n'
          '🙏 ${context.l10n.t('Oração')}:\n${devotional.oracao}\n\n'
          '${context.l10n.t('Devocional do Dia • Bíblia e Harpa')}';
      subject =
          '${context.l10n.t('Devocional do Dia')} - ${devotional.topic}';
    } else {
      final word = _word;
      if (word == null) return;
      text = '“${word.text}”\n— ${word.reference}\n\n'
          '${context.l10n.t('Palavra do Dia • Bíblia e Harpa')}';
      subject = context.l10n.t('Palavra do Dia');
    }

    await SharePlus.instance.share(
      ShareParams(text: text, subject: subject),
    );
  }

  Future<void> _pickImageAndShare() async {
    if (_isSharing) return;

    late final ImageShareContent content;
    if (_showDevotional) {
      final devotional = _devotional;
      if (devotional == null) return;
      content = ImageShareContent(
        label: 'DEVOCIONAL DO DIA',
        quote: devotional.texto,
        reference: devotional.versiculo,
      );
    } else {
      final word = _word;
      if (word == null) return;
      content = ImageShareContent(
        label: 'PALAVRA DO DIA',
        quote: word.text,
        reference: word.reference,
      );
    }

    setState(() => _isSharing = true);

    try {
      // Pede permissão ao abrir a galeria (o file_picker solicita as
      // permissões de leitura de mídia automaticamente quando necessário).
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        dialogTitle: context.l10n.t('Escolha uma imagem para compartilhar'),
      );
      final String? pickedPath =
          (result == null || result.paths.isEmpty) ? null : result.paths.first;
      final File? picked = pickedPath == null ? null : File(pickedPath);

      if (picked == null) {
        // Usuário cancelou a seleção.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(context.l10n.t('Nenhuma imagem selecionada.')),
            ),
          );
        }
        return;
      }

      // Abre a tela de composição: o conteúdo do card é desenhado sobre a
      // imagem escolhida e o resultado pode ser compartilhado como PNG.
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImageShareView(
              imageFile: picked,
              content: content,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.t(
              'Não foi possível abrir a galeria: {error}',
              {'error': '$e'},
            )),
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

    return ListenableBuilder(
      listenable: Listenable.merge([_wordController, _devotionalController]),
      builder: (context, _) {
        return Screenshot(
          controller: _screenshotController,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.t(
                          _showDevotional
                              ? 'Devocional do Dia'
                              : 'Palavra do Dia',
                        ),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!_hideShareButton) ...[
                      IconButton(
                        icon: Icon(
                          Icons.change_circle,
                          color: colorScheme.onSurface,
                          size: 22,
                        ),
                        onPressed: _isSharing ? null : _toggleContent,
                        tooltip: _showDevotional
                            ? context.l10n.t('Mudar para Palavra do Dia')
                            : context.l10n.t('Mudar para Devocional diário'),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          color: colorScheme.onSurface,
                          size: 22,
                        ),
                        onPressed: _isSharing ? null : _showShareOptions,
                        tooltip: context.l10n.t('Compartilhar'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _buildBody(colorScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_showDevotional) {
      final devotional = _devotional;
      if (devotional == null) {
        return _buildPlaceholder(
          colorScheme,
          _devotionalLoaded
              ? context.l10n.t('Nenhum devocional disponível hoje.')
              : context.l10n.t('Carregando devocional...'),
          loading: !_devotionalLoaded,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (devotional.topic.isNotEmpty) ...[
            Text(
              devotional.topic,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
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
                color: colorScheme.onSurface,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            devotional.texto,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      );
    }

    final word = _word;
    if (word == null) {
      return _buildPlaceholder(
        colorScheme,
        _wordLoaded
            ? context.l10n.t('Nenhuma palavra disponível hoje.')
            : context.l10n.t('Carregando palavra...'),
        loading: !_wordLoaded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          word.text,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '— ${word.reference}',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(
    ColorScheme colorScheme,
    String message, {
    required bool loading,
  }) {
    return Row(
      children: [
        if (loading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onSurface,
            ),
          )
        else
          Icon(
            Icons.info_outline,
            size: 18,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
      ],
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
                leading: Icon(Icons.text_snippet, color: colorScheme.onSurface),
                title: Text(
                  context.l10n.t('Compartilhar texto'),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                onTap: () => Navigator.pop(sheetContext, 'text'),
              ),
              ListTile(
                leading: Icon(Icons.image, color: colorScheme.onSurface),
                title: Text(
                  context.l10n.t('Compartilhar imagem da galeria'),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                subtitle: Text(
                  context.l10n.t('Escolha uma imagem do seu dispositivo'),
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext, 'gallery'),
              ),
              ListTile(
                leading: Icon(Icons.screenshot, color: colorScheme.onSurface),
                title: Text(
                  context.l10n.t('Compartilhar como imagem'),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                subtitle: Text(
                  context.l10n.t('Gera uma imagem com o conteúdo do card'),
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
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
