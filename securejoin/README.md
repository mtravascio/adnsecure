# securejoin.exe

securejoin.exe decodifica il file encrypted_password.txt risultato della doppia cifratura AES(256) e RSA(2048).
Prima decodifica con RSA private_key per ottenere la password che è ancora cifrata in AES
Successivamente la password viene decifrata con algoritmo AES e key che in questo momento è cablata nell'eseguibile
ma bisognerà renderla parametro e tollerante alla diversificazione: attualmente se la chiave AES è sbagliata avviene un errore di decifrazione AES (try catch?).

Qui bisognerà aggiungere l'esecuzione del processo di join in ADN con la password decifrata.
