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

Copy-Item ".\bin\securejoin2.exe" -Destination "..\build\securejoin2.exe" -Force

Set-Location "..\"
