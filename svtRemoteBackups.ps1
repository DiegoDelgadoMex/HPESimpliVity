# Script para obtener los respaldos remotos de SVT
# El script recibe parámetros que permiten tomar el reporte por cada cluster
# Para ejecutar este script es necesario instalar el módulo de PowerShell de SimpliVity con el siguiente comando en PowerShell
# Install-Module -Name HPESimpliVity

# https://github.com/atkinsroy/HPESimpliVity



param (
    [Parameter(Mandatory=$true)][string]$ovcip,         # IP de un OVC o del MVA
    [Parameter(Mandatory=$true)][string]$username,      # Usuario administrador de vCenter
    [Parameter(Mandatory=$true)][string]$password,      # Contraseña del administrador
    
    [Parameter(Mandatory=$true)][string]$destination    # Cluster destino
)

# Ejemplo de uso 
# .\svtRemoteBackups.ps1 -username administrator@vsphere.local -password <password de vcenter> -ovcip <IP de OVC> -source <cluster origen> -destination <cluster destino>
# Archivo resultante
# <cluster origen>-SVTbackup-<fecha>.csv

$securePwd = ConvertTo-SecureString $password -AsPlainText -Force


$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $securePwd)

Connect-SVT -VA $ovcip -Credential $Cred

$filename = $source + "-SVTbackups"  + (Get-Date -UFormat "-%d-%m-%Y" ) + ".csv"
 
Get-SvtBackup -DestinationName $destination -all | Export-Csv -Path $filename -Encoding ASCII -NoTypeInformation

