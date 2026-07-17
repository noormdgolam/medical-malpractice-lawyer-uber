$prompt = "What are the most critical and up-to-date USA SEO techniques and Google AdSense placement strategies for a niche website about Medical Malpractice Law in 2024? Keep it concise and actionable."

$groqBody = @{
    model = "llama-3.1-8b-instant"
    messages = @(@{role="user";content=$prompt})
} | ConvertTo-Json -Depth 10

$cerebrasBody = @{
    model = "llama3.1-8b"
    messages = @(@{role="user";content=$prompt})
} | ConvertTo-Json -Depth 10

$geminiBody = @{
    contents = @(@{parts=@(@{text=$prompt})})
} | ConvertTo-Json -Depth 10

$scriptBlock = {
    param($apiName, $url, $headers, $body)
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
        return @{Name=$apiName; Response=$response}
    } catch {
        return @{Name=$apiName; Error=$_}
    }
}

$jobs = @()

# Groq
$jobs += Start-Job -ScriptBlock $scriptBlock -ArgumentList "Groq", "https://api.groq.com/openai/v1/chat/completions", @{Authorization="Bearer <GROQ_API_KEY>"; "Content-Type"="application/json"}, $groqBody

# Cerebras
$jobs += Start-Job -ScriptBlock $scriptBlock -ArgumentList "Cerebras", "https://api.cerebras.ai/v1/chat/completions", @{Authorization="Bearer <CEREBRAS_API_KEY>"; "Content-Type"="application/json"}, $cerebrasBody

# Gemini
$geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=<GEMINI_API_KEY>"
$jobs += Start-Job -ScriptBlock $scriptBlock -ArgumentList "Gemini", $geminiUrl, @{"Content-Type"="application/json"}, $geminiBody

Write-Host "Waiting for AI responses..."
Wait-Job -Job $jobs | Out-Null
$results = Receive-Job -Job $jobs

$outputString = ""
foreach ($res in $results) {
    $outputString += "## $($res.Name) Findings`n`n"
    if ($res.Error) {
        $outputString += "Error: $($res.Error)`n`n"
    } else {
        if ($res.Name -eq "Gemini") {
            $outputString += "$($res.Response.candidates[0].content.parts[0].text)`n`n"
        } else {
            $outputString += "$($res.Response.choices[0].message.content)`n`n"
        }
    }
}

Set-Content -Path "seo-research-results.txt" -Value $outputString
Write-Host "Research complete and saved to seo-research-results.txt"
