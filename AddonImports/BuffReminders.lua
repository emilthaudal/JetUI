function JetUI:ImportBuffReminders(forceImport)
    if not IsAddOnLoaded("BuffReminders") then return end
    if forceImport then
        if not JetUI.BuffRemindersProfileString or JetUI.BuffRemindersProfileString == "PASTE_BUFF_REMINDERS_PROFILE_STRING_HERE" then
            print("|cff00ff96JetUI|r BuffReminders: no profile string set, skipping.")
            return
        end
        BuffRemindersAPI:ImportProfile(JetUI.BuffRemindersProfileString, "JetUI")
        JetUIDB.InstalledVersions["BuffReminders"] = GetAddOnMetadata("JetUI", "X-BuffReminders")
    end
    BuffRemindersAPI:SetProfile("JetUI")
end
