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

mod head;
mod link_list;
mod profile_card;

pub use head::{generate_head_html, Head};
pub use link_list::LinkList;
pub use profile_card::ProfileCard;
