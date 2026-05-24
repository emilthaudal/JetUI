function JetUI:ImportNorskenUI(forceImport)
    if not C_AddOns.IsAddOnLoaded("NorskenUI") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.NorskenUIProfileString or JetUI.NorskenUIProfileString == "PASTE_NORSKENUI_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r NorskenUI: no profile string set, skipping.")
            return
        end
        -- Profile strings starting with !NRSKNUI1! use LibDeflate format (in-game export).
        -- Use NRSKNUI.ProfileManager:ImportProfile for this format.
        -- NorskenUIAPI:ImportProfile is a different API that expects raw Base64/CBOR (WagoUI format).
        local pm = NRSKNUI and NRSKNUI.ProfileManager
        if not (pm and pm.ImportProfile) then
            print("|cff00ff96JetUI|r NorskenUI: ProfileManager not available.")
            return
        end
        local ok, resultName = pm:ImportProfile(JetUI.NorskenUIProfileString, profileName)
        if not ok then
            print("|cff00ff96JetUI|r NorskenUI: import failed - " .. tostring(resultName))
            return
        end
        -- Activate the imported profile
        if NRSKNUI.db then
            NRSKNUI.db:SetProfile(resultName or profileName)
        end
        JetUIDB.InstalledVersions["NorskenUI"] = C_AddOns.GetAddOnMetadata("JetUI", "X-NorskenUI")
    else
        -- Activate only
        if NRSKNUI and NRSKNUI.db then
            NRSKNUI.db:SetProfile(profileName)
        end
    end
end
