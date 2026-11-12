/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:biblia_e_harpa/src/view/component/app_section_card.dart';
import 'package:biblia_e_harpa/src/controllers/settings_controller.dart';
import 'package:biblia_e_harpa/src/controllers/database_export_controller.dart';
import 'package:biblia_e_harpa/src/l10n/app_localizations.dart';
import 'package:biblia_e_harpa/src/view/component/language_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:biblia_e_harpa/src/utils/theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DatabaseExportController(),
      child: _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  static const String _repositoryUrl =
      'https://github.com/ruan-slv/Biblia-Harpa.git';

  final Future<PackageInfo> _packageInfoFuture = PackageInfo.fromPlatform();

  // Valores lidos do .env a cada construção da tela (em vez de uma vez de
  // forma estática), para refletir o conteúdo após o dotenv ser carregado
  // em paralelo na inicialização.
  late final String _supportEmail;
  late final String _playStoreURL;
  late final String _pixKey;
  late final Uri _playStoreUrl;

  _SettingsContent() {
    _supportEmail = dotenv.env["SUPPORT_EMAIL"] ?? "";
    _playStoreURL = dotenv.env["PLAYSTORE_URL"] ?? "";
    _pixKey = dotenv.env["PIX_KEY"] ?? "";
    _playStoreUrl = Uri.parse(_playStoreURL);
  }

  void copyPixKey(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _pixKey));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.t("Chave PIX copiada com sucesso!")),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _startSupport(BuildContext context) async {
    const subject = "Pedido de suporte";

    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: _encodeQueryParameters({
        'subject': subject,
      }),
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Não foi possível abrir o e-mail: $e");
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }

  Future<void> _showSupportDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            context.l10n.t("Suporte"),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            "E-mail: ${_supportEmail.isEmpty ? context.l10n.t("Email de suporte não encontrado!") : _supportEmail}",
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => _startSupport(context),
              child: Text(
                context.l10n.t("Entrar em contato"),
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.t("Fechar"),
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openExternal(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Não foi possível abrir a Play Store");
    }
  }

  Future<void> _openRepository(BuildContext context) async {
    try {
      if (!await launchUrl(
        Uri.parse(_repositoryUrl),
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('link inválido');
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.t(
              'Não foi possível abrir o link: {error}',
              {'error': '$error'},
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportDatabase(
    BuildContext context,
    DatabaseExportController controller,
  ) async {
    final result = await controller.export();
    if (!context.mounted) return;

    final message = result.directory == null
        ? result.message
        : '${result.message}\n${result.directory}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<SettingsController>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: ListView(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
            children: [
              Column(
                children: [
                  AppSectionCard(
                    icon: Icons.format_size_rounded,
                    title: context.l10n.t("Tamanho da fonte"),
                    subtitle: context.l10n.t(
                        "Defina um tamanho confortável para leitura em todas as telas de texto."),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.t(
                            "Tamanho atual: {size} pt",
                            {
                              'size': viewModel.fontSize.toStringAsFixed(0),
                            },
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: viewModel.decreaseFontSize,
                              child: const Text("A-"),
                            ),
                            ElevatedButton(
                              onPressed: viewModel.increaseFontSize,
                              child: const Text("A+"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    icon: Icons.language_rounded,
                    title: context.l10n.t("Idioma do aplicativo"),
                    subtitle: context.l10n.t("Escolha o idioma da interface"),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          child: Text(
                            context.l10n.t(
                              "Idioma atual: {language}",
                              {
                                'language':
                                    "${viewModel.language.flag} ${viewModel.language.nativeName}",
                              },
                            ),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => showLanguageSelectionDialog(context),
                          icon: const Icon(Icons.translate_rounded),
                          label: Text(context.l10n.t("Alterar idioma")),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    icon: viewModel.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: context.l10n.t("Tema do aplicativo"),
                    subtitle: context.l10n.t(
                        "Alterne entre os modos claro e escuro conforme o ambiente e sua preferência."),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          child: Text(
                            viewModel.isDarkMode
                                ? context.l10n.t("Modo escuro ativo")
                                : context.l10n.t("Modo claro ativo"),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: viewModel.toggleTheme,
                          icon: Icon(viewModel.isDarkMode
                              ? Icons.sunny
                              : Icons.brightness_2),
                          label: Text(viewModel.isDarkMode
                              ? context.l10n.t("Usar claro")
                              : context.l10n.t("Usar escuro")),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    icon: Icons.share_outlined,
                    title: context.l10n.t("Compartilhar app"),
                    subtitle: context.l10n.t(
                        "Envie o aplicativo para familiares e amigos e ajude mais pessoas a alcançarem esse conteúdo."),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text:
                                "📖✨ ${context.l10n.t("Descubra uma nova forma de se conectar com a Palavra de Deus!")}\n\n"
                                "${context.l10n.t("Baixe agora nosso aplicativo gratuito de leitura bíblica e tenha acesso a versículos, harpa e muito mais, tudo na palma da sua mão, offline e sem anúncios.")}\n\n"
                                "🔗 ${context.l10n.t("Acesse aqui: {url}", {
                                  'url': _playStoreUrl.toString()
                                })}",
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: Text(context.l10n.t("Compartilhar")),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    icon: Icons.coffee_rounded,
                    title: context.l10n.t("Apoiar projeto"),
                    subtitle: context.l10n.t(
                        "Seu apoio nos ajuda a manter este projeto de pé com manutenções e atualizações do aplicativo para seu aproveitamento."),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        copyPixKey(context);
                      },
                      icon: const Icon(Icons.info_outline_rounded),
                      label: Text(context.l10n.t("Apoiar")),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    icon: Icons.support_agent_rounded,
                    title: context.l10n.t("Suporte"),
                    subtitle: context.l10n.t(
                        "Entre em contato por e-mail para pedir ajuda ou enviar feedback."),
                    child: ElevatedButton.icon(
                      onPressed: () => _showSupportDialog(context),
                      icon: const Icon(Icons.mail_outline_rounded),
                      label: Text(context.l10n.t("Solicitar suporte")),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    icon: Icons.privacy_tip_outlined,
                    title: context.l10n.t("Política de Privacidade"),
                    subtitle: context.l10n.t(
                        "Conheça como tratamos seus dados e sua privacidade."),
                    child: ElevatedButton.icon(
                      onPressed: () async => await _openExternal(
                          Uri.parse("https://ruan-slv.github.io/biblia-site/")),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(context.l10n.t("Ver política")),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<DatabaseExportController>(
                    builder: (context, exportController, _) {
                      return AppSectionCard(
                        icon: Icons.save_alt_rounded,
                        title: context.l10n.t("Exportar Base de Dados"),
                        subtitle: context.l10n.t(
                            "Salve os arquivos .json da Bíblia (versão selecionada) e da Harpa em uma pasta do seu dispositivo."),
                        child: ElevatedButton.icon(
                          onPressed: exportController.isExporting
                              ? null
                              : () => _exportDatabase(
                                    context,
                                    exportController,
                                  ),
                          icon: exportController.isExporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_alt_rounded),
                          label: Text(
                            exportController.isExporting
                                ? context.l10n.t("Exportando...")
                                : context.l10n.t("Exportar"),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    icon: Icons.code_rounded,
                    title: context.l10n.t('Projeto Open Source'),
                    subtitle: context.l10n.t(
                      'Este projeto faz parte da comunidade Open Source. Contribua com ideias, melhorias ou código e ajude o aplicativo a crescer.',
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openRepository(context),
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: Text(
                            context.l10n.t('Contribuir no GitHub'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<PackageInfo>(
                    future: _packageInfoFuture,
                    builder: (context, snapshot) {
                      final version = (snapshot.hasData &&
                              snapshot.data!.version.isNotEmpty)
                          ? snapshot.data!.version
                          : "1.1.4";
                      final displayVersion = "$version - stable 1.0";

                      return AppSectionCard(
                        icon: Icons.info_outline_rounded,
                        title: context.l10n.t("Versão do aplicativo"),
                        subtitle: context.l10n.t(
                            "Informações sobre a versão atual instalada e canal de atualização."),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 20,
                                    color: AppTheme.sucesso,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    displayVersion,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
