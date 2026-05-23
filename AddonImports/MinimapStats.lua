function JetUI:ImportMinimapStats(forceImport)
    if not IsAddOnLoaded("MinimapStats") then return end
    if not JetUI.MinimapStatsProfileString then
        -- No profile string — show info step only, no import
        return
    end
    if forceImport then
        -- MinimapStats SavedVar structure TBD.
        print("|cff00ff96JetUI|r MinimapStats: import not yet implemented.")
        JetUIDB.InstalledVersions["MinimapStats"] = GetAddOnMetadata("JetUI", "X-MinimapStats")
    end
end
