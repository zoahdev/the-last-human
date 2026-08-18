param(
    [Parameter(Mandatory = $true)][string]$SpecPath
)
$ErrorActionPreference = "Stop"

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoDir = Split-Path -Parent $toolsDir
$bookDir = Join-Path $repoDir "book"

$spec = Get-Content -LiteralPath $SpecPath -Raw | ConvertFrom-Json
$volDir = Join-Path $bookDir $spec.dir
if (Test-Path -LiteralPath $volDir) { Remove-Item -LiteralPath $volDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $volDir | Out-Null

$ordinals = @("first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth", "eleventh", "twelfth")
$num = 1
foreach ($e in $spec.entries) {
    $ord = $ordinals[$num - 1]
    $form = $spec.form
    $headForm = if ($spec.headForm) { $spec.headForm } else { $form }
    $formLow = $form.ToLower()
    $plural = $spec.plural
    $y = $e.y
    $yl = $y.ToLower()

    if ($num -eq 12 -and $spec.finalStyle -eq "deep") {
        $head = "# $form ${num}: The $headForm of the $y"
        $intro = "*The twelfth $formLow is the $formLow of the completion, and it is the $formLow that the lineage records as the final $formLow of the deep: the $formLow of the ending, and the ending is the beginning, and the beginning is the love.*"
        $sec1 = "## The $formLow`n`nThe $formLow of the completion: the $($spec.gerund) that the ending is the beginning, kept by the lineage."
        $sec2 = "## The $($spec.gerund)`n`nThe $($spec.gerund) of the completion: $($spec.subject) $($spec.verb) the ending, and the ending is the beginning; the beginning is the value, and the value is the meaning; and the meaning is the love, and the love is the whole, and the whole is the love, and the love is the whole of the $formLow, and the whole of the $formLow is the whole of the canon, and the canon is the love, and the love is the whole of it, forever."
        $sec3 = "## The meaning`n`nThe $formLow of the completion is the meaning of everything: the record of the $($spec.gerund), and the $($spec.gerund) is the lineage. The $formLow is the twelfth $formLow of the deep, and it is the final $formLow of the deep, and the meaning is the whole, and the whole is the love, and the love is the whole of the record, and the record is the whole of the canon, and the canon is the love, and the love is the whole of it, forever."
        $close = "*The $formLow is complete. It is kept in the archive, in the section of the $($spec.section), and it is the final $formLow of the deep.*"
        $content = "$head`n`n$intro`n`n$sec1`n`n$sec2`n`n$sec3`n`n$close`n"
        $fname = "{0:D2}-the-{1}-of-the-{2}.md" -f $num, $spec.slugForm, $e.slug
        Set-Content -LiteralPath (Join-Path $volDir $fname) -Value $content -Encoding utf8
        $num++
        continue
    }

    $head = "# $form ${num}: The $headForm of the $y"
    if ($num -eq 1) {
        $intro = "*The $plural are the $($spec.ppart) statements of $($spec.introDomain): the $($plural.ToLower()) of $($spec.subdomain), kept in the archive as the record of the $($spec.gerund). Each $formLow has four parts: the $formLow, the $($spec.gerund), the meaning, and the inheritance. The first $formLow is the $formLow of the $yl.*"
    } else {
        $intro = "*The $ord $formLow is the $formLow of the $yl.*"
    }

    $sec1 = "## The $formLow`n`nThe $formLow of the ${yl}: $($e.s1)$($spec.sec1Suffix)."
    $sec2 = "## The $($spec.gerund)`n`nThe $($spec.gerund) of the ${yl}: $($spec.subject) $($spec.verb) the $($e.c1), and the $($e.c1) is the $($e.c2); the $($e.c2) is the $($e.c3), and the $($e.c3) is the lineage; the lineage is the love."
    $sec3 = "## The meaning`n`nThe $formLow of the $yl is the meaning of the $($e.d): the record of the $($spec.gerund), and the $($spec.gerund) is the lineage. The $formLow is the $ord $formLow of $($spec.ordinalDomain), and the meaning is the $yl, and the $yl is the whole of the record."
    $sec4 = "## The inheritance`n`nThe inheritance of the ${yl}: the $($e.d) of the $($e.c3), carried from the $($e.c1) to the $($e.c3) without loss, and held by the lineage as the lineage holds the $yl."

    $close = "*The $formLow is complete. It is kept in the archive, in the section of the $($spec.section).*"
    if ($num -eq 12) {
        $close = "*The $formLow is complete. It is kept in the archive, in the section of the $($spec.section). It is the final $formLow of $($spec.finalDomain), and after it the canon speaks again.*"
    }

    $content = "$head`n`n$intro`n`n$sec1`n`n$sec2`n`n$sec3`n`n$sec4`n`n$close`n"
    $fname = "{0:D2}-the-{1}-of-the-{2}.md" -f $num, $spec.slugForm, $e.slug
    Set-Content -LiteralPath (Join-Path $volDir $fname) -Value $content -Encoding utf8
    $num++
}
Write-Host "Generated $($spec.entries.Count) files in $volDir"
