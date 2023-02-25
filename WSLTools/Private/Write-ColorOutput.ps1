function Write-ColorOutput($ForegroundColor)
{
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Host $args
    }
    else {
        $input | Write-Host
    }
    $host.UI.RawUI.ForegroundColor = $fc
}