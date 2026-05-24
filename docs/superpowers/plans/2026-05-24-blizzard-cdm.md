# Blizzard CDM Spell Profiles Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Blizzard Cooldown Manager spell profiles to the JetUI installer, with per-spec import buttons, an Import All button, and a `/jetui cdm` standalone command.

**Architecture:** New `AddonData/BlizzardCDM.lua` stores flat per-spec profile strings keyed by `classAndSpecTag` integer. New `AddonImports/BlizzardCDM.lua` provides `JetUI:ImportBlizzardCDM(specTag)` and `JetUI:ImportAllBlizzardCDM()`. `UI/Installer.lua` gains multi-button support via a `page.buttons` array rendered in `ShowStep`. `JetUI.lua` gains the `/jetui cdm` slash command, adds `"BlizzardCDM"` to `addonTags`, and builds a 2-page CDM sub-flow with dynamic spec buttons.

**Tech Stack:** Lua, WoW addon API (`CooldownViewerSettings`, `CooldownViewerUtil`, `GetSpecializationInfo`)

---

### Task 1: Add multi-button support to `UI/Installer.lua`

**Files:**
- Modify: `UI/Installer.lua:316-399` (ShowStep function)

The `page.buttons` array holds `{label, fn}` entries. When present, the single `importBtn` is hidden and instead a column of dynamically created buttons is shown. Buttons are stored in `Installer.dynamicBtns` and recycled on each `ShowStep` call.

- [ ] **Step 1: Add `Installer.dynamicBtns = {}` to the `BuildFrame` function after `Installer.sidebarBtns = {}`**

In `UI/Installer.lua`, find the line:
```lua
    Installer.sidebarBtns   = {}
```
Add after it:
```lua
    Installer.dynamicBtns   = {}
```

- [ ] **Step 2: Add a helper `ClearDynamicBtns()` before `ShowStep`**

Insert this function immediately before `function Installer:ShowStep(index)` (line 316):

```lua
local function ClearDynamicBtns()
    for _, b in ipairs(Installer.dynamicBtns) do b:Hide() end
    Installer.dynamicBtns = {}
end
```

- [ ] **Step 3: Add `page.buttons` rendering inside `ShowStep`**

In `ShowStep`, find the `else` branch that hides `importBtn` (currently the final `else` in the import button block, ending around line 382):

```lua
    else
        importBtn:Hide()
    end
```

Replace it with:

```lua
    elseif page.buttons then
        importBtn:Hide()
        ClearDynamicBtns()
        local BTN_W, BTN_H, GAP = 160, 26, 6
        -- Spec buttons stacked, centered vertically, Import All pinned below
        local specBtns = {}
        for _, bDef in ipairs(page.buttons) do
            if not bDef.isImportAll then
                table.insert(specBtns, bDef)
            end
        end
        local totalH = #specBtns * (BTN_H + GAP) - GAP
        local startY = math.floor(totalH / 2) + 10
        for i, bDef in ipairs(specBtns) do
            local b = MakeButton(bDef.label, Installer.frame.main or main, BTN_W, BTN_H)
            -- main pane reference: anchor to importBtn's parent (main content pane)
            b:SetParent(importBtn:GetParent())
            b:ClearAllPoints()
            local yOff = startY - (i - 1) * (BTN_H + GAP)
            b:SetPoint("CENTER", importBtn:GetParent(), "CENTER", 0, yOff)
            local fn = bDef.fn
            b:SetScript("OnClick", function()
                fn()
                b:Disable()
            end)
            table.insert(Installer.dynamicBtns, b)
            b:Show()
        end
        -- Import All button at bottom
        for _, bDef in ipairs(page.buttons) do
            if bDef.isImportAll then
                local b = MakeButton(bDef.label, importBtn:GetParent(), BTN_W, BTN_H)
                b:ClearAllPoints()
                b:SetPoint("CENTER", importBtn:GetParent(), "CENTER", 0, -startY - BTN_H - GAP)
                local fn = bDef.fn
                b:SetScript("OnClick", function()
                    fn()
                    for _, db in ipairs(Installer.dynamicBtns) do db:Disable() end
                    b:Disable()
                end)
                table.insert(Installer.dynamicBtns, b)
                b:Show()
            end
        end
    else
        importBtn:Hide()
        ClearDynamicBtns()
    end
```

Also add `ClearDynamicBtns()` at the top of the import-button block (right after the `local importBtn = Installer.importBtn` line) so switching away from a buttons-page clears them:

Find:
```lua
    -- Import button
    local importBtn = Installer.importBtn
    if page.isDone then
```

Replace with:
```lua
    -- Import button
    local importBtn = Installer.importBtn
    ClearDynamicBtns()
    if page.isDone then
```

- [ ] **Step 4: Verify the file looks correct**

Open `UI/Installer.lua` and confirm `ShowStep` now has three branches: `isDone`, `page.import`, `page.buttons`, and the final `else`. Confirm `ClearDynamicBtns()` is called at the top of the import block and in the `else` branch.

---

### Task 2: Create `AddonData/BlizzardCDM.lua`

**Files:**
- Create: `AddonData/BlizzardCDM.lua`

This file defines a flat table keyed by `classAndSpecTag` integer. Each entry has `profileKey` (the name to use in Blizzard CDM) and `profileString` (the encoded string — placeholders for now).

Spec tag reference (from Blizzard's CDM, matching atrocityUI values):
- Death Knight: Unholy=251, Frost=252, Blood=250
- Demon Hunter: Havoc=577, Vengeance=581
- Druid: Balance=102, Feral=103, Guardian=104, Restoration=105
- Evoker: Devastation=1467, Preservation=1468, Augmentation=1473
- Hunter: Beast Mastery=253, Marksmanship=254, Survival=255
- Mage: Arcane=62, Fire=63, Frost=64
- Monk: Brewmaster=268, Windwalker=269, Mistweaver=270
- Paladin: Holy=65, Protection=66, Retribution=70
- Priest: Discipline=256, Holy=257, Shadow=258
- Rogue: Assassination=259, Outlaw=260, Subtlety=261
- Shaman: Elemental=262, Enhancement=263, Restoration=264
- Warlock: Affliction=265, Demonology=266, Destruction=267
- Warrior: Arms=71, Fury=72, Protection=73

- [ ] **Step 1: Create the file**

```lua
-- AddonData/BlizzardCDM.lua
-- Per-spec profile strings for Blizzard Cooldown Manager.
-- Keys are classAndSpecTag integers from CooldownViewerUtil.GetCurrentClassAndSpecTag().
-- Replace PASTE_..._PROFILE_STRING_HERE with the real encoded string.

JetUI.BlizzardCDMProfiles = {
    -- Death Knight
    [250] = { profileKey = "JetUI - Blood DK",       profileString = "PASTE_BLOOD_DK_PROFILE_STRING_HERE" },
    [251] = { profileKey = "JetUI - Unholy DK",      profileString = "PASTE_UNHOLY_DK_PROFILE_STRING_HERE" },
    [252] = { profileKey = "JetUI - Frost DK",       profileString = "PASTE_FROST_DK_PROFILE_STRING_HERE" },
    -- Demon Hunter
    [577] = { profileKey = "JetUI - Havoc DH",       profileString = "PASTE_HAVOC_DH_PROFILE_STRING_HERE" },
    [581] = { profileKey = "JetUI - Vengeance DH",   profileString = "PASTE_VENGEANCE_DH_PROFILE_STRING_HERE" },
    -- Druid
    [102] = { profileKey = "JetUI - Balance Druid",  profileString = "PASTE_BALANCE_DRUID_PROFILE_STRING_HERE" },
    [103] = { profileKey = "JetUI - Feral Druid",    profileString = "PASTE_FERAL_DRUID_PROFILE_STRING_HERE" },
    [104] = { profileKey = "JetUI - Guardian Druid", profileString = "PASTE_GUARDIAN_DRUID_PROFILE_STRING_HERE" },
    [105] = { profileKey = "JetUI - Resto Druid",    profileString = "PASTE_RESTO_DRUID_PROFILE_STRING_HERE" },
    -- Evoker
    [1467] = { profileKey = "JetUI - Devastation Evoker",   profileString = "PASTE_DEVASTATION_EVOKER_PROFILE_STRING_HERE" },
    [1468] = { profileKey = "JetUI - Preservation Evoker",  profileString = "PASTE_PRESERVATION_EVOKER_PROFILE_STRING_HERE" },
    [1473] = { profileKey = "JetUI - Augmentation Evoker",  profileString = "PASTE_AUGMENTATION_EVOKER_PROFILE_STRING_HERE" },
    -- Hunter
    [253] = { profileKey = "JetUI - BM Hunter",      profileString = "PASTE_BM_HUNTER_PROFILE_STRING_HERE" },
    [254] = { profileKey = "JetUI - MM Hunter",      profileString = "PASTE_MM_HUNTER_PROFILE_STRING_HERE" },
    [255] = { profileKey = "JetUI - SV Hunter",      profileString = "PASTE_SV_HUNTER_PROFILE_STRING_HERE" },
    -- Mage
    [62]  = { profileKey = "JetUI - Arcane Mage",    profileString = "PASTE_ARCANE_MAGE_PROFILE_STRING_HERE" },
    [63]  = { profileKey = "JetUI - Fire Mage",      profileString = "PASTE_FIRE_MAGE_PROFILE_STRING_HERE" },
    [64]  = { profileKey = "JetUI - Frost Mage",     profileString = "PASTE_FROST_MAGE_PROFILE_STRING_HERE" },
    -- Monk
    [268] = { profileKey = "JetUI - Brewmaster Monk",  profileString = "PASTE_BREWMASTER_MONK_PROFILE_STRING_HERE" },
    [269] = { profileKey = "JetUI - Windwalker Monk",  profileString = "PASTE_WINDWALKER_MONK_PROFILE_STRING_HERE" },
    [270] = { profileKey = "JetUI - Mistweaver Monk",  profileString = "PASTE_MISTWEAVER_MONK_PROFILE_STRING_HERE" },
    -- Paladin
    [65]  = { profileKey = "JetUI - Holy Paladin",   profileString = "PASTE_HOLY_PALADIN_PROFILE_STRING_HERE" },
    [66]  = { profileKey = "JetUI - Prot Paladin",   profileString = "PASTE_PROT_PALADIN_PROFILE_STRING_HERE" },
    [70]  = { profileKey = "JetUI - Ret Paladin",    profileString = "PASTE_RET_PALADIN_PROFILE_STRING_HERE" },
    -- Priest
    [256] = { profileKey = "JetUI - Disc Priest",    profileString = "PASTE_DISC_PRIEST_PROFILE_STRING_HERE" },
    [257] = { profileKey = "JetUI - Holy Priest",    profileString = "PASTE_HOLY_PRIEST_PROFILE_STRING_HERE" },
    [258] = { profileKey = "JetUI - Shadow Priest",  profileString = "PASTE_SHADOW_PRIEST_PROFILE_STRING_HERE" },
    -- Rogue
    [259] = { profileKey = "JetUI - Assassination Rogue", profileString = "PASTE_ASSASSINATION_ROGUE_PROFILE_STRING_HERE" },
    [260] = { profileKey = "JetUI - Outlaw Rogue",        profileString = "PASTE_OUTLAW_ROGUE_PROFILE_STRING_HERE" },
    [261] = { profileKey = "JetUI - Subtlety Rogue",      profileString = "PASTE_SUBTLETY_ROGUE_PROFILE_STRING_HERE" },
    -- Shaman
    [262] = { profileKey = "JetUI - Elemental Shaman",    profileString = "PASTE_ELEMENTAL_SHAMAN_PROFILE_STRING_HERE" },
    [263] = { profileKey = "JetUI - Enhancement Shaman",  profileString = "PASTE_ENHANCEMENT_SHAMAN_PROFILE_STRING_HERE" },
    [264] = { profileKey = "JetUI - Resto Shaman",        profileString = "PASTE_RESTO_SHAMAN_PROFILE_STRING_HERE" },
    -- Warlock
    [265] = { profileKey = "JetUI - Affliction Warlock",  profileString = "PASTE_AFFLICTION_WARLOCK_PROFILE_STRING_HERE" },
    [266] = { profileKey = "JetUI - Demonology Warlock",  profileString = "PASTE_DEMONOLOGY_WARLOCK_PROFILE_STRING_HERE" },
    [267] = { profileKey = "JetUI - Destruction Warlock", profileString = "PASTE_DESTRUCTION_WARLOCK_PROFILE_STRING_HERE" },
    -- Warrior
    [71]  = { profileKey = "JetUI - Arms Warrior",   profileString = "PASTE_ARMS_WARRIOR_PROFILE_STRING_HERE" },
    [72]  = { profileKey = "JetUI - Fury Warrior",   profileString = "PASTE_FURY_WARRIOR_PROFILE_STRING_HERE" },
    [73]  = { profileKey = "JetUI - Prot Warrior",   profileString = "PASTE_PROT_WARRIOR_PROFILE_STRING_HERE" },
}
```

---

### Task 3: Create `AddonImports/BlizzardCDM.lua`

**Files:**
- Create: `AddonImports/BlizzardCDM.lua`

This file implements the import logic. Key Blizzard CDM API:
- `CooldownViewerSettings:GetLayoutManager()` → `lm`
- `lm:CreateLayoutsFromSerializedData(profileString)` → table of layout IDs
- `lm:SetActiveLayoutByID(layoutID)` — activates the first layout ID returned
- `CooldownViewerUtil.GetCurrentClassAndSpecTag()` → current spec's integer tag

`JetUI:ImportBlizzardCDMSpec(specTag)` imports and activates one spec. Returns `true` on success, `false` with a print on failure (missing profile string, addon not loaded, layout cap hit).

`JetUI:ImportAllBlizzardCDM()` calls `ImportBlizzardCDMSpec` for every tag in the current player's class. Class detection: collect all `GetSpecializationInfo(i)` spec IDs, map them to `classAndSpecTag` tags (the specID is the tag). Import all matching entries in `JetUI.BlizzardCDMProfiles`, activate the one matching the currently active spec.

- [ ] **Step 1: Create the file**

```lua
-- AddonImports/BlizzardCDM.lua

-- Returns the classAndSpecTag for the player's currently active spec.
local function GetCurrentSpecTag()
    if CooldownViewerUtil and CooldownViewerUtil.GetCurrentClassAndSpecTag then
        return CooldownViewerUtil.GetCurrentClassAndSpecTag()
    end
    -- Fallback: spec ID == tag for most classes
    local _, _, _, specID = GetSpecializationInfo(GetSpecialization() or 1)
    return specID
end

-- Returns a list of classAndSpecTag integers for every spec of the player's class.
local function GetClassSpecTags()
    local tags = {}
    local numSpecs = GetNumSpecializations()
    for i = 1, numSpecs do
        local _, _, _, specID = GetSpecializationInfo(i)
        if specID then
            table.insert(tags, specID)
        end
    end
    return tags
end

-- Import and activate a single spec's profile. specTag is a classAndSpecTag integer.
function JetUI:ImportBlizzardCDMSpec(specTag, activate)
    if not CooldownViewerSettings then
        print("|cff00ff96JetUI|r BlizzardCDM: addon not loaded.")
        return false
    end
    local entry = (JetUI.BlizzardCDMProfiles or {})[specTag]
    if not entry then
        print("|cff00ff96JetUI|r BlizzardCDM: no profile for specTag " .. tostring(specTag))
        return false
    end
    if entry.profileString:find("^PASTE_") then
        print("|cff00ff96JetUI|r BlizzardCDM: profile string not set for " .. entry.profileKey)
        return false
    end
    local prefix = JetUI.profilePrefix or ""
    local profileKey = prefix .. entry.profileKey
    local lm = CooldownViewerSettings:GetLayoutManager()
    if lm:AreLayoutsFullyMaxed() then
        print("|cff00ff96JetUI|r BlizzardCDM: layout slots full, cannot import " .. profileKey)
        return false
    end
    local layoutIDs = lm:CreateLayoutsFromSerializedData(entry.profileString)
    if layoutIDs and #layoutIDs > 0 then
        -- Rename the layout to our profileKey
        if lm.RenameLayout then lm:RenameLayout(layoutIDs[1], profileKey) end
        if activate then
            lm:SetActiveLayoutByID(layoutIDs[1])
        end
        return true
    end
    print("|cff00ff96JetUI|r BlizzardCDM: import failed for " .. profileKey)
    return false
end

-- Import all specs for the player's current class and activate the current spec's profile.
function JetUI:ImportAllBlizzardCDM()
    if not CooldownViewerSettings then
        print("|cff00ff96JetUI|r BlizzardCDM: addon not loaded.")
        return
    end
    local currentTag = GetCurrentSpecTag()
    local classTags  = GetClassSpecTags()
    for _, tag in ipairs(classTags) do
        local isActive = (tag == currentTag)
        JetUI:ImportBlizzardCDMSpec(tag, isActive)
    end
    JetUIDB.InstalledVersions = JetUIDB.InstalledVersions or {}
    JetUIDB.InstalledVersions["BlizzardCDM"] = C_AddOns.GetAddOnMetadata("JetUI", "X-BlizzardCDM")
end
```

---

### Task 4: Register `BlizzardCDM` in `JetUI.toc`

**Files:**
- Modify: `JetUI.toc`

- [ ] **Step 1: Add the metadata field after existing CDM entries**

Find:
```
## X-SkironCDM: 1.0
```
Add after:
```
## X-BlizzardCDM: 1.0
```

- [ ] **Step 2: Add the data file after `AddonData\SkironCDM.lua`**

Find:
```
AddonData\SkironCDM.lua
```
Add after:
```
AddonData\BlizzardCDM.lua
```

- [ ] **Step 3: Add the import file after `AddonImports\SkironCDM.lua`**

Find:
```
AddonImports\SkironCDM.lua
```
Add after:
```
AddonImports\BlizzardCDM.lua
```

---

### Task 5: Add BlizzardCDM to `JetUI.lua` — installer integration and slash command

**Files:**
- Modify: `JetUI.lua`

BlizzardCDM is a standalone Blizzard feature (not a separate addon), so there's no `IsAddOnLoaded` guard — it's always present when the game is running The War Within. It's added to `addonTags` and gets its own 2-page sub-flow in `BuildInstallPages`. A `/jetui cdm` slash command opens just those 2 pages.

- [ ] **Step 1: Add `"BlizzardCDM"` to `ForceReinstall` addonTags**

Find:
```lua
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "MinimapStats", "NorskenUI" }
```
Replace with:
```lua
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "BlizzardCDM", "MinimapStats", "NorskenUI" }
```

- [ ] **Step 2: Add `"BlizzardCDM"` to `SetProfiles` addonTags**

Find:
```lua
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "MinimapStats", "NorskenUI" }
```
(in `SetProfiles`) — note this is the same literal string, second occurrence in the file. Replace with:
```lua
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "BlizzardCDM", "MinimapStats", "NorskenUI" }
```

- [ ] **Step 3: Add the BlizzardCDM page builder inside `BuildInstallPages`**

`BuildInstallPages` builds pages from `addonTags`. Add a special case for `"BlizzardCDM"` inside the tag loop. Find the `else` branch that handles regular addons (around line 126):

```lua
        else
            table.insert(pages, {
                title        = tag,
                sidebarLabel = tag,
```

Insert a new `elseif` block before this `else`:

```lua
        elseif tag == "BlizzardCDM" then
            -- Build spec buttons for the player's current class
            local specButtons = {}
            local numSpecs = GetNumSpecializations()
            for i = 1, numSpecs do
                local _, specName, _, specID = GetSpecializationInfo(i)
                if specID then
                    local capturedID = specID
                    table.insert(specButtons, {
                        label = specName or ("Spec " .. i),
                        fn    = function()
                            JetUI:ImportBlizzardCDMSpec(capturedID, true)
                        end,
                    })
                end
            end
            table.insert(specButtons, {
                label       = "Import All",
                isImportAll = true,
                fn          = function() JetUI:ImportAllBlizzardCDM() end,
            })
            table.insert(pages, {
                title        = "Blizzard CDM",
                sidebarLabel = "Blizzard CDM",
                status       = "Import your spec's cooldown layout.\nBlizzard CDM only allows importing your current class.",
                buttons      = specButtons,
            })
```

- [ ] **Step 4: Add the `/jetui cdm` command**

`BuildCDMPages()` is a local helper that returns just the 2-page CDM flow (CDM page + done page).

Find the slash command handler block and add a new `elseif` before the final `else`:

```lua
    elseif cmd == "cdm" then
        local pages = {}
        local specButtons = {}
        local numSpecs = GetNumSpecializations()
        for i = 1, numSpecs do
            local _, specName, _, specID = GetSpecializationInfo(i)
            if specID then
                local capturedID = specID
                table.insert(specButtons, {
                    label = specName or ("Spec " .. i),
                    fn    = function()
                        JetUI:ImportBlizzardCDMSpec(capturedID, true)
                    end,
                })
            end
        end
        table.insert(specButtons, {
            label       = "Import All",
            isImportAll = true,
            fn          = function() JetUI:ImportAllBlizzardCDM() end,
        })
        table.insert(pages, {
            title   = "Blizzard CDM",
            status  = "Import your spec's cooldown layout.\nBlizzard CDM only allows importing your current class.",
            buttons = specButtons,
        })
        table.insert(pages, {
            title  = "Done!",
            status = "CDM profile imported.\nClick Reload UI to apply.",
            isDone = true,
        })
        JetUI.Installer:Open(pages)
```

Also update the help text in the final `else` to mention `/jetui cdm`:

Find:
```lua
        print("  /jetui reset    - Clear SavedVariables and reload")
```
Add after:
```lua
        print("  /jetui cdm      - Open Blizzard CDM spec importer")
```

- [ ] **Step 5: Verify `JetUI.lua` has `"BlizzardCDM"` in both `addonTags` lists and the new slash command**

Search for `BlizzardCDM` in `JetUI.lua` — it should appear in `ForceReinstall`, `SetProfiles`, `BuildInstallPages` (elseif branch), and the slash command handler.

---

### Task 6: Smoke-test checklist (no automated tests — WoW Lua)

Since this is a WoW addon, verification is done manually in-game or by reading the code carefully.

- [ ] **Review `UI/Installer.lua`**: `ShowStep` has `isDone`, `page.import`, `page.buttons`, `else` branches. `ClearDynamicBtns()` called at top of import block and in `else`.
- [ ] **Review `AddonData/BlizzardCDM.lua`**: all spec tags present, all `profileString` values are placeholder strings starting with `PASTE_`.
- [ ] **Review `AddonImports/BlizzardCDM.lua`**: `ImportBlizzardCDMSpec` guards for addon not loaded, missing entry, placeholder string, layout cap. `ImportAllBlizzardCDM` iterates `GetClassSpecTags()` and calls `ImportBlizzardCDMSpec`.
- [ ] **Review `JetUI.toc`**: `X-BlizzardCDM`, `AddonData\BlizzardCDM.lua`, `AddonImports\BlizzardCDM.lua` present in correct load order.
- [ ] **Review `JetUI.lua`**: `"BlizzardCDM"` in both `addonTags` arrays, `elseif tag == "BlizzardCDM"` block in `BuildInstallPages`, `/jetui cdm` slash command present.

---

### Task 7: Commit

- [ ] **Step 1: Stage and commit all changes**

```bash
git add AddonData/BlizzardCDM.lua AddonImports/BlizzardCDM.lua UI/Installer.lua JetUI.lua JetUI.toc
git commit -m "feat: add Blizzard CDM per-spec profile importer

- UI/Installer.lua: multi-button page support (page.buttons array)
- AddonData/BlizzardCDM.lua: per-spec profile string placeholders
- AddonImports/BlizzardCDM.lua: ImportBlizzardCDMSpec / ImportAllBlizzardCDM
- JetUI.toc: register BlizzardCDM files and X-BlizzardCDM metadata
- JetUI.lua: BlizzardCDM in addonTags, BuildInstallPages branch, /jetui cdm command"
```
