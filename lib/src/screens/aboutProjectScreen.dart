import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/components/text_content_card.dart';
import 'package:flutter/material.dart';

class Aboutprojectscreen extends StatelessWidget {
  const Aboutprojectscreen({super.key});

  static const String _aboutText =
      "O aplicativo Bíblia e Harpa foi desenvolvido para oferecer uma experiência simples, prática e eficiente para quem deseja acessar a Bíblia Sagrada e a Harpa Cristã de forma acessível e sem complicações.\n\n"
      "Ele funciona parcialmente offline: você só precisa de internet para ouvir os áudios e receber avisos do desenvolvedor, que servem para manter todos informados sobre melhorias e novidades.\n\n"
      "Este projeto começou oficialmente no dia 02/12/2024, e a primeira versão de teste foi criada entre os dias 14 e 16/12/2024. A ideia nasceu da necessidade de ter um aplicativo sem anúncios, já que, em momentos de estudo ou devoção, anúncios constantes atrapalhavam bastante. Foi então que pensei: 'Se for para passar aperto tendo que ver vários anúncios e não conseguir usar o app direito, eu prefiro passar aperto fazendo o meu próprio.' Assim surgiu este app totalmente livre de anúncios.\n\n"
      "Muitas soluções dentro do aplicativo ainda são provisórias, justamente para reduzir custos de desenvolvimento e não depender de uma verba alta, que é difícil de manter. Além disso, este projeto está sendo desenvolvido de forma solo por mim, Ruan Gustavo, como uma maneira de unir meu trabalho com meu propósito de servir a Cristo através dos conhecimentos que adquiri na área de tecnologia.\n\n"
      "Se você sentir no coração o desejo de apoiar este trabalho, sua contribuição será muito bem-vinda. As doações ajudam a cobrir certificações, pequenos gastos de manutenção e também servem como uma pequena renda para que eu possa continuar ativo e mantendo o aplicativo no ar.\n\n"
      "Não importa o valor, pode ser centavos ou qualquer quantia. O que realmente importa é a intenção de ajudar. E caso não seja possível contribuir financeiramente, compartilhar o app com amigos e familiares já é uma forma incrível de apoiar e alcançar mais pessoas.\n\n"
      "Agradeço imensamente a todos que fazem parte desta caminhada, seja por meio de doações, compartilhamentos ou simplesmente utilizando o aplicativo. Cada gesto de apoio fortalece este projeto e me motiva a continuar.\n\n"
      "Que a paz do Senhor esteja sempre com vocês!";

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
