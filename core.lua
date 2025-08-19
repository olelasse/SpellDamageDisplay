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
            -- Let's print the line to find the correct text format
            print("Checking tooltip line: " .. line)
            
            -- This is the new, more flexible pattern
            local damageValue = string.match(line, "(%d+%p?%d* to %d+%p?%d*)") or string.match(line, "(%d+%p?%d*)")
            
            if damageValue then
                local text = string.lower(line)
                -- We only want the damage number if the word "skade" or "damage" is on the same line
                if string.find(text, "skade") or string.find(text, "damage") then
                    print("Found damage for spell ID " .. spellID .. ": " .. damageValue)
                    return damageValue
                end
            end
        end
    end
    print("No damage found for spell ID " .. spellID)
    return ""
end

-- The main function to update the damage labels on all action bar buttons
local function UpdateDamageDisplays()
    print("Updating spell damage displays...")
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