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
