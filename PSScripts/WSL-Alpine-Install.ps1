function WSL-Alpine-Install
{
	Param(
		[switch]$Interactive = $false,
		[Parameter(Mandatory = $true)] [String]$DistroAlias
	)
	if (-Not $(Get-Command 'Ensure-PSDependency' -errorAction SilentlyContinue)) {
		throw "Ensure-PSDependency is not available"
	}
	
	if (-Not $(Get-Command 'Write-ColorOutput' -errorAction SilentlyContinue)) {
		"Write-ColorOutput" | Ensure-PSDependency
		. "$(Get-Location)\PSDependencies\Write-ColorOutput.ps1"
	}
	
	if (-Not $(Get-Command 'Ensure-WSL' -errorAction SilentlyContinue)) {
		"Ensure-WSL" | Ensure-PSDependency
		. "$(Get-Location)\PSDependencies\Ensure-WSL.ps1"
	}
	
	if (-not $(Ensure-WSL)) {
		Write-ColorOutput red "WSL not installed"
		return $false
	}
	
	# Get all alpine versions
	$versions = (Invoke-WebRequest https://dl-cdn.alpinelinux.org/alpine/ -UseBasicParsing).Content
	$HTML = New-Object -Com "HTMLFile"
	try {
		$HTML.IHTMLDocument2_write($versions)
		
		$ihtml = $true
		$prop = "IHTMLAnchorElement_pathname"
		$versions = $HTML
	}
	catch {
		$ihtml = $false
		$prop = "pathname"
		
		$src = [System.Text.Encoding]::Unicode.GetBytes($versions)
		$HTML.write($src)
		$versions = $HTML.body
	}
	
	# Only get links that match path: v[number].[number]/
	$versions = $versions.getElementsByTagName("a") | Where-Object {$_.$prop -match "v\d+\.\d+\/"}
	$parsed_versions = $versions | Select -ExpandProperty $prop | % { New-Object System.Version ($($_ -replace 'v' -replace '/')) } | Sort
	
	if ($Interactive) {
		Write-ColorOutput yellow "Select which Alpine version you'd like to install:"
		$parsed_versions | % {$i=0} {"`t $($i+1)) $($_)"; $i++}
		Do {
			$selected = Read-Host -Prompt "Select"
			$validated = $false
			if ($selected -match '^[0-9]+$') {
				$selected = [int]$selected
				if ($selected -gt 0 -And $selected -le $parsed_versions.Count) {
					$validated = $true
				}
			}
		}
		Until ($validated)
		
		$selected = $parsed_versions | Select -Index $($selected - 1)
	}
	
	# Get latest
	if (-not $Interactive) {
		$selected = $parsed_versions.item($($parsed_versions.Count - 1))
	}
	
	$selected = $versions | Where-Object -Property $prop -Like -Value "*$($selected.toString())*"
	
	# Grab available modifications of alpine image (minimal/net etc.)
	$selver = $selected | Select-Object -ExpandProperty $prop
	$modifications = (Invoke-WebRequest https://dl-cdn.alpinelinux.org/alpine/$($selver)releases/x86_64/).Content
	$HTML = New-Object -Com "HTMLFile"
	
	if ($ihtml) {
		$HTML.IHTMLDocument2_write($modifications)
		$modifications = $HTML
	}
	if (-not $ihtml) {
		$src = [System.Text.Encoding]::Unicode.GetBytes($modifications)
		$HTML.write($src)
		$modifications = $HTML.body
	}
	
	# Only interested in .tar.gz images (maybe iso support next (?))
	$modifications = $modifications.getElementsByTagName("a") | Where-Object {$_.$prop -like "*.tar.gz"} | Sort-Object -Property $prop
	
	$parsed_modifications = $modifications | Select -ExpandProperty $prop | % { $_ | Select-String -Pattern '(?:[^-]*-){3}' } | % { $_.Matches } | % { $_.Value  -replace '.$' } | Sort
	
	if ($Interactive) {
		Write-ColorOutput yellow "Select which modification:"
		$parsed_modifications | % {$i=0} {"`t $($i+1)) $($_)"; $i++}
		Do {
			$selected = Read-Host -Prompt "Select"
			$validated = $false
			if ($selected -match '^[0-9]+$') {
				$selected = [int]$selected
				if ($selected -gt 0 -And $selected -le $parsed_modifications.Count) {
					$validated = $true
				}
			}
		}
		Until ($validated)
		$selected = $parsed_modifications | Select -Index $($selected - 1)
	}
	# Get latest minirootfs
	if (-not $Interactive) {
		$candidates = $parsed_modifications | Select-String -NoEmphasis -Pattern '.*miniroot.*'
		$found = $candidates | % { $_ -match '\d+\.\d+\.\d+_*\w*$' } | % {$matches[0]} | Sort -Unique
		$selected = $found.item($($found.Count - 1))
		$selected = $candidates | Select-String -Pattern "$selected"
	}
	
	$selected = $modifications | Where-Object -Property $prop -Like -Value "$selected*"
		
	#Download image
	$selmod = $selected | Select-Object -ExpandProperty $prop
	Invoke-WebRequest -Uri https://dl-cdn.alpinelinux.org/alpine/$($selver)releases/x86_64/$selmod -OutFile alpine.tar.gz
	
	return $true
}