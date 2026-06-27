Godot Android XR Template
=========================

This is a lightweight Godot project that is already setup to run on
Android XR or Meta Quest 3!

For XR glasses like project Aura, this defaults to a "passthrough" rather
than "immersive" experience.

For an immersive design like a VR HMD, we specify immersive.

<p align="center">
  <img width="430" alt="BowleramaXR — synthwave bowling, immersive view"
       src="https://github.com/user-attachments/assets/0803d880-b03f-408d-b3d2-3ebd3363adea" />
</p>

## Godot XR Tools

This template comes with the
[Godot XR Tools](https://github.com/GodotVR/godot-xr-tools) addon
pre-installed.

It provides many useful XR utilities, for example, rendering 2D UIs
and letting the user interact with them via a pointer attached to
their hands.

Please see the
[XR Tools documentation](https://github.com/GodotVR/godot-xr-tools/wiki)
for more information.

## Installation

Getting an Android XR / Meta Quest project to actually build is the part that
is poorly documented. Here is the full, tested sequence.

### 1. Install Godot 4.7

Android XR support and the OpenXR vendor plugins require **Godot 4.7 or newer**
(the standard build — you do *not* need the .NET/Mono build unless you are
writing C#). Download it from [godotengine.org](https://godotengine.org/download)
or use the exact editor you already have, e.g.:

```
C:\Users\<you>\dev\tools\godot.windows.editor.x86_64.exe
```

### 2. Install the matching Export Templates

The editor ships *without* the platform export binaries. Install them so Godot
can produce an `.apk`:

1. Open the project in Godot.
2. **Editor → Manage Export Templates…**
3. Either **Download and Install** the templates that match your editor version
   exactly (4.7), or, if you downloaded the
   `Godot_v4.7-stable_export_templates.tpz` archive manually, choose
   **Install from File** and point at it.

The version of the templates **must** match the editor version, or exports fail
with a "templates not found / version mismatch" error.

### 3. Install the Android Build Template (Gradle build)

XR requires a **custom Gradle build** so the OpenXR vendor libraries (Meta /
Android XR) and the GDExtension plugin can be packaged into the APK. The stock,
non-Gradle export path will *not* include them.

1. **Project → Install Android Build Template…**
2. This unpacks `android_source.zip` into `res://android/build` in your project.
   You should see an `android/` folder appear next to `game/`, `addons/`, etc.
3. In **Project → Export… → Android**, make sure **Gradle Build → Use Gradle
   Build** is enabled (this template's presets already have it on).

> If you re-download the export templates, re-run *Install Android Build
> Template* so `res://android/build` matches the new version.

### 4. Android SDK / JDK prerequisites

Godot drives the Gradle build using your local Android SDK and a JDK:

- **OpenJDK 17** (required by the current Android Gradle Plugin).
- **Android SDK** with platform-tools, a recent build-tools, and an SDK
  platform (API 34+). The easiest way to get a consistent set is to install
  [Android Studio](https://developer.android.com/studio) once and let it pull
  the SDK, or use the command-line `sdkmanager`.

Then point Godot at them in **Editor → Editor Settings → Export → Android**:

- **Android SDK Path** → your SDK root (e.g. `C:\Users\<you>\AppData\Local\Android\Sdk`).
- A **debug keystore** is generated automatically on first export; for release
  builds set your own.

### 5. Choosing the deploy target (Meta Quest vs Android XR)

This project carries **two export presets**, identical except for which OpenXR
vendor is bundled:

| Preset       | Vendor plugin enabled | Runs on              |
|--------------|-----------------------|----------------------|
| `Meta Quest` | Meta                  | Quest 2 / 3 / 3S / Pro |
| `Android XR` | Android XR (Google)   | Android XR devices / emulator, e.g. Aura |

Only **one preset can be "Runnable" at a time**, and that flag is what Remote
Deploy uses. Switch targets in **Project → Export…** by checking **Runnable** on
the preset you want.

> Mismatch symptom: deploying the `Android XR` preset to a Quest fails with
> `INSTALL_FAILED_MISSING_SHARED_LIBRARY ... libopenxr.google.so`. That library
> only exists on Google Android XR devices — the Quest uses the Meta runtime.
> Switch the Runnable preset back to `Meta Quest`.

### 6. Deploy to the headset

1. Enable **Developer Mode** on the device and connect it over USB.
2. Accept the **"Allow USB debugging"** prompt *inside the headset* — otherwise
   the device shows as `unauthorized` and will not appear in Remote Deploy.
3. Confirm the device is visible:
   ```
   adb devices
   ```
4. In Godot, use the **Remote Deploy** button (top-right, the little Android
   icon) to build and install the runnable preset onto the device.

## Viewing the experience with scrcpy

Because the action happens inside the headset, the easiest way to *see and
record* what the player sees — for debugging, demos, or screenshots — is
[**scrcpy**](https://github.com/Genymotion/scrcpy), a free, open-source,
cross-platform (Windows / macOS / Linux) screen-mirroring tool that works over
the same ADB connection.

```
# Windows (Scoop / Chocolatey), macOS (Homebrew), or Linux (apt) — for example:
scoop install scrcpy        # Windows
brew install scrcpy         # macOS
sudo apt install scrcpy     # Linux

# Mirror the connected headset:
scrcpy
```

On a Meta Quest the mirror shows the **stereo (dual-eye) render**, which is why
the capture below is split into a left and right view:

<p align="center">
  <img width="800" alt="BowleramaXR mirrored from the headset via scrcpy (stereo view)"
       src="https://github.com/user-attachments/assets/e77cca67-bfa1-4fad-8f85-bff94a632c79" />
</p>

Handy tips:

- `scrcpy --crop 1832:1920:0:0` (or similar) to mirror just one eye.
- `scrcpy --record demo.mp4` to capture a video for sharing.
- Add `--no-audio` if you only want the video stream.

## Godot MCP and AI integration

There are numerous MCP servers available for Godot, all with somewhat
different approaches.

We recommend [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp),
which is one of the most popular. It's also easy to install (it can be
run via `npx`) and limit to working on the intended Godot project.

The template already includes an `.mcp.json` which will be picked up automatically
by Claude Code.

See [the documentation](https://github.com/Coding-Solo/godot-mcp#quick-start)
for instructions on how to use it with other MCP clients.
