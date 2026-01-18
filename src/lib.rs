//! # EverythingSings.art
//!
//! A self-hosted, AI-crawler-accessible landing page built with Rust Leptos.
//!
//! This crate provides the component library for the static site, implementing
//! triple semantic markup (JSON-LD, Microformats2, Schema.org microdata) for
//! maximum AI/crawler accessibility.
//!
//! ## Architecture
//!
//! - All components render server-side only for static HTML output
//! - No client-side JavaScript required for content access
//! - Designed for ~24KB WASM stub with zero islands

pub mod app;
pub mod components;

pub use app::App;

/// Site configuration constants.
pub mod config {
    /// The artist/site name.
    pub const SITE_NAME: &str = "EverythingSings";

    /// The site domain.
    pub const SITE_DOMAIN: &str = "everythingsings.art";

    /// Full site URL.
    pub const SITE_URL: &str = "https://everythingsings.art";

    /// Site description for meta tags and JSON-LD.
    pub const SITE_DESCRIPTION: &str =
        "Formless art brand for the future. Exploring AI, art, and sovereign technology.";

    /// Path to avatar image (relative to site root).
    pub const AVATAR_PATH: &str = "/avatar.png";
}

#[cfg(test)]
mod tests {
    use super::config::*;

    #[test]
    fn config_site_url_is_https() {
        assert!(SITE_URL.starts_with("https://"));
    }

    #[test]
    fn config_site_url_contains_domain() {
        assert!(SITE_URL.contains(SITE_DOMAIN));
    }

    #[test]
    fn config_avatar_path_is_absolute() {
        assert!(AVATAR_PATH.starts_with('/'));
    }
}
