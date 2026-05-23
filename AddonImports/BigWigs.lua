function JetUI:ImportBigWigs(forceImport)
    if not IsAddOnLoaded("BigWigs") then return end
    if forceImport then
        if not JetUI.BigWigsProfileString or JetUI.BigWigsProfileString == "PASTE_BIGWIGS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r BigWigs: no profile string set, skipping.")
            return
        end
        BigWigsAPI.RegisterProfile("JetUI", JetUI.BigWigsProfileString, "JetUI", function()
            BigWigsAPI.SetProfile("JetUI")
            JetUIDB.InstalledVersions["BigWigs"] = GetAddOnMetadata("JetUI", "X-BigWigs")
        end)
    else
        BigWigsAPI.SetProfile("JetUI")
    end
end
