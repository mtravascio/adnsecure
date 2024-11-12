import 'package:rsakey2array/rsakey2array.dart' as rsakey2array;
import 'package:pointycastle/export.dart';

/// Genera una coppia di chiavi RSA (pubblica e privata) e le converte in array di byte.
void main() {
  // Genera la coppia di chiavi RSA
  final keyPair = rsakey2array.generateRSAKeyPair();

  // Codifica la chiave privata e pubblica in DER
  final privateKeyBytes = rsakey2array
      .encodeRSAPrivateKeyToDER(keyPair.privateKey as RSAPrivateKey);
  final publicKeyBytes =
      rsakey2array.encodeRSAPublicKeyToDER(keyPair.publicKey as RSAPublicKey);

  // Stampa gli array di byte in formato Dart
  rsakey2array.printByteArray(publicKeyBytes, 'publicKeyBytes');
  rsakey2array.printByteArray(privateKeyBytes, 'privateKeyBytes');
}
