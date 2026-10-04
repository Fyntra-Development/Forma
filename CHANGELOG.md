# Forma Changelog

> Tracked history across 368 commits (`18a9d70` → `ef7c1c3`). Timestamps in UTC.

---

### Highlights

| Date | Key Developments |
| :--- | :--- |
| **2026-10-04** | Luau type definitions, layered theme tokens, documentation rewrite |
| **2026-09-29** | Glowing alignment guides, magnetic snapping engine, dockable utility frames |
| **2026-09-25** | Keybind panel rework, mode persistence, smootherstep interpolation |
| **2026-09-24** | Modal dialog system, frame-rate independent tweening, drag smoothing |
| **2026-09-22** | Sliding tab transitions, utility windows, custom easing parameters |
| **2026-09-21** | Option wheel, character-wave title animations, cursor presets |
| **2026-08-16** | Colorpicker overhaul, notification stretch physics, showcase suite |
| **2026-08-15** | Tabbox containers, dependency resolution, watermark metadata |
| **2026-08-13** | Target HUD subsystem, searchable select menus, provider architecture |
| **2026-08-12** | Core architecture baseline, gradient/font pipeline, accent glow system |

---

## Release Log

<details open>
<summary><strong>2026-10-04</strong></summary>

- [`ef7c1c3`](https://github.com/Fyntra-Development/UiLibrary/commit/ef7c1c3338140411dbf0ef7b7276e3a11896d33f) **Types & Design Tokens** — Added exported Luau types, dynamic design tokens, and documentation index.
- [`252b88f`](https://github.com/Fyntra-Development/UiLibrary/commit/252b88fcfb3a92c4d8e048691a971008eb0e017f) **Docs** — Streamlined `README.md` to core badges, install instructions, and asset links.
- [`363ade6`](https://github.com/Fyntra-Development/UiLibrary/commit/363ade696084a8399c621511e169c800ffde6f17) **Docs** — Overhauled quickstart documentation and setup guides.

</details>

<details open>
<summary><strong>2026-09-29</strong></summary>

- [`5f18495`](https://github.com/Fyntra-Development/UiLibrary/commit/5f1849517b737fc4e8ca6449740ea87bc183d119) **Window Snapping** — Added screen/peer magnetic docking with dynamic accent guides.
- [`610a3d4`](https://github.com/Fyntra-Development/UiLibrary/commit/610a3d4dbd9c4f8d6a999b6b9a157add435647b7) **Docking Engine** — Added edge/center anchor detection and snapping configuration toggles.
- [`ca5c2c6`](https://github.com/Fyntra-Development/UiLibrary/commit/ca5c2c699970835b51dd2f204ceb3742228a86ab) **Physics Solver** — Introduced magnetic hysteresis thresholds and snap margins to `MenuManager`.

</details>

<details>
<summary><strong>2026-09-25</strong></summary>

- [`bfbaed8`](https://github.com/Fyntra-Development/UiLibrary/commit/bfbaed83db72930134debe9680a2215af315fb31) **Fix** — Retain keybind settings panel focus during mode toggle (`Always` / `Toggle` / `Hold`).
- [`6865da8`](https://github.com/Fyntra-Development/UiLibrary/commit/6865da866065f2cbc51c84f8f1232c6b54f47520) **Fix** — Resolved `nil` constructor exceptions by binding the shared groupbox dropdown.
- [`be95d21`](https://github.com/Fyntra-Development/UiLibrary/commit/be95d21bf4db6886736fb3418e42271b4cdff923) **Styling** — Decoupled color-picker shell from nested content palettes.
- [`d359b2d`](https://github.com/Fyntra-Development/UiLibrary/commit/d359b2da8ef870fe414765c1330ad4aa88162b14) **Keybinds** — Added styled right-click context menu with option highlighting.
- [`6244ec2`](https://github.com/Fyntra-Development/UiLibrary/commit/6244ec2d496ae46683222d84656bb41a68f5346c) **Motion Engine** — Added frame-driven animation timeline and retargetable property interpolation.
- [`174da89`](https://github.com/Fyntra-Development/UiLibrary/commit/174da89403cda1935136f7e83793c20c7a5cb223) **Keybinds** — Staggered slide/fade entry transitions for active keybind rows.
- [`2845961`](https://github.com/Fyntra-Development/UiLibrary/commit/2845961fac60857f9dca15b98473c179a0df612d) **Easing** — Added `smootherstep` curves with adjustable smoothness weights.

</details>

<details>
<summary><strong>2026-09-24</strong></summary>

- [`96cda99`](https://github.com/Fyntra-Development/UiLibrary/commit/96cda993cc80350bbd6023051be37046a5ba27e1) **Keybinds** — Reworked layout hierarchy to allow flexible row/header proportions.
- [`41be289`](https://github.com/Fyntra-Development/UiLibrary/commit/41be2893bd304bf337f4760bab21965db486c7b7) **Manipulation** — Added configurable direct-manipulation profiles (`Drag smoothing`, `Resize smoothing`).
- [`83d6fc4`](https://github.com/Fyntra-Development/UiLibrary/commit/83d6fc4f46aaf104dcd95ffc995d60d2f5eeff60) **Motion** — Gliding slot transitions for list items; smooth fades on unmount.
- [`2fa9058`](https://github.com/Fyntra-Development/UiLibrary/commit/2fa9058921b762ae2c6c7e8ead9b7717d03c63a9) **Modals** — Added `Library:Dialog()` modal controller with background input capture.
- [`48e0890`](https://github.com/Fyntra-Development/UiLibrary/commit/48e089076c3b5936f75ed3c2d703bd1d1dfb073a) **Rendering** — Added layered gradient utility `Library:AddControlBackgroundGradient()`.

</details>

<details>
<summary><strong>2026-09-22</strong></summary>

- [`c89490c`](https://github.com/Fyntra-Development/UiLibrary/commit/c89490c3fc9eeaf1993ba73c44d40a004841c790) **Navigation** — Added coordinated tab controllers (`Library:CreateTabTransitionController`).
- [`ae8eb5f`](https://github.com/Fyntra-Development/UiLibrary/commit/ae8eb5f6f46d3205c9be71aaaa1f516693f8c5a9) **Motion** — Integrated `SmoothDampScalar` for state transitions.
- [`237d9ce`](https://github.com/Fyntra-Development/UiLibrary/commit/237d9ce495c0f3a9083d96a7447b11d3d8e961b6) **Tabs** — Added sliding indicator track matching active tab boundaries.
- [`ca13145`](https://github.com/Fyntra-Development/UiLibrary/commit/ca13145d1204385fb3d73fc06a563ace76269aa8) **Easing** — Exposed easing style and direction selectors in `MenuManager`.
- [`82b0774`](https://github.com/Fyntra-Development/UiLibrary/commit/82b07748ede36565633251cbccb9a5bfea3ce440) **Windows** — Added utility window constructor and pinned resize handles (`Library:MakeResizable`).

</details>

<details>
<summary><strong>2026-09-21</strong></summary>

- [`d941ee9`](https://github.com/Fyntra-Development/UiLibrary/commit/d941ee901db8854c5192b92c397fe3f96684d356) **Text Effects** — Sinusoidal wave animations for window title headers.
- [`bb4b809`](https://github.com/Fyntra-Development/UiLibrary/commit/bb4b809fbb8966d5e715a61b557ed1185714d820) **Cursor** — Added cursor presets and dynamic trail styling via `Library:SetCursorStyle`.
- [`7220568`](https://github.com/Fyntra-Development/UiLibrary/commit/7220568a3960f4cdc72a7ff718f063fa9cd8abe1) **Assets** — Added font assets: `Space Grotesk`, `Orbitron`, `Sora`, and `Oxanium`.
- [`050d36a`](https://github.com/Fyntra-Development/UiLibrary/commit/050d36a91e7b92ee410479bde5b69d48070ec3af) **Controls** — Added `Library:CreateOptionWheel()` radial selector.
- [`d97b669`](https://github.com/Fyntra-Development/UiLibrary/commit/d97b669570dc63c93309311d80e37521ccb8cbd3) **Versioning** — Integrated semver comparison utilities (`Library:CompareVersions`).
- [`df50eae`](https://github.com/Fyntra-Development/UiLibrary/commit/df50eae639a69f2346dfd94eb1003e201296ed4d) **Components** — Added reactive `DataTable` and embedded `Console` widgets.
- [`5115f19`](https://github.com/Fyntra-Development/UiLibrary/commit/5115f19155013a9aa04f82f08e34426e7814568b) **Controls** — Added dual-thumb range sliders.
- [`fe3ef5d`](https://github.com/Fyntra-Development/UiLibrary/commit/fe3ef5dc1c4aeef4f80496a05ee686f06944da3d) **Updater** — Added animated update prompt dialogs and automatic restart dispatchers.

</details>

<details>
<summary><strong>2026-08-16</strong></summary>

- [`4e941cc`](https://github.com/Fyntra-Development/UiLibrary/commit/4e941cc0fefcef8305a0453963860987018e64d7) **Showcase** — Rewrote `Example.lua` into an interactive feature reference.
- [`fab1fc4`](https://github.com/Fyntra-Development/UiLibrary/commit/fab1fc44936404163afd20d91f5e69892a08a3a7) **Color Picker** — Added animated color picker with layout mode presets.
- [`52731f4`](https://github.com/Fyntra-Development/UiLibrary/commit/52731f43765fede1578decc8fdc3e28e11e7f6d9) **Notifications** — Coordinated accent progression, elastic squash/stretch, and stack transitions.

</details>

<details>
<summary><strong>2026-08-15</strong></summary>

- [`920d102`](https://github.com/Fyntra-Development/UiLibrary/commit/920d1028bc76ffbd4485289e008bb5f00ddbd8f1) **Containers** — Added tabboxes with clean border styling.
- [`3870eb6`](https://github.com/Fyntra-Development/UiLibrary/commit/3870eb6f1e2e71380a73d3712c1b2561507175e9) **Logic** — Added dependency-aware control states and bidirectional row fading.
- [`d32bbe0`](https://github.com/Fyntra-Development/UiLibrary/commit/d32bbe03b0551c3a49ac4ed7ca289a1b3179eeed) **Watermark** — Added animated HUD status displays with rich metadata fields.
- [`95e3b28`](https://github.com/Fyntra-Development/UiLibrary/commit/95e3b286a329547bcb7625aa5371c64b1fe52b2c) **Animation Engine** — Refactored transition pipeline around non-scaling alpha/offset tweens.

</details>

<details>
<summary><strong>2026-08-13</strong></summary>

- [`3b33ebd`](https://github.com/Fyntra-Development/UiLibrary/commit/3b33ebd8f5a8864b5284081ff749fd5cd7e1dbdc) **Target HUD** — Added draggable target HUD with animated health/meter bars and provider hooks.
- [`0d95fe5`](https://github.com/Fyntra-Development/UiLibrary/commit/0d95fe54085cc429359da6044e96046c2513d46f) **Core Addons** — Introduced `MenuManager` and opt-in searchable dropdown popups.
- [`cdec240`](https://github.com/Fyntra-Development/UiLibrary/commit/cdec2408acea163c5f62543de721b7cc1294a22d) **Theming** — Dynamic text scaling and theme-driven overlay positioning.

</details>

<details>
<summary><strong>2026-08-12</strong></summary>

- [`18a9d70`](https://github.com/Fyntra-Development/UiLibrary/commit/18a9d7000d89052cb96c6c10e261f98de78d5239) **Initial Commit** — Core library fork, Linoria foundation, and custom addon managers.
- [`0c6fe33`](https://github.com/Fyntra-Development/UiLibrary/commit/0c6fe33a4030241bf23b7768da9efa7c155fec64) **Visuals** — Built-in glow effects, hardware cursor overlays, and repository-hosted font loaders.
- [`898b7f5`](https://github.com/Fyntra-Development/UiLibrary/commit/898b7f554c2dc9508d5966dd46ee3d452ab85a7f) **Primitives** — Added base slider, tooltip, and dropdown components with standard easing curves.

</details>
