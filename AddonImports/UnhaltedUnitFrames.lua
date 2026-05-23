function JetUI:ImportUnhaltedUnitFrames(forceImport)
    if not IsAddOnLoaded("UnhaltedUnitFrames") then return end
    if not JetUI.UnhaltedUnitFramesProfileString or JetUI.UnhaltedUnitFramesProfileString == "PASTE_UNHALTED_UNIT_FRAMES_PROFILE_STRING_HERE" then
        print("|cff00ff96JetUI|r UnhaltedUnitFrames: no profile string set, skipping.")
        return
    end
    if forceImport then
        -- UnhaltedUnitFrames SavedVar structure TBD.
        -- Confirm with: /run DevTools_Dump(UnhaltedUnitFramesDB)  (check the actual SavedVariables name in its TOC)
        print("|cff00ff96JetUI|r UnhaltedUnitFrames: import not yet implemented.")
        JetUIDB.InstalledVersions["UnhaltedUnitFrames"] = GetAddOnMetadata("JetUI", "X-UnhaltedUnitFrames")
    end
end
