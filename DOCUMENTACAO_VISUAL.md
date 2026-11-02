# Documentação visual — Player Offline

Este documento descreve a paleta de cores, os tokens visuais, a tipografia e
onde cada elemento é aplicado no aplicativo. A fonte de verdade é o arquivo
[`lib/theme/app_theme.dart`](lib/theme/app_theme.dart); cores pontuais de
componentes específicos também estão listadas aqui.

---

## 1. Estrutura da paleta

A identidade visual é construída em quatro camadas:

1. **Marca** — cores fixas da identidade (verde-água, violeta, vermelho e dourado).
2. **Superfícies** — fundo, cartões, blocos internos e bordas, com variantes clara e escura.
3. **Semântica** — cores geradas pelo `ColorScheme.fromSeed` para texto, ícones, estados e foco.
4. **Estados** — sucesso, informação, alerta e erro, aplicadas em badges, banners e SnackBars.

### 1.1 Cores de marca

| Token | Hex | RGB | Aplicação principal |
|---|---|---|---|
| `AppTheme.corPrimaria` | `#00BFA6` | `0, 191, 166` | Marca, gradiente padrão, sombra do logo, destaque de mídias de áudio, SnackBar informativo |
| `AppTheme.corSecundaria` | `#7C6BFF` | `124, 107, 255` | Gradiente padrão, estatística de pastas, etiquetas de módulo nos logs, badge de contagem |
| `AppTheme.corVermelha` | `#FF6B6B` | `255, 107, 107` | Vídeos, erro da tela de inicialização, ícones de erro nos logs, estatística de vídeos |
| `AppTheme.corDourada` | `#F5B93F` | `245, 185, 63` | Músicas, itens “Link da web”, aviso de senha padrão, resultado de download cancelado |

### 1.2 Gradientes

| Nome | Cores | Onde é aplicado |
|---|---|---|
| `AppTheme.gradienteMarca` | `#00BFA6` → `#7C6BFF` (diagonal) | Logo da barra lateral, ícone de pasta nas pastas, ícone do diálogo de lote, ícone de pasta do Player |
| Gradiente do hero | `#008F7E` → `#5B4BD6` (diagonal) | Bloco principal da tela **Início** |
| Gradiente de capa de áudio | `scheme.primary` → `#7C6BFF` → `scheme.tertiary` | Capa do player de música |
| Gradiente de mídia | cor do tipo → mesma cor com 65% de opacidade | Ícone de vídeo (`#FF6B6B`) ou música (`#00BFA6`) no cartão de mídia e no cabeçalho do player |

Cores auxiliares do hero:

| Cor | Hex | Uso |
|---|---|---|
| Verde profundo do botão | `#0B4F47` | Texto/ícone do botão branco “Abrir Player” |
| Branco com alpha | `#FFFFFF` em 10%–82% | Textos, bordas e círculos decorativos sobre o gradiente |

### 1.3 Superfícies por tema

#### Tema claro

| Token | Hex | Onde é aplicado |
|---|---|---|
| Fundo da aplicação | `#F3F6FA` | `scaffoldBackgroundColor` |
| `AppTheme.superficie` | `#FFFFFF` | Cartões, diálogos, barra lateral, campos e áreas elevadas |
| `AppTheme.superficieSuave` | `#F7F9FC` | Blocos internos de configurações, atalhos e áreas de formulário |
| `AppTheme.borda` | `outlineVariant` a 50% (`#BEC9C5`) | Contorno de cartões, diálogos, divisores e campos |
| `AppTheme.textoSuave` | `#3F4946` | Textos secundários, descrições, legendas e ícones neutros |

#### Tema escuro

| Token | Hex | Onde é aplicado |
|---|---|---|
| Fundo da aplicação | `#0B0F14` | `scaffoldBackgroundColor` |
| `AppTheme.superficie` | `#141B23` | Cartões, diálogos, barra lateral e áreas elevadas |
| `AppTheme.superficieSuave` | `#1A232D` | Blocos internos e áreas de apoio |
| `AppTheme.borda` | `outlineVariant` a 50% (`#3F4946`) | Contornos e divisores |
| `AppTheme.textoSuave` | `#BEC9C5` | Textos secundários e legendas |

> Observação: o `surface` do `ColorScheme` (`#F5FBF7` no claro e `#0E1513` no
> escuro) é diferente das superfícies customizadas acima. Os componentes do app
> usam `AppTheme.superficie()` e `AppTheme.superficieSuave()` para manter o
> visual próprio; o `scheme.surface` fica disponível para widgets Material
> nativos.

### 1.4 ColorScheme gerado

As cores abaixo são produzidas automaticamente por
`ColorScheme.fromSeed(seedColor: #00BFA6, brightness: ...)`.

#### Tema claro

| Token | Hex | Token | Hex |
|---|---|---|---|
| `primary` | `#046B5C` | `onPrimary` | `#FFFFFF` |
| `primaryContainer` | `#A0F2DF` | `onPrimaryContainer` | `#005045` |
| `secondary` | `#4A635D` | `onSecondary` | `#FFFFFF` |
| `secondaryContainer` | `#CDE8E0` | `onSecondaryContainer` | `#334B46` |
| `tertiary` | `#436278` | `onTertiary` | `#FFFFFF` |
| `tertiaryContainer` | `#C9E6FF` | `onTertiaryContainer` | `#2B4A5F` |
| `error` | `#BA1A1A` | `onError` | `#FFFFFF` |
| `errorContainer` | `#FFDAD6` | `onErrorContainer` | `#93000A` |
| `surface` | `#F5FBF7` | `onSurface` | `#171D1B` |
| `surfaceContainerHighest` | `#DEE4E1` | `onSurfaceVariant` | `#3F4946` |
| `outline` | `#6F7976` | `outlineVariant` | `#BEC9C5` |
| `inverseSurface` | `#2B3230` | `onInverseSurface` | `#ECF2EF` |
| `scaffoldBackgroundColor` | `#F3F6FA` | — | — |

#### Tema escuro

| Token | Hex | Token | Hex |
|---|---|---|---|
| `primary` | `#84D6C3` | `onPrimary` | `#00382F` |
| `primaryContainer` | `#005045` | `onPrimaryContainer` | `#A0F2DF` |
| `secondary` | `#B1CCC4` | `onSecondary` | `#1C352F` |
| `secondaryContainer` | `#334B46` | `onSecondaryContainer` | `#CDE8E0` |
| `tertiary` | `#ABCAE4` | `onTertiary` | `#123348` |
| `tertiaryContainer` | `#2B4A5F` | `onTertiaryContainer` | `#C9E6FF` |
| `error` | `#FFB4AB` | `onError` | `#690005` |
| `errorContainer` | `#93000A` | `onErrorContainer` | `#FFDAD6` |
| `surface` | `#0E1513` | `onSurface` | `#DEE4E1` |
| `surfaceContainerHighest` | `#303634` | `onSurfaceVariant` | `#BEC9C5` |
| `outline` | `#89938F` | `outlineVariant` | `#3F4946` |
| `inverseSurface` | `#DEE4E1` | `onInverseSurface` | `#2B3230` |
| `scaffoldBackgroundColor` | `#0B0F14` | — | — |

### 1.5 Cores de estado

| Estado | Cor | Aplicação |
|---|---|---|
| Sucesso / offline | `#22C55E` | Estatística “Offline”, selo “Offline”, confirmações, SnackBar de sucesso, resultado de lote concluído, selo AES-256 |
| Informação | `#0EA5E9` | Estatística “Em disco”, filtro “Informação” nos logs, nível padrão `info` |
| Alerta / pendente | `#F5B93F` (`AppTheme.corDourada`) | Link ainda não baixado, aviso de senha padrão, download cancelado, estatística de músicas |
| Erro de SnackBar | `#EF4444` | SnackBar de erro |
| Erro Material | `scheme.error` (`#BA1A1A` claro / `#FFB4AB` escuro) | Banners de erro, validações, botões destrutivos e ícones de excluir |

### 1.6 Escala de opacidade

As cores são aplicadas com `withValues(alpha: ...)` para preservar consistência
entre os temas.

| Alpha | Uso típico |
|---|---|
| `0.05`–`0.10` | Fundo de banners, blocos de erro, painel de progresso e círculos decorativos |
| `0.12`–`0.18` | Fundo de ícones, badges, etiquetas, seleção de navegação |
| `0.22`–`0.35` | Bordas de banners, chips, avisos e overlays |
| `0.45`–`0.50` | Divisores e contornos estruturais (`AppTheme.borda`) |
| `0.60`–`0.82` | Textos secundários sobre fundos coloridos ou gradientes |

---

## 2. Onde cada cor é aplicada

### 2.1 Barra lateral e navegação (`lib/views/tela_shell.dart`)

| Elemento | Cores |
|---|---|
| Fundo da barra | `AppTheme.superficie` |
| Divisor vertical | `AppTheme.borda` |
| Logo | Gradiente `#00BFA6` → `#7C6BFF`, ícone branco, sombra `#00BFA6` a 28% |
| Rótulo “OFFLINE” | `AppTheme.corPrimaria` |
| Item ativo | Fundo `scheme.primary` a 13%, borda a 28%, ícone/texto `scheme.primary` |
| Item inativo | Ícone/texto `AppTheme.textoSuave` |
| Badge de logs | `AppTheme.corSecundaria` a 14%, texto na mesma cor |
| Rodapé | Texto e ícones em `AppTheme.textoSuave` |

### 2.2 Tela Início (`lib/views/tela_inicio.dart`)

| Elemento | Cores |
|---|---|
| Hero | Gradiente `#008F7E` → `#5B4BD6`; sombra `#00BFA6` a 18% |
| Selo “MÚSICA SEM ANÚNCIOS” | Branco a 16% de fundo, texto branco |
| Título e descrição do hero | Branco e branco a 82% |
| Botão “Abrir Player” | Fundo branco, texto `#0B4F47` |
| Botão “Ver logs” | Texto branco, borda branca a 50% |
| Círculos decorativos | Branco a 10% e 14% |
| Cartões de estatística | `AppTheme.superficie`, borda `AppTheme.borda` |
| Pastas | Ícone `#7C6BFF` |
| Mídias | Ícone `#00BFA6` |
| Offline | Ícone `#22C55E` |
| Músicas | Ícone `#F5B93F` |
| Vídeos | Ícone `#FF6B6B` |
| Em disco | Ícone `#0EA5E9` |
| Linha recente — música | Ícone `#00BFA6` |
| Linha recente — vídeo | Ícone `#FF6B6B` |

### 2.3 Tela Player (`lib/views/tela_player.dart`)

| Elemento | Cores |
|---|---|
| Cartão de pasta | Fundo `AppTheme.superficie`, borda `AppTheme.borda`; ícone com `AppTheme.gradienteMarca` |
| Contagem de mídias | Ícone `scheme.primary`, texto `AppTheme.textoSuave` |
| Indicador offline da pasta | `#22C55E` |
| Botão excluir pasta/mídia | `scheme.error` |
| Cartão de áudio | Destaque `#00BFA6`; gradiente do ícone `#00BFA6` → 65% |
| Cartão de vídeo | Destaque `#FF6B6B`; gradiente do ícone `#FF6B6B` → 65% |
| Selo “Offline” | `#22C55E` |
| Selo “Link da web” | `#F5B93F` |
| Banner de erro | `scheme.error` a 9% no fundo, borda a 25%, texto/ícone `scheme.error` |
| Painel de progresso | `scheme.primary` a 8% no fundo, borda a 22%, textos e progresso `scheme.primary` |
| Resultado do lote — sucesso | `#22C55E` |
| Resultado do lote — cancelado | `#F5B93F` |
| Resultado do lote — falha | `scheme.error` |
| Mensagem vazia | Ícone e destaque `scheme.primary` |

### 2.4 Logs (`lib/views/tela_logs.dart`)

| Elemento | Cores |
|---|---|
| Cartão de log | `AppTheme.superficie`, borda `AppTheme.borda` |
| Filtro “Todos” | `#00BFA6` |
| Filtro “Sucesso” | `#22C55E` |
| Filtro “Ações” | `#7C6BFF` |
| Filtro “Informação” | `#0EA5E9` |
| Filtro “Erros” | `#FF6B6B` |
| Filtro ativo | Cor do filtro a 16% no fundo, borda a 50%, texto na cor |
| Etiqueta de módulo | `#7C6BFF` |
| Nível `sucesso` | Ícone `#22C55E` |
| Nível `erro` | Ícone `#FF6B6B` |
| Nível `acao` | Ícone `#7C6BFF` |
| Nível `info` | Ícone `#0EA5E9` |
| Data/hora | `AppTheme.textoSuave`, com números tabulares |

### 2.5 Configurações (`lib/views/dialog_configuracoes.dart`)

| Elemento | Cores |
|---|---|
| Blocos de seção | Fundo `AppTheme.superficieSuave`, borda `AppTheme.borda` |
| Ícones de seção | `scheme.primary` |
| Aviso de senha padrão | `#F5B93F` a 12% no fundo, borda a 35%, ícone/texto na cor |
| Caminho da pasta | `AppTheme.superficie`, borda `AppTheme.borda`, texto `AppTheme.textoSuave` em monoespaçado |
| Etiquetas “Sobre” | Player `#00BFA6`, versão `#7C6BFF`, AES-256 `#22C55E` |
| Erros de formulário | `scheme.error` |

### 2.6 Diálogos e widgets compartilhados

| Elemento | Cores |
|---|---|
| `DialogoBase` | Fundo `AppTheme.superficie`, borda `AppTheme.borda`, ícone `scheme.primary` ou cor customizada |
| `CabecalhoSecao` | Ícone e etiqueta em `scheme.primary` ou `corIcone` |
| `Etiqueta` | Cor base a 13% no fundo, borda a 25%, texto e ícone na cor |
| `Vazio` | Círculo `scheme.primary` a 10% / borda a 22%, ícone `scheme.primary` |
| `confirmar` | Ícone `scheme.error` (destrutivo) ou `scheme.primary`; botão de confirmação `scheme.error` |
| `verificarAcessoAdmin` | Ícone `scheme.primary`, erros `scheme.error` |
| `DialogFormPasta` | Fundo de aviso `scheme.primary` a 8%, borda a 18% |
| `DialogNovoItemPlayer` | Bloco de destino `AppTheme.superficieSuave`, ícone `scheme.primary`, erros `scheme.error` |
| `DialogBaixarLote` | Cabeçalho com `AppTheme.gradienteMarca`, bloco de destino `scheme.primary` a 8%, erros `scheme.error` |

### 2.7 Player de mídia (`lib/views/player/dialog_player_midia.dart`)

| Elemento | Cores |
|---|---|
| Fundo do diálogo | `AppTheme.superficie`, borda `AppTheme.borda` |
| Cabeçalho de música | Gradiente `#00BFA6` → 65% |
| Cabeçalho de vídeo | Gradiente `#FF6B6B` → 65% |
| Área de vídeo | Fundo preto, controles e spinner brancos |
| Capa de música | Gradiente `scheme.primary` → `#7C6BFF` → `scheme.tertiary` |
| Círculos decorativos | Branco a 5% e 7% |
| Disco central | Preto a 22%, borda branca a 22%, centro branco a 16% |
| Texto sobre a capa | Branco e branco a 78% |
| Botão play/pause | Fundo `scheme.primary`, ícone `scheme.onPrimary` |
| Slider e textos auxiliares | `scheme.primary` / `AppTheme.textoSuave` |
| Erro de reprodução | `scheme.error` a 9%, borda a 25% |

### 2.8 SnackBars e tela de falha

| Elemento | Cores |
|---|---|
| SnackBar de sucesso | Fundo `#22C55E` a 96%, conteúdo branco |
| SnackBar de erro | Fundo `#EF4444` a 96%, conteúdo branco |
| SnackBar informativo | Fundo `#00BFA6` a 96%, conteúdo branco |
| Tela de falha de inicialização | Tema escuro, ícone `#FF6B6B`, bloco de erro `#FF6B6B` a 10% |

### 2.9 Componentes Material padronizados

| Elemento | Cores |
|---|---|
| `AppBar` | Fundo transparente, sem elevação |
| `Divider` | `outlineVariant` a 45% |
| Campos de texto | Preenchimento `AppTheme.superficie`; borda normal `outlineVariant`; foco `scheme.primary` com 1,6 px; erro `scheme.error` |
| Rótulos e hints | `onSurfaceVariant` (hint a 70%) |
| Tooltip | `inverseSurface` / `onInverseSurface` |
| Splash | `InkSparkle.splashFactory` (usa cores do `ColorScheme`) |

---

## 3. Tipografia

### 3.1 Família tipográfica

O projeto **não declara fontes customizadas** no `pubspec.yaml` e não possui
assets de fonte. Portanto, usa a fonte padrão da plataforma:

| Plataforma | Fonte padrão |
|---|---|
| Windows (alvo principal) | **Segoe UI** |
| macOS | San Francisco |
| Linux | Fonte definida pelo sistema (geralmente Ubuntu/Noto Sans) |

Fontes auxiliares:

| Fonte | Onde é usada |
|---|---|
| **Material Icons** | Todos os ícones (`uses-material-design: true`) |
| **monospace** (família genérica do sistema) | Caminho da pasta de downloads em Configurações e detalhes técnicos na tela de falha |
| **Números tabulares** (`FontFeature.tabularFigures()`) | Horário dos logs, para evitar variação de largura entre os dígitos |

> Não há fontes externas, Google Fonts ou arquivos `.ttf`/`.otf` no projeto.

### 3.2 Estilos base do Material 3

O `ThemeData` usa `useMaterial3: true` e herda a escala tipográfica padrão do
Material. Os estilos mais usados são:

| Estilo | Uso |
|---|---|
| `headlineSmall` | Título principal de cada seção (`CabecalhoSecao`), com peso 700 e `letter-spacing: -0.3` |
| `titleLarge` | Título de diálogos e do cabeçalho do player, com peso 700 |
| `titleMedium` | Títulos de cartões, seções internas e “Últimas mídias”, com peso 700 |
| `titleSmall` | Títulos de mídia e subtítulos de seção, com peso 700 |
| `bodyMedium` | Textos descritivos e mensagens de estado vazio |
| `bodySmall` | Subtítulos de cabeçalhos, em `AppTheme.textoSuave` |
| `labelLarge` | Rótulo padrão de botões Material |

### 3.3 Escala customizada

Além dos estilos herdados, os componentes usam tamanhos explícitos:

| Tamanho | Peso | Aplicação |
|---|---|---|
| `26 px` | 800 | Título do hero da tela Início, altura 1.16, `letter-spacing: -0.5` |
| `20 px` | 700 | Título da tela de falha de inicialização |
| `18 px` | 700 | Título da música na capa do player |
| `16 px` | 800 | Nome “Player” na barra lateral |
| `14.5 px` | 700 | Título da mídia no cartão do Player |
| `14 px` | 700 | Título de seção nas Configurações |
| `13 px` | 500–700 | Itens de navegação, descrição do hero, título de log, textos de apoio |
| `12.5 px` | 500–700 | Textos de botões compactos, mensagens de erro, banners e legendas |
| `12 px` | 400–600 | Descrições de pasta, filtros, tempo do player, textos de formulário |
| `11.5 px` | 400 | Subtítulos, metadados de mídia, textos de ajuda |
| `11 px` | 400 | Contagens, datas curtas e textos auxiliares |
| `10.5 px` | 400–700 | Microtextos, “OFFLINE”, dicas de interação e rodapé |
| `9.5 px` | 700 | Letreiro “OFFLINE” da marca, com `letter-spacing: 1.6` |
| `10 px` | 700 | Contador de logs na barra lateral |

### 3.4 Pesos e espaçamento

| Peso | Uso |
|---|---|
| `w500` | Textos de navegação inativos e corpo de SnackBar |
| `w600` | Etiquetas, subtítulos de botões e nomes de mídia |
| `w700` | Títulos, filtros ativos, ênfases e ações principais |
| `w800` | Marca e título do hero |

`letter-spacing` é usado apenas em situações de ênfase:

- `-0.5` no título do hero;
- `-0.4` no nome da marca e nos valores das estatísticas;
- `-0.3` no `headlineSmall` dos cabeçalhos;
- `0.1` nos títulos de seção do Player;
- `0.7`–`1.6` em letreiros maiúsculos (“MÚSICA SEM ANÚNCIOS” e “OFFLINE”).

### 3.5 Altura de linha

Textos longos usam `height` entre `1.35` e `1.5` para leitura confortável
(descrições, mensagens de erro e textos de estado vazio). Títulos curtos usam
`1.16` no hero e o padrão do Material nos demais casos.

---

## 4. Regras de uso

1. **Texto sobre fundo claro** deve usar `scheme.primary` (`#046B5C`) e não
   `AppTheme.corPrimaria` (`#00BFA6`), que tem contraste insuficiente para
   textos pequenos.
2. **Texto sobre fundo escuro** deve usar `scheme.primary` (`#84D6C3`) para
   links, ícones e destaques.
3. **Cores de marca** (`corPrimaria`, `corSecundaria`, `corVermelha`,
   `corDourada`) são reservadas para identidade, ícones, badges e gradientes.
4. **Erros destrutivos** usam `scheme.error`, não `AppTheme.corVermelha`; esta
   última é a cor de categoria “vídeo” e de ícones de erro em contexto
   ilustrativo.
5. **Superfícies** devem usar os helpers `AppTheme.superficie(context)` e
   `AppTheme.superficieSuave(context)` para responder automaticamente ao tema.
6. **Opacidade** deve ser aplicada com `withValues(alpha: ...)`, mantendo a
   escala descrita na seção 1.6.
7. **Novos componentes** devem reutilizar `Etiqueta`, `Vazio`,
   `CabecalhoSecao` e `DialogoBase` antes de criar estilos próprios.

---

## 5. Arquivos de referência

| Arquivo | Responsabilidade visual |
|---|---|
| `lib/theme/app_theme.dart` | Tokens de marca, temas claro/escuro, superfícies, bordas e tipografia base |
| `lib/utils/widgets_compartilhados.dart` | Cabeçalhos, etiquetas, estados vazios, diálogos e SnackBars |
| `lib/views/tela_shell.dart` | Barra lateral, marca, navegação e rodapé |
| `lib/views/tela_inicio.dart` | Hero, estatísticas e atalhos |
| `lib/views/tela_player.dart` | Pastas, cartões de mídia, banners e progresso |
| `lib/views/tela_logs.dart` | Filtros, cartões e níveis de log |
| `lib/views/dialog_configuracoes.dart` | Aparência, pasta de downloads e segurança |
| `lib/views/player/dialog_player_midia.dart` | Player de áudio e vídeo |
| `lib/main.dart` | Aplicação dos temas e tela de falha |

---

## 6. Como alterar a identidade visual

1. Atualize as constantes em `lib/theme/app_theme.dart`.
2. O `ColorScheme` será regenerado automaticamente a partir de `corPrimaria`.
3. Ajuste os gradientes fixos do hero (`#008F7E` → `#5B4BD6`) em
   `lib/views/tela_inicio.dart`, caso a marca mude.
4. Revise as cores de estado (`#22C55E`, `#0EA5E9`, `#EF4444`) caso seja
   necessária uma paleta de feedback diferente.
5. Execute `flutter analyze`, `flutter test` e valide visualmente nos dois temas.
