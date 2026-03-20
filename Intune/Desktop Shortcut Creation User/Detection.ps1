# Declare names of shortcuts to be detected here. Name mSust match the remediation script.
$Shortcuts = @("Change BitLocker PIN", "IT Email", "IT HelpDesk") # Names only for detection

# Don't change anything below here.
# How to get the user's desktop dir. Difficult when mapped to onedrive.
$Desktop = [Environment]::GetFolderPath("Desktop")

# Missing shortcut counter
$MissingCount = 0
foreach ($Name in $Shortcuts) {
    if (-not (Test-Path "$Desktop\$Name.lnk")) { $MissingCount++ }
}

# If missing >0 then remediate (exit 1)
if ($MissingCount -eq 0) {
    Write-Output "Shortcuts present."
    Exit 0
} else {
    Write-Output "Shortcuts missing."
    Exit 1
}