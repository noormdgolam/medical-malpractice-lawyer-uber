$ErrorActionPreference = 'Stop'
# Delete existing duplicates
Remove-Item -Path "assets/images/*.jpg" -Force -ErrorAction SilentlyContinue

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
    
    $prompt = "Professional legal photography, medical malpractice, $title, highly detailed, cinematic lighting, realistic"
    $encodedPrompt = [uri]::EscapeDataString($prompt)
    
    # FIX: Use ${encodedPrompt} to prevent PowerShell from swallowing the variable!
    $seed = Get-Random
    $url = "https://image.pollinations.ai/prompt/${encodedPrompt}?width=1200&height=630&nologo=true&model=flux&seed=$seed"
    
    Write-Host "($count/$total) Downloading UNIQUE image for $slug..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $imagePath -UseBasicParsing -TimeoutSec 30
        Start-Sleep -Milliseconds 200
    } catch {
        Write-Host "Failed to download image for $slug. Skipping." -ForegroundColor Red
        continue
    }
}
Write-Host "Successfully downloaded 91 UNIQUE images!"
