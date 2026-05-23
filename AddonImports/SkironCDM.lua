-- local HEALER_SPECS defined here once SkironCDM API is known and profile activation is implemented

-- NOTE: "SkironCDM" addon name is unverified — no public source found.
-- Update this string once the correct addon name is confirmed.
function JetUI:ImportSkironCDM(forceImport)
    if not IsAddOnLoaded("SkironCDM") then return end
    if forceImport then
        -- SkironCDM API TBD. Check addon source for export/import functions.
        -- Once confirmed, import JetUI.SkironCDMProfileStrings here similarly to AyijeCDM.
        print("|cff00ff96JetUI|r SkironCDM: import not yet implemented. Check SkironCDM API.")
        -- Note: InstalledVersions NOT written until import is actually implemented
    end
    -- TODO: add profile activation (DPS/Healer based on spec) once API is known
end
