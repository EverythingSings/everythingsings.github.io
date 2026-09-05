//! Immersive viewing controls, enhanced by the existing shader manager.

use leptos::prelude::*;

#[component]
pub fn ArtEntry() -> impl IntoView {
    view! {
        <div class="art-entry" hidden>
            <button id="art-enter" type="button" aria-controls="art-viewer">
                <span>"Hide links"</span>
                <span aria-hidden="true">"↗"</span>
            </button>
        </div>
    }
}

#[component]
pub fn ArtViewer() -> impl IntoView {
    view! {
        <section id="art-viewer" aria-label="Art viewer" tabindex="-1" hidden>
            <div class="art-viewer-top">
                <button id="art-exit" type="button"><span aria-hidden="true">"← "</span>"Show links"</button>
                <span class="art-signature">"EverythingSings"</span>
            </div>
            <div class="art-viewer-bottom">
                <button id="art-choose" type="button" aria-expanded="false" aria-controls="background-panel" aria-label="Choose a study">
                    <span id="art-position" class="art-eyebrow"></span>
                    <span class="art-title-line"><span id="art-title"></span><span class="art-browse">"Browse ↗"</span></span>
                </button>
                <div class="art-actions" aria-label="Study controls">
                    <div class="art-transport">
                        <button id="art-prev" type="button" aria-label="Previous study">"←"</button>
                        <button id="art-motion" type="button" aria-pressed="false">"Pause"</button>
                        <button id="art-next" type="button" aria-label="Next study">"→"</button>
                    </div>
                    <button id="art-share" type="button">"Copy link"</button>
                </div>
                <div id="art-share-fallback" hidden>
                    <label for="art-share-url">"Copy this study’s link"</label>
                    <input id="art-share-url" type="text" readonly />
                </div>
                <p id="art-notice" role="status" aria-live="polite"></p>
            </div>
        </section>
    }
}
