if (-not (Get-Module -ListAvailable -Name WSLTools)) {
    Install-Module -Name WSLTools
} 

Import-Module WSLTools -WarningAction SilentlyContinue
if (-not (Ensure-HyperV)) {
	Ensure-HyperV -Install
	$command = "pwsh ""Start-Process pwsh -ArgumentList '-NoExit -ExecutionPolicy Bypass -file """"E:\Github\PowerShell-WSLTools\example.ps1""""'"""
	Run-AfterReboot -Command $command
}
if (-not (Ensure-WSL)) {
	Ensure-WSL -Install
}