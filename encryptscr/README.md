# EncryptScr

* Secure Script Encoder: encrypt a powershell (windows) or bash (Linux/Max) script. (python to be...)

* Ministero della Giustizia - Cisia di Torino - 2024 - Massimo Travascio (massimo.travascio@giustizia.it) 

* encryptscr.exe [--wks|-w] workstation [--file|-f] 'script.ps1'|'script.sh'|'script.py'  -> genera 'workstation.scr' da usare con secscr.exe 
Cripta lo 'script.*' in 'WORKSTATIONNAME.SCR' che possiede il nome specificato da 'workstaion' come nome conputer (windows) o hostname (Linux/Mac).
secscr.exe utilizerà il nome macchina o hostname per eseguire il file WORKSTATION.SCR. Uno script cryptato per una workstation non verrà eseguito su un'altra workstation con nome macchina o hostname diverso!  (a meno di -force (hidden)). 

* encryptscr.exe [--wks|-w] workstation -> verifica il file 'workstation.scr'
Verifica se 'workstation.scr' è cryptato e valido ed è possibile eseguirlo ma non lo esegue!

* encryptscr.exe [--url|-u] http://HOST:PORT/workstation -> verifica la presenza di 'workstation.scr' url remota
Verifica se è possibile scaricare il file alla url specificata utilizzando il protocollo 'http' effettuando le stesse operazioni dell'opzione -w.

* encryptscr.exe [--wks|-w] workstation [-s|--show] -> 
Decripta il file 'workstation.scr' e lo mostra a video

* encryptscr.exe [--wks|-w] workstation [-x|--exec] [--runas] 
Decripta ed !!!esegue workstation.scr in locale!!!! (l'opzione --runas richiede l'utente con il quale eseguire lo script cryptato)
