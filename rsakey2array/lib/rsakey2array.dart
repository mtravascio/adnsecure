import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart';

/// Genera una coppia di chiavi RSA con una dimensione di 2048 bit
AsymmetricKeyPair<PublicKey, PrivateKey> generateRSAKeyPair() {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
      SecureRandom('Fortuna')..seed(KeyParameter(Uint8List(32))),
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

/// Stampa un array di byte in formato Dart
void printByteArray(Uint8List bytes, String arrayName) {
  final buffer = StringBuffer();
  buffer.writeln('final $arrayName = <int>[');
  for (int i = 0; i < bytes.length; i++) {
    buffer.write('0x${bytes[i].toRadixString(16).padLeft(2, '0')}, ');
    if ((i + 1) % 12 == 0) buffer.writeln();
  }
  buffer.writeln('];');
  print(buffer.toString());
}
