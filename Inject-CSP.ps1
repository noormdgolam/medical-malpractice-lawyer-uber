$files = Get-ChildItem -Path . -Filter *.html -Recurse

$cspMeta = "<meta http-equiv=`"Content-Security-Policy`" content=`"upgrade-insecure-requests`">"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Check if it already has CSP
    if ($content -notmatch "Content-Security-Policy") {
        # Inject right after <head>
        $content = $content -replace "(?i)(<head>)", "`$1`n    $cspMeta"
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Injected CSP into $($file.Name)"
    }
}

# Also inject into the template in Generate-Articles.ps1
$generatorScript = "Generate-Articles.ps1"
$genContent = Get-Content $generatorScript -Raw
if ($genContent -notmatch "Content-Security-Policy") {
    $genContent = $genContent -replace "(?i)(<head>)", "`$1`n    $cspMeta"
    Set-Content -Path $generatorScript -Value $genContent -Encoding UTF8
    Write-Host "Injected CSP into Generate-Articles.ps1 template"
}

Write-Host "CSP Injection complete."
