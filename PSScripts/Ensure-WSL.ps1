function Ensure-WSL 
{
	Param(
		[switch]$Install
	)
	if (-Not $(Get-Command "Ensure-PSDependency" -errorAction SilentlyContinue)) {
		throw "Ensure-PSDependency is not available"
	}
	
	if (-Not $(Get-Command "Write-ColorOutput" -errorAction SilentlyContinue)) {
		"Write-ColorOutput" | Ensure-PSDependency
		. "$(Get-Location)\PSDependencies\Write-ColorOutput.ps1"
	}
	
	if (-Not $(Get-Command "Ensure-HyperV" -errorAction SilentlyContinue)) {
		"Ensure-HyperV" | Ensure-PSDependency
		. "$(Get-Location)\PSDependencies\Ensure-HyperV.ps1"
	}
	if (-Not (Ensure-HyperV)) {
		return $false
	}
	
	if ((winget list -n 1 --id 9P9TQF7MRM4R | Measure-Object -line).Lines -eq 3) {
		if ($Install) {
			winget install 9P9TQF7MRM4R --source msstore --accept-source-agreements --accept-package-agreements
		}
		else {
			return $false
		}
	}
	wsl --set-default-version 2
	return $true
}