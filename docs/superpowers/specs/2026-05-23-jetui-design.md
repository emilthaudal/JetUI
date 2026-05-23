# JetUI Installer — Design Spec

**Date:** 2026-05-23  
**Status:** Approved

---

## Overview

JetUI is a standalone WoW addon that installs and manages profiles for a curated set of addons (the JetUI pack). It provides a multi-step wizard UI that guides the player through importing profiles on a fresh setup, activating profiles on a new alt, and re-importing updated profiles after a pack update.

---

## Goals

- Make it trivial to get the full JetUI addon setup running on a clean WoW install.
- Make new alts automatically get the correct profiles without any manual configuration.
- Keep profiles up-to-date across JetUI version bumps with minimal user action.
- Match the NorskenUI visual aesthetic exactly (dark flat frames, neon-teal accent, Expressway font).

---

## Non-Goals

- Not a settings/config panel — the wizard is shown once per scenario, not on demand.
- Not a theme engine — hardcodes NUI v2 colors (no live sync to NorskenUI theme preference).
- No resolution variants — all profiles are 1440p only.

---

## Architecture

### File Structure

```
JetUI/
├── JetUI.toc                  -- Addon manifest, SavedVariables, X- version tags
├── JetUI.lua                  -- Core: init, state machine, flows, slash commands
├── UI/
│   └── Installer.lua          -- Wizard frame and UI logic
├── AddonData/
│   ├── Details.lua
│   ├── Plater.lua
│   ├── Grid2.lua
│   ├── UnhaltedUnitFrames.lua
│   ├── BigWigs.lua
│   ├── BuffReminders.lua
│   ├── AyijeCDM.lua
│   ├── SkironCDM.lua
│   └── MinimapStats.lua
└── AddonImports/
    ├── Details.lua
    ├── Plater.lua
    ├── Grid2.lua
    ├── UnhaltedUnitFrames.lua
    ├── BigWigs.lua
    ├── BuffReminders.lua
    ├── AyijeCDM.lua
    ├── SkironCDM.lua
    └── MinimapStats.lua
```

### SavedVariables (`JetUIDB`)

| Key                 | Type             | Purpose                              |
| ------------------- | ---------------- | ------------------------------------ |
| `InstalledVersion`  | string           | JetUI version last installed         |
| `InstalledChars`    | table (char→ver) | Characters that have had profiles set |
| `InstalledVersions` | table (name→ver) | Per-addon version last imported      |

---

## Installer Flows

Four distinct flows are selected at `PLAYER_LOGIN` based on state:

| Flow                | Trigger                                             | Action                                        |
| ------------------- | --------------------------------------------------- | --------------------------------------------- |
| **Fresh install**   | `JetUIDB == nil`                                    | Wizard: import all addon profiles              |
| **New character**   | Current char not in `InstalledChars`                | Wizard: activate (set) profiles, no re-import |
| **Update**          | Any `InstalledVersions[addon]` < TOC `X-AddonName` | Wizard: re-import only out-of-date addons     |
| **Force reinstall** | `/jetui install` slash command                      | Wizard: re-import all addons                  |

If everything is up-to-date and char is known: silent, no wizard shown.

---

## Addon List and Import Methods

| Addon                | Import Method                    | Multi-profile? | CDM-conditional?     |
| -------------------- | -------------------------------- | -------------- | -------------------- |
| Details              | `_detalhes:ImportProfile` API    | No             | No                   |
| Plater               | Direct SavedVar write            | No             | No                   |
| Grid2                | Direct SavedVar write            | No             | No                   |
| Unhalted Unit Frames | Direct SavedVar write            | No             | No                   |
| BigWigs              | `BigWigsAPI.RegisterProfile` API | No             | No                   |
| BuffReminders        | `BuffRemindersAPI:ImportProfile` | No             | No                   |
| AyijeCDM             | `Ayije_CDM_API:ImportProfile`    | Yes (DPS/heal) | Yes — AyijeCDM only  |
| SkironCDM            | SkironCDM API (TBD)              | Yes (DPS/heal) | Yes — SkironCDM only |
| MinimapStats         | Direct SavedVar write            | No             | No                   |

### Multi-profile Strategy

All profiles are imported (DPS and healer variants). The DPS profile is set as active by default. Each addon's own spec-detection logic handles switching to the healer profile at runtime when the player is in a healing spec.

For AyijeCDM/SkironCDM, spec-profile mappings are written to the addon's SavedVariables at import time, mapping each healing spec ID to the healer profile and all other specs to the DPS profile.

### CDM Conditional Logic

At the start of each flow, check:
- `IsAddOnLoaded("AyijeCDM")` → import AyijeCDM profiles, skip SkironCDM
- `IsAddOnLoaded("SkironCDM")` → import SkironCDM profiles, skip AyijeCDM
- Both loaded → show warning step, skip both (user must disable one)
- Neither loaded → skip CDM step silently

---

## Versioning

TOC `X-` metadata tags declare the profile data version bundled in this JetUI release:

```
## X-Details: 1.0
## X-Plater: 1.0
## X-Grid2: 1.0
## X-UnhaltedUnitFrames: 1.0
## X-BigWigs: 1.0
## X-BuffReminders: 1.0
## X-AyijeCDM: 1.0
## X-SkironCDM: 1.0
## X-MinimapStats: 1.0
```

`JetUIDB.InstalledVersions[addonName]` stores what version was last imported. On load, compare TOC version to stored version. If TOC is higher, queue that addon for re-import.

Version numbers are compared as `major * 1000 + minor` integers.

---

## Wizard UI

### Frame

- **Size:** 600×420px
- **Strata:** `DIALOG`
- **Backdrop:** `WHITE8X8`, solid `bgDark = {0.015, 0.047, 0.062, 0.6}`
- **Border:** 1px solid black, via raw `CreateTexture` at all 4 edges (`SetTexelSnappingBias(0)`, `SetSnapToPixelGrid(false)`)

### Header (35px)

- Background: `bgMedium = {0.015, 0.047, 0.062, 0.8}`
- Bottom 1px border line
- Left: "JetUI" title in `accent = {0, 1, 0.588, 1}`, Expressway 16px
- Right: Step counter ("Step 3 of 7") in `textSecondary = {0.70, 0.70, 0.70, 1}`, Expressway 12px

### Content Area

- Background: `bgDark`
- Two variants:
  - **Import step:** Addon name in accent (16px), status text in `textSecondary` (12px), "Import" button. Clicking imports then auto-advances after a short delay.
  - **Info step:** Centered message text (e.g., "Welcome to JetUI", "Installation complete").

### Footer (40px)

- Background: `bgMedium`
- Top 1px border line
- Right-aligned: Back button, Next/Finish button
- Buttons: `bgMedium` fill, 1px black border at rest → `accent` border on hover (0.18s animated lerp)
- Button labels in `accent` color, Expressway 12px

### Font

Expressway.TTF from NorskenUI: `Interface\AddOns\NorskenUI\Media\Fonts\Expressway.TTF`. Falls back to `Fonts\FRIZQT__.TTF` if NorskenUI is not installed.

---

## Slash Commands

| Command          | Action                                                     |
| ---------------- | ---------------------------------------------------------- |
| `/jetui`         | Print help text                                            |
| `/jetui install` | Force reinstall (confirmation dialog if already installed) |
| `/jetui load`    | Activate profiles for current character (new alt flow)     |
| `/jetui ver`     | Print installed version info for all addons                |

---

## Finish Installation

After the last wizard step:
1. Set `JetUIDB.InstalledVersion` to current JetUI version
2. Register current character (`"Name-Realm"`) in `JetUIDB.InstalledChars`
3. Update `JetUIDB.InstalledVersions` for each imported addon
4. Call `ReloadUI()`

---

## Open Questions / Future Work

- SkironCDM import API needs to be researched when profile strings are ready.
- Grid2 and Unhalted Unit Frames SavedVar structure needs to be confirmed against live addon code before writing importers.
- MinimapStats may not support profile import at all — may just need a "configure manually" info step.
