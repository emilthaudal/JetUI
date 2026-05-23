function JetUI:ImportDetails(forceImport)
    if not C_AddOns.IsAddOnLoaded("Details") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.DetailsProfileString or JetUI.DetailsProfileString == "PASTE_DETAILS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r Details: no profile string set, skipping.")
            return
        end
        _detalhes:ImportProfile(JetUI.DetailsProfileString, profileName, true, true)
        JetUIDB.InstalledVersions["Details"] = C_AddOns.GetAddOnMetadata("JetUI", "X-Details")
        _detalhes:ApplyProfile(profileName)
    else
        _detalhes:ApplyProfile(profileName)
    end
end
