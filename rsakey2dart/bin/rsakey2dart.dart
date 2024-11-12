import 'package:rsakey2dart/rsakey2dart.dart' as rsakey2dart;
import 'package:pointycastle/export.dart';

void main() {
  // Genera la coppia di chiavi RSA
  final keyPair = rsakey2dart.generateRSAKeyPair();

  // Codifica la chiave pubblica e privata in DER
  final privateKeyBytes =
      rsakey2dart.encodeRSAPrivateKeyToDER(keyPair.privateKey as RSAPrivateKey);
  final publicKeyBytes =
      rsakey2dart.encodeRSAPublicKeyToDER(keyPair.publicKey as RSAPublicKey);

  // Salva le chiavi come array di byte in file separati

//EncryptJoin dir
  rsakey2dart.saveKeyToDartFile(
      publicKeyBytes, 'publicKeyBytes', '../encryptjoin/lib/public_key.dart');
  rsakey2dart.saveKeyToDartFile(privateKeyBytes, 'privateKeyBytes',
      '../encryptjoin/lib/private_key.dart');

//SecureJoin dir
  rsakey2dart.saveKeyToDartFile(
      privateKeyBytes, 'privateKeyBytes', '../securejoin/lib/private_key.dart');

  print(
      'Chiavi generate e salvate nei file public_key.dart e private_key.dart.');
}
