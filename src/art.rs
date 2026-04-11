//! # Art Series Data Model
//!
//! Reads art series from the filesystem (`public/art/<slug>/series.toml`)
//! and provides typed data for gallery page generation.

use serde::Deserialize;
use std::path::Path;

/// Raw TOML representation of a series.
#[derive(Deserialize)]
pub struct SeriesToml {
    pub title: String,
    pub description: String,
    pub date: String,
    pub cover: Option<String>,
    pub images: Vec<ImageToml>,
}

/// Raw TOML representation of an image entry.
#[derive(Deserialize)]
pub struct ImageToml {
    pub file: String,
    pub alt: String,
    pub title: Option<String>,
    pub description: Option<String>,
}

/// A resolved art series ready for rendering.
#[derive(Clone)]
pub struct ArtSeries {
    pub slug: String,
    pub title: String,
    pub description: String,
    pub date: String,
    pub cover_url: String,
    pub images: Vec<ArtImage>,
}

/// A resolved image with URL paths.
#[derive(Clone)]
pub struct ArtImage {
    pub url: String,
    pub alt: String,
    pub title: Option<String>,
    pub description: Option<String>,
}

/// Discovers all art series from `<base>/art/*/series.toml`.
///
/// Returns series sorted by date descending (newest first).
pub fn discover_series(base: &Path) -> Vec<ArtSeries> {
    let art_dir = base.join("art");
    if !art_dir.exists() {
        return Vec::new();
    }

    let mut series = Vec::new();

    let entries = match std::fs::read_dir(&art_dir) {
        Ok(e) => e,
        Err(_) => return Vec::new(),
    };

    for entry in entries.flatten() {
        let path = entry.path();
        if !path.is_dir() {
            continue;
        }

        let toml_path = path.join("series.toml");
        if !toml_path.exists() {
            continue;
        }

        let slug = match path.file_name().and_then(|n| n.to_str()) {
            Some(s) => s.to_string(),
            None => continue,
        };

        let content = match std::fs::read_to_string(&toml_path) {
            Ok(c) => c,
            Err(e) => {
                eprintln!("Warning: Could not read {}: {}", toml_path.display(), e);
                continue;
            }
        };

        let parsed: SeriesToml = match toml::from_str(&content) {
            Ok(p) => p,
            Err(e) => {
                eprintln!("Warning: Could not parse {}: {}", toml_path.display(), e);
                continue;
            }
        };

        let images: Vec<ArtImage> = parsed
            .images
            .iter()
            .map(|img| ArtImage {
                url: format!("/art/{}/{}", slug, img.file),
                alt: img.alt.clone(),
                title: img.title.clone(),
                description: img.description.clone(),
            })
            .collect();

        let cover_url = parsed
            .cover
            .as_ref()
            .map(|c| format!("/art/{}/{}", slug, c))
            .unwrap_or_else(|| {
                images
                    .first()
                    .map(|i| i.url.clone())
                    .unwrap_or_default()
            });

        series.push(ArtSeries {
            slug,
            title: parsed.title,
            description: parsed.description,
            date: parsed.date,
            cover_url,
            images,
        });
    }

    series.sort_by(|a, b| b.date.cmp(&a.date));
    series
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn create_test_series(base: &Path) {
        let series_dir = base.join("art").join("test-series");
        fs::create_dir_all(&series_dir).unwrap();
        fs::write(
            series_dir.join("series.toml"),
            r#"
title = "Test Series"
description = "A test series."
date = "2025-06-15"

[[images]]
file = "001.jpg"
alt = "Test image one"
title = "First"

[[images]]
file = "002.jpg"
alt = "Test image two"
"#,
        )
        .unwrap();
    }

    #[test]
    fn discover_empty_dir() {
        let tmp = tempdir();
        let result = discover_series(&tmp);
        assert!(result.is_empty());
    }

    #[test]
    fn discover_finds_series() {
        let tmp = tempdir();
        create_test_series(&tmp);
        let result = discover_series(&tmp);
        assert_eq!(result.len(), 1);
        assert_eq!(result[0].title, "Test Series");
        assert_eq!(result[0].slug, "test-series");
    }

    #[test]
    fn images_have_correct_urls() {
        let tmp = tempdir();
        create_test_series(&tmp);
        let result = discover_series(&tmp);
        assert_eq!(result[0].images[0].url, "/art/test-series/001.jpg");
        assert_eq!(result[0].images[1].url, "/art/test-series/002.jpg");
    }

    #[test]
    fn cover_defaults_to_first_image() {
        let tmp = tempdir();
        create_test_series(&tmp);
        let result = discover_series(&tmp);
        assert_eq!(result[0].cover_url, "/art/test-series/001.jpg");
    }

    #[test]
    fn series_sorted_by_date_descending() {
        let tmp = tempdir();
        // Create two series with different dates
        let dir_a = tmp.join("art").join("older");
        fs::create_dir_all(&dir_a).unwrap();
        fs::write(
            dir_a.join("series.toml"),
            r#"
title = "Older"
description = "Old series."
date = "2024-01-01"
[[images]]
file = "a.jpg"
alt = "a"
"#,
        )
        .unwrap();

        let dir_b = tmp.join("art").join("newer");
        fs::create_dir_all(&dir_b).unwrap();
        fs::write(
            dir_b.join("series.toml"),
            r#"
title = "Newer"
description = "New series."
date = "2025-06-15"
[[images]]
file = "b.jpg"
alt = "b"
"#,
        )
        .unwrap();

        let result = discover_series(&tmp);
        assert_eq!(result[0].title, "Newer");
        assert_eq!(result[1].title, "Older");
    }

    use std::sync::atomic::{AtomicU32, Ordering};
    static COUNTER: AtomicU32 = AtomicU32::new(0);

    fn tempdir() -> std::path::PathBuf {
        let id = COUNTER.fetch_add(1, Ordering::SeqCst);
        let dir = std::env::temp_dir().join(format!(
            "esart-test-{}-{}",
            std::process::id(),
            id
        ));
        let _ = fs::remove_dir_all(&dir);
        fs::create_dir_all(&dir).unwrap();
        dir
    }
}
