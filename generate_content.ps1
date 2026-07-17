$GroqKeys = @(
    'gsk_placeholder_1',
    'gsk_placeholder_2',
    'gsk_placeholder_3',
    'gsk_placeholder_4',
    'gsk_placeholder_5',
    'gsk_placeholder_6',
    'gsk_placeholder_7'
)
$OpenAIKey = 'sk-proj-placeholder'

$ProgressFile = 'c:\Users\Maria\Documents\WEB\100-120\101\progress.json'
$ArticlesDir = 'c:\Users\Maria\Documents\WEB\100-120\101\articles'
$ImagesDir = 'c:\Users\Maria\Documents\WEB\100-120\101\assets\images'

$Progress = @{}
if (Test-Path $ProgressFile) {
    $Progress = Get-Content $ProgressFile | ConvertFrom-Json
}

$HtmlFiles = Get-ChildItem -Path $ArticlesDir -Filter *.html
$BatchLimit = 100
$Count = 0
$KeyIndex = 0

foreach ($File in $HtmlFiles) {
    if ($Count -ge $BatchLimit) {
        Write-Host "Batch limit of $BatchLimit reached. Please manually review the generated articles before continuing."
        break
    }

    $TitleKebab = $File.BaseName
    if ($Progress.$TitleKebab) {
        Write-Host "Skipping: $TitleKebab"
        continue
    }

    $TitleReadable = $TitleKebab -replace '-', ' '
    Write-Host 'Processing: ' $TitleReadable

    $CurrentKey = $GroqKeys[$KeyIndex]
    $KeyIndex = ($KeyIndex + 1) % $GroqKeys.Count

    $Headers = @{
        'Authorization' = 'Bearer ' + $CurrentKey
        'Content-Type' = 'application/json'
    }

    # Step 1: Generate Unique Brief
    $BriefPrompt = "You are an expert SEO strategist. Write a 3-bullet-point brief for an article titled '$TitleReadable'. Focus on specific facts, legal nuances, and unique angles not covered by generic articles."
    $BriefBody = @{
        model = 'llama-3.1-8b-instant'
        messages = @(
            @{ role = 'user'; content = $BriefPrompt }
        )
    } | ConvertTo-Json -Depth 10

    try {
        $BriefRes = Invoke-RestMethod -Uri 'https://api.groq.com/openai/v1/chat/completions' -Method Post -Headers $Headers -Body $BriefBody
        $Brief = $BriefRes.choices[0].message.content
        Write-Host ' -> Brief generated.'
    } catch {
        Write-Host ' -> Error generating brief: ' $_
        continue
    }

    # Step 2: Generate Article with strict structure
    $GroqPrompt = "You are an expert legal copywriter with 20 years of experience. Write a highly detailed, 1000+ word data-driven article about '$TitleReadable'. 
Follow this brief closely to ensure originality: 
$Brief

REQUIREMENTS:
- Do NOT output any markdown code blocks (like ```html). Output ONLY raw HTML.
- Use semantic HTML (h2, h3, p, ul).
- Include a 'Key Takeaways' summary box at the top (use <div class='key-takeaways'><ul>...</ul></div>).
- Include a Table of Contents linking to your H2s.
- Deep H2 and H3 hierarchies.
- Specific facts, real figures, and comparison tables.
- FAQ section at the bottom.
- Ensure all external links open in a new tab with rel='noopener noreferrer'.
- Do NOT include generic filler.
- NO <html>, <head>, or <body> tags. Just the HTML to go inside <article>."
    
    $GroqBody = @{
        model = 'llama-3.1-8b-instant'
        messages = @(
            @{ role = 'user'; content = $GroqPrompt }
        )
    } | ConvertTo-Json -Depth 10

    try {
        $Response = Invoke-RestMethod -Uri 'https://api.groq.com/openai/v1/chat/completions' -Method Post -Headers $Headers -Body $GroqBody
        $NewContent = $Response.choices[0].message.content
        $NewContent = $NewContent -replace '```html', '' -replace '```', ''

        # Insert Newsletter Opt-in after the second H2
        $PartsH2 = $NewContent -split '<h2'
        if ($PartsH2.Length -gt 2) {
            $NewsletterHtml = "<div class='newsletter-optin'><h3>Stay Informed</h3><p>Subscribe to our newsletter for the latest updates on medical malpractice law and rideshare injury rights.</p><form><input type='email' placeholder='Enter your email address' required><button type='button'>Subscribe</button></form></div>"
            # Reconstruct string
            $Reconstructed = $PartsH2[0] + '<h2' + $PartsH2[1] + '<h2' + $PartsH2[2] + $NewsletterHtml
            for ($i = 3; $i -lt $PartsH2.Length; $i++) {
                $Reconstructed += '<h2' + $PartsH2[$i]
            }
            $NewContent = $Reconstructed
        }

        # Inject Social Shares, Author, Sidebar, and Content into existing HTML template
        $HtmlContent = Get-Content $File.FullName -Raw -Encoding UTF8
        
        # Reliable split on the AdSense block end
        $SplitMarker = '</script>' + [char]13 + [char]10 + '            </div>'
        $FallbackMarker = '</script>' + [char]10 + '            </div>'
        
        $Parts = $HtmlContent -split $SplitMarker
        if ($Parts.Length -lt 2) {
            $Parts = $HtmlContent -split $FallbackMarker
        }

        if ($Parts.Length -ge 2) {
            $Prefix = $Parts[0] + $SplitMarker
            if ($Parts.Length -lt 2) { $Prefix = $Parts[0] + $FallbackMarker }

            $FooterSplit = $HtmlContent -split '</article>'
            if ($FooterSplit.Length -ge 2) {
                $FooterPart = '</article>' + $FooterSplit[1]
                
                $SocialShare = "<div class='social-share'><span>Share: </span><button class='share-btn'>X</button> <button class='share-btn'>Facebook</button> <button class='share-btn'>LinkedIn</button> <button class='share-btn'>Copy Link</button></div>"
                $AuthorByline = "<div class='author-byline'><p><strong>Author:</strong> Medical Malpractice Editorial Team | <strong>Last Updated:</strong> $(Get-Date -Format 'MM/dd/yyyy')</p></div>"
                $Sidebar = "<aside class='similar-items'><h3>Similar Items</h3><ul><li><a href='./uber-lyft-medical-malpractice-lawyer.html'>Uber/Lyft Medical Malpractice Lawyer</a></li><li><a href='./average-settlement-for-uber-passenger-medical-malpractice.html'>Average Settlements</a></li><li><a href='./suing-lyft-and-the-hospital-for-wrongful-death.html'>Wrongful Death Claims</a></li></ul></aside>"
                
                $MidAdSense = "<div class='ad-slot mid-article'><ins class='adsbygoogle' style='display:block; text-align:center;' data-ad-layout='in-article' data-ad-format='fluid' data-ad-client='ca-pub-1234567890123456' data-ad-slot='1234567894'></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script></div>"

                $BottomAdSense = "<div class='ad-slot bottom-article'><ins class='adsbygoogle' style='display:block' data-ad-client='ca-pub-1234567890123456' data-ad-slot='1234567895' data-ad-format='auto' data-full-width-responsive='true'></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script></div>"

                # Layout: Prefix -> Social -> Author -> Content + Mid Ad -> Sidebar -> Bottom Ad -> Footer
                $NewHtml = $Prefix + [char]10 + $SocialShare + [char]10 + $AuthorByline + [char]10 + $NewContent + [char]10 + $MidAdSense + [char]10 + $Sidebar + [char]10 + $BottomAdSense + [char]10 + $FooterPart
                
                Set-Content -Path $File.FullName -Value $NewHtml -Encoding UTF8
                Write-Host ' -> Content updated.'
            }
        }
    } catch {
        Write-Host ' -> Error generating content: ' $_
        continue
    }

    # Step 3: Check/Generate Image
    $ImagePath = Join-Path $ImagesDir ($TitleKebab + '.jpg')
    if (-not (Test-Path $ImagePath)) {
        Write-Host ' -> Missing image, generating...'
        $ImagePrompt = 'A professional, photorealistic dramatic legal and medical conceptual image representing: ' + $TitleReadable + '. High quality, no text.'
        $ImageBody = @{
            model = 'dall-e-3'
            prompt = $ImagePrompt
            n = 1
            size = '1024x1024'
        } | ConvertTo-Json

        $OpenAIHeaders = @{
            'Authorization' = 'Bearer ' + $OpenAIKey
            'Content-Type' = 'application/json'
        }

        try {
            $ImageRes = Invoke-RestMethod -Uri 'https://api.openai.com/v1/images/generations' -Method Post -Headers $OpenAIHeaders -Body $ImageBody
            $ImageUrl = $ImageRes.data[0].url
            Invoke-WebRequest -Uri $ImageUrl -OutFile $ImagePath
            Write-Host ' -> Image saved.'
        } catch {
            Write-Host ' -> Error generating image: ' $_
        }
    }

    $Progress | Add-Member -MemberType NoteProperty -Name $TitleKebab -Value $true -Force
    $Progress | ConvertTo-Json | Set-Content $ProgressFile -Encoding UTF8
    Write-Host ' -> Progress saved.'
    $Count++
}

Write-Host "Batch finished ($Count articles processed)."



