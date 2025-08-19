local addonName = "SpellDamageDisplay"
local addon = CreateFrame("Frame", addonName)

local damageLabels = {}
local tooltip = CreateFrame("GameTooltip", addonName.."Tooltip", nil, "GameTooltipTemplate")
local updateTimer = 0.5 -- How often to update the display, in seconds
local lastUpdate = 0

-- A helper function to create or get the damage label for an action button
local function GetOrCreateDamageLabel(button)
    local label = damageLabels[button]
    if not label then
        label = button:CreateFontString(nil, "OVERLAY")
        
        -- Nytt: Mindre font og justering for å sentrere teksten
        label:SetFont(STANDARD_TEXT_FONT, 8, "OUTLINE") -- Fontstørrelse redusert til 8
        label:SetWidth(button:GetWidth()) -- Sett bredden til ikonets bredde
        label:SetJustifyH("CENTER") -- Juster horisontalt til midten
        
        -- Nytt: Plassering for å unngå at teksten overlapper ikonet
        label:SetPoint("BOTTOM", 0, 5) -- Juster posisjon til litt over bunnen av ikonet
        
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
            -- This pattern is more robust and will handle numbers with commas, e.g., "1,012"
            local minDamage, maxDamage = string.match(line, "([%d,%.]+) to ([%d,%.]+) damage") or string.match(line, "([%d,%.]+) to ([%d,%.]+) skade")
            local singleDamage = string.match(line, "([%d,%.]+) damage") or string.match(line, "([%d,%.]+) skade")

            if minDamage and maxDamage then
                -- Return a compact format "min-max"
                return minDamage .. "-" .. maxDamage
            elseif singleDamage then
                return singleDamage
            end
        end
    end
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