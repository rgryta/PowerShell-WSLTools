function Get-Select
{
	Param(
		[Parameter(Mandatory = $true)] [String]$Prompt,
		[Parameter(Mandatory = $true)] [String[]]$Options
	)
	
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