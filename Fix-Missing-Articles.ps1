$ErrorActionPreference = 'Stop'
$apiKey = "<GROQ_API_KEY>"
$apiUrl = "https://api.groq.com/openai/v1/chat/completions"
$model = "llama-3.1-8b-instant"

# Find all articles that still have the old formatting (which means they failed)
$failedFiles = Get-ChildItem -Path "articles" -Filter *.html | Where-Object { 
    $content = Get-Content $_.FullName -Raw
    $content -match "class='key-takeaways'" 
}
Write-Host "Found $($failedFiles.Count) failed articles. Regenerating..."

$baseTemplate = @"
<!DOCTYPE html>
<html lang="en-US">
<head>
    <meta http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{TITLE}}</title>
    <meta name="description" content="Legal guide on {{TITLE}}.">
    <meta name="robots" content="index, follow">
    <link rel="stylesheet" href="/css/styles.css">
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "LegalService",
      "name": "Medical Malpractice Lawyer Guide",
      "url": "http://localhost:8080/articles/{{SLUG}}.html",
      "serviceType": "Medical Malpractice Law"
    }
    </script>
</head>
<body>
    <header>
        <div class="container header-inner">
            <a href="/" class="brand">Medical Malpractice Lawyer Guide</a>
            <nav>
                <ul>
                    <li><a href="/">Home</a></li>
                    <li class="dropdown">
                        <a href="javascript:void(0)" style="cursor: default;">Categories ▼</a>
                        <ul class="dropdown-content">
                            <li><a href="/sitemap.html">All Articles</a></li>
                            <li><a href="/articles/uber-lyft-medical-malpractice-lawyer.html">Uber Accidents</a></li>
                            <li><a href="/articles/lyft-accident-emergency-room-misdiagnosis.html">Lyft Accidents</a></li>
                            <li><a href="/articles/who-pays-for-medical-bills-if-a-surgeon-botches-an-uber-accident-surgery.html">Surgical Errors</a></li>
                            <li><a href="/articles/average-settlement-for-uber-passenger-medical-malpractice.html">Settlements</a></li>
                        </ul>
                    </li>
                    <li><a href="/about.html">About Us</a></li>
                    <li><a href="/contact.html">Contact</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <main class="container content-grid">
        <article class="content-main">
            <nav aria-label="breadcrumb" style="font-size: 0.875rem; margin-bottom: 1rem;">
                <ol style="list-style: none; display: flex; gap: 0.5rem; padding: 0;">
                    <li><a href="/" style="color: var(--primary-light);">Home</a> /</li>
                    <li aria-current="page">Articles /</li>
                    <li aria-current="page">Guide</li>
                </ol>
            </nav>

            <h1>{{TITLE}}</h1>
            <p style="color: var(--text-light); font-size: 0.875rem;">By Editorial Team | Last Updated: July 17, 2026</p>

            <img src="/assets/images/{{SLUG}}.jpg" class="featured-image" alt="{{TITLE}}">

            <div class="ad-slot" style="min-height: 90px; margin-bottom: 2rem;">
                <ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-1234567890123456" data-ad-slot="1234567893" data-ad-format="auto" data-full-width-responsive="true"></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
            </div>

            {{CONTENT}}

            <div class="ad-slot" style="min-height: 250px; margin-top: 2rem;">
                <ins class="adsbygoogle" style="display:block" data-ad-format="fluid" data-ad-layout-key="-fb+5w+4e-db+86" data-ad-client="ca-pub-1234567890123456" data-ad-slot="1234567894"></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
            </div>
        </article>

        <aside class="sidebar">
            <div class="sidebar-widget">
                <h3>Case Evaluation</h3>
                <p>Have you been injured due to medical negligence after a rideshare accident?</p>
                <a href="/contact.html" style="display: inline-block; background: var(--accent); color: white; padding: 0.75rem 1.5rem; border-radius: var(--radius); margin-top: 1rem;">Free Consultation</a>
            </div>
            <div class="sidebar-widget">
                <h3>Related Guides</h3>
                <ul>
                    <li><a href="/articles/who-pays-for-medical-bills-if-a-surgeon-botches-an-uber-accident-surgery.html">Surgeon Errors in Uber Crashes</a></li>
                    <li><a href="/articles/average-settlement-for-uber-passenger-medical-malpractice.html">Average Malpractice Settlements</a></li>
                    <li><a href="/articles/suing-lyft-and-the-hospital-for-wrongful-death.html">Wrongful Death Claims</a></li>
                </ul>
            </div>
        </aside>
    </main>

    <footer>
        <div class="container" style="text-align: center; color: var(--text-light);">
            <p>&copy; 2026 Medical Malpractice Lawyer Guide. All rights reserved.</p>
            <p style="margin-top: 0.5rem; font-size: 0.875rem;">
                <a href="/privacy-policy.html" style="color: var(--text-light);">Privacy Policy</a> | 
                <a href="/terms.html" style="color: var(--text-light);">Terms of Service</a> |
                <a href="/disclaimer.html" style="color: var(--text-light);">Disclaimer</a>
            </p>
        </div>
    </footer>
    <div id="cookieConsent" style="display:none; position:fixed; bottom:0; width:100%; background:var(--bg-alt); padding:1rem; text-align:center; border-top:1px solid var(--border); z-index:1000; box-shadow:0 -2px 10px rgba(0,0,0,0.1);">
        <p style="margin-bottom:1rem; color:var(--text);">We use cookies to enhance your browsing experience, serve personalized ads, and analyze our traffic. By clicking "Accept All", you consent to our use of cookies.</p>
        <button onclick="acceptCookies()" style="background:var(--accent); color:white; border:none; padding:0.5rem 1.5rem; border-radius:var(--radius); cursor:pointer; font-weight:bold; margin-right:1rem;">Accept All</button>
        <button onclick="document.getElementById('cookieConsent').style.display='none'" style="background:transparent; color:var(--text); border:1px solid var(--border); padding:0.5rem 1.5rem; border-radius:var(--radius); cursor:pointer; font-weight:bold;">Decline</button>
    </div>
    <script>
        if (!document.cookie.includes('cookieConsent=true')) {
            document.getElementById('cookieConsent').style.display = 'block';
        }
        function acceptCookies() {
            document.cookie = 'cookieConsent=true; max-age=31536000; path=/';
            document.getElementById('cookieConsent').style.display = 'none';
        }
    </script>
</body>
</html>
"@

$systemPrompt = "You are a seasoned Medical Malpractice Attorney writing a highly authoritative, empathetic, and deeply actionable legal guide for victims. Topic: '$keyword'. Output ONLY raw HTML. Start with an <h2> title. You MUST include actionable step-by-step advice (what to do in first 24 hours), explain evidentiary requirements, and include a realistic composite case study of a similar rideshare/hospital dual-liability settlement to anchor the article in reality. Do NOT wrap the entire output in a div. Use <h2>, <h3>, <ul>, <p>, and <blockquote> for case studies. Include at least two authoritative external links to .gov, .edu, or .org sources with target='_blank' rel='noopener noreferrer'. Output ONLY pure HTML."

foreach ($file in $failedFiles) {
    $slug = $file.BaseName
    $title = (Get-Culture).TextInfo.ToTitleCase(($slug -replace '-', ' '))
    $filePath = $file.FullName
    
    Write-Host "Regenerating missing content for: $title"
    
    $body = @{
        model = $model
        messages = @(
            @{
                role = "system"
                content = $systemPrompt.Replace('$keyword', $title)
            },
            @{
                role = "user"
                content = "Write the article HTML now for: $title"
            }
        )
        temperature = 0.5
    } | ConvertTo-Json -Depth 10

    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type"  = "application/json"
    }

    $retries = 5
    $success = $false
    while ($retries -gt 0 -and -not $success) {
        try {
            $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Post -Body $body -TimeoutSec 60
            $content = $response.choices[0].message.content.Trim()
            
            # Clean up potential markdown code blocks returned by LLM
            $content = $content -replace '^(?s)`html\r?\n', '' -replace '(?s)\r?\n`$', ''
            
            $html = $baseTemplate.Replace("{{TITLE}}", $title).Replace("{{SLUG}}", $slug).Replace("{{CONTENT}}", $content)
            
            Set-Content -Path $filePath -Value $html -Encoding UTF8
            Write-Host "Fixed $filePath" -ForegroundColor Green
            $success = $true
            
            # Add a 6 second delay to absolutely ensure we don't hit the RPM limit for Groq Free Tier
            Start-Sleep -Seconds 6 
        }
        catch {
            Write-Host "Rate limit or error. Retrying... ($retries left)" -ForegroundColor Red
            $retries--
            Start-Sleep -Seconds 10
        }
    }
}
Write-Host "Finished repairing all missing articles!"
