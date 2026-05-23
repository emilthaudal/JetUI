-- NUI v2 color palette (hardcoded — JetUI targets this specific setup)
local C = {
    bgDark        = { 0.015, 0.047, 0.062, 0.96 },
    bgMedium      = { 0.020, 0.060, 0.078, 1.0  },
    bgSidebar     = { 0.010, 0.035, 0.048, 1.0  },
    border        = { 0, 0, 0, 1 },
    accent        = { 0, 1, 0.588, 1 },
    accentDim     = { 0, 0.35, 0.21, 1 },
    textPrimary   = { 0.95, 0.95, 0.95, 1 },
    textSecondary = { 0.60, 0.60, 0.60, 1 },
    textDisabled  = { 0.35, 0.35, 0.35, 1 },
    sidebarActive = { 0.015, 0.12, 0.09, 1 },
}

local FONT = C_AddOns.IsAddOnLoaded("NorskenUI")
    and "Interface\\AddOns\\NorskenUI\\Media\\Fonts\\Expressway.TTF"
    or  "Fonts\\FRIZQT__.TTF"

-- Helper: pixel-perfect 1px borders on a frame
local function AddBorders(f, r, g, b, a)
    r, g, b, a = r or 0, g or 0, b or 0, a or 1
    local function mkLine(subLayer)
        local t = f:CreateTexture(nil, "OVERLAY", nil, subLayer)
        t:SetColorTexture(r, g, b, a)
        t:SetTexelSnappingBias(0)
        t:SetSnapToPixelGrid(false)
        return t
    end
    local top   = mkLine(7); top:SetHeight(1);   top:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);          top:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)
    local bot   = mkLine(7); bot:SetHeight(1);   bot:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0);    bot:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,0)
    local left  = mkLine(7); left:SetWidth(1);   left:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);         left:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)
    local right = mkLine(7); right:SetWidth(1);  right:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0);      right:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,0)
end

local function MakeBackdropFrame(name, parent, w, h, bgColor)
    local f = CreateFrame("Frame", name, parent, "BackdropTemplate")
    f:SetSize(w, h)
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    f:SetBackdropBorderColor(0, 0, 0, 1)
    return f
end

local function MakeButton(label, parent, w, h)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w, h)
    btn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    btn:SetBackdropColor(C.bgMedium[1], C.bgMedium[2], C.bgMedium[3], C.bgMedium[4])
    btn:SetBackdropBorderColor(0, 0, 0, 1)

    local lbl = btn:CreateFontString(nil, "OVERLAY")
    lbl:SetFont(FONT, 12, "OUTLINE")
    lbl:SetTextColor(C.accent[1], C.accent[2], C.accent[3])
    lbl:SetPoint("CENTER")
    lbl:SetText(label)
    btn.label = lbl

    local hoverP = 0
    btn:SetScript("OnUpdate", function(self, elapsed)
        if self.disabled then return end
        local target = self.isHovered and 1 or 0
        hoverP = hoverP + (target - hoverP) * math.min(elapsed / 0.18, 1)
        self:SetBackdropBorderColor(
            hoverP * C.accent[1],
            hoverP * C.accent[2],
            hoverP * C.accent[3], 1)
    end)
    btn:SetScript("OnEnter", function(self) if not self.disabled then self.isHovered = true end end)
    btn:SetScript("OnLeave", function(self) self.isHovered = false end)

    function btn:Disable()
        self.disabled  = true
        self.isHovered = false
        self:SetBackdropBorderColor(0, 0, 0, 1)
        self.label:SetTextColor(C.textDisabled[1], C.textDisabled[2], C.textDisabled[3])
    end

    function btn:Enable()
        self.disabled = false
        self.label:SetTextColor(C.accent[1], C.accent[2], C.accent[3])
    end

    return btn
end

-- ── Installer state ───────────────────────────────────────────────────────────
JetUI = JetUI or {}
JetUI.Installer = JetUI.Installer or {}
local Installer = JetUI.Installer

local W            = 640
local H            = 440
local HEADER_H     = 36
local FOOTER_H     = 42
local SIDEBAR_W    = 148
local CONTENT_H    = H - HEADER_H - FOOTER_H
local MAIN_W       = W - SIDEBAR_W

-- ── BuildFrame ────────────────────────────────────────────────────────────────
local function BuildFrame()
    local f = MakeBackdropFrame("JetUIInstallerFrame", UIParent, W, H, C.bgDark)
    f:SetFrameStrata("DIALOG")
    f:SetPoint("CENTER")
    f:Hide()
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)

    -- ── Header ────────────────────────────────────────────────────────────────
    local header = MakeBackdropFrame(nil, f, W, HEADER_H, C.bgMedium)
    header:SetPoint("TOPLEFT",  f, "TOPLEFT",  0, 0)
    header:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    local hBorder = header:CreateTexture(nil, "OVERLAY")
    hBorder:SetHeight(1); hBorder:SetColorTexture(0,0,0,1)
    hBorder:SetPoint("BOTTOMLEFT",  header, "BOTTOMLEFT",  0, 0)
    hBorder:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)

    local titleText = header:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(FONT, 16, "OUTLINE")
    titleText:SetTextColor(C.accent[1], C.accent[2], C.accent[3])
    titleText:SetPoint("LEFT", header, "LEFT", 14, 0)
    titleText:SetText("JetUI")

    local stepText = header:CreateFontString(nil, "OVERLAY")
    stepText:SetFont(FONT, 11, "OUTLINE")
    stepText:SetTextColor(C.textSecondary[1], C.textSecondary[2], C.textSecondary[3])
    stepText:SetPoint("RIGHT", header, "RIGHT", -14, 0)
    Installer.stepText = stepText

    -- ── Content row (main + sidebar) ──────────────────────────────────────────
    local contentRow = CreateFrame("Frame", nil, f)
    contentRow:SetPoint("TOPLEFT",     header, "BOTTOMLEFT",  0,  0)
    contentRow:SetPoint("BOTTOMRIGHT", f,      "BOTTOMRIGHT", 0, FOOTER_H)

    -- Main content pane
    local main = MakeBackdropFrame(nil, contentRow, MAIN_W, CONTENT_H, C.bgDark)
    main:SetPoint("TOPLEFT",    contentRow, "TOPLEFT",    0, 0)
    main:SetPoint("BOTTOMLEFT", contentRow, "BOTTOMLEFT", 0, 0)

    -- Vertical divider between main and sidebar
    local divider = contentRow:CreateTexture(nil, "OVERLAY")
    divider:SetWidth(1)
    divider:SetColorTexture(0, 0, 0, 1)
    divider:SetPoint("TOPLEFT",    contentRow, "TOPLEFT",    MAIN_W, 0)
    divider:SetPoint("BOTTOMLEFT", contentRow, "BOTTOMLEFT", MAIN_W, 0)

    -- Sidebar pane
    local sidebar = MakeBackdropFrame(nil, contentRow, SIDEBAR_W, CONTENT_H, C.bgSidebar)
    sidebar:SetPoint("TOPRIGHT",    contentRow, "TOPRIGHT",    0, 0)
    sidebar:SetPoint("BOTTOMRIGHT", contentRow, "BOTTOMRIGHT", 0, 0)

    -- ── Main content widgets ──────────────────────────────────────────────────
    local addonLabel = main:CreateFontString(nil, "OVERLAY")
    addonLabel:SetFont(FONT, 18, "OUTLINE")
    addonLabel:SetTextColor(C.accent[1], C.accent[2], C.accent[3])
    addonLabel:SetPoint("TOP", main, "TOP", 0, -32)
    addonLabel:SetJustifyH("CENTER")
    Installer.addonLabel = addonLabel

    local statusLabel = main:CreateFontString(nil, "OVERLAY")
    statusLabel:SetFont(FONT, 12, "OUTLINE")
    statusLabel:SetTextColor(C.textSecondary[1], C.textSecondary[2], C.textSecondary[3])
    statusLabel:SetPoint("CENTER", main, "CENTER", 0, 10)
    statusLabel:SetJustifyH("CENTER")
    statusLabel:SetWidth(MAIN_W - 32)
    statusLabel:SetWordWrap(true)
    Installer.statusLabel = statusLabel

    -- Import / Reload button (centered, lower half of main pane)
    local importBtn = MakeButton("Import", main, 130, 28)
    importBtn:SetPoint("CENTER", main, "CENTER", 0, -38)
    Installer.importBtn = importBtn

    -- ── Sidebar header label ──────────────────────────────────────────────────
    local sidebarTitle = sidebar:CreateFontString(nil, "OVERLAY")
    sidebarTitle:SetFont(FONT, 10, "OUTLINE")
    sidebarTitle:SetTextColor(C.textSecondary[1], C.textSecondary[2], C.textSecondary[3])
    sidebarTitle:SetPoint("TOP", sidebar, "TOP", 0, -8)
    sidebarTitle:SetText("ADDONS")

    local sTitleLine = sidebar:CreateTexture(nil, "OVERLAY")
    sTitleLine:SetHeight(1); sTitleLine:SetColorTexture(0, 0, 0, 0.6)
    sTitleLine:SetPoint("TOPLEFT",  sidebar, "TOPLEFT",  4, -20)
    sTitleLine:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", -4, -20)

    Installer.sidebar       = sidebar
    Installer.sidebarTitle  = sidebarTitle
    Installer.sidebarBtns   = {}

    -- ── Footer ────────────────────────────────────────────────────────────────
    local footer = MakeBackdropFrame(nil, f, W, FOOTER_H, C.bgMedium)
    footer:SetPoint("BOTTOMLEFT",  f, "BOTTOMLEFT",  0, 0)
    footer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    local fBorder = footer:CreateTexture(nil, "OVERLAY")
    fBorder:SetHeight(1); fBorder:SetColorTexture(0,0,0,1)
    fBorder:SetPoint("TOPLEFT",  footer, "TOPLEFT",  0, 0)
    fBorder:SetPoint("TOPRIGHT", footer, "TOPRIGHT", 0, 0)

    local nextBtn = MakeButton("Next", footer, 86, 26)
    nextBtn:SetPoint("BOTTOMRIGHT", footer, "BOTTOMRIGHT", -12, 10)
    Installer.nextBtn = nextBtn

    local backBtn = MakeButton("Back", footer, 86, 26)
    backBtn:SetPoint("RIGHT", nextBtn, "LEFT", -8, 0)
    Installer.backBtn = backBtn

    Installer.frame = f
end

-- ── Sidebar population ────────────────────────────────────────────────────────
local function BuildSidebar(pages)
    -- Clear old buttons
    for _, btn in ipairs(Installer.sidebarBtns) do btn:Hide() end
    Installer.sidebarBtns = {}

    -- Collect only addon pages (those with an import function)
    -- We store their original page index so clicking jumps correctly
    local ROW_H   = 24
    local PADDING = 6
    local yOff    = -26

    for i, page in ipairs(pages) do
        if page.sidebarLabel then
            local row = CreateFrame("Button", nil, Installer.sidebar)
            row:SetSize(SIDEBAR_W - 2, ROW_H)
            row:SetPoint("TOPLEFT", Installer.sidebar, "TOPLEFT", 1, yOff)

            -- Background texture (hidden by default, shown when active)
            local bg = row:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(C.sidebarActive[1], C.sidebarActive[2], C.sidebarActive[3], C.sidebarActive[4])
            bg:Hide()
            row.bg = bg

            -- Left accent bar (shown when active)
            local accent = row:CreateTexture(nil, "OVERLAY")
            accent:SetWidth(2)
            accent:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 1)
            accent:SetPoint("TOPLEFT",    row, "TOPLEFT",    0, 0)
            accent:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
            accent:Hide()
            row.accent = accent

            local lbl = row:CreateFontString(nil, "OVERLAY")
            lbl:SetFont(FONT, 11, "OUTLINE")
            lbl:SetTextColor(C.textSecondary[1], C.textSecondary[2], C.textSecondary[3])
            lbl:SetPoint("LEFT", row, "LEFT", 10, 0)
            lbl:SetText(page.sidebarLabel)
            row.lbl = lbl

            -- Check mark (shown after import)
            local check = row:CreateFontString(nil, "OVERLAY")
            check:SetFont(FONT, 10, "OUTLINE")
            check:SetTextColor(C.accent[1], C.accent[2], C.accent[3])
            check:SetPoint("RIGHT", row, "RIGHT", -6, 0)
            check:SetText("✓")
            check:Hide()
            row.check = check

            local pageIndex = i
            row:SetScript("OnClick", function()
                Installer.current = pageIndex
                Installer:ShowStep(pageIndex)
            end)
            row:SetScript("OnEnter", function(self)
                if not self.isActive then
                    self.lbl:SetTextColor(C.textPrimary[1], C.textPrimary[2], C.textPrimary[3])
                end
            end)
            row:SetScript("OnLeave", function(self)
                if not self.isActive then
                    self.lbl:SetTextColor(C.textSecondary[1], C.textSecondary[2], C.textSecondary[3])
                end
            end)

            row.pageIndex = pageIndex
            table.insert(Installer.sidebarBtns, row)
            yOff = yOff - ROW_H - 1
        end
    end
end

-- ── ShowStep ──────────────────────────────────────────────────────────────────
function Installer:ShowStep(index)
    local pages = Installer.pages
    local page  = pages[index]
    if not page then return end

    -- Count only sidebar pages for the step display
    local addonCount = 0
    local addonIndex = 0
    for i, p in ipairs(pages) do
        if p.sidebarLabel then
            addonCount = addonCount + 1
            if i == index then addonIndex = addonCount end
        end
    end
    if addonIndex > 0 then
        Installer.stepText:SetText(addonIndex .. " / " .. addonCount)
    else
        Installer.stepText:SetText("")
    end

    Installer.addonLabel:SetText(page.title or "")
    Installer.statusLabel:SetText(page.status or "")

    -- Back button
    local canBack = (index > 1)
    Installer.backBtn:SetAlpha(canBack and 1 or 0.3)
    Installer.backBtn.disabled = not canBack

    -- Next / Finish label
    local isLast = (index == #pages)
    Installer.nextBtn.label:SetText(isLast and "Close" or "Next")

    -- Import button
    local importBtn = Installer.importBtn
    if page.isDone then
        -- Done page: show "Reload UI" button
        importBtn:Show()
        importBtn:Enable()
        importBtn.label:SetText("Reload UI")
        importBtn:SetScript("OnClick", function()
            JetUI:FinishInstallation()
        end)
    elseif page.import then
        importBtn:Show()
        if page.imported then
            importBtn:Disable()
            importBtn.label:SetText("Imported ✓")
        else
            importBtn:Enable()
            importBtn.label:SetText("Import")
            importBtn:SetScript("OnClick", function()
                page.import()
                page.imported = true
                importBtn:Disable()
                importBtn.label:SetText("Imported ✓")
                Installer.statusLabel:SetText("Profile imported successfully.")
                -- Update sidebar checkmark
                for _, btn in ipairs(Installer.sidebarBtns) do
                    if btn.pageIndex == index then
                        btn.check:Show()
                    end
                end
            end)
        end
    else
        importBtn:Hide()
    end

    -- Sidebar: update active highlight
    for _, btn in ipairs(Installer.sidebarBtns) do
        local isActive = (btn.pageIndex == index)
        btn.isActive = isActive
        btn.bg:SetShown(isActive)
        btn.accent:SetShown(isActive)
        if isActive then
            btn.lbl:SetTextColor(C.accent[1], C.accent[2], C.accent[3])
        else
            btn.lbl:SetTextColor(C.textSecondary[1], C.textSecondary[2], C.textSecondary[3])
        end
    end

    -- Run page OnShow callback if present
    if page.OnShow then page.OnShow() end
end

-- ── Open ──────────────────────────────────────────────────────────────────────
function Installer:Open(pages)
    if not Installer.frame then BuildFrame() end

    -- Reset imported state on all pages
    for _, p in ipairs(pages) do p.imported = nil end

    Installer.pages   = pages
    Installer.current = 1

    BuildSidebar(pages)

    Installer.nextBtn:SetScript("OnClick", function()
        if Installer.current < #pages then
            Installer.current = Installer.current + 1
            Installer:ShowStep(Installer.current)
        else
            Installer.frame:Hide()
        end
    end)

    Installer.backBtn:SetScript("OnClick", function()
        if Installer.current > 1 then
            Installer.current = Installer.current - 1
            Installer:ShowStep(Installer.current)
        end
    end)

    Installer:ShowStep(1)
    Installer.frame:Show()
end
