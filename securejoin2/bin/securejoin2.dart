import 'package:securejoin2/securejoin2.dart' as securejoin2;
import 'dart:io';

//import 'package:encrypt/encrypt.dart';

void main() {
  String chiaveSegreta = "WKCISTOTO30001";
  String encryptedPassword = '';
  //-------------Decrypt Test--------------//
  try {
    encryptedPassword = File('encrypted_password.txt').readAsStringSync();
  } catch (e) {
    print('encrypted_password.txt non trovato!\n');
  }
  if (encryptedPassword.isNotEmpty) {
    print("Testo Crittografato AES: $encryptedPassword\n");
    // Decritta con chiave AES
    String testoDecrittografato =
        securejoin2.decrittografaAES(encryptedPassword, chiaveSegreta);
    if (testoDecrittografato.isNotEmpty) {
      print("Testo Decrittografato RSA: $testoDecrittografato\n");

      final privateKey = securejoin2.decodePrivateKey();
      //print('private: $privateKey \n');

      // Decrittografa la password
      final passwordDecrittografata =
          securejoin2.decrittografaPassword(testoDecrittografato, privateKey);

      if (passwordDecrittografata.isNotEmpty) {
        print('Password decrittografata RSA: $passwordDecrittografata\n');
      } else
        print('encrypted_password.txt errato!\n');
    } else
      print('wkey errata o encrypted_password.txt errato!\n');
  }
}
