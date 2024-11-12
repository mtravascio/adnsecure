import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'winapi.dart';

int join(String domainName, String userName, String password) {
  //String domainName = 'usr.root.jus\\NBTOCIS00092';
  //String userName = 'UTENTI\\massimo.travascio';
  //String password = 'Password01';

  //int options = NETSETUP_JOIN_DOMAIN | NETSETUP_ACCT_CREATE; //ACCOUNT CREATE DISABILITATO!
  int options = NETSETUP_JOIN_DOMAIN;

  final Pointer<Utf16> pDomainName = domainName.toNativeUtf16();
  final Pointer<Utf16> pUserName = userName.toNativeUtf16();
  final Pointer<Utf16> pPassword = password.toNativeUtf16();

  //print('Dominio: $domainName - Username: $userName - Password: $password');

  print('Dominio: $domainName - Username: $userName - Password: ********');

  try {
    final int result = NetJoinDomain(
        nullptr, pDomainName, nullptr, pUserName, pPassword, options);

    if (result == NERR_Success) {
      print('Join al dominio avvenuta con successo!');
    } else {
      print('Errore nel join al dominio. Codice di errore: $result');
    }
  } finally {
    calloc.free(pDomainName);
    calloc.free(pUserName);
    calloc.free(pPassword);
  }

  return 0;
}
