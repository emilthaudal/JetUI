# JetUI — Agent Notes

## What this project is

A World of Warcraft addon written in Lua. No build system, no tests, no package manager. "Deployment" means copying the repo into `Interface/AddOns/JetUI/` inside a WoW installation.

## Before releasing

**Set `JetUI.profilePrefix = ""` in `JetUI.lua:9`.** It defaults to `"TEST_"` so test imports don't overwrite live profiles. Forgetting this is the most common release mistake.

## File load order

Controlled by `JetUI.toc`. Any new `.lua` file must be added there or WoW will not load it. Order matters — `JetUI.lua` must come before `UI/Installer.lua` and both must come before `AddonData/` and `AddonImports/` files.

## Architecture

```
JetUI.lua              — entry point, PLAYER_LOGIN event, slash commands, install flow
UI/Installer.lua       — installer UI (NUI v2 color palette, hardcoded)
AddonData/<Tag>.lua    — large encoded profile string blob (e.g. JetUI.DetailsProfileString)
AddonImports/<Tag>.lua — JetUI:Import<Tag>(forceImport) calls the addon's own API
```

## Adding support for a new addon

Four files must be touched:

1. **`JetUI.toc`** — add `AddonData\<Tag>.lua` and `AddonImports\<Tag>.lua`
2. **`JetUI.lua`** — add `"<Tag>"` to the `addonTags` table in **three places**: `Initialize()`, `ForceReinstall()`, and `SetProfiles()`
3. **`AddonData/<Tag>.lua`** — set `JetUI.<Tag>ProfileString = "..."`
4. **`AddonImports/<Tag>.lua`** — implement `JetUI:Import<Tag>(forceImport)`

## CDM addon mutual exclusivity

AyijeCDM and SkironCDM are mutually exclusive. `JetUI.cdmAddon` is set to whichever is loaded; if both are loaded `JetUI.cdmConflict = true` and both are skipped. Any code touching CDM must respect this — see `JetUI.lua:39-48` and `BuildInstallPages` in `JetUI.lua:128-145`.

## Version tracking

Each addon's version is stored in `JetUIDB.InstalledVersions[tag]` and compared against the `X-<Tag>` field in `JetUI.toc`. Bump the TOC metadata field to trigger an update prompt on next login.

## Slash commands (in-game)

```
/jetui install   force reinstall all profiles
/jetui load      set profiles for current character (no UI)
/jetui ver       show installed versions
/jetui reset     wipe JetUIDB and reload
```

## WoW Lua environment

Uses standard WoW globals: `C_AddOns`, `CreateFrame`, `BackdropTemplate`, `UnitName`, `GetRealmName`, `ReloadUI`, `strsplit`, `strtrim`, `strlower`. No LuaRocks, no external libraries. The font path falls back to `Fonts\\FRIZQT__.TTF` if NorskenUI is not loaded.

## Profile string placeholders

`AddonData/<Tag>.lua` files ship with real encoded strings. If a profile string is missing or still set to `"PASTE_<TAG>_PROFILE_STRING_HERE"`, the import is silently skipped with a print warning.

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:7510c1e2 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md for details and anti-patterns.

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->
