//! # Head Component
//!
//! Renders the `<head>` element with all necessary metadata for SEO and AI crawlers.
//!
//! ## Contents
//!
//! - Character encoding and viewport meta tags
//! - Favicon and Apple Touch Icon
//! - Theme color and web app manifest
//! - Open Graph and Twitter Card meta tags
//! - JSON-LD structured data (Schema.org Person)
//! - RSS feed link
//! - Stylesheet link
//! - Canonical URL
//!
//! Note: The Head component returns raw HTML because Leptos's view! macro
//! doesn't support the `property` attribute needed for Open Graph meta tags.

use crate::config::{AVATAR_PATH, SITE_DESCRIPTION, SITE_NAME, SITE_URL};

/// Theme color for browser chrome (matches --color-bg in dark mode).
const THEME_COLOR: &str = "#0d0d0d";
use leptos::prelude::*;

/// Generates the JSON-LD structured data for the page.
///
/// Returns a Schema.org Person object as a JSON string.
pub fn generate_json_ld() -> String {
    format!(
        r#"{{
  "@context": "https://schema.org",
  "@type": "Person",
  "name": "{name}",
  "url": "{url}",
  "description": "{description}",
  "image": "{url}{avatar}",
  "sameAs": []
}}"#,
        name = SITE_NAME,
        url = SITE_URL,
        description = SITE_DESCRIPTION,
        avatar = AVATAR_PATH,
    )
}

/// Generates the complete `<head>` element content as HTML string.
///
/// Returns the full head HTML including Open Graph meta tags.
/// This is used directly in SSG mode since Leptos's view! macro
/// doesn't support the `property` attribute.
pub fn generate_head_html() -> String {
    let json_ld = generate_json_ld();
    let full_avatar_url = format!("{}{}", SITE_URL, AVATAR_PATH);

    format!(
        r#"<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>{name} | Digital Artist</title>
<meta name="description" content="{description}" />
<link rel="canonical" href="{url}" />
<link rel="icon" href="/favicon.ico" sizes="32x32" />
<link rel="icon" href="/favicon.svg" type="image/svg+xml" />
<link rel="apple-touch-icon" href="/apple-touch-icon.png" />
<link rel="manifest" href="/site.webmanifest" />
<meta name="theme-color" content="{theme}" />
<meta property="og:type" content="profile" />
<meta property="og:title" content="{name}" />
<meta property="og:description" content="{description}" />
<meta property="og:url" content="{url}" />
<meta property="og:image" content="{avatar}" />
<meta name="twitter:card" content="summary" />
<meta name="twitter:title" content="{name}" />
<meta name="twitter:description" content="{description}" />
<meta name="twitter:image" content="{avatar}" />
<link rel="alternate" type="application/rss+xml" title="{name} RSS Feed" href="/feed.xml" />
<script type="application/ld+json">{json_ld}</script>
<link rel="stylesheet" href="/main.css" />
<script src="/js/shader-bg.js" defer></script>
</head>"#,
        name = SITE_NAME,
        description = SITE_DESCRIPTION,
        url = SITE_URL,
        avatar = full_avatar_url,
        theme = THEME_COLOR,
        json_ld = json_ld,
    )
}

/// The `<head>` component placeholder.
///
/// Note: For SSG mode, use `generate_head_html()` directly in the main
/// render function. This component exists for API compatibility with
/// tests but returns an empty fragment since the actual head is
/// rendered via raw HTML.
#[component]
pub fn Head() -> impl IntoView {
    // For SSG, head is rendered via generate_head_html() in main.rs
    // Returns empty Option - the actual head is constructed in main.rs
    None::<()>
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Tests use generate_head_html() directly since the component
    /// returns empty view for SSG compatibility.
    fn render_head() -> String {
        generate_head_html()
    }

    #[test]
    fn head_contains_charset() {
        let html = render_head();
        assert!(
            html.contains("charset=\"utf-8\""),
            "Head should specify UTF-8 charset"
        );
    }

    #[test]
    fn head_contains_viewport() {
        let html = render_head();
        assert!(
            html.contains("name=\"viewport\""),
            "Head should contain viewport meta tag"
        );
    }

    #[test]
    fn head_contains_title() {
        let html = render_head();
        assert!(
            html.contains("<title>"),
            "Head should contain title element"
        );
        assert!(
            html.contains(SITE_NAME),
            "Title should contain site name"
        );
    }

    #[test]
    fn head_contains_description() {
        let html = render_head();
        assert!(
            html.contains("name=\"description\""),
            "Head should contain description meta tag"
        );
    }

    #[test]
    fn head_contains_canonical_url() {
        let html = render_head();
        assert!(
            html.contains("rel=\"canonical\""),
            "Head should contain canonical link"
        );
        assert!(
            html.contains(SITE_URL),
            "Canonical should point to site URL"
        );
    }

    #[test]
    fn head_contains_open_graph_tags() {
        let html = render_head();
        assert!(
            html.contains("og:type"),
            "Head should contain Open Graph type"
        );
        assert!(
            html.contains("og:title"),
            "Head should contain Open Graph title"
        );
        assert!(
            html.contains("og:description"),
            "Head should contain Open Graph description"
        );
        assert!(
            html.contains("og:image"),
            "Head should contain Open Graph image"
        );
    }

    #[test]
    fn head_contains_twitter_card_tags() {
        let html = render_head();
        assert!(
            html.contains("twitter:card"),
            "Head should contain Twitter card type"
        );
        assert!(
            html.contains("twitter:title"),
            "Head should contain Twitter title"
        );
    }

    #[test]
    fn head_contains_json_ld() {
        let html = render_head();
        assert!(
            html.contains("application/ld+json"),
            "Head should contain JSON-LD script"
        );
    }

    #[test]
    fn json_ld_has_schema_context() {
        let json_ld = generate_json_ld();
        assert!(
            json_ld.contains("\"@context\": \"https://schema.org\""),
            "JSON-LD should have schema.org context"
        );
    }

    #[test]
    fn json_ld_has_person_type() {
        let json_ld = generate_json_ld();
        assert!(
            json_ld.contains("\"@type\": \"Person\""),
            "JSON-LD should have Person type"
        );
    }

    #[test]
    fn json_ld_has_required_fields() {
        let json_ld = generate_json_ld();
        assert!(json_ld.contains("\"name\":"), "JSON-LD should have name");
        assert!(json_ld.contains("\"url\":"), "JSON-LD should have url");
        assert!(
            json_ld.contains("\"description\":"),
            "JSON-LD should have description"
        );
        assert!(json_ld.contains("\"image\":"), "JSON-LD should have image");
        assert!(
            json_ld.contains("\"sameAs\":"),
            "JSON-LD should have sameAs array"
        );
    }

    #[test]
    fn head_links_stylesheet() {
        let html = render_head();
        assert!(
            html.contains("rel=\"stylesheet\""),
            "Head should link stylesheet"
        );
        assert!(
            html.contains("main.css"),
            "Head should link to main.css"
        );
    }

    #[test]
    fn head_contains_favicon_ico() {
        let html = render_head();
        assert!(
            html.contains("favicon.ico"),
            "Head should link favicon.ico"
        );
    }

    #[test]
    fn head_contains_favicon_svg() {
        let html = render_head();
        assert!(
            html.contains("favicon.svg"),
            "Head should link favicon.svg"
        );
        assert!(
            html.contains("type=\"image/svg+xml\""),
            "SVG favicon should have correct type"
        );
    }

    #[test]
    fn head_contains_apple_touch_icon() {
        let html = render_head();
        assert!(
            html.contains("apple-touch-icon"),
            "Head should link apple-touch-icon"
        );
    }

    #[test]
    fn head_contains_web_manifest() {
        let html = render_head();
        assert!(
            html.contains("rel=\"manifest\""),
            "Head should link web manifest"
        );
        assert!(
            html.contains("site.webmanifest"),
            "Head should link to site.webmanifest"
        );
    }

    #[test]
    fn head_contains_theme_color() {
        let html = render_head();
        assert!(
            html.contains("name=\"theme-color\""),
            "Head should have theme-color meta"
        );
        assert!(
            html.contains(THEME_COLOR),
            "Theme color should match constant"
        );
    }

    #[test]
    fn head_contains_rss_feed_link() {
        let html = render_head();
        assert!(
            html.contains("application/rss+xml"),
            "Head should have RSS feed link type"
        );
        assert!(
            html.contains("feed.xml"),
            "Head should link to feed.xml"
        );
    }
}
