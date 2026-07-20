@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"

set "ACTS=%~dp0tools\acts.exe"
set "NEURA=D:\SteamLibrary\steamapps\common\Call of Duty Modern Warfare III\neura"

:: make sure the target folders exist
if not exist "%NEURA%\" (
    mkdir "%NEURA%"
)
if not exist "%NEURA%\custom_scripts\" (
    mkdir "%NEURA%\custom_scripts"
)

:: fully custom scripts - no stock overrides, filename = 64-bit asset name hash
:: custom_scripts/main.gsc (root script, autoexec + system::register)
"%ACTS%" gscc "custom_scripts/main.gsc" -o "%NEURA%\custom_scripts\67BBF5C89F20A41F" -g mwiii --name "custom_scripts/main.gsc" --namespace "cicada"

:: custom_scripts/menu.gsc (cicada menu), pulled in by "#using custom_scripts\menu;" in main.gsc
"%ACTS%" gscc "custom_scripts/menu.gsc" -o "%NEURA%\custom_scripts\0E70DE8A8FD24969" -g mwiii --name "custom_scripts/menu.gsc" --namespace "cicada_menu"

popd
echo:
