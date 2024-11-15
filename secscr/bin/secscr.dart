import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:secscr/secscr.dart' as secscr;
//import 'package:secscr/winapi.dart';
import 'dart:io';
import 'package:args/args.dart';
import 'package:http/http.dart' as http;

const ver = '1.3';
const help = 'help';
const fileopt = 'file';
//const show = 'show';
const exec = 'exec';
const urlopt = 'url';
const force = 'force';
//bool showscript = false;
bool execscript = false;
bool forcescript = false;
String fileSCR = '';
String urlSCR = '';
String interpreter = '';

void main(List<String> arguments) async {
  //if (Platform.isWindows) print('Computer Name: ${getComputerName()}\n');

  //print('hostname: ${Platform.localHostname}');

  print('Parametri: $arguments\n');

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

secscr.exe [--f|--file] scriptname.scr [-u|--url] http://HOST:PORT/scriptname.scr [--exec|-x]
''');
        exit(0);
      }
    },
  );
  parser.addOption(fileopt, mandatory: false, abbr: 'f');
  parser.addOption(urlopt, mandatory: false, abbr: 'u');
  parser.addFlag(exec, negatable: false, abbr: 'x');
  //parser.addFlag(show, negatable: false);
  parser.addFlag(force, negatable: false);

  ArgResults results;

  try {
    results = parser.parse(arguments);
    fileSCR = results.option(fileopt) ?? '';
    urlSCR = results.option(urlopt) ?? '';
// 'http://localhost:8080/${Platform.localHostname}.scr';
    //showscript = results.flag(show);
    execscript = results.flag(exec);
    forcescript = results.flag(force);
  } catch (e) {
    print('parametro sconosciuto! [-h|--help] per help\n');
  }
  //-------------Decrypt Test--------------//

  String encryptedScript = '';
  if (urlSCR.isEmpty) {
    if (fileSCR.isEmpty) {
      fileSCR = '${Platform.localHostname}.scr';
    }
    try {
      encryptedScript = File(fileSCR).readAsStringSync();
    } catch (e) {
      print('File $fileSCR non trovato!\n');
      exit(-1);
    }
    //scarica da url il file scr
  } else {
    print('Download $urlSCR\n');

    fileSCR = Uri.parse(urlSCR).pathSegments.last;

    final response;
    try {
      response = await http.get(Uri.parse(urlSCR));
    } catch (e) {
      print("Errore di connessione!\n");
      exit(-1);
    }

    if (response.statusCode != 200) {
      print('Errore nel download: ${response.statusCode}');
      print('$fileSCR non trovato!\n');
      exit(-1);
    }
    encryptedScript = response.body;

    print('Downloaded $fileSCR:\n$encryptedScript\n');
  }

  String workStation = '';
  //Qui per decodificare ed eseguire tutti gli script
  if (forcescript) {
    workStation = fileSCR.split('.').first;
  } else {
    //Qui ped decoficare solo gli script destinati allla Workstation locale;
    workStation = Platform.localHostname;
  }

  if (encryptedScript.isNotEmpty) {
    //print("File Crittato RSA+AES: $encryptedScript\n");
    // Decritta con chiave AES
    String scriptDecrittatoAES =
        secscr.decrittografaAES(encryptedScript, workStation);

    //Stampa lo script decodificato
    //print("Decoded Script: $scriptDecrittatoAES\n");

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

      /*
      if (showscript) {
        print('Script ($interpreter) decrittato:\n$script\n');
      }
      */
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
