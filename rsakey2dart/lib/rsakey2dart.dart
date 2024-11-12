import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart';

/// Funzione principale per generare le chiavi e salvarle nei file .dart

SecureRandom getSecureRandom() {
  var secureRandom = FortunaRandom();
  var random = Random.secure();
  List<int> seeds = [];
  for (int i = 0; i < 32; i++) {
    seeds.add(random.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  return secureRandom;
}

/// Genera una coppia di chiavi RSA con una dimensione di 2048 bit che non cambia
/*
AsymmetricKeyPair<PublicKey, PrivateKey> generateRSAKeyPair() {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
      SecureRandom('Fortuna')..seed(KeyParameter(Uint8List(32))),
    ));
  return keyGen.generateKeyPair();
}
*/
/// Genera una coppia di chiavi RSA con una dimensione di 2048 bit che cambia sempre
AsymmetricKeyPair<PublicKey, PrivateKey> generateRSAKeyPair() {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
      SecureRandom('Fortuna')
        ..seed(KeyParameter(
            Uint8List(32))), //che non cambia (inizializzata da ZERI)
      //getSecureRandom(),  //che cambia con inizializzazione random
    ));
  return keyGen.generateKeyPair();
}

/// Codifica una chiave pubblica RSA in formato DER
Uint8List encodeRSAPublicKeyToDER(RSAPublicKey publicKey) {
  final asn1Sequence = ASN1Sequence()
    ..add(ASN1Integer(publicKey.modulus!))
    ..add(ASN1Integer(publicKey.exponent!));
  return Uint8List.fromList(asn1Sequence.encodedBytes);
}

/// Codifica una chiave privata RSA in formato DER
Uint8List encodeRSAPrivateKeyToDER(RSAPrivateKey privateKey) {
  final asn1Sequence = ASN1Sequence()
    ..add(ASN1Integer(BigInt.from(0))) // Versione
    ..add(ASN1Integer(privateKey.modulus!))
    ..add(ASN1Integer(privateKey.publicExponent!))
    ..add(ASN1Integer(privateKey.privateExponent!))
    ..add(ASN1Integer(privateKey.p!))
    ..add(ASN1Integer(privateKey.q!))
    ..add(ASN1Integer(privateKey.privateExponent! %
        (privateKey.p! - BigInt.one))) // d mod (p-1)
    ..add(ASN1Integer(privateKey.privateExponent! %
        (privateKey.q! - BigInt.one))) // d mod (q-1)
    ..add(ASN1Integer(
        privateKey.q!.modInverse(privateKey.p!))); // Coefficiente CRT
  return Uint8List.fromList(asn1Sequence.encodedBytes);
}

/// Salva l'array di byte della chiave in un file Dart
void saveKeyToDartFile(Uint8List bytes, String arrayName, String fileName) {
  final buffer = StringBuffer();
  buffer.writeln(
      '// Questo file contiene la chiave in formato binario come array di byte.');
  buffer.writeln('final $arrayName = <int>[');

  for (int i = 0; i < bytes.length; i++) {
    buffer.write('0x${bytes[i].toRadixString(16).padLeft(2, '0')}, ');
    if ((i + 1) % 12 == 0)
      buffer
          .writeln(); // Migliora la leggibilità con una nuova riga ogni 12 byte
  }

  buffer.writeln('];');

  final file = File(fileName);
  file.writeAsStringSync(buffer.toString());

  print('Array $arrayName salvato nel file $fileName.');
}
