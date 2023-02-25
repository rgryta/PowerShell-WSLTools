function Ensure-PSDependency 
{
	begin {
		New-Item –ItemType directory –Path "$(Get-Location)\PSDependencies"  -ErrorAction SilentlyContinue | Out-Null
	}
	process {
		if (Get-Command "$_" -errorAction SilentlyContinue) {
			if (-Not $(Get-Command "Write-ColorOutput" -errorAction SilentlyContinue)) {
				"Write-ColorOutput" | Ensure-PSDependency
				. "$(Get-Location)\PSDependencies\Write-ColorOutput.ps1"
			}
			Write-ColorOutput yellow "[INFO] $_ already downloaded"
		}
		else {
			if (-Not (Test-Path -Path "$(Get-Location)\PSDependencies\$_.ps1")) {
				$ProgressPreference = 'SilentlyContinue'
				Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rgryta/PowerShell-Tools/main/PSScripts/$_.ps1" -OutFile "$(Get-Location)\PSDependencies\$_.ps1"
			}
		}
	}
}