JetUI = JetUI or {}
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

    local charKey = GetCharKey()

    -- Determine which CDM addon is active
    local hasAyijeCDM   = IsAddOnLoaded("Ayije_CDM")
    local hasSkironCDM  = IsAddOnLoaded("SkironCooldownManager")
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
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "MinimapStats", "NorskenUI" }
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

function JetUI:RunInstall(addonTags)
    local pages = JetUI:BuildInstallPages(addonTags, true)
    JetUI.Installer:Open(pages)
end

function JetUI:ForceReinstall()
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "MinimapStats", "NorskenUI" }
    local pages = JetUI:BuildInstallPages(addonTags, true)
    JetUI.Installer:Open(pages)
end

function JetUI:UpdateOutOfDateAddons(outOfDate)
    local pages = JetUI:BuildInstallPages(outOfDate, true)
    JetUI.Installer:Open(pages)
end

function JetUI:SetProfiles()
    local addonTags = { "Details", "Plater", "Grid2", "UnhaltedUnitFrames", "BigWigs", "BuffReminders", "AyijeCDM", "SkironCDM", "MinimapStats", "NorskenUI" }
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
    elseif cmd == "load" then
        JetUI:SetProfiles()
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
