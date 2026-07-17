$files = Get-ChildItem -Path . -Filter *.html -Recurse

$oldNav = @"
                <ul>
                    <li><a href="/">Home</a></li>
                    <li><a href="/about.html">About Us</a></li>
                    <li><a href="/contact.html">Contact</a></li>
                </ul>
"@

$newNav = @"
                <ul>
                    <li><a href="/">Home</a></li>
                    <li class="dropdown">
                        <a href="javascript:void(0)" style="cursor: default;">Categories ▼</a>
                        <ul class="dropdown-content">
                            <li><a href="/articles/uber-lyft-medical-malpractice-lawyer.html">Uber Accidents</a></li>
                            <li><a href="/articles/lyft-accident-emergency-room-misdiagnosis.html">Lyft Accidents</a></li>
                            <li><a href="/articles/who-pays-for-medical-bills-if-a-surgeon-botches-an-uber-accident-surgery.html">Surgical Errors</a></li>
                            <li><a href="/articles/average-settlement-for-uber-passenger-medical-malpractice.html">Settlements</a></li>
                        </ul>
                    </li>
                    <li><a href="/about.html">About Us</a></li>
                    <li><a href="/contact.html">Contact</a></li>
                </ul>
"@

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "\s*<ul>\s*<li><a href=`"/`">Home</a></li>\s*<li><a href=`"/about\.html`">About Us</a></li>\s*<li><a href=`"/contact\.html`">Contact</a></li>\s*</ul>") {
        $content = $content -replace "\s*<ul>\s*<li><a href=`"/`">Home</a></li>\s*<li><a href=`"/about\.html`">About Us</a></li>\s*<li><a href=`"/contact\.html`">Contact</a></li>\s*</ul>", $newNav
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Updated $($file.Name)"
    }
}
Write-Host "Nav update complete!"


