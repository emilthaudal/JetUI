function JetUI:ImportBigWigs(forceImport)
    if not C_AddOns.IsAddOnLoaded("BigWigs") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.BigWigsProfileString or JetUI.BigWigsProfileString == "PASTE_BIGWIGS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r BigWigs: no profile string set, skipping.")
            return
        end
        -- BigWigs profile strings are LAP-encoded: LibDeflate:DecodeForPrint + DecompressDeflate + AceSerializer
        -- LibDeflate and AceSerializer-3.0 are guaranteed present when BigWigs is loaded
        local LD = LibStub and LibStub("LibDeflate", true)
        local AS = LibStub and LibStub("AceSerializer-3.0", true)
        if not LD or not AS then
            print("|cff00ff96JetUI|r BigWigs: LibDeflate or AceSerializer not available.")
            return
        end
        local decoded = LD:DecodeForPrint(JetUI.BigWigsProfileString)
        if not decoded then
            print("|cff00ff96JetUI|r BigWigs: failed to decode profile string.")
            return
        end
        local decompressed = LD:DecompressDeflate(decoded)
        if not decompressed then
            print("|cff00ff96JetUI|r BigWigs: failed to decompress profile string.")
            return
        end
        local ok, data = AS:Deserialize(decompressed)
        if not ok or type(data) ~= "table" then
            print("|cff00ff96JetUI|r BigWigs: failed to deserialize profile data.")
            return
        end
        -- data.d contains { profileKey, profile, moduleName } as encoded by LAP
        local pData = data.d and data.d[2] or data
        local bw3db = pData and pData.BigWigs3DB
        if not bw3db then
            print("|cff00ff96JetUI|r BigWigs: unexpected profile data structure.")
            return
        end
        -- Write namespaces
        if bw3db.namespaces then
            for nsKey, ns in pairs(bw3db.namespaces) do
                if ns.profiles then
                    for _, profile in pairs(ns.profiles) do
                        BigWigs3DB.namespaces = BigWigs3DB.namespaces or {}
                        BigWigs3DB.namespaces[nsKey] = BigWigs3DB.namespaces[nsKey] or {}
                        BigWigs3DB.namespaces[nsKey].profiles = BigWigs3DB.namespaces[nsKey].profiles or {}
                        BigWigs3DB.namespaces[nsKey].profiles[profileName] = profile
                    end
                end
            end
        end
        -- Write profile
        if bw3db.profiles then
            for _, profile in pairs(bw3db.profiles) do
                BigWigs3DB.profiles = BigWigs3DB.profiles or {}
                BigWigs3DB.profiles[profileName] = profile
            end
        end
        -- Assign profile to this character
        BigWigs3DB.profileKeys = BigWigs3DB.profileKeys or {}
        BigWigs3DB.profileKeys[UnitName("player") .. " - " .. GetRealmName()] = profileName
        -- Activate profile via BigWigsLoader AceDB
        if BigWigsLoader and BigWigsLoader.db then
            BigWigsLoader.db:SetProfile(profileName)
        end
        JetUIDB.InstalledVersions["BigWigs"] = C_AddOns.GetAddOnMetadata("JetUI", "X-BigWigs")
    else
        -- Just activate the profile
        if BigWigsLoader and BigWigsLoader.db then
            BigWigsLoader.db:SetProfile(profileName)
        end
    end
end
