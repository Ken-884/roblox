--- FREE KEY IF PLATOBOOST IS DOWN ---
local executorName = (identifyexecutor and identifyexecutor()) or ""

-- Function to create a Roblox-style notification (bottom right corner)
local function createNotification(message)
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("SendNotification", {
        Title = "Seisen Hub",
        Text = message,
        Duration = 8, -- seconds before it disappears
    })
end

-- Normalize executor name to lowercase
local execLower = executorName:lower()

-- Block if executor contains any form of Xeno or Solara
if execLower:find("xeno") or execLower:find("solara") then
    createNotification("Xeno and Solara are no longer supported by Seisen Hub.")
    return {} -- Return empty table so no games are selected
end

local Games = {
    -- Swordburst 3 floors
    ["4093155512"] = "https://raw.githubusercontent.com/Mentos4/Roblox/refs/heads/main/Script/Script_Swordburst3.lua",
    -- Dungeon Heroes
    ["7546582051"] = "https://raw.githubusercontent.com/Mentos4/Roblox/refs/heads/main/Script/Script_DungeonHeroes.lua",
    -- Anime Eternal
    ["7882829745"] = "https://raw.githubusercontent.com/Mentos4/Roblox/refs/heads/main/Script/Script_AnimeEternal.lua",
    -- Hypershot
    ["5995470825"] = "https://raw.githubusercontent.com/Mentos4/Roblox/refs/heads/main/Script/Script_Hypershot.lua",
    -- Build an Island
    ["7541395924"] = "https://raw.githubusercontent.com/Mentos4/Roblox/refs/heads/main/Script/Script_BuildanIsland.lua",
    -- Blue Heater 2
    ["5803093656"] = "https://raw.githubusercontent.com/Mentos4/Roblox/refs/heads/main/Script/Script_BlueHeater2.lua",
    -- Arise Crossover
    ["7074860883"] = "https://raw.githubusercontent.com/Mentos4/Roblox/refs/heads/main/Script/Script_AriseCrossover.lua",
    -- Anime Ranger X
    ["6884266247"] = "https://raw.githubusercontent.com/Mentos4/Roblox/refs/heads/main/Script/Script_AnimeRangerX.lua",
    -- Restaurant Tycoon 3
    ["7094518649"] = "https://raw.githubusercontent.com/Mentos4/Roblox/refs/heads/main/Script/Script_RestaurantTycoon3.lua",
}

return Games
