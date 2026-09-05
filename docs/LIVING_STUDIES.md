# Living studies

Five studies extend the collection to 84. The three interactive fields evolve
from stored GPU state; they are not functions of wall-clock time alone.

| Study | Mechanism | Interaction |
| --- | --- | --- |
| Morphogenesis | Gray–Scott reaction–diffusion, six chemical updates per tick; embossed chemical concentration | Drag to plant a reagent |
| Ink Weather | Velocity advection, 16 Jacobi pressure iterations, pressure projection, and limited MacCormack pigment transport | Drag to add pigment and momentum |
| Resonant Basin | Damped wave equation with velocity diffusion, absorbing edges and balanced drop impulses; height-derived refraction | Drag or tap to disturb the water |
| Gyroid Reliquary | Ray-marched bounded gyroid membrane, cut plane, ambient occlusion and soft shadows | Pointer changes the view |
| Aster Glass | Analytic ellipsoid entry/exit intersections, Snell refraction for three wavelengths, absorption and Fresnel reflection | Pointer rotates the glass |

## Field storage and timing

`public/js/art-simulation.js` is imported only for a study with a `simulation`
registry entry. Each RGBA8 field stores two scalars in paired 16-bit channels.
This uses ordinary WebGL 1 render targets and does not require floating-point
framebuffer extensions. Dithering is disabled during numerical passes and its
previous state restored afterward. Signed quantities encode zero as exactly
32768, avoiding a constant forcing from representing zero halfway between codes.

The outer tick is fixed at 1/60 second. Accumulated time is capped at 50 ms per
render so a slow frame cannot create an unbounded catch-up loop. Hidden tabs,
pause and reduced motion stop stepping. On a slow device, simulation time may
advance more slowly than wall-clock time. The reaction field uses approximately
190,000 cells, fluid 115,000 and water 170,000, adapted to initial aspect ratio.
Construction includes a short deterministic warm-up.

Simulation studies bypass the global image-warp compositor so screen position
maps directly to brush position. Pointer capture allows a stroke to continue
across its starting element. A pending press survives a touch tap that begins
and ends between animation frames. Pause and leaving the viewer cancel input.

Resizing stretches the existing field without clearing it. Returning to the
homepage retains the current field; switching studies releases it. Context loss
returns to the static links. Restoration creates a new field. Restart creates
a new seed and respects the current pause state.

`?study=inkweather&view=art&seed=7` identifies the study and initial seed. It does
not save the current field, gesture history, elapsed evolution or initial aspect
ratio. Equal seeds reproduce initial conditions for equal dimensions on the
same renderer; floating-point shader behavior can differ between GPUs.

These are bounded numerical models composed as artworks. The water lighting is
an artistic approximation from local height/curvature, not a physically complete
caustic solver. The fluid uses a finite pressure solve and clamped velocities.

## Gallery previews

Every study has a 288 × 180 WebP preview captured from its actual WebGL render
at the correct viewing exposure. Images load lazily, use empty alt text beside
the study name, and have fixed dimensions. The immersive gallery shows a visual
grid; the background selector retains its compact layout. Original GLSL source
files and their stable registry indices remain intact.

The stylesheet, manager script, simulation module, fragment sources and previews
share a release cache key. Bump the head URLs and `ASSET_VERSION` together when
shipping changes that require matching UI and renderer assets.

To regenerate previews after serving the generated site:

```sh
node scripts/capture-previews.cjs http://127.0.0.1:8765/
```

Set `STUDIES=inkweather,resonantbasin` to limit either preview capture or
`capture-studies.cjs` to selected IDs. Regenerate the static site afterward to
copy preview files into the served output. The capture script checks the actual
selected ID before saving each image; a silently substituted shader is an error.

## Verification

```sh
cargo test --all-features --locked
cargo build --release --locked
./target/release/everythingsings --generate-static
node scripts/verify-gallery.cjs http://127.0.0.1:8765/
node scripts/verify-simulations.cjs http://127.0.0.1:8765/
node scripts/capture-studies.cjs http://127.0.0.1:8765/
```

`PLAYWRIGHT_MODULE` and `PLAYWRIGHT_CHANNEL` can select an existing Playwright
installation and browser. Each verification script accepts an output directory
as its second positional argument. Reports and screenshots live under `target/`.

The simulation verification creates paired real GPU simulations with identical
seeds and step counts. Their fields must match before one receives a stroke and
remain different 90 unforced ticks afterward. It reads numerical fields back,
checks their ranges, confirms pressure projection reduces divergence, and checks
WebGL errors and dithering restoration. Separate integration checks use trusted
mouse/touch input, verify exact paused field preservation through resize and
hide/show, and exercise Restart and shared seeds at three mobile viewport sizes.
The read-only `window.__ART_GALLERY__.snapshot(true)` reports the current field's
checksum, range and, for fluid, divergence before/after the last projection. This
readback is opt-in for diagnosis; ordinary rendering never reads pixels to CPU.

Frame timings and touch emulation describe the tested browser, GPU and viewport.
They do not establish performance on a physical phone.

## Algorithm references

- [Karl Sims: Reaction–Diffusion Tutorial](https://www.karlsims.com/rd.html)
- [Mark Harris: Fast Fluid Dynamics Simulation on the GPU, GPU Gems 38](https://developer.nvidia.com/gpugems/gpugems/part-vi-beyond-triangles/chapter-38-fast-fluid-dynamics-simulation-gpu)

The implementation and visual compositions are local to this repository; these
references explain the chemical and fluid update methods.
