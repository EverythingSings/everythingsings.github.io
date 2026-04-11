//! # Site Navigation Component
//!
//! Minimal site-wide navigation with home and art links.

use crate::config::SITE_NAME;
use leptos::prelude::*;

/// Site navigation bar.
#[component]
pub fn Nav() -> impl IntoView {
    view! {
        <nav class="site-nav" aria-label="Site navigation">
            <a href="/" class="site-nav-home">{SITE_NAME}</a>
            <a href="/art/">Art</a>
        </nav>
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn render_nav() -> String {
        Nav().to_html()
    }

    #[test]
    fn nav_has_aria_label() {
        let html = render_nav();
        assert!(html.contains("aria-label=\"Site navigation\""));
    }

    #[test]
    fn nav_has_home_link() {
        let html = render_nav();
        assert!(html.contains("href=\"/\""));
    }

    #[test]
    fn nav_has_art_link() {
        let html = render_nav();
        assert!(html.contains("href=\"/art/\""));
    }
}
