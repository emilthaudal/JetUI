JetUI = JetUI or {}
JetUIDB = JetUIDB or {}

local ADDON_NAME = "JetUI"
local ADDON_VERSION = "1.0"

-- Set to "" for release. During testing, profiles are imported under this prefix
-- so they don't overwrite profiles you're actively developing.
JetUI.profilePrefix = ""

-- Version helpers
local function GetNiceVersionNumber(versionString)
    local major, minor = strsplit(".", versionString or "0.0")
    return (tonumber(major) or 0) * 1000 + (tonumber(minor) or 0)
end

local function GetTOCVersion(addonTag)
    local v = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-" .. addonTag)
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

    -- Determine which CDM addon is active
    local hasAyijeCDM   = C_AddOns.IsAddOnLoaded("Ayije_CDM")
    local hasSkironCDM  = C_AddOns.IsAddOnLoaded("SkironCooldownManager")
    JetUI.cdmAddon = nil
    if hasAyijeCDM and hasSkironCDM then
        JetUI.cdmConflict = true
    elseif hasAyijeCDM then
        JetUI.cdmAddon = "AyijeCDM"
    elseif hasSkironCDM then
        JetUI.cdmAddon = "SkironCDM"
    end

    -- Nothing happens automatically on login.
    -- Use /jetui install to open the installer and import profiles manually.
end

function JetUI:RunInstall(addonTags)
    local pages = JetUI:BuildInstallPages(addonTags, true)
    JetUI.Installer:Open(pages)
end

function JetUI:ForceReinstall()
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "BlizzardCDM", "MinimapStats", "NorskenUI", "EditMode" }
    local pages = JetUI:BuildInstallPages(addonTags, true)
    JetUI.Installer:Open(pages)
end

function JetUI:UpdateOutOfDateAddons(outOfDate)
    local pages = JetUI:BuildInstallPages(outOfDate, true)
    JetUI.Installer:Open(pages)
end

function JetUI:SetProfiles()
    -- Silently activate profiles for this character without opening the installer
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "BlizzardCDM", "MinimapStats", "NorskenUI", "EditMode" }
    for _, tag in ipairs(addonTags) do
        if tag == "AyijeCDM" or tag == "SkironCDM" then
            if JetUI.cdmAddon == tag then
                local fn = JetUI["Import" .. tag]
                if fn then fn(JetUI, false) end
            end
        else
            local fn = JetUI["Import" .. tag]
            if fn then fn(JetUI, false) end
        end
    end
    local charKey = GetCharKey()
    JetUIDB.InstalledChars[charKey] = JetUIDB.InstalledVersion or ADDON_VERSION
    print("|cff00ff96JetUI|r Profiles loaded. Reloading UI...")
    ReloadUI()
end

-- Build a list of installer pages from a list of addon tag names
-- forceImport = true: import profiles; false: activate/set profiles only
function JetUI:BuildInstallPages(addonTags, forceImport)
    local pages = {}

    -- Welcome page (no sidebarLabel = not shown in sidebar)
    table.insert(pages, {
        title  = "JetUI Installer",
        status = "Select an addon from the list on the right, then click Import.",
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
                    title        = tag,
                    sidebarLabel = tag,
                    alreadyInstalled = (GetInstalledVersion(tag) >= GetTOCVersion(tag) and GetTOCVersion(tag) > 0),
                    status       = forceImport and "Click Import to install this profile." or "Click Import to activate this profile.",
                    import       = forceImport and function()
                        local fn = JetUI["Import" .. tag]
                        if fn then fn(JetUI, true) end
                    end or function()
                        local fn = JetUI["Import" .. tag]
                        if fn then fn(JetUI, false) end
                    end,
                })
            end
        elseif tag == "BlizzardCDM" then
            if CooldownViewerSettings then
                local specButtons = {}
                for _, spec in ipairs(JetUI.GetBlizzardCDMSpecsForPlayer()) do
                    local capturedTag = spec.cdmTag
                    specButtons[#specButtons + 1] = {
                        label = spec.label,
                        fn    = function()
                            JetUI:ImportBlizzardCDMSpec(capturedTag, true)
                        end,
                    }
                end
                specButtons[#specButtons + 1] = {
                    label       = "Import All",
                    isImportAll = true,
                    fn          = function()
                        JetUI:ImportAllBlizzardCDM(true)
                    end,
                }
                table.insert(pages, {
                    title        = "Blizzard CDM",
                    sidebarLabel = "Blizzard CDM",
                    status       = "Import your spec's cooldown layout.\nBlizzard CDM only allows importing your current class.",
                    buttons      = specButtons,
                })
            end
        else
            table.insert(pages, {
                title           = tag,
                sidebarLabel    = tag,
                alreadyInstalled = (GetInstalledVersion(tag) >= GetTOCVersion(tag) and GetTOCVersion(tag) > 0),
                status       = forceImport and "Click Import to install this profile." or "Click Import to activate this profile.",
                import       = function()
                    local fn = JetUI["Import" .. tag]
                    if fn then fn(JetUI, forceImport) end
                end,
            })
        end
    end

    -- Done page
    table.insert(pages, {
        title  = "All Done!",
        status = "All profiles installed.\nClick Reload UI to apply changes.",
        isDone = true,
    })

    return pages
end

function JetUI:FinishInstallation()
    local charKey = GetCharKey()
    JetUIDB.InstalledVersion          = ADDON_VERSION
    JetUIDB.InstalledChars[charKey]   = ADDON_VERSION
    ReloadUI()
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
        JetUI:ForceReinstall()
    elseif cmd == "cdm" then
        if CooldownViewerSettings then
            local specButtons = {}
            for _, spec in ipairs(JetUI.GetBlizzardCDMSpecsForPlayer()) do
                local capturedTag = spec.cdmTag
                specButtons[#specButtons + 1] = {
                    label = spec.label,
                    fn    = function()
                        JetUI:ImportBlizzardCDMSpec(capturedTag, true)
                    end,
                }
            end
            specButtons[#specButtons + 1] = {
                label       = "Import All",
                isImportAll = true,
                fn          = function()
                    JetUI:ImportAllBlizzardCDM(true)
                end,
            }
            local pages = {
                {
                    title        = "Blizzard CDM",
                    sidebarLabel = "Blizzard CDM",
                    status       = "Import your spec's cooldown layout.\nBlizzard CDM only allows importing your current class.",
                    buttons      = specButtons,
                },
                {
                    title  = "All Done!",
                    status = "Blizzard CDM profiles imported.\nClick Reload UI to apply changes.",
                    isDone = true,
                },
            }
            JetUI.Installer:Open(pages)
        else
            print("|cff00ff96JetUI|r Blizzard Cooldown Manager is not available.")
        end
    elseif cmd == "load" then
        JetUI:SetProfiles()
    elseif cmd == "ver" then
        print("|cff00ff96JetUI|r version " .. ADDON_VERSION)
        for k, v in pairs(JetUIDB.InstalledVersions or {}) do
            print("  " .. k .. ": " .. tostring(v))
        end
    elseif cmd == "reset" then
        JetUIDB = {}
        print("|cff00ff96JetUI|r SavedVariables cleared. Reloading...")
        ReloadUI()
    else
        print("|cff00ff96JetUI|r commands:")
        print("  /jetui install  - Force reinstall all profiles")
        print("  /jetui cdm      - Import Blizzard CDM spell layouts")
        print("  /jetui load     - Load profiles for this character")
        print("  /jetui ver      - Show installed versions")
        print("  /jetui reset    - Clear SavedVariables and reload")
    end
end
