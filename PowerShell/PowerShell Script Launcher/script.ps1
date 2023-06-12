Write-Host "Hello World!`n"
Write-Host "Is Administrator   `t: $(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))"
Write-Host "Execution Policy   `t: $(Get-ExecutionPolicy)"
Write-Host "Terminal Profile ID`t: $($env:WT_PROFILE_ID)"
Write-Host

Pause