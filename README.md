# Medical Malpractice Lawyer Guide - Static Website

This repository contains the source code for the pre-built static HTML website `medical-malpractice-lawyer-uber.bongshai.com`. 
It is built with pure semantic HTML5, Vanilla CSS, and minimal JS.

## Deploying to cPanel
This repository contains a `.cpanel.yml` file. When you connect this Git repository to cPanel's Git™ Version Control feature, every `git push` to the main branch will automatically deploy the files directly to the `public_html/medical-malpractice-lawyer-uber` directory without any manual copying.

## Adding New Articles
Because this site does not rely on a complex Node.js/build pipeline (to keep it completely tech-stack free), adding a new article means creating a new `.html` file.

1. Copy `articles/uber-lyft-medical-malpractice-lawyer.html` and rename it to your new keyword slug (e.g. `articles/average-settlement-uber-malpractice.html`).
2. Open the new file and update the `<title>`, `<meta description>`, JSON-LD schema, and `<h1>`.
3. Write your highly-researched, 1,000+ word original content inside the `<div class="article-content">`.
4. Add a link to your new article on the homepage (`index.html`) and inside the `sitemap.xml`.
5. Update `rss.xml` with the new item.

## Important Steps for Google AdSense & SEO
1. **Analytics:** Edit `index.html` (and all other HTML pages) to replace `G-XXXXXXXXXX` with your real Google Analytics 4 Measurement ID.
2. **AdSense:** Once you have 100+ pages of high quality, unique content published, apply for AdSense. Then, replace the AdSense Placeholder scripts with your real `ca-pub-XXXXXXXXX` tags.
3. **Search Console:** Submit `https://medical-malpractice-lawyer-uber.bongshai.com/sitemap.xml` to Google Search Console to get your pages indexed.
