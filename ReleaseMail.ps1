param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("morning", "afternoon")]
    [string]$Schedule,
    
    [Parameter(Mandatory=$true)]
    [string]$RecipientEmailsFilePath
)

# Connect to Exchange Online PowerShell
# $UserCredential = Get-Credential
# $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $UserCredential -Authentication "Basic" -AllowRedirection
# Import-PSSession $Session

# Read recipient email addresses from the text file
$RecipientEmails = Get-Content $RecipientEmailsFilePath

# Get the current date and time
$CurrentDateTime = Get-Date

# Set the StartReceivedDate based on the schedule
if ($Schedule -eq "morning") {
    $StartReceivedDate = (Get-Date -Year $CurrentDateTime.Year -Month $CurrentDateTime.Month -Day $CurrentDateTime.Day -Hour 4 -Minute 30 -Second 0)
} elseif ($Schedule -eq "afternoon") {
    $StartReceivedDate = (Get-Date -Year $CurrentDateTime.Year -Month $CurrentDateTime.Month -Day $CurrentDateTime.Day -Hour 10 -Minute 30 -Second 0)
}

# Get the quarantined messages sent to the specified recipients within the StartReceivedDate
$QuarantineMessages = Get-QuarantineMessage | Where-Object {
    $RecipientEmails -contains $_.RecipientAddress -and
    $_.Received -gt $StartReceivedDate -and
    $_.SCL -eq 5  # Filter for spam messages only (SCL: 5)
}

# Release and report false positives for the quarantined messages
foreach ($Message in $QuarantineMessages) {
    Release-QuarantineMessage -Identity $Message.Identity
    Submit-QuarantineMessageReport -Identity $Message.Identity -FalsePositive
}

# Disconnect from Exchange Online PowerShell
# Remove-PSSession $Session

# .\Release-QuarantinedMail.ps1 -schedule morning -RecipientEmailsFilePath "C:\path\to\RecipientEmails.txt"
