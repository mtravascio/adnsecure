import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:encryptscr/encryptscr.dart' as encryptscr;
import 'dart:io';
import 'package:args/args.dart';
import 'package:encryptscr/winapi.dart';

const ver = '1.2';
const help = 'help';
const wks = 'wks';
const inputFile = 'file';
const url = 'url';
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
* Secure Script Encoder - v$ver *
* Ministero della Giustizia - Cisia di Torino - 2024 *
Massimo Travascio (massimo.travascio@giustizia.it) 

encryptscr.exe [-h|--help] genera questo help.

encryptscr.exe [--wks|-w] workstation [--file|-f] 'script.ps1'|'script.sh'|'script.py'  -> genera 'workstation.scr' da usare con secscr.exe 
encryptscr.exe [--wks|-w] workstation -> verifica il file 'workstation.scr'
encryptscr.exe [--wks|-w] workstation [-s|--show] -> mostra workstation.scr descrittato 
encryptscr.exe [--wks|-w] workstation [-x|--exec] -> !!!esegue workstation.scr locale!!!!
''');
        exit(0);
      }
    },
  );
  parser.addOption(wks, mandatory: true, abbr: 'w');
  parser.addOption(inputFile, mandatory: false, abbr: 'f');
  parser.addOption(url, mandatory: false, abbr: 'u');
  parser.addFlag(show, negatable: false, abbr: 's');
  parser.addFlag(exec, negatable: false, abbr: 'x');

  String scriptFile = '';
  String urlFile = '';
  String interpreter = '';

  ArgResults results;
  try {
    results = parser.parse(arguments);
    scriptFile = results.option(inputFile) ?? '';
    urlFile = results.option(url) ?? '';
    workStation = results.option(wks) ?? getComputerName();
    showscript = results.flag(show);
    execscript = results.flag(exec);
  } catch (e) {
    print('encryptscr.exe [-h|--help] per help\n');
    exitCode = -1;
  }

  if (workStation.isNotEmpty && scriptFile.isNotEmpty) {
    try {
      String userScript = '';

      //scriptEnc = scriptFile.replaceAll(RegExp(r'\.[^.]+$'), '.enc');

      //legge lo script
      try {
        userScript = File(scriptFile).readAsStringSync();
      } catch (e) {
        print('Errore nel caricare $scriptFile\n');
      }

      // Carica la chiave pubblica
      final publicKey = encryptscr.decodePublicKey();
      //print('public: $publicKey \n');
      Key randomAESKey = Key.fromLength(32);

      print('\nRandom AES KEY:\n${randomAESKey.base64}\n');

      // Crittografa lo script con AES e chiave Random
      final encScript = encryptscr.cryptENC(userScript, randomAESKey);

      // Crittografa la chiave Random AES con RSA
      final encKey = encryptscr.crittografaRSA(randomAESKey.base64, publicKey);

      print('\nEncoded $scriptFile:\n$encScript\n');

      print('RSA key.txt:\n$encKey\n');

      final data = jsonEncode({'n': scriptFile, 'e': encScript, 'k': encKey});

      //scrive il file script.enc
      //File('data.enc').writeAsStringSync(data);

      //File(scriptEnc).writeAsStringSync(encScript);
      //File('key.txt').writeAsStringSync(encKey);

      if (data.isNotEmpty) {
        // Crittografa il AES in workstation.scr
        String scriptCrittato = encryptscr.crittografaAES(data, workStation);
        File('$workStation.scr').writeAsStringSync(scriptCrittato);

        print('\nEncoded $workStation.scr:\n$scriptCrittato\n');
      }
    } catch (e) {
      print('Errore nella chiave di crittazione!\n');
      exit(-1);
    }
  }
  if (workStation.isNotEmpty) {
    String encryptedSCR = '';

    try {
      encryptedSCR = File('$workStation.scr').readAsStringSync();
    } catch (e) {
      print('File $workStation.scr non trovato!\n');
      exit(-1);
    }

    if (encryptedSCR.isNotEmpty) {
      // Verifica lo script AES
      print('\nCheck $workStation.scr:\n');
      final res = encryptscr.decrittografaAES(encryptedSCR, workStation);
      if (res.isNotEmpty) {
        print('OK!');
      } else {
        print('Error!');
        exit(-1);
      }
    }
  }
  //-------------Decrypt Test--------------//
  String encryptedScript = '';
  if (workStation.isNotEmpty && (execscript || showscript)) {
    try {
      encryptedScript = File('$workStation.scr').readAsStringSync();
      print("\nRead $workStation.scr:\n$encryptedScript\n");
    } catch (e) {
      print('$workStation.scr non trovato!\n');
    }
  }
  //print('inizia la decodifica\n');
  if (encryptedScript.isNotEmpty) {
    //print("File Crittato RSA+AES: $encryptedScript\n");
    // Decritta il file json con chiave AES
    String scriptDecrittatoAES =
        encryptscr.decrittografaAES(encryptedScript, workStation);
    print("\nDecoded Script:\n$scriptDecrittatoAES\n");

    //var privateKey;
    try {
      var privateKey = encryptscr.decodePrivateKey();
      // Decrittografa la password
      // Legge il file enc in formato json
      //final data = File('script.enc').readAsStringSync();
      //final decData = jsonDecode(data);

      final decData = jsonDecode(scriptDecrittatoAES);

      final encKey = decData['k'];
      final encScript = decData['e'];
      final scriptFile = decData['n'];

      //final encKey = File('key.txt').readAsStringSync();
      final AESKey = encryptscr.decrittografaRSA(encKey, privateKey);

      final randomKey = base64Decode(AESKey);
      //final script = encryptscr.decryptENC(scriptDecrittatoAES, Key(randomKey));
      final script = encryptscr.decryptENC(encScript, Key(randomKey));

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
        print('Show Script ($interpreter):\n$script\n');
      }

      if (execscript) {
        print('Execute Script ($interpreter):\n');
        if (Platform.isLinux) {
          var result = await Process.run('bash', ['-c', script]);
          print('Output:\n${result.stdout}\n');
          print('Error:\n${result.stderr}\n');
        }
        //runInShell: false perp poter visualizzare i messaggi di output e di errore!
        //in secscr potrebbe essere true!
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
      print('Errore di decrittazione!\n');
      exit(-1);
    }
  }
//  print('Check!');
}
