function Get-Select
{
	Param(
		[Parameter(Mandatory = $true)] [String]$Prompt,
		[Parameter(Mandatory = $true)] [String[]]$Options
	)
	if (-Not $(Get-Command 'Ensure-PSDependency' -errorAction SilentlyContinue)) {
		throw "Ensure-PSDependency is not available"
	}
	
	if (-Not $(Get-Command "Write-ColorOutput" -errorAction SilentlyContinue)) {
		"Write-ColorOutput" | Ensure-PSDependency
		. "$(Get-Location)\PSDependencies\Write-ColorOutput.ps1"
	}
	
	Write-ColorOutput white "$Prompt"
	$Options | % {$i=0} {Write-ColorOutput white "`t $($i+1)) $($_)"; $i++}
	Do {
		$selected = Read-Host -Prompt "Select"
		$validated = $false
		if ($selected -match '^[0-9]+$') {
			$selected = [int]$selected
			if ($selected -gt 0 -And $selected -le $Options.Count) {
				$validated = $true
			}
		}
	}
	Until ($validated)
	$selected = $Options | Select -Index $($selected - 1)
	return $selected
}