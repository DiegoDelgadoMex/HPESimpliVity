# Requieres Roy Atkins' HPESimpliVity module installed in PowerShell (https://github.com/atkinsroy/HPESimpliVity) 
# Author: Diego Delgado (diego.delgado@hpe.com)

# Script to log most recent HPE SimpliViy backups to a file

# Install-Module -Name HPESimplivity
# PowerShell has to be restarted after installation or forced to load it: Import-Module HPESimplivity -Force

# Before running the script the password for the user has to be saved securely to a file . This can be done by using the following procedure.

# $password = "Password123!@#"
# $secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force
# $secureStringText = $secureStringPwd | ConvertFrom-SecureString
# Set-Content "C:\temp\ExportedPassword.txt" $secureStringText


# Script execution starts here
#-------------------------------------------------------------------------------------

# Set the OVC IP address to establish the connection to
$ovcip = "OVC_IP_address"

# Define the output filename 
$filename = "SVTbackups" + (Get-Date -UFormat "-%d-%m-%Y" ) + ".log"

# Define user that will connect to SimpliViy
$username = "administrator@vsphere.local"
# Get the hashed text from the file and convert it to the format needed
$pwdText = Get-Content "C:\Users\Console\logs\Password"
$securePwd = $pwdText | ConvertTo-SecureString
$secureStringText = $secureStringPwd | ConvertFrom-SecureString

# Create the credentia object to use to connect
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd

# Connect to the OVC (The IP has to be defined)
Connect-SVT -OVC $ovcip -Credential $Cred

# Run the module that actually gets the backups, formats the output so it doesn't get cropped and saves it to file 
Get-SVTbackup | Format-Table -AutoSize | Out-String -Width 4096 | Out-File $filename

# Failed backup log created in different file

# Define filename
$failFile = "SVTbackups" + (Get-Date -UFormat "-%d-%m-%Y" ) + "_FAILED" + ".log"

# Search pattern in output file and send to file
Select-String -Path $filename -Pattern 'FAILED'| select line | Format-Table -AutoSize | Out-String -Width 4096 | Out-File $failFile
