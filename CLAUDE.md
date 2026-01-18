# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EverythingSings.art is a self-hosted, AI-crawler-accessible landing page replacing Linktree. Built with Rust Leptos in islands mode for static site generation, deployed to GitHub Pages.

**Core principle:** Machine-first, human-enhanced. AI crawlers cannot execute JavaScript, so all content must be accessible as static HTML.

## Build Commands

```bash
# Install build tool (first time only)
cargo install cargo-leptos

# Development with hot reload
cargo leptos watch

# Production build
cargo leptos build --release

# Generate static site (run after production build)
./target/release/everythingsings --generate-static
```

Output goes to `target/site/` for deployment.

## Architecture

### Leptos Islands Mode

- All `#[component]` functions render **server-side only** as pure HTML
- Only `#[island]` marked code compiles to WASM and hydrates client-side
- Target: ~24KB WASM stub (zero islands) vs 274-355KB full hydration
- Components can use `std::fs` directly since they only run at build time

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

GitHub Actions workflow builds with cargo-leptos and deploys `target/site/` to GitHub Pages. DNS configured for everythingsings.art domain.
