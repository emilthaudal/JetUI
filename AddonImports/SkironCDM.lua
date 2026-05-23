local HEALER_SPECS = { [65]=true, [256]=true, [257]=true, [105]=true, [264]=true, [270]=true, [1468]=true }

function JetUI:ImportSkironCDM(forceImport)
    if not IsAddOnLoaded("SkironCDM") then return end
    if forceImport then
        -- SkironCDM API TBD. Check addon source for export/import functions.
        -- Once confirmed, import JetUI.SkironCDMProfileStrings here similarly to AyijeCDM.
        print("|cff00ff96JetUI|r SkironCDM: import not yet implemented. Check SkironCDM API.")
        JetUIDB.InstalledVersions["SkironCDM"] = GetAddOnMetadata("JetUI", "X-SkironCDM")
    end
end
