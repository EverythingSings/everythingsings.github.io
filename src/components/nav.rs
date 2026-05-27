//! # Site Navigation Component
//!
//! Minimal site-wide nav — just the home link.

use crate::config::SITE_NAME;
use leptos::prelude::*;

#[component]
pub fn Nav() -> impl IntoView {
    view! {
        <nav class="site-nav" aria-label="Site navigation">
            <a href="/" class="site-nav-home">{SITE_NAME}</a>
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
}
