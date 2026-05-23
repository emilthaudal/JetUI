function JetUI:ImportDetails(forceImport)
    if not C_AddOns.IsAddOnLoaded("Details") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.DetailsProfileString or JetUI.DetailsProfileString == "PASTE_DETAILS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r Details: no profile string set, skipping.")
            return
        end
        if not (DetailsAPI and DetailsAPI.ImportProfile) then
            print("|cff00ff96JetUI|r Details: DetailsAPI not available.")
            return
        end
        -- DetailsAPI:ImportProfile handles import + profile switch internally (needReload=false)
        DetailsAPI:ImportProfile(JetUI.DetailsProfileString, profileName)
        JetUIDB.InstalledVersions["Details"] = C_AddOns.GetAddOnMetadata("JetUI", "X-Details")
    else
        if DetailsAPI and DetailsAPI.SetProfile then
            DetailsAPI:SetProfile(profileName)
        end
    end
end
