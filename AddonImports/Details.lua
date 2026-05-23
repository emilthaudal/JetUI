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
