$console = ([console]::OutputEncoding)
[console]::OutputEncoding = New-Object System.Text.UnicodeEncoding
$distroArray = (wsl -l -v | Select-String -SimpleMatch 'ASUS-Workbench') -split '\s+'
[console]::OutputEncoding = $console

if ($distroArray -contains 'ASUS-Workbench') {
    Write-Output "ASUS-Workbench is installed"
    exit 0
} else {
    Write-Output "ASUS-Workbench is not installed"
    exit 1
}
