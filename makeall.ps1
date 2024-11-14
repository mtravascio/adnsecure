$buildir=".\build"
$buildfiles="$buildir\*"

if (-not (Test-Path $buildir)) {
	New-Item -ItemType Directory -Path $buildir
} else {
	Remove-Item $buildfiles -Force
}

Set-Location ".\rsakey2dart\"
dart pub get
dart compile exe .\bin\rsakey2dart.dart -o rsakey2dart.exe -S rsakey2dart.dbg
.\rsakey2dart.exe
#cp .\rsakey2dart.exe  ..\build\rsakey2dart.exe

Set-Location "..\encryptjoin2"
dart pub get
dart compile exe .\bin\encryptjoin2.dart -o encryptjoin2.exe -S encryptjoin2.dbg
.\encryptjoin2.exe --wkey=WKCISTOTO30001 --psw="UTENTI\massimo.travascio,Password01"

Copy-Item ".\encryptjoin2.exe" -Destination "..\build\" -Force
Copy-Item ".\encrypted_password.txt" -Destination "..\securejoin2\" -Force
Copy-Item ".\encrypted_rsa.txt"	-Destination "..\build\" -Force
Copy-Item ".\encrypted_password.txt" -Destination "..\build\" -Force

Set-Location "..\securejoin2\"
dart pub get
dart compile exe .\bin\securejoin2.dart -o securejoin2.exe -S securejoin2.dbg
.\securejoin2.exe --wkey=WKCISTOTO30001

Copy-Item ".\securejoin2.exe" -Destination "..\build\" -Force

Set-Location "..\encryptscr\"
dart pub get
dart compile exe .\bin\encryptscr.dart -o encryptscr.exe -S encryptscr.dbg
.\encryptscr.exe --wks=WKCISTOTO30001 --file=".\script.ps1" -s -x

Copy-Item ".\encryptscr.exe" -Destination "..\build\" -Force
Copy-Item ".\script.enc" -Destination "..\build\" -Force
Copy-Item ".\WKCISTOTO30001.scr" -Destination "..\build\" -Force
Copy-Item ".\WKCISTOTO30001.scr" -Destination "..\secscr\" -Force

Set-Location "..\secscr\"
dart pub get
dart compile exe .\bin\secscr.dart -o secscr.exe -S secscr.dbg
.\bin\secscr.exe --wks=WKCISTOTO30001 -s -x

Copy-Item ".\secscr.exe" -Destination "..\build\" -Force

Set-Location "..\"
