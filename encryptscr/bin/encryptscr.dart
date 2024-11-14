import 'package:encryptscr/encryptscr.dart' as encryptscr;
import 'dart:io';
import 'package:args/args.dart';
import 'package:encryptscr/winapi.dart';

const ver = '1.0';
const help = 'help';
const wks = 'wks';
const inputFile = 'file';
const encodedFile = 'enc';
const show = 'show';
const exec = 'exec';
bool showscript = false;
bool execscript = false;
String workStation = '';

void main(List<String> arguments) async {
  exitCode = 0;

  //print('Argomenti: $arguments \n');

  final parser = ArgParser();
  parser.addFlag(
    help,
    negatable: false,
    abbr: 'h',
    callback: (p0) {
      if (p0) {
        print('''
* Script Encoder Cisia Torino v$ver *

encryptscr.exe [-h|--help] genera questo help.

encryptscr.exe [--file|-f] 'script.ps1'|'script.sh'|'script.py'  -> genera 'script.enc'
encryptscr.exe [--wks|-w] workstation [-e|--enc] 'script.enc' -> genera 'workstation.scr' da usare con secscr.exe 
encryptscr.exe [--wks|-w] workstation [-f|--file] 'script.ps1' -> genera 'script.enc' e 'workstation.scr' 

encryptscr.exe [--wks|-w] workstation -> verifica 'workstation.scr'
encryptscr.exe [--wks|-w] workstation [-s|--show] -> mostra workstation.scr descrittato 
encryptscr.exe [--wks|-w] workstation [-x|--exec] -> !!!esegue workstation.scr locale!!!!
''');
      }
    },
  );
  parser.addOption(wks, mandatory: false, abbr: 'w');
  parser.addOption(inputFile, mandatory: false, abbr: 'f');
  parser.addOption(encodedFile, mandatory: true, abbr: 'e');
  parser.addFlag(show, negatable: false, abbr: 's');
  parser.addFlag(exec, negatable: false, abbr: 'x');

  String scriptFile = '';
  String scriptEnc = '';
  String interpreter = '';

  ArgResults results;
  try {
    results = parser.parse(arguments);
    scriptFile = results.option(inputFile) ?? '';
    scriptEnc = results.option(encodedFile) ?? '';
    workStation = results.option(wks) ?? getComputerName();
    showscript = results.flag(show);
    execscript = results.flag(exec);
  } catch (e) {
    print('encryptscr.exe [-h|--help] per help\n');
    exitCode = -1;
  }

  if (scriptFile.isNotEmpty) {
    try {
      String userScript = '';

      scriptEnc = scriptFile.replaceAll(RegExp(r'\.[^.]+$'), '.enc');

      //legge lo script
      try {
        userScript = File(scriptFile).readAsStringSync();
      } catch (e) {
        print('Errore nel caricare $scriptFile\n');
      }

      // Carica la chiave pubblica
      final publicKey = encryptscr.decodePublicKey();
      //print('public: $publicKey \n');

      // Crittografa la password
      final userScriptRSA = encryptscr.crittografaRSA(userScript, publicKey);

      print('$scriptEnc crittato e salvato: $userScriptRSA\n');

      File(scriptEnc).writeAsStringSync(userScriptRSA);
    } catch (e) {
      print('Errore nella chiave di crittazione!\n');
      exit(-1);
    }
  }
  if (workStation.isNotEmpty &&
      //(scriptEnc.isNotEmpty || scriptFile.isNotEmpty)) {
      scriptEnc.isNotEmpty) {
    String encryptedRSAenc = '';

    if (scriptEnc.isNotEmpty) {
      try {
        encryptedRSAenc = File(scriptEnc).readAsStringSync();
      } catch (e) {
        print('$scriptEnc File non trovato!\n');
        exit(-1);
      }
    }
/*
    if (scriptFile.isNotEmpty) {
      try {
        encryptedRSAenc =
            File(scriptFile.replaceAll(RegExp(r'\.[^.]+$'), '.enc'))
                .readAsStringSync();
      } catch (e) {
        print('$scriptFile Encoded non trovato!\n');
        exit(-1);
      }
    }
*/
    if (encryptedRSAenc.isNotEmpty) {
      print('Encoded $workStation.scr:\n$encryptedRSAenc\n');

      // Crittografa il AES los script
      String scriptCrittato =
          encryptscr.crittografaAES(encryptedRSAenc, workStation);
      File('$workStation.scr').writeAsStringSync(scriptCrittato);
    }
  }
  //-------------Decrypt Test--------------//
  String encryptedScript = '';
  if (workStation.isNotEmpty) {
    try {
      encryptedScript = File('$workStation.scr').readAsStringSync();
    } catch (e) {
      print('$workStation.scr non trovato!\n');
    }
  }
  if (encryptedScript.isNotEmpty) {
    //print("File Crittato RSA+AES: $encryptedScript\n");
    // Decritta con chiave AES
    String scriptDecrittatoAES =
        encryptscr.decrittografaAES(encryptedScript, workStation);
    //print("Testo Decrittato AES: $scriptDecrittatoAES\n");

    //var privateKey;
    try {
      var privateKey = encryptscr.decodePrivateKey();
      // Decrittografa la password
      final script =
          encryptscr.decrittografaRSA(scriptDecrittatoAES, privateKey);

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

      print('Script ($interpreter) Checked!\n');

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
              runInShell: true);
          print('Output:\n${result.stdout}\n');
          print('Error:\n${result.stderr}\n');
        }
        print('OK!');
        exit(0);
      }
    } catch (e) {
      print('Errore di decrittazione!\n');
      exit(-1);
    }
  }
//  print('Check!');
}
