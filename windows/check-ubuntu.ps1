$console = ([console]::OutputEncoding)
[console]::OutputEncoding = New-Object System.Text.UnicodeEncoding
$distroArray = (wsl -l -v | Select-String -SimpleMatch 'Ubuntu') -split '\s+'
[console]::OutputEncoding = $console

if ($distroArray -contains 'Ubuntu') {
    Write-Output "Ubuntu 已安装"
    exit 0
} else {
    Write-Output "Ubuntu 未安装"
    exit 1
}
