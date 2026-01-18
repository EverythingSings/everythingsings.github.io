//! # Profile Card Component
//!
//! Renders the artist profile card with triple semantic markup:
//! - Microformats2 h-card for IndieWeb compatibility
//! - Schema.org Person microdata for search engines
//! - Accessible HTML structure
//!
//! ## Microformats2 Classes
//!
//! - `.h-card` - Container for person/organization
//! - `.p-name` - Person's name
//! - `.p-note` - Short description/bio
//! - `.u-photo` - Profile photo URL
//! - `.u-url` - Profile URL (rel="me" for identity)

use crate::config::{AVATAR_PATH, SITE_DESCRIPTION, SITE_NAME, SITE_URL};
use leptos::prelude::*;

/// The profile card component.
///
/// Displays avatar, name, and bio with full semantic markup.
#[component]
pub fn ProfileCard() -> impl IntoView {
    view! {
        <article
            class="h-card profile-card"
            itemscope
            itemtype="https://schema.org/Person"
        >
            <a href=SITE_URL class="u-url" rel="me" itemprop="url">
                <img
                    src=AVATAR_PATH
                    alt=format!("{} avatar", SITE_NAME)
                    class="u-photo avatar"
                    itemprop="image"
                    width="128"
                    height="128"
                />
            </a>

            <h1 class="p-name" itemprop="name">
                {SITE_NAME}
            </h1>

            <p class="p-note" itemprop="description">
                {SITE_DESCRIPTION}
            </p>
        </article>
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn render_card() -> String {
        ProfileCard().to_html()
    }

    // Microformats2 h-card tests
    #[test]
    fn card_has_hcard_class() {
        let html = render_card();
        assert!(
            html.contains("class=\"h-card"),
            "Profile card should have h-card class"
        );
    }

    #[test]
    fn card_has_p_name_class() {
        let html = render_card();
        assert!(
            html.contains("p-name"),
            "Profile card should have p-name class"
        );
    }

    #[test]
    fn card_has_p_note_class() {
        let html = render_card();
        assert!(
            html.contains("p-note"),
            "Profile card should have p-note class"
        );
    }

    #[test]
    fn card_has_u_photo_class() {
        let html = render_card();
        assert!(
            html.contains("u-photo"),
            "Profile card should have u-photo class"
        );
    }

    #[test]
    fn card_has_u_url_class() {
        let html = render_card();
        assert!(
            html.contains("u-url"),
            "Profile card should have u-url class"
        );
    }

    #[test]
    fn card_link_has_rel_me() {
        let html = render_card();
        assert!(
            html.contains("rel=\"me\""),
            "Profile URL link should have rel=\"me\" attribute"
        );
    }

    // Schema.org microdata tests
    #[test]
    fn card_has_person_itemtype() {
        let html = render_card();
        assert!(
            html.contains("itemtype=\"https://schema.org/Person\""),
            "Profile card should have Person itemtype"
        );
    }

    #[test]
    fn card_has_itemscope() {
        let html = render_card();
        assert!(
            html.contains("itemscope"),
            "Profile card should have itemscope attribute"
        );
    }

    #[test]
    fn card_has_name_itemprop() {
        let html = render_card();
        assert!(
            html.contains("itemprop=\"name\""),
            "Name should have itemprop attribute"
        );
    }

    #[test]
    fn card_has_description_itemprop() {
        let html = render_card();
        assert!(
            html.contains("itemprop=\"description\""),
            "Description should have itemprop attribute"
        );
    }

    #[test]
    fn card_has_image_itemprop() {
        let html = render_card();
        assert!(
            html.contains("itemprop=\"image\""),
            "Image should have itemprop attribute"
        );
    }

    #[test]
    fn card_has_url_itemprop() {
        let html = render_card();
        assert!(
            html.contains("itemprop=\"url\""),
            "URL should have itemprop attribute"
        );
    }

    // Content tests
    #[test]
    fn card_contains_site_name() {
        let html = render_card();
        assert!(
            html.contains(SITE_NAME),
            "Profile card should contain site name"
        );
    }

    #[test]
    fn card_contains_avatar_path() {
        let html = render_card();
        assert!(
            html.contains(AVATAR_PATH),
            "Profile card should contain avatar path"
        );
    }

    #[test]
    fn avatar_has_alt_text() {
        let html = render_card();
        assert!(
            html.contains("alt=\""),
            "Avatar image should have alt text"
        );
    }

    #[test]
    fn avatar_has_dimensions() {
        let html = render_card();
        assert!(
            html.contains("width=\"") && html.contains("height=\""),
            "Avatar should have width and height attributes"
        );
    }
}
