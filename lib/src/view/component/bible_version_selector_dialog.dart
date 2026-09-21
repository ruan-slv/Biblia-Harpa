/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';

class BibleVersionInfo {
  final String key;
  final String fileName;
  final String name;
  final String language;
  final String flag;

  const BibleVersionInfo({
    required this.key,
    required this.fileName,
    required this.name,
    required this.language,
    required this.flag,
  });
}

final List<BibleVersionInfo> bibleVersions = [
  // Português
  const BibleVersionInfo(key: 'ACF', fileName: 'acf.json', name: 'Almeida Corrigida Fiel', language: 'Português', flag: '🇧🇷'),
  const BibleVersionInfo(key: 'AA', fileName: 'aa.json', name: 'Almeida Atualizada', language: 'Português', flag: '🇧🇷'),
  const BibleVersionInfo(key: 'NVI', fileName: 'nvi.json', name: 'Nova Versão Internacional', language: 'Português', flag: '🇧🇷'),
  // Inglês
  const BibleVersionInfo(key: 'KJV', fileName: 'en_kjv.json', name: 'King James Version', language: 'English', flag: '🇬🇧'),
  const BibleVersionInfo(key: 'BBE', fileName: 'en_bbe.json', name: 'Basic English Bible', language: 'English', flag: '🇬🇧'),
  // Espanhol
  const BibleVersionInfo(key: 'RVR', fileName: 'es_rvr.json', name: 'Reina-Valera', language: 'Español', flag: '🇪🇸'),
  // Alemão
  const BibleVersionInfo(key: 'SCHLACHTER', fileName: 'de_schlachter.json', name: 'Schlachter', language: 'Deutsch', flag: '🇩🇪'),
  // Francês
  const BibleVersionInfo(key: 'APEE', fileName: 'fr_apee.json', name: 'APEE', language: 'Français', flag: '🇫🇷'),
  // Russo
  const BibleVersionInfo(key: 'SYNODAL', fileName: 'ru_synodal.json', name: 'Synodal', language: 'Русский', flag: '🇷🇺'),
  // Chinês
  const BibleVersionInfo(key: 'CUV', fileName: 'zh_cuv.json', name: 'Chinese Union Version', language: '中文', flag: '🇨🇳'),
  const BibleVersionInfo(key: 'NCV', fileName: 'zh_ncv.json', name: 'New Chinese Version', language: '中文', flag: '🇨🇳'),
  // Coreano
  const BibleVersionInfo(key: 'KO', fileName: 'ko_ko.json', name: 'Korean', language: '한국어', flag: '🇰🇷'),
  // Vietnamita
  const BibleVersionInfo(key: 'VIETNAMESE', fileName: 'vi_vietnamese.json', name: 'Vietnamese', language: 'Tiếng Việt', flag: '🇻🇳'),
  // Grego
  const BibleVersionInfo(key: 'GREEK', fileName: 'el_greek.json', name: 'Greek', language: 'Ελληνικά', flag: '🇬🇷'),
  // Romeno
  const BibleVersionInfo(key: 'CORNILESCU', fileName: 'ro_cornilescu.json', name: 'Cornilescu', language: 'Română', flag: '🇷🇴'),
  // Esperanto
  const BibleVersionInfo(key: 'ESPERANTO', fileName: 'eo_esperanto.json', name: 'Esperanto', language: 'Esperanto', flag: '🌍'),
  // Árabe
  const BibleVersionInfo(key: 'SVD', fileName: 'ar_svd.json', name: 'Saudi Standard Version', language: 'العربية', flag: '🇸🇦'),
  // Finlandês
  const BibleVersionInfo(key: 'FINNISH', fileName: 'fi_finnish.json', name: 'Finnish', language: 'Suomi', flag: '🇫🇮'),
  const BibleVersionInfo(key: 'FI_PR', fileName: 'fi_pr.json', name: 'Finnish (PR)', language: 'Suomi', flag: '🇫🇮'),
];

class BibleVersionSelectorDialog extends StatefulWidget {
  final String currentVersionKey;
  final ValueChanged<BibleVersionInfo> onSelected;

  const BibleVersionSelectorDialog({
    super.key,
    required this.currentVersionKey,
    required this.onSelected,
  });

  @override
  State<BibleVersionSelectorDialog> createState() =>
      _BibleVersionSelectorDialogState();
}

class _BibleVersionSelectorDialogState extends State<BibleVersionSelectorDialog> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<BibleVersionInfo> get filteredVersions {
    if (_searchQuery.isEmpty) return bibleVersions;
    final query = _searchQuery.toLowerCase();
    return bibleVersions.where((v) {
      return v.name.toLowerCase().contains(query) ||
          v.language.toLowerCase().contains(query) ||
          v.key.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Selecione a versão',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou idioma',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.primary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filteredVersions.length,
                itemBuilder: (context, index) {
                  final version = filteredVersions[index];
                  final isSelected = version.key == widget.currentVersionKey;
                  return ListTile(
                    leading: Text(version.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      version.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      version.language,
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary)
                        : null,
                    onTap: () {
                      widget.onSelected(version);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}