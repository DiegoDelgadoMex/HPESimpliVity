<# Script to report SimpliVity Backups in a CSV File

@Diego Delgado: https://github.com/DiegoDelgadoMex/HPESimpliVity

# Requieres the SimpliVity Power Shell module to be installed
# Install-Module -Name HPESimplivity
# Module created by Roy Atkins: https://github.com/atkinsroy/HPESimpliVity

# To force the module to load without restarting PowerShell run:
# Import-Module HPESimplivity -Force

Mandatory parameters: -ovcip : SVT OCV or MVA IP address (any OVC in the federation)
                      -username : Administrator user name
                      -plainPassword : User password

Default operation: Without any parameters it will return backups made in the last 24 hours (Limited to 500 backups)

Optional parameters: -fromDate : Returns backups made from the specified date (Date format inherited from executing computer)
                     -limit: Amount of backups to obtain, can be smaller of bigger than the 500 default

Generates a CSV file in the same folder where the script runs named SVTbackups-DD-MM-YYYY.csv


#>

param (
    [Parameter(Mandatory=$true)][string]$ovcip,
    [Parameter(Mandatory=$true)][string]$username,
    [Parameter(Mandatory=$true)][string]$plainPassword,
    $fromDate,
    $limit
)

$securePwd = ConvertTo-SecureString $plainPassword -AsPlainText -Force


$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $securePwd)

Connect-SVT -VA $ovcip -Credential $Cred

$filename = "SVTbackups" + (Get-Date -UFormat "-%d-%m-%Y" ) + ".csv"


# Script execution

If (($fromDate -eq $null) -and ($limit -eq $null)) {    # No date or limits

#Write-Host "Sin fecha sin limite "
Get-SVTbackup | Export-Csv -Path $filename -Encoding ASCII -NoTypeInformation

} elseif (($fromDate -ne $null) -and ($limit -eq $null)) {     # From date, no limit (500 default)

#Write-Host "Con fecha sin limite "
Get-SVTbackup -CreatedAfter $fromDate | Export-Csv -Path $filename -Encoding ASCII -NoTypeInformation


} elseif (($fromDate -eq $null) -and ($limit -ne $null)) {          # No from date, limit stated

#Write-Host "Sin fecha con limite "
Get-SVTbackup -Limit $limit | Export-Csv -Path $filename -Encoding ASCII -NoTypeInformation

} elseif (($fromDate -ne $null) -and ($limit -ne $null)) {          # States from date and backup count limit

Get-SVTbackup -CreatedAfter $fromDate -Limit $limit| Export-Csv -Path $filename -Encoding ASCII -NoTypeInformation

}
