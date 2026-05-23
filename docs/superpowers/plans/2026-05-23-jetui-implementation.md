# JetUI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build JetUI, a standalone WoW addon that installs and manages profiles for the JetUI addon pack via a NorskenUI-styled wizard UI.

**Architecture:** Standalone addon with no required dependencies. Core state machine in `JetUI.lua` selects one of four installer flows at login. Wizard UI in `UI/Installer.lua` renders NorskenUI-styled frames. Profile data in `AddonData/` and import logic in `AddonImports/` are separated per-addon.

**Tech Stack:** Lua 5.1 (WoW addon environment), raw WoW Frame API (CreateFrame, BackdropTemplate), WoW SavedVariables system.

---

## File Map

| File | Responsibility |
|---|---|
| `JetUI.toc` | Addon manifest, SavedVariables, X- version tags, file load order |
| `JetUI.lua` | Init, state machine, flow selection, page table construction, slash commands, FinishInstallation |
| `UI/Installer.lua` | Wizard frame: header, content area, footer, nav buttons, step rendering, hover animations |
| `AddonData/Details.lua` | Details profile strings |
| `AddonData/Plater.lua` | Plater profile strings |
| `AddonData/Grid2.lua` | Grid2 profile strings |
| `AddonData/UnhaltedUnitFrames.lua` | Unhalted Unit Frames profile strings |
| `AddonData/BigWigs.lua` | BigWigs profile string |
| `AddonData/BuffReminders.lua` | BuffReminders profile string |
| `AddonData/AyijeCDM.lua` | AyijeCDM profile strings (DPS + healer variants) |
| `AddonData/SkironCDM.lua` | SkironCDM profile strings (DPS + healer variants) |
| `AddonData/MinimapStats.lua` | MinimapStats profile strings (or placeholder if unsupported) |
| `AddonImports/Details.lua` | `JetUI_ImportDetails(forceImport)` function |
| `AddonImports/Plater.lua` | `JetUI_ImportPlater(forceImport)` function |
| `AddonImports/Grid2.lua` | `JetUI_ImportGrid2(forceImport)` function |
| `AddonImports/UnhaltedUnitFrames.lua` | `JetUI_ImportUnhaltedUnitFrames(forceImport)` function |
| `AddonImports/BigWigs.lua` | `JetUI_ImportBigWigs(forceImport)` function |
| `AddonImports/BuffReminders.lua` | `JetUI_ImportBuffReminders(forceImport)` function |
| `AddonImports/AyijeCDM.lua` | `JetUI_ImportAyijeCDM(forceImport)` function |
| `AddonImports/SkironCDM.lua` | `JetUI_ImportSkironCDM(forceImport)` function |
| `AddonImports/MinimapStats.lua` | `JetUI_ImportMinimapStats(forceImport)` function |

---

## Task 1: TOC and skeleton

**Files:**
- Create: `JetUI.toc`
- Create: `JetUI.lua`

- [ ] **Step 1: Create JetUI.toc**

```
## Interface: 120001, 120005, 120000
## Author: JetUI
## Version: 1.0
## Title: |cff00ff96JetUI|r
## Notes: JetUI Installer
## DefaultState: enabled
## SavedVariables: JetUIDB

## X-Details: 1.0
## X-Plater: 1.0
## X-Grid2: 1.0
## X-UnhaltedUnitFrames: 1.0
## X-BigWigs: 1.0
## X-BuffReminders: 1.0
## X-AyijeCDM: 1.0
## X-SkironCDM: 1.0
## X-MinimapStats: 1.0

JetUI.lua
UI\Installer.lua
AddonData\Details.lua
AddonData\Plater.lua
AddonData\Grid2.lua
AddonData\UnhaltedUnitFrames.lua
AddonData\BigWigs.lua
AddonData\BuffReminders.lua
AddonData\AyijeCDM.lua
AddonData\SkironCDM.lua
AddonData\MinimapStats.lua
AddonImports\Details.lua
AddonImports\Plater.lua
AddonImports\Grid2.lua
AddonImports\UnhaltedUnitFrames.lua
AddonImports\BigWigs.lua
AddonImports\BuffReminders.lua
AddonImports\AyijeCDM.lua
AddonImports\SkironCDM.lua
AddonImports\MinimapStats.lua
```

- [ ] **Step 2: Create JetUI.lua skeleton**

```lua
JetUI = {}
JetUIDB = JetUIDB or {}

local ADDON_NAME = "JetUI"
local ADDON_VERSION = "1.0"

-- Version helpers
local function GetNiceVersionNumber(versionString)
    local major, minor = strsplit(".", versionString or "0.0")
    return (tonumber(major) or 0) * 1000 + (tonumber(minor) or 0)
end

local function GetTOCVersion(addonTag)
    local v = GetAddOnMetadata(ADDON_NAME, "X-" .. addonTag)
    return GetNiceVersionNumber(v)
end

local function GetInstalledVersion(addonTag)
    return GetNiceVersionNumber(JetUIDB.InstalledVersions and JetUIDB.InstalledVersions[addonTag])
end

-- Character key
local function GetCharKey()
    return UnitName("player") .. "-" .. GetRealmName()
end

-- Flow selection
local function Initialize()
    JetUIDB.InstalledVersions = JetUIDB.InstalledVersions or {}
    JetUIDB.InstalledChars    = JetUIDB.InstalledChars    or {}

    -- TODO: wire up flows and open installer
    print("|cff00ff96JetUI|r loaded. Type /jetui for help.")
end

-- Event registration
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then Initialize() end
end)

-- Slash commands
SLASH_JETUI1 = "/jetui"
SlashCmdList["JETUI"] = function(msg)
    local cmd = strtrim(strlower(msg or ""))
    if cmd == "install" then
        -- TODO: ForceReinstall flow
        print("|cff00ff96JetUI|r Force reinstall triggered.")
    elseif cmd == "load" then
        -- TODO: SetProfiles flow
        print("|cff00ff96JetUI|r Profile load triggered.")
    elseif cmd == "ver" then
        print("|cff00ff96JetUI|r version " .. ADDON_VERSION)
        for k, v in pairs(JetUIDB.InstalledVersions or {}) do
            print("  " .. k .. ": " .. tostring(v))
        end
    else
        print("|cff00ff96JetUI|r commands:")
        print("  /jetui install  - Force reinstall all profiles")
        print("  /jetui load     - Load profiles for this character")
        print("  /jetui ver      - Show installed versions")
    end
end
```

- [ ] **Step 3: Verify addon loads in WoW**

Enable JetUI in the addon list. Log in. Expected: "JetUI loaded. Type /jetui for help." in chat. Type `/jetui ver` — should print version with empty version list.

- [ ] **Step 4: Commit**

```bash
git add JetUI.toc JetUI.lua
git commit -m "feat: addon skeleton with TOC, init, slash commands"
```

---

## Task 2: Wizard frame

**Files:**
- Create: `UI/Installer.lua`

- [ ] **Step 1: Create UI/Installer.lua with the wizard frame**

```lua
-- NUI v2 color palette (hardcoded — JetUI targets this specific setup)
local C = {
    bgDark      = { 0.015, 0.047, 0.062, 0.6 },
    bgMedium    = { 0.015, 0.047, 0.062, 0.8 },
    border      = { 0, 0, 0, 1 },
    accent      = { 0, 1, 0.588, 1 },
    textPrimary = { 0.95, 0.95, 0.95, 1 },
    textSecondary = { 0.70, 0.70, 0.70, 1 },
}

-- Font path: use Expressway from NorskenUI if available, else Blizzard default
local FONT = (IsAddOnLoaded and IsAddOnLoaded("NorskenUI"))
    and "Interface\\AddOns\\NorskenUI\\Media\\Fonts\\Expressway.TTF"
    or  "Fonts\\FRIZQT__.TTF"

-- Helper: add 4 pixel-perfect 1px border textures to a frame
local function AddBorders(f, r, g, b, a)
    r, g, b, a = r or 0, g or 0, b or 0, a or 1
    local function mkLine(subLayer)
        local t = f:CreateTexture(nil, "OVERLAY", nil, subLayer)
        t:SetColorTexture(r, g, b, a)
        t:SetTexelSnappingBias(0)
        t:SetSnapToPixelGrid(false)
        return t
    end
    local top    = mkLine(7) top:SetHeight(1)    top:SetPoint("TOPLEFT",f,"TOPLEFT",0,0)         top:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)
    local bot    = mkLine(7) bot:SetHeight(1)    bot:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)   bot:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,0)
    local left   = mkLine(7) left:SetWidth(1)    left:SetPoint("TOPLEFT",f,"TOPLEFT",0,0)        left:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)
    local right  = mkLine(7) right:SetWidth(1)   right:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)     right:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,0)
end

-- Helper: create a backdrop frame with solid bg + border
local function MakeBackdropFrame(name, parent, w, h, bgColor)
    local f = CreateFrame("Frame", name, parent, "BackdropTemplate")
    f:SetSize(w, h)
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    f:SetBackdropBorderColor(0, 0, 0, 1)
    return f
end

-- Installer state
JetUI.Installer = {}
local Installer = JetUI.Installer

local W, H         = 600, 420
local HEADER_H     = 35
local FOOTER_H     = 40
local CONTENT_H    = H - HEADER_H - FOOTER_H

-- Build the frame (hidden until shown)
local function BuildFrame()
    local f = MakeBackdropFrame("JetUIInstallerFrame", UIParent, W, H, C.bgDark)
    f:SetFrameStrata("DIALOG")
    f:SetPoint("CENTER")
    f:Hide()
    AddBorders(f, 0, 0, 0, 1)

    -- Header
    local header = MakeBackdropFrame(nil, f, W, HEADER_H, C.bgMedium)
    header:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    -- header bottom border
    local hBorder = header:CreateTexture(nil, "OVERLAY")
    hBorder:SetHeight(1) hBorder:SetColorTexture(0,0,0,1)
    hBorder:SetPoint("BOTTOMLEFT",header,"BOTTOMLEFT",0,0)
    hBorder:SetPoint("BOTTOMRIGHT",header,"BOTTOMRIGHT",0,0)

    local titleText = header:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(FONT, 16, "OUTLINE")
    titleText:SetTextColor(C.accent[1], C.accent[2], C.accent[3], C.accent[4])
    titleText:SetPoint("LEFT", header, "LEFT", 12, 0)
    titleText:SetText("JetUI")

    local stepText = header:CreateFontString(nil, "OVERLAY")
    stepText:SetFont(FONT, 12, "OUTLINE")
    stepText:SetTextColor(C.textSecondary[1], C.textSecondary[2], C.textSecondary[3], C.textSecondary[4])
    stepText:SetPoint("RIGHT", header, "RIGHT", -12, 0)
    Installer.stepText = stepText

    -- Content area
    local content = MakeBackdropFrame(nil, f, W, CONTENT_H, C.bgDark)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    content:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, 0)
    Installer.content = content

    -- Addon name label (import steps)
    local addonLabel = content:CreateFontString(nil, "OVERLAY")
    addonLabel:SetFont(FONT, 16, "OUTLINE")
    addonLabel:SetTextColor(C.accent[1], C.accent[2], C.accent[3], C.accent[4])
    addonLabel:SetPoint("CENTER", content, "CENTER", 0, 30)
    Installer.addonLabel = addonLabel

    -- Status text
    local statusLabel = content:CreateFontString(nil, "OVERLAY")
    statusLabel:SetFont(FONT, 12, "OUTLINE")
    statusLabel:SetTextColor(C.textSecondary[1], C.textSecondary[2], C.textSecondary[3], C.textSecondary[4])
    statusLabel:SetPoint("CENTER", content, "CENTER", 0, 0)
    Installer.statusLabel = statusLabel

    -- Footer
    local footer = MakeBackdropFrame(nil, f, W, FOOTER_H, C.bgMedium)
    footer:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    footer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    -- footer top border
    local fBorder = footer:CreateTexture(nil, "OVERLAY")
    fBorder:SetHeight(1) fBorder:SetColorTexture(0,0,0,1)
    fBorder:SetPoint("TOPLEFT",footer,"TOPLEFT",0,0)
    fBorder:SetPoint("TOPRIGHT",footer,"TOPRIGHT",0,0)

    -- Helper: create a styled button
    local function MakeButton(label, parent, w, h)
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(w, h)
        btn:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(C.bgMedium[1], C.bgMedium[2], C.bgMedium[3], C.bgMedium[4])
        btn:SetBackdropBorderColor(0, 0, 0, 1)
        AddBorders(btn, 0, 0, 0, 1)

        local lbl = btn:CreateFontString(nil, "OVERLAY")
        lbl:SetFont(FONT, 12, "OUTLINE")
        lbl:SetTextColor(C.accent[1], C.accent[2], C.accent[3], C.accent[4])
        lbl:SetPoint("CENTER")
        lbl:SetText(label)

        -- Hover: animate border to accent color over 0.18s
        local hoverProgress = 0
        btn:SetScript("OnUpdate", function(self, elapsed)
            local target = self.isHovered and 1 or 0
            hoverProgress = hoverProgress + (target - hoverProgress) * math.min(elapsed / 0.18, 1)
            local r = hoverProgress * C.accent[1]
            local g = hoverProgress * C.accent[2]
            local b = hoverProgress * C.accent[3]
            self:SetBackdropBorderColor(r, g, b, 1)
        end)
        btn:SetScript("OnEnter", function(self) self.isHovered = true end)
        btn:SetScript("OnLeave", function(self) self.isHovered = false end)

        return btn
    end

    local nextBtn = MakeButton("Next", footer, 80, 24)
    nextBtn:SetPoint("BOTTOMRIGHT", footer, "BOTTOMRIGHT", -10, 8)
    Installer.nextBtn = nextBtn

    local backBtn = MakeButton("Back", footer, 80, 24)
    backBtn:SetPoint("RIGHT", nextBtn, "LEFT", -8, 0)
    Installer.backBtn = backBtn

    Installer.frame = f
end

-- Show a step
local function ShowStep(index, pages)
    local page = pages[index]
    if not page then return end
    Installer.stepText:SetText("Step " .. index .. " of " .. #pages)
    Installer.addonLabel:SetText(page.title or "")
    Installer.statusLabel:SetText(page.status or "")

    -- Back button
    Installer.backBtn:SetEnabled(index > 1)
    Installer.backBtn:SetAlpha(index > 1 and 1 or 0.3)

    -- Next/Finish label
    local isLast = (index == #pages)
    -- find nextBtn label fontstring
    for _, child in pairs({Installer.nextBtn:GetRegions()}) do
        if child:GetObjectType() == "FontString" then
            child:SetText(isLast and "Finish" or "Next")
        end
    end

    -- Run the page's OnShow if present
    if page.OnShow then page.OnShow() end
end

-- Public: queue and open the installer with a list of page tables
-- Each page: { title = "...", status = "...", OnShow = function() end, import = function() end }
function Installer:Open(pages)
    if not Installer.frame then BuildFrame() end
    Installer.pages   = pages
    Installer.current = 1

    Installer.nextBtn:SetScript("OnClick", function()
        local page = pages[Installer.current]
        if page and page.import then
            page.import()
            page.status = "Done!"
            Installer.statusLabel:SetText("Done!")
        end
        if Installer.current < #pages then
            Installer.current = Installer.current + 1
            ShowStep(Installer.current, pages)
        else
            Installer.frame:Hide()
            JetUI:FinishInstallation()
        end
    end)

    Installer.backBtn:SetScript("OnClick", function()
        if Installer.current > 1 then
            Installer.current = Installer.current - 1
            ShowStep(Installer.current, pages)
        end
    end)

    ShowStep(1, pages)
    Installer.frame:Show()
end
```

- [ ] **Step 2: Add UI/Installer.lua to JetUI.toc**

`UI\Installer.lua` should be listed right after `JetUI.lua` in the TOC (it already is from Task 1 — verify it's present).

- [ ] **Step 3: Verify wizard frame appears in WoW**

Add a temporary test call at the bottom of `JetUI.lua`:

```lua
-- TEMP TEST: open installer with 2 dummy pages
C_Timer.After(2, function()
    JetUI.Installer:Open({
        { title = "Welcome to JetUI", status = "Press Next to begin." },
        { title = "Details", status = "Ready to import.", import = function() print("Details imported!") end },
    })
end)
```

Log in. After 2 seconds, the installer frame should appear centered on screen with header "JetUI", step counter "Step 1 of 2", title "Welcome to JetUI", and footer buttons. Clicking Next should advance to step 2 and print "Details imported!" in chat. Clicking Next on step 2 should close the frame.

- [ ] **Step 4: Remove the temp test code from JetUI.lua**

- [ ] **Step 5: Commit**

```bash
git add UI/Installer.lua JetUI.lua
git commit -m "feat: wizard frame with header, content, footer, hover buttons"
```

---

## Task 3: Flow selection logic

**Files:**
- Modify: `JetUI.lua`

- [ ] **Step 1: Add flow selection to Initialize() in JetUI.lua**

Replace the `Initialize()` function body with:

```lua
local function Initialize()
    JetUIDB.InstalledVersions = JetUIDB.InstalledVersions or {}
    JetUIDB.InstalledChars    = JetUIDB.InstalledChars    or {}

    local charKey = GetCharKey()

    -- Determine which CDM addon is active
    local hasAyijeCDM   = IsAddOnLoaded("AyijeCDM")
    local hasSkironCDM  = IsAddOnLoaded("SkironCDM")
    JetUI.cdmAddon = nil
    if hasAyijeCDM and hasSkironCDM then
        JetUI.cdmConflict = true
    elseif hasAyijeCDM then
        JetUI.cdmAddon = "AyijeCDM"
    elseif hasSkironCDM then
        JetUI.cdmAddon = "SkironCDM"
    end

    -- Check for out-of-date addons
    local outOfDate = {}
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "MinimapStats" }
    for _, tag in ipairs(addonTags) do
        if GetTOCVersion(tag) > GetInstalledVersion(tag) then
            table.insert(outOfDate, tag)
        end
    end

    -- Select flow
    if next(JetUIDB.InstalledVersions) == nil and next(JetUIDB.InstalledChars) == nil then
        -- First ever run
        JetUI:RunInstall(addonTags)
    elseif not JetUIDB.InstalledChars[charKey] then
        -- Known install, new character
        JetUI:SetProfiles()
    elseif #outOfDate > 0 then
        -- Update out-of-date addons
        JetUI:UpdateOutOfDateAddons(outOfDate)
    else
        -- All good, silent
    end
end
```

- [ ] **Step 2: Add stub flow functions to JetUI.lua**

```lua
function JetUI:RunInstall(addonTags)
    local pages = JetUI:BuildInstallPages(addonTags, true)
    JetUI.Installer:Open(pages)
end

function JetUI:ForceReinstall()
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "MinimapStats" }
    local pages = JetUI:BuildInstallPages(addonTags, true)
    JetUI.Installer:Open(pages)
end

function JetUI:UpdateOutOfDateAddons(outOfDate)
    local pages = JetUI:BuildInstallPages(outOfDate, true)
    JetUI.Installer:Open(pages)
end

function JetUI:SetProfiles()
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "MinimapStats" }
    local pages = JetUI:BuildInstallPages(addonTags, false) -- false = activate only, no import
    JetUI.Installer:Open(pages)
end

-- Build a list of installer pages from a list of addon tag names
-- forceImport = true: import profiles; false: activate/set profiles only
function JetUI:BuildInstallPages(addonTags, forceImport)
    local pages = {}

    -- Welcome page
    table.insert(pages, {
        title  = "JetUI Installer",
        status = "Press Next to begin installing your profiles.",
    })

    -- CDM conflict warning
    if JetUI.cdmConflict then
        table.insert(pages, {
            title  = "CDM Conflict",
            status = "Both AyijeCDM and SkironCDM are enabled.\nPlease disable one and run /jetui install.",
        })
    end

    -- One page per addon
    for _, tag in ipairs(addonTags) do
        -- Skip CDM addons if wrong one or conflict
        if (tag == "AyijeCDM" or tag == "SkironCDM") then
            if JetUI.cdmConflict or JetUI.cdmAddon ~= tag then
                -- skip
            else
                table.insert(pages, {
                    title  = tag,
                    status = forceImport and "Ready to import." or "Activating profile.",
                    import = forceImport and function()
                        local fn = JetUI["Import" .. tag]
                        if fn then fn(JetUI, true) end
                    end or function()
                        local fn = JetUI["Import" .. tag]
                        if fn then fn(JetUI, false) end
                    end,
                })
            end
        else
            table.insert(pages, {
                title  = tag,
                status = forceImport and "Ready to import." or "Activating profile.",
                import = function()
                    local fn = JetUI["Import" .. tag]
                    if fn then fn(JetUI, forceImport) end
                end,
            })
        end
    end

    -- Finish page
    table.insert(pages, {
        title  = "Done!",
        status = "All profiles installed. Click Finish to reload.",
    })

    return pages
end

function JetUI:FinishInstallation()
    local charKey = GetCharKey()
    JetUIDB.InstalledVersion          = ADDON_VERSION
    JetUIDB.InstalledChars[charKey]   = ADDON_VERSION
    ReloadUI()
end
```

- [ ] **Step 3: Wire up slash commands to ForceReinstall/SetProfiles**

Replace the TODO stubs in `SlashCmdList["JETUI"]`:

```lua
    if cmd == "install" then
        JetUI:ForceReinstall()
    elseif cmd == "load" then
        JetUI:SetProfiles()
```

- [ ] **Step 4: Verify flow selection in WoW**

Clear `JetUIDB` by typing `/run JetUIDB = nil` then `/reload`. The fresh install flow should trigger and open the installer. Advance through all pages. On Finish, `ReloadUI()` should fire. After reload, type `/run print(JetUIDB.InstalledChars["YourChar-Realm"])` — should print `"1.0"`.

- [ ] **Step 5: Commit**

```bash
git add JetUI.lua
git commit -m "feat: flow selection logic, install/update/setprofiles/forcereinstall flows"
```

---

## Task 4: AddonData files (profile string placeholders)

**Files:**
- Create: `AddonData/Details.lua`, `AddonData/Plater.lua`, `AddonData/Grid2.lua`, `AddonData/UnhaltedUnitFrames.lua`, `AddonData/BigWigs.lua`, `AddonData/BuffReminders.lua`, `AddonData/AyijeCDM.lua`, `AddonData/SkironCDM.lua`, `AddonData/MinimapStats.lua`

Each file follows the same pattern. The profile strings are filled in by the user; the structure is defined here.

- [ ] **Step 1: Create AddonData/Details.lua**

```lua
JetUI.DetailsProfileString = "PASTE_DETAILS_PROFILE_STRING_HERE"
```

- [ ] **Step 2: Create AddonData/Plater.lua**

```lua
JetUI.PlaterProfileString = "PASTE_PLATER_PROFILE_STRING_HERE"
```

- [ ] **Step 3: Create AddonData/Grid2.lua**

```lua
JetUI.Grid2ProfileString = "PASTE_GRID2_PROFILE_STRING_HERE"
```

- [ ] **Step 4: Create AddonData/UnhaltedUnitFrames.lua**

```lua
JetUI.UnhaltedUnitFramesProfileString = "PASTE_UNHALTED_UNIT_FRAMES_PROFILE_STRING_HERE"
```

- [ ] **Step 5: Create AddonData/BigWigs.lua**

```lua
JetUI.BigWigsProfileString = "PASTE_BIGWIGS_PROFILE_STRING_HERE"
```

- [ ] **Step 6: Create AddonData/BuffReminders.lua**

```lua
JetUI.BuffRemindersProfileString = "PASTE_BUFF_REMINDERS_PROFILE_STRING_HERE"
```

- [ ] **Step 7: Create AddonData/AyijeCDM.lua**

AyijeCDM supports multiple profiles — DPS and healer variants are both imported.

```lua
JetUI.AyijeCDMProfileStrings = {
    ["JetUI DPS"]    = "PASTE_AYIJE_CDM_DPS_PROFILE_STRING_HERE",
    ["JetUI Healer"] = "PASTE_AYIJE_CDM_HEALER_PROFILE_STRING_HERE",
}
```

- [ ] **Step 8: Create AddonData/SkironCDM.lua**

```lua
JetUI.SkironCDMProfileStrings = {
    ["JetUI DPS"]    = "PASTE_SKIRON_CDM_DPS_PROFILE_STRING_HERE",
    ["JetUI Healer"] = "PASTE_SKIRON_CDM_HEALER_PROFILE_STRING_HERE",
}
```

- [ ] **Step 9: Create AddonData/MinimapStats.lua**

```lua
-- MinimapStats profile import support TBD.
-- If the addon supports SavedVar profile import, fill in the string below.
-- If not, the installer will show a manual configuration step.
JetUI.MinimapStatsProfileString = nil
```

- [ ] **Step 10: Commit**

```bash
git add AddonData/
git commit -m "feat: AddonData files with profile string placeholders"
```

---

## Task 5: Import functions — API-driven addons

**Files:**
- Create: `AddonImports/Details.lua`, `AddonImports/BigWigs.lua`, `AddonImports/BuffReminders.lua`

- [ ] **Step 1: Create AddonImports/Details.lua**

```lua
function JetUI:ImportDetails(forceImport)
    if not IsAddOnLoaded("Details") then return end
    if forceImport then
        if not JetUI.DetailsProfileString or JetUI.DetailsProfileString == "PASTE_DETAILS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r Details: no profile string set, skipping.")
            return
        end
        _detalhes:ImportProfile(JetUI.DetailsProfileString, "JetUI", true, true)
        JetUIDB.InstalledVersions["Details"] = GetAddOnMetadata("JetUI", "X-Details")
    end
    _detalhes:ApplyProfile("JetUI")
end
```

- [ ] **Step 2: Create AddonImports/BigWigs.lua**

```lua
function JetUI:ImportBigWigs(forceImport)
    if not IsAddOnLoaded("BigWigs") then return end
    if forceImport then
        if not JetUI.BigWigsProfileString or JetUI.BigWigsProfileString == "PASTE_BIGWIGS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r BigWigs: no profile string set, skipping.")
            return
        end
        BigWigsAPI.RegisterProfile("JetUI", JetUI.BigWigsProfileString, "JetUI", function()
            BigWigsAPI.SetProfile("JetUI")
            JetUIDB.InstalledVersions["BigWigs"] = GetAddOnMetadata("JetUI", "X-BigWigs")
        end)
    else
        BigWigsAPI.SetProfile("JetUI")
    end
end
```

- [ ] **Step 3: Create AddonImports/BuffReminders.lua**

```lua
function JetUI:ImportBuffReminders(forceImport)
    if not IsAddOnLoaded("BuffReminders") then return end
    if forceImport then
        if not JetUI.BuffRemindersProfileString or JetUI.BuffRemindersProfileString == "PASTE_BUFF_REMINDERS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r BuffReminders: no profile string set, skipping.")
            return
        end
        BuffRemindersAPI:ImportProfile(JetUI.BuffRemindersProfileString, "JetUI")
        JetUIDB.InstalledVersions["BuffReminders"] = GetAddOnMetadata("JetUI", "X-BuffReminders")
    end
    BuffRemindersAPI:SetProfile("JetUI")
end
```

- [ ] **Step 4: Commit**

```bash
git add AddonImports/Details.lua AddonImports/BigWigs.lua AddonImports/BuffReminders.lua
git commit -m "feat: import functions for Details, BigWigs, BuffReminders"
```

---

## Task 6: Import functions — SavedVar write addons

**Files:**
- Create: `AddonImports/Plater.lua`, `AddonImports/Grid2.lua`, `AddonImports/UnhaltedUnitFrames.lua`, `AddonImports/MinimapStats.lua`

Note: Grid2, UnhaltedUnitFrames, and MinimapStats SavedVar structures must be confirmed by inspecting those addons' `.toc` files for their `SavedVariables` field and then looking at their SavedVar tables in-game via `/run DevTools_Dump(Grid2DB)` (or equivalent). The patterns below are templates that must be verified before real profile strings are added.

- [ ] **Step 1: Create AddonImports/Plater.lua**

Plater stores profiles in `PlaterDB.profiles[profileName]`. The profile string uses the `!PLATER:2!` prefix and is decoded by Plater's own decompression function.

```lua
function JetUI:ImportPlater(forceImport)
    if not IsAddOnLoaded("Plater") then return end
    if forceImport then
        if not JetUI.PlaterProfileString or JetUI.PlaterProfileString == "PASTE_PLATER_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r Plater: no profile string set, skipping.")
            return
        end
        local decoded = Plater.DecompressData(JetUI.PlaterProfileString, "print")
        if decoded then
            PlaterDB.profiles = PlaterDB.profiles or {}
            PlaterDB.profiles["JetUI"] = decoded
            JetUIDB.InstalledVersions["Plater"] = GetAddOnMetadata("JetUI", "X-Plater")
        else
            print("|cff00ff96JetUI|r Plater: failed to decode profile string.")
        end
    end
    -- Set the profile active for this character
    if Plater.SetProfile then
        Plater.SetProfile("JetUI")
    elseif PlaterDB then
        PlaterDB.profile_name = "JetUI"
    end
end
```

- [ ] **Step 2: Create AddonImports/Grid2.lua**

Grid2 stores profiles in `Grid2DB` (exact structure TBD — must be confirmed in-game before filling in a real profile string). This is a placeholder that prints a notice until confirmed.

```lua
function JetUI:ImportGrid2(forceImport)
    if not IsAddOnLoaded("Grid2") then return end
    if not JetUI.Grid2ProfileString or JetUI.Grid2ProfileString == "PASTE_GRID2_PROFILE_STRING_HERE" then
        print("|cff00ff96JetUI|r Grid2: no profile string set, skipping.")
        return
    end
    if forceImport then
        -- Grid2 stores profiles in Grid2DB. Import method TBD.
        -- Confirm SavedVar structure with: /run DevTools_Dump(Grid2DB)
        -- Then implement the write here.
        print("|cff00ff96JetUI|r Grid2: import not yet implemented.")
        JetUIDB.InstalledVersions["Grid2"] = GetAddOnMetadata("JetUI", "X-Grid2")
    end
end
```

- [ ] **Step 3: Create AddonImports/UnhaltedUnitFrames.lua**

```lua
function JetUI:ImportUnhaltedUnitFrames(forceImport)
    if not IsAddOnLoaded("UnhaltedUnitFrames") then return end
    if not JetUI.UnhaltedUnitFramesProfileString or JetUI.UnhaltedUnitFramesProfileString == "PASTE_UNHALTED_UNIT_FRAMES_PROFILE_STRING_HERE" then
        print("|cff00ff96JetUI|r UnhaltedUnitFrames: no profile string set, skipping.")
        return
    end
    if forceImport then
        -- UnhaltedUnitFrames SavedVar structure TBD.
        -- Confirm with: /run DevTools_Dump(UnhaltedUnitFramesDB)  (check the actual SavedVariables name in its TOC)
        print("|cff00ff96JetUI|r UnhaltedUnitFrames: import not yet implemented.")
        JetUIDB.InstalledVersions["UnhaltedUnitFrames"] = GetAddOnMetadata("JetUI", "X-UnhaltedUnitFrames")
    end
end
```

- [ ] **Step 4: Create AddonImports/MinimapStats.lua**

```lua
function JetUI:ImportMinimapStats(forceImport)
    if not IsAddOnLoaded("MinimapStats") then return end
    if not JetUI.MinimapStatsProfileString then
        -- No profile string — show info step only, no import
        return
    end
    if forceImport then
        -- MinimapStats SavedVar structure TBD.
        print("|cff00ff96JetUI|r MinimapStats: import not yet implemented.")
        JetUIDB.InstalledVersions["MinimapStats"] = GetAddOnMetadata("JetUI", "X-MinimapStats")
    end
end
```

- [ ] **Step 5: Commit**

```bash
git add AddonImports/Plater.lua AddonImports/Grid2.lua AddonImports/UnhaltedUnitFrames.lua AddonImports/MinimapStats.lua
git commit -m "feat: import functions for Plater, Grid2, UnhaltedUnitFrames, MinimapStats"
```

---

## Task 7: Import functions — CDM addons

**Files:**
- Create: `AddonImports/AyijeCDM.lua`, `AddonImports/SkironCDM.lua`

- [ ] **Step 1: Create AddonImports/AyijeCDM.lua**

AyijeCDM exposes `Ayije_CDM_API:ImportProfile(string, name)`. All profiles are imported; spec mappings write DPS as default and healer profiles for healing spec IDs.

Healing spec IDs in WoW: Holy Paladin (65), Holy Priest (256), Discipline Priest (257), Restoration Druid (105), Restoration Shaman (264), Mistweaver Monk (270), Preservation Evoker (1468).

```lua
local HEALER_SPECS = { [65]=true, [256]=true, [257]=true, [105]=true, [264]=true, [270]=true, [1468]=true }

function JetUI:ImportAyijeCDM(forceImport)
    if not IsAddOnLoaded("AyijeCDM") then return end
    if forceImport then
        for profileName, profileString in pairs(JetUI.AyijeCDMProfileStrings or {}) do
            if not profileString:find("^PASTE_") then
                Ayije_CDM_API:ImportProfile(profileString, profileName)
            end
        end
        JetUIDB.InstalledVersions["AyijeCDM"] = GetAddOnMetadata("JetUI", "X-AyijeCDM")
    end

    -- Set active profile: DPS by default, healer if current spec is a healer
    local _, _, _, specID = GetSpecializationInfo(GetSpecialization() or 1)
    local activeProfile = HEALER_SPECS[specID] and "JetUI Healer" or "JetUI DPS"
    if Ayije_CDM_API.SetProfile then
        Ayije_CDM_API:SetProfile(activeProfile)
    end
end
```

- [ ] **Step 2: Create AddonImports/SkironCDM.lua**

SkironCDM API is TBD — this is a placeholder that prints a notice. Fill in once the addon's API is confirmed.

```lua
local HEALER_SPECS = { [65]=true, [256]=true, [257]=true, [105]=true, [264]=true, [270]=true, [1468]=true }

function JetUI:ImportSkironCDM(forceImport)
    if not IsAddOnLoaded("SkironCDM") then return end
    if forceImport then
        -- SkironCDM API TBD. Check addon source for export/import functions.
        -- Once confirmed, import JetUI.SkironCDMProfileStrings here similarly to AyijeCDM.
        print("|cff00ff96JetUI|r SkironCDM: import not yet implemented. Check SkironCDM API.")
        JetUIDB.InstalledVersions["SkironCDM"] = GetAddOnMetadata("JetUI", "X-SkironCDM")
    end
end
```

- [ ] **Step 3: Commit**

```bash
git add AddonImports/AyijeCDM.lua AddonImports/SkironCDM.lua
git commit -m "feat: import functions for AyijeCDM and SkironCDM placeholder"
```

---

## Task 8: Fill in profile strings and end-to-end test

**Files:**
- Modify: `AddonData/*.lua` (replace placeholder strings with real profile exports)

- [ ] **Step 1: Export profiles from each addon in WoW**

For each addon in the JetUI pack, export the profile string using that addon's built-in export UI. Paste the string into the corresponding `AddonData/*.lua` file, replacing the `"PASTE_..._HERE"` placeholder.

- [ ] **Step 2: Confirm Grid2 SavedVar structure**

In-game, with Grid2 loaded and your profile active:
```
/run DevTools_Dump(Grid2DB)
```
Identify the structure of profiles (likely `Grid2DB.profiles[profileName]` or similar). Update `AddonImports/Grid2.lua` with the correct write logic.

- [ ] **Step 3: Confirm UnhaltedUnitFrames SavedVar structure**

Check the addon's `.toc` file for the `SavedVariables` field name, then:
```
/run DevTools_Dump(<SavedVarName>)
```
Update `AddonImports/UnhaltedUnitFrames.lua` with the correct write logic.

- [ ] **Step 4: Confirm SkironCDM API (if using SkironCDM)**

Browse SkironCDM's source (`/run print(GetAddOnInfo("SkironCDM"))` to find its folder). Look for export/import functions. Update `AddonImports/SkironCDM.lua`.

- [ ] **Step 5: Full end-to-end test — fresh install**

1. Clear state: `/run JetUIDB = nil` then `/reload`
2. Installer should open automatically
3. Click through all steps, each import should succeed silently (no error messages)
4. On Finish, `ReloadUI()` fires
5. After reload, verify each addon is using the JetUI profile

- [ ] **Step 6: Full end-to-end test — new character flow**

Log in on a different character. The "new character" flow should open (activate profiles without re-importing). Verify each addon switches to the JetUI profile.

- [ ] **Step 7: Full end-to-end test — update flow**

Manually bump a version in `JetUIDB.InstalledVersions` to something lower than the TOC:
```
/run JetUIDB.InstalledVersions["Details"] = "0.1" then /reload
```
Only the Details step should appear.

- [ ] **Step 8: Commit**

```bash
git add AddonData/
git commit -m "feat: populate profile strings, all imports functional"
```

---

## Task 9: Polish and confirmation dialog

**Files:**
- Modify: `JetUI.lua`

- [ ] **Step 1: Add confirmation dialog for force reinstall**

In `SlashCmdList["JETUI"]`, replace the `install` branch:

```lua
    if cmd == "install" then
        if JetUIDB and next(JetUIDB.InstalledChars) then
            StaticPopupDialogs["JETUI_CONFIRM_REINSTALL"] = {
                text = "|cff00ff96JetUI|r is already installed. Reinstall all profiles?",
                button1 = "Reinstall",
                button2 = "Cancel",
                OnAccept = function() JetUI:ForceReinstall() end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            StaticPopup_Show("JETUI_CONFIRM_REINSTALL")
        else
            JetUI:ForceReinstall()
        end
```

- [ ] **Step 2: Verify confirmation dialog**

With JetUI already installed, type `/jetui install`. A confirmation dialog should appear. Clicking Cancel should do nothing. Clicking Reinstall should open the full installer.

- [ ] **Step 3: Commit**

```bash
git add JetUI.lua
git commit -m "feat: confirmation dialog for /jetui install when already installed"
```

---

## Summary

After all tasks:
- JetUI loads and selects the correct flow automatically at login
- Wizard UI matches NorskenUI's dark/teal aesthetic
- All 9 addons have profile import functions
- Versioning system tracks what's installed and queues updates
- `/jetui install`, `/jetui load`, `/jetui ver` all work
- Force reinstall prompts for confirmation
