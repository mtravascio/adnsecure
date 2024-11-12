import 'package:encrypt/encrypt.dart';
import 'package:asn1lib/asn1lib.dart' as asn1lib;
import 'package:pointycastle/export.dart';
import 'dart:typed_data';
import 'private_key.dart';

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

/// Decrittografa il testo usando la chiave privata
String decrittografaPassword(
    String encryptedPassword, RSAPrivateKey chiavePrivata) {
  final encrypter =
      Encrypter(RSA(privateKey: chiavePrivata, encoding: RSAEncoding.PKCS1));
  String decrypted = '';
  try {
    decrypted = encrypter.decrypt(Encrypted.from64(encryptedPassword));
  } catch (e) {
    //print('Errore RSA!');
  }
  return decrypted;
}

/// Decrittografa una stringa crittografata in Base64 con AES
String decrittografaAES(String encryptedText, String chiave) {
  //final chiave =
  //    Key.fromUtf8(key.padRight(32)); // Chiave a 256-bit (32 caratteri)
  final key = Key.fromUtf8(chiave.padRight(32)); //deve essere 256Bit per forza
  //final iv = IV.fromSecureRandom(16);
  final iv = IV.fromUtf8('3AveMaria'.padRight(16)); // IV a 128-bit

  final encrypter = Encrypter(AES(key));
  String decrypted = '';
  try {
    decrypted = encrypter.decrypt64(encryptedText, iv: iv);
  } catch (e) {
    //print('Errore AES!');
  }
  return decrypted; // Ritorna il testo decrittografato
}
