function JetUI:ImportPlater(forceImport)
    if not C_AddOns.IsAddOnLoaded("Plater") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.PlaterProfileString or JetUI.PlaterProfileString == "PASTE_PLATER_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r Plater: no profile string set, skipping.")
            return
        end
        if not (PlaterAPI and PlaterAPI.ImportProfile) then
            print("|cff00ff96JetUI|r Plater: PlaterAPI not available.")
            return
        end
        -- PlaterAPI:ImportProfile handles decode, write AND profile switch internally
        PlaterAPI:ImportProfile(JetUI.PlaterProfileString, profileName)
        JetUIDB.InstalledVersions["Plater"] = C_AddOns.GetAddOnMetadata("JetUI", "X-Plater")
    else
        if PlaterAPI and PlaterAPI.SetProfile then
            PlaterAPI:SetProfile(profileName)
        end
    end
end
