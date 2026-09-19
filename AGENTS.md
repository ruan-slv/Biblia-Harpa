# Tarefas

## [CONCLUÍDA] Troca da base de dados local para web

**Descrição:** Remover a base de dados local para reduzir o tamanho do aplicativo.
Agora os dados são armazenados no Google Drive e baixados sob demanda.

**Implementação:**

1. **`lib/src/controllers/download_manager_controller.dart`** - Controlador responsável por:
   - Carregar metadados de downloads do `assets/data.json`
   - Gerenciar downloads de arquivos do Google Drive
   - Converter URLs do formato `open?id=` para `uc?export=download&id=`
   - Armazenar arquivos baixados em pasta local do dispositivo
   - Rastrear progresso de download

2. **`lib/src/view/download_selection_view.dart`** - View para seleção de downloads com:
   - Bandeiras de países para referência de idioma
   - Categorias: Bíblias, Áudios, Outros Conteúdos
   - Botão de "download recomendado" (NVI + Harpa)
   - Cards individuais para cada item

3. **`assets/data.json`** - Metadados de todos os arquivos disponíveis com URLs do Google Drive

4. **`pubspec.yaml`** - Adicionada dependência `http: ^1.2.2` para downloads

**Fluxo de uso:**
1. Usuário abre tela de seleção de downloads
2. Escolhe versões da Bíblia e outros conteúdos
3. App baixa arquivos do Google Drive e armazena localmente
4. Conteúdo baixado fica disponível offline