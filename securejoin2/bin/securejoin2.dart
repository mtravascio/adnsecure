import 'package:securejoin2/securejoin2.dart' as securejoin2;
import 'package:securejoin2/winapi.dart';
import 'dart:io';
import 'package:args/args.dart';
import 'package:win32/win32.dart';

const wkey = 'wkey';
const help = 'help';
const join = 'join';
bool joindomain = false;
const dn = 'usr.root.jus';
const un = 'UTENTI\\massimo.travascio';

int main(List<String> arguments) {
  int exitCode = 0;

  if (Platform.isWindows) print('Computer Name: ${getComputerName()}\n');

  print('Argomenti: $arguments \n');

  final parser = ArgParser();
  parser.addFlag(
    help,
    negatable: false,
    abbr: 'h',
    callback: (p0) {
      if (p0) {
        print('''
securejoin2.exe -h oppure securejoin2.exe help genera questo help.

securejoin2.exe --wkey workstation + file 'encrypted_password.txt' --join|--no-join

opzioni per 'wkey':
--wkey=workstation
--wkey workstation
-wworkstation
-w workstation
''');
      }
    },
  );
  parser.addOption(wkey, mandatory: true, abbr: 'w');
  parser.addFlag(join, abbr: 'j');

  String chiaveSegreta = '';
  String encryptedPassword = '';
  ArgResults results;

  try {
    results = parser.parse(arguments);
    chiaveSegreta = results.option(wkey) ?? getComputerName();
    joindomain = results.flag(join);
  } catch (e) {
    print('parametro sconosciuto! securejoin2.exe -h per help\n');
    exitCode = -1;
  }
  //-------------Decrypt Test--------------//
  if (chiaveSegreta.isNotEmpty) {
    try {
      encryptedPassword = File('encrypted_password.txt').readAsStringSync();
    } catch (e) {
      print('encrypted_password.txt non trovato!\n');
    }
    if (encryptedPassword.isNotEmpty) {
      print("File Crittato RSA+AES: $encryptedPassword\n");
      // Decritta con chiave AES
      String testoDecrittografato =
          securejoin2.decrittografaAES(encryptedPassword, chiaveSegreta);
      if (testoDecrittografato.isNotEmpty) {
        print("Testo Decrittato AES: $testoDecrittografato\n");

        final privateKey = securejoin2.decodePrivateKey();
        //print('private: $privateKey \n');

        // Decrittografa la password
        final passwordDecrittografata =
            securejoin2.decrittografaPassword(testoDecrittografato, privateKey);

        if (passwordDecrittografata.isNotEmpty) {
          print('Password Decrittata RSA: $passwordDecrittografata\n');

          if (Platform.isWindows && joindomain) {
            print('tenta il join\n');
            Process.run('powershell', [
              '-Command',
              'Add-Computer -DomainName "$dn" -Credential (New-Object System.Management.Automation.PSCredential("$un",(ConvertTo-SecureString "$passwordDecrittografata" -AsPlainText -Force)))'
            ]);
          }
        } else {
          print('encrypted_password.txt errato!\n');
        }
      } else {
        print('wkey errata o encrypted_password.txt errato!\n');
      }
    }
  } else {
    print('nop!');
    exitCode = -1;
  }
  return exitCode;
}
