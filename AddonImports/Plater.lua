function JetUI:ImportPlater(forceImport)
    if not IsAddOnLoaded("Plater") then return end
    if forceImport then
        if not JetUI.PlaterProfileString or JetUI.PlaterProfileString == "PASTE_PLATER_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r Plater: no profile string set, skipping.")
            return
        end
        local decoded = Plater.DecompressData(JetUI.PlaterProfileString, "print")
        if decoded then
            PlaterDB.profiles = PlaterDB.profiles or {}
            PlaterDB.profiles["JetUI"] = decoded
            JetUIDB.InstalledVersions["Plater"] = GetAddOnMetadata("JetUI", "X-Plater")
        else
            print("|cff00ff96JetUI|r Plater: failed to decode profile string.")
        end
    end
    -- Set the profile active for this character
    if Plater.SetProfile then
        Plater.SetProfile("JetUI")
    elseif PlaterDB then
        PlaterDB.profile_name = "JetUI"
    end
end
