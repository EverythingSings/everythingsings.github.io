//! # Art Series Page Component
//!
//! Renders an individual art series page with vertically stacked images.
//! Uses Schema.org ImageGallery + ImageObject microdata.

use crate::art::{ArtImage, ArtSeries};
use crate::components::Nav;
use leptos::prelude::*;

/// Renders a single image figure.
fn render_image(image: &ArtImage) -> impl IntoView {
    let has_caption = image.title.is_some() || image.description.is_some();

    view! {
        <figure class="art-image" itemscope itemtype="https://schema.org/ImageObject">
            <img
                src=image.url.clone()
                alt=image.alt.clone()
                itemprop="contentUrl"
                loading="lazy"
            />
            {has_caption.then(|| {
                let title = image.title.clone();
                let desc = image.description.clone();
                view! {
                    <figcaption>
                        {title.map(|t| view! { <strong itemprop="name">{t}</strong> })}
                        {desc.map(|d| view! { <span itemprop="description">{d}</span> })}
                    </figcaption>
                }
            })}
        </figure>
    }
}

/// The art series page component.
///
/// Displays a single series with a back link, header, and vertical image scroll.
#[component]
pub fn ArtSeriesPage(series: ArtSeries) -> impl IntoView {
    view! {
        <body itemscope itemtype="https://schema.org/ImageGallery">
            <canvas id="shader-canvas" aria-hidden="true"></canvas>
            <noscript>
                <style>{"body { background: linear-gradient(135deg, #0d0d0d 0%, #1a1a1a 50%, #0d0d0d 100%); }"}</style>
            </noscript>
            <main class="container art-container">
                <Nav />
                <a href="/art/" class="back-link">{"\u{2190} All Series"}</a>
                <header class="art-header">
                    <h1 itemprop="name">{series.title.clone()}</h1>
                    <p itemprop="description">{series.description.clone()}</p>
                </header>
                <div class="art-images">
                    {series.images.iter().map(render_image).collect::<Vec<_>>()}
                </div>
            </main>
            <footer></footer>
        </body>
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample_series() -> ArtSeries {
        ArtSeries {
            slug: "test".to_string(),
            title: "Test Series".to_string(),
            description: "A test.".to_string(),
            date: "2025-06-15".to_string(),
            cover_url: "/art/test/001.jpg".to_string(),
            images: vec![
                ArtImage {
                    url: "/art/test/001.jpg".to_string(),
                    alt: "First image".to_string(),
                    title: Some("Dawn".to_string()),
                    description: Some("Morning light".to_string()),
                },
                ArtImage {
                    url: "/art/test/002.jpg".to_string(),
                    alt: "Second image".to_string(),
                    title: None,
                    description: None,
                },
            ],
        }
    }

    fn render_series() -> String {
        ArtSeriesPage(ArtSeriesPageProps {
            series: sample_series(),
        })
        .to_html()
    }

    #[test]
    fn series_has_image_gallery_microdata() {
        let html = render_series();
        assert!(html.contains("ImageGallery"));
    }

    #[test]
    fn series_has_image_object_microdata() {
        let html = render_series();
        assert!(html.contains("ImageObject"));
    }

    #[test]
    fn series_has_back_link() {
        let html = render_series();
        assert!(html.contains("href=\"/art/\""));
        assert!(html.contains("back-link"));
    }

    #[test]
    fn series_has_figcaption_for_titled_images() {
        let html = render_series();
        assert!(html.contains("<figcaption>"));
        assert!(html.contains("Dawn"));
    }

    #[test]
    fn series_has_nav() {
        let html = render_series();
        assert!(html.contains("site-nav"));
    }
}
