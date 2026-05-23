function JetUI:ImportNorskenUI(forceImport)
    if not C_AddOns.IsAddOnLoaded("NorskenUI") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.NorskenUIProfileString or JetUI.NorskenUIProfileString == "PASTE_NORSKENUI_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r NorskenUI: no profile string set, skipping.")
            return
        end
        if not (NorskenUIAPI and NorskenUIAPI.ImportProfile) then
            print("|cff00ff96JetUI|r NorskenUI: NorskenUIAPI not available.")
            return
        end
        NorskenUIAPI:ImportProfile(JetUI.NorskenUIProfileString, profileName)
        if NorskenUIAPI.SetProfile then
            NorskenUIAPI:SetProfile(profileName)
        end
        JetUIDB.InstalledVersions["NorskenUI"] = C_AddOns.GetAddOnMetadata("JetUI", "X-NorskenUI")
    end
end
