# --- Configuration ---
[system.string]$Desktop = [Environment]::GetFolderPath("Desktop")
$Shortcuts = @(
    "$Desktop\Google Chrome.lnk",
    "$Desktop\VLC Media Player.lnk"
)

foreach ($Path in $Shortcuts) {
    if (Test-Path -Path $Path) {
        try {
            Remove-Item -Path $Path -Force -ErrorAction Stop
            Write-Host "Successfully removed: $Path"
        } catch {
            Write-Error "Failed to remove $Path : $($_.Exception.Message)"
        }
    }
}