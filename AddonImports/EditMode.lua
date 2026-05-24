function JetUI:ImportEditMode(forceImport)
    if InCombatLockdown and InCombatLockdown() then return end

    local LAYOUT_NAME = (JetUI.profilePrefix or "") .. "JetUI"
    local layoutsInfo = C_EditMode.GetLayouts()
    layoutsInfo.layouts = layoutsInfo.layouts or {}

    local customIndex

    if forceImport then
        if not JetUI.EditModeProfileString or JetUI.EditModeProfileString == "PASTE_EDITMODE_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r EditMode: no profile string set, skipping.")
            return
        end

        local layoutInfo = C_EditMode.ConvertStringToLayoutInfo(JetUI.EditModeProfileString)
        if not layoutInfo then return end

        layoutInfo.layoutName = LAYOUT_NAME
        layoutInfo.layoutType = Enum.EditModeLayoutType.Account

        for i, layout in ipairs(layoutsInfo.layouts) do
            if layout.layoutName == LAYOUT_NAME then
                layoutsInfo.layouts[i] = layoutInfo
                customIndex = i
                break
            end
        end

        if not customIndex then
            if #layoutsInfo.layouts >= 5 then
                UIErrorsFrame:AddMessage("Edit Mode layout limit reached (5). Delete a layout and try again.", 1, 0.2, 0.2)
                return
            end
            table.insert(layoutsInfo.layouts, layoutInfo)
            customIndex = #layoutsInfo.layouts
        end

        C_EditMode.SaveLayouts(layoutsInfo)
        JetUIDB.InstalledVersions["EditMode"] = C_AddOns.GetAddOnMetadata("JetUI", "X-EditMode")
    else
        for i, layout in ipairs(layoutsInfo.layouts) do
            if layout.layoutName == LAYOUT_NAME then
                customIndex = i
                break
            end
        end
        if not customIndex then return end
    end

    local activeIndex = Enum.EditModePresetLayoutsMeta.NumValues + customIndex
    C_EditMode.SetActiveLayout(activeIndex)
end
