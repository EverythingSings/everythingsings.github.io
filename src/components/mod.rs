//! # UI Components
//!
//! Reusable components implementing triple semantic markup for AI accessibility.
//!
//! ## Semantic Markup Layers
//!
//! Each component implements multiple semantic formats:
//! - **JSON-LD**: Structured data in `<head>` for search engines/AI
//! - **Microformats2**: h-card classes for IndieWeb compatibility
//! - **Schema.org microdata**: `itemscope`/`itemprop` attributes

mod art_index;
mod art_series;
mod head;
mod link_list;
mod nav;
mod profile_card;
mod sigil;

pub use art_index::{ArtIndexPage, ArtIndexPageProps};
pub use art_series::{ArtSeriesPage, ArtSeriesPageProps};
pub use head::{generate_head_html, generate_head_html_for, Head, PageMeta};
pub use link_list::LinkList;
pub use nav::Nav;
pub use profile_card::ProfileCard;
pub use sigil::SigilPage;
