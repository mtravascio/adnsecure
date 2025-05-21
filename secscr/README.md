# SecScr

* Secure Script Executer: Run an encrypted powershell (windows) or bash (Linux/Max) script. (python to be...)

* Ministero della Giustizia - Cisia di Torino - 2024 - Massimo Travascio (massimo.travascio@giustizia.it) 

* secscr.exe [-f|--file] scriptname.scr [-u|--url] http://HOST:PORT/scriptname.scr [--exec|-x] [--runas]
Decripta ed !!!esegue scriptname.scr in locale!!!! leggendo da file in locale o effettuando un download da remoto via http.
(l'opzione --runas richiede l'utente con il quale eseguire lo script decryptato)
scriptname.scr verrà eseguito solo se criptato per la workstation locale.
