import 'dart:io';
import 'package:encryptjoin2/encryptjoin2.dart' as encryptjoin2;
import 'package:args/args.dart';

const wkey = 'wkey';
const upassword = 'psw';
const help = 'help';

void main(List<String> arguments) {
  exitCode = 0;

  final parser = ArgParser();
  parser.addFlag(
    help,
    negatable: false,
    abbr: 'h',
    callback: (p0) {
      if (p0) {
        print('''
encryptjoin2.exe -h oppure encryptjoin2.exe help genera questo help.

encryptjoin2.exe --psw password  -> genera 'encrypter_rsa.txt'

encryptjoin2.exe -wkey workstation (+ file encrypt_rsa.txt generato prima) -> genera 'encrypted_password.txt'
 da utilizzarsi con securejoin2.exe

encryptjoin2.exe --wkey workstatoin --psw password  genera entrambi i file 
''');
      }
    },
  );
  parser.addOption(wkey, mandatory: true, abbr: 'w');
  parser.addOption(upassword, mandatory: false, abbr: 'p');
/*
  String testoOriginale = "Questa è una password di amministrazione segreta";
  String chiaveSegreta = "WKCISTOTO30001";
*/
  print('Argomenti: $arguments \n');

  var results = parser.parse(arguments);

  /*
  String testoOriginale = results.option(upassword) ??
      "Questa è una password di amministrazione segreta";
  String chiaveSegreta = results.option(wkey) ?? "WKCISTOTO30001";
  */

  if (results.option(upassword) != null) {
    final password = results.option(upassword);
    // Carica la chiave pubblica

    final publicKey = encryptjoin2.decodePublicKey();
    //print('public: $publicKey \n');

    // Crittografa la password
    final passwordCrittografata =
        encryptjoin2.crittografaPassword(password!, publicKey);

    print('Password crittografata RSA: $passwordCrittografata');

    File('encrypted_rsa.txt').writeAsStringSync(passwordCrittografata);
  } else {
    print('''
Possibili opzioni:
--psw=password
--psw password
-ppassword
-p password
''');
  }
  if (results.option(wkey) != null) {
    final chiaveSegreta = results.option(wkey);

    final encryptedRSAPassword = File('encrypted_rsa.txt').readAsStringSync();

    print('Password crittografata RSA: $encryptedRSAPassword \n');

    // Crittografa il messaggio
    String testoCrittografato =
        encryptjoin2.crittografaAES(encryptedRSAPassword, chiaveSegreta!);
    print("Testo Crittografato AES: $testoCrittografato \n");
    File('encrypted_password.txt').writeAsStringSync(testoCrittografato);
    //-------------Decrypt Test--------------//
    final encryptedPassword = File('encrypted_password.txt').readAsStringSync();

    // Decritta con chiave AES
    String testoDecrittografato =
        encryptjoin2.decrittografaAES(encryptedPassword, chiaveSegreta);
    print("Testo Decrittografato AES: $testoDecrittografato");

    final privateKey = encryptjoin2.decodePrivateKey();
    //print('private: $privateKey \n');

    // Decrittografa la password
    final passwordDecrittografata =
        encryptjoin2.decrittografaPassword(testoDecrittografato, privateKey);
    print('Password decrittografata RSA: $passwordDecrittografata');
  } else {
    print('''
Possibili opzioni:
--wkey=workstationname
--wkey workstationname
-wworkstationname
-w workstationname
''');
  }
}
