function Ensure-NewPS
{
	Param(
		[switch]$Git = $false,
		[switch]$Install,
		[switch]$Interactive = $false
	)
	if (-not $Git) {
		try {
			if ($(Get-AppxPackage -Name Microsoft.PowerShell*) -eq $null) {
				if ($Install) {
					$selected = "Release"
					Write-Output "text"
					if ($Interactive) {
						$Options = "Release", "Preview"
						$selected = Get-Select -Prompt "[OPER] Select which PowerShell version you'd like to install:" -Options $Options
					}
					if ($selected -eq "Release") {
						winget install 9MZ1SNWT0N5D --source msstore --accept-source-agreements --accept-package-agreements
					}
					if ($selected -eq "Preview") {
						winget install 9P95ZZKTNRN4 --source msstore --accept-source-agreements --accept-package-agreements
					}
					return $true
				}
				else {
					return $false
				}
			}
			$ignr = winget upgrade 9MZ1SNWT0N5D
			$ignr = winget upgrade 9P95ZZKTNRN4
			return $true
		}
		catch {
			Write-ColorOutput red "[ERROR] Elevated access needed to check WSL settings or installation"
			return $false
		}
	}
	
	if ($Git) {
		$response = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases"
		
		$psvs = $response | % { New-Object System.Version ($_.tag_name -replace '-preview' -replace '-rc' -replace 'v') } | Sort -Descending
		
		if ($Interactive) {
			$selected = Get-Select -Prompt "[OPER] Select which PowerShell version you'd like to install:" -Options $psvs
		}
		if (-not $Interactive) {
			$selected = $psvs.item(0)
		}
		
		$candidates = $response | Where-Object {$($_.tag_name -replace '-preview' -replace '-rc') -Like "*$selected*"} | Select -Expand tag_name
		
		$selected = $candidates
		if ($candidates.Count -ne $null -And $candidates.Count -ne 1) {
			if ($Interactive) {
				$selected = Get-Select -Prompt "[OPER] Select which PowerShell release you'd like to install:" -Options $candidates
			}
			if (-not $Interactive) {
				$selected = $candidates | Where-Object { $_ -match 'v(\d\.){3}' }
				if ($selected -eq $null) {
					$selected = $candidates | Where-Object { $_ -match 'v(\d\.){2}\d\-rc' }
				}
				if ($selected -eq $null) {
					$selected = $candidates | Where-Object { $_ -match 'v(\d\.){2}\d\-preview' }
				}
			}
		}
		
		$selected = $response | Where-Object { $($_.tag_name -eq "$selected") }
		
		$available = $selected.assets | Where-Object {$_.browser_download_url -like '*.msi'}
		
		$is64 = [Environment]::Is64BitOperatingSystem
		
		if ($candidates.Count -ne $null) {
			if ($Interactive -And $is64) {
				$selected = Get-Select -Prompt "[OPER] Select whether you need 64bit or 32bit:" -Options $($available.name)
				$selected = $available | Where-Object { $_.name -eq "$selected" }
			}
			if (-not ($Interactive -And $is64)) {
				if ($is64) {
					$selected = $available | Where-Object { $_.name -like '*x64.msi' }
				}
				if (-not $is64) {
					$selected = $available | Where-Object { $_.name -like '*x86.msi' }
				}
			}
		}
		
		New-Item -ItemType directory -Path "$(Get-Location)\tmp" -ErrorAction SilentlyContinue | Out-Null
		$ProgressPreference = 'SilentlyContinue'
		Invoke-WebRequest -Uri $selected.browser_download_url -OutFile "$(Get-Location)\tmp\PowerShell.msi"
		
		if ($Install) {
			Start-Process msiexec.exe -Wait -NoNewWindow -ArgumentList "/I ""$(Get-Location)\tmp\PowerShell.msi"" /norestart"
		}
		Remove-Item -Path "$(Get-Location)\tmp" -Recurse | Out-Null
	}
	
	return $true
}