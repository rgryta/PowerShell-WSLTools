if (-not (Get-Module -ListAvailable -Name WSLTools)) {
	Install-Module -Name WSLTools
}
Import-Module WSLTools -WarningAction SilentlyContinue
try {
	Ensure-HyperV -Install
	Ensure-WSL -Install
	Write-Host "Reboot required"
}
catch {
	Write-Host "Permissions need to be elevated or HyperV is disabled in BIOS"
}