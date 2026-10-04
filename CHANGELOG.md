# Changelog

A dated history of **Forma** sourced from the repository's Git commits. Dates below use the **commit author timestamp in UTC** (`YYYY-MM-DD`). Each linked entry represents a distinct commit, including fixes, reversions, assets, documentation, and version-only updates. A commit with no identifiable feature addition is **not** described as a new feature.

This archive covers **368 commits**, from the initial commit through `ef7c1c333`, immediately before this changelog was published. The publishing commit itself is not listed because a Git commit cannot include its own final SHA.

## Daily highlights

- **2026-10-04** — Repository documentation, compact README, and public type/design-token definitions.
- **2026-09-29** — Glowing alignment guides; screen and window-to-window magnetic snapping; utility, watermark, and keybind support.
- **2026-09-25** — Shared dropdown in keybind settings; picker styling revisions and reversion; persistent keybind mode panel.
- **2026-09-24** — Keybind menu sizing and transitions, animated color-picker behavior, modal dialogs, and window motion refinements.
- **2026-09-23** — Targeted library updates and component version synchronization.
- **2026-09-22** — Tab/utility layout, dependency and motion refinements; component release synchronization.
- **2026-09-21** — Utility windows, title animations, option wheel, additional fonts, theme controls, and iterative UI updates.
- **2026-09-20** — Comic Mono font integration and script refinements.
- **2026-09-19** — Exploratory control and presentation changes recorded under short commit messages.
- **2026-08-16** — Animated color-picker modes, notifications, HUD motion, and expanded usage examples.
- **2026-08-15** — Tabboxes, dependency-aware controls, keybind modes, fade/slide motion, inputs, and watermark refinements.
- **2026-08-14** — Multiple UI motion rewrites, geometry experiments, and a reverted compact restyle.
- **2026-08-13** — Target HUD health/meter providers, searchable dropdowns, MenuManager controls, and overlay fixes.
- **2026-08-12** — Initial Linoria-based UI, gradients, sliders, tooltips, cursor, typography, and repository font assets.

---

## Complete commit history


### 2026-10-04

- [`ef7c1c333`](https://github.com/Fyntra-Development/UiLibrary/commit/ef7c1c3338140411dbf0ef7b7276e3a11896d33f) — Add public Luau definitions, layered live-theme design tokens, and README file links.
- [`252b88fcf`](https://github.com/Fyntra-Development/UiLibrary/commit/252b88fcfb3a92c4d8e048691a971008eb0e017f) — Reduce README to badges and file links; remove banner from documentation.
- [`2d7b64b82`](https://github.com/Fyntra-Development/UiLibrary/commit/2d7b64b823eac2e19d402f318843e388cea1231b) — Remove the gradient banner asset.
- [`363ade696`](https://github.com/Fyntra-Development/UiLibrary/commit/363ade696084a8399c621511e169c800ffde6f17) — Redesign README with gradient banner, feature overview, and quick-start documentation.

### 2026-09-29

- [`54121801a`](https://github.com/Fyntra-Development/UiLibrary/commit/54121801ac1bf388efe757347873eadba2ac0d19) — Synchronize component version/release metadata in `versions.json`.
- [`5f1849517`](https://github.com/Fyntra-Development/UiLibrary/commit/5f1849517b737fc4e8ca6449740ea87bc183d119) — Glowing accent guide layers, live peer-window alignment, and snapping for the watermark and keybind list.
- [`610a3d4db`](https://github.com/Fyntra-Development/UiLibrary/commit/610a3d4dbd9c4f8d6a999b6b9a157add435647b7) — Peer-window docking and edge/center anchors; options for glowing guides and window snapping.
- [`9d5704cbb`](https://github.com/Fyntra-Development/UiLibrary/commit/9d5704cbb4f5f1b51c2d1857103e3223c3bc6279) — Synchronize component version/release metadata in `versions.json`.
- [`13501e15a`](https://github.com/Fyntra-Development/UiLibrary/commit/13501e15a08d76c22627a930417a785bc4dc3295) — Real-time screen anchor snapping integrated with window dragging and live alignment guides.
- [`ca5c2c699`](https://github.com/Fyntra-Development/UiLibrary/commit/ca5c2c699970835b51dd2f204ceb3742228a86ab) — Magnetic anchor solver, release hysteresis, snap margin, and MenuManager settings.

### 2026-09-25

- [`6ee1bd5db`](https://github.com/Fyntra-Development/UiLibrary/commit/6ee1bd5db72d962a76cfeb6ec3c2fd16aa817182) — Synchronize component version/release metadata in `versions.json`.
- [`bfbaed83d`](https://github.com/Fyntra-Development/UiLibrary/commit/bfbaed83db72930134debe9680a2215af315fb31) — Keep keybind settings open after changing Always/Toggle/Hold mode.
- [`3c7136a0e`](https://github.com/Fyntra-Development/UiLibrary/commit/3c7136a0e2b66bdd379ce8f3651a12a76ace7bdd) — Synchronize component version/release metadata in `versions.json`.
- [`1a838d8e8`](https://github.com/Fyntra-Development/UiLibrary/commit/1a838d8e8d8008e2058b8b0b4cf8e7ba66a19d20) — Revert recent color-picker layout changes while preserving keybind behavior.
- [`c7714fccb`](https://github.com/Fyntra-Development/UiLibrary/commit/c7714fccbedd1d28d90a41e0aa12ae73894690f7) — Synchronize component version/release metadata in `versions.json`.
- [`bc70608b0`](https://github.com/Fyntra-Development/UiLibrary/commit/bc70608b0f805ae98ef8e5f866959576bd861ac2) — Move color-picker accent line above tabs and adjust picker outlines.
- [`7be2744ea`](https://github.com/Fyntra-Development/UiLibrary/commit/7be2744ea44d5b3e14547e24a5af8605c4797f91) — Synchronize component version/release metadata in `versions.json`.
- [`6865da866`](https://github.com/Fyntra-Development/UiLibrary/commit/6865da866065f2cbc51c84f8f1232c6b54f47520) — Fix nil AddDropdown call by sharing the real groupbox dropdown constructor.
- [`1ee0fa794`](https://github.com/Fyntra-Development/UiLibrary/commit/1ee0fa79493bbdf9d2d6b6d1b8a38ea3678d80fb) — Synchronize component version/release metadata in `versions.json`.
- [`be95d21bf`](https://github.com/Fyntra-Development/UiLibrary/commit/be95d21bf4db6886736fb3418e42271b4cdff923) — Use the actual Forma dropdown for keybind modes; separate color-picker shell/content colors.
- [`147890308`](https://github.com/Fyntra-Development/UiLibrary/commit/147890308776b5b8356cbc91dbcdb73f39fc9934) — Synchronize component version/release metadata in `versions.json`.
- [`bb48106a3`](https://github.com/Fyntra-Development/UiLibrary/commit/bb48106a3bc17bc03edffc050334676e267481aa) — Compact keybind mode dropdown panel and color-picker content/header sections.
- [`b0457984f`](https://github.com/Fyntra-Development/UiLibrary/commit/b0457984f4b9668b38a2cc6cbdd78084624cc3d5) — Synchronize component version/release metadata in `versions.json`.
- [`dd9df2e45`](https://github.com/Fyntra-Development/UiLibrary/commit/dd9df2e456e5eeb7f5ef9c86e8c4ca806d46b49c) — Prevent right-click from immediately dismissing its keybind popup.
- [`d359b2da8`](https://github.com/Fyntra-Development/UiLibrary/commit/d359b2da8ef870fe414765c1330ad4aa88162b14) — Add styled right-click keybind mode menu with highlighted options.
- [`2a23e9e06`](https://github.com/Fyntra-Development/UiLibrary/commit/2a23e9e06906d4d18ead042f191d8c83b32bd394) — Synchronize component version/release metadata in `versions.json`.
- [`beb10a63b`](https://github.com/Fyntra-Development/UiLibrary/commit/beb10a63b9f3d19a30daee79cdec515bdfd34654) — Refined end) · `Example.lua`.
- [`6244ec2d4`](https://github.com/Fyntra-Development/UiLibrary/commit/6244ec2d496ae46683222d84656bb41a68f5346c) — Frame-driven fluid animation timeline and retargetable property interpolation.
- [`174da8940`](https://github.com/Fyntra-Development/UiLibrary/commit/174da89403cda1935136f7e83793c20c7a5cb223) — Staggered sliding/fading keybind rows and persistent live visibility API.
- [`11c6fe06c`](https://github.com/Fyntra-Development/UiLibrary/commit/11c6fe06c427a2e13bedcb15a1f22c5386201bbd) — Expanded `Handle:Cancel()`, `Handle:Play()` (v1.21.0+build.1) · `Library.lua`.
- [`2845961fa`](https://github.com/Fyntra-Development/UiLibrary/commit/2845961fac60857f9dca15b98473c179a0df612d) — Introduce smootherstep easing and configurable easing smoothness.
- [`a62aa7083`](https://github.com/Fyntra-Development/UiLibrary/commit/a62aa7083b5d701721ebe4dbe76f01ce06442dae) — Synchronize component version/release metadata in `versions.json`.
- [`58c3480df`](https://github.com/Fyntra-Development/UiLibrary/commit/58c3480df4278ac4dfe925f708ce25c2f9777560) — Implementation/behavior maintenance (v1.20.6+build.1) · `Library.lua`.

### 2026-09-24

- [`c7b17a911`](https://github.com/Fyntra-Development/UiLibrary/commit/c7b17a911d24fe8e53ad2cd028594ec75afeaaed) — Synchronize component manifest with keybind UI fixes.
- [`96cda993c`](https://github.com/Fyntra-Development/UiLibrary/commit/96cda993cc80350bbd6023051be37046a5ba27e1) — Refine compact keybind header and rows against reference layout.
- [`fd8e07f98`](https://github.com/Fyntra-Development/UiLibrary/commit/fd8e07f98bc1d25412ed939274fb635e291e0e47) — Synchronize component version/release metadata in `versions.json`.
- [`577a691f2`](https://github.com/Fyntra-Development/UiLibrary/commit/577a691f22c8a183fcccb83ec22a1e8183e9bc5c) — The supplied reference is mostly a top-to-bottom shaded accent (v1.20.4+build.1) · `Library.lua`.
- [`d65afe1dd`](https://github.com/Fyntra-Development/UiLibrary/commit/d65afe1dd865476ca69d6f5991c5177be2ddc626) — Header width is intentionally independent from the longest keybind (v1.20.3+build.1) · `Library.lua`.
- [`5c19937bf`](https://github.com/Fyntra-Development/UiLibrary/commit/5c19937bf6476b7e4e81a3f4dbdef0ee2dbe8b2a) — Implementation/behavior maintenance · `Library.lua`.
- [`e61a27b73`](https://github.com/Fyntra-Development/UiLibrary/commit/e61a27b735bd214de56d2975253730987d9510e2) — Synchronize component version/release metadata in `versions.json`.
- [`3e10f6d70`](https://github.com/Fyntra-Development/UiLibrary/commit/3e10f6d709c16054c165c88ce527ff381a6a4f94) — Updated `GetKeybindHeaderGradientColor()`, `RefreshKeybindLayout()` (v1.20.2+build.1) · `Library.lua`.
- [`c5933d7d9`](https://github.com/Fyntra-Development/UiLibrary/commit/c5933d7d94f6076b2fa8b907aaa44da23b06fbb0) — Synchronize component version/release metadata in `versions.json`.
- [`1e9f803de`](https://github.com/Fyntra-Development/UiLibrary/commit/1e9f803deefe0a471f000ac83564eedcdaa5da01) — Updated `IsInsideActiveResize()`, `GetDependencyHeight()` (v1.20.1+build.1) · `Library.lua`.
- [`eed8b7457`](https://github.com/Fyntra-Development/UiLibrary/commit/eed8b7457d48cf3f32f8af4834454ce9b39d2264) — Add uploaded repository files/assets (paths visible in linked diff).
- [`97017e391`](https://github.com/Fyntra-Development/UiLibrary/commit/97017e3914b305e228ad6520d4bc0247f4eaa443) — Synchronize component version/release metadata in `versions.json`.
- [`ab84e3e23`](https://github.com/Fyntra-Development/UiLibrary/commit/ab84e3e236e5a7a852d7cce4acc9c49aa501562b) — Updated `GetProfile()`, `ApplyVisual()` (v1.20.0+build.1) · `Library.lua`.
- [`41be2893b`](https://github.com/Fyntra-Development/UiLibrary/commit/41be2893bd304bf337f4760bab21965db486c7b7) — Expanded `MenuManager:GetDirectManipulationProfile()`, `MenuManager:GetResizeResponse()`, `MenuManager:SetDragSmoothTime()`; controls: `Drag smoothing`, `Resize smoothing` (v1.4.0+build.1) · `addons/MenuManager.lua`.
- [`7d6c3601f`](https://github.com/Fyntra-Development/UiLibrary/commit/7d6c3601f4495b7f6aa1d50dd5be6a8391214e25) — Synchronize component version/release metadata in `versions.json`.
- [`83d6fc4f4`](https://github.com/Fyntra-Development/UiLibrary/commit/83d6fc4f46aaf104dcd95ffc995d60d2f5eeff60) — Existing visible rows glide between slots. Hidden rows fade (v1.19.4+build.1) · `Library.lua`.
- [`9aa522786`](https://github.com/Fyntra-Development/UiLibrary/commit/9aa522786422b19dd20a750237d61bc75538d07a) — Synchronize component version/release metadata in `versions.json`.
- [`2ced8a6ae`](https://github.com/Fyntra-Development/UiLibrary/commit/2ced8a6ae0c75c5705ab58e98e3f02dce183b528) — Build the backdrop as many extremely low-opacity overlapping shells (v1.19.3+build.1) · `Library.lua`.
- [`aeea0cac2`](https://github.com/Fyntra-Development/UiLibrary/commit/aeea0cac2b985c47fd67e23d4ed6d9501f9dcd0e) — Synchronize component version/release metadata in `versions.json`.
- [`f51ffaad6`](https://github.com/Fyntra-Development/UiLibrary/commit/f51ffaad69cd621c0791eee7cec50e218458ef0a) — Two-phase filtering keeps text at its normal geometry: (v1.19.2+build.1) · `Library.lua`.
- [`00484c152`](https://github.com/Fyntra-Development/UiLibrary/commit/00484c152f85fa18095f7ac4611cf90fa8cd54b0) — Synchronize component version/release metadata in `versions.json`.
- [`fd1b3338f`](https://github.com/Fyntra-Development/UiLibrary/commit/fd1b3338f93924bb17e59daab14d117353ad072d) — Updated `GetAnimatedRowsHeight()`, `CreateBackdropPiece()` (v1.19.1+build.1) · `Library.lua`.
- [`e96b6eb24`](https://github.com/Fyntra-Development/UiLibrary/commit/e96b6eb24d095354772ea3a4bf2add35ea604a1e) — Synchronize component version/release metadata in `versions.json`.
- [`fe6b19827`](https://github.com/Fyntra-Development/UiLibrary/commit/fe6b198274e23cd0fc31552b5020fbde21c837d8) — Modal dialogs block interaction with the underlying UI until dismissed; controls: `Open dialog`, `Cancel` · `Example.lua`.
- [`1f9e287bf`](https://github.com/Fyntra-Development/UiLibrary/commit/1f9e287bf774d8399f4dd8c8a8c57a5360b95478) — Refined `Library:Dialog()` · `Library.lua`.
- [`2fa905892`](https://github.com/Fyntra-Development/UiLibrary/commit/2fa9058921b762ae2c6c7e8ead9b7717d03c63a9) — Expanded `Library:CancelFadePropertyMotions()`, `Library:Dialog()`, `Dialog:Close()`; controls: `Dialog` (v1.19.0+build.1) · `Library.lua`.
- [`4011ab593`](https://github.com/Fyntra-Development/UiLibrary/commit/4011ab593b7571e983fc420ce376f56fc2c3db2f) — Synchronize component version/release metadata in `versions.json`.
- [`eec001717`](https://github.com/Fyntra-Development/UiLibrary/commit/eec0017173cab456220f20fc7641672c0a82c120) — Updated `PositionPicker()`, `SetPickerMotionTarget()` (v1.18.3+build.1) · `Library.lua`.
- [`fe13d725f`](https://github.com/Fyntra-Development/UiLibrary/commit/fe13d725f66ba995e53017a8f80d41a201e155d3) — Synchronize component version/release metadata in `versions.json`.
- [`cc0516612`](https://github.com/Fyntra-Development/UiLibrary/commit/cc05166122f0756cf590230fed2c96c35e573dd1) — Implementation/behavior maintenance (v1.18.2+build.1) · `Library.lua`.
- [`1c6cc7afb`](https://github.com/Fyntra-Development/UiLibrary/commit/1c6cc7afb2a8267d09fcfcf39948c9a87908b1bf) — Synchronize component version/release metadata in `versions.json`.
- [`d80115f4a`](https://github.com/Fyntra-Development/UiLibrary/commit/d80115f4a31826a91b6c36066ff13a8a132e8eeb) — Implementation/behavior maintenance (v1.18.1+build.1) · `Library.lua`.
- [`bbc03dc42`](https://github.com/Fyntra-Development/UiLibrary/commit/bbc03dc42e00db86334afa4104a4e32a459f1561) — Synchronize component version/release metadata in `versions.json`.
- [`fddd9a7cf`](https://github.com/Fyntra-Development/UiLibrary/commit/fddd9a7cf654f3509b66c02896b978b5b39e55db) — Updated `ReadThemeColor()` (v1.10.0+build.1) · `addons/ThemeManager.lua`.
- [`48e089076`](https://github.com/Fyntra-Development/UiLibrary/commit/48e089076c3b5936f75ed3c2d703bd1d1dfb073a) — Expanded `Library:AddControlBackgroundGradient()` (v1.18.0+build.1) · `Library.lua`.
- [`05cb70f28`](https://github.com/Fyntra-Development/UiLibrary/commit/05cb70f28d5ef2e346e5bff39b82f24cb1036e12) — Synchronize component version/release metadata in `versions.json`.
- [`92cb0568c`](https://github.com/Fyntra-Development/UiLibrary/commit/92cb0568cfa6fbb48e4c08063436946a097e2c24) — Implementation/behavior maintenance (v1.17.2+build.1) · `Library.lua`.

### 2026-09-23

- [`73a799e80`](https://github.com/Fyntra-Development/UiLibrary/commit/73a799e80d8d81f8137aeedbfa0148ad898bb68d) — Synchronize component version/release metadata in `versions.json`.
- [`bea1c6e38`](https://github.com/Fyntra-Development/UiLibrary/commit/bea1c6e380820b657adceaaf6b709b7b0731afbf) — Expanded `Library:UpdateFadeBaselineProperty()` (v1.17.1+build.1) · `Library.lua`.

### 2026-09-22

- [`decd0bb63`](https://github.com/Fyntra-Development/UiLibrary/commit/decd0bb638727d8a0825a3bd12f82c617754dc7e) — Synchronize component version/release metadata in `versions.json`.
- [`25c18dfcf`](https://github.com/Fyntra-Development/UiLibrary/commit/25c18dfcf282fb7efca9eb42232825294ecd3eac) — Updated `CancelStateMotion()` · `Library.lua`.
- [`c89490c3f`](https://github.com/Fyntra-Development/UiLibrary/commit/c89490c3fc9eeaf1993ba73c44d40a004841c790) — Expanded `Library:CreateTabTransitionController()`, `Controller:ApplyButton()`, `Controller:ApplyFrame()` (v1.17.0+build.1) · `Library.lua`.
- [`460b87e5c`](https://github.com/Fyntra-Development/UiLibrary/commit/460b87e5cb22f5cdd71bc94ed3ef7739b586e0d4) — Synchronize component version/release metadata in `versions.json`.
- [`88ab1e3f4`](https://github.com/Fyntra-Development/UiLibrary/commit/88ab1e3f456f63dd1ff17af8082388357da1bbcd) — Implementation/behavior maintenance (v1.5.3+build.1, 1.16.5+build.1) · `Library.lua`.
- [`cfda568ef`](https://github.com/Fyntra-Development/UiLibrary/commit/cfda568ef55bd3bf1e28b6358d8ce79222a3eec1) — Updated `ValidateCachedManifestAgainst()` (v1.5.3+build.1) · `Loader.lua`.
- [`778afe8ed`](https://github.com/Fyntra-Development/UiLibrary/commit/778afe8ed1b57cf51c53d0e597526151606beaf2) — Synchronize component version/release metadata in `versions.json`.
- [`f2705ef99`](https://github.com/Fyntra-Development/UiLibrary/commit/f2705ef99a0657f1b5023322337a7739749aeaec) — Refined `Library:UpdateColorsUsingRegistry()` (v1.16.4+build.1) · `Library.lua`.
- [`7fe5cd7b4`](https://github.com/Fyntra-Development/UiLibrary/commit/7fe5cd7b41f96e91d5abe5b3163aa15f551b32ee) — Synchronize component version/release metadata in `versions.json`.
- [`f7de1e332`](https://github.com/Fyntra-Development/UiLibrary/commit/f7de1e33213a8b0844653809b1726446e5c43b7e) — Apply the hidden opacity before the frame can be rendered · `Library.lua`.
- [`ae8eb5f6f`](https://github.com/Fyntra-Development/UiLibrary/commit/ae8eb5f6f46d3205c9be71aaaa1f516693f8c5a9) — Expanded `Library:SmoothDampScalar()`, `Library:CreateTabTransition()`, `State:SetVisible()` (v1.16.3+build.1) · `Library.lua`.
- [`75452d3ac`](https://github.com/Fyntra-Development/UiLibrary/commit/75452d3acbdbc0b7c7046b990db496e606017390) — Synchronize component version/release metadata in `versions.json`.
- [`237d9ce49`](https://github.com/Fyntra-Development/UiLibrary/commit/237d9ce495c0f3a9083d96a7447b11d3d8e961b6) — Refined `Library:CreateSlidingTabIndicator()`, `Library:CreateWindow()` (v1.16.2+build.1) · `Library.lua`.
- [`a3ecee05a`](https://github.com/Fyntra-Development/UiLibrary/commit/a3ecee05a9ea416693ce81f1bbc391d0ac8a9a0c) — Synchronize component version/release metadata in `versions.json`.
- [`9a7ea54e4`](https://github.com/Fyntra-Development/UiLibrary/commit/9a7ea54e4e4e1e30686b8349d203d2f72649d926) — Implementation/behavior maintenance (v1.3.1) · `addons/MenuManager.lua`.
- [`625e08eef`](https://github.com/Fyntra-Development/UiLibrary/commit/625e08eef54ed4921ce5ebe4d654ff092b22444c) — Refined `Library:GetMenuTweenInfo()`, `Library:CreateSlidingTabIndicator()` (v1.16.1+build.1) · `Library.lua`.
- [`47983f1e3`](https://github.com/Fyntra-Development/UiLibrary/commit/47983f1e312c2a36b769ad5d2ae2e240d5cd7e12) — Synchronize component version/release metadata in `versions.json`.
- [`ca13145d1`](https://github.com/Fyntra-Development/UiLibrary/commit/ca13145d1204385fb3d73fc06a563ace76269aa8) — Implementation/behavior maintenance; controls: `Easing style`, `Easing direction` (v1.3.0) · `addons/MenuManager.lua`.
- [`32b13df24`](https://github.com/Fyntra-Development/UiLibrary/commit/32b13df24f5fc78ef6de4ba50958094ca8a184a6) — Implementation/behavior maintenance; controls: `Font`, `Theme list` (v1.9.0+build.1) · `addons/ThemeManager.lua`.
- [`8c525aa4c`](https://github.com/Fyntra-Development/UiLibrary/commit/8c525aa4c5aeff5e8356d321bb291d208b62a4ae) — Expanded `Dropdown:GetActiveValueCount()`, `Dropdown:EnsureRequiredSelection()` (v1.16.0+build.1) · `Library.lua`.
- [`4a38a099f`](https://github.com/Fyntra-Development/UiLibrary/commit/4a38a099f9733f03832cc7c2c8a0afef42f7600f) — Update font asset: `Ubuntu.ttf`.
- [`c48cfe4e6`](https://github.com/Fyntra-Development/UiLibrary/commit/c48cfe4e6ea3766e1600178a3b1de7f6573bce5d) — Synchronize component version/release metadata in `versions.json`.
- [`9d1cd58db`](https://github.com/Fyntra-Development/UiLibrary/commit/9d1cd58db2f6dcfdeb0aa61dc9b6eeccaf88ddb9) — Keep the resize cube pinned exactly to the actual window corner (v1.15.1+build.1) · `Library.lua`.
- [`e2de4af2b`](https://github.com/Fyntra-Development/UiLibrary/commit/e2de4af2bb2008d47274e00f95ec54c711451686) — Synchronize component version/release metadata in `versions.json`.
- [`82b07748e`](https://github.com/Fyntra-Development/UiLibrary/commit/82b07748ede36565633251cbccb9a5bfea3ce440) — Refined `Library:MakeResizable()`, `Library:CreateUtilityWindow()` (v1.15.0+build.1) · `Library.lua`.
- [`dbcd7ff34`](https://github.com/Fyntra-Development/UiLibrary/commit/dbcd7ff3458da39e62847f748e60a148d639f1c9) — Synchronize component version/release metadata in `versions.json`.
- [`b6611e6e7`](https://github.com/Fyntra-Development/UiLibrary/commit/b6611e6e7f31677a7c33c89e0659385bf5851520) — Implementation/behavior maintenance (v1.14.0+build.1) · `Library.lua`.
- [`12acec6ec`](https://github.com/Fyntra-Development/UiLibrary/commit/12acec6ec9660d3bf7abefa26266f6b94d47a365) — Synchronize component version/release metadata in `versions.json`.
- [`8764919b8`](https://github.com/Fyntra-Development/UiLibrary/commit/8764919b84fc01424ccf444af1103d54c0f7e0e9) — Use true ease-in/ease-out curves for the tiny horizontal (v1.13.2+build.1) · `Library.lua`.
- [`6ea9eb11b`](https://github.com/Fyntra-Development/UiLibrary/commit/6ea9eb11b761b26f0b2d3709926c5e46e370a399) — Synchronize component version/release metadata in `versions.json`.
- [`217f57666`](https://github.com/Fyntra-Development/UiLibrary/commit/217f57666207f4721d54a7883981940462c2cdf2) — Give the horizontal motion its own easing instead of sharing (v1.13.1+build.1) · `Library.lua`.
- [`ad5e53aa2`](https://github.com/Fyntra-Development/UiLibrary/commit/ad5e53aa2c622f361107fdac0eca205f1e7a96b9) — Synchronize component version/release metadata in `versions.json`.
- [`4a4889ff0`](https://github.com/Fyntra-Development/UiLibrary/commit/4a4889ff0100d74a0d6946ec1df4915e89b597c8) — Updated `IsRowSelected()`, `ResolveRowLabelPosition()` (v1.13.0+build.1) · `Library.lua`.
- [`ed2bab880`](https://github.com/Fyntra-Development/UiLibrary/commit/ed2bab880d3146a7c301f4746e16a6ebbfd3a7f2) — Synchronize component version/release metadata in `versions.json`.
- [`a3f0cd082`](https://github.com/Fyntra-Development/UiLibrary/commit/a3f0cd0827aa01bd13968f309ee8de66dc4e7187) — Refined `Library:UpdateColorsUsingRegistry()` (v1.12.6+build.1) · `Library.lua`.
- [`286ffecd2`](https://github.com/Fyntra-Development/UiLibrary/commit/286ffecd200e6b00f49d9b12bd479e8d99c6b68f) — Synchronize component version/release metadata in `versions.json`.
- [`e8e5e506d`](https://github.com/Fyntra-Development/UiLibrary/commit/e8e5e506d3ba201b3905e7101885d150f2ef7833) — Implementation/behavior maintenance (v1.8.2+build.1) · `addons/ThemeManager.lua`.
- [`098472beb`](https://github.com/Fyntra-Development/UiLibrary/commit/098472beb8314738632522fd892f50b339814bad) — Refined `Library:SetCursorStyle()`, `Library:UpdateFont()` (v1.12.5+build.1) · `Library.lua`.
- [`e6ec543bb`](https://github.com/Fyntra-Development/UiLibrary/commit/e6ec543bb9f436093592f4509c1716b7db6e5f41) — Synchronize component version/release metadata in `versions.json`.
- [`6f32884a1`](https://github.com/Fyntra-Development/UiLibrary/commit/6f32884a1582ca0c95064c245dc534255a905706) — Refined `Library:CreateUtilityWindow()` · `Library.lua`.
- [`a09a365b5`](https://github.com/Fyntra-Development/UiLibrary/commit/a09a365b511a569d2afef6da2ebd3fb7cc255480) — Expanded `Library:GetMovingAccentGradientPhase()`, `Library:GetMovingAccentGradientOffset()`, `Library:SampleMovingAccentGradient()` (v1.12.4+build.1) · `Library.lua`.
- [`9f2d038a2`](https://github.com/Fyntra-Development/UiLibrary/commit/9f2d038a27805e2db15632ab912fbb123109c17f) — Synchronize component version/release metadata in `versions.json`.
- [`3f7f168bc`](https://github.com/Fyntra-Development/UiLibrary/commit/3f7f168bcf46d69ce4d6fe780fe4958519c58d26) — Updated `SetFadeBaselineProperty()`, `SetTitleSourceTextVisibility()` (v1.12.3+build.1) · `Library.lua`.
- [`2929f3e52`](https://github.com/Fyntra-Development/UiLibrary/commit/2929f3e52ed234565bbc486ef2bf62024e80b93f) — Synchronize component version/release metadata in `versions.json`.
- [`e3eaf484e`](https://github.com/Fyntra-Development/UiLibrary/commit/e3eaf484e5f648991930bc375adfa3f9ff851d79) — Updated `MeasureTitleWidth()`, `SetTitleSourceTransparency()` (v1.12.2+build.1) · `Library.lua`.
- [`99dc45b4f`](https://github.com/Fyntra-Development/UiLibrary/commit/99dc45b4ff4da06f632559ff485135676cf2f0ea) — Synchronize component version/release metadata in `versions.json`.
- [`d27faca1f`](https://github.com/Fyntra-Development/UiLibrary/commit/d27faca1f7a1cc4324ddbda49d7469e09ae2f9d1) — Implementation/behavior maintenance (v1.8.1+build.1) · `addons/ThemeManager.lua`.
- [`64b9a0e55`](https://github.com/Fyntra-Development/UiLibrary/commit/64b9a0e55074f599396aa279db5e16d5ee30c34b) — Updated `SplitTitleCharacters()`, `OffsetTitleY()` (v1.12.1+build.1) · `Library.lua`.

### 2026-09-21

- [`03a699e45`](https://github.com/Fyntra-Development/UiLibrary/commit/03a699e450416d631745508012d159525d2aff93) — Synchronize component version/release metadata in `versions.json`.
- [`f194d9c8b`](https://github.com/Fyntra-Development/UiLibrary/commit/f194d9c8b0507b1f07fba3206c398863e3975098) — Implementation/behavior maintenance (v1.8.0+build.1) · `addons/ThemeManager.lua`.
- [`2f1325bae`](https://github.com/Fyntra-Development/UiLibrary/commit/2f1325baef1bd5442eb963ef96e6f9ac15f0a0b3) — Updated `SyncTitleLayer()` (v1.12.0+build.1) · `Library.lua`.
- [`f003b12a3`](https://github.com/Fyntra-Development/UiLibrary/commit/f003b12a30cc39af6dd8f547b65dc138e6cab637) — Refined `Library:ResetTitleAnimation()` · `Library.lua`.
- [`c16850c09`](https://github.com/Fyntra-Development/UiLibrary/commit/c16850c095a04ae72bb48b71344d1a6e47cf4560) — Synchronize component version/release metadata in `versions.json`.
- [`6e6efe097`](https://github.com/Fyntra-Development/UiLibrary/commit/6e6efe0971928552104a7a18ff0f89e29b674591) — Implementation/behavior maintenance (v1.7.1+build.1) · `addons/ThemeManager.lua`.
- [`d941ee901`](https://github.com/Fyntra-Development/UiLibrary/commit/d941ee901db8854c5192b92c397fe3f96684d356) — Expanded `Library:StartTitleAnimation()`, `Library:ApplyTitleAnimation()` (v1.11.2+build.1) · `Library.lua`.
- [`2d307bfad`](https://github.com/Fyntra-Development/UiLibrary/commit/2d307bfade6349ead2757788076789139f62ed15) — Synchronize component version/release metadata in `versions.json`.
- [`b1b7011a6`](https://github.com/Fyntra-Development/UiLibrary/commit/b1b7011a6380977e442b3db7d9a4a287261c60bb) — Expanded `Library:BuildTitleAnimationPalette()`, `Library:SyncTitleAnimationState()`, `Library:EnsureTitleAnimationState()` (v1.11.1+build.1) · `Library.lua`.
- [`81dd8dc56`](https://github.com/Fyntra-Development/UiLibrary/commit/81dd8dc5649b28ed2f674c5bc2088775a5cf672e) — Synchronize component version/release metadata in `versions.json`.
- [`b7ee86f04`](https://github.com/Fyntra-Development/UiLibrary/commit/b7ee86f04530bcee846d0b372bb2937b92878bdf) — Implementation/behavior maintenance (v1.7.0+build.1) · `addons/ThemeManager.lua`.
- [`5d743981a`](https://github.com/Fyntra-Development/UiLibrary/commit/5d743981a51ccf061037598cddec22e64ae8f801) — Expanded `Library:TriggerTitleAnimation()` (v1.11.0+build.1) · `Library.lua`.
- [`2ef4609ad`](https://github.com/Fyntra-Development/UiLibrary/commit/2ef4609ad989e8de6b2f577c08141d5a285bdbfe) — Synchronize component version/release metadata in `versions.json`.
- [`27d9f9d16`](https://github.com/Fyntra-Development/UiLibrary/commit/27d9f9d162d18968eed586910d5db5cbbaa1d8e1) — Slow sinusoidal ribbon: adjacent characters are close enough in phase (v1.10.1+build.1) · `Library.lua`.
- [`6d0b7bd8b`](https://github.com/Fyntra-Development/UiLibrary/commit/6d0b7bd8bbed5f5d99258615511972b6101d2d87) — Synchronize component version/release metadata in `versions.json`.
- [`2410f88a5`](https://github.com/Fyntra-Development/UiLibrary/commit/2410f88a5ce10d5a6a8c46039098d0b5acd1851b) — Implementation/behavior maintenance (v1.6.0+build.1) · `addons/ThemeManager.lua`.
- [`adee1c0e2`](https://github.com/Fyntra-Development/UiLibrary/commit/adee1c0e28bafb9f29df5a7e1ed42b44b1155bab) — Refined `Library:SetCursorStyle()`, `Library:ResetTitleAnimation()` (v1.10.0+build.1) · `Library.lua`.
- [`f3a06a5f3`](https://github.com/Fyntra-Development/UiLibrary/commit/f3a06a5f31f9059dee54c57d30f9b4aeca5f9363) — Synchronize component version/release metadata in `versions.json`.
- [`9aa2866cf`](https://github.com/Fyntra-Development/UiLibrary/commit/9aa2866cfb372eca980d9504630f97fa9baa34cc) — Refined `Library:ApplyTitleAnimation()`, `Library:UpdateFont()` · `Library.lua`.
- [`d08a1b8bd`](https://github.com/Fyntra-Development/UiLibrary/commit/d08a1b8bdc8a5656560221ba9cf27934b1bb3237) — Updated `AddTitleOffset()`, `SplitTitleCharacters()` (v1.9.0+build.1) · `Library.lua`.
- [`61b639c76`](https://github.com/Fyntra-Development/UiLibrary/commit/61b639c76a0248b11e8a1f7dd33c98121b8a81d6) — Synchronize component version/release metadata in `versions.json`.
- [`177d453c4`](https://github.com/Fyntra-Development/UiLibrary/commit/177d453c49e0062bfe623fced316b0ad990ad4d1) — Implementation/behavior maintenance; controls: `Title animation` (v1.5.0+build.1) · `addons/ThemeManager.lua`.
- [`9cf407cfa`](https://github.com/Fyntra-Development/UiLibrary/commit/9cf407cfa733786eb23d82d88052ae89766867e7) — Expanded `Library:GetTitleAnimations()`, `Library:ResetTitleAnimation()`, `Library:ApplyTitleAnimation()` (v1.8.0+build.1) · `Library.lua`.
- [`702960e8c`](https://github.com/Fyntra-Development/UiLibrary/commit/702960e8c21480edd7f4f4c20358ac88f012b699) — Synchronize component version/release metadata in `versions.json`.
- [`604612ed5`](https://github.com/Fyntra-Development/UiLibrary/commit/604612ed5e5158481f0d909dbe7f6b82dd5cb2a2) — Expanded `ThemeManager:CreateOverlayLabel()`, `ThemeManager:CancelOverlayTweens()`, `ThemeManager:ApplyOverlayLayout()`; controls: `Cursor` (v1.4.0+build.1) · `addons/ThemeManager.lua`.
- [`bb4b809fb`](https://github.com/Fyntra-Development/UiLibrary/commit/bb4b809fbb8966d5e715a61b557ed1185714d820) — Expanded `Library:GetCursorStyles()`, `Library:SetCursorStyle()` (v1.7.0+build.1) · `Library.lua`.
- [`2170926c4`](https://github.com/Fyntra-Development/UiLibrary/commit/2170926c4b3ea60e5515a9ffb77647b55a1e015f) — Update font asset: `Orbitron.ttf`.
- [`cee92d5e1`](https://github.com/Fyntra-Development/UiLibrary/commit/cee92d5e1e59e0b157751de63bf013be88b9b6d9) — Update font asset: `Sora.ttf`.
- [`9ed207794`](https://github.com/Fyntra-Development/UiLibrary/commit/9ed207794008bbfb93224acae8975a7375787f9a) — Update font asset: `Oxanium.ttf`.
- [`27b88d9c8`](https://github.com/Fyntra-Development/UiLibrary/commit/27b88d9c8a9ac50921f92aa7c61e2c06b5ef2ad4) — Add uploaded repository files/assets (paths visible in linked diff).
- [`e563e2f8e`](https://github.com/Fyntra-Development/UiLibrary/commit/e563e2f8ee9620f6dcc7f59d73ecfe4110993f7c) — Add uploaded repository files/assets (paths visible in linked diff).
- [`197f5b709`](https://github.com/Fyntra-Development/UiLibrary/commit/197f5b709677da774828dc74bd96c067240c104f) — Synchronize component version/release metadata in `versions.json`.
- [`f58d1b1b0`](https://github.com/Fyntra-Development/UiLibrary/commit/f58d1b1b01b6b720ce36f1c515c19182666d4d76) — Implementation/behavior maintenance (v1.3.0+build.1) · `addons/ThemeManager.lua`.
- [`30c5c6a02`](https://github.com/Fyntra-Development/UiLibrary/commit/30c5c6a027c85aa97e3d1d0a73528776dce0b20e) — Refined `Library:CreateWindow()` (v1.6.0+build.1) · `Library.lua`.
- [`7220568a3`](https://github.com/Fyntra-Development/UiLibrary/commit/7220568a3960f4cdc72a7ff718f063fa9cd8abe1) — Update font asset: `SpaceGrotesk-Regular.ttf`.
- [`e6fc55142`](https://github.com/Fyntra-Development/UiLibrary/commit/e6fc5514251ffc2e94f1047407365f3e3c477c52) — Synchronize component version/release metadata in `versions.json`.
- [`57d485635`](https://github.com/Fyntra-Development/UiLibrary/commit/57d48563553e920cef48a4121b81a15476274a89) — Implementation/behavior maintenance · `Example.lua`.
- [`964c2df1c`](https://github.com/Fyntra-Development/UiLibrary/commit/964c2df1c74078409a3587ca805461ed11ee704e) — Implementation/behavior maintenance (v1.5.2+build.1) · `Library.lua`.
- [`250ba1d18`](https://github.com/Fyntra-Development/UiLibrary/commit/250ba1d18b5888ad84984de95602d8f4ca76d29a) — Updated `EncodeRepoPath()`, `FetchRepoFile()` (v1.5.2+build.1) · `Loader.lua`.
- [`c485fdb24`](https://github.com/Fyntra-Development/UiLibrary/commit/c485fdb24d5daddd90a1476af6af9fc8d0e06481) — Synchronize component version/release metadata in `versions.json`.
- [`25540dc96`](https://github.com/Fyntra-Development/UiLibrary/commit/25540dc962fb6d168d441b8e6d3d2e83a1367c6e) — Refined `Library:CreateOptionWheel()` (v1.5.1+build.1) · `Library.lua`.
- [`08221c3d1`](https://github.com/Fyntra-Development/UiLibrary/commit/08221c3d16ebe151249b4cdddf0897ee8d8cceeb) — Synchronize component version/release metadata in `versions.json`.
- [`050d36a91`](https://github.com/Fyntra-Development/UiLibrary/commit/050d36a91e7b92ee410479bde5b69d48070ec3af) — Refined `Library:CreateUtilityWindow()`, `Library:CreateOptionWheel()`; controls: `No utilities available` (v1.5.0+build.1) · `Library.lua`.
- [`8d43225c5`](https://github.com/Fyntra-Development/UiLibrary/commit/8d43225c5586d607feb2010e53763b0e7933fae7) — Synchronize component version/release metadata in `versions.json`.
- [`d97b66957`](https://github.com/Fyntra-Development/UiLibrary/commit/d97b669570dc63c93309311d80e37521ccb8cbd3) — Expanded `Library:ParseVersion()`, `Library:CompareVersions()`, `Library:IsVersionNewer()` (v1.4.0+build.1) · `Library.lua`.
- [`2594f9544`](https://github.com/Fyntra-Development/UiLibrary/commit/2594f954448ce0939d1d01715804b604520aaf7b) — Synchronize component version/release metadata in `versions.json`.
- [`1ff2b8371`](https://github.com/Fyntra-Development/UiLibrary/commit/1ff2b8371b61aa69b6709255aa698e8819a4ef2c) — Implementation/behavior maintenance (v1.3.11) · `Library.lua`.
- [`0619c76c7`](https://github.com/Fyntra-Development/UiLibrary/commit/0619c76c7477906ac7c1012064539e19e53d1a2d) — Implementation/behavior maintenance · `Library.lua`.
- [`d3bdcedfd`](https://github.com/Fyntra-Development/UiLibrary/commit/d3bdcedfdcd0fbc95477d4658ce176690523bd17) — Synchronize component version/release metadata in `versions.json`.
- [`98b5cfca5`](https://github.com/Fyntra-Development/UiLibrary/commit/98b5cfca54d3a4d48c00ce36327b6d39e0c717d5) — Refined `Library:CreateDataTable()`, `Library:GiveSignal()`; controls: `Priority`, `Teleport` · `Example.lua`.
- [`68e028c8e`](https://github.com/Fyntra-Development/UiLibrary/commit/68e028c8e65aea1ad06a83729f60cb2bc1eddc39) — Expanded `Row:RefreshData()` (v1.3.10) · `Library.lua`.
- [`f2bd11dd1`](https://github.com/Fyntra-Development/UiLibrary/commit/f2bd11dd1228be21e062c1e9d40fb4726c3af56c) — Implementation/behavior maintenance · `Library.lua`.
- [`58e7c7069`](https://github.com/Fyntra-Development/UiLibrary/commit/58e7c7069b4af7b41725491daf6e754d9a52284f) — Synchronize component version/release metadata in `versions.json`.
- [`647f408b6`](https://github.com/Fyntra-Development/UiLibrary/commit/647f408b6a314da32d004f658f69e29ee86b6193) — Implementation/behavior maintenance · `Loader.lua`.
- [`83df6f140`](https://github.com/Fyntra-Development/UiLibrary/commit/83df6f140e908d36b0c79e064a905f18d5fe8142) — Expanded `Window:SetPosition()`, `Window:GetPosition()` (v1.3.9-r2) · `Library.lua`.
- [`91134fbd6`](https://github.com/Fyntra-Development/UiLibrary/commit/91134fbd68fe210fc4c835e6a7d83ea6d3503dce) — Synchronize component version/release metadata in `versions.json`.
- [`7d9ad0548`](https://github.com/Fyntra-Development/UiLibrary/commit/7d9ad0548416fb9047adb3241194df93d3d8a409) — Refined `Library:ApplyFont()`, `Library:CreateWindow()` · `Library.lua`.
- [`036ec03e7`](https://github.com/Fyntra-Development/UiLibrary/commit/036ec03e72fb22eb844700a5f2b3c3595d171ce2) — Implementation/behavior maintenance (v1.3.9) · `Library.lua`.
- [`4e8415574`](https://github.com/Fyntra-Development/UiLibrary/commit/4e8415574a06963e1646e68030cfc1afa1eb4259) — Implementation/behavior maintenance · `Loader.lua`.
- [`5a5dfe750`](https://github.com/Fyntra-Development/UiLibrary/commit/5a5dfe7501e3f6116c903c834c79c12601a0ef46) — Refined `Library:CreateWindow()`, `Library:GiveSignal()`; controls: `Skin Changer` · `Example.lua`.
- [`410c545d4`](https://github.com/Fyntra-Development/UiLibrary/commit/410c545d40536277e2f2456200573adc284d6ac5) — Expanded `Library:CreateUtilityWindow()`, `Host:Resize()`, `Window:BringToFront()` (v1.3.9) · `Library.lua`.
- [`554d4f095`](https://github.com/Fyntra-Development/UiLibrary/commit/554d4f0956fe18b0d56538947817942df00a6c10) — Updated `ResolveRowTextColor()` · `Library.lua`.
- [`f30dd4505`](https://github.com/Fyntra-Development/UiLibrary/commit/f30dd45051b3a7dc43119347561dee86e454eb8a) — Synchronize component version/release metadata in `versions.json`.
- [`3ea956986`](https://github.com/Fyntra-Development/UiLibrary/commit/3ea956986d009693e37d57e63f46b3bca7b9ab15) — Implementation/behavior maintenance (v1.3.8) · `Library.lua`.
- [`43b8dabc0`](https://github.com/Fyntra-Development/UiLibrary/commit/43b8dabc068a6f8150da5b5f3f005bd8404d0d30) — Implementation/behavior maintenance · `Example.lua`.
- [`13ec8572d`](https://github.com/Fyntra-Development/UiLibrary/commit/13ec8572d5067f7da6cac1478b83b4bb084516d4) — Implementation/behavior maintenance · `Library.lua`.
- [`1678f2fde`](https://github.com/Fyntra-Development/UiLibrary/commit/1678f2fdecd7cbd05cc2b66e4d1a96df1dcba595) — Implementation/behavior maintenance · `Example.lua`.
- [`5be652bad`](https://github.com/Fyntra-Development/UiLibrary/commit/5be652badf6c1a68cdda3f9edca93dcf43bb9508) — Implementation/behavior maintenance; controls: `Print selected`, `Mark priority` · `Example.lua`.
- [`8e46eeca7`](https://github.com/Fyntra-Development/UiLibrary/commit/8e46eeca716f13e1a9d81ebb56b27b6c54f3b665) — Implementation/behavior maintenance · `Library.lua`.
- [`df50eae63`](https://github.com/Fyntra-Development/UiLibrary/commit/df50eae639a69f2346dfd94eb1003e201296ed4d) — Expanded `DataTable:RefreshDetails()`, `Funcs:AddDataTable()`, `Tab:AddDataTable()` · `Library.lua`.
- [`9fff64752`](https://github.com/Fyntra-Development/UiLibrary/commit/9fff647526edb0029efe0a29cd719f9d23896fc5) — Updated `RefreshPlayerTable()`; controls: `Console`, `Players` · `Example.lua`.
- [`631251c88`](https://github.com/Fyntra-Development/UiLibrary/commit/631251c888a059676e5dd8397870417ebbc10937) — Expanded `Tab:AddFullGroupbox()`, `Tab:AddConsole()`, `Tab:AddTable()` · `Library.lua`.
- [`c15c36e11`](https://github.com/Fyntra-Development/UiLibrary/commit/c15c36e11872d21984cfcafd8fb329de65490103) — Implementation/behavior maintenance · `Library.lua`.
- [`fe3a139fb`](https://github.com/Fyntra-Development/UiLibrary/commit/fe3a139fb7476ccc42a6a77be08f959dbbcea345) — Updated `RefreshUtilityButton()` · `Library.lua`.
- [`87eb31654`](https://github.com/Fyntra-Development/UiLibrary/commit/87eb31654c36c818c8e1fbc9a535d6e48655653b) — Expanded `Button:RefreshFormaStyle()`, `Funcs:AddConsole()`, `Console:Refresh()` · `Library.lua`.
- [`22461ff62`](https://github.com/Fyntra-Development/UiLibrary/commit/22461ff62838f4dab50ece775c74ff83deeeecb3) — Implementation/behavior maintenance · `Library.lua`.
- [`f70be3de0`](https://github.com/Fyntra-Development/UiLibrary/commit/f70be3de08e81e94dbeef28442ea4e34869f242d) — Synchronize component version/release metadata in `versions.json`.
- [`bed59e0c1`](https://github.com/Fyntra-Development/UiLibrary/commit/bed59e0c1a76c7c8420d1cce9957a4d94d9e8a35) — Implementation/behavior maintenance (v1.3.7) · `Library.lua`.
- [`394ccb57a`](https://github.com/Fyntra-Development/UiLibrary/commit/394ccb57a9f7f09634592c45fc4c5abaa9c77dae) — Update font asset: `SF-Pro.ttf`.
- [`9ff8e20f8`](https://github.com/Fyntra-Development/UiLibrary/commit/9ff8e20f860ef67dc24cad9f5fa6b6aa670ee5e4) — Update font asset: `SF-Pro.ttf`.
- [`3318a8d9d`](https://github.com/Fyntra-Development/UiLibrary/commit/3318a8d9d1e6b4ba1191ec6c3937889685ad1436) — Synchronize component version/release metadata in `versions.json`.
- [`23d7d2f10`](https://github.com/Fyntra-Development/UiLibrary/commit/23d7d2f10f2b43f0c737d7391ca55dce1711fba4) — Refined `Library:GetFontVisualScale()`, `Library:SetTextSize()` · `Library.lua`.
- [`0ea1144d5`](https://github.com/Fyntra-Development/UiLibrary/commit/0ea1144d5d5a29c109fbb55aa844ba14a1f707fb) — Refined `Library:LoadFont()` · `Library.lua`.
- [`47d9e039a`](https://github.com/Fyntra-Development/UiLibrary/commit/47d9e039ab3cab889eebda2f018bb3e3445ba2c8) — Expanded `Library:GetFontVisualScale()`, `Library:RefreshTextSizes()` · `Library.lua`.
- [`78827052c`](https://github.com/Fyntra-Development/UiLibrary/commit/78827052c4049b50a26f13b0127667be89bb8341) — Implementation/behavior maintenance (v1.3.6) · `Library.lua`.
- [`70ff6fc7b`](https://github.com/Fyntra-Development/UiLibrary/commit/70ff6fc7b1e9fa44965ba5c1e647d1de804dcf4a) — Synchronize component version/release metadata in `versions.json`.
- [`b7ab49348`](https://github.com/Fyntra-Development/UiLibrary/commit/b7ab49348882118b17cb9f44f980e8be3f89f670) — Implementation/behavior maintenance (v1.3.5) · `Library.lua`.
- [`7791e6f87`](https://github.com/Fyntra-Development/UiLibrary/commit/7791e6f87bb3ae867490013157cfcbda8522d69b) — Synchronize component version/release metadata in `versions.json`.
- [`2f49c9b45`](https://github.com/Fyntra-Development/UiLibrary/commit/2f49c9b4551e76e904f215eb0b61d0d42858f46a) — Refined `Updater:InstallManifest()`, `Updater:EnsureInstalled()` · `Loader.lua`.
- [`10508f013`](https://github.com/Fyntra-Development/UiLibrary/commit/10508f013ef521a7afde35f9612cd852e1522b62) — Implementation/behavior maintenance (v1.3.4) · `Library.lua`.
- [`5115f1915`](https://github.com/Fyntra-Development/UiLibrary/commit/5115f19155013a9aa04f82f08e34426e7814568b) — Range sliders expose a minimum and maximum value on the same track; controls: `Distance range`, `Compact range` · `Example.lua`.
- [`0bd827cae`](https://github.com/Fyntra-Development/UiLibrary/commit/0bd827caef0f0247141fd2494eada232cf62c580) — Refined `Library:DetectGameName()`, `Library:SetTextScale()` (v1.3.4) · `Library.lua`.
- [`a624a9c00`](https://github.com/Fyntra-Development/UiLibrary/commit/a624a9c00e7bbba6c21a141d3c6d12ef4c30d62a) — Synchronize component version/release metadata in `versions.json`.
- [`f11f90cd8`](https://github.com/Fyntra-Development/UiLibrary/commit/f11f90cd84e5e428333c5fc0dc2d3b3988ae60b5) — Implementation/behavior maintenance · `Library.lua`.
- [`48e9f52a6`](https://github.com/Fyntra-Development/UiLibrary/commit/48e9f52a6cb7c79db50d8273ebf7c5fd56f6d442) — Updated `StopFormaCursor()`; controls: `Update available` (v1.3.3) · `Library.lua`.
- [`fe3ef5dc1`](https://github.com/Fyntra-Development/UiLibrary/commit/fe3ef5dc1c4aeef4f80496a05ee686f06944da3d) — Expanded `Updater:StyleUpdatePrompt()`, `Updater:BeginUpdateAnimation()`, `Library:PerformUpdateRestart()`; controls: `Update available`, `Updating Forma` · `Loader.lua`.
- [`d93baab80`](https://github.com/Fyntra-Development/UiLibrary/commit/d93baab80a539f2518b914163d141357845b0c7c) — Synchronize component version/release metadata in `versions.json`.
- [`cd9e6b31c`](https://github.com/Fyntra-Development/UiLibrary/commit/cd9e6b31c444cecda796dbb19c775e2d1ceb039a) — Expanded `Library:CheckAllUpdates()` (v1.3.2) · `Library.lua`.
- [`1faa93a39`](https://github.com/Fyntra-Development/UiLibrary/commit/1faa93a39d9ff61165447d778990a5a2bf8ec867) — Synchronize component version/release metadata in `versions.json`.
- [`8ff761ea8`](https://github.com/Fyntra-Development/UiLibrary/commit/8ff761ea8083bae5949dbefe66934b10b6b2506c) — Implementation/behavior maintenance (v1.3.1) · `Library.lua`.
- [`465fbdcff`](https://github.com/Fyntra-Development/UiLibrary/commit/465fbdcff4dfe3801940ddfe06ca4adf0f8f9b52) — Implementation/behavior maintenance · `Library.lua`.
- [`0f36a444d`](https://github.com/Fyntra-Development/UiLibrary/commit/0f36a444d9a52d202e94b9e72b9fa69de275339b) — Implementation/behavior maintenance · `Loader.lua`.
- [`8c7648195`](https://github.com/Fyntra-Development/UiLibrary/commit/8c764819542a31d437d5cad7fe84fd41e6b26b76) — Synchronize component version/release metadata in `versions.json`.
- [`39eaf8e95`](https://github.com/Fyntra-Development/UiLibrary/commit/39eaf8e95257f52b4c68fa130d326ccdc64bad56) — Implementation/behavior maintenance · `addons/ThemeManager.lua`.
- [`9aad07d39`](https://github.com/Fyntra-Development/UiLibrary/commit/9aad07d3942d8ffd6d07fda0bb8c68b055cff498) — Loader.lua keeps the installed Forma release cached locally. That lets the · `Example.lua`.
- [`dbe42cb0b`](https://github.com/Fyntra-Development/UiLibrary/commit/dbe42cb0b0fde758a768ac81892efc0db08fa07b) — Expanded `Library:PreviewUpdateNotification()`; controls: `Forma update available`, `Yes` (v1.3.0) · `Library.lua`.
- [`5f068c1e2`](https://github.com/Fyntra-Development/UiLibrary/commit/5f068c1e2ac738b45ee741270cf207582a0266ae) — Expanded `Updater:FetchManifest()`, `Updater:ReadInstalledManifest()`, `Updater:WriteInstalledManifest()` · `Loader.lua`.
- [`3fde45019`](https://github.com/Fyntra-Development/UiLibrary/commit/3fde450195a8ffe3ddb9d19e64491562172ca2f3) — Expanded `Wheel:RefreshKeybindAvoidance()` · `Library.lua`.
- [`031b594ac`](https://github.com/Fyntra-Development/UiLibrary/commit/031b594ac98aabf7c10225e942fe84fe30dd73c9) — Synchronize component version/release metadata in `versions.json`.
- [`841f01058`](https://github.com/Fyntra-Development/UiLibrary/commit/841f01058afa4c30c2dc8244bd7e82be9ede41e8) — Implementation/behavior maintenance (v1.2.0) · `addons/ThemeManager.lua`.
- [`2fa6fd34d`](https://github.com/Fyntra-Development/UiLibrary/commit/2fa6fd34dc121a56b7c3f1ccb4a94dbf468ce798) — Implementation/behavior maintenance (v1.2.0) · `addons/SaveManager.lua`.
- [`aca0edabc`](https://github.com/Fyntra-Development/UiLibrary/commit/aca0edabce83333c65d0eba2aae11c1b0f1ae6e6) — Implementation/behavior maintenance (v1.2.0) · `addons/MenuManager.lua`.
- [`e1190a882`](https://github.com/Fyntra-Development/UiLibrary/commit/e1190a8829709ea5fde4654cfd1329d4c17e27ca) — Updated `BuildModeItems()`, `SwapItems()`; controls: `No saved configs`, `No themes available` (v1.2.0) · `Library.lua`.
- [`a846a3d88`](https://github.com/Fyntra-Development/UiLibrary/commit/a846a3d88a5e3cbe6e7c3db21808b70ceca3ef9d) — Implementation/behavior maintenance · `Example.lua`.
- [`5d58e5c77`](https://github.com/Fyntra-Development/UiLibrary/commit/5d58e5c7702e99e5a3855253e0d3e0f904b16cdf) — Synchronize component version/release metadata in `versions.json`.
- [`fb8db5031`](https://github.com/Fyntra-Development/UiLibrary/commit/fb8db50311f0f1f41fd116b38fa34f4360c21386) — Implementation/behavior maintenance (v1.1.0) · `addons/ThemeManager.lua`.
- [`56cf7c649`](https://github.com/Fyntra-Development/UiLibrary/commit/56cf7c64998b41c9af9a6017b8d9c40e4b577efe) — Implementation/behavior maintenance (v1.1.0) · `addons/SaveManager.lua`.
- [`403078778`](https://github.com/Fyntra-Development/UiLibrary/commit/40307877843fc8ff74e22c38d27018cfee7663bb) — Implementation/behavior maintenance (v1.1.0) · `addons/MenuManager.lua`.
- [`89a87356a`](https://github.com/Fyntra-Development/UiLibrary/commit/89a87356acb1017cd2217ebbfefa2674f4706de2) — Implementation/behavior maintenance (v1.1.0) · `Library.lua`.
- [`9b2fc210b`](https://github.com/Fyntra-Development/UiLibrary/commit/9b2fc210b52581eaca8cc174f88fc64cf69772b5) — Expanded `Library:SetAutoUpdateEnabled()`, `Library:SetUpdateRestartHandler()`, `Library:SetUpdateRestartSource()`; controls: `Forma update available`, `Yes` (v1.0.0) · `Library.lua`.
- [`8b5670def`](https://github.com/Fyntra-Development/UiLibrary/commit/8b5670def52e889ea24be4ce991d966c3b6f07e2) — Expanded `Wheel:GetMode()`, `Wheel:SetStyle()` · `Library.lua`.
- [`082971aee`](https://github.com/Fyntra-Development/UiLibrary/commit/082971aee9b36c74b9777a70c1613431ed80eb4b) — oops.
- [`1f188387c`](https://github.com/Fyntra-Development/UiLibrary/commit/1f188387c616d757c2d9627c1e0478f9deb83951) — Update print statement from 'Hello' to 'Goodbye'.
- [`9fe7818cb`](https://github.com/Fyntra-Development/UiLibrary/commit/9fe7818cbd2cd8bcfe81713f960f2b373ea7e206) — just this once.
- [`bd44933fc`](https://github.com/Fyntra-Development/UiLibrary/commit/bd44933fce10d6ffdeb520a7cf074d7b64a6a3a5) — oh boy.
- [`824c37d77`](https://github.com/Fyntra-Development/UiLibrary/commit/824c37d77caa8cbf18f454213d313ec29818082e) — i dont know: part 0.

### 2026-09-20

- [`d76e38068`](https://github.com/Fyntra-Development/UiLibrary/commit/d76e38068e796be72fdd262a6408e964f066e9a7) — Update print statement from 'Hello' to 'Goodbye'.
- [`55e415d29`](https://github.com/Fyntra-Development/UiLibrary/commit/55e415d2968743080544db369d83cf7ee9df2b5c) — Add Comic Mono font.
- [`b3c6dd84d`](https://github.com/Fyntra-Development/UiLibrary/commit/b3c6dd84de337ece3fdbb22650e5e8e3faccc697) — i dont know: part 4.

### 2026-09-19

- [`ee2333618`](https://github.com/Fyntra-Development/UiLibrary/commit/ee23336186878e679201dc47a00aa7c054d368e4) — pick a color.
- [`44b640d8c`](https://github.com/Fyntra-Development/UiLibrary/commit/44b640d8c8b67e7534cd0b9d3a85a0d5dd01f6e3) — i dont know part 3.
- [`489a9e643`](https://github.com/Fyntra-Development/UiLibrary/commit/489a9e64353821c3a062c4be697dadcbe2d2f029) — i dont know part 2.
- [`30885361d`](https://github.com/Fyntra-Development/UiLibrary/commit/30885361d0fc3d5fc4078c2eeabca9b73dd0db6b) — i dont know.
- [`7aed04687`](https://github.com/Fyntra-Development/UiLibrary/commit/7aed0468706f709d746f4ec4dd41b4ee08e65372) — the whole 9 yards.
- [`c5a6de95b`](https://github.com/Fyntra-Development/UiLibrary/commit/c5a6de95b314a6dd1ccde0458f384fd3fc449bfa) — he was clicking buttons and stuff.

### 2026-08-16

- [`c1ec0b367`](https://github.com/Fyntra-Development/UiLibrary/commit/c1ec0b36716d808f234df3f5091f886b80426cd6) — Fix notification shell artifacts and solid picker indicator.
- [`aff770725`](https://github.com/Fyntra-Development/UiLibrary/commit/aff77072586e9a3d6d7550b29ac6c1213097b5b0) — Base Example.lua on Linoria layout.
- [`4e941cc0f`](https://github.com/Fyntra-Development/UiLibrary/commit/4e941cc0fefcef8305a0453963860987018e64d7) — Rewrite Example.lua as a documented Forma showcase (#59).
- [`46f6e37dd`](https://github.com/Fyntra-Development/UiLibrary/commit/46f6e37dd5993303e0c22a7a3360a7b1815b8e86) — Refine animated colorpicker controls and transitions (#58).
- [`fab1fc449`](https://github.com/Fyntra-Development/UiLibrary/commit/fab1fc44936404163afd20d91f5e69892a08a3a7) — Add animated colorpicker settings modes.
- [`52731f437`](https://github.com/Fyntra-Development/UiLibrary/commit/52731f43765fede1578decc8fdc3e28e11e7f6d9) — Connect notification accent, progress, and stretch motion.
- [`13824a3d8`](https://github.com/Fyntra-Development/UiLibrary/commit/13824a3d8e74def0a8addb54c51e4eefe0f9cc2b) — Refine notification sizing, progress, and stack motion.
- [`fb1edb7f2`](https://github.com/Fyntra-Development/UiLibrary/commit/fb1edb7f2e1446f43f90a3bc759d1c01806078ac) — Smooth notifications, sliders, and Target HUD health.

### 2026-08-15

- [`d39854744`](https://github.com/Fyntra-Development/UiLibrary/commit/d39854744408f9c411c8e0995bf73e832f53c26e) — Fix slider FocusLost callback syntax.
- [`dcc56476a`](https://github.com/Fyntra-Development/UiLibrary/commit/dcc56476a5f0287885106cef57cf882a309c778b) — Fix tooltip callback syntax.
- [`0c2466801`](https://github.com/Fyntra-Development/UiLibrary/commit/0c246680197ecd96f15a30bb2bdf033e98b4183c) — Restore single-file library and keep text shaping fix.
- [`fa5187470`](https://github.com/Fyntra-Development/UiLibrary/commit/fa5187470aa6e9fc4c9412f2da26c97883c055c3) — Fix overlapping characters in animated text inputs.
- [`a77bc83df`](https://github.com/Fyntra-Development/UiLibrary/commit/a77bc83df9e1f45c19fb3fb6bba8a491d60df615) — Restore Always, Toggle, and Hold keybind modes.
- [`35cd0dcad`](https://github.com/Fyntra-Development/UiLibrary/commit/35cd0dcad65eeae366f8119063369cdcdcbc53b9) — Hide inactive toggle shade and expand examples.
- [`3870eb6f1`](https://github.com/Fyntra-Development/UiLibrary/commit/3870eb6f1e2e71380a73d3712c1b2561507175e9) — Add dropdown dependencies and bidirectional row fades.
- [`7be3eac2a`](https://github.com/Fyntra-Development/UiLibrary/commit/7be3eac2a83e498e518c2534369563c2cdcd0246) — Prevent tabbox fade-driver resize errors (#46).
- [`920d1028b`](https://github.com/Fyntra-Development/UiLibrary/commit/920d1028bc76ffbd4485289e008bb5f00ddbd8f1) — Add functional tabboxes and clean color picker outlines (#45).
- [`10a3724e7`](https://github.com/Fyntra-Development/UiLibrary/commit/10a3724e7bfb23db48b2711b44edd46b2322c5b9) — Refine control shading, notifications, and game detection (#44).
- [`9b07dda92`](https://github.com/Fyntra-Development/UiLibrary/commit/9b07dda9207f02d1288cd7f858822d5e33ab8a3b) — Improve input feedback, button rows, warnings, and theme blends (#43).
- [`d32bbe03b`](https://github.com/Fyntra-Development/UiLibrary/commit/d32bbe03b0551c3a49ac4ed7ca289a1b3179eeed) — Extend watermark metadata and animated HUD accents (#42).
- [`b71ce3dee`](https://github.com/Fyntra-Development/UiLibrary/commit/b71ce3dee4e600bc82fa40c2208cdc49bbd95ff5) — Polish watermark and keep UI motion synchronized (#41).
- [`3f8c5b240`](https://github.com/Fyntra-Development/UiLibrary/commit/3f8c5b240fa44c0fd741f5179b995b86234a94ea) — Add smooth scroll reveal, typing, resizing, and watermark (#40).
- [`77759584c`](https://github.com/Fyntra-Development/UiLibrary/commit/77759584c4b647822f983dab028646cc98820111) — Polish dropdown layout, drag motion, and theme controls (#39).
- [`24050ce26`](https://github.com/Fyntra-Development/UiLibrary/commit/24050ce261cc581cecb00a79f5b2f7d9dfd89e37) — Fix missing fades in tabs, color pickers, and dropdown text (#38).
- [`734ac2579`](https://github.com/Fyntra-Development/UiLibrary/commit/734ac2579d81ff70053e00f786ab7bf43cf3db06) — Fix descendant fades across animated UI.
- [`95e3b286a`](https://github.com/Fyntra-Development/UiLibrary/commit/95e3b286a329547bcb7625aa5371c64b1fe52b2c) — Rewrite every UI animation around smooth fades and slides (#37).
- [`3b989a03d`](https://github.com/Fyntra-Development/UiLibrary/commit/3b989a03d1b2c947aee637bdea8d810a7d6678fa) — Rewrite UI animations without scale effects.
- [`c38673a2e`](https://github.com/Fyntra-Development/UiLibrary/commit/c38673a2ef90f99efd470cf12d6e215385b27100) — Add fluid fades and coordinated UI transitions (#36).
- [`965e05aab`](https://github.com/Fyntra-Development/UiLibrary/commit/965e05aab12ffea99f6e1f78468457c66946b4de) — Rewrite UI motion for smooth, responsive animations (#35).

### 2026-08-14

- [`1fc135c1d`](https://github.com/Fyntra-Development/UiLibrary/commit/1fc135c1d5c2e05c2c80fd3351498d0c08f91db6) — Revert "Restyle Forma to match the compact reference UI (#34)".
- [`bac87335c`](https://github.com/Fyntra-Development/UiLibrary/commit/bac87335c4f64110d9c9a133e594c202007f3ff8) — Restyle Forma to match the compact reference UI (#34).
- [`20c75c035`](https://github.com/Fyntra-Development/UiLibrary/commit/20c75c035e8812175b27caeec0fb8718dcb9b6ae) — Rewrite the UI motion system (#33).
- [`83876e734`](https://github.com/Fyntra-Development/UiLibrary/commit/83876e7347fb203a1475192a22ba4b42f9840898) — Improve UI motion and square HUD styling (#32).

### 2026-08-13

- [`3b33ebd8f`](https://github.com/Fyntra-Development/UiLibrary/commit/3b33ebd8f5a8864b5284081ff749fd5cd7e1dbdc) — Smooth Target HUD health and menu easing (#31).
- [`568358b2e`](https://github.com/Fyntra-Development/UiLibrary/commit/568358b2eb7f9e2efa1e8cbdad04798f47eed480) — Refine Target HUD layout and draggable release (#30).
- [`2e329247c`](https://github.com/Fyntra-Development/UiLibrary/commit/2e329247c86da70c81b2c994c77bf78d843df2cb) — Merge PR #29: Improve HUD display and watermark outline.
- [`cab0d433b`](https://github.com/Fyntra-Development/UiLibrary/commit/cab0d433b37137f5f21017e03d8c37cc79e167d2) — Remove watermark outline cleanup workflow.
- [`194d9c877`](https://github.com/Fyntra-Development/UiLibrary/commit/194d9c877cd544a57052fb1422de977ab12bbc4f) — Remove duplicate watermark outline block.
- [`b828ac079`](https://github.com/Fyntra-Development/UiLibrary/commit/b828ac0797849bd2fc740ee9c02651170eb8b57a) — Add watermark outline cleanup workflow.
- [`6c2367174`](https://github.com/Fyntra-Development/UiLibrary/commit/6c23671740b685937cecd799edae99cede9ba62c) — Clean Target HUD patch scaffolding.
- [`f6ff8ad14`](https://github.com/Fyntra-Development/UiLibrary/commit/f6ff8ad14c41a6ad00493a84154cc760d860c26c) — Refine Target HUD provider updates.
- [`09ed1b315`](https://github.com/Fyntra-Development/UiLibrary/commit/09ed1b31585906f822ae45a9af3ffb09e7fb2127) — Add Target HUD refinement workflow.
- [`4c8e3b333`](https://github.com/Fyntra-Development/UiLibrary/commit/4c8e3b33328e796ac340043dc37ad03ce20bd008) — Remove Target HUD patch workflow.
- [`f443c3654`](https://github.com/Fyntra-Development/UiLibrary/commit/f443c365486b93e4c2c6bd1ad8f207d8bf217d14) — Upgrade Target HUD health and labels.
- [`9b7ee1019`](https://github.com/Fyntra-Development/UiLibrary/commit/9b7ee1019f3110fd4da731f0d5648751c5520bc0) — Add Target HUD refinement script.
- [`497cc8d7a`](https://github.com/Fyntra-Development/UiLibrary/commit/497cc8d7ad49b310ccd66a5a1be6cab7412326cc) — Upgrade Target HUD health and labels.
- [`d804dea7d`](https://github.com/Fyntra-Development/UiLibrary/commit/d804dea7d3ff6995f726a897a8d0c279f94d7b58) — Add Target HUD validation workflow.
- [`1502a59cd`](https://github.com/Fyntra-Development/UiLibrary/commit/1502a59cdf504967d9b94cb62a4b64e4ae566b5d) — Stage Target HUD visibility and public fields.
- [`cab311948`](https://github.com/Fyntra-Development/UiLibrary/commit/cab311948d89b712f3d81bc113b72b4004f824ab) — Stage Target HUD refresh behavior.
- [`15b5641dd`](https://github.com/Fyntra-Development/UiLibrary/commit/15b5641dded980beffb3f7eee10defa5d47f077e) — Stage Target HUD health and meter providers.
- [`5ae41413d`](https://github.com/Fyntra-Development/UiLibrary/commit/5ae41413d3ffb669e5b88c38078fc42c0b806ce1) — Stage Target HUD label management.
- [`c2d511fc2`](https://github.com/Fyntra-Development/UiLibrary/commit/c2d511fc2433c94431daa9545fbf89f2051f9f18) — Stage Target HUD custom labels.
- [`793b127d9`](https://github.com/Fyntra-Development/UiLibrary/commit/793b127d983ec5c3a9d5ea213c6b0a6e189c4dd0) — Stage Target HUD health animation.
- [`61c39e9bf`](https://github.com/Fyntra-Development/UiLibrary/commit/61c39e9bfdb0419dfb5d76ea3ba9b2f07ef9b2af) — Stage Target HUD meter and healthbar.
- [`706dffc8e`](https://github.com/Fyntra-Development/UiLibrary/commit/706dffc8eb44e57d702741a6d62412d3d852dd36) — Stage Target HUD base layout.
- [`4fe8dd48c`](https://github.com/Fyntra-Development/UiLibrary/commit/4fe8dd48cf9a26bb3d4ccebdb17ea3b7daa3c941) — Split Target HUD patch into smaller chunks.
- [`eb5c55279`](https://github.com/Fyntra-Development/UiLibrary/commit/eb5c55279e413e971ffd9d1cbdf968329790d106) — Add Target HUD patch script.
- [`84789ae43`](https://github.com/Fyntra-Development/UiLibrary/commit/84789ae433f5923c1b56f1374876439c89aa2645) — Unify menu fades and smooth MenuManager motion.
- [`738815651`](https://github.com/Fyntra-Development/UiLibrary/commit/7388156512f194f85b6a9d9821f43b11abcb687a) — Remove accidental placeholder.
- [`5e201ac01`](https://github.com/Fyntra-Development/UiLibrary/commit/5e201ac011f3742282750ef9c8318d14e1f4554b) — placeholder.
- [`421a7e297`](https://github.com/Fyntra-Development/UiLibrary/commit/421a7e297997f63894b7f6f20ed050907baee7e7) — Surface MenuManager controls and soften accent glow (#27).
- [`6ce2ef004`](https://github.com/Fyntra-Development/UiLibrary/commit/6ce2ef00467dcabe075075982568be7c298de927) — Remove accidental staging file.
- [`fd2c4100b`](https://github.com/Fyntra-Development/UiLibrary/commit/fd2c4100bea6a1ce9e83014373e01d59da84d889) — x.
- [`0d95fe540`](https://github.com/Fyntra-Development/UiLibrary/commit/0d95fe54085cc429359da6044e96046c2513d46f) — Add MenuManager, Target HUD, and opt-in searchable dropdowns.
- [`b419eb18c`](https://github.com/Fyntra-Development/UiLibrary/commit/b419eb18c76844d33f4a808da4e134306ca3aa20) — Fix dropdown runtime errors and add searchable popups.
- [`c4be86883`](https://github.com/Fyntra-Development/UiLibrary/commit/c4be86883c1f27995a830aae267499d971496a40) — Add missing Dropdown OnChanged API.
- [`0e7d54abd`](https://github.com/Fyntra-Development/UiLibrary/commit/0e7d54abd88f5d59b517e6fda737d7902e756881) — Make UI fades visible and fix Marin placement.
- [`3e2105011`](https://github.com/Fyntra-Development/UiLibrary/commit/3e2105011f5b1550deb9b5d188dde8bcc7746854) — Polish overlays dropdowns transitions and HUD styling.
- [`0d1c26963`](https://github.com/Fyntra-Development/UiLibrary/commit/0d1c26963b52107bae87713970beee239611a426) — Fix Marin overlay scale and placement.
- [`cdec2408a`](https://github.com/Fyntra-Development/UiLibrary/commit/cdec2408acea163c5f62543de721b7cc1294a22d) — Add elastic tab transitions and theme text sizing.
- [`9f2b92e1a`](https://github.com/Fyntra-Development/UiLibrary/commit/9f2b92e1af728023965d7f1a678f28a516be795e) — Add uploaded repository files/assets (paths visible in linked diff).
- [`658cc434f`](https://github.com/Fyntra-Development/UiLibrary/commit/658cc434f401a06325e116ba2fa6253dc45a429e) — Fix distorted runtime overlay images.
- [`9e9bfabe4`](https://github.com/Fyntra-Development/UiLibrary/commit/9e9bfabe48a36e868d04da1c454d5d1b7a235f58) — Fix corruption.
- [`2c8576979`](https://github.com/Fyntra-Development/UiLibrary/commit/2c8576979aea7e50199468543de80819dcd94f38) — Delete `assets/idfk/edp445.png`.
- [`70a93d417`](https://github.com/Fyntra-Development/UiLibrary/commit/70a93d417bb2875a8977ac0c7b36c2d7865aba0c) — Fix theme overlay positioning.
- [`1e87270a6`](https://github.com/Fyntra-Development/UiLibrary/commit/1e87270a69c58864e800a8aad75eb227f4548f2a) — Add uploaded repository files/assets (paths visible in linked diff).
- [`8af6acbe2`](https://github.com/Fyntra-Development/UiLibrary/commit/8af6acbe273edce1337eff8645e933dee13a390c) — Delete `assets/idfk/janedoe.png`.
- [`4f268a027`](https://github.com/Fyntra-Development/UiLibrary/commit/4f268a027a0c61915e15b7e7ee13cd462111a0b8) — Delete `assets/idfk/ibuki.png`.
- [`63bfc711d`](https://github.com/Fyntra-Development/UiLibrary/commit/63bfc711de79e9edf041dc85ff89bef08a2c2214) — Delete `assets/idfk/edp445.png`.
- [`0a7a677c7`](https://github.com/Fyntra-Development/UiLibrary/commit/0a7a677c7bc76671d8326cd823a520546d24a448) — Create NAN.txt.
- [`c31f28d20`](https://github.com/Fyntra-Development/UiLibrary/commit/c31f28d203698a235f64871390e1f092b954205e) — Add selectable UI overlay images.

### 2026-08-12

- [`bf351b8ef`](https://github.com/Fyntra-Development/UiLibrary/commit/bf351b8efb7b6465a02ff4045957bd72277430e2) — Fix tab geometry and simplify UI animations.
- [`c6db4f26c`](https://github.com/Fyntra-Development/UiLibrary/commit/c6db4f26c2a47d36f0af1b05c23b11806f0564e2) — Polish UI visual integration.
- [`51170a51b`](https://github.com/Fyntra-Development/UiLibrary/commit/51170a51bdea90f8ca3c102bb3f715912a3e98d1) — Polish UI motion, connected dropdowns, and font pack.
- [`e591c73da`](https://github.com/Fyntra-Development/UiLibrary/commit/e591c73da1452ee468298a83534b94bec1cffcbc) — Polish sliders and rounded controls.
- [`88719822b`](https://github.com/Fyntra-Development/UiLibrary/commit/88719822b9f84ff2cc69ed899448f785f337729e) — Use Rubik Light and add Miracode/Monocraft.
- [`f5d212ed0`](https://github.com/Fyntra-Development/UiLibrary/commit/f5d212ed062c3009eac7975ffc9f2ddd452cb125) — Use repo Rubik font by default.
- [`d724945e8`](https://github.com/Fyntra-Development/UiLibrary/commit/d724945e800ab135a9b2fe2780c87cefbcb368d0) — Rename RubikL.ttf to Rubik.ttf.
- [`471602f54`](https://github.com/Fyntra-Development/UiLibrary/commit/471602f54a626e4c49250e826c218361e8e352b0) — Delete `fonts/Rubik.ttf`.
- [`ff3729a7c`](https://github.com/Fyntra-Development/UiLibrary/commit/ff3729a7c114a05a91ab1cd5221ce4c3309e12ab) — Add uploaded repository files/assets (paths visible in linked diff).
- [`27556487d`](https://github.com/Fyntra-Development/UiLibrary/commit/27556487d43499bd13e6781a3483ee751913374e) — Add uploaded repository files/assets (paths visible in linked diff).
- [`0370dec0e`](https://github.com/Fyntra-Development/UiLibrary/commit/0370dec0ee51d99fe34f6fea420fe483200692f0) — Restore supplied Rubik font.
- [`ae4db8f78`](https://github.com/Fyntra-Development/UiLibrary/commit/ae4db8f78b9b7578a1e7f078f4fcad5e1824ab39) — Remove temporary file.
- [`b8c4bcef0`](https://github.com/Fyntra-Development/UiLibrary/commit/b8c4bcef0eda4398864ede38aa32c78f4164ca24) — temporary.
- [`eb1c3bf1c`](https://github.com/Fyntra-Development/UiLibrary/commit/eb1c3bf1c55c199a49986e5cba281e8e23f54716) — Remove temporary file.
- [`2b457886d`](https://github.com/Fyntra-Development/UiLibrary/commit/2b457886dd3a7e356f40168830ae0ddb7303a934) — temporary.
- [`91ff12960`](https://github.com/Fyntra-Development/UiLibrary/commit/91ff129607af3c7514ba648e717fb2ff37cb931e) — Remove temporary file.
- [`462fc20f2`](https://github.com/Fyntra-Development/UiLibrary/commit/462fc20f2343c8506f102802c0861145a36dee82) — temp.
- [`0202eaf8a`](https://github.com/Fyntra-Development/UiLibrary/commit/0202eaf8a8d74c94edfaad006fcb0db0f7c68602) — Remove temporary file.
- [`f0163ad7e`](https://github.com/Fyntra-Development/UiLibrary/commit/f0163ad7e4f6a0e2ed41c6e4b373dc0c760e4ab4) — temp.
- [`b02d7da84`](https://github.com/Fyntra-Development/UiLibrary/commit/b02d7da849b91e4ddd2b32b81ce53b8b4d181376) — Remove temporary noop file.
- [`97f690bb9`](https://github.com/Fyntra-Development/UiLibrary/commit/97f690bb9851f5fa3fc8ee3ef6a2bea73a77a930) — noop.
- [`bd5335a3b`](https://github.com/Fyntra-Development/UiLibrary/commit/bd5335a3bfb49450de7428487f43865116d7005c) — Delete `fonts/Rubik.ttf`.
- [`de7e70ea2`](https://github.com/Fyntra-Development/UiLibrary/commit/de7e70ea292526b83316e39b55734818e73e2980) — Tighten window glow and move fonts into repo.
- [`4fca80a7e`](https://github.com/Fyntra-Development/UiLibrary/commit/4fca80a7e85238f42c0774c1b357db564813db6b) — Remove duplicate glow frame wrapper.
- [`32fec4cec`](https://github.com/Fyntra-Development/UiLibrary/commit/32fec4cec3aaff49ccb11eb33bcc6a99bcc7ce52) — Remove duplicate HttpService declaration.
- [`7ee725131`](https://github.com/Fyntra-Development/UiLibrary/commit/7ee7251315f237a406258188d9a3025607c48a5a) — Polish cursor glow selection fades and fonts.
- [`93c792f99`](https://github.com/Fyntra-Development/UiLibrary/commit/93c792f9943c681100a2d923a749fd94ec30fd60) — Fix repo cursor and window glow implementation.
- [`0c6fe33a4`](https://github.com/Fyntra-Development/UiLibrary/commit/0c6fe33a4030241bf23b7768da9efa7c155fec64) — Add repo-hosted accent cursor and window glow.
- [`898b7f554`](https://github.com/Fyntra-Development/UiLibrary/commit/898b7f554c2dc9508d5966dd46ee3d452ab85a7f) — Add smooth slider and dropdown animations.
- [`03a232d6e`](https://github.com/Fyntra-Development/UiLibrary/commit/03a232d6ed38e3b98fe3ad78fe51081044c080fe) — Add smooth titled tooltips.
- [`e6adfc95e`](https://github.com/Fyntra-Development/UiLibrary/commit/e6adfc95e44ff21ce284efef2d35ba3ec9c8e57b) — Import Linoria UI and managers.
- [`18a9d7000`](https://github.com/Fyntra-Development/UiLibrary/commit/18a9d7000d89052cb96c6c10e261f98de78d5239) — Initial repository commit.
