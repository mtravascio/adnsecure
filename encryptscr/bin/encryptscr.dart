import 'package:encryptscr/encryptscr.dart' as encryptscr;
import 'dart:io';
import 'package:args/args.dart';

const wks = 'wks';
const uscript = 'scr';
const test = 'test';
const help = 'help';
bool exec = false;

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
encryptscr.exe -h oppure encrypscr.exe help genera questo help.

encryptscr.exe --scr script.ps1  -> genera 'encrypted_scr.txt'

encryptscr.exe --wks workstation (+ file encrypted_scr.txt generato prima) -> genera 'wks_scr.txt'
 da utilizzarsi con secscr.exe

encryptscr.exe --wks workstatoin --scr script.ps1 genera entrambi i file 

flag -t o --test testa lo script in locale dopo il processo di crittazione e decrittazione

opzioni per 'wks':
--wks=workstation
--wks="workstation"
--wks workstation
-wworkstation
-w workstation

opzioni per 'scr':
--scr=script.ps1
--scr script.ps1
-sscript.ps1
-s script.ps1
''');
      }
    },
  );
  parser.addOption(wks, mandatory: false, abbr: 'w');
  parser.addOption(uscript, mandatory: true, abbr: 's');
  parser.addFlag(test, negatable: false, abbr: 't');

  String scriptFn = '';
  String chiaveSegreta = '';

  ArgResults results;
  try {
    results = parser.parse(arguments);
    scriptFn = results.option(uscript) ?? '';
    chiaveSegreta = results.option(wks) ?? '';
    exec = results.flag(test);
  } catch (e) {
    print('parametro sconosciuto! encryptjoin2.exe -h per help\n');
    exitCode = -1;
  }

  if (scriptFn.isNotEmpty) {
    try {
      String userScript = '';

      //legge lo script
      try {
        userScript = File(scriptFn).readAsStringSync();
      } catch (e) {
        print('Errore nel caricare $scriptFn\n');
      }

      // Carica la chiave pubblica
      final publicKey = encryptscr.decodePublicKey();
      //print('public: $publicKey \n');

      // Crittografa la password
      final userScriptRSA = encryptscr.crittografaRSA(userScript, publicKey);

      print('Script crittato e salvato RSA: $userScriptRSA\n');

      File('encrypted_scr.txt').writeAsStringSync(userScriptRSA);
    } catch (e) {
      print('Errore nella chiave di crittazione RSA!\n');
      exitCode = -1;
    }
  }
  if (chiaveSegreta.isNotEmpty) {
    String encryptedRSAscr = '';
    try {
      encryptedRSAscr = File('encrypted_scr.txt').readAsStringSync();
    } catch (e) {
      print('encrypted_scr.txt non trovato!\n');
    }
    if (encryptedRSAscr.isNotEmpty) {
      print('File Password RSA: $encryptedRSAscr\n');

      // Crittografa il messaggio
      String scriptCrittato =
          encryptscr.crittografaAES(encryptedRSAscr, chiaveSegreta);
      File('wks_scr.txt').writeAsStringSync(scriptCrittato);
    }
    //-------------Decrypt Test--------------//
    String encryptedScript = '';
    try {
      encryptedScript = File('wks_scr.txt').readAsStringSync();
    } catch (e) {
      print('wks_scr.txt non trovato!\n');
    }
    if (encryptedScript.isNotEmpty) {
      print("File Crittato RSA+AES: $encryptedScript\n");
      // Decritta con chiave AES
      String scriptDecrittatoAES =
          encryptscr.decrittografaAES(encryptedScript, chiaveSegreta);
      print("Testo Decrittato AES: $scriptDecrittatoAES\n");

      //var privateKey;
      try {
        var privateKey = encryptscr.decodePrivateKey();
        // Decrittografa la password
        final script =
            encryptscr.decrittografaRSA(scriptDecrittatoAES, privateKey);

        print('Script decrittato:\n$script\n');
        if (exec) {
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
        }
      } catch (e) {
        print('errore nella chiave di decrittazione RSA!\n');
        exitCode = -1;
      }
    }
  }
  //return exitCode;
}
