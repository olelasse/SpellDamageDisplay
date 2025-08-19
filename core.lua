local addonName = "SpellDamageDisplay"
local addon = CreateFrame("Frame", addonName)

local damageLabels = {}
local updateTimer = 0.5 -- How often to update the display, in seconds
local lastUpdate = 0

-- A helper function to create or get the damage label for an action button
local function GetOrCreateDamageLabel(button)
    local label = damageLabels[button]
    if not label then
        label = button:CreateFontString(nil, "OVERLAY")
        label:SetFont(STANDARD_TEXT_FONT, 8, "OUTLINE")
        label:SetWidth(button:GetWidth())
        label:SetJustifyH("CENTER")
        label:SetPoint("BOTTOM", 0, 5)
        label:SetTextColor(1, 1, 0)
        damageLabels[button] = label
    end
    return label
end

-- The core logic to get damage from a spell's tooltip
local function GetSpellDamage(spellID)
    local tooltip = CreateFrame("GameTooltip", "LocalSpellDamageTooltip", nil, "GameTooltipTemplate")
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetSpellByID(spellID)

    for i = 1, tooltip:NumLines() do
        local line = _G[tooltip:GetName() .. "TextLeft" .. i]:GetText()
        if line then
            -- Mønster for å fange tall, også med punktum eller komma
            local minDamage, maxDamage = string.match(line, "([%d%.,]+)%s?to%s?([%d%.,]+) damage")
            if not minDamage then
                minDamage, maxDamage = string.match(line, "([%d%.,]+)%s?til%s?([%d%.,]+) skade")
            end
            local singleDamage = string.match(line, "([%d%.,]+) damage") or string.match(line, "([%d%.,]+) skade")

            if minDamage and maxDamage then
                return minDamage .. "-" .. maxDamage
            elseif singleDamage then
                return singleDamage
            end
        end
    end
    
    tooltip:Hide()
    tooltip:ClearAllPoints()
    tooltip:SetParent(nil)
    tooltip = nil

    return ""
end

-- The main function to update the damage labels on all action bar buttons
local function UpdateDamageDisplays()
    for i = 1, 120 do
        local button = _G["ActionButton" .. i]
        if button then
            local actionType, spellID = GetActionInfo(i)
            local label = GetOrCreateDamageLabel(button)

            if actionType == "spell" and spellID then
                local damage = GetSpellDamage(spellID)
                if damage ~= "" then
                    label:SetText(damage)
                    label:Show()
                else
                    label:Hide()
                end
            else
                label:Hide()
            end
        end
    end
end

-- Use a timer to update the display regularly
addon:SetScript("OnUpdate", function(self, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate >= updateTimer then
        UpdateDamageDisplays()
        lastUpdate = 0
    end
end)

-- Initial update on login
addon:RegisterEvent("PLAYER_LOGIN")
addon:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        UpdateDamageDisplays()
    end
end)