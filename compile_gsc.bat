@echo off
setlocal enabledelayedexpansion

set "ACTS=%~dp0tools\acts.exe"

"%ACTS%" gscc "main.gsc" -o final\31FCFD26E002B5AD -g mwiii --name "scripts/mp/art.gsc" --crc "f5051fa6" --namespace "scripts/mp/art"
::"%ACTS%" gscc "other_4500bytes.gsc" -o final\2B79931B08683E0A -g mwiii --name "script_2b79931b08683e0a.gsc" --crc "a325beb1" --namespace "namespace_152f3860b54f75e5"
"%ACTS%" gscc "other.gsc" -o final\13645532f846e433 -g mwiii --name "script_13645532f846e433.gsc" --crc "1fa99f98" --namespace "namespace_eb31a7ea746bf7d0"

:: if Documents\retdonetskmod\ folder exists, keep going else create
set "MODROOT=%USERPROFILE%\Documents\retdonetskmod"
if not exist "%MODROOT%\" (
    mkdir "%MODROOT%"
)

:: copy our final\ gsc to Documents\retdonetskmod\customassets\gsc\jup_latest_stm\mp\ folder, and force override any file.
set "DEST=%MODROOT%\customassets\gsc\jup_latest_stm\mp"
if not exist "%DEST%\" (
    mkdir "%DEST%"
)
xcopy "%~dp0final\*" "%DEST%\" /Y /E /I

echo:
