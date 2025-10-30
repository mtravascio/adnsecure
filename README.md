[🇮🇹 Italian version below](#versione-italiana)

# ADNSecure: Utility Suite for Secure Script Execution

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/github/v/release/mtravascio/adnsecure)](https://github.com/mtravascio/adnsecure/releases/latest)
[![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/mtravascio/adnsecure/releases/latest)

**ADNSecure** is a collection of command-line utilities written in Dart, designed for the secure management and execution of administrative scripts (PowerShell, Bash) across multiple operating systems.
The core of the project is an encryption mechanism that binds scripts to specific workstations, preventing their execution on unauthorized machines.

The project was developed by **Massimo Travascio** for the Ministry of Justice – Cisia of Turin (2024).

## Core Concept: Encrypt & Execute

The ADNSecure workflow is based on a two-phase model:

1. **Encryption (`encryptscr`)**: A script (e.g., `script.ps1` or `script.sh`) is encrypted for a specific target workstation. The output is a `.scr` file that can only be executed on that machine.
2. **Execution (`secscr`)**: The `secscr` utility runs on the target workstation to decrypt and securely execute the script. The script can be loaded from a local file or downloaded from a remote URL.

This approach ensures that even if a `.scr` file is intercepted, it cannot be decrypted or executed on a computer other than the one it was created for.

## Suite Components

ADNSecure is a monorepo containing several specialized utilities:

| Utility             | Description                                                                                                                            |
| :------------------ | :------------------------------------------------------------------------------------------------------------------------------------- |
| **`encryptscr`**    | **Secure Script Encoder**: Encrypts PowerShell or Bash scripts for a specific workstation, generating a `.scr` file.                   |
| **`secscr`**        | **Secure Script Executor**: Decrypts and executes a `.scr` file on the target workstation, with support for remote execution via HTTP. |
| **`securejoin`**    | Utility for securely managing the process of joining an Active Directory domain, using double-encrypted credentials.                   |
| **`encryptjoin`**   | Encrypts credentials for `securejoin` using a dual encryption mechanism (AES-256 + RSA-2048).                                          |
| **`rsakey2dart`**   | Converts RSA keys into Dart array format for embedding into executables.                                                               |
| **`netjoindomain`** | A low-level implementation for joining Windows domains through direct Win32 API calls.                                                 |

## Security Architecture

System security is built on two key pillars:

* **Strong Encryption**: A combination of industry-standard cryptographic algorithms is used.

  * **RSA (2048-bit)**: For asymmetric key encryption.
  * **AES (256-bit)**: For symmetric encryption of script content.
* **Workstation Binding**: Each encrypted script is irrevocably bound to the computer name (on Windows) or hostname (on Linux/macOS) of the target machine. This binding prevents unauthorized execution on other systems.

## Usage

The utilities are designed to be used from the command line. Below are some basic examples.

### Encrypting a Script

To encrypt the file `deploy.ps1` for a machine named `PC-OFFICE`:

```bash
encryptscr.exe --wks PC-OFFICE --file deploy.ps1
```

This command will generate a file called `PC-OFFICE.scr`.

### Executing an Encrypted Script

To execute the file `PC-OFFICE.scr` on the target machine:

```bash
secscr.exe --file PC-OFFICE.scr --exec
```

To execute it with administrative privileges:

```bash
secscr.exe --file PC-OFFICE.scr --exec --runas
```

### Executing a Script from a URL

```bash
secscr.exe --url http://server/scripts/PC-OFFICE.scr --exec
```

## Installation

Precompiled executables for Windows, Linux, and macOS are available on the repository’s [**Releases**](https://github.com/mtravascio/adnsecure/releases) page.

## Key Dependencies

The project relies on well-established Dart libraries for cryptography and system management:

* **[encrypt](https://pub.dev/packages/encrypt)** and **[pointycastle](https://pub.dev/packages/pointycastle)**: For cryptographic functionality (AES, RSA).
* **[args](https://pub.dev/packages/args)**: For command-line argument parsing.
* **[win32](https://pub.dev/packages/win32)**: For interacting with native Windows APIs.
* **[http](https://pub.dev/packages/http)**: For downloading scripts from remote URLs.

## Contributing

Contributions are welcome. Feel free to open an issue to report bugs or suggest new features.
If you wish to contribute code, fork the repository and submit a pull request.

## License

This project is released under the [MIT License](https://opensource.org/licenses/MIT).

---

# Versione Italiana

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
