# ADNSecure: Suite di Utility per l'Esecuzione Sicura di Script

[![Licenza](https://img.shields.io/badge/licenza-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Versione](https://img.shields.io/github/v/release/mtravascio/adnsecure)](https://github.com/mtravascio/adnsecure/releases/latest)
[![Piattaforme](https://img.shields.io/badge/piattaforme-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/mtravascio/adnsecure/releases/latest)

**ADNSecure** è una raccolta di utility a riga di comando, scritte in Dart, progettate per la gestione e l'esecuzione sicura di script amministrativi (PowerShell, Bash) su sistemi operativi multi-piattaforma. Il cuore del progetto è un meccanismo di crittografia che lega gli script a workstation specifiche, impedendone l'esecuzione su macchine non autorizzate.

Il progetto è stato sviluppato da **Massimo Travascio** per il Ministero della Giustizia - Cisia di Torino (2024).

## Concetto Fondamentale: Encrypt & Execute

Il flusso di lavoro di ADNSecure si basa su un modello a due fasi:

1.  **Crittografia (`encryptscr`)**: Uno script (es. `script.ps1` o `script.sh`) viene crittografato per una specifica workstation di destinazione. L'output è un file `.scr` che può essere eseguito solo su quella macchina.
2.  **Esecuzione (`secscr`)**: L'utility `secscr` viene eseguita sulla workstation di destinazione per decifrare ed eseguire lo script in modo sicuro. Lo script può essere letto da un file locale o scaricato da un URL remoto.

Questo approccio garantisce che anche se un file `.scr` venisse intercettato, non potrebbe essere decifrato o eseguito su un computer diverso da quello per cui è stato creato.

## Componenti della Suite

ADNSecure è un monorepo che contiene diverse utility specializzate:

| Utility         | Descrizione                                                                                                                                |
| :-------------- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| **`encryptscr`**    | **Secure Script Encoder**: Cripta script PowerShell o Bash per una workstation specifica, generando un file `.scr`.                          |
| **`secscr`**        | **Secure Script Executer**: Decifra ed esegue un file `.scr` sulla workstation di destinazione, con supporto per l'esecuzione remota via HTTP. |
| **`securejoin`**    | Utility per la gestione sicura del processo di join a un dominio Active Directory, utilizzando credenziali a doppia crittografia.         |
| **`encryptjoin`**   | Cripta le credenziali per `securejoin` utilizzando un meccanismo di doppia cifratura (AES-256 + RSA-2048).                                |
| **`rsakey2dart`**   | Converte chiavi RSA in un formato array Dart da incorporare negli eseguibili.                                                              |
| **`netjoindomain`** | Un'implementazione di basso livello per il join a domini Windows tramite chiamate dirette alle API Win32.                                      |

## Architettura di Sicurezza

La sicurezza del sistema si basa su due pilastri fondamentali:

-   **Crittografia Robusta**: Viene utilizzata una combinazione di algoritmi crittografici standard di settore.
    -   **RSA (2048-bit)**: Per la crittografia asimmetrica delle chiavi.
    -   **AES (256-bit)**: Per la crittografia simmetrica del contenuto degli script.
-   **Workstation Binding**: Ogni script crittografato è indissolubilmente legato al nome del computer (su Windows) o all'hostname (su Linux/macOS) della macchina di destinazione. Questo legame impedisce l'esecuzione non autorizzata su altri sistemi.

## Utilizzo

Le utility sono progettate per essere usate da riga di comando. Di seguito alcuni esempi di base.

### Criptare uno script

Per criptare il file `deploy.ps1` per una macchina chiamata `PC-UFFICIO`:

```bash
encryptscr.exe --wks PC-UFFICIO --file deploy.ps1
```

Questo comando genererà un file `PC-UFFICIO.scr`.

### Eseguire uno script crittografato

Per eseguire il file `PC-UFFICIO.scr` sulla macchina di destinazione:

```bash
secscr.exe --file PC-UFFICIO.scr --exec
```

Per eseguirlo con privilegi amministrativi:

```bash
secscr.exe --file PC-UFFICIO.scr --exec --runas
```

### Eseguire uno script da URL

```bash
secscr.exe --url http://server/scripts/PC-UFFICIO.scr --exec
```

## Installazione

Gli eseguibili compilati per Windows, Linux e macOS sono disponibili nella pagina [**Releases**](https://github.com/mtravascio/adnsecure/releases) del repository.

## Dipendenze Chiave

Il progetto si affida a librerie Dart consolidate per la crittografia e la gestione del sistema:

-   **[encrypt](https://pub.dev/packages/encrypt)** e **[pointycastle](https://pub.dev/packages/pointycastle)**: Per le funzionalità crittografiche (AES, RSA).
-   **[args](https://pub.dev/packages/args)**: Per il parsing degli argomenti a riga di comando.
-   **[win32](https://pub.dev/packages/win32)**: Per l'interazione con le API native di Windows.
-   **[http](https://pub.dev/packages/http)**: Per il download di script da URL remoti.

## Contribuire

I contributi sono benvenuti. Sentiti libero di aprire una issue per segnalare bug o proporre nuove funzionalità. Se desideri contribuire al codice, puoi creare una fork del repository e sottomettere una pull request.

## Licenza

Questo progetto è rilasciato sotto la [Licenza MIT](https://opensource.org/licenses/MIT).
