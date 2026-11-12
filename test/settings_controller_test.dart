import 'package:biblia_e_harpa/src/controllers/settings_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('o modo contínuo vem ativado por padrão', () async {
    final controller = SettingsController();

    await controller.initialize();

    expect(controller.continuousPlayback, isTrue);
  });

  test('alterna o modo contínuo e salva a preferência', () async {
    final controller = SettingsController();
    await controller.initialize();

    await controller.toggleContinuousPlayback();
    expect(controller.continuousPlayback, isFalse);

    final recarregado = SettingsController();
    await recarregado.initialize();
    expect(recarregado.continuousPlayback, isFalse);
  });

  test('respeita a preferência salva pelo usuário', () async {
    SharedPreferences.setMockInitialValues({'continuous_playback': false});

    final controller = SettingsController();
    await controller.initialize();

    expect(controller.continuousPlayback, isFalse);

    await controller.setContinuousPlayback(true);
    expect(controller.continuousPlayback, isTrue);
  });

  test('começa em português e sem idioma escolhido', () async {
    final controller = SettingsController();
    await controller.initialize();

    expect(controller.languageCode, 'pt');
    expect(controller.language.nativeName, 'Português (Brasil)');
    expect(controller.hasSelectedLanguage, isFalse);
    expect(controller.initialized, isTrue);
  });

  test('salva o idioma escolhido e restaura em uma nova instância', () async {
    final controller = SettingsController();
    await controller.initialize();

    await controller.setLanguage('ru');
    expect(controller.hasSelectedLanguage, isTrue);
    expect(controller.languageCode, 'ru');
    expect(controller.locale, const Locale('ru'));

    final recarregado = SettingsController();
    await recarregado.initialize();
    expect(recarregado.hasSelectedLanguage, isTrue);
    expect(recarregado.languageCode, 'ru');
  });

  test('normaliza códigos de idioma como pt-BR', () async {
    final controller = SettingsController();
    await controller.initialize();

    await controller.setLanguage('pt-BR');

    expect(controller.languageCode, 'pt');
    expect(controller.hasSelectedLanguage, isTrue);
  });

  test('idioma desconhecido cai para português', () async {
    SharedPreferences.setMockInitialValues({'app_language': 'xx'});

    final controller = SettingsController();
    await controller.initialize();

    expect(controller.languageCode, 'pt');
    expect(controller.hasSelectedLanguage, isTrue);
  });

  test('escolher russo seleciona a Bíblia russa', () async {
    final controller = SettingsController();
    await controller.initialize();

    await controller.setLanguage('ru');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selectedVersion'), 'ru_synodal.json');
  });

  test('escolher português seleciona a NVI como padrão', () async {
    final controller = SettingsController();
    await controller.initialize();

    await controller.setLanguage('pt');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selectedVersion'), 'nvi.json');
  });

  test('trocar o idioma atualiza a versão da Bíblia', () async {
    final controller = SettingsController();
    await controller.initialize();

    await controller.setLanguage('es');
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selectedVersion'), 'es_rvr.json');

    await controller.setLanguage('de');
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selectedVersion'), 'de_schlachter.json');
  });
}
