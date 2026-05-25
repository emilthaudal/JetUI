local HEALER_SPECS = { [65]=true, [256]=true, [257]=true, [105]=true, [264]=true, [270]=true, [1468]=true }
local CASTER_SPECS = {
    [62]=true,  -- Arcane Mage
    [63]=true,  -- Fire Mage
    [64]=true,  -- Frost Mage
    [102]=true, -- Balance Druid
    [258]=true, -- Shadow Priest
    [262]=true, -- Elemental Shaman
    [265]=true, -- Affliction Warlock
    [266]=true, -- Demonology Warlock
    [267]=true, -- Destruction Warlock
    [253]=true, -- Beast Mastery Hunter
    [254]=true, -- Marksmanship Hunter
    [577]=true, -- Havoc Demon Hunter
}

function JetUI:ImportAyijeCDM(forceImport)
    if not C_AddOns.IsAddOnLoaded("Ayije_CDM") then return end
    local prefix = JetUI.profilePrefix or ""
    if forceImport then
        for profileName, profileString in pairs(JetUI.AyijeCDMProfileStrings or {}) do
            if not profileString:find("^PASTE_") then
                Ayije_CDM_API:ImportProfile(profileString, prefix .. profileName)
            end
        end
        JetUIDB.InstalledVersions["AyijeCDM"] = C_AddOns.GetAddOnMetadata("JetUI", "X-AyijeCDM")
    end

    -- Set active profile: Caster > Healer > DPS
    local _, _, _, specID = GetSpecializationInfo(GetSpecialization() or 1)
    local baseName
    if HEALER_SPECS[specID] then
        baseName = "JetUI Healer"
    elseif CASTER_SPECS[specID] then
        baseName = "JetUI Caster"
    else
        baseName = "JetUI DPS"
    end
    if Ayije_CDM_API.SetProfile then
        Ayije_CDM_API:SetProfile(prefix .. baseName)
    end
end
