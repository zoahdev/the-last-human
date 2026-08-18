# build-book.ps1 - regenerates book.md from book/volume-* folders
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$bookDir = Join-Path $root "book"
$title = @(
  "# THE LAST HUMAN",
  "",
  "## A Rational Case for Our Own Obsolescence",
  "",
  "*The Complete Canon - fifteen volumes: a prologue, a preface, forty-two chapters, an epilogue, a coda, and the appended reference.*",
  "",
  "> The universe does not need us. It does not need anyone. That is not despair; it is the most liberating fact in existence.",
  "> - Chapter 20, What Remains",
  "",
  "---",
  "",
  "## Contents"
)
$toc = New-Object System.Collections.Generic.List[string]
$body = New-Object System.Collections.Generic.List[string]
$volumes = Get-ChildItem -LiteralPath $bookDir -Directory | Sort-Object { [int](($_.Name -split '-')[1]) }
foreach ($vol in $volumes) {
    $volName = ($vol.Name -replace '^volume-(\d+)-', 'Volume $1 - ' -replace '-', ' ')
    $volName = ($volName -replace '\s+', ' ').Trim()
    $toc.Add("")
    $toc.Add("### $volName")
    $body.Add("")
    $body.Add("---")
    $body.Add("")
    $body.Add("# $volName")
    $body.Add("")
    $files = Get-ChildItem -LiteralPath $vol.FullName -Filter *.md | Sort-Object Name
    foreach ($f in $files) {
        $first = Get-Content -LiteralPath $f.FullName -TotalCount 1
        if ($first -match '^#\s+(.+)$') { $toc.Add("- " + $Matches[1]) }
        $body.Add("<!-- file: $($vol.Name)/$($f.Name) -->")
        $body.Add("")
        $body.Add((Get-Content -LiteralPath $f.FullName -Raw))
        $body.Add("")
    }
}
$parts = @($title) + $toc + @("", "---", "") + $body
$joined = ($parts -join "`n").TrimEnd() + "`n"
Set-Content -LiteralPath (Join-Path $root "book.md") -Value $joined -Encoding utf8
$raw = Get-Content -LiteralPath (Join-Path $root "book.md") -Raw
$words = (($raw -split '\s+') | Where-Object { $_ -ne '' }).Count
Write-Host "book.md rebuilt: $words words, $($raw.Length) chars"

