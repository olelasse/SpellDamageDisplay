local addonName = "SpellDamageDisplay"
local addon = CreateFrame("Frame", addonName)

local damageLabels = {}
local tooltip = CreateFrame("GameTooltip", addonName.."Tooltip", nil, "GameTooltipTemplate")

-- A helper function to create or get the damage label for an action button
local function GetOrCreateDamageLabel(button)
    local label = damageLabels[button]
    if not label then
        label = button:CreateFontString(nil, "OVERLAY")
        label:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        label:SetPoint("CENTER", 0, 0) -- Adjust position as needed
        label:SetTextColor(1, 1, 0) -- Yellow text
        damageLabels[button] = label
    end
    return label
end

-- A helper function to extract damage numbers from a spell's tooltip
local function GetSpellDamage(spellID)
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetSpellByID(spellID)

    for i = 1, tooltip:NumLines() do
        local line = _G[tooltip:GetName() .. "TextLeft" .. i]:GetText()
        if line then
            -- This pattern looks for numbers (e.g., "350 to 400" or "32") and the word "damage" or "skade"
            local damageValue = string.match(line, "(%d+ to %d+) damage") or string.match(line, "(%d+) damage")
            if not damageValue then
                damageValue = string.match(line, "(%d+ til %d+) skade") or string.match(line, "(%d+) skade")
            end
            if damageValue then
                return damageValue
            end
        end
    end
    return ""
end

-- The main function to update the damage labels on all action bar buttons
local function UpdateDamageDisplays()
    for i = 1, 120 do -- Loop through all possible action bar slots
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

-- Register for relevant events to update the display
addon:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "ACTIONBAR_SLOT_CHANGED" then
        UpdateDamageDisplays()
    end
end)

addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
