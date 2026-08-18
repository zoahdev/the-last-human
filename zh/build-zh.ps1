# build-zh.ps1 - regenerates zh/book-zh.md from zh/volume-* folders
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$bookDir = Join-Path $root "volume-*"
$title = @(
  "# 最后的人类",
  "",
  "## 关于我们自身过时的一次理性论证",
  "",
  "*正典全集 · 中文版（翻译中）*",
  "",
  "> 宇宙不需要我们。它不需要任何人。那不是绝望；那是存在中最解放的事实。",
  "> —— 第二十章《剩下的是什么》",
  "",
  "---",
  "",
  "## 目录"
)
$toc = New-Object System.Collections.Generic.List[string]
$body = New-Object System.Collections.Generic.List[string]
$volumes = Get-ChildItem -LiteralPath $root -Directory | Where-Object { $_.Name -like 'volume-*' } | Sort-Object { [int](($_.Name -split '-')[1]) }
foreach ($vol in $volumes) {
    $volName = ($vol.Name -replace '^volume-(\d+)-', '卷 $1 · ' -replace '-', ' ')
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
Set-Content -LiteralPath (Join-Path $root "book-zh.md") -Value $joined -Encoding utf8
$raw = Get-Content -LiteralPath (Join-Path $root "book-zh.md") -Raw
$chars = ($raw -replace '\s', '').Length
Write-Host "book-zh.md rebuilt: $chars Chinese chars"
