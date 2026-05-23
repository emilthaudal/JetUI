function JetUI:ImportBigWigs(forceImport)
    if not IsAddOnLoaded("BigWigs") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.BigWigsProfileString or JetUI.BigWigsProfileString == "PASTE_BIGWIGS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r BigWigs: no profile string set, skipping.")
            return
        end
        BigWigsAPI.RegisterProfile(profileName, JetUI.BigWigsProfileString, profileName, function()
            BigWigsAPI.SetProfile(profileName)
            JetUIDB.InstalledVersions["BigWigs"] = GetAddOnMetadata("JetUI", "X-BigWigs")
        end)
    else
        BigWigsAPI.SetProfile(profileName)
    end
end
