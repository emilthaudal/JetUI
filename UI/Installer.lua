-- NUI v2 color palette (hardcoded — JetUI targets this specific setup)
local C = {
    bgDark      = { 0.015, 0.047, 0.062, 0.6 },
    bgMedium    = { 0.015, 0.047, 0.062, 0.8 },
    border      = { 0, 0, 0, 1 },
    accent      = { 0, 1, 0.588, 1 },
    textPrimary = { 0.95, 0.95, 0.95, 1 },
    textSecondary = { 0.70, 0.70, 0.70, 1 },
}

-- Font path: use Expressway from NorskenUI if available, else Blizzard default
local FONT = (IsAddOnLoaded and IsAddOnLoaded("NorskenUI"))
    and "Interface\\AddOns\\NorskenUI\\Media\\Fonts\\Expressway.TTF"
    or  "Fonts\\FRIZQT__.TTF"

-- Helper: add 4 pixel-perfect 1px border textures to a frame
local function AddBorders(f, r, g, b, a)
    r, g, b, a = r or 0, g or 0, b or 0, a or 1
    local function mkLine(subLayer)
        local t = f:CreateTexture(nil, "OVERLAY", nil, subLayer)
        t:SetColorTexture(r, g, b, a)
        t:SetTexelSnappingBias(0)
        t:SetSnapToPixelGrid(false)
        return t
    end
    local top    = mkLine(7) top:SetHeight(1)    top:SetPoint("TOPLEFT",f,"TOPLEFT",0,0)         top:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)
    local bot    = mkLine(7) bot:SetHeight(1)    bot:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)   bot:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,0)
    local left   = mkLine(7) left:SetWidth(1)    left:SetPoint("TOPLEFT",f,"TOPLEFT",0,0)        left:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)
    local right  = mkLine(7) right:SetWidth(1)   right:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)     right:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,0)
end

-- Helper: create a backdrop frame with solid bg + border
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

-- Installer state
JetUI.Installer = {}
local Installer = JetUI.Installer

local W, H         = 600, 420
local HEADER_H     = 35
local FOOTER_H     = 40
local CONTENT_H    = H - HEADER_H - FOOTER_H

-- Build the frame (hidden until shown)
local function BuildFrame()
    local f = MakeBackdropFrame("JetUIInstallerFrame", UIParent, W, H, C.bgDark)
    f:SetFrameStrata("DIALOG")
    f:SetPoint("CENTER")
    f:Hide()
    AddBorders(f, 0, 0, 0, 1)

    -- Header
    local header = MakeBackdropFrame(nil, f, W, HEADER_H, C.bgMedium)
    header:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    -- header bottom border
    local hBorder = header:CreateTexture(nil, "OVERLAY")
    hBorder:SetHeight(1) hBorder:SetColorTexture(0,0,0,1)
    hBorder:SetPoint("BOTTOMLEFT",header,"BOTTOMLEFT",0,0)
    hBorder:SetPoint("BOTTOMRIGHT",header,"BOTTOMRIGHT",0,0)

    local titleText = header:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(FONT, 16, "OUTLINE")
    titleText:SetTextColor(C.accent[1], C.accent[2], C.accent[3], C.accent[4])
    titleText:SetPoint("LEFT", header, "LEFT", 12, 0)
    titleText:SetText("JetUI")

    local stepText = header:CreateFontString(nil, "OVERLAY")
    stepText:SetFont(FONT, 12, "OUTLINE")
    stepText:SetTextColor(C.textSecondary[1], C.textSecondary[2], C.textSecondary[3], C.textSecondary[4])
    stepText:SetPoint("RIGHT", header, "RIGHT", -12, 0)
    Installer.stepText = stepText

    -- Content area
    local content = MakeBackdropFrame(nil, f, W, CONTENT_H, C.bgDark)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    content:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, 0)
    Installer.content = content

    -- Addon name label (import steps)
    local addonLabel = content:CreateFontString(nil, "OVERLAY")
    addonLabel:SetFont(FONT, 16, "OUTLINE")
    addonLabel:SetTextColor(C.accent[1], C.accent[2], C.accent[3], C.accent[4])
    addonLabel:SetPoint("CENTER", content, "CENTER", 0, 30)
    Installer.addonLabel = addonLabel

    -- Status text
    local statusLabel = content:CreateFontString(nil, "OVERLAY")
    statusLabel:SetFont(FONT, 12, "OUTLINE")
    statusLabel:SetTextColor(C.textSecondary[1], C.textSecondary[2], C.textSecondary[3], C.textSecondary[4])
    statusLabel:SetPoint("CENTER", content, "CENTER", 0, 0)
    Installer.statusLabel = statusLabel

    -- Footer
    local footer = MakeBackdropFrame(nil, f, W, FOOTER_H, C.bgMedium)
    footer:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    footer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    -- footer top border
    local fBorder = footer:CreateTexture(nil, "OVERLAY")
    fBorder:SetHeight(1) fBorder:SetColorTexture(0,0,0,1)
    fBorder:SetPoint("TOPLEFT",footer,"TOPLEFT",0,0)
    fBorder:SetPoint("TOPRIGHT",footer,"TOPRIGHT",0,0)

    -- Helper: create a styled button
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
        AddBorders(btn, 0, 0, 0, 1)

        local lbl = btn:CreateFontString(nil, "OVERLAY")
        lbl:SetFont(FONT, 12, "OUTLINE")
        lbl:SetTextColor(C.accent[1], C.accent[2], C.accent[3], C.accent[4])
        lbl:SetPoint("CENTER")
        lbl:SetText(label)

        -- Hover: animate border to accent color over 0.18s
        local hoverProgress = 0
        btn:SetScript("OnUpdate", function(self, elapsed)
            local target = self.isHovered and 1 or 0
            hoverProgress = hoverProgress + (target - hoverProgress) * math.min(elapsed / 0.18, 1)
            local r = hoverProgress * C.accent[1]
            local g = hoverProgress * C.accent[2]
            local b = hoverProgress * C.accent[3]
            self:SetBackdropBorderColor(r, g, b, 1)
        end)
        btn:SetScript("OnEnter", function(self) self.isHovered = true end)
        btn:SetScript("OnLeave", function(self) self.isHovered = false end)

        return btn
    end

    local nextBtn = MakeButton("Next", footer, 80, 24)
    nextBtn:SetPoint("BOTTOMRIGHT", footer, "BOTTOMRIGHT", -10, 8)
    Installer.nextBtn = nextBtn

    local backBtn = MakeButton("Back", footer, 80, 24)
    backBtn:SetPoint("RIGHT", nextBtn, "LEFT", -8, 0)
    Installer.backBtn = backBtn

    Installer.frame = f
end

-- Show a step
local function ShowStep(index, pages)
    local page = pages[index]
    if not page then return end
    Installer.stepText:SetText("Step " .. index .. " of " .. #pages)
    Installer.addonLabel:SetText(page.title or "")
    Installer.statusLabel:SetText(page.status or "")

    -- Back button
    Installer.backBtn:SetEnabled(index > 1)
    Installer.backBtn:SetAlpha(index > 1 and 1 or 0.3)

    -- Next/Finish label
    local isLast = (index == #pages)
    -- find nextBtn label fontstring
    for _, child in pairs({Installer.nextBtn:GetRegions()}) do
        if child:GetObjectType() == "FontString" then
            child:SetText(isLast and "Finish" or "Next")
        end
    end

    -- Run the page's OnShow if present
    if page.OnShow then page.OnShow() end
end

-- Public: queue and open the installer with a list of page tables
-- Each page: { title = "...", status = "...", OnShow = function() end, import = function() end }
function Installer:Open(pages)
    if not Installer.frame then BuildFrame() end
    Installer.pages   = pages
    Installer.current = 1

    Installer.nextBtn:SetScript("OnClick", function()
        local page = pages[Installer.current]
        if page and page.import then
            page.import()
            page.status = "Done!"
            Installer.statusLabel:SetText("Done!")
        end
        if Installer.current < #pages then
            Installer.current = Installer.current + 1
            ShowStep(Installer.current, pages)
        else
            Installer.frame:Hide()
            JetUI:FinishInstallation()
        end
    end)

    Installer.backBtn:SetScript("OnClick", function()
        if Installer.current > 1 then
            Installer.current = Installer.current - 1
            ShowStep(Installer.current, pages)
        end
    end)

    ShowStep(1, pages)
    Installer.frame:Show()
end
