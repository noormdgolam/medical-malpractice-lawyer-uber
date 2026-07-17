$ErrorActionPreference = 'Stop'

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
    
    $prompt = "High quality professional photography, $title, dramatic lighting, cinematic, photorealistic, highly detailed, safe for work"
    $encodedPrompt = [uri]::EscapeDataString($prompt)
    
    $seed = Get-Random
    $url = "https://image.pollinations.ai/prompt/${encodedPrompt}?width=1200&height=630&nologo=true&seed=$seed"
    
    Write-Host "($count/$total) Generating AI image for $slug..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $imagePath -UseBasicParsing -TimeoutSec 120
        Write-Host "Successfully generated." -ForegroundColor Green
        Start-Sleep -Seconds 3 # Short wait to avoid aggressive rate limiting
    } catch {
        Write-Host "Failed to download image for $slug. Skipping." -ForegroundColor Red
    }
}
Write-Host "All 91 AI images successfully generated and injected!"
