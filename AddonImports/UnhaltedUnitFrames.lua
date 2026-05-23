function JetUI:ImportUnhaltedUnitFrames(forceImport)
    if not IsAddOnLoaded("UnhaltedUnitFrames") then return end
    if forceImport then
        if not JetUI.UnhaltedUnitFramesProfileString or JetUI.UnhaltedUnitFramesProfileString == "PASTE_UNHALTED_UNIT_FRAMES_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r UnhaltedUnitFrames: no profile string set, skipping.")
            return
        end
        -- UnhaltedUnitFrames SavedVar structure TBD.
        -- Confirm with: /run DevTools_Dump(UnhaltedUnitFramesDB)  (check the actual SavedVariables name in its TOC)
        print("|cff00ff96JetUI|r UnhaltedUnitFrames: import not yet implemented.")
        -- Note: InstalledVersions NOT written until import is actually implemented
    end
end
