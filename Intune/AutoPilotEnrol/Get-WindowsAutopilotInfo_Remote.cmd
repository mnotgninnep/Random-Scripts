set computer = "SIT-OD-TEST11"
powershell.exe -NoProfile -ExecutionPolicy Unrestricted -Command "& '%~dp0Get-WindowsAutoPilotInfo.ps1' -ComputerName %computer% -OutputFile '%~dp0computers.csv' -Append"
