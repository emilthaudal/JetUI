function JetUI:ImportGrid2(forceImport)
    if not IsAddOnLoaded("Grid2") then return end
    if forceImport then
        if not JetUI.Grid2ProfileStrings then
            print("|cff00ff96JetUI|r Grid2: no profile strings set, skipping.")
            return
        end
        if not (Grid2ProfileAPI and Grid2ProfileAPI.ImportProfile) then
            print("|cff00ff96JetUI|r Grid2: Grid2ProfileAPI not available.")
            return
        end
        local prefix = JetUI.profilePrefix or ""
        for profileKey, profileString in pairs(JetUI.Grid2ProfileStrings) do
            if profileString and profileString ~= "" then
                Grid2ProfileAPI:ImportProfile(profileString, prefix .. profileKey)
            end
        end
        -- Set DPS profile active by default
        if Grid2ProfileAPI.SetProfile and JetUI.Grid2ProfileStrings["JetUI DPS"] then
            Grid2ProfileAPI:SetProfile(prefix .. "JetUI DPS")
        end
        JetUIDB.InstalledVersions["Grid2"] = GetAddOnMetadata("JetUI", "X-Grid2")
        -- Grid2 requires a reload after import
        C_UI.Reload()
    end
end
