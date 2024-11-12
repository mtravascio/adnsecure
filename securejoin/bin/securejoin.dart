import 'dart:io';
import 'package:securejoin/securejoin.dart' as securejoin;
//import 'package:encrypt/encrypt.dart';

void main() {
  String chiaveSegreta = "WKCISTOTO30001";
  final testoCrittografato = File('encrypted_aes.txt').readAsStringSync();
  //Decritta con Chiave Privata RSA
  final privateKey = securejoin.decodePrivateKey();
  print('private: $privateKey \n');

  final encryptedPassword = File('encrypted_password.txt').readAsStringSync();

  // Decrittografa la password
  final passwordDecrittografata =
      securejoin.decrittografaPassword(encryptedPassword, privateKey);
  print('Password decrittografata RSA: $passwordDecrittografata');

  // Decrittografa il messaggio
  //String testoDecrittografato =
  //    securejoin.decrittografaAES(testoCrittografato, chiaveSegreta);
  String testoDecrittografato =
      securejoin.decrittografaAES(passwordDecrittografata, chiaveSegreta);

  print("Testo Decrittografato: $testoDecrittografato");
}
