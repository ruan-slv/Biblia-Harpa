/// Define a tela inicial de primeiro acesso do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/notification_service.dart';

/// Um arquivo .json de conteúdo que o usuário pode escolher baixar.
class JsonFileOption {
  const JsonFileOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.assetPath,
    this.url,
    this.required = false,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final String assetPath;
  final String? url;
  final bool required;
}

/// Configuração de um arquivo .json oferecido na tela de primeiro acesso.
class JsonFileConfig {
  const JsonFileConfig({
    required this.option,
    this.baseUrl =
        'https://raw.githubusercontent.com/ruanslv/Biblia-Harpa/main/assets/json/',
  });

  final JsonFileOption option;
  final String baseUrl;

  String get downloadUrl =>
      option.url ?? '$baseUrl${option.assetPath.split('/').last}';
}

/// Arquivos .json disponíveis para download no primeiro acesso.
///
/// Edite esta lista para incluir, remover ou alterar as opções que o usuário
/// pode escolher antes de iniciar o aplicativo.
const List<JsonFileConfig> kJsonFileOptions = [
  JsonFileConfig(
    option: JsonFileOption(
      id: 'acf',
      name: 'Bíblia ACF',
      description: 'Almeida Corrigida Fiel',
      icon: Icons.menu_book_rounded,
      gradient: [
        Color(0xFFE65100),
        Color(0xFFFFC107),
        Color(0xFFFFCC80),
      ],
      assetPath: 'assets/json/bible/acf.json',
      required: true,
    ),
  ),
  JsonFileConfig(
    option: JsonFileOption(
      id: 'nvi',
      name: 'Bíblia NVI',
      description: 'Nova Versão Internacional',
      icon: Icons.menu_book_rounded,
      gradient: [
        Color(0xFFE65100),
        Color(0xFFFFC107),
        Color(0xFFFFCC80),
      ],
      assetPath: 'assets/json/bible/nvi.json',
    ),
  ),
  JsonFileConfig(
    option: JsonFileOption(
      id: 'aa',
      name: 'Bíblia AA',
      description: 'Almeida Atualizada',
      icon: Icons.menu_book_rounded,
      gradient: [
        Color(0xFFE65100),
        Color(0xFFFFC107),
        Color(0xFFFFCC80),
      ],
      assetPath: 'assets/json/bible/aa.json',
    ),
  ),
  JsonFileConfig(
    option: JsonFileOption(
      id: 'harp',
      name: 'Harpa Cristã',
      description: '640 hinos em texto',
      icon: Icons.music_note_rounded,
      gradient: [
        Color(0xFF5C6BC0),
        Color(0xFF7E57C2),
        Color(0xFFB39DDB),
      ],
      assetPath: 'assets/json/outros/harpa_crista_640_hinos.json',
    ),
  ),
  JsonFileConfig(
    option: JsonFileOption(
      id: 'devotional',
      name: 'Devocional',
      description: 'Leituras diárias por tema',
      icon: Icons.auto_stories_rounded,
      gradient: [
        Color(0xFF00897B),
        Color(0xFF7BAE7F),
        Color(0xFFA5D6A7),
      ],
      assetPath: 'assets/json/outros/devocionais.json',
    ),
  ),
  JsonFileConfig(
    option: JsonFileOption(
      id: 'bible_audio',
      name: 'Bíblia em áudio',
      description: 'Índice dos áudios da Bíblia',
      icon: Icons.headphones_outlined,
      gradient: [
        Color(0xFF4A90E2),
        Color(0xFF3F51B5),
        Color(0xFF90CAF9),
      ],
      assetPath: 'assets/json/outros/audios.json',
    ),
  ),
  JsonFileConfig(
    option: JsonFileOption(
      id: 'harp_audio',
      name: 'Hinos em áudio',
      description: 'Índice dos hinos da Harpa',
      icon: Icons.audiotrack_rounded,
      gradient: [
        Color(0xFF4A90E2),
        Color(0xFF3F51B5),
        Color(0xFF90CAF9),
      ],
      assetPath: 'assets/json/outros/audios_harpa.json',
    ),
  ),
  JsonFileConfig(
    option: JsonFileOption(
      id: 'quiz',
      name: 'Quiz bíblico',
      description: 'Perguntas e respostas',
      icon: Icons.quiz_outlined,
      gradient: [
        Color(0xFF00897B),
        Color(0xFF7BAE7F),
        Color(0xFFA5D6A7),
      ],
      assetPath: 'assets/json/outros/quizz.json',
    ),
  ),
  JsonFileConfig(
    option: JsonFileOption(
      id: 'daily_word',
      name: 'Palavra do dia',
      description: 'Versículo diário',
      icon: Icons.wb_sunny_rounded,
      gradient: [
        Color(0xFFE65100),
        Color(0xFFD32F2F),
        Color(0xFFEF9A9A),
      ],
      assetPath: 'assets/json/outros/palavra_do_dia.json',
    ),
  ),
];

/// Chave usada para memorizar a escolha do usuário entre os .json.
const String kJsonChoiceKey = 'json_choice';

/// Chave usada para saber se o download do primeiro acesso já foi concluído.
const String kDownloadDoneKey = 'download_done';

/// Estado do fluxo de primeiro acesso: escolher os arquivos e depois baixá-los.
enum StartedAccessState { choosing, downloading, done }

/// Popup exibido no primeiro acesso do aplicativo.
///
/// Permite que o usuário escolha quais arquivos .json deseja baixar e, em
/// seguida, inicia o download de todos os selecionados antes de liberar o
/// acesso ao restante do app.
class StartedAccessOn extends StatefulWidget {
  const StartedAccessOn({
    super.key,
    this.options = kJsonFileOptions,
    this.onStart,
  });

  final List<JsonFileConfig> options;
  final VoidCallback? onStart;

  @override
  State<StartedAccessOn> createState() => _StartedAccessOnState();
}

class _StartedAccessOnState extends State<StartedAccessOn> {
  StartedAccessState _state = StartedAccessState.choosing;
  final Set<String> _selected = <String>{};
  final Set<String> _done = <String>{};
  final Map<String, DownloadStatus> _status = {};
  final Map<String, double> _progress = {};
  final Map<String, String> _errors = {};

  bool _online = true;
  bool _busy = false;
  bool _cancelled = false;

  late final Dio _dio;
  Directory? _dir;
  CancelToken? _activeCancel;

  @override
  void initState() {
    super.initState();
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _online = kIsWeb || (!Platform.isAndroid && !Platform.isIOS);
    _selected.addAll(widget.options.where((o) => o.option.required).map((o) => o.option.id));
    if (!kIsWeb) {
      Connectivity().checkConnectivity().then((results) {
        if (!mounted) return;
        final online = results.any((r) => r != ConnectivityResult.none);
        if (online != _online) {
          setState(() => _online = online);
        }
      }).catchError((_) {});
    }
  }

  void _toggle(String id) {
    if (_state != StartedAccessState.choosing) return;
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _selectAll() {
    if (_state != StartedAccessState.choosing) return;
    setState(() => _selected.addAll(widget.options.map((o) => o.option.id)));
  }

  void _clearAll() {
    if (_state != StartedAccessState.choosing) return;
    setState(() {
      _selected.clear();
      _selected.addAll(
          widget.options.where((o) => o.option.required).map((o) => o.option.id));
    });
  }

  Future<Directory> _storageDir() async {
    final existing = _dir;
    if (existing != null && await existing.exists()) {
      return existing;
    }
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/json_data');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _dir = dir;
    return dir;
  }

  /// Persiste a escolha do usuário e a flag de download concluído.
  Future<void> _persist({required bool downloadDone}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        kJsonChoiceKey, jsonEncode(_selected.toList()..sort()));
    if (downloadDone) {
      await prefs.setBool(kDownloadDoneKey, true);
    }
  }

  Future<void> _startDownload() async {
    if (_selected.isEmpty) {
      await _persist(downloadDone: true);
      _finish();
      return;
    }
    setState(() {
      _state = StartedAccessState.downloading;
      _busy = true;
      _done.clear();
      _status.clear();
      _errors.clear();
      _progress.clear();
    });
    await _persist(downloadDone: false);
    await _runDownloads();
  }

  Future<void> _runDownloads() async {
    final targets = widget.options
        .where((o) => _selected.contains(o.option.id))
        .toList();
    var allOk = true;

    for (final config in targets) {
      if (_cancelled) return;
      final ok = await _downloadOne(config);
      if (!ok) allOk = false;
      if (!mounted) return;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _state = allOk ? StartedAccessState.done : StartedAccessState.choosing;
    });
    if (allOk) {
      await _persist(downloadDone: true);
    }
  }

  Future<bool> _downloadOne(JsonFileConfig config) async {
    final id = config.option.id;
    try {
      setState(() {
        _status[id] = DownloadStatus.downloading;
        _errors.remove(id);
        _progress[id] = _progress[id] ?? 0.0;
      });

      if (kIsWeb) {
        final response = await http.get(
          Uri.parse('${config.downloadUrl}?t=${DateTime.now().millisecondsSinceEpoch}'),
        );
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }
        if (!mounted) return false;
        setState(() {
          _status[id] = DownloadStatus.done;
          _progress[id] = 1.0;
          _done.add(id);
        });
        return true;
      }

      final dir = await _storageDir();
      final file = File('${dir.path}/$id.json');
      final token = CancelToken();
      _activeCancel = token;

      await _dio.download(
        config.downloadUrl,
        file.path,
        cancelToken: token,
        onReceiveProgress: (received, total) {
          if (total <= 0 || !mounted) return;
          setState(() => _progress[id] = received / total);
        },
      );

      if (!mounted) return false;
      setState(() {
        _status[id] = DownloadStatus.done;
        _progress[id] = 1.0;
        _done.add(id);
      });
      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        if (mounted) {
          setState(() {
            _status[id] = DownloadStatus.idle;
            _errors[id] = 'Cancelado';
          });
        }
        return false;
      }
      _fail(config);
      return false;
    } catch (_) {
      _fail(config);
      return false;
    } finally {
      _activeCancel = null;
    }
  }

  void _fail(JsonFileConfig config) {
    final id = config.option.id;
    if (!mounted) return;
    setState(() {
      _status[id] = DownloadStatus.error;
      _errors[id] = 'Falha ao baixar ${config.option.name}';
    });
  }

  void _cancel() {
    _cancelled = true;
    _activeCancel?.cancel('cancelado');
  }

  /// Pula o download (mantém a escolha) e libera o acesso ao app.
  Future<void> _skip() async {
    if (_state == StartedAccessState.downloading) {
      _cancel();
    }
    await _persist(downloadDone: true);
    _finish();
  }

  void _finish() {
    if (widget.onStart != null) {
      widget.onStart!();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _cancelled = true;
    _activeCancel?.cancel('dispose');
    _dio.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: switch (_state) {
          StartedAccessState.choosing => _buildChoosing(colorScheme),
          StartedAccessState.downloading => _buildDownloading(colorScheme),
          StartedAccessState.done => _buildDone(colorScheme),
        },
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.cloud_download_rounded, color: colorScheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? 'Escolha os arquivos .json para baixar e iniciar',
                  style: TextStyle(
                    color: colorScheme.secondary.withValues(alpha: .75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoosing(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildHeader(colorScheme),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: widget.options
                .map((config) => _buildTile(config, colorScheme))
                .toList(),
          ),
        ),
        _buildSelectBar(colorScheme),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ElevatedButton.icon(
            onPressed: _online && !_busy ? _startDownload : null,
            icon: const Icon(Icons.download_rounded),
            label: Text(_online
                ? 'Iniciar download e começar'
                : 'Sem conexão — usar arquivos locais'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.secondary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: TextButton(
            onPressed: _skip,
            child: Text(
              'Pular e usar os arquivos já no app',
              style: TextStyle(color: colorScheme.secondary.withValues(alpha: .8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(JsonFileConfig config, ColorScheme colorScheme) {
    final id = config.option.id;
    final selected = _selected.contains(id);
    final isRequired = config.option.required;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: selected ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isRequired ? null : () => _toggle(id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: config.option.gradient),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(config.option.icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.option.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRequired
                            ? '${config.option.description} (obrigatório)'
                            : config.option.description,
                        style: TextStyle(
                          color: colorScheme.secondary.withValues(alpha: .7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRequired)
                  Icon(Icons.lock_rounded,
                      size: 20, color: colorScheme.secondary.withValues(alpha: .6))
                else
                  Checkbox(
                    value: selected,
                    onChanged: (_) => _toggle(id),
                    side: BorderSide(color: colorScheme.secondary.withValues(alpha: .5)),
                    activeColor: colorScheme.secondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          TextButton(onPressed: _selectAll, child: const Text('Selecionar todos')),
          const Spacer(),
          TextButton(onPressed: _clearAll, child: const Text('Limpar')),
          Text(
            '${_selected.length} de ${widget.options.length}',
            style: TextStyle(color: colorScheme.secondary.withValues(alpha: .7)),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloading(ColorScheme colorScheme) {
    final total = widget.options.length;
    final completed = _done.length;
    final overall = total == 0 ? 1.0 : completed / total;

    return Column(
      children: [
        _buildHeader(colorScheme, subtitle: 'Baixando seus arquivos...'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                'Concluído: $completed de $total',
                style: TextStyle(color: colorScheme.secondary.withValues(alpha: .7)),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: overall,
                  minHeight: 12,
                  backgroundColor: colorScheme.primary,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: widget.options
                .map((config) => _buildProgressTile(config, colorScheme))
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: OutlinedButton.icon(
            onPressed: _busy ? _cancel : null,
            icon: const Icon(Icons.cancel_rounded),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: colorScheme.secondary,
              side: BorderSide(color: colorScheme.secondary.withValues(alpha: .4)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTile(JsonFileConfig config, ColorScheme colorScheme) {
    final id = config.option.id;
    final selected = _selected.contains(id);
    final status = _status[id];
    final progress = _progress[id] ?? 0.0;
    final error = _errors[id];

    IconData icon;
    Color iconColor;
    String label;

    if (!selected) {
      icon = Icons.skip_next_rounded;
      iconColor = colorScheme.secondary.withValues(alpha: .3);
      label = 'Pulado';
    } else if (status == DownloadStatus.done || _done.contains(id)) {
      icon = Icons.check_circle_rounded;
      iconColor = Colors.green;
      label = 'Concluído';
    } else if (status == DownloadStatus.error || error != null) {
      icon = Icons.error_rounded;
      iconColor = colorScheme.error;
      label = error ?? 'Erro';
    } else if (status == DownloadStatus.downloading) {
      icon = Icons.cloud_download_rounded;
      iconColor = colorScheme.secondary;
      label = '${(progress * 100).toInt()}%';
    } else {
      icon = Icons.hourglass_top_rounded;
      iconColor = colorScheme.secondary.withValues(alpha: .5);
      label = 'Aguardando';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: colorScheme.primary.withValues(alpha: selected ? 0.5 : 0.2),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.option.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (status == DownloadStatus.downloading ||
                        (status == DownloadStatus.idle && selected))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: colorScheme.surface,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDone(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(Icons.check_circle_rounded, size: 64, color: Colors.green),
            ),
            const SizedBox(height: 24),
            Text(
              'Tudo pronto!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seus arquivos foram baixados com sucesso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.secondary.withValues(alpha: .7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _finish,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Começar a usar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de um download individual, usado na tela de progresso.
enum DownloadStatus { idle, downloading, done, error }

/// Porta de entrada do aplicativo.
///
/// Exibe o [StartedAccessOn] apenas no primeiro acesso (ou quando o download
/// ainda não foi concluído). Depois de concluído, mostra a [child] normalmente.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key, required this.child, this.options = kJsonFileOptions});

  final Widget child;
  final List<JsonFileConfig> options;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  @override
  void initState() {
    super.initState();
    // Schedule reading notification on app start
    NotificationService.scheduleReadingNotification();
  }

  @override
  Widget build(BuildContext context) {
    // Always show the child directly - no download popup
    return widget.child;
  }
}
