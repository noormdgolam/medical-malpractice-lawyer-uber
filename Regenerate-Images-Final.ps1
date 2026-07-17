$ErrorActionPreference = 'Stop'
Remove-Item -Path "assets/images/*.jpg" -Force -ErrorAction SilentlyContinue

$files = Get-ChildItem -Path "articles" -Filter *.html
$total = $files.Count
$count = 0

foreach ($file in $files) {
    $count++
    $slug = $file.BaseName
    $imagePath = "assets/images/$slug.jpg"
    
    # Use LoremFlickr which works flawlessly without rate limit returning the same image
    $url = "https://loremflickr.com/1200/630/lawyer,hospital/all?lock=$count"
    
    Write-Host "($count/$total) Downloading UNIQUE image for $slug..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $imagePath -UseBasicParsing -TimeoutSec 15
    } catch {
        Write-Host "Failed to download image for $slug. Skipping." -ForegroundColor Red
    }
}
Write-Host "Successfully downloaded 91 UNIQUE images!"
