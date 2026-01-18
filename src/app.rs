//! # App Component
//!
//! The root component that composes the entire page structure.
//! Renders the body content for the static site.
//!
//! Note: The `<head>` element is rendered separately via `generate_head_html()`
//! in main.rs because Leptos's view! macro doesn't support the `property`
//! attribute needed for Open Graph meta tags.

use crate::components::{LinkList, ProfileCard};
use leptos::prelude::*;

/// The root application component.
///
/// Renders just the `<body>` content. The `<head>` is handled separately
/// via `generate_head_html()` in the SSG binary.
#[component]
pub fn App() -> impl IntoView {
    view! {
        <Body />
    }
}

/// The body component containing the main content.
///
/// Uses Schema.org WebPage microdata for semantic structure.
#[component]
pub fn Body() -> impl IntoView {
    view! {
        <body
            itemscope
            itemtype="https://schema.org/WebPage"
        >
            <canvas id="shader-canvas" aria-hidden="true"></canvas>
            <noscript>
                <style>{"body { background: linear-gradient(135deg, #0d0d0d 0%, #1a1a1a 50%, #0d0d0d 100%); }"}</style>
            </noscript>
            <main class="container">
                <ProfileCard />
                <LinkList />
            </main>
            <footer></footer>
        </body>
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Helper to render a component to HTML string for testing.
    fn render<V: IntoView + 'static>(view: V) -> String {
        view.to_html()
    }

    #[test]
    fn app_renders_body_element() {
        let html = render(App());
        assert!(html.contains("<body"), "App should render <body> element");
    }

    #[test]
    fn app_does_not_render_head() {
        // Head is rendered separately via generate_head_html()
        let html = render(App());
        assert!(
            !html.contains("<head"),
            "App should not render <head> (handled by generate_head_html)"
        );
    }

    #[test]
    fn body_has_webpage_microdata() {
        let html = render(Body());
        assert!(
            html.contains("itemtype=\"https://schema.org/WebPage\""),
            "Body should have WebPage microdata"
        );
    }

    #[test]
    fn body_contains_main_element() {
        let html = render(Body());
        assert!(
            html.contains("<main"),
            "Body should contain <main> element"
        );
    }

    #[test]
    fn body_contains_footer() {
        let html = render(Body());
        assert!(
            html.contains("<footer"),
            "Body should contain <footer> element"
        );
    }
}
