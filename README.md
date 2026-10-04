<p align="center">
  <img src="./assets/forma-gradient-banner.jpg" alt="Forma — flowing cobalt, cyan, and lavender gradient" width="100%" />
</p>

<h1 align="center">Forma</h1>

<p align="center">
  <strong>Interfaces in motion.</strong><br />
  A customizable Roblox UI library built to feel as good as it looks.
</p>

<p align="center">
  <img alt="Luau" src="https://img.shields.io/badge/Luau-Roblox-0969DA?style=flat-square" />
  <img alt="Fluid motion" src="https://img.shields.io/badge/Fluid-motion-7D69E8?style=flat-square" />
  <img alt="Themes" src="https://img.shields.io/badge/Personalization-built--in-C691ED?style=flat-square" />
  <a href="./LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-5D8DCB?style=flat-square" /></a>
</p>

<p align="center">
  <a href="#the-details">Explore</a> ·
  <a href="#getting-started">Get started</a> ·
  <a href="./Example.lua">Full example</a> ·
  <a href="./versions.json">Versions</a>
</p>

---

Forma combines a familiar tab-and-groupbox workflow with a focus on **smooth interactions, flexible styling, and useful controls**. Build a small configuration menu, a multi-tab dashboard, or a collection of independent utility windows without stitching together several different UI systems.

## The details

<table>
  <tr>
    <td width="50%" valign="top">
      <h3>Fluid by design</h3>
      Responsive window dragging, resizing, animated tabs, smooth fades, and frame-driven motion that can retarget without repeatedly restarting.
    </td>
    <td width="50%" valign="top">
      <h3>Magnetic layouts</h3>
      Real-time anchor snapping for the main UI, utility windows, watermark, and keybind menu. Align windows to screen anchors or to each other, with optional glowing guides.
    </td>
  </tr>
  <tr>
    <td valign="top">
      <h3>Controls that belong together</h3>
      Toggles, sliders, range sliders, dropdowns, inputs, buttons, color pickers, and keybinds with <code>Always</code>, <code>Toggle</code>, and <code>Hold</code> modes.
    </td>
    <td valign="top">
      <h3>Make it yours</h3>
      Theme colors, fonts, cursor styles, gradients, and settings for motion and direct manipulation.
    </td>
  </tr>
  <tr>
    <td valign="top">
      <h3>Beyond the main menu</h3>
      Notifications, modal dialogs, a watermark, target HUD, and independent utility windows for more specialized views.
    </td>
    <td valign="top">
      <h3>Settings that stay</h3>
      Optional theme and configuration management, plus a loader/update workflow and a component version manifest.
    </td>
  </tr>
</table>

## Getting started

The repository includes a [complete, annotated example](./Example.lua) that demonstrates creating windows, connecting controls, loading add-ons, and working with themes and saved configurations.

Here's a smaller starting point, following the same API:

```lua
-- The URL must expose the library's raw source files.
local source = "https://raw.githubusercontent.com/Fyntra-Development/Forma/main/"
local Forma = loadstring(game:HttpGet(source .. "Loader.lua"))()

local Library = Forma.Library

local Window = Library:CreateWindow({
    Title = "My Forma UI",
    Center = true,
    AutoShow = true,
})

local Main = Window:AddTab("Main")
local Controls = Main:AddLeftGroupbox("Controls")

Controls:AddToggle("Enabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})

Controls:AddSlider("Intensity", {
    Text = "Intensity",
    Min = 0,
    Max = 100,
    Default = 50,
    Rounding = 0,
})

Controls:AddDropdown("Mode", {
    Text = "Mode",
    Values = { "Smooth", "Responsive", "Custom" },
    Default = 1,
    RequireSelection = true,
})
```

> **Source access:** The example and loader currently reference the `Fyntra-Development/Forma` raw-source URL. This repository is also available under its current name, `Fyntra-Development/UiLibrary`. If you're using a private checkout or another host, make sure the loader's source URLs point to files your environment can actually fetch.

### Add-ons

```lua
local ThemeManager = Forma:LoadAddon("ThemeManager")
local SaveManager = Forma:LoadAddon("SaveManager")

-- See Example.lua for the full theme/configuration setup.
```

MenuManager provides easing controls, drag/resize response, and real-time snapping settings. It is available at [`addons/MenuManager.lua`](./addons/MenuManager.lua).

## Explore the repository

| File | What's inside |
| :-- | :-- |
| [`Library.lua`](./Library.lua) | Core controls, windows, motion, HUDs, and utilities |
| [`Loader.lua`](./Loader.lua) | Component loading and update workflow |
| [`Example.lua`](./Example.lua) | Full integration and API examples |
| [`addons/MenuManager.lua`](./addons/MenuManager.lua) | Easing, dragging, resizing, and anchor snapping |
| [`addons/ThemeManager.lua`](./addons/ThemeManager.lua) | Theme and appearance customization |
| [`addons/SaveManager.lua`](./addons/SaveManager.lua) | Configuration persistence |
| [`versions.json`](./versions.json) | Version information for each component |

## A small design principle

Good motion doesn't call attention to itself. Controls should react immediately; the visuals should catch up gracefully. Forma is built around that distinction, from softly animated tab transitions to snapping a utility window into alignment with another.

---

<p align="center">
  <strong>Forma</strong> · UI that stays out of your way.
  <br />
  <sub>See <a href="./LICENSE">LICENSE</a> for licensing and attribution.</sub>
</p>
