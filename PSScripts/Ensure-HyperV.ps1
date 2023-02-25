function Ensure-HyperV 
{
	Param(
		[switch]$Install
	)
	if (-Not $(Get-Command 'Ensure-PSDependency' -errorAction SilentlyContinue)) {
		throw "Ensure-PSDependency is not available"
	}
	
	if (-Not $(Get-Command 'Write-ColorOutput' -errorAction SilentlyContinue)) {
		"Write-ColorOutput" | Ensure-PSDependency
		. "$(Get-Location)\PSDependencies\Write-ColorOutput.ps1"
	}
	
	$hvmissing = (Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online).State -ne "Enabled"
	
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