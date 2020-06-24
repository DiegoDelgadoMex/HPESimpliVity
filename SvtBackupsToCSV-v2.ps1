<# Script para reporteo de respaldos realizados por HPE SimpliVity

# Requiere instalar modulo SVT PowerShell en el equipo donde se ejecutará
# Install-Module -Name HPESimplivity

# Forzar que carge el módulo sin reiniciar PowerShell
# Import-Module HPESimplivity -Force

Parámetros obligatorios: -ovcip : IP de OVC a ejecutar el comando
                         -username : Nombre de usuario con permisos de administración
                         -plainPassword : Contraseña de usuario

Operación por defecto: Sin parámetros adicionales se obtienen los respaldos realizados en las últimas 24 horas (Limitado a 500 respaldos)

Parámetros modificatorios: -fromDate : Fecha desde la cuál se quieren obtener los respaldos en formato "DD/MM/YYYY" (Hereda el formato de fecha del equipo donde se ejecuta por lo que podría ser "MM/DD/YYYY"
                           -limit: Número de respaldos a obtener, puede ser menor o mayor al límite por defecto de 500

Se generará un archivo CSV en la misma carpeta donde reside el Scritpt con nombre SVTbackups-DD-MM-YYYY.csv

TODO: Implementación de filtro por estado de respaldo para buscar respaldos fallidos y la opción de reportar todos los respaldos en una categoría como opción al parámetro "limit"

#>

param (
    [Parameter(Mandatory=$true)][string]$ovcip,
    [Parameter(Mandatory=$true)][string]$username,
    [Parameter(Mandatory=$true)][string]$plainPassword,
    [string]$state,
    $fromDate,
    $limit
)

$securePwd = ConvertTo-SecureString $plainPassword -AsPlainText -Force


$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $securePwd)

Connect-SVT -OVC $ovcip -Credential $Cred

$filename = "SVTbackups" + (Get-Date -UFormat "-%d-%m-%Y" ) + ".csv"


# Ejecuta comandos según parámetros

If (($fromDate -eq $null) -and ($limit -eq $null)) {    # Sin fecha o límite

Write-Host "Sin fecha sin limite "
Get-SVTbackup | Export-Csv -Path $filename -Encoding ASCII -NoTypeInformation

} elseif (($fromDate -ne $null) -and ($limit -eq $null)) {     # Con fecha, sin límite

Write-Host "Con fecha sin limite "
Get-SVTbackup -CreatedAfter $fromDate | Export-Csv -Path $filename -Encoding ASCII -NoTypeInformation


} elseif (($fromDate -eq $null) -and ($limit -ne $null)) {          # Sin fecha, con límite

Write-Host "Sin fecha con limite "
Get-SVTbackup -Limit $limit | Export-Csv -Path $filename -Encoding ASCII -NoTypeInformation

} elseif (($fromDate -ne $null) -and ($limit -ne $null)) {          # Sin fecha, sin límite

Get-SVTbackup -CreatedAfter $fromDate -Limit $limit| Export-Csv -Path $filename -Encoding ASCII -NoTypeInformation

}
