import 'dart:io';
import 'package:netjoindomain/netjoindomain.dart' as netjoindomain;

void main(List<String> arguments) {
  stdout.writeln('Inserisci Dominio: usr.root.jus\\<machinename>');
  String domain = stdin.readLineSync() ?? 'usr.root.jus\\NBTOTOCIS00092';
  stdout.writeln('Inserisci Username: UTENTI\\<username>');
  String user = stdin.readLineSync() ?? 'UTENTI\\massimo.travascio';
  stdout.writeln('Inserisci Password: <password>');
  String password = stdin.readLineSync() ?? 'Password01';

  print('Join Domanin Result: ${netjoindomain.join(domain, user, password)}!');

  stdout.writeln('premere INVIO per terminare!');
  String? pause = stdin.readLineSync();
}
