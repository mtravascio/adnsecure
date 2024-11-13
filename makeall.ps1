$buildir=".\build"
$buildfiles="$buildir\*"

if (-not (Test-Path $buildir)) {
	New-Item -ItemType Directory -Path $buildir
} else {
	Remove-Item $buildfiles -Force
}

Set-Location ".\rsakey2dart\"
dart pub get
dart compile exe .\bin\rsakey2dart.dart
.\bin\rsakey2dart.exe
#cp .\bin\rsakey2dart.exe  ..\build\rsakey2dart.exe

Set-Location "..\encryptjoin2"
dart pub get
dart compile exe .\bin\encryptjoin2.dart
.\bin\encryptjoin2.exe --wkey=WKCISTOTO30001 --psw="UTENTI\massimo.travascio,Password01"

Copy-Item ".\bin\encryptjoin2.exe" -Destination "..\build\" -Force
Copy-Item ".\encrypted_password.txt" -Destination "..\securejoin2\" -Force
Copy-Item ".\encrypted_rsa.txt"	-Destination "..\build\" -Force
Copy-Item ".\encrypted_password.txt" -Destination "..\build\" -Force

Set-Location "..\securejoin2\"
dart pub get
dart compile exe .\bin\securejoin2.dart
.\bin\securejoin2.exe --wkey=WKCISTOTO30001

Copy-Item ".\bin\securejoin2.exe" -Destination "..\build\" -Force

Set-Location "..\encryptscr\"
dart pub get
dart compile exe .\bin\encryptscr.dart
.\bin\encryptscr.exe --wks=WKCISTOTO30001 --file=".\script.ps1" -s -x

Copy-Item ".\bin\encryptscr.exe" -Destination "..\build\" -Force
Copy-Item ".\script.enc" -Destination "..\build\" -Force
Copy-Item ".\WKCISTOTO30001.scr" -Destination "..\build\" -Force
Copy-Item ".\WKCISTOTO30001.scr" -Destination "..\secscr\" -Force

Set-Location "..\secscr\"
dart pub get
dart compile exe .\bin\secscr.dart
.\bin\secscr.exe --wks=WKCISTOTO30001 -s -x

Copy-Item ".\bin\secscr.exe" -Destination "..\build\" -Force

Set-Location "..\"
