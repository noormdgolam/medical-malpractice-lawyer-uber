$files = Get-ChildItem -Path . -Include *.html,*.xml,*.json -Recurse
$allValidPaths = @()
$errors = 0

# Collect all valid internal paths
foreach ($f in $files) {
    # Convert absolute path to web-relative path
    $relPath = $f.FullName.Replace((Get-Location).Path, "").Replace("\", "/")
    if ($relPath -eq "/index.html") {
        $allValidPaths += "/"
    }
    $allValidPaths += $relPath
}
# Allow root
$allValidPaths += "/"

# Scan each file for links
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $matches = [regex]::Matches($content, 'href="(.*?)"')
    
    foreach ($match in $matches) {
        $link = $match.Groups[1].Value
        
        # Skip external, hash links, mailto, etc.
        if ($link -match "^http" -or $link -match "^#" -or $link -match "^mailto:" -or $link -match "^javascript:") {
            continue
        }
        
        # Check internal links
        if ($link -eq "/css/styles.css" -or $link -match "/js/") {
            continue # Skip asset links for this check
        }
        
        if ($allValidPaths -notcontains $link) {
            Write-Host "[ERROR] Broken link found in $($file.Name): '$link'" -ForegroundColor Red
            $errors++
        }
    }
}

if ($errors -eq 0) {
    Write-Host "Success! Zero broken internal links found across $($files.Count) HTML files." -ForegroundColor Green
} else {
    Write-Host "Found $errors broken link(s)." -ForegroundColor Yellow
}
