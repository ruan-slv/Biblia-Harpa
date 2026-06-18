#!/usr/bin/env bash

# Clear cache and reload de flutter
cache_clean() {
  echo "*** Clean cache and fetching dependencies ***"
  flutter clean && flutter pub get
}
# desktop build
desktop_builds=("flutter build linux" "flutter build windows" "flutter build macos")
# You can choose one of the above options
case $1 in
  "test" | "deployment")
    echo "============================================="
    echo " Select the target platforms (separated by spaces):"
    echo "============================================="
    echo " [0] android   [1] ios   [2] windows"
    echo " [3] macos     [4] linux [5] web"
    echo " [6] desktop   [7] all"
    echo "============================================="

    read -p "Choose the type of build that would be show on menu: " opt
    cache_clean
    # Set the build option and verify if it's ok
    # Android
    if [[ $2 -eq 0 ]];then
      echo "*** Generating a build test for android apk ***"
      cache_clean
      flutter build apk --release --obfuscate --split-debug-info=build/symbols
      flutter build appbundle
      echo "*** Finished ***"
      exit 0
    # IOS
    elif [[ $2 -eq 1 ]];then
      echo "*** Generating a build test for ios apk ***"
      cache_clean
      flutter build ios --release --obfuscate --split-debug-info=build/symbols
      flutter build ipa
      echo "*** Finished ***"
      exit 0
    # Windows
    elif [[ $2 -eq 2 ]];then
      echo "*** Generating a build test for windows apk ***"
      flutter build windows
      echo "*** Finished ***"
      exit 0
    elif [[ $2 -eq 3 ]];then
      echo "*** Generating a build test for macos apk ***"
      flutter build macos
      echo "*** Finished ***"
      exit 0
    elif [[ $2 -eq 4 ]];then
      echo "*** Generating a build test for linux apk ***"
      flutter build linux
      echo "*** Finished ***"
      exit 0
    elif [[ $2 -eq 5 ]];then
      echo "*** Generating a build test for web apk ***"
      flutter build web
      echo "*** Finished ***"
      exit 0
    elif [[ $2 -eq 6 ]];then
      echo "*** Generating a build test for web apk ***"
      ${desktop_builds[@]}
      echo "*** Finished ***"
      exit 0
    exit 0
    ;;
  *)
    echo "Inválid options ."
    exit 1
    ;;
esac