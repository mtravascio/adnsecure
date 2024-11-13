import 'package:secscr/secscr.dart' as secscr;
import 'package:secscr/winapi.dart';
import 'dart:io';
import 'package:args/args.dart';
//import 'package:win32/win32.dart';

const help = 'help';
const wks = 'wks';
const show = 'show';
const exec = 'exec';
bool showscript = false;
bool execscript = false;

void main(List<String> arguments) async {
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
secscr.exe -h oppure help genera questo help.

secscr.exe [--wks|-w] workstation [--show|-x] | [--exec|-x] (file wks_scr.txt presente)
''');
      }
    },
  );
  parser.addOption(wks, mandatory: false, abbr: 'w');
  parser.addFlag(show, negatable: false, abbr: 's');
  parser.addFlag(exec, negatable: false, abbr: 'x');

  String chiaveSegreta = '';
  ArgResults results;

  try {
    results = parser.parse(arguments);
    chiaveSegreta = results.option(wks) ?? getComputerName();
    showscript = results.flag(show);
    execscript = results.flag(exec);
  } catch (e) {
    print('parametro sconosciuto! [-h|--help] per help\n');
  }
  //-------------Decrypt Test--------------//

  String encryptedScript = '';
  try {
    encryptedScript = File('wks_scr.txt').readAsStringSync();
  } catch (e) {
    print('wks_scr.txt non trovato!\n');
    exit(-1);
  }
  if (encryptedScript.isNotEmpty) {
    //print("File Crittato RSA+AES: $encryptedScript\n");
    // Decritta con chiave AES
    String scriptDecrittatoAES =
        secscr.decrittografaAES(encryptedScript, chiaveSegreta);
    //print("Testo Decrittato AES: $scriptDecrittatoAES\n");

    //var privateKey;
    try {
      var privateKey = secscr.decodePrivateKey();
      // Decrittografa la password
      final script = secscr.decrittografaRSA(scriptDecrittatoAES, privateKey);
      if (showscript) print('Show script decrittato:\n$script\n');
      if (execscript) {
        if (Platform.isLinux) {
          var result = await Process.run('bash', ['-c', script]);
          print('Output:\n${result.stdout}\n');
          print('Error:\n${result.stderr}\n');
        }

        if (Platform.isWindows) {
          var result = await Process.run('powershell.exe', ['-Command', script],
              runInShell: true);
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
  print('Check!');
}
