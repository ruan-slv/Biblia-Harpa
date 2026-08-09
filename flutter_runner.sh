#!/usr/bin/env bash

# Clear cache and reload Flutter
cache_clean() {
  echo "*** Cleaning cache and fetching dependencies ***"
  flutter clean && flutter pub get
}

# Desktop build commands
desktop_builds=("flutter build linux" "flutter build windows" "flutter build macos")

case $1 in
  "test" | "deployment")
    echo "============================================="
    echo " Select the target platform:"
    echo " [0] android   [1] ios   [2] windows"
    echo " [3] macos     [4] linux [5] web"
    echo " [6] desktop   [7] all"
    echo "============================================="

    read -p "Choose the type of build (number): " opt
    cache_clean

    case $opt in
      0)
        echo "*** Building Android ***"
        flutter build apk --release --obfuscate --split-debug-info=build/symbols
        flutter build appbundle
        ;;
      1)
        echo "*** Building iOS ***"
        flutter build ios --release --obfuscate --split-debug-info=build/symbols
        flutter build ipa
        ;;
      2)
        echo "*** Building Windows ***"
        flutter build windows
        ;;
      3)
        echo "*** Building macOS ***"
        flutter build macos
        ;;
      4)
        echo "*** Building Linux ***"
        flutter build linux
        ;;
      5)
        echo "*** Building Web ***"
        flutter build web
        ;;
      6)
        echo "*** Building all desktop targets ***"
        for build in "${desktop_builds[@]}"; do
          $build
        done
        ;;
      7)
        echo "*** Building all platforms ***"
        flutter build apk --release
        flutter build appbundle
        flutter build ios --release
        flutter build ipa
        flutter build windows
        flutter build macos
        flutter build linux
        flutter build web
        ;;
      *)
        echo "Invalid option."
        exit 1
        ;;
    esac
    echo "*** Finished ***"
    ;;
  *)
    echo "Invalid command. Use 'test' or 'deployment'."
    exit 1
    ;;
esac
