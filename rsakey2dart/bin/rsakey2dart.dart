import 'package:rsakey2dart/rsakey2dart.dart' as rsakey2dart;
import 'package:pointycastle/export.dart';

const ENCRYPTJOINPATH = '../encryptjoin/lib/';
const SECUREJOINPATH = '../securejoin/lib/';
const ENCRYPTJOIN2PATH = '../encryptjoin2/lib/';
const SECUREJOIN2PATH = '../securejoin2/lib/';

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
/*  rsakey2dart.saveKeyToDartFile(
      publicKeyBytes, 'publicKeyBytes', '../encryptjoin/lib/public_key.dart');
  rsakey2dart.saveKeyToDartFile(privateKeyBytes, 'privateKeyBytes',
      '../encryptjoin/lib/private_key.dart');
*/
  rsakey2dart.saveKeyToDartFile(
      publicKeyBytes, 'publicKeyBytes', '${ENCRYPTJOINPATH}public_key.dart');
  rsakey2dart.saveKeyToDartFile(
      privateKeyBytes, 'privateKeyBytes', '${ENCRYPTJOINPATH}private_key.dart');
  rsakey2dart.saveKeyToDartFile(
      publicKeyBytes, 'publicKeyBytes', '${ENCRYPTJOIN2PATH}public_key.dart');
  rsakey2dart.saveKeyToDartFile(privateKeyBytes, 'privateKeyBytes',
      '${ENCRYPTJOIN2PATH}private_key.dart');

//SecureJoin dir
/*  rsakey2dart.saveKeyToDartFile(
      privateKeyBytes, 'privateKeyBytes', '../securejoin/lib/private_key.dart');
*/
  rsakey2dart.saveKeyToDartFile(
      privateKeyBytes, 'privateKeyBytes', '${SECUREJOINPATH}private_key.dart');
  rsakey2dart.saveKeyToDartFile(
      privateKeyBytes, 'privateKeyBytes', '${SECUREJOIN2PATH}private_key.dart');

  print(
      'Chiavi generate e salvate nei file public_key.dart e private_key.dart.');
}
