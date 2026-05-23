function JetUI:ImportSkironCDM(forceImport)
    if not C_AddOns.IsAddOnLoaded("SkironCooldownManager") then return end
    local prefix = JetUI.profilePrefix or ""
    if forceImport then
        for profileName, profileString in pairs(JetUI.SkironCDMProfileStrings or {}) do
            if not profileString:find("^PASTE_") then
                SCMAPI.ImportProfile(prefix .. profileName, profileString)
            end
        end
        JetUIDB.InstalledVersions["SkironCDM"] = C_AddOns.GetAddOnMetadata("JetUI", "X-SkironCDM")
    end
end
