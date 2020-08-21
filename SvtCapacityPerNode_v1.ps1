<# Script para reporteo de respaldos realizados por HPE SimpliVity

@Diego Delgado: https://github.com/ddelgado03/HPESimpliVity

# Requiere instalar modulo SVT PowerShell en el equipo donde se ejecutará
# Install-Module -Name HPESimplivity
# Módulo creado por Roy Atkins: https://github.com/atkinsroy/HPESimpliVity

# Forzar que carge el módulo sin reiniciar PowerShell
# Import-Module HPESimplivity -Force

Parámetros obligatorios: -ovcip (Obligatorio) : IP de OVC a ejecutar el comando
                         -username (Obligatorio) : Nombre de usuario con permisos de administración
                         -plainPassword (Obligatorio) : Contraseña de usuario

Comportamiento por defecto: Sin parámetros adicionales toma el espacio usado en cada nodo en el momento de la ejecución y crea una línea por cada nodo en un archivo de nombre SVTcapacityPerNode.csv
                            en la carpeta donde se ejecuta el Script. En ejecuciones subsecuentes agrega lineas adicionales al mismo archivo con el espacio en el momento de la nueva ejecución

Parámetros adicionales: -days <<número de días>> : Toma el espacio usado en cada nodo durante el periodo establecido y crea una línea por cada día en un archivo de nombre SVTcapacityPerNode-X-days.csv
                                                   en la carpeta donde se ejecuta el Script
                     

TODO: Permitir que el password del administrador se almacene en un archivo cifrado para ejecución "batch" desde el scheduler del OS de modo que tome una muestra diaria de forma automática

#>

param (
    [Parameter(Mandatory=$true)][string]$ovcip,
    [Parameter(Mandatory=$true)][string]$username,
    [Parameter(Mandatory=$true)][string]$plainPassword,
    $days
    )

$securePwd = ConvertTo-SecureString $plainPassword -AsPlainText -Force


$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $securePwd)

Connect-SVT -OVC $ovcip -Credential $Cred

$filename = "SVTcapacityPerNode.csv"
$filenameHistory = "SVTcapacityPerNode-" + $days + "-days" + ".csv"


if ($days -ne $null) {
    $days = $days * 24
    Write-Host  "${days}"

    Get-SVTcapacity -Hour $days -Resolution DAY | Export-Csv -Path $filenameHistory -Encoding ASCII -NoTypeInformation
    } else {

        if (!(Test-Path .\$filename)) {
            New-Item -Path .\ -name $filename -type "file"
            Write-Host $filename " created"
        }
        
        Get-SVTcapacity -Hour 0 | Export-Csv -Path $filename -Encoding ASCII -NoTypeInformation -Append

}


