import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/components/text_content_card.dart';
import 'package:flutter/material.dart';

class Aboutprojectscreen extends StatelessWidget {
  const Aboutprojectscreen({super.key});

  static const String _aboutText =
  """
Este app surgiu em dezembro de 2024 e publicado na playstore em junho de 2025, criado por um estudante de tecnologia que frequentemente enfrentava problemas ao utilizar aplicativos biblicos durante a rotina por conta de muitos anúncios e produtos pagos que chegavam em momentos importantes.\n\n Como forma de contornar esta situação foi criado este app, onde foi pensado em fornecer um executável com diversas ferramentas improvisadas a fim de reduzir custo e permitir que seja disponibilizado um aplicativo sincero, onde possuem poucas versões de bíblia e somente uma versão de áudio entre outros, porém disponibilizando ao mesmo tempo um ambiente onde é prezado pelo momento de leitura de conteúdos sagrados.\n\n Nesta atualização de Abril será removida a área de doações, pois com muito esforço e apoio de outros usuários deste aplicativo, conseguimos cobrir o custo ao decorrer deste projeto e o desenvolvimento será continuado de forma voluntária.\n\n Este é um aplicativo simples, mas entregue de coração ao evangelho de Deus.\n\n Somente um aviso: Nem todas as sugestões dadas pelos usuários serão possível inserir no app, mas faremos o melhor possível para que gostem deste projeto. Amém!
                        """;

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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: CustomAppBar(
          title: "Sobre o App",
          automaticallyImplyLeading: true,
          centerTitle: true,
          tabBar: TabBar(
            labelColor: colorScheme.secondary,
            unselectedLabelColor: colorScheme.secondary.withOpacity(0.65),
            indicatorColor: colorScheme.secondary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: "Sobre o App"),
              Tab(text: "Privacidade"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TextContentCard(
              title: "Sobre o App",
              body: _aboutText,
            ),
            TextContentCard(
              title: "Política de Privacidade",
              body: _privacyText,
            ),
          ],
        ),
      ),
    );
  }
}
