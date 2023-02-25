function Run-AfterReboot
{
	Param(
		[Parameter(Mandatory = $true)] [String]$Command
	)
	New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name PST-RAR -PropertyType String -Value "$Command"  | Out-Null

	Write-ColorOutput yellow '[Warning] Your computer will restart in 5s'
	Start-Sleep -Seconds 5

	Write-ColorOutput yellow '[Warning] Restarting...'
	Start-Sleep -Seconds 1
	Restart-Computer -Force
}