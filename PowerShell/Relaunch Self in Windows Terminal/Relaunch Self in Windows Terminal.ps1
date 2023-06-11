# Launch Self in Windows Terminal

$CodeString = ""
$CodeString += "Set-ExecutionPolicy Bypass -Scope Process;"
$CodeString += "&'$PSCommandPath';"
$Code = [scriptblock]::Create($CodeString)

if ($env:WT_PROFILE_ID) {
  Write-Host "Launched in Windows Terminal"
  pause
} else {
  if (Get-Command wt.exe -ErrorAction SilentlyContinue) { wt.exe -p "Windows PowerShell" powershell.exe -command $Code }
  if (Get-Command wdt.exe -ErrorAction SilentlyContinue) { wdt.exe -p "Windows PowerShell" powershell.exe -command $Code }
}
