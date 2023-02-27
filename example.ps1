New-Item –ItemType directory –Path "$(Get-Location)\PSDependencies"  -ErrorAction SilentlyContinue | Out-Null
if (-Not (Test-Path -Path "$(Get-Location)\PSDependencies\Ensure-PSDependency.ps1")) {
	Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rgryta/PowerShell-Tools/main/PSScripts/Ensure-PSDependency.ps1" -OutFile "$(Get-Location)\PSDependencies\Ensure-PSDependency.ps1"
}
. "$(Get-Location)\PSDependencies\Ensure-PSDependency.ps1"


"WSL-Alpine-Install" | Ensure-PSDependency
. ".\PSDependencies\WSL-Alpine-Install.ps1"

WSL-Alpine-Install


# Run-AfterReboot Example:
# $command = "powershell.exe ""Start-Process pwsh -ArgumentList '-NoExit -ExecutionPolicy Bypass -file """"E:\Github\PowerShell-Tools\example2.ps1""""'"""
# Run-AfterReboot -Command $command