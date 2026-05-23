function JetUI:ImportBigWigs(forceImport)
    if not C_AddOns.IsAddOnLoaded("BigWigs") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.BigWigsProfileString or JetUI.BigWigsProfileString == "PASTE_BIGWIGS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r BigWigs: no profile string set, skipping.")
            return
        end
        if not (BigWigsAPI and BigWigsAPI.RegisterProfile) then
            print("|cff00ff96JetUI|r BigWigs: BigWigsAPI not available.")
            return
        end
        -- RegisterProfile shows the BigWigs accept popup, then calls the callback on accept
        BigWigsAPI.RegisterProfile(profileName, JetUI.BigWigsProfileString, profileName, function()
            -- Activate via BigWigsLoader AceDB after user accepts
            if BigWigsLoader and BigWigsLoader.db then
                BigWigsLoader.db:SetProfile(profileName)
            end
        end)
        JetUIDB.InstalledVersions["BigWigs"] = C_AddOns.GetAddOnMetadata("JetUI", "X-BigWigs")
    else
        -- Just activate the profile
        if BigWigsLoader and BigWigsLoader.db then
            BigWigsLoader.db:SetProfile(profileName)
        end
    end
end
