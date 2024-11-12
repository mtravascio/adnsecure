import 'dart:io';
import 'package:encryptjoin2/encryptjoin2.dart' as encryptjoin2;
import 'package:args/args.dart';

const wkey = 'wkey';
const upassword = 'psw';
const help = 'help';

int main(List<String> arguments) {
  exitCode = 0;

  print('Argomenti: $arguments \n');

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

encryptjoin2.exe --wkey workstation (+ file encrypt_rsa.txt generato prima) -> genera 'encrypted_password.txt'
 da utilizzarsi con securejoin2.exe

encryptjoin2.exe --wkey workstatoin --psw password  genera entrambi i file 

opzioni per 'wkey':
--wkey=workstation
--wkey workstation
-wworkstation
-w workstation

opzioni per 'psw':
--psw=password
--psw password
-ppassword
-p password
''');
      }
    },
  );
  parser.addOption(wkey, mandatory: true, abbr: 'w');
  parser.addOption(upassword, mandatory: false, abbr: 'p');

  String password = '';
  String chiaveSegreta = '';

  ArgResults results;
  try {
    results = parser.parse(arguments);
    password = results.option(upassword) ?? '';
    chiaveSegreta = results.option(wkey) ?? '';
  } catch (e) {
    print('parametro sconosciuto! encryptjoin2.exe -h per help\n');
    exitCode = -1;
  }

  if (password.isNotEmpty) {
    try {
      // Carica la chiave pubblica
      final publicKey = encryptjoin2.decodePublicKey();
      //print('public: $publicKey \n');

      // Crittografa la password
      final passwordCrittografata =
          encryptjoin2.crittografaPassword(password, publicKey);

      print('Password crittata e salvata RSA: $passwordCrittografata\n');

      File('encrypted_rsa.txt').writeAsStringSync(passwordCrittografata);
    } catch (e) {
      print('Errore nella chiave di crittazione RSA!\n');
      exitCode = -1;
    }
  }
  if (chiaveSegreta.isNotEmpty) {
    String encryptedRSAPassword = '';
    try {
      encryptedRSAPassword = File('encrypted_rsa.txt').readAsStringSync();
    } catch (e) {
      print('encrypted_rsa.txt non trovato!\n');
    }
    if (encryptedRSAPassword.isNotEmpty) {
      print('File Password RSA: $encryptedRSAPassword\n');

      // Crittografa il messaggio
      String testoCrittografato =
          encryptjoin2.crittografaAES(encryptedRSAPassword, chiaveSegreta);
      //print("WRITE - Testo Crittografato AES: $testoCrittografato \n");
      File('encrypted_password.txt').writeAsStringSync(testoCrittografato);
    }
    //-------------Decrypt Test--------------//
    String encryptedPassword = '';
    try {
      encryptedPassword = File('encrypted_password.txt').readAsStringSync();
    } catch (e) {
      print('encrypted_password.txt non trovato!\n');
    }
    if (encryptedPassword.isNotEmpty) {
      print("File Crittato RSA+AES: $encryptedPassword\n");
      // Decritta con chiave AES
      String testoDecrittografato =
          encryptjoin2.decrittografaAES(encryptedPassword, chiaveSegreta);
      print("Testo Decrittato AES: $testoDecrittografato\n");

      var privateKey;
      try {
        privateKey = encryptjoin2.decodePrivateKey();
        // Decrittografa la password
        final passwordDecrittografata = encryptjoin2.decrittografaPassword(
            testoDecrittografato, privateKey);
        print('Password decrittata RSA: $passwordDecrittografata');
      } catch (e) {
        print('errore nella chiave di decrittazione RSA!');
        exitCode = -1;
      }
    }
  }
  return exitCode;
}
