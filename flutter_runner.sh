#!/usr/bin/env bash

flutter clean
flutter pub get

if [[ "$1" == "release" ]]; then
  echo "Gerando apk de teste"
  flutter build apk --release --obfuscate --split-debug-info=build/symbols

elif [[ "$1" == "store" ]]; then
  echo "Gerando apk para a Playstore"
  flutter build appbundle

else
  echo "Argumento inválido!"
  echo "use: release ou store"
  exit 1

fi