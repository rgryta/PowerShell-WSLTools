function Write-ColorOutput($ForegroundColor)
{
    # Getting Alpine:
	$x = (Invoke-WebRequest https://dl-cdn.alpinelinux.org/alpine/).ParsedHtml.getElementsByTagName("a") | Where-Object {$_.IHTMLAnchorElement_pathname -like "v*"}
	$z = (Invoke-WebRequest https://dl-cdn.alpinelinux.org/alpine/$($x.item(9) | Select-Object -ExpandProperty IHTMLAnchorElement_pathname)releases/x86_64/).ParsedHtml.getElementsByTagName("a") | Where-Object {$_.IHTMLAnchorElement_pathname -like "*.tar.gz"}


	Invoke-WebRequest -Uri https://dl-cdn.alpinelinux.org/alpine/$($x.item(9) | Select-Object -ExpandProperty IHTMLAnchorElement_pathname)releases/x86_64/$($z | Select -Index 0 | Select-Object -ExpandProperty IHTMLAnchorElement_pathname) -OutFile test.tar.gz
}