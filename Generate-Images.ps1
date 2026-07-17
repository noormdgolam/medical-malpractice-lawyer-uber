$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path "assets/images" | Out-Null

$files = Get-ChildItem -Path "articles" -Filter *.html
$total = $files.Count
$count = 0

foreach ($file in $files) {
    $count++
    $slug = $file.BaseName
    $imagePath = "assets/images/$slug.jpg"
    
    $content = Get-Content $file.FullName -Raw
    
    # Extract title
    if ($content -match '<h1>(.*?)</h1>') {
        $title = $matches[1]
    } else {
        $title = $slug -replace '-', ' '
    }
    
    # Generate image if it doesn't exist
    if (-not (Test-Path $imagePath)) {
        $prompt = "Professional legal photography, medical malpractice, $title, highly detailed, cinematic lighting, realistic, safe for work"
        $encodedPrompt = [uri]::EscapeDataString($prompt)
        $url = "https://image.pollinations.ai/prompt/$encodedPrompt?width=1200&height=630&nologo=true&model=flux"
        
        Write-Host "($count/$total) Downloading image for $slug..."
        try {
            Invoke-WebRequest -Uri $url -OutFile $imagePath -UseBasicParsing -TimeoutSec 30
        } catch {
            Write-Host "Failed to download image for $slug. Skipping." -ForegroundColor Red
            continue
        }
    }
    
    # Inject image tag into HTML if not present
    if ($content -notmatch 'class="featured-image"') {
        $imgTag = "<img src="/assets/images/$slug.jpg" class="featured-image" alt="$title">
"
        
        # Inject after the Editorial Team paragraph
        $content = $content -replace '(<p style="color: var\(--text-light\); font-size: 0\.875rem;">.*?<\/p>)', "$1

            $imgTag"
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
    }
}
Write-Host "All images downloaded and injected!"
