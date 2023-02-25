function Run-AfterReboot
{
	Param(
		[Parameter(Mandatory = $true)] [String]$Command
	)
	if (-Not $(Get-Command "Write-ColorOutput" -errorAction SilentlyContinue)) {
		"Write-ColorOutput" | Ensure-PSDependency
		. "$(Get-Location)\PSDependencies\Write-ColorOutput.ps1"
	}
	
	New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name PST-RAR -PropertyType String -Value "$Command"  | Out-Null

	Write-ColorOutput yellow '[Warning] Your computer will restart in 5s'
	Start-Sleep -Seconds 5

	Write-ColorOutput red '[Warning] Restarting...'
	Start-Sleep -Seconds 1
	Restart-Computer -Force
}