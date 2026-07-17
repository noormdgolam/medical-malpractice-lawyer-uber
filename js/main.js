document.addEventListener('DOMContentLoaded', () => {
    // Cookie Banner
    const cookieBanner = document.getElementById('cookie-banner');
    const acceptCookies = document.getElementById('accept-cookies');
    
    if (!localStorage.getItem('cookiesAccepted')) {
        cookieBanner.classList.add('show');
    }
    
    if (acceptCookies) {
        acceptCookies.addEventListener('click', () => {
            localStorage.setItem('cookiesAccepted', 'true');
            cookieBanner.classList.remove('show');
        });
    }

    // Service Worker Registration
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
            navigator.serviceWorker.register('/sw.js').then(registration => {
                console.log('SW registered: ', registration);
            }).catch(registrationError => {
                console.log('SW registration failed: ', registrationError);
            });
        });
    }
});
