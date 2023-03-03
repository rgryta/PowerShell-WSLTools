function Ensure-WSL 
{
	Param(
		[switch]$Install
	)
	if (-Not (Ensure-HyperV)) {
		Write-ColorOutput red "[ERROR] HyperV not installed"
		return $false
	}
	try {
		if ($(Get-AppxPackage -Name MicrosoftCorporationII.WindowsSubsystemForLinux) -eq $null) {
			if ($Install) {
				winget install 9P9TQF7MRM4R --source msstore --accept-source-agreements --accept-package-agreements
			}
			else {
				return $false
			}
		}
	}
	catch {
		Write-ColorOutput red "[ERROR] Elevated access needed to check WSL settings or installation"
		throw "Elevated access required"
	}
	$ignr = wsl --set-default-version 2
	return $true
}