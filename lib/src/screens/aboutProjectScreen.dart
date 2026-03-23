import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:flutter/material.dart';

class Aboutprojectscreen extends StatelessWidget {
  const Aboutprojectscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          automaticallyImplyLeading: true,
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.secondary),
          title: Text(
            "Sobre o App",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(46.0),
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              child: TabBar(
                labelColor: Theme.of(context).colorScheme.secondary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                indicatorColor: Theme.of(context).colorScheme.secondary,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.normal),
                tabs: const [
                  Tab(text: "Sobre o App"),
                  Tab(text: "Política de Privacidade"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: FontSizeController.fontSizeNotifier,
                    builder: (context, fontSize, _) {
                      return Text(
                        "Sobre o App",
                        style: TextStyle(
                          fontSize: fontSize + 4, // título maior que o corpo
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<double>(
                    valueListenable: FontSizeController.fontSizeNotifier,
                    builder: (context, fontSize, _) {
                      return Text(
                        """
Este app surgiu em dezembro de 2024 e publicado na playstore em junho de 2025, criado por um estudante de tecnologia que frequentemente enfrentava problemas ao utilizar aplicativos biblicos durante a rotina por conta de muitos anúncios e produtos pagos que chegavam em momentos importantes.\n\n Como forma de contornar esta situação foi criado este app, onde foi pensado em fornecer um executável com diversas ferramentas improvisadas a fim de reduzir custo e permitir que seja disponibilizado um aplicativo sincero, onde possuem poucas versões de bíblia e somente uma versão de áudio entre outros, porém disponibilizando ao mesmo tempo um ambiente onde é prezado pelo momento de leitura de conteúdos sagrados.\n\n Nesta atualização de Abril será removida a área de doações, pois com muito esforço e apoio de outros usuários deste aplicativo, conseguimos cobrir o custo ao decorrer deste projeto e o desenvolvimento será continuado de forma voluntária.\n\n Este é um aplicativo simples, mas entregue de coração ao evangelho de Deus.\n\n Somente um aviso: Nem todas as sugestões dadas pelos usuários serão possível inserir no app, mas faremos o melhor possível para que gostem deste projeto. Amém!
                        """,
                        style: TextStyle(
                          fontSize: fontSize, // corpo do texto
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        textAlign: TextAlign.justify,
                      );
                    },
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: FontSizeController.fontSizeNotifier,
                    builder: (context, fontSize, _) {
                      return Text(
                        "Política de Privacidade",
                        style: TextStyle(
                          fontSize: fontSize + 4, // título maior que o corpo
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<double>(
                    valueListenable: FontSizeController.fontSizeNotifier,
                    builder: (context, fontSize, _) {
                      return Text(
                        "Última atualização: 6 de maio de 2025\n\n"
                        "O aplicativo Bíblia e Harpa foi desenvolvido com o objetivo de proporcionar aos usuários uma experiência cristã edificante, segura e respeitosa. Valorizamos sua privacidade e queremos deixar claro nosso compromisso com a proteção das suas informações.\n\n"
                        "1. Coleta de Dados\n"
                        "Não coletamos, armazenamos ou compartilhamos qualquer dado pessoal dos usuários. O aplicativo funciona completamente offline e não solicita cadastro, login ou qualquer informação identificável.\n\n"
                        "2. Permissões\n"
                        "As permissões solicitadas pelo aplicativo (quando necessárias) servem unicamente para permitir o funcionamento adequado de suas funcionalidades. Por exemplo, o app pode solicitar acesso ao armazenamento local para que o usuário possa selecionar músicas do seu dispositivo. Nenhuma dessas informações é coletada, armazenada ou compartilhada com terceiros. Todo o processamento ocorre localmente no aparelho do usuário.\n\n"
                        "3. Anúncios e Terceiros\n"
                        "O aplicativo não exibe anúncios e não utiliza serviços de terceiros que possam coletar dados dos usuários.\n\n"
                        "4. Alterações nesta Política\n"
                        "Podemos atualizar esta política de tempos em tempos. Caso isso ocorra, a nova versão será disponibilizada nesta seção do aplicativo ou na loja de aplicativos correspondente.",
                        style: TextStyle(
                          fontSize: fontSize, // corpo do texto
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        textAlign: TextAlign.justify,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
