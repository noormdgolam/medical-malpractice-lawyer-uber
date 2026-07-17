$domain = "https://medical-malpractice-lawyer-uber.bongshai.com"
$articlesDir = "articles"
$files = Get-ChildItem -Path $articlesDir -Filter *.html

$articlesData = @()

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $title = ""
    $desc = ""
    
    if ($content -match "<title>(.*?)</title>") { $title = $matches[1] }
    if ($content -match '<meta name="description" content="(.*?)">') { $desc = $matches[1] }
    
    $articlesData += @{
        Title = $title
        Desc = $desc
        Url = "$domain/$articlesDir/$($file.Name)"
        Path = "/$articlesDir/$($file.Name)"
        Date = $file.LastWriteTime
    }
}

# Sort by newest
$articlesData = $articlesData | Sort-Object Date -Descending

# 1. Build sitemap.xml
$sitemapPath = "sitemap.xml"
$sitemap = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n"
$sitemap += "  <url>`n    <loc>$domain/</loc>`n    <lastmod>$(Get-Date -Format 'yyyy-MM-dd')</lastmod>`n    <changefreq>daily</changefreq>`n    <priority>1.0</priority>`n  </url>`n"
$sitemap += "  <url>`n    <loc>$domain/about.html</loc>`n    <priority>0.5</priority>`n  </url>`n"

foreach ($article in $articlesData) {
    $sitemap += "  <url>`n    <loc>$($article.Url)</loc>`n    <lastmod>$($article.Date.ToString('yyyy-MM-dd'))</lastmod>`n    <changefreq>monthly</changefreq>`n    <priority>0.8</priority>`n  </url>`n"
}
$sitemap += "</urlset>"
Set-Content -Path $sitemapPath -Value $sitemap -Encoding UTF8
Write-Host "Updated sitemap.xml"

# 2. Build rss.xml
$rssPath = "rss.xml"
$rss = "<?xml version=`"1.0`" encoding=`"UTF-8`" ?>`n<rss version=`"2.0`">`n<channel>`n"
$rss += "  <title>Medical Malpractice Lawyer Guide</title>`n"
$rss += "  <link>$domain/</link>`n"
$rss += "  <description>Expert legal insights on medical malpractice in Uber/Lyft accidents.</description>`n"

foreach ($article in $articlesData) {
    $rss += "  <item>`n    <title><![CDATA[$($article.Title)]]></title>`n    <link>$($article.Url)</link>`n    <description><![CDATA[$($article.Desc)]]></description>`n  </item>`n"
}
$rss += "</channel>`n</rss>"
Set-Content -Path $rssPath -Value $rss -Encoding UTF8
Write-Host "Updated rss.xml"

# 3. Update index.html featured articles
$indexHtmlPath = "index.html"
$indexHtml = Get-Content $indexHtmlPath -Raw

$featuredHtml = "`n"
$count = 0
foreach ($article in $articlesData) {
    if ($count -ge 5) { break }
    $featuredHtml += @"
                    <article class="article-card">
                        <div class="article-card-content">
                            <h3><a href="$($article.Path)" style="text-decoration:none; color:inherit;">$($article.Title)</a></h3>
                            <p>$($article.Desc)</p>
                            <a href="$($article.Path)" class="btn" style="padding: 0.5rem 1rem; font-size: 0.875rem;">Read More</a>
                        </div>
                    </article>
"@ + "`n"
    $count++
}

$regex = "(?s)(<!-- DYNAMIC_ARTICLES_START -->).*?(<!-- DYNAMIC_ARTICLES_END -->)"
if ($indexHtml -match $regex) {
    $newIndex = $indexHtml -replace $regex, "`$1$featuredHtml                    `$2"
    Set-Content -Path $indexHtmlPath -Value $newIndex -Encoding UTF8
    Write-Host "Updated index.html featured articles"
}

# 4. Build sitemap.html
$htmlSitemapPath = "sitemap.html"
$htmlSitemap = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HTML Sitemap - Medical Malpractice Lawyer Guide</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <header>
        <div class="container header-inner">
            <a href="/" class="brand">Medical Malpractice Lawyer Guide</a>
        </div>
    </header>
    <main class="container" style="padding: 4rem 1.5rem;">
        <h1>HTML Sitemap</h1>
        <p>A complete list of all our legal guides and resources.</p>
        <ul style="margin-top: 2rem; line-height: 2;">
"@

foreach ($article in $articlesData) {
    $htmlSitemap += "            <li><a href=`"$($article.Path)`">$($article.Title)</a></li>`n"
}

$htmlSitemap += @"
        </ul>
    </main>
</body>
</html>
"@
Set-Content -Path $htmlSitemapPath -Value $htmlSitemap -Encoding UTF8
Write-Host "Updated sitemap.html"

Write-Host "Indexing complete!"
