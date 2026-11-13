//! # Privacy Page
//!
//! Plain-language notice describing the cookie-less analytics on this site.

use leptos::prelude::*;

use super::nav::Nav;
use super::BackgroundGallery;

/// The privacy notice. Keep this in step with `everythingsings-analytics` (what it stores, and for how long).
#[component]
pub fn PrivacyPage() -> impl IntoView {
    view! {
        <body itemscope itemtype="https://schema.org/WebPage">
            <canvas id="shader-canvas" aria-hidden="true"></canvas>
            <BackgroundGallery />
            <noscript>
                <style>"#shader-canvas { display: none; }"</style>
            </noscript>
            <main class="container">
                <Nav />
                <article class="privacy-page">
                    <h1>"Privacy"</h1>
                    <p>"This site measures how it is used, in a way that does not identify you."</p>
                    <h2>"What is recorded"</h2>
                    <ul>
                        <li>"Which page you viewed, and which profile link you clicked."</li>
                        <li>"How long the page was open."</li>
                        <li>"The website that sent you here, as a domain name only."</li>
                        <li>"Your country, and whether you use a phone or a computer."</li>
                    </ul>
                    <h2>"What is not recorded"</h2>
                    <p>
                        "No cookies, and nothing is stored in your browser. Your IP address and browser details are not saved. Visits are counted with a one-way code that changes every day, so one day's visit cannot be linked to another."
                    </p>
                    <h2>"How long it is kept"</h2>
                    <p>"Records are deleted after 90 days."</p>
                    <h2>"Who handles it"</h2>
                    <p>"Cloudflare runs the counting service on this site's behalf. The data is not sold or shared."</p>
                    <h2>"Opting out"</h2>
                    <p>"If your browser sends Do Not Track or Global Privacy Control, nothing is recorded."</p>
                </article>
            </main>
            <footer>
                <a href="/">"Home"</a>
            </footer>
        </body>
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn html() -> String {
        PrivacyPage().to_html()
    }

    #[test]
    fn has_heading() {
        assert!(html().contains("<h1>Privacy</h1>") || html().contains(">Privacy</h1>"));
    }

    #[test]
    fn states_no_cookies_and_retention() {
        let h = html();
        assert!(h.contains("No cookies"));
        assert!(h.contains("deleted after 90 days"));
    }

    #[test]
    fn mentions_opt_out_signals() {
        let h = html();
        assert!(h.contains("Do Not Track"));
        assert!(h.contains("Global Privacy Control"));
    }

    #[test]
    fn does_not_claim_ip_is_stored() {
        assert!(html().contains("IP address and browser details are not saved"));
    }
}
