# Overview

This is a Bowling All prototype for AndroidXR made in Godot 4.7.  

## References

- Gogot 4.7 https://godotengine.org/article/release-candidate-godot-4-7-rc-2/
- AndroidXR https://developer.android.com/reference/kotlin/androidx/compose/runtime/package-summary
- Bowling Rules https://en.wikipedia.org/wiki/Bowling

## Requirements

- R1: A bowling alley has a lane built from a wood surface, 10 pins, and a bolwing ball. 
- R2: We don't need to follow real bowling rules, our goal is a visually interesting experience
- R3: Bowling pins should have a floating number assigned to them , per standard pin numbering: https://www.thesportofbowling.com/blog/bowling-pin-numbers/
- R4: A bowling ball weights 6-16lbs, and we will simulate standard world physics for a ball and normal earth gravity
- R5: bowling pins are made of wood and painted white, and we will expect the ball to exercise standard vector physics and newtons law of inertia
- R6: We want sound effects when the ball hits a pin
- R7: The user has a ball attached to their (left or right) and a throw will happen when velocity and forward motion stops, and the trajectory of the ball will follow the phyics of the vector of the strow
- R8: when a ball hits a pin, fallent pins stay down. 
- R9: when a ball reaches the back of the bowling lane, or reaches complete zero motion, it resets to the user's hand
- R10: play continues until all pins are knocked down in practice mode
- R11: our game needs a startup menu, and the only menu item is practice, about, and quit
- R12: in game we need a way to quit back to the main menu
- R13: the design asthetic is synthwave bowlerama
- R14: The game is called BowleramaXR
- R15: The ongoing music theme is synthwave that is sort of randomized

## UI Spec

See [DESIGN.md](DESIGN.md) for the full design. Summary:

- **Aesthetic**: synthwave — dark purple/magenta sky, scanline "sun", neon
  wireframe grid horizon, emissive neon trim on lane/ball/pins. All procedural
  (shaders + emissive materials + WorldEnvironment glow), no image assets.
- **Main menu** (R11): floating 2D-in-3D panel titled **BowleramaXR** in the
  synthwave void. Items: **Practice**, **About**, **Quit**. Pointer-driven via
  godot-xr-tools `function_pointer`.
- **About**: short panel with title and credits; back button returns to menu.
- **In-game HUD** (R12): a floating **MENU** button at the foul line (and/or a
  controller face-button) to quit back to the main menu. Win state shows a
  celebratory message before auto re-rack.
- **Ball cradle**: a glowing snap zone at the foul line holding the ball at rest
  and serving as its return target after each throw (R9).
- **Pin numbers** (R3): billboard `Label3D` floating above each pin, standard
  1–10 layout (head pin nearest the player).

## Test Plan

Manual on-device (Android XR / OpenXR) plus in-editor checks, mapped to requirements:

| # | Test | Expect | Reqs |
|---|------|--------|------|
| T1 | Launch app | Immersive synthwave world (no passthrough); BowleramaXR menu visible | R13, R14 |
| T2 | Menu pointer | Practice / About / Quit selectable; Quit exits; About opens/returns | R11 |
| T3 | Start Practice | Lane, 10 pins in standard triangle, ball in cradle | R1, R10 |
| T4 | Pin numbers | Each pin shows correct floating number (1–10), billboarded | R3 |
| T5 | Grab ball | Grip with either hand attaches ball; release detaches | R7 |
| T6 | Throw physics | Released ball flies along swing vector under gravity; rolls on lane | R4, R5, R7 |
| T7 | Pin collision | Ball knocks pins; struck pins transfer momentum realistically | R5, R8 |
| T8 | Pins stay down | Fallen pins remain down for the rest of the frame/throw | R8 |
| T9 | Hit sound | Audible clack on ball↔pin and pin↔pin contact | R6 |
| T10 | Ball reset | Ball returns to cradle when it reaches lane end or stops | R9 |
| T11 | Win | All 10 down → win FX → auto re-rack; play continues | R10 |
| T12 | In-game quit | MENU control returns to main menu mid-game | R12 |
| T13 | Music | Synthwave plays, varies over time, no repeats; no audio dropouts on-device | R15 |
| T14 | Performance | Stable framerate on target headset under glow + physics load | — |

