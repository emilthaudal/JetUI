function JetUI:ImportMinimapStats(forceImport)
    if not IsAddOnLoaded("MinimapStats") then return end
    if not JetUI.MinimapStatsProfileString then
        -- No profile string — no import. Mark as configured so the installer
        -- doesn't prompt on every run (manual configuration only).
        if forceImport then
            JetUIDB.InstalledVersions["MinimapStats"] = GetAddOnMetadata("JetUI", "X-MinimapStats")
        end
        return
    end
    if forceImport then
        -- MinimapStats SavedVar structure TBD.
        print("|cff00ff96JetUI|r MinimapStats: import not yet implemented.")
        -- Note: InstalledVersions NOT written until import is actually implemented
    end
end
