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
    /// Stable name sent to analytics when the link is clicked (a-z, 0-9, hyphen).
    pub track: &'static str,
    pub href: &'static str,
    pub description: Option<&'static str>,
}

/// The canonical profile links, in display order.
///
/// Intentionally short. Anything more should live on its own page or sub-domain.
const LINKS: &[LinkEntry] = &[
    LinkEntry {
        label: "Networked Art",
        track: "networked-art",
        href: "https://networked.art/everything?action=follow",
        description: Some("Scarce digital editions on networked.art"),
    },
    LinkEntry {
        label: "Shop",
        track: "shop",
        href: "https://bedim.redbubble.com",
        description: Some("Physical prints and merchandise on Redbubble"),
    },
    LinkEntry {
        label: "Ask Me Anything",
        track: "ask-me-anything",
        href: "https://unsaid.fyi/everythingSung?card=ama-1792261910016",
        description: Some("Ask me a question on Unsaid"),
    },
    LinkEntry {
        label: "Spawn",
        track: "spawn",
        href: "https://www.spawn.co/@everything",
        description: Some("Play my games on Spawn"),
    },
    LinkEntry {
        label: "Discord",
        track: "discord",
        href: "https://discord.gg/8Q8w2CBhZZ",
        description: Some("Join my Discord community"),
    },
    LinkEntry {
        label: "GitHub",
        track: "github",
        href: "https://github.com/EverythingSings",
        description: Some("Code is art"),
    },
    LinkEntry {
        label: "X",
        track: "x",
        href: "https://x.com/everythingSung",
        description: Some("Follow on X"),
    },
    LinkEntry {
        label: "YouTube",
        track: "youtube",
        href: "https://www.youtube.com/@EverythingSings",
        description: Some("Watch on YouTube"),
    },
    LinkEntry {
        label: "Music",
        track: "music",
        href: "https://music.apple.com/artist/1704503690",
        description: Some("Listen on Apple Music"),
    },
    LinkEntry {
        label: "Midjourney",
        track: "midjourney",
        href: "https://www.midjourney.com/@everythingsings",
        description: Some("Explore images on Midjourney"),
    },
    LinkEntry {
        label: "Book Reviews",
        track: "book-reviews",
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
                data-track=link.track
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
    fn list_has_eleven_links() {
        assert_eq!(LINKS.len(), 11);
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
    fn midjourney_link_present() {
        let html = render_list();
        assert!(html.contains("midjourney.com/@everythingsings"));
    }

    #[test]
    fn links_in_expected_order() {
        let expected = [
            "Networked Art",
            "Shop",
            "Ask Me Anything",
            "Spawn",
            "Discord",
            "GitHub",
            "X",
            "YouTube",
            "Music",
            "Midjourney",
            "Book Reviews",
        ];
        for (i, link) in LINKS.iter().enumerate() {
            assert_eq!(link.label, expected[i]);
        }
    }

    #[test]
    fn spawn_link_present() {
        let html = render_list();
        assert!(html.contains("https://www.spawn.co/@everything"));
    }

    #[test]
    fn networked_art_link_present() {
        let html = render_list();
        assert!(html.contains("networked.art/everything"));
    }

    #[test]
    fn shop_and_networked_art_are_differentiated() {
        let networked = LINKS.iter().find(|l| l.label == "Networked Art").unwrap();
        let shop = LINKS.iter().find(|l| l.label == "Shop").unwrap();
        assert!(networked.description.unwrap().contains("digital"));
        assert!(shop.description.unwrap().contains("Physical"));
    }

    #[test]
    fn every_link_has_a_data_track_name() {
        let html = render_list();
        for link in LINKS {
            assert!(
                html.contains(&format!("data-track=\"{}\"", link.track)),
                "missing data-track for {}",
                link.label
            );
        }
    }

    #[test]
    fn track_names_are_unique_and_url_safe() {
        let mut seen = std::collections::HashSet::new();
        for link in LINKS {
            assert!(!link.track.is_empty() && link.track.len() <= 40);
            assert!(link
                .track
                .chars()
                .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-'));
            assert!(seen.insert(link.track), "duplicate track name {}", link.track);
        }
    }

    #[test]
    fn shop_link_is_tracked_as_shop() {
        let shop = LINKS.iter().find(|l| l.href.contains("redbubble")).unwrap();
        assert_eq!(shop.track, "shop");
    }
}
