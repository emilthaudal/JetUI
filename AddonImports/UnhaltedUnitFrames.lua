function JetUI:ImportUnhaltedUnitFrames(forceImport)
    if not C_AddOns.IsAddOnLoaded("UnhaltedUnitFrames") then return end
    if forceImport then
        if not JetUI.UnhaltedUnitFramesProfileStrings then
            print("|cff00ff96JetUI|r UnhaltedUnitFrames: no profile strings set, skipping.")
            return
        end
        if not (UUFG and UUFG.ImportUUF) then
            print("|cff00ff96JetUI|r UnhaltedUnitFrames: UUFG not available.")
            return
        end
        local prefix = JetUI.profilePrefix or ""
        -- Import all profiles; UUFG:ImportUUF writes to UUF.db.profiles and calls UUF.db:SetProfile internally
        -- Import DPS last so it ends up as the active profile
        if JetUI.UnhaltedUnitFramesProfileStrings["JetUI Healer"] then
            local s = JetUI.UnhaltedUnitFramesProfileStrings["JetUI Healer"]
            if s ~= "" then UUFG:ImportUUF(s, prefix .. "JetUI Healer") end
        end
        if JetUI.UnhaltedUnitFramesProfileStrings["JetUI DPS"] then
            local s = JetUI.UnhaltedUnitFramesProfileStrings["JetUI DPS"]
            if s ~= "" then UUFG:ImportUUF(s, prefix .. "JetUI DPS") end
        end
        JetUIDB.InstalledVersions["UnhaltedUnitFrames"] = C_AddOns.GetAddOnMetadata("JetUI", "X-UnhaltedUnitFrames")
    else
        -- Activate only: switch to JetUI DPS profile
        -- UUFG has no SetProfile method; use AceDB directly
        local prefix = JetUI.profilePrefix or ""
        if UUF and UUF.db and UUF.db.SetProfile then
            UUF.db:SetProfile(prefix .. "JetUI DPS")
        end
    end
end
