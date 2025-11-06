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
                        "O Bíblia e Harpa foi desenvolvido para oferecer uma experiência simples, prática e eficiente para quem deseja acessar a Bíblia Sagrada e a Harpa Cristã de forma prática.\n\n"
                        "O aplicativo funciona totalmente offline para leitura, permitindo que você acesse os textos a qualquer momento e em qualquer lugar, sem depender de internet. Apenas a função de áudio, loja e avisos necessitam de conexão, garantindo mais praticidade para quem deseja ouvir os conteúdos.\n\n"
                        "Uma das grandes vantagens é que o app não possui anúncios, proporcionando uma navegação limpa e focada, sem distrações. A interface foi pensada para ser leve, intuitiva e acessível para todos os usuários.\n\n"
                        "Este projeto foi iniciado no dia 14~16 de dezembro de 2024 por um estudante de tecnologia que, ao enfrentar dificuldades com aplicativos cheios de anúncios durante um culto, decidiu criar sua própria solução. A ideia surgiu do pensamento: 'Se for para passar aperto tendo que ver anúncios e não conseguir usar o app direito, eu prefiro passar aperto fazendo o meu próprio.' Assim nasceu este aplicativo totalmente sem anúncios.\n\n"
                        "Por um lado, isso garante o melhor para o usuário na parte de usabilidade, mas por outro, traz desafios para manter o app em funcionamento, já que não há monetização ou receita para sustentar o projeto. Algumas funcionalidades ainda estão sendo feitas de forma provisória, mas sempre com dedicação para entregar a melhor experiência possível.\n\n"
                        "Por isso, temos áreas para doações e a lojinha criada, pois na doação de qualquer valor ou uma compra de produtos, vai fazer com que o projeto consiga fundos para se manter em constante atualização.",
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
