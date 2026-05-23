function JetUI:ImportNorskenUI(forceImport)
    if not IsAddOnLoaded("NorskenUI") then return end
    if forceImport then
        if not JetUI.NorskenUIProfileString or JetUI.NorskenUIProfileString == "PASTE_NORSKENUI_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r NorskenUI: no profile string set, skipping.")
            return
        end
        if not (NorskenUIAPI and NorskenUIAPI.ImportProfile) then
            print("|cff00ff96JetUI|r NorskenUI: NorskenUIAPI not available.")
            return
        end
        NorskenUIAPI:ImportProfile(JetUI.NorskenUIProfileString, "JetUI")
        if NorskenUIAPI.SetProfile then
            NorskenUIAPI:SetProfile("JetUI")
        end
        JetUIDB.InstalledVersions["NorskenUI"] = GetAddOnMetadata("JetUI", "X-NorskenUI")
        -- NorskenUI requires a reload after import
        C_UI.Reload()
    end
end
