# --- Configuration ---
$Shortcuts = @(
    "C:\Users\Public\Desktop\Adobe Acrobat.lnk",
    "C:\Users\Public\Desktop\Google Chrome.lnk",
    "C:\Users\Public\Desktop\Microsoft Edge.lnk",
    "C:\Users\Public\Desktop\VLC Media Player.lnk"
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