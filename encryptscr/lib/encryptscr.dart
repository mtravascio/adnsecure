import 'package:encrypt/encrypt.dart';
import 'package:asn1lib/asn1lib.dart' as asn1lib;
import 'package:pointycastle/export.dart';
import 'dart:typed_data';
import 'public_key.dart';
import 'private_key.dart';

const ENC = 'vSSvPM';
const SCR = '3AM@ive';

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
String crittografaRSA(String password, RSAPublicKey chiavePubblica) {
  final encrypter =
      Encrypter(RSA(publicKey: chiavePubblica, encoding: RSAEncoding.PKCS1));
  var encrypted;
  try {
    encrypted = encrypter.encrypt(password);
  } catch (e) {
    //print('Errore RSA Encription!');
  }
  return encrypted.base64; // Ritorna il testo crittografato in Base64
}

/// Decrittografa il testo usando la chiave privata
String decrittografaRSA(String encryptedPassword, RSAPrivateKey chiavePrivata) {
  final encrypter =
      Encrypter(RSA(privateKey: chiavePrivata, encoding: RSAEncoding.PKCS1));
  String decrypted = '';
  try {
    decrypted = encrypter.decrypt(Encrypted.from64(encryptedPassword));
  } catch (e) {
    //print('Errore RSA Decription!');
  }
  return decrypted;
}

// Crittografa una un testo con AES Key casuale!
String cryptENC(String plainText, Key enckey) {
  //final chiave =
  //    Key.fromUtf8(key.padRight(32)); // Chiave a 256-bit (32 caratteri)
  //final key = Key.fromUtf8(chiave.padRight(32)); //deve essere 256Bit per forza
  //print('chiave AES da key');
  //final key = Key.fromLength(32); //deve essere 256Bit per forza
  //final iv = IV.fromSecureRandom(16);
  //final iv = IV.fromLength(16);
  final iv = IV.fromUtf8(ENC.padRight(16)); // IV a 128-bit

  final encrypter = Encrypter(AES(enckey));
  var encrypted;
  try {
    encrypted = encrypter.encrypt(plainText, iv: iv);
  } catch (e) {
    print('Errore ENC Encryption!');
  }

//final decrypted = encrypter.decrypt(encrypted, iv: iv);
//  print(decrypted);
//  print(encrypted.bytes);
//  print(encrypted.base16);
//  print(encrypted.base64);

  return encrypted.base64; // Ritorna il testo crittografato in Base64
}

// Crittografa una stringa con AES
String crittografaAES(String plainText, String chiave) {
  //final chiave =
  //    Key.fromUtf8(key.padRight(32)); // Chiave a 256-bit (32 caratteri)
  final key = Key.fromUtf8(chiave.padRight(32)); //deve essere 256Bit per forza
  //final key = Key.fromLength(32); //deve essere 256Bit per forza
  //final iv = IV.fromSecureRandom(16);
  //final iv = IV.fromLength(16);
  final iv = IV.fromUtf8(SCR.padRight(16)); // IV a 128-bit

  final encrypter = Encrypter(AES(key));
  var encrypted;
  try {
    encrypted = encrypter.encrypt(plainText, iv: iv);
  } catch (e) {
    print('Errore SCR Encryption!');
  }

//final decrypted = encrypter.decrypt(encrypted, iv: iv);
//  print(decrypted);
//  print(encrypted.bytes);
//  print(encrypted.base16);
//  print(encrypted.base64);

  return encrypted.base64; // Ritorna il testo crittografato in Base64
}

// Decrittografa una stringa crittografata in Base64 con AES
String decryptENC(String encryptedText, Key deckey) {
  //print('chiave AES da key');
  //final chiave =
  //    Key.fromUtf8(key.padRight(32)); // Chiave a 256-bit (32 caratteri)
  //final key = Key.fromUtf8(chiave.padRight(32)); //deve essere 256Bit per forza
  //final iv = IV.fromSecureRandom(16);
  //final iv = IV.fromLength(16);
  final iv = IV.fromUtf8(ENC.padRight(16)); // IV a 128-bit

  final encrypter = Encrypter(AES(deckey));
  String decrypted = '';
  try {
    decrypted = encrypter.decrypt64(encryptedText, iv: iv);
  } catch (e) {
    print('Errore ENC Decryption!');
  }
  return decrypted; // Ritorna il testo decrittografato
}

// Decrittografa una stringa crittografata in Base64 con AES
String decrittografaAES(String encryptedText, String chiave) {
  //final chiave =
  //    Key.fromUtf8(key.padRight(32)); // Chiave a 256-bit (32 caratteri)
  final key = Key.fromUtf8(chiave.padRight(32)); //deve essere 256Bit per forza
  //final iv = IV.fromSecureRandom(16);
  //final iv = IV.fromLength(16);
  final iv = IV.fromUtf8(SCR.padRight(16)); // IV a 128-bit

  final encrypter = Encrypter(AES(key));
  String decrypted = '';
  try {
    decrypted = encrypter.decrypt64(encryptedText, iv: iv);
  } catch (e) {
    print('Errore SCR Decryption!');
  }
  return decrypted; // Ritorna il testo decrittografato
}
