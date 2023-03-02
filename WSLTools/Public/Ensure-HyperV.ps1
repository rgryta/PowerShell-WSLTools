function Ensure-HyperV 
{
	Param(
		[switch]$Install
	)
	try {
		$bios = Get-ComputerInfo -Property HyperVRequirementVirtualizationFirmwareEnabled | Select -Expand HyperVRequirementVirtualizationFirmwareEnabled
		$hvmissing = (Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online).State -ne "Enabled"
	}
	catch {
		Write-ColorOutput red "[ERROR] Elevated access needed to check HyperV settings"
		return $false
	}
	
	if ($bios -eq $false) {
		# Enabled can be either $true or $null
		Write-ColorOutput red "[ERROR] Virtualization disabled in BIOS"
		return $false
	}
	
	if ($Install -And $hvmissing) {
		if ((Get-WindowsEdition -Online).Edition -ne "Home"){
			Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Hyper-V-All
		}
		else {
			Write-ColorOutput yellow "[INFO] Windows Home Edition detected. Installing HyperV with DISM"
			Import-Module DISM
			$packages = (Get-ChildItem -Path $env:SystemRoot\servicing\Packages\*Hyper-V*.mum).Name
			ForEach ($line in $($packages -split "`r`n"))
			{
				Add-WindowsPackage -NoRestart -Online -IgnoreCheck -PackagePath $env:SystemRoot\servicing\Packages\$line
			}
			Enable-WindowsOptionalFeature -Online -LimitAccess -All -FeatureName Microsoft-Hyper-V
		}
		$hvmissing = $false
	}
	return -Not $hvmissing
}