# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EverythingSings.art is a self-hosted, AI-crawler-accessible landing page replacing Linktree. Built with Rust Leptos for pure server-side static site generation, deployed to GitHub Pages.

**Core principle:** Machine-first, human-enhanced. AI crawlers cannot execute JavaScript, so all content must be accessible as static HTML. This project deliberately uses **zero JavaScript/WASM** to ensure 100% crawler accessibility.

## Build Commands

```bash
# Development: build and generate static site
cargo build && ./target/debug/everythingsings --generate-static

# Production build
cargo build --release && ./target/release/everythingsings --generate-static

# Serve locally (after generating)
python -m http.server 8080 --directory target/site
```

Output goes to `target/site/` for deployment.

## Architecture

### Pure SSR (No WASM/JavaScript)

- All `#[component]` functions render **server-side only** as pure HTML
- No `#[island]` components - intentionally zero client-side JavaScript
- Custom SSG binary generates complete static HTML at build time
- Components can use `std::fs` directly since they only run at build time
- `crate-type = ["rlib"]` (not cdylib) - no WASM compilation needed

### Semantic Markup Layers (All Three Required)

1. **JSON-LD** in `<head>` - Schema.org structured data for AI/search engines
2. **Microformats2 h-card** in body - IndieWeb compatibility, `rel="me"` identity verification
3. **Schema.org microdata** via `itemscope`/`itemprop` - Defense-in-depth parsing

### Required Static Files

| File | Purpose |
|------|---------|
| `/llms.txt` | AI-optimized Markdown sitemap for LLM consumption |
| `/robots.txt` | Explicitly allow GPTBot, ClaudeBot, PerplexityBot, etc. |
| `/feed.xml` | RSS feed for content syndication |
| `/sitemap.xml` | Standard XML sitemap |

### Key CSS Classes for Semantic HTML

- `.h-card` - Microformats2 person/org container
- `.p-name`, `.p-note` - Microformats2 properties
- `.u-photo`, `.u-url`, `.u-email` - Microformats2 URL properties
- `rel="me"` - Bidirectional identity verification links

## Testing AI Accessibility

```bash
# Verify content is accessible without JavaScript
curl https://everythingsings.art

# Validate structured data
# Use Google Rich Results Test or Schema.org validator
```

## Deployment

GitHub Actions workflow runs `cargo build --release` then `./target/release/everythingsings --generate-static` and deploys `target/site/` to GitHub Pages. DNS configured for everythingsings.art domain.
