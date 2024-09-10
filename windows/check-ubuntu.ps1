$console = ([console]::OutputEncoding)
[console]::OutputEncoding = New-Object System.Text.UnicodeEncoding
$distroArray = (wsl -l -v | Select-String -SimpleMatch 'Ubuntu') -split '\s+'
[console]::OutputEncoding = $console

if ($distroArray -contains 'Ubuntu') {
    Write-Output "Ubuntu is installed"
    exit 0
} else {
    Write-Output "Ubuntu is not installed"
    exit 1
}
