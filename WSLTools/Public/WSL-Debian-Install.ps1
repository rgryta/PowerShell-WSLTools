function WSL-Debian-Install
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
	
	# Get which debian version
	$debian_vs = "bookworm","bullseye","buster"
	if ($Interactive) {
		$version = Get-Select -Prompt "[OPER] Select which Debian distribution you'd like to install:" -Options $debian_vs
	}
	# Get latest
	if (-not $Interactive) {
		$version = "buster"
	}
	
	$debian_vs = "full","slim"
	if ($Interactive) {
		$subselected = Get-Select -Prompt "[OPER] Full or slim (reduced size, e.g. man pages):" -Options $debian_vs
	}
	# Get latest
	if (-not $Interactive) {
		$subselected = "full"
	}
	
	if ($subselected -eq "full") {
		$subversion = ""
	}
	if (-not ($subselected -eq "full")) {
		$subversion = "/slim"
	}
	
	New-Item -ItemType directory -Path "$(Get-Location)\tmp" -ErrorAction SilentlyContinue | Out-Null
	$ProgressPreference = 'SilentlyContinue'
	Invoke-WebRequest -Uri https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-amd64/$version$subversion/rootfs.tar.xz -OutFile  "$(Get-Location)\tmp\$($DistroAlias).tar.xz"
	
	wsl --import $DistroAlias $InstallPath "$(Get-Location)\tmp\$($DistroAlias).tar.xz"
	Remove-Item -Path "$(Get-Location)\tmp" -Recurse | Out-Null
	
	wsl -d $DistroAlias -u root -e sh -c 'apt-get update && apt-get upgrade -y'
	
	return $true
}