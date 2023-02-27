New-Item –ItemType directory –Path "$(Get-Location)\PSDependencies"  -ErrorAction SilentlyContinue | Out-Null
if (-Not (Test-Path -Path "$(Get-Location)\PSDependencies\Ensure-PSDependency.ps1")) {
	Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rgryta/PowerShell-Tools/main/PSScripts/Ensure-PSDependency.ps1" -OutFile "$(Get-Location)\PSDependencies\Ensure-PSDependency.ps1"
}
. "$(Get-Location)\PSDependencies\Ensure-PSDependency.ps1"


"WSL-Ubuntu-Install" | Ensure-PSDependency
. ".\PSDependencies\WSL-Ubuntu-Install.ps1"




# Ensure-HyperV  Example:
# if (-Not (Ensure-HyperV)) {
#		return $false
#	}
# Returns false if Hyper-V is not enabled
# Ensure-HyperV --Install - Installs HyperV

# Ensure-PSDependency Example:
# "WSL-Alpine-Install" | Ensure-PSDependency
# . ".\PSDependencies\WSL-Alpine-Install.ps1"

# Ensure-WSL  Example:
# if (-Not (Ensure-WSL)) {
#		return $false
#	}
# Returns false if WSL is not enabled
# Ensure-WSL --Install - Installs WSL

# Run-AfterReboot Example:
# $command = "powershell.exe ""Start-Process pwsh -ArgumentList '-NoExit -ExecutionPolicy Bypass -file """"E:\Github\PowerShell-Tools\example2.ps1""""'"""
# Run-AfterReboot -Command $command

# Write-ColorOutput Example:
# Write-ColorOutput red "Prints red string"

# WSL-Alpine-Install Example:
# WSL-Alpine-Install -DistroAlias alpine -InstallPath . -Interactive

# WSL-Ubuntu-Install Example:
# WSL-Ubuntu-Install -DistroAlias ubuntu -InstallPath . -Interactive
