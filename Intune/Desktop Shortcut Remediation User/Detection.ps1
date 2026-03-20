# --- Configuration ---
[system.string]$Desktop = [Environment]::GetFolderPath("Desktop")
$Shortcuts = @(
    "$Desktop\Google Chrome.lnk",
    "$Desktop\VLC Media Player.lnk"
)

$Found = $false

foreach ($Path in $Shortcuts) {
    if (Test-Path -Path $Path) {
        Write-Host "Found shortcut: $Path"
        $Found = $true
    }
}

if ($Found) {
    # Exit 1 triggers the Remediation script
    exit 1
} else {
    Write-Host "No targeted shortcuts found. System is clean."
    exit 0
}