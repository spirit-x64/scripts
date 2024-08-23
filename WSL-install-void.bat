@echo off

echo THIS SCRIPT IS NOT FULLY TESTED YET
echo use at ur own

if not defined DISTRONAME set DISTRONAME=void
if not defined STORAGEPATH set STORAGEPATH=%cd%
if not defined USER set USER=spirit

mkdir .void-on-WSL2.temp
cd .void-on-WSL2.temp

echo downloading 7zr.exe...
curl.exe -LSfs --remote-name --remove-on-error https://7-zip.org/a/7zr.exe
echo downloading void-x86_64-ROOTFS...
curl.exe -LSfs --remote-name --remove-on-error https://repo-default.voidlinux.org/live/current/void-x86_64-ROOTFS-20240314.tar.xz
7zr.exe x void-x86_64-ROOTFS-20240314.tar.xz -oextracted

wsl.exe --import %DISTRONAME% %STORAGEPATH% extracted\void-x86_64-ROOTFS-20240314.tar

echo downloading init-void.sh and setup-void.sh...
curl.exe -LSfs --remote-name --remove-on-error https://raw.githubusercontent.com/spirit-x64/scripts/main/void-init.sh
curl.exe -LSfs --remote-name --remove-on-error https://raw.githubusercontent.com/spirit-x64/scripts/main/void-setup.sh

wsl -d %DISTRONAME% -e sh -c "USERNAME=%USER% ./init-void.sh --wsl"

wsl --terminate %DISTRONAME%
wsl -d %DISTRONAME% -e sh -c "./setup-void.sh --no-gui"

cd ..
rd /s /q .void-on-WSL2.temp

echo Void Linux ready (it could be, didn't check tho..)
echo Press any key to exit . . .
pause>nul
