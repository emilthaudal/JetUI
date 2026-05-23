local HEALER_SPECS = { [65]=true, [256]=true, [257]=true, [105]=true, [264]=true, [270]=true, [1468]=true }

function JetUI:ImportAyijeCDM(forceImport)
    if not IsAddOnLoaded("Ayije_CDM") then return end
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
