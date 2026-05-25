# JetUI

JetUI is a World of Warcraft addon that installs and manages profiles for a curated set of UI addons. It provides a guided installer UI and automatic profile activation for new characters.

## Supported Addons

- **Details!** — damage meter
- **Plater** — nameplates
- **Grid2** — raid frames
- **Unhalted Unit Frames (UUF)** — unit frames
- **BigWigs** — boss timers
- **Buff Reminders** — buff tracking
- **Blizzard CDM** — Blizzard's built-in Cooldown Manager (required; AyijeCDM and SkironCDM reskin and enhance it)
- **Ayije CDM** — recommended CDM reskin/enhancer
- **Skiron CDM** — alternative CDM reskin/enhancer (not recommended; still under development, profiles not finished)
- **MinimapStats** — minimap resource display
- **NorskenUI** — skin/theme
- **Edit Mode** — HUD layout

## First Login

On first login with a new character, JetUI opens automatically:

- **Fresh account** (no characters set up): the full installer opens, allowing you to import all profiles.
- **Existing account, new character**: the load UI opens, allowing you to activate profiles for this character without re-importing the profile data.

## Slash Commands

| Command | Description |
|---------|-------------|
| `/jetui install` | Open the full installer to (re)import all profiles |
| `/jetui load` | Open the load UI to activate profiles for this character |
| `/jetui cdm` | Import Blizzard Cooldown Manager spell layouts |
| `/jetui ver` | Show installed addon profile versions |
| `/jetui reset` | Clear all JetUI saved data and reload |

## Installation Flow

1. Install all supported addons.
2. Log in — JetUI opens the installer automatically if it's your first time.
3. Click **Import** on each addon page to import and activate its profile.
4. When done, click **Reload UI**.

## Activating Profiles on an Alt

1. Log in on the alt — JetUI opens the load UI automatically.
2. Click **Load** on each addon page to activate its profile for this character.
3. Click **Reload UI**.

Or run `/jetui load` at any time to open the load UI manually.

## CDM Conflict

If both AyijeCDM and SkironCDM are loaded at the same time, JetUI skips both and shows a warning. Disable one of them to proceed.

## Release Notes

Set `JetUI.profilePrefix = ""` in `JetUI.lua` before packaging a release. It defaults to `"TEST_"` during development to avoid overwriting live profiles.
