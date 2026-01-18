//! # EverythingSings.art Static Site Generator
//!
//! Entry point for generating the static site. Run with `--generate-static`
//! to output HTML to `target/site/`.

use everythingsings::components::generate_head_html;
use everythingsings::App;
use leptos::prelude::*;
use std::env;
use std::fs;
use std::path::Path;

/// Generates the complete HTML document.
///
/// Combines the head (from `generate_head_html()`) and body (from Leptos SSR).
fn render_to_html() -> String {
    // Generate head HTML (with OG meta tags that need property attribute)
    let head_html = generate_head_html();

    // Render the app component (body only) to HTML string
    let body_html = App().to_html();

    format!(
        r#"<!DOCTYPE html>
<html lang="en">
{head_html}
{body_html}
</html>"#
    )
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
