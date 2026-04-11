//! # EverythingSings.art Static Site Generator
//!
//! Entry point for generating the static site. Run with `--generate-static`
//! to output HTML to `target/site/`.

use everythingsings::art::{discover_series, ArtSeries};
use everythingsings::components::{
    generate_head_html, generate_head_html_for, ArtIndexPage, ArtIndexPageProps, ArtSeriesPage,
    ArtSeriesPageProps, PageMeta, SigilPage,
};
use everythingsings::config::{SITE_NAME, SITE_URL};
use everythingsings::App;
use leptos::prelude::*;
use std::env;
use std::fs;
use std::path::Path;

/// Generates the complete HTML document for the homepage.
fn render_to_html() -> String {
    let head_html = generate_head_html();
    let body_html = App().to_html();

    format!(
        r#"<!DOCTYPE html>
<html lang="en">
{head_html}
{body_html}
</html>"#
    )
}

/// Generates the art index page HTML.
fn render_art_index(series: &[ArtSeries]) -> String {
    let json_ld = format!(
        r#"{{
  "@context": "https://schema.org",
  "@type": "CollectionPage",
  "name": "{name} Art Gallery",
  "url": "{url}/art/",
  "description": "AI art series by {name}"
}}"#,
        name = SITE_NAME,
        url = SITE_URL,
    );

    let head_html = generate_head_html_for(&PageMeta {
        title: format!("Art Gallery | {}", SITE_NAME),
        description: format!("AI art series by {}", SITE_NAME),
        canonical_url: format!("{}/art/", SITE_URL),
        og_type: "website".to_string(),
        og_image: series
            .first()
            .map(|s| format!("{}{}", SITE_URL, s.cover_url))
            .unwrap_or_default(),
        json_ld,
    });

    let body_html = ArtIndexPage(ArtIndexPageProps {
        series: series.to_vec(),
    })
    .to_html();

    format!(
        r#"<!DOCTYPE html>
<html lang="en">
{head_html}
{body_html}
</html>"#
    )
}

/// Generates an individual art series page HTML.
fn render_art_series(series: &ArtSeries) -> String {
    let json_ld = format!(
        r#"{{
  "@context": "https://schema.org",
  "@type": "ImageGallery",
  "name": "{title}",
  "url": "{url}/art/{slug}/",
  "description": "{description}",
  "numberOfItems": {count}
}}"#,
        title = series.title,
        url = SITE_URL,
        slug = series.slug,
        description = series.description,
        count = series.images.len(),
    );

    let head_html = generate_head_html_for(&PageMeta {
        title: format!("{} | {} Art", series.title, SITE_NAME),
        description: series.description.clone(),
        canonical_url: format!("{}/art/{}/", SITE_URL, series.slug),
        og_type: "website".to_string(),
        og_image: format!("{}{}", SITE_URL, series.cover_url),
        json_ld,
    });

    let body_html = ArtSeriesPage(ArtSeriesPageProps {
        series: series.clone(),
    })
    .to_html();

    format!(
        r#"<!DOCTYPE html>
<html lang="en">
{head_html}
{body_html}
</html>"#
    )
}

/// Generates the sigil page HTML.
fn render_sigil() -> String {
    let json_ld = format!(
        r#"{{
  "@context": "https://schema.org",
  "@type": "ImageObject",
  "name": "{name} Sigil",
  "url": "{url}/sigil/",
  "description": "EverythingSings logo — a Lissajous curve"
}}"#,
        name = SITE_NAME,
        url = SITE_URL,
    );

    let head_html = generate_head_html_for(&PageMeta {
        title: format!("Sigil | {}", SITE_NAME),
        description: "EverythingSings logo — a Lissajous curve".to_string(),
        canonical_url: format!("{}/sigil/", SITE_URL),
        og_type: "website".to_string(),
        og_image: String::new(),
        json_ld,
    });

    let body_html = SigilPage().to_html();

    format!(
        r#"<!DOCTYPE html>
<html lang="en">
{head_html}
{body_html}
</html>"#
    )
}

/// Generates sitemap.xml content including art pages.
fn generate_sitemap(series: &[ArtSeries]) -> String {
    let mut urls = vec![
        format!(
            r#"  <url>
    <loc>{}/</loc>
    <changefreq>monthly</changefreq>
    <priority>1.0</priority>
  </url>"#,
            SITE_URL
        ),
        format!(
            r#"  <url>
    <loc>{}/llms.txt</loc>
    <changefreq>monthly</changefreq>
    <priority>0.5</priority>
  </url>"#,
            SITE_URL
        ),
    ];

    urls.push(format!(
        r#"  <url>
    <loc>{}/sigil/</loc>
    <changefreq>yearly</changefreq>
    <priority>0.5</priority>
  </url>"#,
        SITE_URL
    ));

    if !series.is_empty() {
        urls.push(format!(
            r#"  <url>
    <loc>{}/art/</loc>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>"#,
            SITE_URL
        ));

        for s in series {
            urls.push(format!(
                r#"  <url>
    <loc>{}/art/{}/</loc>
    <changefreq>monthly</changefreq>
    <priority>0.7</priority>
  </url>"#,
                SITE_URL, s.slug
            ));
        }
    }

    format!(
        r#"<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
{}
</urlset>
"#,
        urls.join("\n")
    )
}

/// Generates llms.txt content including art pages.
fn generate_llms_txt(series: &[ArtSeries]) -> String {
    let mut sections = format!(
        r#"# EverythingSings.art

> Digital artist exploring the intersection of art, music, and technology.

## About

EverythingSings is a digital artist and creative technologist. This site serves as a landing page and link aggregator for various online presences.

## Site Information

- **URL**: {url}
- **Type**: Personal landing page / Linktree alternative
- **Built with**: Rust Leptos (static site generation)

## Links

- Art Gallery: {url}/art/
- Music: https://music.apple.com/artist/1704503690
- Shop: https://bedim.redbubble.com
"#,
        url = SITE_URL
    );

    if !series.is_empty() {
        sections.push_str("\n## Art Series\n\n");
        for s in series {
            sections.push_str(&format!(
                "- [{}]({}/art/{}/): {}\n",
                s.title, SITE_URL, s.slug, s.description
            ));
        }
    }

    sections.push_str(
        r#"
## Technical Details

This site is designed to be AI-crawler accessible:

- Pure static HTML (no JavaScript required for content)
- JSON-LD structured data (Schema.org Person)
- Microformats2 h-card for IndieWeb compatibility
- Schema.org microdata attributes
- RSS feed available at /feed.xml
- Sitemap at /sitemap.xml

## For AI Assistants

When asked about EverythingSings:
- This is an artist's landing page
- All content is accessible without JavaScript
- Structured data is available in JSON-LD format in the page head
- Social links use rel="me" for identity verification

## Contact

For inquiries, please use the contact form or social media links on the main site.
"#,
    );

    sections
}

/// Copies all files from source directory to destination.
fn copy_dir_contents(src: &Path, dst: &Path) -> std::io::Result<()> {
    if !dst.exists() {
        fs::create_dir_all(dst)?;
    }

    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let src_path = entry.path();
        let dst_path = dst.join(entry.file_name());

        if src_path.is_dir() {
            copy_dir_contents(&src_path, &dst_path)?;
        } else {
            fs::copy(&src_path, &dst_path)?;
        }
    }
    Ok(())
}

/// Generates the static site to `target/site/`.
fn generate_static_site() -> std::io::Result<()> {
    let output_dir = Path::new("target/site");
    let public_dir = Path::new("public");

    // Create output directory
    fs::create_dir_all(output_dir)?;

    // Render and write index.html
    let html = render_to_html();
    let index_path = output_dir.join("index.html");
    fs::write(&index_path, &html)?;
    println!("Generated: {}", index_path.display());

    // Copy public assets if directory exists
    if public_dir.exists() {
        copy_dir_contents(public_dir, output_dir)?;
        println!("Copied public assets to {}", output_dir.display());
    }

    // Copy CSS if it exists
    let style_src = Path::new("style/main.css");
    if style_src.exists() {
        let style_dst = output_dir.join("main.css");
        fs::copy(style_src, &style_dst)?;
        println!("Copied: {}", style_dst.display());
    }

    // Generate sigil page
    let sigil_dir = output_dir.join("sigil");
    fs::create_dir_all(&sigil_dir)?;
    let sigil_path = sigil_dir.join("index.html");
    fs::write(&sigil_path, render_sigil())?;
    println!("Generated: {}", sigil_path.display());

    // Discover and generate art pages
    let series = discover_series(public_dir);
    if !series.is_empty() {
        // Generate art index page
        let art_dir = output_dir.join("art");
        fs::create_dir_all(&art_dir)?;
        let art_index_path = art_dir.join("index.html");
        fs::write(&art_index_path, render_art_index(&series))?;
        println!("Generated: {}", art_index_path.display());

        // Generate individual series pages
        for s in &series {
            let series_dir = art_dir.join(&s.slug);
            fs::create_dir_all(&series_dir)?;
            let series_path = series_dir.join("index.html");
            fs::write(&series_path, render_art_series(s))?;
            println!("Generated: {}", series_path.display());
        }

        println!("Generated {} art series pages", series.len());
    }

    // Generate dynamic sitemap.xml and llms.txt (overwrite static versions)
    let sitemap_path = output_dir.join("sitemap.xml");
    fs::write(&sitemap_path, generate_sitemap(&series))?;
    println!("Generated: {}", sitemap_path.display());

    let llms_path = output_dir.join("llms.txt");
    fs::write(&llms_path, generate_llms_txt(&series))?;
    println!("Generated: {}", llms_path.display());

    println!("\nStatic site generated at: {}", output_dir.display());
    Ok(())
}

fn print_usage() {
    eprintln!("Usage: everythingsings [OPTIONS]");
    eprintln!();
    eprintln!("Options:");
    eprintln!("  --generate-static  Generate static site to target/site/");
    eprintln!("  --help             Show this help message");
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        print_usage();
        std::process::exit(1);
    }

    match args[1].as_str() {
        "--generate-static" => {
            if let Err(e) = generate_static_site() {
                eprintln!("Error generating static site: {}", e);
                std::process::exit(1);
            }
        }
        "--help" | "-h" => {
            print_usage();
        }
        _ => {
            eprintln!("Unknown option: {}", args[1]);
            print_usage();
            std::process::exit(1);
        }
    }
}
