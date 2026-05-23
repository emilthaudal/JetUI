function JetUI:ImportBuffReminders(forceImport)
    if not C_AddOns.IsAddOnLoaded("BuffReminders") then return end
    local profileName = (JetUI.profilePrefix or "") .. "JetUI"
    if forceImport then
        if not JetUI.BuffRemindersProfileString or JetUI.BuffRemindersProfileString == "PASTE_BUFF_REMINDERS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r BuffReminders: no profile string set, skipping.")
            return
        end
        BuffRemindersAPI:ImportProfile(JetUI.BuffRemindersProfileString, profileName)
        JetUIDB.InstalledVersions["BuffReminders"] = C_AddOns.GetAddOnMetadata("JetUI", "X-BuffReminders")
    end
    BuffRemindersAPI:SetProfile(profileName)
end
