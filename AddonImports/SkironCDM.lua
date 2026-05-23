function JetUI:ImportSkironCDM(forceImport)
    if not IsAddOnLoaded("SkironCooldownManager") then return end
    if forceImport then
        for profileName, profileString in pairs(JetUI.SkironCDMProfileStrings or {}) do
            if not profileString:find("^PASTE_") then
                SCMAPI.ImportProfile(profileName, profileString)
            end
        end
        JetUIDB.InstalledVersions["SkironCDM"] = GetAddOnMetadata("JetUI", "X-SkironCDM")
    end
end
