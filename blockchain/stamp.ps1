param(
    [string[]]$Targets
)
$ErrorActionPreference = 'Stop'
foreach ($file in $Targets) {
    if (-not (Test-Path -LiteralPath $file)) { Write-Output "MISSING: $file"; continue }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $fs = [System.IO.File]::OpenRead($file)
    $hash = $sha.ComputeHash($fs)
    $fs.Close()
    $digestFile = Join-Path $env:TEMP ("ots-digest-" + [guid]::NewGuid().ToString('N') + '.bin')
    [System.IO.File]::WriteAllBytes($digestFile, $hash)
    $otsFile = $file + '.ots'
    & curl.exe -s -X POST -H 'Content-Type: application/octet-stream' --data-binary "@$digestFile" 'https://a.pool.opentimestamps.org/digest' -o $otsFile
    Remove-Item -LiteralPath $digestFile -Force
    if (Test-Path -LiteralPath $otsFile) {
        $len = (Get-Item -LiteralPath $otsFile).Length
        Write-Output "$([System.IO.Path]::GetFileName($file)) -> $otsFile ($len bytes)"
    } else {
        Write-Output "STAMP FAILED: $file"
    }
}
