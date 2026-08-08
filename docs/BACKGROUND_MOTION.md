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

If a future artwork needs deliberate art direction, explicit profile values can
be added to its registry entry and merged over the generated defaults. The
compositor remains the universal baseline.

## Invariants

- Fragment shaders only need `u_time`, `u_resolution`, and `void main()`.
- Motion permission is requested from the `Enable tilt` button, never on load.
- `prefers-reduced-motion` disables the animated canvas and its controls.
- The static HTML content remains complete without WebGL or JavaScript.
