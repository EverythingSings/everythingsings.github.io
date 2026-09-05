# Generative background motion

Every background is rendered through the same two-stage WebGL pipeline:

1. The selected artwork renders unchanged into an offscreen texture.
2. A shared compositor transforms that texture using the current motion state.

This keeps motion independent from individual fragment shaders. Adding a new
entry to `SHADERS` automatically gives it inertial translation, rotation,
elastic impulse response, and subtle velocity separation.

## Input model

Pointer position and mobile sensors feed the same normalized two-axis target.
A spring-damper simulation turns that target into position and velocity. Device
acceleration is used only for short impulses; it is not integrated into a
persistent position because consumer accelerometers drift.

Mobile orientation is calibrated when tilt is enabled and is transformed into
screen coordinates for portrait and landscape use. Sensor listeners run only
after a user action, stop while the page is hidden, and never transmit data.
Pointer input is the automatic fallback.

## Generated material profiles

`generatedProfile(id)` hashes the stable background ID into mass, stiffness,
damping, travel, rotation, warp, and color-separation values. The result gives
each study a consistent physical character without adding per-shader metadata.
Profiles are deterministic across visits and deployments.

The compositor remains the universal baseline. New studies also receive optional
`u_pointer` (the smoothed two-axis position) and `u_impulse` uniforms, so their
geometry, light, or material can respond directly to the same input. Existing
studies that do not declare these uniforms continue to work unchanged.

## Invariants

- Fragment shaders only need `u_time`, `u_resolution`, and `void main()`.
- Motion permission is requested from the `Enable tilt` button, never on load.
- `prefers-reduced-motion` disables the animated canvas and its controls.
- The static HTML content remains complete without WebGL or JavaScript.

## Immersive viewing

The homepage's **Hide links** button opens the current study across the
viewport. The profile and links fade out and become inert; **Show links** or
Escape restores them, their scroll position, and focus on the entry button.
The original shader sources stay unchanged. A CSS brightness multiplier of four
reveals the deliberately dark legacy backgrounds while viewing a study. Registry
entries with `fullRange: true` render at their authored exposure in the viewer and
16% exposure behind the links. This is independent of the `featured` flag.

The title opens the existing searchable gallery. Previous/next and the arrow
keys switch studies; Space pauses when focus is on the viewing surface. Escape
closes an open gallery before leaving the viewer. Pause state is shared with the
background controls and paused studies redraw when the viewport is resized.

`?study=<stable-shader-id>&view=art` opens a particular study directly, taking
precedence over the saved preference. Entering adds a history entry and changing
studies replaces that entry. Browser Back/Forward restores the viewing mode.
Copy link uses the clipboard when available and otherwise exposes a selectable
URL. Links identify a study, not an exact animation frame or pointer position.

The entry button is enabled only after a shader loads successfully. Without
JavaScript, WebGL, or with reduced motion enabled, visitors get the complete
static homepage. Enabling reduced motion or losing the WebGL context while
viewing returns to the links.

## September 2026 additions

The collection now has 79 studies. The eight additions appear first in the
gallery, with distinct swatches. First-time visits sample this group; explicit
study URLs, saved preferences, and the original legacy indices take precedence.

| Study | Construction | Pointer response |
| --- | --- | --- |
| Lacuna | Ray-marched, breathing porcelain torus with 76 flutes | Viewing angle and key light |
| Silk Current | Four flowing bundles of fine, layered filaments | Flow displacement |
| Tidal Memory | Lit sediment height field with contours and a wandering inlet | Light across the terrain |
| Orbital Loom | Three separately rotating, engraved metal hoops | Viewing angle |
| Prismatic Fold | Pleated optical surface, spectral edges, traveling caustics | Fold displacement and light |
| Noctiluca | Independently breathing, translucent cellular membranes | Drift and touch impulse |
| Aperture Choir | Seven refracting lenses with rotating polygonal irises | Illumination and aperture offset |
| Palimpsest | Two interacting contour engravings on mineral paper | Engraving focal points |

Per-study `renderPixels` budgets cap the drawing buffer between 1.1 and 2.2
million pixels for the new work, while the original four-million-pixel ceiling
remains the default. These limits apply before the device-pixel-ratio cap.
No external textures, fonts, models, or image services are required.

## Browser verification

After building and generating `target/site`, serve it locally. With Playwright
installed, run:

```sh
node scripts/verify-gallery.cjs http://127.0.0.1:8765/
node scripts/capture-studies.cjs http://127.0.0.1:8765/
```

Set `PLAYWRIGHT_MODULE` to an installed module path if it is not on Node's normal
module search path, and `PLAYWRIGHT_CHANNEL=msedge` to use installed Microsoft
Edge. A second argument overrides the artifact directory.

The first script checks navigation, shared URLs, history, true pause, gallery
ordering, touch controls at three sizes, and JavaScript/WebGL/reduced-motion
fallbacks. The second captures every new study on desktop and mobile, checks the
actual selected title against the requested artwork, measures frame cadence,
and verifies temporal change and stable paused pixels. Screenshots and JSON
reports are written under `target/`; frame cadence is evidence for the tested
browser, GPU, and viewport only, not for a physical phone.
