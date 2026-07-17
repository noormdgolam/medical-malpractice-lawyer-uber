$ErrorActionPreference = 'Stop'
$apiKey = "<OPENAI_API_KEY>"
$apiUrl = "https://api.openai.com/v1/images/generations"

$files = Get-ChildItem -Path "articles" -Filter *.html
$total = $files.Count
$count = 0
$generatedCount = 0

foreach ($file in $files) {
    $count++
    $slug = $file.BaseName
    $imagePath = "assets/images/$slug.jpg"
    
    $imgFileInfo = Get-Item $imagePath
    
    # Check if image is less than 90KB (which means it's a random placeholder, not a high quality AI image)
    if ($imgFileInfo.Length -lt 90000) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match '<h1>(.*?)</h1>') {
            $title = $matches[1]
        } else {
            $title = $slug -replace '-', ' '
        }
        
        Write-Host "($count/$total) Generating DALL-E 3 image for: $title"
        
        $prompt = "A high-quality, professional, photorealistic web header image representing the legal topic: $title. Medical and legal themes, modern cinematic lighting, no text, safe for work."
        
        $body = @{
            model = "dall-e-3"
            prompt = $prompt
            n = 1
            size = "1024x1024"
        } | ConvertTo-Json
        
        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type"  = "application/json"
        }

        $retries = 3
        while ($retries -gt 0) {
            try {
                $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body -TimeoutSec 60
                $imageUrl = $response.data[0].url
                
                Invoke-WebRequest -Uri $imageUrl -OutFile $imagePath -UseBasicParsing -TimeoutSec 30
                Write-Host "Successfully generated using DALL-E 3." -ForegroundColor Green
                $generatedCount++
                break
            } catch {
                Write-Host "Error generating image for $slug. Retrying... ($retries left)" -ForegroundColor Red
                $retries--
                Start-Sleep -Seconds 5
            }
        }
    } else {
        Write-Host "Skipping $slug (Already successfully generated custom AI image)" -ForegroundColor DarkGray
    }
}
Write-Host "Finished! $generatedCount new DALL-E 3 images successfully generated and injected!"
