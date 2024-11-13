#!/bin/bash

cd ./rsakey2dart
dart pub get
dart compile exe ./bin/rsakey2dart.dart
./bin/rsakey2dart.exe

cd ../encryptjoin2
dart pub get
dart compile exe ./bin/encryptjoin2.dart
./bin/encryptjoin2.exe --wkey=WKCISTOTO30001 --psw=Password01

cp ./encrypted_password.txt ../securejoin2/encrypted_password.txt

cd ../securejoin2/
dart pub get
dart compile exe ./bin/securejoin2.dart
./bin/securejoin2.exe --wkey=WKCISTOTO30001

cd ../encryptscr/
dart pub get
dart compile exe ./bin/encryptscr.dart
./bin/encryptscr.exe --wks=WKCISTOTO30001 --file="./script.sh" -s -x

cp ./WKCISTOTO30001.scr ../secscr/WKCISTOTO30001.scr

cd ../secscr/
dart pub get
dart compile exe ./bin/secscr.dart
./bin/secscr.exe --wks=WKCISTOTO30001 -s -x

cd ../






