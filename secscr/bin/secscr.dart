import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:secscr/secscr.dart' as secscr;
//import 'package:secscr/winapi.dart';
import 'dart:io';
import 'package:args/args.dart';

const ver = '1.2';
const help = 'help';
const fileopt = 'file';
const show = 'show';
const exec = 'exec';
const urlopt = 'url';
bool showscript = false;
bool execscript = false;
String fileSCR = '';
String interpreter = '';

void main(List<String> arguments) async {
  //if (Platform.isWindows) print('Computer Name: ${getComputerName()}\n');

  print('hostname: ${Platform.localHostname}');

  print('Argomenti: $arguments \n');

  final parser = ArgParser();
  parser.addFlag(
    help,
    negatable: false,
    abbr: 'h',
    callback: (p0) {
      if (p0) {
        print('''
* Secure Script Exec v$ver' *
* Ministero della Giustizia - Cisia di Torino - 2024 *
Massimo Travascio (massimo.travascio@giustizia.it) 

secscr.exe [-h|--help] oppure help genera questo help.

secscr.exe [--f|--file] workstation.scr [--show|-s] | [--exec|-x] [-u|--url] http://localdomain:8080/workstation.scr
''');
        exit(0);
      }
    },
  );
  parser.addOption(fileopt, mandatory: false, abbr: 'f');
  parser.addOption(urlopt, mandatory: false, abbr: 'u');
  parser.addFlag(show, negatable: false, abbr: 's');
  parser.addFlag(exec, negatable: false, abbr: 'x');

  ArgResults results;

  try {
    results = parser.parse(arguments);
    fileSCR = results.option(fileopt) ?? '${Platform.localHostname}.scr';
    showscript = results.flag(show);
    execscript = results.flag(exec);
  } catch (e) {
    print('parametro sconosciuto! [-h|--help] per help\n');
  }
  //-------------Decrypt Test--------------//

  String encryptedScript = '';
  try {
    encryptedScript = File('$fileSCR').readAsStringSync();
  } catch (e) {
    print('$fileSCR non trovato!\n');
    exit(-1);
  }

  String workStation = fileSCR.split('.').first;

  if (encryptedScript.isNotEmpty) {
    //print("File Crittato RSA+AES: $encryptedScript\n");
    // Decritta con chiave AES
    String scriptDecrittatoAES =
        secscr.decrittografaAES(encryptedScript, workStation);
    print("Decoded Script: $scriptDecrittatoAES\n");

    //var privateKey;
    try {
      var privateKey = secscr.decodePrivateKey();

      // Legge il file enc in formato json
      //final data = File('script.enc').readAsStringSync();
      //final decData = jsonDecode(data);

      final decData = jsonDecode(scriptDecrittatoAES);

      final encKey = decData['k'];
      final encScript = decData['e'];
      final scriptFile = decData['n'];

      final AESKey = secscr.decrittografaRSA(encKey, privateKey);

      final randomKey = base64Decode(AESKey);
      //final script = encryptscr.decryptENC(scriptDecrittatoAES, Key(randomKey));
      final script = secscr.decryptENC(encScript, Key(randomKey));

      var lines = script.split('\n');

      String shebang = lines.first;

      if (shebang.startsWith('#!')) {
        if (shebang.contains('bash')) {
          interpreter = 'bash';
        }
        if (shebang.contains('python3')) {
          interpreter = 'python3';
        }
        if (shebang.contains('pwsh') || shebang.contains('powershell')) {
          if (Platform.isWindows) {
            interpreter = 'powershell.exe';
          }
          if (Platform.isLinux) {
            interpreter = 'pwsh';
          }
        }
      } else {
        interpreter = 'unknown!';
      }

      print('Script ($interpreter) $scriptFile Checked!\n');

      if (showscript) {
        print('Script ($interpreter) decrittato:\n$script\n');
      }
      if (execscript) {
        print('Eseguo Script ($interpreter):\n');
        if (Platform.isLinux) {
          var result = await Process.run('bash', ['-c', script]);
          print('Output:\n${result.stdout}\n');
          print('Error:\n${result.stderr}\n');
        }

        if (Platform.isWindows) {
          var result = await Process.run('powershell.exe', ['-Command', script],
              runInShell: false);
          print('Output:\n${result.stdout}\n');
          print('Error:\n${result.stderr}\n');
        }

        if (Platform.isMacOS) {
          var result = await Process.run('bash', ['-c', script]);
          print('Output:\n${result.stdout}\n');
          print('Error:\n${result.stderr}\n');
        }

        print('OK!');
        exit(0);
      }
    } catch (e) {
      print('Errore nella decrittazione!\n');
      exit(-1);
    }
  }
//  print('Check!');
}
