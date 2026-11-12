/// Define a versão da Bíblia usada como padrão para cada idioma da interface.
///
/// A escolha do idioma no primeiro acesso (ou nas configurações) seleciona
/// automaticamente a versão da Bíblia correspondente. Quando o idioma possui
/// mais de uma versão, a primeira opção abaixo é a padrão — no português (Brasil)
/// a padrão é a NVI.
library;

/// Chave de `SharedPreferences` onde a versão selecionada é salva.
const String kBibleVersionPrefsKey = 'selectedVersion';

/// Versão padrão do português (Brasil).
const String kDefaultPortugueseBibleFile = 'nvi.json';

/// Versão usada quando nenhum idioma é reconhecido (o app assume português).
const String kDefaultBibleFile = kDefaultPortugueseBibleFile;

/// Arquivo `.json` padrão para cada idioma suportado pela interface.
const Map<String, String> _bibleFileByLanguage = <String, String>{
  'pt': kDefaultPortugueseBibleFile,
  'en': 'en_kjv.json',
  'es': 'es_rvr.json',
  'de': 'de_schlachter.json',
  'fr': 'fr_apee.json',
  'ru': 'ru_synodal.json',
  'zh': 'zh_cuv.json',
  'ko': 'ko_ko.json',
  'vi': 'vi_vietnamese.json',
  'el': 'el_greek.json',
  'ro': 'ro_cornilescu.json',
  'eo': 'eo_esperanto.json',
  'ar': 'ar_svd.json',
  'fi': 'fi_finnish.json',
};

/// Arquivo `.json` de cada versão, indexado pela chave exibida no seletor.
const Map<String, String> _bibleFileByKey = <String, String>{
  'ACF': 'acf.json',
  'AA': 'aa.json',
  'NVI': 'nvi.json',
  'KJV': 'en_kjv.json',
  'BBE': 'en_bbe.json',
  'RVR': 'es_rvr.json',
  'SCHLACHTER': 'de_schlachter.json',
  'APEE': 'fr_apee.json',
  'SYNODAL': 'ru_synodal.json',
  'CUV': 'zh_cuv.json',
  'NCV': 'zh_ncv.json',
  'KO': 'ko_ko.json',
  'VIETNAMESE': 'vi_vietnamese.json',
  'GREEK': 'el_greek.json',
  'CORNILESCU': 'ro_cornilescu.json',
  'ESPERANTO': 'eo_esperanto.json',
  'SVD': 'ar_svd.json',
  'FINNISH': 'fi_finnish.json',
  'FI_PR': 'fi_pr.json',
};

/// Retorna o arquivo da Bíblia padrão para [languageCode].
///
/// Aceita códigos como `pt`, `pt-BR` ou `pt_BR`. Idiomas desconhecidos usam o
/// padrão do português.
String bibleVersionFileForLanguage(String languageCode) {
  final normalized =
      languageCode.toLowerCase().replaceAll('_', '-').split('-').first;
  return _bibleFileByLanguage[normalized] ?? kDefaultBibleFile;
}

/// Retorna o arquivo correspondente à [key] do seletor de versões.
String? bibleVersionFileForKey(String key) =>
    _bibleFileByKey[key.toUpperCase()];

/// Retorna a chave do seletor correspondente ao [fileName] salvo.
String bibleVersionKeyForFile(String fileName) {
  for (final entry in _bibleFileByKey.entries) {
    if (entry.value == fileName) return entry.key;
  }
  return 'NVI';
}
