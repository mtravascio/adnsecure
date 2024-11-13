import 'package:encryptscr/encryptscr.dart' as encryptscr;
import 'dart:io';
import 'package:args/args.dart';
import 'package:encryptscr/winapi.dart';

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

  print('Argomenti: $arguments \n');

  final parser = ArgParser();
  parser.addFlag(
    help,
    negatable: false,
    abbr: 'h',
    callback: (p0) {
      if (p0) {
        print('''
encryptscr.exe [-h|--help] genera questo help.

encryptscr.exe [--file|-f] 'script.ps1'|'script.sh'  -> 'script.enc'

encryptscr.exe [--wks|-w] workstation [-e|--enc] 'script.enc' ->  'workstation.scr'
 da utilizzarsi con secscr.exe 

encryptscr.exe [--wks|-w] workstation [-f|--file] 'script.ps1' -> 'script.enc' + 'workstation.scr' 

flag [-s|--show] mostra lo script in locale dopo il processo di crittazione e decrittazione

flag [-x|--exec] esegue lo script in locale dopo il processo di crittazione e decrittazione
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
  String scriptScr = '';

  ArgResults results;
  try {
    results = parser.parse(arguments);
    scriptFile = results.option(inputFile) ?? '';
    scriptEnc = results.option(encodedFile) ?? '';
    workStation = results.option(wks) ?? getComputerName();
    showscript = results.flag(show);
    execscript = results.flag(exec);
  } catch (e) {
    print('parametro sconosciuto! [-h|--help] per help\n');
    exitCode = -1;
  }

  if (scriptFile.isNotEmpty) {
    try {
      String userScript = '';

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

      print('Script crittato e salvato: $userScriptRSA\n');

      File(scriptFile.replaceAll(RegExp(r'\.[^.]+$'), '.enc'))
          .writeAsStringSync(userScriptRSA);
    } catch (e) {
      print('Errore nella chiave di crittazione!\n');
      exit(-1);
    }
  }
  if (workStation.isNotEmpty &&
      (scriptEnc.isNotEmpty || scriptFile.isNotEmpty)) {
    String encryptedRSAenc = '';

    if (scriptEnc.isNotEmpty) {
      try {
        encryptedRSAenc = File(scriptEnc).readAsStringSync();
      } catch (e) {
        print('$scriptEnc File non trovato!\n');
        exit(-1);
      }
    }

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

    if (encryptedRSAenc.isNotEmpty) {
      print('Encoded Script:\n$encryptedRSAenc\n');

      // Crittografa il AES los script
      String scriptCrittato =
          encryptscr.crittografaAES(encryptedRSAenc, workStation);
      File('$workStation.scr').writeAsStringSync(scriptCrittato);
    }
    //-------------Decrypt Test--------------//
    String encryptedScript = '';
    try {
      encryptedScript = File('$workStation.scr').readAsStringSync();
    } catch (e) {
      print('$workStation.scr non trovato!\n');
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

        if (showscript) {
          print('Script decrittato:\n$script\n');
        }
        if (execscript) {
          if (Platform.isLinux) {
            var result = await Process.run('bash', ['-c', script]);
            print('Output:\n${result.stdout}\n');
            print('Error:\n${result.stderr}\n');
          }

          if (Platform.isWindows) {
            var result = await Process.run(
                'powershell.exe', ['-Command', script],
                runInShell: true);
            print('Output:\n${result.stdout}\n');
            print('Error:\n${result.stderr}\n');
          }
          print('OK!');
          exit(0);
        }
      } catch (e) {
        print('errore nella chiave di decrittazione!\n');
        exit(-1);
      }
    }
  }
//  print('Check!');
}
