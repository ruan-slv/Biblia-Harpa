import 'dart:io';

import 'package:biblia_e_harpa/src/l10n/app_localizations.dart';
import 'package:biblia_e_harpa/src/utils/bible_version_defaults.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cada idioma da interface aponta para uma Bíblia existente', () {
    for (final language in appLanguages) {
      final fileName = bibleVersionFileForLanguage(language.code);
      final asset = File('assets/json/bible/$fileName');
      expect(
        asset.existsSync(),
        isTrue,
        reason: '${language.code} aponta para $fileName, que não existe',
      );
    }
  });

  test('português usa a NVI como versão padrão', () {
    expect(bibleVersionFileForLanguage('pt'), 'nvi.json');
    expect(bibleVersionFileForLanguage('pt-BR'), 'nvi.json');
    expect(bibleVersionFileForLanguage('pt_BR'), 'nvi.json');
  });

  test('russo usa a versão Synodal', () {
    expect(bibleVersionFileForLanguage('ru'), 'ru_synodal.json');
  });

  test('idioma desconhecido usa o padrão do português', () {
    expect(bibleVersionFileForLanguage('xx'), kDefaultBibleFile);
    expect(kDefaultBibleFile, 'nvi.json');
  });

  test('converte chave do seletor e arquivo nos dois sentidos', () {
    expect(bibleVersionFileForKey('NVI'), 'nvi.json');
    expect(bibleVersionFileForKey('nvi'), 'nvi.json');
    expect(bibleVersionFileForKey('SYNODAL'), 'ru_synodal.json');
    expect(bibleVersionKeyForFile('nvi.json'), 'NVI');
    expect(bibleVersionKeyForFile('ru_synodal.json'), 'SYNODAL');
  });
}
