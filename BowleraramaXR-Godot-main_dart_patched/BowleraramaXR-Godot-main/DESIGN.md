# BowleramaXR — Design

A synthwave bowling prototype for **Android XR**, built in **Godot 4.7** using
**OpenXR** and **godot-xr-tools**. See [FSD.md](FSD.md) for requirements (R1–R15).

## Platform note

The AndroidXR reference in the FSD (`androidx.compose.runtime`) is the Jetpack
Compose API for *native Kotlin* XR apps. We are committed to the **Godot
approach**, so we do **not** use Compose. Godot reaches the headset through
**OpenXR**, already configured in this template (`openxr/enabled=true`,
hand-interaction profile on, foveation level 3). Our effective "AndroidXR API"
is *Godot OpenXR + godot-xr-tools*.

## Confirmed design decisions

| Topic | Decision | Notes |
|-------|----------|-------|
| Environment | **Full immersive synthwave** (passthrough off) | Best sells R13. Procedural — no image assets. |
| Lane scale | **Compressed ~7m lane** | Keeps pins readable & action punchy; R2 frees us from real rules. |
| Throw | **Grip-to-grab, release-to-throw** | Uses XR Tools release-velocity physics (R7). |
| Music | **Fully procedural synth** | In-engine synthesis, no audio assets (R15). |

## What the template gives us for free

- **godot-xr-tools `pickable`** — grab + on-release imparts controller
  linear/angular velocity → our throw physics (R7).
- **`snap_zone` / `return_to_snap_zone`** — ball cradle the ball returns to (R9).
- **`viewport_2d_in_3d` + `function_pointer`** — floating 2D menus (R11, R12).
- **Jolt physics** — ball↔pin collisions (R4, R5, R8).
- **Glow / MSAA / foveation / VRS** — already enabled; neon look = emissive + glow.

## Visual style (all procedural)

- **Synthwave sky**: purple→magenta gradient + emissive "sun" disc with scanline
  bands, via a shader on a quad.
- **Grid horizon/floor**: large plane with a shader drawing perspective +
  scrolling neon horizontal lines.
- **Lane & pins**: dark surfaces with emissive neon edge trim; pins are
  white "wood" (R5) rimmed in neon. WorldEnvironment glow provides bloom.

## Scene & code architecture

```
res://
  autoload/
    game_state.gd        # mode, pins-remaining, win logic, scene swap
  game/
    main_menu.tscn/.gd   # Practice / About / Quit (2D-in-3D panel)
    alley.tscn/.gd       # immersive bowling world
    ball/  ball.tscn/.gd # pickable RigidBody3D, neon sphere
    pin/   pin.tscn/.gd  # RigidBody3D + floating Label3D number + hit sound
    pin_rack.gd          # spawns 10 pins, detects all-down
    cradle.tscn          # snap/return zone at the foul line
  fx/shaders/            # synth_sun, synth_grid, neon_edge .gdshader
  audio/
    music_director.gd    # autoload — procedural synthwave engine
    synth/ voice.gd  sequencer.gd  delay.gd
  ui/  synthwave_theme.tres
```

Autoloads: keep existing `XRToolsUserSettings`, `XRToolsRumbleManager`; add
`GameState` and `MusicDirector`.

## Pins (R3 numbering)

Standard triangle, head pin nearest the player, floating billboard `Label3D`
numbers above each:

```
        [7] [8] [9] [10]     back row
          [4] [5] [6]
            [2] [3]
              [1]            head pin (nearest you)
```

**Knockdown detection**: each pin compares its up-vector tilt against an upright
threshold; once past it (or knocked off its base) it is "down" and stays down
(R8). When all 10 are down → `GameState` win → celebratory FX → auto re-rack
(R10). No scorecard (R2).

## Ball & throw (R4, R5, R7, R9)

- `pickable` RigidBody3D, sphere collision, mass ~5 kg (R4: 6–16 lb).
- Grab with grip; release imparts controller velocity → throw.
- A snap/return cradle at the foul line returns the ball to hand reach after the
  throw completes — i.e. when it reaches the lane's back or hits ~zero motion (R9).
- Grabbable by either hand (R7).

## Sound (R6)

Pin-hit "clack" via `AudioStreamPlayer3D` triggered on collision (contact
monitor). Generated procedurally (noise burst + pitch) to stay asset-free,
consistent with the music approach.

## Procedural music engine (R15)

`MusicDirector` autoload synthesizing synthwave in-engine, **no audio assets**:

- **Voices**: saw/square/sine oscillators with ADSR — bass, arp lead, pad, and
  drums (sine kick, noise snare/hat).
- **Sequencer**: minor-key progressions (Am–F–C–G family), randomized arp
  patterns and progression order → never repeats (the "randomized" in R15).
- **FX**: feedback delay/echo for the synthwave shimmer.
- ⚠️ **Mobile-XR perf**: per-sample GDScript synthesis on a standalone headset
  is CPU-heavy. Plan: synthesize **one bar at a time into a buffer on a
  background thread, then queue it** — still 100% procedural, but won't starve
  the audio thread. Validate on-device early.

## Menus & flow (R11, R12, R14)

- **Boot → Main Menu**: floating panel titled **BowleramaXR** in the synthwave
  void; items **Practice / About / Quit**; pointer-driven.
- **Practice** → fade to `alley.tscn`, rack pins, ball in cradle.
- **In-game quit (R12)**: a floating "MENU" button at the foul line (or a
  controller face-button) → back to main menu.
- **About**: short title/credits panel.

## Build milestones

1. **World** — immersive env, sun + grid shaders, lane, glow (passthrough off).
2. **Ball** — pickable + cradle + throw + auto-return.
3. **Pins** — rack + numbers + knockdown + win/re-rack.
4. **SFX** — procedural pin hit.
5. **Music** — procedural engine (validate threaded synthesis on-device early).
6. **Menus** — main, in-game quit, about.
7. **Polish** — haptics on grab/hit, strike particles, on-device perf pass.

## Top risks

- Procedural-music CPU cost on standalone hardware (mitigation above).
- Glow + transparency cost in the mobile renderer — keep neon emissive; lean on
  foveation/VRS already enabled.
- Hand-tracking vs controllers — target **controllers first**, hands as a stretch.
