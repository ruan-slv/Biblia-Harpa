import 'package:biblia_e_harpa/src/controllers/settings_controller.dart';
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
}
