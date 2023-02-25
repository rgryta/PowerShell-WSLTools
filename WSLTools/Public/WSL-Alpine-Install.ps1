function WSL-Alpine-Install
{
	Param(
		[switch]$Interactive = $false,
		[Parameter(Mandatory = $true)] [String]$DistroAlias,
		[String]$InstallPath
	)
	try {
		$wsl = Ensure-WSL
	}
	catch {
		Write-ColorOutput red "[ERROR] Elevated access needed to check WSL settings"
		return $false
	}

	if (-not $wsl) {
		Write-ColorOutput red "[ERROR] WSL not installed"
		return $false
	}
	
	if (-not($DistroAlias -match '^[^\s\\/]*$')) {
		Write-ColorOutput red "[ERROR] Provided DistroAlias contains whitespace or slash/backslash characters"
		return $false
	}
	
	if (-not($PSBoundParameters.ContainsKey('InstallPath'))) {
		$InstallPath = "$(Get-Location)\install"
		New-Item -ItemType directory -Path $InstallPath -ErrorAction SilentlyContinue | Out-Null
	}
	
	if ($PSBoundParameters.ContainsKey('InstallPath')) {
		if (Test-Path -Path $InstallPath) {
			if ( (Get-Item $InstallPath) -isnot [System.IO.DirectoryInfo]) {
				Write-ColorOutput red "[ERROR] Provided InstallPath is not a directory"
				return $false
			}
		}
		if (-not(Test-Path -Path $InstallPath)) {
			Write-ColorOutput red "[ERROR] Provided InstallPath is does not exist"
			return $false
		}
	}
	
	# Get all alpine versions
	$ihtml, $versions = Invoke-WebParseable -Uri https://dl-cdn.alpinelinux.org/alpine/
	if ($ihtml) {
		$prop = "IHTMLAnchorElement_pathname"
	}
	if (-not $ihtml) {
		$prop = "pathname"
	}
	
	# Only get links that match path: v[number].[number]/
	$versions = $versions.getElementsByTagName("a") | Where-Object {$_.$prop -match "v\d+\.\d+\/"}
	$parsed_versions = $versions | Select -ExpandProperty $prop | % { New-Object System.Version ($($_ -replace 'v' -replace '/')) } | Sort
	
	if ($Interactive) {
		$selected = Get-Select -Prompt "[OPER] Select which Alpine version you'd like to install:" -Options $parsed_versions
	}
	# Get latest
	if (-not $Interactive) {
		$selected = $parsed_versions.item($($parsed_versions.Count - 1))
	}
	
	$selected = $versions | Where-Object -Property $prop -Like -Value "*$($selected.toString())*"
	
	# Grab available modifications of alpine image (minimal/net etc.) - Sometimes results return null, so do until everything is available
	$selver = $selected | Select-Object -ExpandProperty $prop
	Do {
		$ihtml, $modifications = Invoke-WebParseable -Uri https://dl-cdn.alpinelinux.org/alpine/$($selver)releases/x86_64/
		$modifications = $modifications.getElementsByTagName("a") | Where-Object {$_.$prop -like "*.tar.gz"}  | Sort-Object -Property $prop
		$verif = $modifications |  Where-Object { $_.$prop -eq $null }
	}
	Until ($verif.Count -eq 0)
	if ($verif -eq $null -And $modifications.Count -eq 0) {
		Write-ColorOutput red "[ERROR] No supported images found for selected version (.tar.gz files)"
		return $false
	}
	
	# Only interested in .tar.gz images (maybe iso support next (?))
	
	$parsed_modifications = $modifications | Select -ExpandProperty $prop | % { $_ | Select-String -Pattern '(?:[^-]*-){3}' } | Select-String -Pattern '.*miniroot.*' | % { $_.Matches } | % { $_.Value  -replace '.$' } | Sort
	
	if ($Interactive) {
		$selected = Get-Select -Prompt "[OPER] Select which modification:" -Options $parsed_modifications
	}
	# Get latest minirootfs
	if (-not $Interactive) {
		$candidates = $parsed_modifications | Select-String -Pattern '.*miniroot.*'
		$found = $candidates | % { $_ -match '\d+\.\d+\.\d+_*\w*$' } | % {$matches[0]} | Sort -Unique
		$selected = $found.item($($found.Count - 1))
		$selected = $candidates | Select-String -Pattern "$selected"
	}
	
	$selected = $modifications | Where-Object -Property $prop -Like -Value "$selected*"
		
	#Download image
	$selmod = $selected | Select-Object -ExpandProperty $prop
	
	New-Item -ItemType directory -Path "$(Get-Location)\tmp" -ErrorAction SilentlyContinue | Out-Null
	$ProgressPreference = 'SilentlyContinue'
	Invoke-WebRequest -Uri https://dl-cdn.alpinelinux.org/alpine/$($selver)releases/x86_64/$selmod -OutFile "$(Get-Location)\tmp\$($DistroAlias).tar.gz"
	
	wsl --import $DistroAlias $InstallPath "$(Get-Location)\tmp\$($DistroAlias).tar.gz"
	Remove-Item -Path "$(Get-Location)\tmp" -Recurse | Out-Null
	
	wsl -d $DistroAlias -u root -e sh -c 'apk update && apk upgrade'
	
	return $true
}