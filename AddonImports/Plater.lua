function JetUI:ImportPlater(forceImport)
    if not C_AddOns.IsAddOnLoaded("Plater") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.PlaterProfileString or JetUI.PlaterProfileString == "PASTE_PLATER_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r Plater: no profile string set, skipping.")
            return
        end
        local decoded = Plater.DecompressData(JetUI.PlaterProfileString, "print")
        if decoded then
            PlaterDB.profiles = PlaterDB.profiles or {}
            PlaterDB.profiles[profileName] = decoded
            JetUIDB.InstalledVersions["Plater"] = C_AddOns.GetAddOnMetadata("JetUI", "X-Plater")
        else
            print("|cff00ff96JetUI|r Plater: failed to decode profile string.")
            return
        end
    end
    -- Activate profile via AceDB
    if Plater.db then
        Plater.db:SetProfile(profileName)
    end
end
