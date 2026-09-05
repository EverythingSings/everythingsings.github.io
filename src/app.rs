//! # App Component
//!
//! The root component that composes the entire page structure.
//! Renders the body content for the static site.
//!
//! Note: The `<head>` element is rendered separately via `generate_head_html()`
//! in main.rs because Leptos's view! macro doesn't support the `property`
//! attribute needed for Open Graph meta tags.

use crate::components::{ArtEntry, ArtViewer, BackgroundGallery, LinkList, Nav, ProfileCard};
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
            <BackgroundGallery />
            <ArtViewer />
            <noscript>
                <style>{"body { background: linear-gradient(135deg, #0d0d0d 0%, #1a1a1a 50%, #0d0d0d 100%); }"}</style>
            </noscript>
            <main class="container">
                <Nav />
                <ProfileCard />
                <ArtEntry />
                <LinkList />
            </main>
            <footer></footer>
        </body>
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashSet;
    use std::fs;
    use std::path::Path;

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

    #[test]
    fn body_contains_background_gallery_controls() {
        let html = render(Body());
        assert!(html.contains("id=\"background-tab\""));
        assert!(html.contains("aria-controls=\"background-panel\""));
        assert!(html.contains("role=\"listbox\""));
    }

    #[test]
    fn background_gallery_has_live_status() {
        let html = render(Body());
        assert!(html.contains("id=\"background-status\""));
        assert!(html.contains("aria-live=\"polite\""));
        assert!(html.contains("aria-label=\"Random background\""));
        assert!(html.contains("id=\"background-motion\""));
        assert!(html.contains("id=\"background-tilt\""));
        assert!(html.contains("id=\"background-input-status\""));
        assert!(html.contains("aria-pressed=\"false\""));
        assert!(html.contains("id=\"background-filter\""));
        assert!(html.contains("aria-label=\"Find a background\""));
        assert!(html.contains("id=\"background-empty\""));
    }

    #[test]
    fn background_manager_has_a_shared_motion_compositor() {
        let manager = fs::read_to_string("public/js/shader-bg.js")
            .expect("background manager source should be readable");
        assert!(manager.contains("const compositorSource"));
        assert!(manager.contains("function generatedProfile"));
        assert!(manager.contains("DeviceOrientationEvent"));
        assert!(manager.contains("requestPermission"));
        assert!(manager.contains("gl.bindFramebuffer"));
    }

    #[test]
    fn every_registered_background_has_a_shader_source() {
        let manager = fs::read_to_string("public/js/shader-bg.js")
            .expect("background manager source should be readable");
        let ids: Vec<&str> = manager
            .lines()
            .filter_map(|line| line.trim().strip_prefix("{ id: '")?.split('\'').next())
            .collect();
        let names: Vec<&str> = manager
            .lines()
            .filter_map(|line| line.split("name: '").nth(1)?.split('\'').next())
            .collect();
        let unique: HashSet<&&str> = ids.iter().collect();
        let unique_names: HashSet<&&str> = names.iter().collect();
        let shader_files: HashSet<String> = fs::read_dir("public/shaders")
            .expect("shader directory should be readable")
            .filter_map(Result::ok)
            .filter_map(|entry| {
                let path = entry.path();
                (path.extension()?.to_str()? == "glsl")
                    .then(|| path.file_stem()?.to_str().map(str::to_owned))?
            })
            .filter(|id| id != "common")
            .collect();

        assert!(ids.len() >= 79, "background gallery unexpectedly shrank");
        assert_eq!(ids.len(), names.len(), "every background needs a name");
        assert_eq!(ids.len(), unique.len(), "background ids must be unique");
        assert_eq!(
            names.len(),
            unique_names.len(),
            "background names must be unique"
        );
        assert_eq!(
            ids.len(),
            shader_files.len(),
            "every shader source should be represented in the gallery"
        );
        for id in ids {
            let path = Path::new("public/shaders").join(format!("{id}.glsl"));
            assert!(
                shader_files.contains(id) && path.is_file(),
                "registered background {id} is missing its shader source"
            );
            let source = fs::read_to_string(path).expect("shader source should be readable");
            assert!(
                source.contains("void main()"),
                "registered background {id} needs a fragment entry point"
            );
        }
    }
}
