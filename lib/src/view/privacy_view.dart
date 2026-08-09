
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'component/app_bar_component.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  static const String _privacyText =
      "Última atualização: 6 de maio de 2025\n\n"
      "O aplicativo Bíblia e Harpa foi desenvolvido com o objetivo de proporcionar aos usuários uma experiência cristã edificante, segura e respeitosa. Valorizamos sua privacidade e queremos deixar claro nosso compromisso com a proteção das suas informações.\n\n"
      "1. Coleta de Dados\n"
      "Não coletamos, armazenamos ou compartilhamos qualquer dado pessoal dos usuários. O aplicativo funciona completamente offline e não solicita cadastro, login ou qualquer informação identificável.\n\n"
      "2. Permissões\n"
      "As permissões solicitadas pelo aplicativo, quando necessárias, servem unicamente para permitir o funcionamento adequado de suas funcionalidades. Por exemplo, o app pode solicitar acesso ao armazenamento local para que o usuário possa selecionar músicas do seu dispositivo. Nenhuma dessas informações é coletada, armazenada ou compartilhada com terceiros. Todo o processamento ocorre localmente no aparelho do usuário.\n\n"
      "3. Anúncios e Terceiros\n"
      "O aplicativo não exibe anúncios e não utiliza serviços de terceiros que possam coletar dados dos usuários.\n\n"
      "4. Alterações nesta Política\n"
      "Podemos atualizar esta política de tempos em tempos. Caso isso ocorra, a nova versão será disponibilizada nesta seção do aplicativo ou na loja de aplicativos correspondente.";

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Política de Privacidade',
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.verified_user_rounded,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Privacidade e proteção',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Transparência sobre dados, permissões e funcionamento do aplicativo.',
                                style: TextStyle(
                                  color: colorScheme.secondary.withValues(alpha: 0.74),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Política',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _privacyText,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: settings.fontSize,
                            color: colorScheme.secondary,
                            height: 1.65,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
