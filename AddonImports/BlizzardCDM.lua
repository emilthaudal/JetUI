-- AddonImports/BlizzardCDM.lua

-- Returns the classAndSpecTag for the player's currently active spec.
local function GetCurrentSpecTag()
    if CooldownViewerUtil and CooldownViewerUtil.GetCurrentClassAndSpecTag then
        return CooldownViewerUtil.GetCurrentClassAndSpecTag()
    end
    -- Fallback: spec ID == tag for most classes (CooldownViewerUtil not available)
    print("|cff00ff96JetUI|r BlizzardCDM: CooldownViewerUtil not available, using specID fallback.")
    local specID = GetSpecializationInfo(GetSpecialization() or 1)
    return specID
end

-- Returns a sorted list of CDM tag integers for every spec of the player's class.
-- Uses the current CDM tag to find class group (same tens digit).
local function GetClassSpecTags()
    local currentTag = GetCurrentSpecTag()
    if not currentTag then return {} end
    local classGroup = math.floor(currentTag / 10)
    local tags = {}
    for tag, _ in pairs(JetUI.BlizzardCDMProfiles or {}) do
        if math.floor(tag / 10) == classGroup then
            table.insert(tags, tag)
        end
    end
    table.sort(tags)
    return tags
end

-- Returns {cdmTag, label} pairs for all specs of the player's current class.
-- Used by JetUI.lua to build spec import buttons.
function JetUI.GetBlizzardCDMSpecsForPlayer()
    local tags = GetClassSpecTags()
    local result = {}
    for _, tag in ipairs(tags) do
        local entry = (JetUI.BlizzardCDMProfiles or {})[tag]
        local label = entry and entry.profileKey:gsub("^JetUI %- ", "") or tostring(tag)
        table.insert(result, { cdmTag = tag, label = label })
    end
    return result
end

-- Import and activate a single spec's profile. specTag is a classAndSpecTag integer.
-- activate=true sets this layout as the active one after importing.
function JetUI:ImportBlizzardCDMSpec(specTag, activate)
    if not CooldownViewerSettings then
        print("|cff00ff96JetUI|r BlizzardCDM: addon not loaded.")
        return false
    end
    local entry = (JetUI.BlizzardCDMProfiles or {})[specTag]
    if not entry then
        print("|cff00ff96JetUI|r BlizzardCDM: no profile for specTag " .. tostring(specTag))
        return false
    end
    if not entry.profileString or entry.profileString:find("^PASTE_") then
        print("|cff00ff96JetUI|r BlizzardCDM: profile string not set for " .. entry.profileKey)
        return false
    end
    local prefix = JetUI.profilePrefix or ""
    local profileKey = prefix .. entry.profileKey
    local lm = CooldownViewerSettings:GetLayoutManager()
    if lm.AreLayoutsFullyMaxed and lm:AreLayoutsFullyMaxed() then
        print("|cff00ff96JetUI|r BlizzardCDM: layout slots full, cannot import " .. profileKey)
        return false
    end
    local layoutIDs = lm:CreateLayoutsFromSerializedData(entry.profileString)
    if layoutIDs and #layoutIDs > 0 then
        if lm.RenameLayout then lm:RenameLayout(layoutIDs[1], profileKey) end
        lm:SaveLayouts()
        if activate then
            lm:SetActiveLayoutByID(layoutIDs[1])
        end
        return true
    end
    print("|cff00ff96JetUI|r BlizzardCDM: import failed for " .. profileKey)
    return false
end

-- Import all specs for the player's current class and activate the current spec's profile.
function JetUI:ImportAllBlizzardCDM(forceImport)
    if not CooldownViewerSettings then
        print("|cff00ff96JetUI|r BlizzardCDM: addon not loaded.")
        return
    end
    local currentTag = GetCurrentSpecTag()
    if forceImport then
        local classTags = GetClassSpecTags()
        for _, tag in ipairs(classTags) do
            local isActive = (tag == currentTag)
            JetUI:ImportBlizzardCDMSpec(tag, isActive)
        end
        JetUIDB.InstalledVersions = JetUIDB.InstalledVersions or {}
        JetUIDB.InstalledVersions["BlizzardCDM"] = C_AddOns.GetAddOnMetadata("JetUI", "X-BlizzardCDM")
    else
        -- Activate mode: just set the active layout for this spec
        local entry = (JetUI.BlizzardCDMProfiles or {})[currentTag]
        if not entry then return end
        local prefix = JetUI.profilePrefix or ""
        local profileKey = prefix .. entry.profileKey
        local lm = CooldownViewerSettings:GetLayoutManager()
        local layouts = lm.GetLayouts and lm:GetLayouts() or {}
        for _, layout in ipairs(layouts) do
            if layout.name == profileKey then
                lm:SetActiveLayoutByID(layout.id)
                return
            end
        end
        print("|cff00ff96JetUI|r BlizzardCDM: profile not found for " .. profileKey .. ". Run /jetui install to import.")
    end
end
