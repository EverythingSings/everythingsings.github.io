//! # Sigil Page
//!
//! EverythingSings logo as a Lissajous curve, rendered as pure SVG.

use leptos::prelude::*;

use super::nav::Nav;

/// Generates an SVG path for a Lissajous curve.
/// x(t) = A * sin(a*t + delta), y(t) = B * sin(b*t)
fn lissajous_path(a: f64, b: f64, delta: f64, steps: usize, scale: f64) -> String {
    let mut d = String::new();
    for i in 0..=steps {
        let t = 2.0 * std::f64::consts::PI * (i as f64) / (steps as f64);
        let x = scale * (a * t + delta).sin();
        let y = scale * (b * t).sin();
        if i == 0 {
            d.push_str(&format!("M {:.2} {:.2}", x, y));
        } else {
            d.push_str(&format!(" L {:.2} {:.2}", x, y));
        }
    }
    d.push_str(" Z");
    d
}

/// The Sigil page — EverythingSings logo as Lissajous curve.
#[component]
pub fn SigilPage() -> impl IntoView {
    // Lissajous parameters: a=2, b=3, delta=pi/2 — the EverythingSings sigil
    let path = lissajous_path(2.0, 3.0, std::f64::consts::FRAC_PI_2, 512, 140.0);

    view! {
        <body itemscope itemtype="https://schema.org/WebPage">
            <canvas id="shader-canvas" aria-hidden="true"></canvas>
            <noscript>
                <style>"#shader-canvas { display: none; }"</style>
            </noscript>
            <main class="container sigil-container">
                <Nav />
                <div class="sigil-page" itemscope itemtype="https://schema.org/ImageObject">
                    <h1 itemprop="name" class="sigil-title">"Sigil"</h1>
                    <p class="sigil-subtitle" itemprop="description">"EverythingSings — Lissajous curve logo"</p>
                    <div class="sigil-artwork">
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="-160 -160 320 320"
                            class="sigil-svg"
                            role="img"
                            aria-label="EverythingSings sigil — a Lissajous curve"
                        >
                            <path
                                d={path}
                                fill="none"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            />
                        </svg>
                    </div>
                </div>
            </main>
            <footer>
                <p>"EverythingSings"</p>
            </footer>
        </body>
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sigil_page_renders_svg() {
        let html = SigilPage().to_html();
        assert!(html.contains("<svg"));
        assert!(html.contains("Lissajous"));
    }

    #[test]
    fn lissajous_path_is_closed() {
        let path = lissajous_path(3.0, 2.0, std::f64::consts::FRAC_PI_2, 64, 100.0);
        assert!(path.starts_with("M "));
        assert!(path.ends_with(" Z"));
    }
}
