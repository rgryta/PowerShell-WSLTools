if (-not (Get-Module -ListAvailable -Name WSLTools)) {
    Install-Module -Name WSLTools
	Import-Module WSLTools -WarningAction SilentlyContinue
}

Ensure-HyperV -Install
Ensure-WSL -Install
