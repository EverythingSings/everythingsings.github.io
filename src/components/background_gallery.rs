//! Shared controls for the WebGL background gallery.

use leptos::prelude::*;

#[component]
pub fn BackgroundGallery() -> impl IntoView {
    view! {
        <aside id="background-controls" aria-label="Background gallery">
            <button
                id="background-tab"
                type="button"
                aria-expanded="false"
                aria-controls="background-panel"
            >
                <span class="background-tab-label">"Background"</span>
                <span id="background-current">"Loading"</span>
            </button>
            <section id="background-panel" aria-label="Choose a background" hidden>
                <div class="background-panel-heading">
                    <span>"Backgrounds"</span>
                    <span id="background-count" aria-live="polite">"Background studies"</span>
                </div>
                <input
                    id="background-filter"
                    type="search"
                    aria-label="Find a background"
                    aria-controls="background-list"
                    placeholder="Find a background"
                    autocomplete="off"
                />
                <div id="background-list" role="listbox" aria-label="Shader backgrounds"></div>
                <p id="background-empty" hidden>"No backgrounds match."</p>
                <div class="background-tools">
                    <button id="background-motion" type="button" aria-pressed="false">"Pause motion"</button>
                    <button id="background-tilt" type="button" aria-pressed="false" hidden>"Enable tilt"</button>
                    <button id="background-shuffle" type="button" aria-label="Random background">"Shuffle"</button>
                </div>
                <p id="background-input-status" aria-live="polite">"Pointer-responsive"</p>
                <div class="background-stepper">
                    <button id="background-prev" type="button" aria-label="Previous background">{"\u{2190}"}</button>
                    <p id="background-status" aria-live="polite">"Background loading"</p>
                    <button id="background-next" type="button" aria-label="Next background">{"\u{2192}"}</button>
                </div>
            </section>
        </aside>
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn gallery_exposes_direct_and_random_controls() {
        let html = BackgroundGallery().to_html();
        assert!(html.contains("role=\"listbox\""));
        assert!(html.contains("aria-label=\"Find a background\""));
        assert!(html.contains("aria-controls=\"background-list\""));
        assert!(html.contains("aria-label=\"Random background\""));
        assert!(html.contains("id=\"background-tilt\""));
        assert!(html.contains("id=\"background-input-status\""));
        assert!(html.contains("aria-live=\"polite\""));
    }
}
