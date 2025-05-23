import 'package:encrypt/encrypt.dart';
import 'package:asn1lib/asn1lib.dart' as asn1lib;
import 'package:pointycastle/export.dart';
import 'dart:typed_data';
import 'public_key.dart';
import 'private_key.dart';

/// Decodifica i byte della chiave pubblica in un oggetto RSAPublicKey
RSAPublicKey decodePublicKey() {
  final asn1Parser = asn1lib.ASN1Parser(Uint8List.fromList(publicKeyBytes));
  final topLevelSeq = asn1Parser.nextObject() as asn1lib.ASN1Sequence;
  final modulus =
      (topLevelSeq.elements![0] as asn1lib.ASN1Integer).valueAsBigInteger;
  final exponent =
      (topLevelSeq.elements![1] as asn1lib.ASN1Integer).valueAsBigInteger;
  return RSAPublicKey(modulus!, exponent!);
}

/// Decodifica i byte della chiave privata in un oggetto RSAPrivateKey
RSAPrivateKey decodePrivateKey() {
  final asn1Parser = asn1lib.ASN1Parser(Uint8List.fromList(privateKeyBytes));
  final topLevelSeq = asn1Parser.nextObject() as asn1lib.ASN1Sequence;
  final modulus =
      (topLevelSeq.elements![1] as asn1lib.ASN1Integer).valueAsBigInteger;
  final privateExponent =
      (topLevelSeq.elements![3] as asn1lib.ASN1Integer).valueAsBigInteger;
  final p = (topLevelSeq.elements![4] as asn1lib.ASN1Integer).valueAsBigInteger;
  final q = (topLevelSeq.elements![5] as asn1lib.ASN1Integer).valueAsBigInteger;
  return RSAPrivateKey(modulus!, privateExponent!, p, q);
}

/*
/// Funzione per crittografare i dati con la chiave pubblica
Uint8List encryptWithPublicKey(RSAPublicKey publicKey, Uint8List data) {
  final encryptor = RSAEngine()
    ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
  return encryptor.process(data);
}

/// Funzione per decrittografare i dati con la chiave privata
Uint8List decryptWithPrivateKey(
    RSAPrivateKey privateKey, Uint8List encryptedData) {
  final decryptor = RSAEngine()
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
  return decryptor.process(encryptedData);
}
*/

/// Crittografa il testo usando la chiave pubblica
String crittografaPassword(String password, RSAPublicKey chiavePubblica) {
  final encrypter =
      Encrypter(RSA(publicKey: chiavePubblica, encoding: RSAEncoding.PKCS1));
  final encrypted = encrypter.encrypt(password);
  return encrypted.base64; // Ritorna il testo crittografato in Base64
}

/// Decrittografa il testo usando la chiave privata
String decrittografaPassword(
    String encryptedPassword, RSAPrivateKey chiavePrivata) {
  final encrypter =
      Encrypter(RSA(privateKey: chiavePrivata, encoding: RSAEncoding.PKCS1));
  final decrypted = encrypter.decrypt(Encrypted.from64(encryptedPassword));
  return decrypted;
}

/// Crittografa una stringa con AES
String crittografaAES(String plainText, String chiave) {
  //final chiave =
  //    Key.fromUtf8(key.padRight(32)); // Chiave a 256-bit (32 caratteri)
  final key = Key.fromUtf8(chiave.padRight(32)); //deve essere 256Bit per forza
  //final iv = IV.fromSecureRandom(16);
  final iv = IV.fromUtf8('3AveMaria'.padRight(16)); // IV a 128-bit

  final encrypter = Encrypter(AES(key));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
//final decrypted = encrypter.decrypt(encrypted, iv: iv);
//  print(decrypted);
//  print(encrypted.bytes);
//  print(encrypted.base16);
//  print(encrypted.base64);

  return encrypted.base64; // Ritorna il testo crittografato in Base64
}

/// Decrittografa una stringa crittografata in Base64 con AES
String decrittografaAES(String encryptedText, String chiave) {
  //final chiave =
  //    Key.fromUtf8(key.padRight(32)); // Chiave a 256-bit (32 caratteri)
  final key = Key.fromUtf8(chiave.padRight(32)); //deve essere 256Bit per forza
  //final iv = IV.fromSecureRandom(16);
  final iv = IV.fromUtf8('3AveMaria'.padRight(16)); // IV a 128-bit

  final encrypter = Encrypter(AES(key));

  final decrypted = encrypter.decrypt64(encryptedText, iv: iv);

  return decrypted; // Ritorna il testo decrittografato
}
