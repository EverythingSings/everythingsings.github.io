//! # Link List Component
//!
//! Renders the list of external profile links with semantic markup.
//!
//! ## Semantic Features
//!
//! - `rel="me"` on all links for IndieWeb identity verification
//! - Schema.org `sameAs` itemprop for linked profiles
//! - Accessible list structure with proper ARIA
//! - Links grouped by purpose: Create, Think, Build, Support, Connect
//!
//! ## Quantum Reveal Effect
//!
//! Descriptions exist in a "collapsed" state until observed (hover/focus),
//! then materialize with blur-to-sharp transition via CSS.

use leptos::prelude::*;

/// A single link entry with display text and URL.
#[derive(Clone)]
pub struct LinkEntry {
    /// The display text for the link.
    pub label: &'static str,
    /// The URL the link points to.
    pub href: &'static str,
    /// Optional description revealed on hover/focus.
    pub description: Option<&'static str>,
}

/// A group of related links with a semantic label.
#[derive(Clone)]
pub struct LinkGroup {
    /// The group name (e.g., "Create", "Think").
    pub name: &'static str,
    /// The links belonging to this group.
    pub links: &'static [LinkEntry],
}

/// Profile links organized by purpose.
/// Order prioritizes what makes the artist unique, then flows to engagement.
const LINK_GROUPS: &[LinkGroup] = &[
    // Create: Original work first - the differentiator
    LinkGroup {
        name: "Create",
        links: &[
            LinkEntry {
                label: "Lumimenta",
                href: "https://lumimenta.everythingsings.art",
                description: Some("Physical trading card photography series"),
            },
            LinkEntry {
                label: "Sigil",
                href: "https://sigil.everythingsings.art",
                description: Some("Explore Sigil"),
            },
            LinkEntry {
                label: "Music",
                href: "https://music.apple.com/artist/1704503690",
                description: Some("Listen on Apple Music"),
            },
        ],
    },
    // Think: Ideas and writing
    LinkGroup {
        name: "Think",
        links: &[LinkEntry {
            label: "Substack",
            href: "https://everythingsings.substack.com",
            description: Some("Writing on AI, art, and technology"),
        }],
    },
    // Build: Code and tools
    LinkGroup {
        name: "Build",
        links: &[
            LinkEntry {
                label: "GitHub",
                href: "https://github.com/EverythingSings",
                description: Some("Code is art"),
            },
            LinkEntry {
                label: "Sovereign Tools",
                href: "https://github.com/sovereign-composable-tools",
                description: Some("Local-first tools for open protocols"),
            },
        ],
    },
    // Support: Commercial - placed lower to avoid feeling salesy
    LinkGroup {
        name: "Support",
        links: &[LinkEntry {
            label: "Shop",
            href: "https://bedim.redbubble.com",
            description: Some("AI art prints and merchandise"),
        }],
    },
    // Connect: Social - last because it's everywhere, least unique
    LinkGroup {
        name: "Connect",
        links: &[
            LinkEntry {
                label: "Mastodon",
                href: "https://mastodon.social/@everythingsings",
                description: Some("Follow on Mastodon"),
            },
            LinkEntry {
                label: "Nostr",
                href: "https://primal.net/p/nprofile1qqsvxa6ez4lr32zrhk98xwj8pka3kjjy9v4c823m6pt4gvw8d49vfggjfvjru",
                description: Some("Follow on Nostr"),
            },
            LinkEntry {
                label: "X",
                href: "https://x.com/systemicwisdom_",
                description: Some("Follow on X"),
            },
        ],
    },
];

/// Renders a single link item with quantum reveal effect.
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

/// Renders a group of links with a subtle label.
fn render_group(group: &LinkGroup) -> impl IntoView {
    view! {
        <section class="link-group">
            <h2 class="link-group-label">{group.name}</h2>
            <ul>
                {group.links.iter().map(render_link).collect::<Vec<_>>()}
            </ul>
        </section>
    }
}

/// The link list component.
///
/// Renders all profile links grouped by purpose with `rel="me"` and
/// `sameAs` microdata. Descriptions reveal on hover/focus with a
/// blur-to-sharp "quantum" transition.
#[component]
pub fn LinkList() -> impl IntoView {
    view! {
        <nav class="link-list" aria-label="Profile links">
            {LINK_GROUPS.iter().map(render_group).collect::<Vec<_>>()}
        </nav>
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Helper to render the component to HTML string.
    fn render_list() -> String {
        LinkList().to_html()
    }

    /// Helper to count total links across all groups.
    fn total_link_count() -> usize {
        LINK_GROUPS.iter().map(|g| g.links.len()).sum()
    }

    #[test]
    fn list_is_nav_element() {
        let html = render_list();
        assert!(html.contains("<nav"), "Link list should be a nav element");
    }

    #[test]
    fn list_has_aria_label() {
        let html = render_list();
        assert!(
            html.contains("aria-label="),
            "Nav should have aria-label for accessibility"
        );
    }

    #[test]
    fn list_has_five_groups() {
        let html = render_list();
        // Count section elements with link-group class (not link-group-label)
        let group_count = html.matches("<section class=\"link-group\"").count();
        assert_eq!(group_count, 5, "Should have 5 link groups");
    }

    #[test]
    fn groups_have_section_elements() {
        let html = render_list();
        assert!(
            html.contains("<section"),
            "Groups should use section elements"
        );
    }

    #[test]
    fn groups_have_labels() {
        let html = render_list();
        assert!(
            html.contains("link-group-label"),
            "Groups should have label class"
        );
        for group in LINK_GROUPS {
            assert!(
                html.contains(group.name),
                "Group label '{}' should be present",
                group.name
            );
        }
    }

    #[test]
    fn list_uses_ul_element() {
        let html = render_list();
        assert!(html.contains("<ul>"), "Link list should use unordered list");
    }

    #[test]
    fn list_has_li_elements() {
        let html = render_list();
        assert!(
            html.contains("link-item"),
            "Link list should have link-item class on li"
        );
    }

    #[test]
    fn links_have_card_class() {
        let html = render_list();
        assert!(
            html.contains("link-card"),
            "Links should have link-card class"
        );
    }

    #[test]
    fn links_have_label_span() {
        let html = render_list();
        assert!(
            html.contains("link-label"),
            "Links should have link-label span"
        );
    }

    #[test]
    fn links_have_description_span() {
        let html = render_list();
        assert!(
            html.contains("link-description"),
            "Links with descriptions should have link-description span"
        );
    }

    #[test]
    fn links_have_rel_me() {
        let html = render_list();
        assert!(
            html.contains("rel=\"me"),
            "Links should have rel=\"me\" for identity verification"
        );
    }

    #[test]
    fn links_have_noopener() {
        let html = render_list();
        assert!(
            html.contains("noopener"),
            "External links should have noopener for security"
        );
    }

    #[test]
    fn links_have_sameas_itemprop() {
        let html = render_list();
        assert!(
            html.contains("itemprop=\"sameAs\""),
            "Links should have sameAs itemprop for Schema.org"
        );
    }

    #[test]
    fn links_have_title_attribute() {
        let html = render_list();
        assert!(
            html.contains("title=\""),
            "Links should have title attribute for accessibility"
        );
    }

    #[test]
    fn links_contain_all_labels() {
        let html = render_list();
        for group in LINK_GROUPS {
            for link in group.links {
                assert!(
                    html.contains(link.label),
                    "Link list should contain label: {}",
                    link.label
                );
            }
        }
    }

    #[test]
    fn total_links_count() {
        assert_eq!(total_link_count(), 10, "Should have 10 profile links total");
    }

    #[test]
    fn groups_are_in_correct_order() {
        let expected = ["Create", "Think", "Build", "Support", "Connect"];
        for (i, group) in LINK_GROUPS.iter().enumerate() {
            assert_eq!(
                group.name, expected[i],
                "Group {} should be '{}'",
                i, expected[i]
            );
        }
    }
}
