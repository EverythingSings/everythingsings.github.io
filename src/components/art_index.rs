//! # Art Index Page Component
//!
//! Renders the `/art/` page listing all art series as clickable cards.
//! Uses Schema.org CollectionPage microdata.

use crate::art::ArtSeries;
use crate::components::Nav;
use leptos::prelude::*;

/// Renders a single series card.
fn render_series_card(series: &ArtSeries) -> impl IntoView {
    let href = format!("/art/{}/", series.slug);
    let image_count = series.images.len();
    let count_text = if image_count == 1 {
        "1 image".to_string()
    } else {
        format!("{} images", image_count)
    };

    view! {
        <a href=href class="series-card" itemscope itemtype="https://schema.org/ImageGallery">
            <img
                src=series.cover_url.clone()
                alt=format!("Cover image for {}", series.title)
                class="series-card-cover"
                itemprop="image"
                loading="lazy"
            />
            <div class="series-card-info">
                <h2 itemprop="name">{series.title.clone()}</h2>
                <p itemprop="description">{series.description.clone()}</p>
                <span class="series-card-count">{count_text}</span>
            </div>
        </a>
    }
}

/// The art index page component.
///
/// Lists all series as cards with cover images, sorted newest first.
#[component]
pub fn ArtIndexPage(series: Vec<ArtSeries>) -> impl IntoView {
    view! {
        <body itemscope itemtype="https://schema.org/CollectionPage">
            <canvas id="shader-canvas" aria-hidden="true"></canvas>
            <noscript>
                <style>{"body { background: linear-gradient(135deg, #0d0d0d 0%, #1a1a1a 50%, #0d0d0d 100%); }"}</style>
            </noscript>
            <main class="container art-container">
                <Nav />
                <header class="art-header">
                    <h1 itemprop="name">Art Gallery</h1>
                    <p itemprop="description">AI art series by EverythingSings</p>
                </header>
                <div class="series-grid">
                    {series.iter().map(render_series_card).collect::<Vec<_>>()}
                </div>
            </main>
            <footer></footer>
        </body>
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::art::ArtImage;

    fn sample_series() -> Vec<ArtSeries> {
        vec![ArtSeries {
            slug: "test".to_string(),
            title: "Test Series".to_string(),
            description: "A test.".to_string(),
            date: "2025-06-15".to_string(),
            cover_url: "/art/test/cover.jpg".to_string(),
            images: vec![ArtImage {
                url: "/art/test/001.jpg".to_string(),
                alt: "Test".to_string(),
                title: None,
                description: None,
            }],
        }]
    }

    fn render_index() -> String {
        ArtIndexPage(ArtIndexPageProps {
            series: sample_series(),
        })
        .to_html()
    }

    #[test]
    fn index_has_collection_page_microdata() {
        let html = render_index();
        assert!(html.contains("CollectionPage"));
    }

    #[test]
    fn index_has_series_card() {
        let html = render_index();
        assert!(html.contains("series-card"));
    }

    #[test]
    fn index_has_series_link() {
        let html = render_index();
        assert!(html.contains("href=\"/art/test/\""));
    }

    #[test]
    fn index_has_nav() {
        let html = render_index();
        assert!(html.contains("site-nav"));
    }
}
