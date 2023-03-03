function WSL-Ubuntu-Install
{
	Param(
		[switch]$Interactive = $false,
		[Parameter(Mandatory = $true)] [String]$DistroAlias,
		[String]$Version,
		[String]$InstallPath
	)
	try {
		$wsl = Ensure-WSL
	}
	catch {
		Write-ColorOutput red "[ERROR] Elevated access needed to check WSL settings"
		throw "Elevated access required"
	}

	if (-not $wsl) {
		Write-ColorOutput red "[ERROR] WSL not installed"
		throw "WSL not installed"
	}
	
	if (-not($DistroAlias -match '^[^\s\\/]*$')) {
		Write-ColorOutput red "[ERROR] Provided DistroAlias contains whitespace or slash/backslash characters"
		throw "Incorrect DistroAlias"
	}
	
	if (-not($PSBoundParameters.ContainsKey('InstallPath'))) {
		$InstallPath = "$(Get-Location)\install"
		New-Item -ItemType directory -Path $InstallPath -ErrorAction SilentlyContinue | Out-Null
	}
	
	if ($PSBoundParameters.ContainsKey('InstallPath')) {
		if (Test-Path -Path $InstallPath) {
			if ( (Get-Item $InstallPath) -isnot [System.IO.DirectoryInfo]) {
				Write-ColorOutput red "[ERROR] Provided InstallPath is not a directory"
				throw "Incorrect InstallPath"
			}
		}
		if (-not(Test-Path -Path $InstallPath)) {
			Write-ColorOutput red "[ERROR] Provided InstallPath is does not exist"
			throw "Incorrect InstallPath"
		}
	}
	
	# Get all ubuntu versions
	Do {
		$ihtml, $versions = Invoke-WebParseable -Uri https://git.launchpad.net/cloud-images/+oci/ubuntu-base/refs/tags
		if ($ihtml) {
			$prop = "IHTMLAnchorElement_pathname"
			$search = "IHTMLAnchorElement_search"
			$class = "IHTMLElement_className"
			$innerText = "IHTMLElement_innerText"
			$href = "IHTMLAnchorElement_href"
		}
		if (-not $ihtml) {
			$prop = "pathname"
			$search = "search"
			$class = "className"
			$innerText = "innerText"
			$href = "href"
		}
		
		$versions = $versions.getElementsByTagName("a")
		$parsed_versions = $versions | Where-Object {$_.$prop -eq "cloud-images/+oci/ubuntu-base/tag/" -And $_.$search -match  '.*(i386)|(amd64).*'}
		
		$parsed_versions = $parsed_versions | % {Write-Output $($_.$search | Select-String -Pattern 'dist\-\w+\-(i386|amd64)-\d+' )} | % { $_.Matches } | % { $_.Value } 
	
	}
	Until ($parsed_versions.Count -gt 0)
	
	if ($Interactive) {
		$selected = Get-Select -Prompt "[OPER] Select which Ubuntu distribution you'd like to install:" -Options $parsed_versions
	}
	# Get latest
	if (-not $Interactive) {
		if (-not($PSBoundParameters.ContainsKey('Version'))) {
			$Version = "lunar"
		}
		$selected = $parsed_versions | Select-String -Pattern "dist-$Version.*" | Select-Object -Index 0
	}
	$selected = "?h=$selected"
	Do {
		try {
			# Trusty and Xenial have no OCI images
			if ($selected -match '.*(trusty)|(xenial).*') {
				$ihtml, $blobs = Invoke-WebParseable -Uri https://git.launchpad.net/cloud-images/+oci/ubuntu-base/tree/$selected
				$blob = $blobs.getElementsByTagName("a") | Where-Object {$_.href -match '.*plain.*\.tar\.gz.*'}
			}
			if (-not ($selected -match '.*(trusty)|(xenial).*')) {
				$ihtml, $blobs = Invoke-WebParseable -Uri https://git.launchpad.net/cloud-images/+oci/ubuntu-base/tree/oci/blobs/sha256$selected
				$sizes = $blobs.getElementsByTagName("td")| Where-Object {$_.$class -eq "ls-size"}
				$max = ($sizes | Measure-Object -Property $innerText -maximum).maximum
						
				$el = $sizes | ? { $_.$innerText -eq $max}
				$idx = [array]::IndexOf($sizes, $el)
				
				$blob = $blobs.getElementsByTagName("a") | Where-Object {$_.$class -eq "ls-blob"} | Select-Object -Index $idx
			}
			$found = $true
		}
		catch {}
	}
	Until ($found)
	
	New-Item -ItemType directory -Path "$(Get-Location)\tmp" -ErrorAction SilentlyContinue | Out-Null
	$ProgressPreference = 'SilentlyContinue'
	Invoke-WebRequest -Uri https://git.launchpad.net$($blob.$href -replace 'about:' -replace '/tree/','/plain/') -OutFile  "$(Get-Location)\tmp\$($DistroAlias).tar.gz"
	
	wsl --import $DistroAlias $InstallPath "$(Get-Location)\tmp\$($DistroAlias).tar.gz"
	Remove-Item -Path "$(Get-Location)\tmp" -Recurse | Out-Null
	
	wsl -d $DistroAlias -u root -e sh -c 'apt-get update && apt-get upgrade -y'
	
	return $true
}