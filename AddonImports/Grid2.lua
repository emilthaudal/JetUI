local function DoGrid2Import()
    -- Full LAP-style guards: addon loaded + all required globals present
    if not C_AddOns.IsAddOnLoaded("Grid2") then return false end
    if not (Grid2ProfileAPI and Grid2ProfileAPI.ImportProfile) then return false end
    if not (Grid2 and Grid2.ImportProfileIntoKey and Grid2.ExportProfileByKey and Grid2.UnserializeProfile) then return false end
    return true
end

function JetUI:ImportGrid2(forceImport)
    if not C_AddOns.IsAddOnLoaded("Grid2") then return end

    if forceImport then
        if not JetUI.Grid2ProfileStrings then
            print("|cff00ff96JetUI|r Grid2: no profile strings set, skipping.")
            return
        end

        local function DoImportNow()
            local prefix = JetUI.profilePrefix or ""
            for profileKey, profileString in pairs(JetUI.Grid2ProfileStrings) do
                if profileString and profileString ~= "" then
                    Grid2ProfileAPI:ImportProfile(profileString, prefix .. profileKey)
                end
            end
            if Grid2ProfileAPI.SetProfile and JetUI.Grid2ProfileStrings["JetUI DPS"] then
                Grid2ProfileAPI:SetProfile(prefix .. "JetUI DPS")
            end
            JetUIDB.InstalledVersions["Grid2"] = C_AddOns.GetAddOnMetadata("JetUI", "X-Grid2")
        end

        local function TryImport()
            if not DoGrid2Import() then
                -- Grid2 addon may be loaded but Grid2ProfileAPI (from Grid2Options) isn't ready yet.
                -- Keep listening on ADDON_LOADED until all required globals are present.
                local retryFrame = CreateFrame("Frame")
                retryFrame:RegisterEvent("ADDON_LOADED")
                retryFrame:SetScript("OnEvent", function(self, event, addonName)
                    if DoGrid2Import() then
                        self:UnregisterAllEvents()
                        DoImportNow()
                    end
                end)
                return
            end
            DoImportNow()
        end

        TryImport()
    else
        -- Activate only: switch to JetUI DPS profile if API is ready
        if DoGrid2Import() and Grid2ProfileAPI.SetProfile then
            local prefix = JetUI.profilePrefix or ""
            Grid2ProfileAPI:SetProfile(prefix .. "JetUI DPS")
        end
    end
end
