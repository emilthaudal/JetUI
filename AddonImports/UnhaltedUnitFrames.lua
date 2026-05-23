function JetUI:ImportUnhaltedUnitFrames(forceImport)
    if not C_AddOns.IsAddOnLoaded("UnhaltedUnitFrames") then return end
    if forceImport then
        if not JetUI.UnhaltedUnitFramesProfileStrings then
            print("|cff00ff96JetUI|r UnhaltedUnitFrames: no profile strings set, skipping.")
            return
        end
        if not (UUFG and UUFG.ImportUUF) then
            print("|cff00ff96JetUI|r UnhaltedUnitFrames: UUFG not available.")
            return
        end
        local prefix = JetUI.profilePrefix or ""
        for profileKey, profileString in pairs(JetUI.UnhaltedUnitFramesProfileStrings) do
            if profileString and profileString ~= "" then
                UUFG:ImportUUF(profileString, prefix .. profileKey)
            end
        end
        -- Set DPS profile active by default
        if UUFDB and UUFDB.profileKeys then
            local charName = UnitName("player") .. "-" .. GetRealmName()
            UUFDB.profileKeys[charName] = prefix .. "JetUI DPS"
        end
        JetUIDB.InstalledVersions["UnhaltedUnitFrames"] = C_AddOns.GetAddOnMetadata("JetUI", "X-UnhaltedUnitFrames")
        -- UUF requires a reload after import
        C_UI.Reload()
    end
end
