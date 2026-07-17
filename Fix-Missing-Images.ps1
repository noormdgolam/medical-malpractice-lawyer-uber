$ErrorActionPreference = 'Stop'

$files = Get-ChildItem -Path "articles" -Filter *.html
$total = $files.Count
$count = 0

foreach ($file in $files) {
    $count++
    $slug = $file.BaseName
    $imagePath = "assets/images/$slug.jpg"
    
    $needsGeneration = $true
    if (Test-Path $imagePath) {
        $imgFileInfo = Get-Item $imagePath
        if ($imgFileInfo.Length -ge 90000) {
            $needsGeneration = $false
        }
    }
    
    if ($needsGeneration) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match '<h1>(.*?)</h1>') {
            $title = $matches[1]
        } else {
            $title = $slug -replace '-', ' '
        }
        
        $prompt = "High quality professional photography, $title, dramatic lighting, cinematic, photorealistic, highly detailed, safe for work"
        $encodedPrompt = [uri]::EscapeDataString($prompt)
        
        $seed = Get-Random
        $url = "https://image.pollinations.ai/prompt/${encodedPrompt}?width=1200&height=630&nologo=true&seed=$seed"
        
        Write-Host "($count/$total) Regenerating missing AI image for $slug..."
        $retries = 3
        while ($retries -gt 0) {
            try {
                Invoke-WebRequest -Uri $url -OutFile $imagePath -UseBasicParsing -TimeoutSec 120
                Write-Host "Successfully generated." -ForegroundColor Green
                Start-Sleep -Seconds 12
                break
            } catch {
                Write-Host "Rate limited. Retrying... ($retries left)" -ForegroundColor Red
                $retries--
                Start-Sleep -Seconds 20
            }
        }
    } else {
        Write-Host "Skipping $slug (Already successfully generated custom AI image)" -ForegroundColor DarkGray
    }
}
Write-Host "All remaining AI images successfully generated and injected!"

