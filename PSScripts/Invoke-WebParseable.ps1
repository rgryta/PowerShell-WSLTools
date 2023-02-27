function Invoke-WebParseable
{
	Param(
		[Parameter(Mandatory = $true)] [String]$Uri
	)
	$response = (Invoke-WebRequest $Uri -UseBasicParsing).Content
	$HTML = New-Object -Com "HTMLFile"
	try {
		$HTML.IHTMLDocument2_write($response)
		
		$ihtml = $true
		$response = $HTML
	}
	catch {
		$ihtml = $false
		
		$src = [System.Text.Encoding]::Unicode.GetBytes($response)
		$HTML.write($src)
		$response = $HTML.body
	}
	
	return $ihtml, $response
}