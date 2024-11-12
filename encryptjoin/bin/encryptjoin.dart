import 'dart:io';
import 'package:encryptjoin/encryptjoin.dart' as encryptjoin;

void main() {
  String testoOriginale = "Questa è una password di amministrazione segreta";
  String chiaveSegreta = "WKCISTOTO30001";
/*
  final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';

  //final key = Key.fromSecureRandom(32);
  final key = Key.fromUtf8(
      'WKCISTOTO30001'.padRight(32)); //deve essere 256Bit per forza
  //final iv = IV.fromSecureRandom(16);
  final iv = IV.fromUtf8('3AveMaria');
  final encrypter = Encrypter(AES(key));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);

  print(decrypted);
  print(encrypted.bytes);
  print(encrypted.base16);
  print(encrypted.base64);
*/

  // Crittografa il messaggio
  String testoCrittografato =
      encryptjoin.crittografaAES(testoOriginale, chiaveSegreta);
  print("Testo Crittografato AES: $testoCrittografato");
  File('encrypted_aes.txt').writeAsStringSync(testoCrittografato);

  // Carica la chiave pubblica
  // Decodifica la chiave pubblica e la chiave privata
  final publicKey = encryptjoin.decodePublicKey();
  print('public: $publicKey \n');

  // Testo della password da crittografare
  final password = testoCrittografato;

  //final message = Uint8List.fromList('Messaggio segreto'.codeUnits);

  // Crittografia
  //final encryptedData = encryptWithPublicKey(publicKey, message);
  //print('Dati crittografati: $encryptedData');

  // Decrittografia
  //final decryptedData = decryptWithPrivateKey(privateKey, encryptedData);
  //print('Dati decrittografati: ${String.fromCharCodes(decryptedData)}');

  // Crittografa la password
  final passwordCrittografata =
      encryptjoin.crittografaPassword(password, publicKey);

  print('Password crittografata RSA: $passwordCrittografata');

  File('encrypted_password.txt').writeAsStringSync(passwordCrittografata);

//------------------------------------------//
  final privateKey = encryptjoin.decodePrivateKey();
  print('private: $privateKey \n');

  final encryptedPassword = File('encrypted_password.txt').readAsStringSync();
  // Decritta con chiave Privata

  // Decrittografa la password
  final passwordDecrittografata =
      encryptjoin.decrittografaPassword(encryptedPassword, privateKey);
  print('Password decrittografata RSA: $passwordDecrittografata');

  //testoCrittografato = File('encrypted_aes.txt').readAsStringSync();
  testoCrittografato = passwordDecrittografata;

  // Decrittografa il messaggio
  String testoDecrittografato =
      encryptjoin.decrittografaAES(testoCrittografato, chiaveSegreta);
  print("Testo Decrittografato: $testoDecrittografato");
}
