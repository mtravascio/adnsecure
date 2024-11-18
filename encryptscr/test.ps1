#!powershell
#comandi da eseguire come amministratore! (runas)
Write-Host "Comando 1: Elenco processi"; 
Get-Process | Out-Host;
Write-Host "Comando 2: Elenco processi su file c:\log.txt"; 
Get-Process > c:\log.txt 
Write-Host "Comando 3: Informazioni di sistema"; 
Get-ComputerInfo | Out-Host;
Write-Host "Comando 4: Informazioni di sistema su c:\log.txt"; 
Get-ComputerInfo >> c:\log.txt 