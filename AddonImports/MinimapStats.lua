function JetUI:ImportMinimapStats(forceImport)
    if not IsAddOnLoaded("MinimapStats") then return end
    if forceImport then
        if not JetUI.MinimapStatsProfileString or JetUI.MinimapStatsProfileString == "" then
            print("|cff00ff96JetUI|r MinimapStats: no profile string set, skipping.")
            return
        end
        if not (MSG and MSG.ImportSavedVariables) then
            print("|cff00ff96JetUI|r MinimapStats: MSG not available.")
            return
        end
        MSG:ImportSavedVariables(JetUI.MinimapStatsProfileString)
        JetUIDB.InstalledVersions["MinimapStats"] = GetAddOnMetadata("JetUI", "X-MinimapStats")
        -- MinimapStats does NOT require a reload
    end
end
