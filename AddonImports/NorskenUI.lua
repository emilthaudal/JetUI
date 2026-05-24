function JetUI:ImportNorskenUI(forceImport)
    if not C_AddOns.IsAddOnLoaded("NorskenUI") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.NorskenUIProfileString or JetUI.NorskenUIProfileString == "PASTE_NORSKENUI_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r NorskenUI: no profile string set, skipping.")
            return
        end
        -- Profile strings use Base64/Deflate/CBOR (WagoUI format) via C_EncodingUtil.
        -- NorskenUIAPI:ImportProfile handles this format and activates the profile automatically.
        if not (NorskenUIAPI and NorskenUIAPI.ImportProfile) then
            print("|cff00ff96JetUI|r NorskenUI: NorskenUIAPI not available.")
            return
        end
        NorskenUIAPI:ImportProfile(JetUI.NorskenUIProfileString, profileName)
        JetUIDB.InstalledVersions["NorskenUI"] = C_AddOns.GetAddOnMetadata("JetUI", "X-NorskenUI")
    else
        -- Activate only
        if NorskenUIAPI and NorskenUIAPI.SetProfile then
            NorskenUIAPI:SetProfile(profileName)
        end
    end
end
