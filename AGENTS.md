# Tarefas

``
flutter build apk --release
Resolving dependencies...
Downloading packages...
archive 4.0.9 (4.3.0 available)
audio_service 0.18.18 (0.18.19 available)
audio_session 0.2.3 (0.2.4 available)
cli_util 0.4.2 (0.6.0 available)
clock 1.1.2 (1.1.3 available)
code_assets 1.2.1 (2.1.0 available)
connectivity_plus 7.1.1 (7.3.1 available)
cross_file 0.3.5+2 (0.3.5+5 available)
dbus 0.7.14 (0.8.0 available)
dio 5.9.2 (5.11.1 available)
dio_web_adapter 2.1.2 (2.2.2 available)
file_picker 12.0.0-beta.5 (13.1.0 available)
flutter_cache_manager 3.4.1 (3.4.5 available)
glob 2.1.3 (2.2.0 available)
hooks 2.0.2 (2.2.0 available)
html 0.15.6 (0.15.7 available)
image 4.8.0 (4.10.1 available)
in_app_update 4.2.5 (5.0.0 available)
jni 1.0.0 (1.0.3 available)
jni_flutter 1.0.1 (1.0.3 available)
just_audio 0.10.5 (0.10.6 available)
material_color_utilities 0.13.0 (0.13.1 available)
mime 2.0.0 (2.1.0 available)
native_toolchain_c 0.19.1 (0.19.5 available)
objective_c 9.4.1 (9.6.0 available)
package_config 2.2.0 (3.0.0 available)
package_info_plus 10.1.0 (10.2.1 available)
path_provider 2.1.5 (2.1.6 available)
path_provider_linux 2.2.1 (2.2.2 available)
path_provider_platform_interface 2.1.2 (2.1.3 available)
platform 3.1.6 (3.2.0 available)
posix 6.5.0 (6.5.2 available)
pub_semver 2.2.0 (2.2.1 available)
record_use 0.6.0 (1.1.1 available)
safe_local_storage 2.0.3 (2.0.6 available)
share_plus 13.1.0 (13.3.0 available)
share_plus_platform_interface 7.1.0 (7.2.0 available)
shared_preferences_android 2.4.26 (2.4.28 available)
shared_preferences_foundation 2.5.6 (2.5.7 available)
sqflite 2.4.3 (2.4.4 available)
sqflite_android 2.4.3 (2.4.4 available)
sqflite_common 2.5.11 (2.5.13 available)
sqflite_common_ffi 2.4.2 (2.4.3 available)
sqflite_darwin 2.4.3 (2.4.4 available)
sqflite_platform_interface 2.4.1 (2.4.2 available)
sqlite3 3.3.3 (3.6.0 available)
stack_trace 1.12.1 (1.12.2 available)
synchronized 3.4.1 (3.4.2 available)
test_api 0.7.12 (0.7.14 available)
upgrader 13.5.0 (13.7.0 available)
url_launcher_android 6.3.32 (6.3.33 available)
url_launcher_ios 6.4.1 (6.4.2 available)
url_launcher_linux 3.2.2 (3.2.3 available)
url_launcher_macos 3.2.5 (3.2.6 available)
url_launcher_windows 3.1.5 (3.1.6 available)
uuid 4.5.3 (4.6.0 available)
vector_math 2.4.2 (2.4.3 available)
vm_service 15.2.0 (15.3.0 available)
win32 6.3.0 (6.4.0 available)
xml 6.6.1 (7.0.1 available)
yaml 3.1.3 (3.1.4 available)
Got dependencies!
61 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): audio_session, in_app_update, package_info_plus, share_plus
Future versions of Flutter will fail to build if your app uses plugins that apply KGP.

Please check the changelogs of these plugins and upgrade to a version that supports Built-in Kotlin.
If no such version exists, report the issue to the plugin. If necessary, here is a guide on filing
an issue against a plugin: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers#report-incompatible-kotlin-gradle-plugin-usage-to-plugin-authors

If you are a plugin author, please migrate your plugin to Built-in Kotlin using this guide: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 12560 bytes (99.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.

FAILURE: Build failed with an exception.

* What went wrong:
  Execution failed for task ':app:validateSigningRelease'.
> Keystore file 'C:\Users\ruang\OneDrive\Documentos\Projetos\Biblia-Harpa\android\app\key.jks' not found for signing config 'release'.

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to generate a Build Scan (Powered by Develocity).
> Get more help at https://help.gradle.org.

BUILD FAILED in 4m 16s
Running Gradle task 'assembleRelease'...                          257,3s
Gradle task assembleRelease failed with exit code 1
``