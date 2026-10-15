# Tarefas

## ✅ Concluído — Alerta de performance da Play Store (inicialização lenta)

* **Problema:** taxa de "inicialização com estado salvo lenta" alta em dispositivos
  de entrada — GPU **ARM Mali G52** (24,20%) e CPU **ARM Cortex-A55** (28,20%).
* **Causa raiz:** o `main()` aguardava (`await`) em série I/O pesado (abrir o banco
  SQLite, `path_provider`, `SharedPreferences`, `.env`/dotenv, orientação) **antes**
  do `runApp()`, e o `StartupGate` agendava notificações no primeiro frame.
  Assim, o primeiro quadro só era desenhado depois de toda essa cadeia terminar —
  o que, em aparelhos fracos, ultrapassa o limite do vitals.
* **Correção aplicada:**
  * `lib/main.dart` → `main()` agora é **não-bloqueante**: o `runApp()` roda
    imediatamente e um `_warmUp()` dispara em paralelo (`unawaited`) o banco,
    as preferências, o `.env` e a orientação, com tolerância a falhas.
  * `lib/src/view/component/started_access_on.dart` → o agendamento de
    notificação do `StartupGate` passa a ser `unawaited` (sem bloquear o frame).
  * `lib/src/view/settings_view.dart` → os valores do `.env` deixam de ser
    `static final` (avaliados uma única vez) e passam a ser lidos a cada
    construção, refletindo o carregamento em paralelo.

## Tarefas anteriores

* ~~Verifique o alerta de performance dada pela Playstore abaixo:~~

A taxa de inicialização com estado salvo lenta de 7 dias está alta em dispositivos com GPU: ARM Mali G52

Nos últimos 7 dias, os dispositivos com GPU: ARM Mali G52 tiveram uma taxa de inicialização com estado salvo lenta de 24,20%. Esse valor é significativamente mais alto do que sua taxa geral de inicialização com estado salvo lenta (11,34%). Esses dispositivos representam 25% das instalações totais. Reduza as inicializações com estado salvo lentas nesses aparelhos para melhorar a taxa geral.
A taxa de inicialização com estado salvo lenta de 7 dias está alta em dispositivos com CPU: ARM Cortex-A55

Nos últimos 7 dias, os dispositivos com CPU: ARM Cortex-A55 tiveram uma taxa de inicialização com estado salvo lenta de 28,20%. Esse valor é significativamente mais alto do que sua taxa geral de inicialização com estado salvo lenta (11,34%). Esses dispositivos representam 5% das instalações totais. Reduza as inicializações com estado salvo lentas nesses aparelhos para melhorar a taxa geral.
``

Faça os ajustes para atender as necessidades da playstore.
`` 