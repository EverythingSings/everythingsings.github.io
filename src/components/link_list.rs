//! # Link List Component
//!
//! Renders the list of external profile links with semantic markup.
//!
//! ## Semantic Features
//!
//! - `rel="me"` on all links for IndieWeb identity verification
//! - Schema.org `sameAs` itemprop for linked profiles
//! - Accessible list structure with proper ARIA
//!
//! ## Quantum Reveal Effect
//!
//! Descriptions exist in a "collapsed" state until observed (hover/focus),
//! then materialize with blur-to-sharp transition via CSS.

use leptos::prelude::*;

/// A single link entry with display text and URL.
#[derive(Clone)]
pub struct LinkEntry {
    pub label: &'static str,
    pub href: &'static str,
    pub description: Option<&'static str>,
}

/// The five canonical profile links, in display order.
///
/// Intentionally short. Anything more should live on its own page or sub-domain.
const LINKS: &[LinkEntry] = &[
    LinkEntry {
        label: "Shop",
        href: "https://bedim.redbubble.com",
        description: Some("AI art prints and merchandise on Redbubble"),
    },
    LinkEntry {
        label: "GitHub",
        href: "https://github.com/EverythingSings",
        description: Some("Code is art"),
    },
    LinkEntry {
        label: "Music",
        href: "https://music.apple.com/artist/1704503690",
        description: Some("Listen on Apple Music"),
    },
    LinkEntry {
        label: "X",
        href: "https://x.com/everythingSung",
        description: Some("Follow on X"),
    },
    LinkEntry {
        label: "Book Reviews",
        href: "https://books.everythingsings.art",
        description: Some("A personal reading journal — 100+ reviews"),
    },
];

fn render_link(link: &LinkEntry) -> impl IntoView {
    view! {
        <li class="link-item">
            <a
                href=link.href
                rel="me noopener"
                itemprop="sameAs"
                class="link-card"
                title=link.description.unwrap_or(link.label)
            >
                <span class="link-label">{link.label}</span>
                {link.description.map(|desc| {
                    view! { <span class="link-description">{desc}</span> }
                })}
            </a>
        </li>
    }
}

/// The link list component.
#[component]
pub fn LinkList() -> impl IntoView {
    view! {
        <nav class="link-list" aria-label="Profile links">
            <ul>
                {LINKS.iter().map(render_link).collect::<Vec<_>>()}
            </ul>
        </nav>
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn render_list() -> String {
        LinkList().to_html()
    }

    #[test]
    fn list_is_nav_element() {
        let html = render_list();
        assert!(html.contains("<nav"));
    }

    #[test]
    fn list_has_aria_label() {
        let html = render_list();
        assert!(html.contains("aria-label="));
    }

    #[test]
    fn list_uses_ul_element() {
        let html = render_list();
        assert!(html.contains("<ul>"));
    }

    #[test]
    fn list_has_five_links() {
        assert_eq!(LINKS.len(), 5);
    }

    #[test]
    fn links_have_card_class() {
        let html = render_list();
        assert!(html.contains("link-card"));
    }

    #[test]
    fn links_have_rel_me() {
        let html = render_list();
        assert!(html.contains("rel=\"me"));
    }

    #[test]
    fn links_have_noopener() {
        let html = render_list();
        assert!(html.contains("noopener"));
    }

    #[test]
    fn links_have_sameas_itemprop() {
        let html = render_list();
        assert!(html.contains("itemprop=\"sameAs\""));
    }

    #[test]
    fn links_have_title_attribute() {
        let html = render_list();
        assert!(html.contains("title=\""));
    }

    #[test]
    fn links_contain_all_labels() {
        let html = render_list();
        for link in LINKS {
            assert!(
                html.contains(link.label),
                "Link list should contain label: {}",
                link.label
            );
        }
    }

    #[test]
    fn book_reviews_link_present() {
        let html = render_list();
        assert!(html.contains("books.everythingsings.art"));
    }

    #[test]
    fn links_in_expected_order() {
        let expected = ["Shop", "GitHub", "Music", "X", "Book Reviews"];
        for (i, link) in LINKS.iter().enumerate() {
            assert_eq!(link.label, expected[i]);
        }
    }
}
