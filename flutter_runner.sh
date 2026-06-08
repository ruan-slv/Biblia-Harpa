#!/usr/bin/env bash

flutter clean
flutter pub get

if [[ "$1" == "mobile" ]]; then
  echo "Generating mobile apk release"
  flutter build apk --release --obfuscate --split-debug-info=build/symbols

elif [[ "$1" == "playstore" ]]; then
  echo "Generating apk for playstore"
  flutter build appbundle

elif [[ "$1" == "linux" ]]; then
  echo "Generating desktop linux apk"
  flutter build linux --release

else
  echo "Argumento inválido!"
  echo "use: release ou store"
  exit 1

fi