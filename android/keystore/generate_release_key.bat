@echo off
rem Wrapper: executa o script PowerShell de geracao da chave de release.
rem Uso:  android\keystore\generate_release_key.bat
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0generate_release_key.ps1"
