function WSL-Ubuntu-Install
{
	Param(
		[Parameter(Mandatory = $true)] [String]$Command,
		[switch]$Install
	)
	if (-Not $(Get-Command 'Ensure-PSDependency' -errorAction SilentlyContinue)) {
		throw "Ensure-PSDependency is not available"
	}
	
	if (-Not $(Get-Command 'Write-ColorOutput' -errorAction SilentlyContinue)) {
		"Write-ColorOutput" | Ensure-PSDependency
		. "$(Get-Location)\PSDependencies\Write-ColorOutput.ps1"
	}
	
	
	if ($Install) {
		Write-ColorOutput red $Command
		return 1
	}
	else {
		Write-ColorOutput red $Command
		return 0
	}
	
    # Getting Ubuntu:
	$x = (Invoke-WebRequest https://git.launchpad.net/cloud-images/+oci/ubuntu-base/refs/tags).ParsedHtml.getElementsByTagName("a") | Where-Object {$_.IHTMLAnchorElement_pathname -eq "cloud-images/+oci/ubuntu-base/tag/" -And $_.IHTMLAnchorElement_search -match  '.*(i386)|(amd64).*'}

	$z = (Invoke-WebRequest https://git.launchpad.net/cloud-images/+oci/ubuntu-base/tree/oci/blobs/sha256$($x.item(9).IHTMLAnchorElement_search)).ParsedHtml.getElementsByTagName("td") | Where-Object {$_.IHTMLElement_className -eq "ls-size"}

	$max = ($z | Measure-Object -Property IHTMLElement_innerText -maximum).maximum
	$el = $z | ? { $_.IHTMLElement_innerText -eq $max}
	$idx = [array]::IndexOf($z, $el)

	$z = (Invoke-WebRequest https://git.launchpad.net/cloud-images/+oci/ubuntu-base/tree/oci/blobs/sha256$y).ParsedHtml.getElementsByTagName("a") | Where-Object {$_.IHTMLElement_className -eq "ls-blob"} | Select-Object -Index $idx

	Invoke-WebRequest -Uri https://git.launchpad.net$($z.IHTMLAnchorElement_href -replace 'about:' -replace '/tree/','/plain/') -OutFile test.tar.gz
}