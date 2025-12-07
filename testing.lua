getgenv().SeisenHubRunning = true

game.StarterGui:SetCore("SendNotification", {
    Title = "Seisen Hub";
    Text = "Anime Fights Script Loaded";
    Duration = 10; -- seconds
})
game.StarterGui:SetCore("SendNotification", {
    Title = "Stay Updated!";
    Text = "Join our Discord for the latest news, updates, and support!";
    Duration = 10;
    Button1 = "Copy Discord";
    Callback = function()
        setclipboard("https://discord.gg/F4sAf6z8Ph")
    end
})


local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

-- Game whitelist: set GameId(s) (universe) for which this script is allowed to run.
-- Using GameId (universe) makes the script remain allowed across teleports to other places in the same game.
-- Example: local ALLOWED_GAME_IDS = {11111111, 22222222}
-- If you want the script to run in any game, set this to an empty table: {}
local ALLOWED_GAME_IDS = {8469926548} -- TODO: replace with your game's GameId(s) (universe id)

local function isAllowedGame()
    if not ALLOWED_GAME_IDS or #ALLOWED_GAME_IDS == 0 then
        return true
    end
    local gid = tonumber(game.GameId) or 0
    for _, v in ipairs(ALLOWED_GAME_IDS) do
        if gid == v then return true end
    end
    return false
end

if not isAllowedGame() then
    pcall(function()
        -- Notify the user that the script won't run in this game/universe
        game.StarterGui:SetCore("SendNotification", {
            Title = "Seisen Hub";
            Text = "This script is not configured to run in this game (GameId: " .. tostring(game.GameId) .. ").";
            Duration = 6;
        })
    end)
    return
end

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
Library.ShowToggleFrameInKeybinds = true
local Window = Library:CreateWindow({
    Title = "Seisen Hub",
    Footer = "Anime Fights",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Center = true,
    Icon = 125926861378074,
    AutoShow = true,
    ShowCustomCursor = true -- Enable custom cursor
})

config = {}
local FPSBoostToggle = config.FPSBoostToggle or false


local MainTab = Window:AddTab("Main", "atom", "Main Features")
local LeftGroupbox = MainTab:AddLeftGroupbox("Automation", "sun-moon")
local AutoSummon = MainTab:AddRightGroupbox("Auto Summon", "star")
local AutoRoll = MainTab:AddRightGroupbox("Auto Roll", "dices")

local LobbyTab = Window:AddTab("Lobby", "house", "Lobby Features")
local Tower = LobbyTab:AddLeftGroupbox("Tower", "radio-tower")
local Trial = LobbyTab:AddRightGroupbox("Trial", "tally-3")
local Reroll = LobbyTab:AddLeftGroupbox("Reroll Traits", "refresh-cw")
local StatsReroll = LobbyTab:AddRightGroupbox("Stats Reroll", "chart-no-axes-column")

local SettingsTab = Window:AddTab("Settings", "cog", "Script Settings")
local PlayerSettings = SettingsTab:AddLeftGroupbox("Player Settings", "cog")
local Settings = SettingsTab:AddLeftGroupbox("Settings", "cog")
local InfoGroup = SettingsTab:AddRightGroupbox("Script Information", "info")
local UiSettingsTab = Window:AddTab("UI Settings", "sliders-horizontal")

-- Configure SaveManager
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({ 
    "MenuKeybind",
    "BackgroundColorPicker",
    "MainColorPicker", 
    "AccentColorPicker",
    "OutlineColorPicker",
    "FontColorPicker"
}) -- Ignore UI theme related settings
SaveManager:SetFolder("SeisenHub/AnimeFights")
SaveManager:SetSubFolder("Configs") -- Optional subfolder for better organization
SaveManager:BuildConfigSection(UiSettingsTab)

-- Configure ThemeManager  
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenHub")
ThemeManager:ApplyToTab(UiSettingsTab)

InfoGroup:AddLabel("Script by: Seisen")
InfoGroup:AddLabel("Version: 8.0.0")
InfoGroup:AddLabel("Game: Anime Fights")

-- Show current config status
local currentConfig = SaveManager:GetAutoloadConfig()
if currentConfig and currentConfig ~= "none" then
    InfoGroup:AddLabel("Auto-loading: " .. currentConfig)
else
    InfoGroup:AddLabel("Auto-loading: Disabled")
end

InfoGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/F4sAf6z8Ph")
end)


-- Mobile detection and UI adjustments
if Library.IsMobile then
    InfoGroup:AddLabel("📱 Mobile Device Detected")
    InfoGroup:AddLabel("UI optimized for mobile")
else
    InfoGroup:AddLabel("🖥️ Desktop Device Detected")
end
---====================================Main Feature================================--
-- Teleport dropdown: selecting an entry will fire the game's Bridge teleport remote
-- Helper: get interact maps (used for Teleport, Quest, Autofarm)
local function getInteractMaps()
    local out = {}
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local shared = rs:FindFirstChild("Shared")
        if not shared then return end
        local worlds = shared:FindFirstChild("Worlds")
        if not worlds then return end
        for _, child in ipairs(worlds:GetChildren()) do
            if child and child.Name then table.insert(out, child.Name) end
        end
    end)
    table.sort(out)
    return out
end

local teleportDropdownRef = nil
local teleportSelection = ""
local teleportValues = getInteractMaps()
teleportSelection = (teleportValues and #teleportValues > 0) and teleportValues[1] or "Lobby"
teleportDropdownRef = LeftGroupbox:AddDropdown("TeleportTo", {
    Text = "Teleport To",
    Default = teleportSelection,
    Values = teleportValues,
    Tooltip = "Select a location to teleport to (will teleport immediately)",
    Callback = function(selection)
        teleportSelection = selection
        -- Build the args expected by the game's teleport remote
        local args = {
            [1] = "General",
            [2] = "Teleport",
            [3] = "Teleport",
            [4] = selection,
        }
        -- Fire the remote safely
        local ok, err = pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:WaitForChild("Remotes", 9e9)
            local bridge = remotes:WaitForChild("Bridge", 9e9)
            bridge:FireServer(unpack(args))
        end)
    end
})
LeftGroupbox:AddDivider()
    -- Quest accept UI: select a quest and accept it via the game's Bridge remote
    local questSelection = ""
    local questDropdownRef = nil
    local questValues = getInteractMaps()
    questSelection = (questValues and #questValues > 0) and questValues[1] or "Leaf Village"
    questDropdownRef = LeftGroupbox:AddDropdown("QuestSelect", {
        Text = "Quest",
        Default = questSelection,
        Values = questValues,
        Tooltip = "Select a world quest to accept",
        Callback = function(selection)
            questSelection = selection
        end
    })

    LeftGroupbox:AddButton("AcceptQuest", function()
        local args = {
            [1] = "General",
            [2] = "World_Quest",
            [3] = "accept",
            [4] = questSelection,
        }
        local ok, err = pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:WaitForChild("Remotes", 9e9)
            local bridge = remotes:WaitForChild("Bridge", 9e9)
            bridge:FireServer(unpack(args))
        end)
            -- Notification removed as requested
    end)

LeftGroupbox:AddDivider()
    -- Autofarm islands and state (dynamic from workspace.Server.Interact)
    local autofarmIslands = {}
    local autofarmIsland = ""
    local autofarmEnemy = nil
    local autofarmEnemyNames = {}
    local autofarmEnemyDropdownRef = nil
    local autofarmRunning = false
    local autofarmThread = nil

    local function getAutofarmIslandsFromInteract()
        local out = {}
        pcall(function()
            local server = workspace:FindFirstChild("Server")
            if not server then return end
            local interact = server:FindFirstChild("Interact")
            if not interact then return end
            -- include direct children as available islands/maps
            for _, child in ipairs(interact:GetChildren()) do
                if child and child.Name then
                    table.insert(out, child.Name)
                end
            end
        end)
        table.sort(out)
        return out
    end

    -- Helper: get unique enemy names for an island
    local function getUniqueEnemyNames(island)
        local names = {}
        local found = {}
        local ok, _ = pcall(function()
            local server = workspace:FindFirstChild("Server")
            if server then
                local enemiesFolder = server:FindFirstChild("Enemies")
                if enemiesFolder then
                    local islandFolder = enemiesFolder:FindFirstChild(island)
                    if islandFolder then
                        for _, obj in ipairs(islandFolder:GetChildren()) do
                            if obj:IsA("BasePart") and obj.Name and not found[obj.Name] then
                                table.insert(names, obj.Name)
                                found[obj.Name] = true
                            end
                        end
                    end
                end
            end
        end)
        return names
    end


    -- Initial enemy names (island may be empty until we populate)
    autofarmIslands = getAutofarmIslandsFromInteract()
    autofarmIsland = autofarmIslands[1] or ""
    autofarmEnemyNames = getUniqueEnemyNames(autofarmIsland)

    local autofarmIslandDropdownRef = nil
    autofarmIslandDropdownRef = LeftGroupbox:AddDropdown("AutofarmIsland", {
        Text = "Autofarm Island",
        Default = autofarmIsland,
        Values = autofarmIslands,
        Tooltip = "Select the island to autofarm",
        Callback = function(selection)
            autofarmIsland = selection
            autofarmEnemyNames = getUniqueEnemyNames(autofarmIsland)
            autofarmEnemy = nil
            -- Update existing enemy dropdown values instead of adding a new widget
            if autofarmEnemyDropdownRef and autofarmEnemyDropdownRef.SetValues then
                autofarmEnemyDropdownRef:SetValues(autofarmEnemyNames)
                -- Clear current selection in the dropdown UI
                if autofarmEnemyDropdownRef.SetValue then
                    autofarmEnemyDropdownRef:SetValue("")
                end
            else
                -- Fallback: if reference isn't available, add a fresh dropdown
                autofarmEnemyDropdownRef = LeftGroupbox:AddDropdown("AutofarmEnemy", {
                    Text = "Autofarm Enemy",
                    Default = "",
                    Values = autofarmEnemyNames,
                    Tooltip = "Select the enemy to autofarm",
                    Callback = function(sel)
                        autofarmEnemy = sel
                    end
                })
            end
        end
    })

    -- Initial enemy dropdown (keep a reference so we can update it later)
    autofarmEnemyDropdownRef = LeftGroupbox:AddDropdown("AutofarmEnemy", {
        Text = "Autofarm Enemy",
        Default = "",
        Values = autofarmEnemyNames,
        Tooltip = "Select the enemy to autofarm",
        Callback = function(selection)
            autofarmEnemy = selection
        end
    })

    -- Periodically refresh available islands/maps from workspace.Server.Interact
    task.spawn(function()
        while true do
            local maps = getAutofarmIslandsFromInteract()
            -- update autofarm island dropdown
            if autofarmIslandDropdownRef and type(autofarmIslandDropdownRef.SetValues) == "function" then
                pcall(function() autofarmIslandDropdownRef:SetValues(maps) end)
            end
            -- update teleport dropdown
            if teleportDropdownRef and type(teleportDropdownRef.SetValues) == "function" then
                pcall(function() teleportDropdownRef:SetValues(maps) end)
            end
            -- update quest dropdown
            if questDropdownRef and type(questDropdownRef.SetValues) == "function" then
                pcall(function() questDropdownRef:SetValues(maps) end)
            end

            -- if current autofarm selection is gone, pick the first available
            local found = false
            for _, v in ipairs(maps) do if v == autofarmIsland then found = true break end end
            if not found then
                autofarmIsland = maps[1] or ""
                if autofarmIslandDropdownRef and type(autofarmIslandDropdownRef.SetValue) == "function" then
                    pcall(function() autofarmIslandDropdownRef:SetValue(autofarmIsland) end)
                end
                -- refresh enemy list for the new selection
                autofarmEnemyNames = getUniqueEnemyNames(autofarmIsland)
                if autofarmEnemyDropdownRef and type(autofarmEnemyDropdownRef.SetValues) == "function" then
                    pcall(function() autofarmEnemyDropdownRef:SetValues(autofarmEnemyNames) end)
                end
            end

            -- if current teleport selection is gone, pick first available
            local tfound = false
            for _, v in ipairs(maps) do if v == teleportSelection then tfound = true break end end
            if not tfound then
                teleportSelection = maps[1] or ""
                if teleportDropdownRef and type(teleportDropdownRef.SetValue) == "function" then
                    pcall(function() teleportDropdownRef:SetValue(teleportSelection) end)
                end
            end

            -- if current quest selection is gone, pick first available
            local qfound = false
            for _, v in ipairs(maps) do if v == questSelection then qfound = true break end end
            if not qfound then
                questSelection = maps[1] or ""
                if questDropdownRef and type(questDropdownRef.SetValue) == "function" then
                    pcall(function() questDropdownRef:SetValue(questSelection) end)
                end
            end

            task.wait(2)
        end
    end)

    local function autofarmLoop()
            while autofarmRunning do
                if autofarmIsland and autofarmEnemy then
                    local player = game:GetService("Players").LocalPlayer
                    local char = player and player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local islandFolder = nil
                    local ok, err = pcall(function()
                        islandFolder = workspace:WaitForChild("Server", 9e9):WaitForChild("Enemies", 9e9):WaitForChild(autofarmIsland, 9e9)
                    end)
                    if ok and islandFolder and root then
                        local function getClosestLivingEnemy()
                            local closest = nil
                            local minDist = math.huge
                            for _, obj in ipairs(islandFolder:GetChildren()) do
                                if obj:IsA("BasePart") and obj.Name == autofarmEnemy and obj:GetAttribute("ID") then
                                    local health = obj:GetAttribute("Health")
                                    if health and health > 0 then
                                        local dist = (obj.Position - root.Position).Magnitude
                                        if dist < minDist then
                                            minDist = dist
                                            closest = obj
                                        end
                                    end
                                end
                            end
                            return closest
                        end

                        local lastTarget = nil
                        while autofarmRunning do
                            local target = getClosestLivingEnemy()
                            if not target then
                                    -- Notification removed as requested
                                break
                            end
                            if target ~= lastTarget then
                                -- Teleport player to new target
                                pcall(function()
                                    root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                                end)
                                lastTarget = target
                            end
                            -- Attack target
                            local attackArgs = {
                                [1] = "Fighters",
                                [2] = "Attack",
                                [3] = "Attack_All",
                                [4] = "World",
                                [5] = target,
                            }
                            pcall(function()
                                local rs = game:GetService("ReplicatedStorage")
                                local remotes = rs:WaitForChild("Remotes", 9e9)
                                local bridge = remotes:WaitForChild("Bridge", 9e9)
                                bridge:FireServer(unpack(attackArgs))
                            end)
                            -- Check health quickly, switch if dead
                            local health = target:GetAttribute("Health")
                            if not health or health <= 0 then
                                lastTarget = nil
                                continue
                            end
                            task.wait(0.5)
                        end
                    else
                            -- Notification removed as requested
                    end
                end
                task.wait(0.5)
            end
    end

    LeftGroupbox:AddToggle("AutofarmToggle", {
        Text = "Autofarm",
        Default = false,
        Tooltip = "Automatically teleport and attack all selected enemies",
        Callback = function(enabled)
            autofarmRunning = enabled
            if enabled then
                autofarmThread = task.spawn(autofarmLoop)
                    -- Notification removed as requested
            else
                autofarmRunning = false
                    -- Notification removed as requested
            end
        end
    })

    -- Auto Click Attack state
    local autoAttackRunning = false
    local autoAttackThread = nil

    LeftGroupbox:AddToggle("AutoAttackToggle", {
        Text = "Auto Click",
        Default = false,
        Tooltip = "Automatically spam Fighters/Attack/Attack remote",
        Callback = function(enabled)
            autoAttackRunning = enabled
            if enabled then
                autoAttackThread = task.spawn(function()
                    while autoAttackRunning do
                        pcall(function()
                            local args = {
                                [1] = "Fighters",
                                [2] = "Attack",
                                [3] = "Click",
                            }
                            local rs = game:GetService("ReplicatedStorage")
                            local remotes = rs:WaitForChild("Remotes", 9e9)
                            local bridge = remotes:WaitForChild("Bridge", 9e9)
                            bridge:FireServer(unpack(args))
                        end)
                        task.wait(0.5)
                    end
                end)
                -- Notification removed as requested
            else
                autoAttackRunning = false
                -- Notification removed as requested
            end
        end
    })
    



    -- Auto Claim Achievements: only claim Damage/Tower/Luck/Trial levels I..X and Inventory I
    local autoClaimAchievementsRunning = false
    local autoClaimAchievementsThread = nil

    local categories = {"Damage", "Tower", "Luck", "Trial", "Inventory"}
    local maxLevel = 10 -- I to X

    local function toRoman(num)
        local romanNumerals = {
            [1] = "I", [2] = "II", [3] = "III", [4] = "IV", [5] = "V", [6] = "VI", [7] = "VII", [8] = "VIII", [9] = "IX", [10] = "X",
        }
        return romanNumerals[num]
    end

    local function buildAchievementNames()
        local out = {}
        for _, cat in ipairs(categories) do
            for i = 1, maxLevel do
                local roman = toRoman(i) or tostring(i)
                table.insert(out, cat .. " " .. roman)
            end
        end
        table.insert(out, "Inventory I")
        return out
    end

    local function claimAchievement(name)
        pcall(function()
            local args = {
                [1] = "General",
                [2] = "Achievements",
                [3] = "Claim",
                [4] = name,
            }
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:WaitForChild("Remotes", 9e9)
            local bridge = remotes:WaitForChild("Bridge", 9e9)
            bridge:FireServer(unpack(args))
        end)
    end

    LeftGroupbox:AddToggle("AutoClaimAchievements", {
        Text = "Auto Claim Achievements",
        Default = false,
        Tooltip = "Claim Damage/Tower/Luck/Trial I..X and Inventory I",
        Callback = function(enabled)
            autoClaimAchievementsRunning = enabled
            if enabled then
                local names = buildAchievementNames()
                autoClaimAchievementsThread = task.spawn(function()
                    while autoClaimAchievementsRunning do
                        for _, name in ipairs(names) do
                            if not autoClaimAchievementsRunning then break end
                            claimAchievement(name)
                            task.wait(0.5)
                        end
                        task.wait(1)
                    end
                end)
            else
                autoClaimAchievementsRunning = false
            end
        end
    })
    
    -- Auto Claim Daily rewards (1..7)
    local autoClaimDailyRunning = false
    local autoClaimDailyThread = nil

    local function claimDaily(index)
        pcall(function()
            local args = {
                [1] = "General",
                [2] = "DailyRewards",
                [3] = "Claim",
                [4] = index,
            }
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:WaitForChild("Remotes", 9e9)
            local bridge = remotes:WaitForChild("Bridge", 9e9)
            bridge:FireServer(unpack(args))
        end)
    end

    LeftGroupbox:AddToggle("AutoClaimDaily", {
        Text = "Auto Claim Daily",
        Default = false,
        Tooltip = "Automatically claim daily rewards indices 1 through 7",
        Callback = function(enabled)
            autoClaimDailyRunning = enabled
            if enabled then
                autoClaimDailyThread = task.spawn(function()
                    while autoClaimDailyRunning do
                        for i = 1, 7 do
                            if not autoClaimDailyRunning then break end
                            claimDaily(i)
                            task.wait(0.5)
                        end
                        task.wait(5)
                    end
                end)
            else
                autoClaimDailyRunning = false
            end
        end
    })

---================================Summon====================================--
-- Fast Auto Summon: more aggressive loop that forces client attributes to avoid UI gating
    local fastAutoRunning = false
    local fastAutoThread = nil
    local fastAutoInterval = 0.1 -- seconds (super fast)

    local function performFastAutoSummon()
        pcall(function()
            local Players = game:GetService("Players")
            local pl = Players.LocalPlayer
            -- Force client-side attributes so the local UI allows immediate summoning
            if pl then
                pcall(function()
                    pl:SetAttribute("Auto_Summon", true)
                    pl:SetAttribute("Fighter_View", false)
                    pl:SetAttribute("Rewards_View", false)
                    pl:SetAttribute("Star_Animation", false)
                end)
            end

            local args = {
                [1] = "General",
                [2] = "Star",
                [3] = "Open",
            }
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:WaitForChild("Remotes", 9e9)
            local bridge = remotes:WaitForChild("Bridge", 9e9)
            bridge:FireServer(unpack(args))
        end)
    end

    AutoSummon:AddSlider("FastAutoInterval", {
        Text = "Fast Roll Interval (s)",
        Default = fastAutoInterval,
        Min = 0.05,
        Max = 1,
        Rounding = 2,
        Tooltip = "Interval between fast automatic rolls (lower = faster)",
        Callback = function(value)
            fastAutoInterval = value or 0.1
        end
    })

    AutoSummon:AddToggle("FastAutoToggle", {
        Text = "Fast Auto Summon",
        Default = false,
        Tooltip = "Aggressively fire Star/Open while forcing client attributes (may be detected). Does not send AntiAfk.",
        Callback = function(enabled)
            fastAutoRunning = enabled
            if enabled then
                fastAutoThread = task.spawn(function()
                    while fastAutoRunning do
                        performFastAutoSummon()
                        task.wait(fastAutoInterval)
                    end
                end)
            else
                fastAutoRunning = false
                -- clear the local Auto_Summon attribute when stopping
                pcall(function()
                    local pl = game:GetService("Players").LocalPlayer
                    if pl then pl:SetAttribute("Auto_Summon", nil) end
                end)
            end
        end
    })
   -- Auto Delete: multi-select rarities and toggle to call Delete_Rarity
    local autoDeleteRunning = false
    local autoDeleteRarities = {}
    local autoDeleteMode = "Normal" -- "Normal", "Shiny", or "Both"

    local function callDeleteForRarity(rarity, isShiny)
        pcall(function()
            local args = {
                [1] = "General",
                [2] = "Settings",
                [3] = "Delete_Rarity",
                [4] = rarity,
                [5] = isShiny,
            }
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:WaitForChild("Remotes", 9e9)
            local bridge = remotes:WaitForChild("Bridge", 9e9)
            bridge:FireServer(unpack(args))
        end)
    end
    -- helper: normalize selection (Dropdown passes a map when Multi=true)
    local function normalizeSelection(selection)
        local out = {}
        if type(selection) == "table" then
            -- if it's an array-like table, keep those values
            if #selection > 0 then
                for _, v in ipairs(selection) do
                    table.insert(out, v)
                end
                return out
            end
            -- otherwise it's a map {value = true}
            for k, v in pairs(selection) do
                if v then table.insert(out, k) end
            end
            return out
        elseif type(selection) == "string" then
            return { selection }
        end
        return out
    end

    AutoSummon:AddDropdown("AutoDeleteRarities", {
        Text = "Delete Rarities",
        Default = {},
        Values = {"Common", "Uncommon", "Rare", "Epic", "legendary", "Mythical"},
        Multi = true,
        Tooltip = "Select rarities to delete (multi-select)",
        Callback = function(selection)
            -- library passes a map (value->true) when Multi=true; normalize to array
            autoDeleteRarities = normalizeSelection(selection)
            -- If toggle is already enabled, apply deletion for newly selected rarities using current shiny setting
            if autoDeleteRunning then
                for _, r in ipairs(autoDeleteRarities) do
                    if autoDeleteMode == "Normal" then
                        callDeleteForRarity(r, false)
                    elseif autoDeleteMode == "Shiny" then
                        callDeleteForRarity(r, true)
                    else -- Both
                        callDeleteForRarity(r, false)
                        callDeleteForRarity(r, true)
                    end
                end
            end
        end
    })

    -- Dropdown to select Normal/Shiny/Both mode for deletion
    AutoSummon:AddDropdown("AutoDeleteMode", {
        Text = "Delete Mode",
        Default = autoDeleteMode,
        Values = {"Normal", "Shiny", "Both"},
        Tooltip = "Choose whether to delete normal, shiny, or both variants",
        Callback = function(selection)
            autoDeleteMode = selection or "Normal"
        end
    })

    AutoSummon:AddToggle("AutoDeleteToggle", {
        Text = "Auto Delete",
        Default = false,
        Tooltip = "Call Delete_Rarity for selected rarities when toggled",
        Callback = function(enabled)
            autoDeleteRunning = enabled
            -- When toggling on OR off, call the Delete_Rarity remote for each selected rarity.
            for _, r in ipairs(autoDeleteRarities) do
                if autoDeleteMode == "Normal" then
                    callDeleteForRarity(r, false)
                elseif autoDeleteMode == "Shiny" then
                    callDeleteForRarity(r, true)
                else -- Both
                    callDeleteForRarity(r, false)
                    callDeleteForRarity(r, true)
                end
            end
        end
    })
    
    AutoSummon:AddDivider()
    -- Auto Fuse: select one of your fighters (display name from attribute) and call Fuse_Target with the model id
    local autoFuseRunning = false
    local autoFuseThread = nil
    local fuseDropdownRef = nil
    local fuseMap = {}
    local selectedFuseId = nil

    local function refreshFuseList()
        local values = {}
        fuseMap = {}
        local ok, client = pcall(function() return workspace:FindFirstChild("Client") end)
        if not ok or not client then
            if fuseDropdownRef and fuseDropdownRef.SetValues then
                fuseDropdownRef:SetValues({})
            end
            return
        end
        local fightersFolder = client:FindFirstChild("Fighters")
        if not fightersFolder then
            if fuseDropdownRef and fuseDropdownRef.SetValues then
                fuseDropdownRef:SetValues({})
            end
            return
        end
        local PlayersSvc = game:GetService("Players")
        local pl = PlayersSvc.LocalPlayer
        if not pl then
            if fuseDropdownRef and fuseDropdownRef.SetValues then
                fuseDropdownRef:SetValues({})
            end
            return
        end
        local playerFolder = fightersFolder:FindFirstChild(tostring(pl.UserId))
        if not playerFolder then
            if fuseDropdownRef and fuseDropdownRef.SetValues then
                fuseDropdownRef:SetValues({})
            end
            return
        end
        -- collect entries and counts so we can disambiguate duplicate display names
        local entries = {}
        local counts = {}
        for _, model in ipairs(playerFolder:GetChildren()) do
            if model and model:IsA("Model") then
                local ok2, attrName = pcall(function() return model:GetAttribute("Name") end)
                local base = (ok2 and attrName) and tostring(attrName) or tostring(model.Name)
                table.insert(entries, { base = base, id = model.Name })
                counts[base] = (counts[base] or 0) + 1
            end
        end
        -- when duplicates exist, append a numeric index (e.g. 'Name #2') so we don't expose model ids
        local seq = {}
        for _, e in ipairs(entries) do
            local display = e.base
            if counts[e.base] and counts[e.base] > 1 then
                seq[e.base] = (seq[e.base] or 0) + 1
                display = e.base .. " #" .. tostring(seq[e.base])
            end
            table.insert(values, display)
            fuseMap[display] = e.id
        end
        if fuseDropdownRef and fuseDropdownRef.SetValues then
            fuseDropdownRef:SetValues(values)
        end
    end

    fuseDropdownRef = AutoSummon:AddDropdown("FuseTargetDropdown", {
        Text = "Fuse Target",
        Default = "",
        Values = {},
        Tooltip = "Select a fighter to auto-fuse (shows attribute 'Name', calls model id)",
        Callback = function(selection)
            selectedFuseId = fuseMap[selection]
        end
    })

    -- auto-refresh dropdown when player's fighters change
    do
        local refreshAddConn, refreshRemoveConn
        task.spawn(function()
            local PlayersSvc = game:GetService("Players")
            local lastPlayerId = nil
            while true do
                local pl = PlayersSvc.LocalPlayer
                if pl then
                    local ok, client = pcall(function() return workspace:FindFirstChild("Client") end)
                    if ok and client then
                        local fightersFolder = client:FindFirstChild("Fighters")
                        if fightersFolder then
                            local playerFolder = fightersFolder:FindFirstChild(tostring(pl.UserId))
                            if playerFolder then
                                -- connect once
                                if not refreshAddConn then
                                    refreshAddConn = playerFolder.ChildAdded:Connect(function()
                                        task.wait(0.5)
                                        refreshFuseList()
                                    end)
                                    refreshRemoveConn = playerFolder.ChildRemoved:Connect(function()
                                        task.wait(0.5)
                                        refreshFuseList()
                                    end)
                                    -- initial populate
                                    refreshFuseList()
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end

    AutoSummon:AddToggle("AutoFuseToggle", {
        Text = "Auto Fuse",
        Default = false,
        Tooltip = "Automatically call Fuse_Target on the selected fighter",
        Callback = function(enabled)
            autoFuseRunning = enabled
            if enabled then
                -- ensure list is populated
                refreshFuseList()
                autoFuseThread = task.spawn(function()
                    while autoFuseRunning do
                        if selectedFuseId and selectedFuseId ~= "" then
                            pcall(function()
                                local args = {
                                    [1] = "General",
                                    [2] = "Settings",
                                    [3] = "Fuse_Target",
                                    [4] = selectedFuseId,
                                }
                                local rs = game:GetService("ReplicatedStorage")
                                local remotes = rs:WaitForChild("Remotes", 9e9)
                                local bridge = remotes:WaitForChild("Bridge", 9e9)
                                bridge:FireServer(unpack(args))
                            end)
                        end
                        task.wait(0.5)
                    end
                end)
            else
                -- send a plain Fuse_Target call (no id) to cancel/stop server-side fuse targeting
                pcall(function()
                    local args = {
                        [1] = "General",
                        [2] = "Settings",
                        [3] = "Fuse_Target",
                    }
                    local rs = game:GetService("ReplicatedStorage")
                    local remotes = rs:WaitForChild("Remotes", 9e9)
                    local bridge = remotes:WaitForChild("Bridge", 9e9)
                    bridge:FireServer(unpack(args))
                end)
                autoFuseRunning = false
            end
        end
    })

    -- Auto Fuse by Rarity: multi-select rarities and choose Normal/Shiny/Both
    local autoFuseRarityRunning = false
    local autoFuseRarityThread = nil
    local autoFuseRarities = {}
    local autoFuseRarityMode = "Normal" -- Normal, Shiny, Both

    AutoSummon:AddDropdown("AutoFuseRarities", {
        Text = "Fuse Rarities",
        Default = {},
        Values = {"Common", "Uncommon", "Rare", "Epic", "legendary", "Mythical"},
        Multi = true,
        Tooltip = "Select rarities to auto-fuse (multi-select)",
        Callback = function(selection)
            -- normalizeSelection exists above; reuse it
            if type(selection) == "table" then
                autoFuseRarities = {}
                if #selection > 0 then
                    for _, v in ipairs(selection) do table.insert(autoFuseRarities, v) end
                else
                    for k, v in pairs(selection) do if v then table.insert(autoFuseRarities, k) end end
                end
            elseif type(selection) == "string" then
                autoFuseRarities = { selection }
            else
                autoFuseRarities = {}
            end
        end
    })

    AutoSummon:AddDropdown("AutoFuseRarityMode", {
        Text = "Fuse Mode",
        Default = autoFuseRarityMode,
        Values = {"Normal", "Shiny", "Both"},
        Tooltip = "Choose whether to fuse normal, shiny, or both variants",
        Callback = function(selection)
            autoFuseRarityMode = selection or "Normal"
        end
    })

    AutoSummon:AddToggle("AutoFuseRarityToggle", {
        Text = "Auto Fuse Rarity",
        Default = false,
        Tooltip = "Call Fuse_Rarity once for selected rarities when toggled on/off",
        Callback = function(enabled)
            -- Mirror Auto Delete behaviour: call once when toggled (on or off)
            autoFuseRarityRunning = enabled
            if #autoFuseRarities > 0 then
                for _, r in ipairs(autoFuseRarities) do
                    pcall(function()
                        local rs = game:GetService("ReplicatedStorage")
                        local remotes = rs:WaitForChild("Remotes", 9e9)
                        local bridge = remotes:WaitForChild("Bridge", 9e9)
                        if autoFuseRarityMode == "Normal" then
                            bridge:FireServer("General", "Settings", "Fuse_Rarity", r, false)
                        elseif autoFuseRarityMode == "Shiny" then
                            bridge:FireServer("General", "Settings", "Fuse_Rarity", r, true)
                        else -- Both
                            bridge:FireServer("General", "Settings", "Fuse_Rarity", r, false)
                            task.wait(0.5)
                            bridge:FireServer("General", "Settings", "Fuse_Rarity", r, true)
                        end
                    end)
                end
            end
        end
    })

---==================================Reroll================================--
    -- Auto Reroll: dynamically list types from ReplicatedStorage.Shared
    local autoRerollRunning = false
    local autoRerollThread = nil
    local autoRerollInterval = 0.5 -- fixed default speed

    local function getRerollTypesFromShared()
        local out = {}
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local shared = rs:FindFirstChild("Shared")
            if not shared then return end
            for _, child in ipairs(shared:GetChildren()) do
                if child and child:IsA("Instance") then
                    local img = child:FindFirstChild("ImageLabel")
                    if img and img:IsA("ImageLabel") then
                        table.insert(out, child.Name)
                    end
                end
            end
        end)
        table.sort(out)
        return out
    end

    local function ensureHardcodedTypes(list)
        local must = { "Clans", "Races","Breathings","Auras","Fruits","Haki","Rank"}
        local seen = {}
        for _, v in ipairs(list) do seen[v] = true end
        for i = #must, 1, -1 do
            local v = must[i]
            if not seen[v] then
                table.insert(list, 1, v)
            end
        end
        return list
    end

    local rerollTypes = ensureHardcodedTypes(getRerollTypesFromShared())
    local selectedRerollType = rerollTypes[1] or ""

    local function performAutoReroll()
        pcall(function()
            if not selectedRerollType or selectedRerollType == "" then return end
            local args = {
                [1] = "General",
                [2] = selectedRerollType,
                [3] = "Reroll",
            }
            -- include selected type as 4th arg if present
            if selectedRerollType and selectedRerollType ~= "" then
                args[4] = selectedRerollType
            end
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:WaitForChild("Remotes", 9e9)
            local bridge = remotes:WaitForChild("Bridge", 9e9)
            bridge:FireServer(unpack(args))
        end)
    end

    local rerollTypeDropdownRef = nil
    rerollTypeDropdownRef = AutoRoll:AddDropdown("RerollType", {
        Text = "Reroll Type",
        Default = selectedRerollType,
        Values = rerollTypes,
        Tooltip = "Select which type to reroll (populated from ReplicatedStorage.Shared if it has ImageLabel children)",
        Callback = function(selection)
            selectedRerollType = selection
        end
    })

    -- Periodically refresh available reroll types from ReplicatedStorage.Shared
    task.spawn(function()
        while true do
            local types = getRerollTypesFromShared()
            types = ensureHardcodedTypes(types)
            -- update dropdown values if ref supports it
            if rerollTypeDropdownRef and type(rerollTypeDropdownRef.SetValues) == "function" then
                pcall(function()
                    rerollTypeDropdownRef:SetValues(types)
                end)
            end
            -- if current selection is gone, pick the first available
            local found = false
            for _, v in ipairs(types) do if v == selectedRerollType then found = true break end end
            if not found then
                selectedRerollType = types[1] or ""
                -- update UI value too if supported
                if rerollTypeDropdownRef and type(rerollTypeDropdownRef.SetValue) == "function" then
                    pcall(function() rerollTypeDropdownRef:SetValue(selectedRerollType) end)
                end
            end
            rerollTypes = types
            task.wait(2)
        end
    end)

    AutoRoll:AddToggle("AutoRerollToggle", {
        Text = "Auto Reroll",
        Default = false,
        Tooltip = "Automatically call Reroll for the selected type at 0.1s interval",
        Callback = function(enabled)
            autoRerollRunning = enabled
            if enabled then
                autoRerollThread = task.spawn(function()
                    while autoRerollRunning do
                        performAutoReroll()
                        task.wait(autoRerollInterval)
                    end
                end)
            else
                autoRerollRunning = false
            end
        end
    })
---=================================Tower====================================--
    -- Simple AutoFarm: teleport to nearest enemy (workspace-wide) and auto-attack it
    -- Auto Enter Tower
    local autoEnterTowerEnabled = false
    local autoEnterTowerThread = nil

    Tower:AddToggle("AutoEnterTowerToggle", {
        Text = "Auto Enter Tower",
        Default = false,
        Tooltip = "Spam enter Tower every 0.5s if Tower UI is not visible",
        Callback = function(enabled)
            autoEnterTowerEnabled = enabled
            if enabled then
                autoEnterTowerThread = task.spawn(function()
                    -- helper: find closest tower enemy (BasePart with ID attribute)
                    local function getClosestTowerEnemy(root)
                        if not root then return nil end
                        local closest = nil
                        local minDist = math.huge
                        local ok, enemiesParent = pcall(function()
                            return workspace:WaitForChild("Server", 9e9):WaitForChild("Gamemodes", 9e9):WaitForChild("Tower", 9e9):WaitForChild("Enemies", 9e9)
                        end)
                        if not ok or not enemiesParent then
                            -- fallback scan whole workspace
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj:IsA("BasePart") then
                                    local ok2, id = pcall(function() return obj:GetAttribute("ID") end)
                                    if ok2 and id then
                                        local ok3, health = pcall(function() return obj:GetAttribute("Health") end)
                                        if ok3 and health and health > 0 then
                                            local dist = (obj.Position - root.Position).Magnitude
                                            if dist < minDist then
                                                minDist = dist
                                                closest = obj
                                            end
                                        end
                                    end
                                end
                            end
                            return closest
                        end

                        -- prefer scanning children under the Tower enemies folder
                        for _, obj in ipairs(enemiesParent:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                local ok2, id = pcall(function() return obj:GetAttribute("ID") end)
                                if ok2 and id then
                                    local ok3, health = pcall(function() return obj:GetAttribute("Health") end)
                                    if ok3 and health and health > 0 then
                                        local dist = (obj.Position - root.Position).Magnitude
                                        if dist < minDist then
                                            minDist = dist
                                            closest = obj
                                        end
                                    end
                                end
                            end
                        end
                        return closest
                    end

                    -- tower farm loop will run while UI is visible; otherwise we spam enter
                    while autoEnterTowerEnabled do
                        local player = game:GetService("Players").LocalPlayer
                        local char = player and player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")

                        local towerUIVisible = false
                        pcall(function()
                            local towerUI = player.PlayerGui.UI.HUD.Tower
                            towerUIVisible = towerUI and towerUI.Visible
                        end)

                        if not towerUIVisible then
                            -- spam enter until UI appears
                            pcall(function()
                                local args = {
                                    [1] = "Gamemodes",
                                    [2] = "Tower",
                                    [3] = "Start",
                                }
                                local rs = game:GetService("ReplicatedStorage")
                                local remotes = rs:WaitForChild("Remotes", 9e9)
                                local bridge = remotes:WaitForChild("Bridge", 9e9)
                                bridge:FireServer(unpack(args))
                            end)
                            task.wait(0.5)
                        else
                            -- when inside tower UI, run autofarm-style tp + attack
                            if not root then
                                task.wait(0.5)
                            else
                                local lastTarget = nil
                                -- loop while still enabled and UI visible
                                while autoEnterTowerEnabled do
                                    -- re-check UI visibility
                                    local uvis = false
                                    pcall(function()
                                        local towerUI = player.PlayerGui.UI.HUD.Tower
                                        uvis = towerUI and towerUI.Visible
                                    end)
                                    if not uvis then break end

                                    local target = getClosestTowerEnemy(root)
                                    if not target then
                                        task.wait(0.5)
                                        break
                                    end

                                    if target ~= lastTarget then
                                        pcall(function()
                                            root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                                        end)
                                        lastTarget = target
                                    end

                                    -- Attack the current target (Tower context)
                                    pcall(function()
                                        local attackArgs = {
                                            [1] = "Fighters",
                                            [2] = "Attack",
                                            [3] = "Attack_All",
                                            [4] = "Tower",
                                            [5] = target,
                                        }
                                        local rs = game:GetService("ReplicatedStorage")
                                        local remotes = rs:WaitForChild("Remotes", 9e9)
                                        local bridge = remotes:WaitForChild("Bridge", 9e9)
                                        bridge:FireServer(unpack(attackArgs))
                                    end)

                                    -- If target died, reset lastTarget so we'll teleport to next target
                                    local ok, health = pcall(function() return target:GetAttribute("Health") end)
                                    if not ok or not health or health <= 0 then
                                        lastTarget = nil
                                        task.wait(0.5)
                                        continue
                                    end

                                    task.wait(0.5)
                                end
                            end
                        end
                    end
                end)
            else
                autoEnterTowerEnabled = false
            end
        end
    })

    -- Auto Leave Tower on specific wave
    local autoLeaveTowerEnabled = false
    local autoLeaveTowerTargetWave = 10 -- default wave to leave on
    local autoLeaveTowerThread = nil

    Tower:AddSlider("AutoLeaveTowerWave", {
        Text = "Auto Leave Wave",
        Default = autoLeaveTowerTargetWave,
        Min = 1,
        Max = 50,
        Rounding = 0,
        Tooltip = "Leave the Tower when wave number >= this",
        Callback = function(value)
            autoLeaveTowerTargetWave = math.max(1, math.floor(value or 1))
        end
    })

    Tower:AddToggle("AutoLeaveTowerOnWaveToggle", {
        Text = "Auto Leave Tower On Wave",
        Default = false,
        Tooltip = "Automatically leave the Tower when wave reaches target",
        Callback = function(enabled)
            autoLeaveTowerEnabled = enabled
            if enabled then
                autoLeaveTowerThread = task.spawn(function()
                    local Players = game:GetService("Players")
                    -- helper: robustly extract numeric wave from the Tower UI
                    local function tryGetTowerWave()
                        local ok, res = pcall(function()
                            local pl = Players.LocalPlayer
                            if not pl or not pl.PlayerGui then return nil end
                            local ui = pl.PlayerGui:FindFirstChild("UI")
                            if not ui then return nil end
                            local hud = ui:FindFirstChild("HUD")
                            if not hud then return nil end
                            local towerGui = hud:FindFirstChild("Tower")
                            if not towerGui then return nil end

                            -- The Wave value is under Tower.Frame.Wave.Value.UID (but UI can be structured differently)
                            local frame = towerGui:FindFirstChild("Frame") or towerGui
                            local waveNode = frame:FindFirstChild("Wave") or frame:FindFirstChildWhichIsA("Frame")
                            if not waveNode then
                                -- try searching descendants for something named 'Wave'
                                for _, v in ipairs(frame:GetDescendants()) do
                                    if v.Name == "Wave" then waveNode = v break end
                                end
                            end
                            if not waveNode then return nil end

                            -- Try the conventional path: Wave.Value.UID
                            local uid = nil
                            local valueNode = waveNode:FindFirstChild("Value")
                            if valueNode then
                                uid = valueNode:FindFirstChild("UID") or valueNode:FindFirstChildWhichIsA("TextLabel")
                            end
                            if not uid then
                                uid = waveNode:FindFirstChild("UID") or waveNode:FindFirstChildWhichIsA("TextLabel")
                            end
                            if not uid then
                                -- fallback: first TextLabel descendant inside waveNode
                                for _, d in ipairs(waveNode:GetDescendants()) do
                                    if d:IsA("TextLabel") then uid = d break end
                                end
                            end
                            if not uid then return nil end

                            local txt = nil
                            if uid:IsA("TextLabel") and uid.Text then txt = uid.Text end
                            if (not txt or txt == "") and uid.Value ~= nil then txt = tostring(uid.Value) end
                            if not txt or txt == "" then return nil end

                            -- try to extract an integer from text (e.g. "5" or "Wave 5")
                            local n = tonumber(txt) or tonumber(string.match(tostring(txt), "%d+"))
                            return n
                        end)
                        if ok then return res end
                        return nil
                    end

                    while autoLeaveTowerEnabled do
                        local curWave = tryGetTowerWave()
                        if curWave and curWave >= autoLeaveTowerTargetWave then
                            pcall(function()
                                local args = {
                                    [1] = "Gamemodes",
                                    [2] = "Tower",
                                    [3] = "Leave",
                                }
                                local rs = game:GetService("ReplicatedStorage")
                                local remotes = rs:WaitForChild("Remotes", 9e9)
                                local bridge = remotes:WaitForChild("Bridge", 9e9)
                                bridge:FireServer(unpack(args))
                            end)
                            -- After leaving, wait until the UI disappears or wave drops below target
                            while autoLeaveTowerEnabled do
                                task.wait(0.5)
                                local newWave = tryGetTowerWave()
                                if not newWave or newWave < autoLeaveTowerTargetWave then
                                    break
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                autoLeaveTowerEnabled = false
            end
        end
    })

---================================Trial=====================================--
    -- Auto Enter Trial
    local autoEnterTrialEnabled = false
    local autoEnterTrialThread = nil

    Trial:AddToggle("AutoEnterTrialToggle", {
        Text = "Auto Enter Trial",
        Default = false,
        Tooltip = "Spam join Trial every 0.5s if Trial UI is not visible",
        Callback = function(enabled)
            autoEnterTrialEnabled = enabled
            if enabled then
                autoEnterTrialThread = task.spawn(function()
                    while autoEnterTrialEnabled do
                        local player = game:GetService("Players").LocalPlayer
                        local char = player and player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        local trialUIVisible = false
                        pcall(function()
                            local trialUI = player.PlayerGui.UI.HUD.Trial
                            trialUIVisible = trialUI and trialUI.Visible
                        end)
                        if not trialUIVisible then
                            pcall(function()
                                local args = {
                                    [1] = "Gamemodes",
                                    [2] = "Trial",
                                    [3] = "Join",
                                }
                                local rs = game:GetService("ReplicatedStorage")
                                local remotes = rs:WaitForChild("Remotes", 9e9)
                                local bridge = remotes:WaitForChild("Bridge", 9e9)
                                bridge:FireServer(unpack(args))
                            end)
                        else
                            if not root then
                                task.wait(0.5)
                            else
                                -- Find closest Trial enemy (BasePart with ID and Health > 0)
                                local function getClosestTrialEnemy()
                                    local closest = nil
                                    local minDist = math.huge
                                    local ok, enemiesParent = pcall(function()
                                        return workspace:WaitForChild("Server", 9e9):WaitForChild("Gamemodes", 9e9):WaitForChild("Trial", 9e9):WaitForChild("Enemies", 9e9)
                                    end)
                                    if not ok or not enemiesParent then
                                        for _, obj in ipairs(workspace:GetDescendants()) do
                                            if obj:IsA("BasePart") then
                                                local ok2, id = pcall(function() return obj:GetAttribute("ID") end)
                                                if ok2 and id then
                                                    local ok3, health = pcall(function() return obj:GetAttribute("Health") end)
                                                    if ok3 and health and health > 0 then
                                                        local dist = (obj.Position - root.Position).Magnitude
                                                        if dist < minDist then
                                                            minDist = dist
                                                            closest = obj
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        return closest
                                    end
                                    for _, obj in ipairs(enemiesParent:GetDescendants()) do
                                        if obj:IsA("BasePart") then
                                            local ok2, id = pcall(function() return obj:GetAttribute("ID") end)
                                            if ok2 and id then
                                                local ok3, health = pcall(function() return obj:GetAttribute("Health") end)
                                                if ok3 and health and health > 0 then
                                                    local dist = (obj.Position - root.Position).Magnitude
                                                    if dist < minDist then
                                                        minDist = dist
                                                        closest = obj
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    return closest
                                end

                                local lastTarget = nil
                                while autoEnterTrialEnabled do
                                    local trialUI = player.PlayerGui.UI.HUD.Trial
                                    if not (trialUI and trialUI.Visible) then break end
                                    local target = getClosestTrialEnemy()
                                    if not target then
                                        task.wait(0.5)
                                        break
                                    end
                                    if target ~= lastTarget then
                                        pcall(function()
                                            root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                                        end)
                                        lastTarget = target
                                    end
                                    -- Attack the current target (Trial context)
                                    pcall(function()
                                        local attackArgs = {
                                            [1] = "Fighters",
                                            [2] = "Attack",
                                            [3] = "Attack_All",
                                            [4] = "Trial",
                                            [5] = target,
                                        }
                                        local rs = game:GetService("ReplicatedStorage")
                                        local remotes = rs:WaitForChild("Remotes", 9e9)
                                        local bridge = remotes:WaitForChild("Bridge", 9e9)
                                        bridge:FireServer(unpack(attackArgs))
                                    end)
                                    local ok, health = pcall(function() return target:GetAttribute("Health") end)
                                    if not ok or not health or health <= 0 then
                                        lastTarget = nil
                                        task.wait(0.5)
                                        continue
                                    end
                                    task.wait(0.5)
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                autoEnterTrialEnabled = false
            end
        end
    })

    -- Auto Leave Trial on specific wave (mirrors Tower behavior)
    local autoLeaveTrialEnabled = false
    local autoLeaveTrialTargetWave = 5 -- default trial wave to leave on
    local autoLeaveTrialThread = nil

    Trial:AddSlider("AutoLeaveTrialWave", {
        Text = "Auto Leave Wave (Trial)",
        Default = autoLeaveTrialTargetWave,
        Min = 1,
        Max = 50,
        Rounding = 0,
        Tooltip = "Leave the Trial when wave number >= this",
        Callback = function(value)
            autoLeaveTrialTargetWave = math.max(1, math.floor(value or 1))
        end
    })

    Trial:AddToggle("AutoLeaveTrialOnWaveToggle", {
        Text = "Auto Leave Trial On Wave",
        Default = false,
        Tooltip = "Automatically leave the Trial when wave reaches target",
        Callback = function(enabled)
            autoLeaveTrialEnabled = enabled
            if enabled then
                autoLeaveTrialThread = task.spawn(function()
                    local Players = game:GetService("Players")
                    local function tryGetTrialWave()
                        local ok, res = pcall(function()
                            local pl = Players.LocalPlayer
                            if not pl or not pl.PlayerGui then return nil end
                            local ui = pl.PlayerGui:FindFirstChild("UI")
                            if not ui then return nil end
                            local hud = ui:FindFirstChild("HUD")
                            if not hud then return nil end
                            local trialGui = hud:FindFirstChild("Trial")
                            if not trialGui then return nil end

                            local frame = trialGui:FindFirstChild("Frame") or trialGui
                            local waveNode = frame:FindFirstChild("Wave") or frame:FindFirstChildWhichIsA("Frame")
                            if not waveNode then
                                for _, v in ipairs(frame:GetDescendants()) do
                                    if v.Name == "Wave" then waveNode = v break end
                                end
                            end
                            if not waveNode then return nil end

                            local uid = nil
                            local valueNode = waveNode:FindFirstChild("Value")
                            if valueNode then
                                uid = valueNode:FindFirstChild("UID") or valueNode:FindFirstChildWhichIsA("TextLabel")
                            end
                            if not uid then
                                uid = waveNode:FindFirstChild("UID") or waveNode:FindFirstChildWhichIsA("TextLabel")
                            end
                            if not uid then
                                for _, d in ipairs(waveNode:GetDescendants()) do
                                    if d:IsA("TextLabel") then uid = d break end
                                end
                            end
                            if not uid then return nil end

                            local txt = nil
                            if uid:IsA("TextLabel") and uid.Text then txt = uid.Text end
                            if (not txt or txt == "") and uid.Value ~= nil then txt = tostring(uid.Value) end
                            if not txt or txt == "" then return nil end

                            local n = tonumber(txt) or tonumber(string.match(tostring(txt), "%d+"))
                            return n
                        end)
                        if ok then return res end
                        return nil
                    end

                    while autoLeaveTrialEnabled do
                        local curWave = tryGetTrialWave()
                        if curWave and curWave >= autoLeaveTrialTargetWave then
                            pcall(function()
                                local args = {
                                    [1] = "Gamemodes",
                                    [2] = "Trial",
                                    [3] = "Leave",
                                }
                                local rs = game:GetService("ReplicatedStorage")
                                local remotes = rs:WaitForChild("Remotes", 9e9)
                                local bridge = remotes:WaitForChild("Bridge", 9e9)
                                bridge:FireServer(unpack(args))
                            end)
                            -- After leaving, wait until the UI disappears or wave drops below target
                            while autoLeaveTrialEnabled do
                                task.wait(0.5)
                                local newWave = tryGetTrialWave()
                                if not newWave or newWave < autoLeaveTrialTargetWave then
                                    break
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                autoLeaveTrialEnabled = false
            end
        end
    })

-- =================== Auto Reroll Traits ===================
-- Helper: build fighter dropdown values and map for the local player
local rerollFighterMap = {}
local rerollFighterDropdownRef = nil
local statsFighterDropdownRef = nil
local selectedRerollFighterId = nil
local selectedStatsRerollFighterId = nil

local function refreshRerollFighterList()
    local values = {}
    rerollFighterMap = {}
    local ok, client = pcall(function() return workspace:FindFirstChild("Client") end)
    if not ok or not client then
        if rerollFighterDropdownRef and rerollFighterDropdownRef.SetValues then
            rerollFighterDropdownRef:SetValues({})
        end
        return
    end
    local fightersFolder = client:FindFirstChild("Fighters")
    if not fightersFolder then
        if rerollFighterDropdownRef and rerollFighterDropdownRef.SetValues then
            rerollFighterDropdownRef:SetValues({})
        end
        return
    end
    local PlayersSvc = game:GetService("Players")
    local pl = PlayersSvc.LocalPlayer
    if not pl then
        if rerollFighterDropdownRef and rerollFighterDropdownRef.SetValues then
            rerollFighterDropdownRef:SetValues({})
        end
        return
    end
    local playerFolder = fightersFolder:FindFirstChild(tostring(pl.UserId))
    if not playerFolder then
        if rerollFighterDropdownRef and rerollFighterDropdownRef.SetValues then
            rerollFighterDropdownRef:SetValues({})
        end
        return
    end

    local entries = {}
    local counts = {}
    for _, model in ipairs(playerFolder:GetChildren()) do
        if model and model:IsA("Model") then
            local ok2, attrName = pcall(function() return model:GetAttribute("Name") end)
            local base = (ok2 and attrName) and tostring(attrName) or tostring(model.Name)
            table.insert(entries, { base = base, id = model.Name })
            counts[base] = (counts[base] or 0) + 1
        end
    end
    local seq = {}
    for _, e in ipairs(entries) do
        local display = e.base
        if counts[e.base] and counts[e.base] > 1 then
            seq[e.base] = (seq[e.base] or 0) + 1
            display = e.base .. " #" .. tostring(seq[e.base])
        end
        table.insert(values, display)
        rerollFighterMap[display] = e.id
    end
    if rerollFighterDropdownRef and rerollFighterDropdownRef.SetValues then
        pcall(function() rerollFighterDropdownRef:SetValues(values) end)
    end
    if statsFighterDropdownRef and statsFighterDropdownRef.SetValues then
        pcall(function() statsFighterDropdownRef:SetValues(values) end)
    end
    if fuseDropdownRef and fuseDropdownRef.SetValues then
        pcall(function() fuseDropdownRef:SetValues(values) end)
    end
end

rerollFighterDropdownRef = Reroll:AddDropdown("RerollFighterDropdown", {
    Text = "Select Fighter",
    Default = "",
    Values = {},
    Tooltip = "Select the fighter to reroll traits for",
    Callback = function(selection)
        selectedRerollFighterId = rerollFighterMap[selection]
    end
})

-- Refresh fighter list periodically in background so UI stays up-to-date
task.spawn(function()
    while true do
        refreshRerollFighterList()
        task.wait(2)
    end
end)

-- Trait list in desired UI sorting (matches provided image)
local traitList = {
    "Fortune", "Vigor", "Swift", "Vigor II",
    "Swift II", "Fortune II", "Swift III", "Clover I",
    "Fortune III", "Vigor III", "Clover II", "Scholar",
    "Strongest", "Clover III", "Monarch",
}

local traitToggles = {}
local traitToggleRefs = {} -- store UI toggle refs so we can update their visible state
-- Select All toggle
local selectAllTraits = false
Reroll:AddToggle("RerollSelectAllTraits", {
    Text = "Select All Traits",
    Default = false,
    Tooltip = "Toggle all trait toggles on/off",
    Callback = function(state)
        selectAllTraits = state
        for _, name in ipairs(traitList) do
            traitToggles[name] = state
            local ref = traitToggleRefs[name]
            if ref and type(ref.SetValue) == "function" then
                pcall(function() ref:SetValue(state) end)
            end
        end
    end
})

-- Add individual trait toggles (keep refs)
for _, tname in ipairs(traitList) do
    traitToggles[tname] = false
    local ref = Reroll:AddToggle(tname:gsub(" ", "_"), {
        Text = tname,
        Default = false,
        Tooltip = "Include this trait when rerolling",
        Callback = (function(name)
            return function(state)
                traitToggles[name] = state
            end
        end)(tname)
    })
    -- store the returned UI object if available
    traitToggleRefs[tname] = ref
end

-- Auto Reroll loop
local autoRerollTraitsEnabled = false
local autoRerollTraitsThread = nil

Reroll:AddToggle("AutoRerollTraitsToggle", {
    Text = "Auto Reroll Traits",
    Default = false,
    Tooltip = "Automatically call Traits/Reroll for the selected fighter and trait map",
    Callback = function(enabled)
        autoRerollTraitsEnabled = enabled
        if enabled then
            autoRerollTraitsThread = task.spawn(function()
                while autoRerollTraitsEnabled do
                    if selectedRerollFighterId and selectedRerollFighterId ~= "" then
                        -- If the Traits UI currently shows a trait that we have selected to keep,
                        -- pause rerolling until the UI no longer shows that trait (i.e., it changed)
                        local function getCurrentTraitText()
                            local txt = nil
                            pcall(function()
                                local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                                local val = playerGui and playerGui.UI and playerGui.UI.Frames and playerGui.UI.Frames.Traits and playerGui.UI.Frames.Traits.Frame and playerGui.UI.Frames.Traits.Frame.Trait and playerGui.UI.Frames.Traits.Frame.Trait.CanvasGroup and playerGui.UI.Frames.Traits.Frame.Trait.CanvasGroup.Value
                                if val and val:IsA("TextLabel") then
                                    txt = tostring(val.Text)
                                end
                            end)
                            return txt
                        end

                        local curTrait = getCurrentTraitText()
                        if curTrait and traitToggles[curTrait] then
                            -- Wait until trait changes to something not selected (or toggles change)
                            while autoRerollTraitsEnabled do
                                task.wait(0.5)
                                curTrait = getCurrentTraitText()
                                if not curTrait or not traitToggles[curTrait] then break end
                            end
                            -- continue to next iteration (re-evaluate)
                            task.wait(0.5)
                        end

                        -- Build trait map exactly like the sample: name->bool
                        local traitArgsMap = {}
                        for _, name in ipairs(traitList) do
                            traitArgsMap[name] = traitToggles[name] or false
                        end

                        if not autoRerollTraitsEnabled then break end
                        pcall(function()
                            local args = {
                                [1] = "General",
                                [2] = "Traits",
                                [3] = "Reroll",
                                [4] = selectedRerollFighterId,
                                [5] = traitArgsMap,
                            }
                            local rs = game:GetService("ReplicatedStorage")
                            local remotes = rs:WaitForChild("Remotes", 9e9)
                            local bridge = remotes:WaitForChild("Bridge", 9e9)
                            bridge:FireServer(unpack(args))
                        end)
                    end
                    task.wait(0.5)
                end
            end)
        else
            autoRerollTraitsEnabled = false
        end
    end
})

    -- =================== Stats Reroll ===================

    -- Auto Stats Reroll (All)
    local autoStatsRerollEnabled = false
    local autoStatsRerollThread = nil
    local statsMonitorTarget = "All" -- All | Attack | SPA | Ultimate
    local statsMonitorRank = "S" -- desired rank to stop at
    local validRanks = {"D","C","B","A","S","Z","Z+"}
    local function getStatRankUI(stat)
        local ok, txt = pcall(function()
            local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
            if not playerGui then return nil end
            local base = playerGui.UI and playerGui.UI.Frames and playerGui.UI.Frames.StatsReroll and playerGui.UI.Frames.StatsReroll.Frame and playerGui.UI.Frames.StatsReroll.Frame.Stats
            if not base then return nil end
            local node = base[stat]
            if not node then return nil end
            local val = node.Frame and node.Frame.Stats_Rank and node.Frame.Stats_Rank.Value
            if val and val:IsA("TextLabel") then
                return tostring(val.Text)
            end
            return nil
        end)
        if ok then return txt end
        return nil
    end

    -- Stats monitor dropdowns
    StatsReroll:AddDropdown("StatsRerollMonitorTarget", {
        Text = "Monitor Stat",
        Default = statsMonitorTarget,
        Values = {"All","Attack","SPA","Ultimate"},
        Tooltip = "Choose which stat to monitor (All = any stat)",
        Callback = function(selection)
            statsMonitorTarget = selection
        end
    })

    StatsReroll:AddDropdown("StatsRerollMonitorRank", {
        Text = "Target Rank",
        Default = statsMonitorRank,
        Values = validRanks,
        Tooltip = "Stop rerolling when the monitored stat reaches this rank",
        Callback = function(selection)
            statsMonitorRank = selection
        end
    })
    StatsReroll:AddToggle("AutoStatsRerollAll", {
        Text = "Auto Reroll All Stats",
        Default = false,
        Tooltip = "Automatically call StatsReroll All for selected fighter",
        Callback = function(enabled)
            autoStatsRerollEnabled = enabled
            if enabled then
                autoStatsRerollThread = task.spawn(function()
                                while autoStatsRerollEnabled do
                                    if selectedStatsRerollFighterId and selectedStatsRerollFighterId ~= "" then
                                        -- Before firing, check monitored stat(s) in UI. If any monitored stat equals desired rank, pause until it changes.
                                        local function anyMonitoredAtTarget()
                                            if statsMonitorTarget == "All" then
                                                local a = getStatRankUI("Attack")
                                                local s = getStatRankUI("SPA")
                                                local u = getStatRankUI("Ultimate")
                                                if (a and tostring(a) == tostring(statsMonitorRank)) or (s and tostring(s) == tostring(statsMonitorRank)) or (u and tostring(u) == tostring(statsMonitorRank)) then
                                                    return true
                                                end
                                                return false
                                            else
                                                local cur = getStatRankUI(statsMonitorTarget)
                                                return cur and tostring(cur) == tostring(statsMonitorRank)
                                            end
                                        end

                                        if anyMonitoredAtTarget() then
                                            -- wait until none of monitored stats equal target (or toggle disabled)
                                            while autoStatsRerollEnabled and anyMonitoredAtTarget() do
                                                task.wait(0.5)
                                            end
                                            if not autoStatsRerollEnabled then break end
                                        end

                                        if not autoStatsRerollEnabled then break end
                                        pcall(function()
                                            local args = {
                                                [1] = "General",
                                                [2] = "StatsReroll",
                                                [3] = "All",
                                                [4] = selectedStatsRerollFighterId,
                                            }
                                            local rs = game:GetService("ReplicatedStorage")
                                            local remotes = rs:WaitForChild("Remotes", 9e9)
                                            local bridge = remotes:WaitForChild("Bridge", 9e9)
                                            bridge:FireServer(unpack(args))
                                        end)
                                    end
                                    task.wait(0.5)
                                end
                end)
            else
                autoStatsRerollEnabled = false
            end
        end
    })

    -- Manual single-stat reroll buttons
    statsFighterDropdownRef = StatsReroll:AddDropdown("StatsRerollFighterDropdown", {
        Text = "Select Fighter",
        Default = "",
        Values = {},
        Tooltip = "Select fighter for stats reroll",
        Callback = function(selection)
            selectedStatsRerollFighterId = rerollFighterMap[selection]
        end
    })

    StatsReroll:AddButton("RerollAttack", function()
        if not selectedStatsRerollFighterId or selectedStatsRerollFighterId == "" then return end
        -- If monitor rank is set and current Attack rank equals it, skip reroll
        local curAttack = getStatRankUI and getStatRankUI("Attack") or nil
        if curAttack and tostring(curAttack) == tostring(statsMonitorRank) then
            pcall(function()
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Stats Reroll"; Text = "Attack already at target rank; skipped."; Duration = 3;})
                end)
            end)
            return
        end
        pcall(function()
            local args = {
                [1] = "General",
                [2] = "StatsReroll",
                [3] = "Single",
                [4] = selectedStatsRerollFighterId,
                [5] = "Attack",
            }
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:WaitForChild("Remotes", 9e9)
            local bridge = remotes:WaitForChild("Bridge", 9e9)
            bridge:FireServer(unpack(args))
        end)
    end)

    StatsReroll:AddButton("RerollSpeedAttack", function()
        if not selectedStatsRerollFighterId or selectedStatsRerollFighterId == "" then return end
        -- If monitor rank is set and current SPA rank equals it, skip reroll
        local curSPA = getStatRankUI and getStatRankUI("SPA") or nil
        if curSPA and tostring(curSPA) == tostring(statsMonitorRank) then
            pcall(function()
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Stats Reroll"; Text = "SPA already at target rank; skipped."; Duration = 3;})
                end)
            end)
            return
        end
        pcall(function()
            local args = {
                [1] = "General",
                [2] = "StatsReroll",
                [3] = "Single",
                [4] = selectedStatsRerollFighterId,
                [5] = "SPA",
            }
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:WaitForChild("Remotes", 9e9)
            local bridge = remotes:WaitForChild("Bridge", 9e9)
            bridge:FireServer(unpack(args))
        end)
    end)

    StatsReroll:AddButton("RerollUltimate", function()
        if not selectedStatsRerollFighterId or selectedStatsRerollFighterId == "" then return end
        -- If monitor rank is set and current Ultimate rank equals it, skip reroll
        local curUlt = getStatRankUI and getStatRankUI("Ultimate") or nil
        if curUlt and tostring(curUlt) == tostring(statsMonitorRank) then
            pcall(function()
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Stats Reroll"; Text = "Ultimate already at target rank; skipped."; Duration = 3;})
                end)
            end)
            return
        end
        pcall(function()
            local args = {
                [1] = "General",
                [2] = "StatsReroll",
                [3] = "Single",
                [4] = selectedStatsRerollFighterId,
                [5] = "Ultimate",
            }
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:WaitForChild("Remotes", 9e9)
            local bridge = remotes:WaitForChild("Bridge", 9e9)
            bridge:FireServer(unpack(args))
        end)
    end)

    -- Keep fighter dropdowns in sync: if fuseDropdownRef exists, update it when we refresh
    local function syncFighterDropdowns(values)
        if rerollFighterDropdownRef and rerollFighterDropdownRef.SetValues then
            pcall(function() rerollFighterDropdownRef:SetValues(values) end)
        end
        if fuseDropdownRef and fuseDropdownRef.SetValues then
            pcall(function() fuseDropdownRef:SetValues(values) end)
        end
    end

---==================================Settings================================--

local VirtualInputManager = game:GetService("VirtualInputManager")

-- Custom Watermark setup (independent of UI scaling)
local CoreGui = game:GetService("CoreGui")

-- Create independent watermark ScreenGui
local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "SeisenWatermark"
WatermarkGui.DisplayOrder = 999999
WatermarkGui.IgnoreGuiInset = true
WatermarkGui.ResetOnSpawn = false
WatermarkGui.Parent = CoreGui

-- Create watermark frame (main container)
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Name = "WatermarkFrame"
WatermarkFrame.Size = UDim2.new(0, 100, 0, 120) -- Taller container for vertical layout
WatermarkFrame.Position = UDim2.new(0, 10, 0, 100) -- Default position (lower)
WatermarkFrame.BackgroundTransparency = 1 -- Transparent container
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.Parent = WatermarkGui

-- Create perfect circular logo frame
local CircleFrame = Instance.new("Frame")
CircleFrame.Name = "CircleFrame"
CircleFrame.Size = UDim2.new(0, 60, 0, 60) -- Perfect square = perfect circle
CircleFrame.Position = UDim2.new(0.5, -30, 0, 0) -- Centered horizontally at top
CircleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CircleFrame.BorderSizePixel = 0
CircleFrame.Parent = WatermarkFrame

-- Create circular corner (makes it a perfect circle)
local WatermarkCorner = Instance.new("UICorner")
WatermarkCorner.CornerRadius = UDim.new(0.5, 0) -- 50% radius = perfect circle
WatermarkCorner.Parent = CircleFrame

-- Create custom logo/image
local WatermarkImage = Instance.new("ImageLabel")
WatermarkImage.Name = "WatermarkImage"
WatermarkImage.Size = UDim2.new(1, 0, 1, 0) -- Fill the entire circle frame
WatermarkImage.Position = UDim2.new(0, 0, 0, 0) -- Cover the entire circle
WatermarkImage.BackgroundTransparency = 1
WatermarkImage.ImageColor3 = Color3.fromRGB(255, 255, 255) -- White tint
WatermarkImage.ScaleType = Enum.ScaleType.Crop -- Crop to fill the circle
WatermarkImage.Parent = CircleFrame

-- Make the image circular to match the frame
local ImageCorner = Instance.new("UICorner")
ImageCorner.CornerRadius = UDim.new(0.5, 0) -- Same circular radius as the frame
ImageCorner.Parent = WatermarkImage

-- Try multiple image formats for better compatibility
local imageFormats = {
    "rbxassetid://125926861378074",
    "http://www.roblox.com/asset/?id=125926861378074",
}

-- Function to try loading the image
local function tryLoadImage()
    for i, imageId in ipairs(imageFormats) do
        WatermarkImage.Image = imageId
        
        -- Wait a bit to see if image loads
        task.wait(0.5)
        
        -- Check if image loaded (non-zero size means it loaded)
        if WatermarkImage.AbsoluteSize.X > 0 and WatermarkImage.AbsoluteSize.Y > 0 then
            print("✅ Watermark image loaded successfully with format:", imageId)
            break
        elseif i == #imageFormats then
            -- If all formats fail, use a text fallback
            print("⚠️ Could not load custom image, using text fallback")
            WatermarkImage.Image = ""
            
            -- Create text fallback
            local FallbackText = Instance.new("TextLabel")
            FallbackText.Size = UDim2.new(1, 0, 1, 0)
            FallbackText.Position = UDim2.new(0, 0, 0, 0)
            FallbackText.BackgroundTransparency = 1
            FallbackText.Text = "S"
            FallbackText.TextColor3 = Color3.fromRGB(125, 85, 255) -- Accent color
            FallbackText.TextSize = 24
            FallbackText.Font = Enum.Font.GothamBold
            FallbackText.TextXAlignment = Enum.TextXAlignment.Center
            FallbackText.TextYAlignment = Enum.TextYAlignment.Center
            FallbackText.Parent = CircleFrame
        end
    end
end

-- Try loading the image
task.spawn(tryLoadImage)

-- Create Hub Name text
local HubNameText = Instance.new("TextLabel")
HubNameText.Name = "HubNameText"
HubNameText.Size = UDim2.new(1, 0, 0, 20)
HubNameText.Position = UDim2.new(0, 0, 0, 65) -- Below the circle
HubNameText.BackgroundTransparency = 1
HubNameText.Text = "Seisenhub"
HubNameText.TextColor3 = Color3.fromRGB(255, 255, 255)
HubNameText.TextSize = 14
HubNameText.Font = Enum.Font.GothamBold
HubNameText.TextXAlignment = Enum.TextXAlignment.Center
HubNameText.TextYAlignment = Enum.TextYAlignment.Center
HubNameText.TextStrokeTransparency = 0.5
HubNameText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
HubNameText.Parent = WatermarkFrame

-- Create FPS text
local FPSText = Instance.new("TextLabel")
FPSText.Name = "FPSText"
FPSText.Size = UDim2.new(1, 0, 0, 16)
FPSText.Position = UDim2.new(0, 0, 0, 85) -- Below hub name
FPSText.BackgroundTransparency = 1
FPSText.Text = "60 fps"
FPSText.TextColor3 = Color3.fromRGB(200, 200, 200)
FPSText.TextSize = 12
FPSText.Font = Enum.Font.Code
FPSText.TextXAlignment = Enum.TextXAlignment.Center
FPSText.TextYAlignment = Enum.TextYAlignment.Center
FPSText.TextStrokeTransparency = 0.5
FPSText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
FPSText.Parent = WatermarkFrame

-- Create Ping text
local PingText = Instance.new("TextLabel")
PingText.Name = "PingText"
PingText.Size = UDim2.new(1, 0, 0, 16)
PingText.Position = UDim2.new(0, 0, 0, 101) -- Below FPS
PingText.BackgroundTransparency = 1
PingText.Text = "60 ms"
PingText.TextColor3 = Color3.fromRGB(200, 200, 200)
PingText.TextSize = 12
PingText.Font = Enum.Font.Code
PingText.TextXAlignment = Enum.TextXAlignment.Center
PingText.TextYAlignment = Enum.TextYAlignment.Center
PingText.TextStrokeTransparency = 0.5
PingText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
PingText.Parent = WatermarkFrame

-- Make watermark draggable
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local dragging = false
local dragStart = nil
local startPos = nil

-- Mouse/touch input for dragging and UI toggle
local dragThreshold = 5 -- Pixels moved before considering it a drag
local clickStartPos = nil

-- Global input connections for better drag handling
local inputBeganConnection = nil
local inputChangedConnection = nil
local inputEndedConnection = nil

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false -- Reset dragging state
        dragStart = input.Position
        clickStartPos = input.Position
        startPos = WatermarkFrame.Position
        
        -- Visual feedback - slightly fade the circle frame
        local fadeInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local fadeTween = TweenService:Create(CircleFrame, fadeInfo, {BackgroundTransparency = 0.3})
        fadeTween:Play()
        
        -- Connect global input events for smooth dragging
        if inputChangedConnection then inputChangedConnection:Disconnect() end
        if inputEndedConnection then inputEndedConnection:Disconnect() end
        
        inputChangedConnection = UserInputService.InputChanged:Connect(function(globalInput)
            if globalInput.UserInputType == Enum.UserInputType.MouseMovement or globalInput.UserInputType == Enum.UserInputType.Touch then
                if dragStart then
                    local delta = globalInput.Position - dragStart
                    local distance = math.sqrt(delta.X^2 + delta.Y^2)
                    
                    -- Only start dragging if moved beyond threshold
                    if distance > dragThreshold then
                        dragging = true
                        WatermarkFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end
            end
        end)
        
        inputEndedConnection = UserInputService.InputEnded:Connect(function(globalInput)
            if globalInput.UserInputType == Enum.UserInputType.MouseButton1 or globalInput.UserInputType == Enum.UserInputType.Touch then
                -- Restore original transparency
                local restoreInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local restoreTween = TweenService:Create(CircleFrame, restoreInfo, {BackgroundTransparency = 0})
                restoreTween:Play()
                
                -- If it wasn't a drag, treat it as a click to toggle UI
                if not dragging and clickStartPos then
                    local delta = globalInput.Position - clickStartPos
                    local distance = math.sqrt(delta.X^2 + delta.Y^2)
                    
                    if distance <= dragThreshold then
                        -- Toggle UI visibility
                        Library:Toggle()
                        print("🔄 UI toggled via watermark click")
                    end
                end
                
                -- Reset states and disconnect global events
                dragging = false
                dragStart = nil
                clickStartPos = nil
                
                if inputChangedConnection then inputChangedConnection:Disconnect() end
                if inputEndedConnection then inputEndedConnection:Disconnect() end
            end
        end)
    end
end

-- Connect only the initial input event to the watermark frame
WatermarkFrame.InputBegan:Connect(onInputBegan)

-- Dynamic watermark with FPS and Ping (completely independent)
local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    -- Update custom watermark text
    pcall(function()
        local pingValue = game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()
        
        -- Update individual text elements
        FPSText.Text = math.floor(FPS) .. " fps"
        PingText.Text = math.floor(pingValue) .. " ms"
        
        -- No need to resize frame - it's now fixed size for vertical layout
    end)
end)

-- WalkSpeed and Fly controls
-- Local state vars so we can reapply on respawn
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local walkSpeedValue = config.WalkSpeed or 16
local flyEnabled = false
local flySpeed = config.FlySpeed or 50
local flyHeartbeatConn = nil
local flyInputConns = {}
local flyBV = nil
local enforceWalkConn = nil
local originalWalkSpeed = nil

-- Utility to safely set humanoid walkspeedac
local function applyWalkSpeedToCharacter(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if originalWalkSpeed == nil then
            originalWalkSpeed = humanoid.WalkSpeed
        end
        humanoid.WalkSpeed = walkSpeedValue or 16
    end
end

-- Ensure walk speed stays applied (some tools or scripts may reset WalkSpeed)
local function ensureWalkSpeedEnforced()
    if enforceWalkConn then return end
    enforceWalkConn = RunService.Heartbeat:Connect(function()
        local pl = Players.LocalPlayer
        if not pl or not pl.Character then return end
        local humanoid = pl.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= (walkSpeedValue or 16) then
            humanoid.WalkSpeed = (walkSpeedValue or 16)
        end
    end)
end

-- Ensure we apply walk speed on respawn
if LocalPlayer then
    if LocalPlayer.Character then
        applyWalkSpeedToCharacter(LocalPlayer.Character)
    end
    -- Start enforcing WalkSpeed right away for the current character (if present)
    ensureWalkSpeedEnforced()
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        applyWalkSpeedToCharacter(char)
        -- If fly was enabled before respawn, re-enable for new character
        if flyEnabled then
            -- small delay to ensure HumanoidRootPart exists
            task.spawn(function()
                task.wait(0.15)
                -- re-initialize fly for the new character
                if flyEnabled then
                    -- reuse the toggle's enabling logic below by toggling off/on
                    -- but here we'll just ensure a BV is created by calling the enable logic
                end
            end)
        end
        -- Re-establish enforcement for the new character
        ensureWalkSpeedEnforced()
    end)
end

-- Walk Speed slider
PlayerSettings:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Default = walkSpeedValue,
    Min = 0,
    Max = 300,
    Rounding = 0,
    Tooltip = "Sets your humanoid walk speed",
    Callback = function(value)
        walkSpeedValue = value
        if Players.LocalPlayer and Players.LocalPlayer.Character then
            local humanoid = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = walkSpeedValue
            end
        end
        -- Start enforcing the selected WalkSpeed so tools cannot reset it
        ensureWalkSpeedEnforced()
    end
})

-- Fly speed slider
PlayerSettings:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = flySpeed,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Tooltip = "Speed used while flying",
    Callback = function(value)
        flySpeed = value
    end
})

-- Simple fly implementation using BodyVelocity and input tracking
local moveState = {Forward=false,Back=false,Left=false,Right=false,Up=false,Down=false}

local function enableFly()
    if not Players.LocalPlayer then return end
    local character = Players.LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Create BodyVelocity
    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "Seisen_FlyBV"
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.new(0,0,0)
    flyBV.P = 1250
    flyBV.Parent = root

    -- Heartbeat to apply velocity based on camera
    local camera = workspace.CurrentCamera
    flyHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not flyBV or not flyEnabled or not root then return end
        local camCFrame = camera and camera.CFrame or CFrame.new()
        local lookVector = camCFrame.LookVector
        local rightVector = camCFrame.RightVector
        local moveVec = Vector3.new(0,0,0)

        if moveState.Forward then moveVec = moveVec + Vector3.new(lookVector.X, 0, lookVector.Z) end
        if moveState.Back then moveVec = moveVec - Vector3.new(lookVector.X, 0, lookVector.Z) end
        if moveState.Right then moveVec = moveVec + Vector3.new(rightVector.X, 0, rightVector.Z) end
        if moveState.Left then moveVec = moveVec - Vector3.new(rightVector.X, 0, rightVector.Z) end
        if moveState.Up then moveVec = moveVec + Vector3.new(0,1,0) end
        if moveState.Down then moveVec = moveVec - Vector3.new(0,1,0) end

        if moveVec.Magnitude > 0 then
            moveVec = moveVec.Unit * (flySpeed or 50)
        else
            moveVec = Vector3.new(0,0,0)
        end

        -- Preserve vertical momentum if no up/down input
        flyBV.Velocity = Vector3.new(moveVec.X, moveVec.Y, moveVec.Z)
    end)

    -- Input handlers
    flyInputConns.InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then moveState.Forward = true end
        if input.KeyCode == Enum.KeyCode.S then moveState.Back = true end
        if input.KeyCode == Enum.KeyCode.A then moveState.Left = true end
        if input.KeyCode == Enum.KeyCode.D then moveState.Right = true end
        if input.KeyCode == Enum.KeyCode.Space then moveState.Up = true end
        if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then moveState.Down = true end
    end)

    flyInputConns.InputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        if input.KeyCode == Enum.KeyCode.W then moveState.Forward = false end
        if input.KeyCode == Enum.KeyCode.S then moveState.Back = false end
        if input.KeyCode == Enum.KeyCode.A then moveState.Left = false end
        if input.KeyCode == Enum.KeyCode.D then moveState.Right = false end
        if input.KeyCode == Enum.KeyCode.Space then moveState.Up = false end
        if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then moveState.Down = false end
    end)

    -- Make sure character's humanoid doesn't interfere much
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- reduce fall/ragdoll interference
        humanoid.PlatformStand = false
    end
end

local function disableFly()
    if flyHeartbeatConn then
        flyHeartbeatConn:Disconnect()
        flyHeartbeatConn = nil
    end
    if flyInputConns.InputBegan then flyInputConns.InputBegan:Disconnect() flyInputConns.InputBegan = nil end
    if flyInputConns.InputEnded then flyInputConns.InputEnded:Disconnect() flyInputConns.InputEnded = nil end
    if flyBV and flyBV.Parent then
        pcall(function() flyBV:Destroy() end)
    end
    flyBV = nil
    moveState = {Forward=false,Back=false,Left=false,Right=false,Up=false,Down=false}
end

-- Fly toggle
PlayerSettings:AddToggle("FlyToggle", {
    Text = "Fly (Simple)",
    Default = flyEnabled,
    Tooltip = "Enable a simple fly mode (WASD + Space/Ctrl)",
    Callback = function(value)
        flyEnabled = value
        if flyEnabled then
            enableFly()
        else
            disableFly()
        end
    end
})



Settings:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})


-- No Notification Toggle
local noNotificationEnabled = false
local function setNotificationVisibility(state)
    local player = game:GetService("Players").LocalPlayer
    local notif
    pcall(function()
        notif = player.PlayerGui.Notification.HUD.Notifications
    end)
    if notif then
        notif.Visible = not state
    end
end

Settings:AddToggle("NoNotificationToggle", {
    Text = "No Notification",
    Default = false,
    Tooltip = "Hide game notifications when enabled.",
    Callback = function(state)
        noNotificationEnabled = state
        setNotificationVisibility(state)
    end
})

-- Auto Redeem Codes: periodically redeem known promo codes
local autoRedeemRunning = false
local autoRedeemThread = nil
local redeemCodes = {
    "LEVELING","ARISE","QOL","PIRATES","FRIEZA","RELEASE","EARLYACCESS","AKAT","FIXDROPS","ZCITY","Rework",
}

local function redeemCode(code)
    pcall(function()
        local args = {
            [1] = "General",
            [2] = "Codes",
            [3] = "Redeem",
            [4] = code,
        }
        local rs = game:GetService("ReplicatedStorage")
        local remotes = rs:WaitForChild("Remotes", 9e9)
        local bridge = remotes:WaitForChild("Bridge", 9e9)
        bridge:FireServer(unpack(args))
    end)
end

Settings:AddToggle("AutoRedeemCodes", {
    Text = "Auto Redeem Codes",
    Default = false,
    Tooltip = "Redeem known promo codes periodically",
    Callback = function(enabled)
        autoRedeemRunning = enabled
        if enabled then
            autoRedeemThread = task.spawn(function()
                while autoRedeemRunning do
                    for _, code in ipairs(redeemCodes) do
                        if not autoRedeemRunning then break end
                        redeemCode(code)
                        task.wait(0.25)
                    end
                    -- Wait before retrying all codes to avoid spamming
                    local waitTime = 60 -- seconds
                    local elapsed = 0
                    while autoRedeemRunning and elapsed < waitTime do
                        task.wait(1)
                        elapsed = elapsed + 1
                    end
                end
            end)
        else
            autoRedeemRunning = false
        end
    end
})

Settings:AddToggle("AutoHideUI", {
    Text = "Auto Hide UI",
    Default = config.AutoHideUIEnabled or false,
    Tooltip = "Automatically hide the UI on script load",
    Callback = function(value)
        autoHideUIEnabled = value
        if value then
            Library:Toggle(false) -- Hide UI
            Library.ShowCustomCursor = false -- Disable custom cursor
        else
            Library:Toggle(true) -- Show UI
            Library.ShowCustomCursor = true -- Enable custom cursor (restore)
        end
    end
})

local antiAfkEnabled = false
local antiAfkConnection = nil

local function enableAntiAfk()
    if antiAfkConnection == nil then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local vu = game:GetService("VirtualUser")
        antiAfkConnection = player.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0,0))
        end)
    end
end

local function disableAntiAfk()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
end

Settings:AddToggle("AntiAfkToggle", {
    Text = "Anti-AFK",
    Default = false,
    Tooltip = "Prevents Roblox from kicking you for being idle.",
    Callback = function(state)
        antiAfkEnabled = state
        if state then
            enableAntiAfk()
        else
            disableAntiAfk()
        end
    end
})

Settings:AddToggle(
    "FPSBoostToggle",
    {
        Text = "FPS Boost (Lower Graphics)",
        Default = config.FPSBoostToggle or false,
        Callback = function(Value)
        -- Robust inline logic
            local Lighting = game:GetService("Lighting")
            local workspace = game:GetService("Workspace")
            if not originalFPSValues then originalFPSValues = {} end
            if not originalLightingValues then originalLightingValues = {} end
            if not originalTerrainValues then originalTerrainValues = {} end
            if Value then
                -- Enable FPS boost
                if Lighting then
                    if not originalLightingValues.GlobalShadows then
                        originalLightingValues.GlobalShadows = Lighting.GlobalShadows
                        originalLightingValues.FogEnd = Lighting.FogEnd
                        originalLightingValues.Brightness = Lighting.Brightness
                    end
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 100000
                    Lighting.Brightness = 1
                end
                if workspace:FindFirstChild("Terrain") then
                    local Terrain = workspace.Terrain
                    if not originalTerrainValues.WaterWaveSize then
                        originalTerrainValues.WaterWaveSize = Terrain.WaterWaveSize
                        originalTerrainValues.WaterWaveSpeed = Terrain.WaterWaveSpeed
                        originalTerrainValues.WaterReflectance = Terrain.WaterReflectance
                        originalTerrainValues.WaterTransparency = Terrain.WaterTransparency
                    end
                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveSpeed = 0
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 1
                end
                local maxObjects = 1000
                local count = 0
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if count > maxObjects then break end
                    if obj:IsA("Decal") or obj:IsA("Texture") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Type = "Decal", Transparency = obj.Transparency}
                        end
                        obj.Transparency = 1
                        count = count + 1
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Type = "Emitter", Enabled = obj.Enabled}
                        end
                        pcall(function() obj.Enabled = false end)
                        count = count + 1
                    elseif obj:IsA("Humanoid") then
                        if originalFPSValues[obj] == nil then
                            local playing = {}
                            for _, track in ipairs(obj:GetPlayingAnimationTracks()) do
                                table.insert(playing, track)
                                pcall(function() track:Stop() end)
                            end
                            originalFPSValues[obj] = {Type = "Humanoid", Tracks = playing}
                        end
                        count = count + 1
                    elseif obj:IsA("MeshPart") then
                        -- Only change RenderFidelity for MeshParts that are not SolidModels
                        if obj.ClassName == "MeshPart" and not obj:IsA("SolidModel") then
                            local rfKey = tostring(obj).."_RenderFidelity"
                            if originalFPSValues[rfKey] == nil then
                                originalFPSValues[rfKey] = {Type = "RenderFidelity", RenderFidelity = obj.RenderFidelity}
                            end
                            pcall(function()
                                if obj.RenderFidelity ~= nil and obj:IsDescendantOf(workspace) then
                                    obj.RenderFidelity = Enum.RenderFidelity.Performance
                                end
                            end)
                            count = count + 1
                        end
                    elseif obj:IsA("Sound") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Type = "Sound", Volume = obj.Volume}
                        end
                        obj.Volume = 0
                        count = count + 1
                    end
                end

                -- Remove post-processing effects from Lighting
                local Lighting = game:GetService("Lighting")
                for _, effect in ipairs({"BlurEffect", "SunRaysEffect", "ColorCorrectionEffect", "BloomEffect", "DepthOfFieldEffect"}) do
                    for _, v in ipairs(Lighting:GetChildren()) do
                        if v.ClassName == effect then
                            if originalFPSValues[v] == nil then
                                originalFPSValues[v] = {Type = "Effect", Parent = v.Parent}
                end
                            v.Parent = nil -- Remove from Lighting
                        end
                    end
                end
                if fpsBoostConnection then
                    fpsBoostConnection:Disconnect()
                    fpsBoostConnection = nil
                end
                fpsBoostConnection = workspace.DescendantAdded:Connect(function(obj)
                    if obj:IsA("Decal") or obj:IsA("Texture") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Type = "Decal", Transparency = obj.Transparency}
                        end
                        obj.Transparency = 1
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Type = "Emitter", Enabled = obj.Enabled}
                        end
                        pcall(function() obj.Enabled = false end)
                    elseif obj:IsA("Humanoid") then
                        if originalFPSValues[obj] == nil then
                            local playing = {}
                            for _, track in ipairs(obj:GetPlayingAnimationTracks()) do
                                table.insert(playing, track)
                                pcall(function() track:Stop() end)
                            end
                            originalFPSValues[obj] = {Type = "Humanoid", Tracks = playing}
                        end
                    elseif obj:IsA("MeshPart") then
                        if originalFPSValues[obj.."_RenderFidelity"] == nil then
                            originalFPSValues[obj.."_RenderFidelity"] = {Type = "RenderFidelity", RenderFidelity = obj.RenderFidelity}
                        end
                        obj.RenderFidelity = Enum.RenderFidelity.Performance
                    end
                end)
            else
                -- Disable FPS boost
                if fpsBoostConnection then
                    fpsBoostConnection:Disconnect()
                    fpsBoostConnection = nil
                end
                if Lighting and originalLightingValues.GlobalShadows ~= nil then
                    Lighting.GlobalShadows = originalLightingValues.GlobalShadows
                    Lighting.FogEnd = originalLightingValues.FogEnd
                    Lighting.Brightness = originalLightingValues.Brightness
                end
                if workspace:FindFirstChild("Terrain") and originalTerrainValues.WaterWaveSize ~= nil then
                    local Terrain = workspace.Terrain
                    Terrain.WaterWaveSize = originalTerrainValues.WaterWaveSize
                    Terrain.WaterWaveSpeed = originalTerrainValues.WaterWaveSpeed
                    Terrain.WaterReflectance = originalTerrainValues.WaterReflectance
                    Terrain.WaterTransparency = originalTerrainValues.WaterTransparency
                end
                for obj, props in pairs(originalFPSValues) do
                    if obj and (obj.Parent or props.Type == "Effect" or props.Type == "Gui" or props.Type == "Sound" or props.Type == "RenderFidelity") then
                        if props.Type == "Decal" then
                            pcall(function() obj.Transparency = props.Transparency or 0 end)
                        elseif props.Type == "Emitter" then
                            pcall(function() obj.Enabled = (props.Enabled == nil) and true or props.Enabled end)
                        elseif props.Type == "Humanoid" then
                            if props.Tracks and type(props.Tracks) == "table" then
                                for _, track in ipairs(props.Tracks) do
                                    pcall(function() track:Play() end)
                                end
                            end
                        -- No material restore needed
                        elseif props.Type == "RenderFidelity" then
                            pcall(function() obj.RenderFidelity = props.RenderFidelity end)
                        elseif props.Type == "Sound" then
                            pcall(function() obj.Volume = props.Volume end)
                        elseif props.Type == "Effect" then
                            pcall(function() if obj and props.Parent then obj.Parent = props.Parent end end)
                        elseif props.Type == "Gui" then
                            pcall(function() obj.Enabled = props.Enabled end)
                        end
                    end
                end
                if settings().Rendering and originalRenderingQuality then
                    settings().Rendering.QualityLevel = originalRenderingQuality
                end
                originalFPSValues = {}
                originalLightingValues = {}
                originalTerrainValues = {}
                originalRenderingQuality = nil
            end
        end
    }
)

-- White/Black Screen FPS Toggle
local fpsScreenOverlay = nil
Settings:AddToggle("FPSScreenOverlay", {
    Text = "White/Black Screen (Max FPS)",
    Default = false,
    Tooltip = "Covers screen with solid color for max FPS.",
    Callback = function(enabled)
        local CoreGui = game:GetService("CoreGui")
        if enabled then
            if not fpsScreenOverlay then
                fpsScreenOverlay = Instance.new("ScreenGui")
                fpsScreenOverlay.Name = "FPSScreenOverlay"
                fpsScreenOverlay.IgnoreGuiInset = true
                fpsScreenOverlay.ResetOnSpawn = false
                fpsScreenOverlay.DisplayOrder = 100
                fpsScreenOverlay.Parent = CoreGui

                local frame = Instance.new("Frame")
                frame.Name = "OverlayFrame"
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.Position = UDim2.new(0, 0, 0, 0)
                frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black by default
                frame.BorderSizePixel = 0
                frame.Parent = fpsScreenOverlay

                -- Add toggle button for white/black
                local toggleBtn = Instance.new("TextButton")
                toggleBtn.Name = "ColorToggleBtn"
                toggleBtn.Size = UDim2.new(0, 160, 0, 48)
                toggleBtn.Position = UDim2.new(0.5, -80, 0.5, -24)
                toggleBtn.BackgroundTransparency = 0.15
                toggleBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                toggleBtn.Text = "Switch to White"
                toggleBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
                toggleBtn.TextSize = 22
                toggleBtn.Font = Enum.Font.GothamBold
                toggleBtn.Parent = fpsScreenOverlay
                toggleBtn.AutoButtonColor = false
                toggleBtn.BorderSizePixel = 0

                -- Rounded corners
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0.25, 0)
                btnCorner.Parent = toggleBtn

                -- Drop shadow
                local btnShadow = Instance.new("ImageLabel")
                btnShadow.Name = "BtnShadow"
                btnShadow.Size = UDim2.new(1, 12, 1, 12)
                btnShadow.Position = UDim2.new(0, -6, 0, -2)
                btnShadow.BackgroundTransparency = 1
                btnShadow.Image = "rbxassetid://1316045217" -- Simple shadow asset
                btnShadow.ImageTransparency = 0.5
                btnShadow.ZIndex = toggleBtn.ZIndex - 1
                btnShadow.Parent = toggleBtn

                -- Center text
                toggleBtn.TextXAlignment = Enum.TextXAlignment.Center
                toggleBtn.TextYAlignment = Enum.TextYAlignment.Center

                -- Hover effect
                local UserInputService = game:GetService("UserInputService")
                toggleBtn.MouseEnter:Connect(function()
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                end)
                toggleBtn.MouseLeave:Connect(function()
                    if frame.BackgroundColor3 == Color3.fromRGB(255, 255, 255) then
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    else
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                    end
                end)

                toggleBtn.MouseButton1Click:Connect(function()
                    if frame.BackgroundColor3 == Color3.fromRGB(0, 0, 0) then
                        frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        toggleBtn.Text = "Switch to Black"
                        toggleBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    else
                        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        toggleBtn.Text = "Switch to White"
                        toggleBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                    end
                end)
            end
            fpsScreenOverlay.Enabled = true
        else
            if fpsScreenOverlay then
                fpsScreenOverlay.Enabled = false
            end
        end
    end
})


-- Server control buttons: Rejoin + Server Hop

Settings:AddButton("Rejoin Server", function()
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title = "Server", Text = "Rejoining server...", Duration = 2})
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, Players.LocalPlayer)
    end)
end)

-- Server Hop Button
Settings:AddButton("Server Hop", function()
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title = "Server", Text = "Hopping to a new server...", Duration = 2})
        local ts = game:GetService("TeleportService")
        local http = game:GetService("HttpService")
        local placeId = game.PlaceId
        local currentJobId = game.JobId
        local servers = {}
        local cursor = nil
        local found = false
        -- Try up to 5 pages of servers
        for page = 1, 5 do
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100" .. (cursor and ("&cursor=" .. cursor) or "")
            local success, result = pcall(function()
                return http:JSONDecode(game:HttpGet(url))
            end)
            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if server.id ~= currentJobId and server.playing < server.maxPlayers then
                        table.insert(servers, server.id)
                    end
                end
                if result.nextPageCursor then
                    cursor = result.nextPageCursor
                else
                    break
                end
            else
                break
            end
        end
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            ts:TeleportToPlaceInstance(placeId, randomServer, Players.LocalPlayer)
        else
            game.StarterGui:SetCore("SendNotification", {Title = "Server", Text = "No available servers found.", Duration = 3})
        end
    end)
end)

Settings:AddButton("Unload Script", function()
    -- Stop all running features and threads first
        pcall(function()
            -- Stop toggle loops
            autofarmRunning = false
            autoAttackRunning = false
            autoClaimAchievementsRunning = false
            autoClaimDailyRunning = false
            fastAutoRunning = false
            autoDeleteRunning = false
            autoFuseRunning = false
            autoFuseRarityRunning = false
            autoRerollRunning = false
            autoRedeemRunning = false
            antiAfkRunning = false
            autoEnterTowerEnabled = false
            autoLeaveTowerEnabled = false
            autoEnterTrialEnabled = false
            autoLeaveTrialEnabled = false
            -- Nil out any remaining thread refs we created
            autofarmThread = nil
            if autoEnterTowerThread and type(autoEnterTowerThread) == "thread" then autoEnterTowerThread = nil end
            if autoEnterTrialThread and type(autoEnterTrialThread) == "thread" then autoEnterTrialThread = nil end
            if autoLeaveTowerThread and type(autoLeaveTowerThread) == "thread" then autoLeaveTowerThread = nil end
            if autoLeaveTrialThread and type(autoLeaveTrialThread) == "thread" then autoLeaveTrialThread = nil end
            
            -- Additional cleanup for reroll/stats features introduced later
            if rerollRefreshRunning ~= nil then rerollRefreshRunning = false end
            if rerollRefreshThread and type(rerollRefreshThread) == "thread" then rerollRefreshThread = nil end
            if autoRerollThread and type(autoRerollThread) == "thread" then autoRerollThread = nil end
            if autoRerollTraitsEnabled ~= nil then autoRerollTraitsEnabled = false end
            if autoRerollTraitsThread and type(autoRerollTraitsThread) == "thread" then autoRerollTraitsThread = nil end
            if autoStatsRerollEnabled ~= nil then autoStatsRerollEnabled = false end
            if autoStatsRerollThread and type(autoStatsRerollThread) == "thread" then autoStatsRerollThread = nil end
            -- Clear selected fighter ids
            selectedRerollFighterId = nil
            selectedStatsRerollFighterId = nil

        -- Disconnect common connections
        if antiAfkConn then pcall(function() antiAfkConn:Disconnect() end) antiAfkConn = nil end
        if fpsBoostConnection then pcall(function() fpsBoostConnection:Disconnect() end) fpsBoostConnection = nil end
        if enforceWalkConn then pcall(function() enforceWalkConn:Disconnect() end) enforceWalkConn = nil end
        if flyHeartbeatConn then pcall(function() flyHeartbeatConn:Disconnect() end) flyHeartbeatConn = nil end
        if flyInputConns then pcall(function()
            for k, v in pairs(flyInputConns) do if v and v.Disconnect then pcall(function() v:Disconnect() end) end end
            flyInputConns = {}
        end) end

        -- Attempt to remove UI widgets and dropdown refs if present
        pcall(function()
            if fuseDropdownRef and fuseDropdownRef.SetValues then fuseDropdownRef:SetValues({}) end
            if autofarmEnemyDropdownRef and autofarmEnemyDropdownRef.SetValues then autofarmEnemyDropdownRef:SetValues({}) end
            if autofarmIslandDropdownRef and autofarmIslandDropdownRef.SetValues then pcall(function() autofarmIslandDropdownRef:SetValues({}) end) end
            if teleportDropdownRef and teleportDropdownRef.SetValues then pcall(function() teleportDropdownRef:SetValues({}) end) end
            if questDropdownRef and questDropdownRef.SetValues then pcall(function() questDropdownRef:SetValues({}) end) end
            -- Clear reroll/stat dropdowns added by this script
            if rerollTypeDropdownRef and rerollTypeDropdownRef.SetValues then pcall(function() rerollTypeDropdownRef:SetValues({}) end) end
            if rerollTypeDropdownRef and rerollTypeDropdownRef.SetValue then pcall(function() rerollTypeDropdownRef:SetValue("") end) end
            if rerollFighterDropdownRef and rerollFighterDropdownRef.SetValues then pcall(function() rerollFighterDropdownRef:SetValues({}) end) end
            if statsFighterDropdownRef and statsFighterDropdownRef.SetValues then pcall(function() statsFighterDropdownRef:SetValues({}) end) end
            -- nil out refs
            rerollTypeDropdownRef = nil
            rerollFighterDropdownRef = nil
            statsFighterDropdownRef = nil
            rerollTypes = nil
            -- nil out map/dropdown refs we added
            autofarmIslandDropdownRef = nil
            teleportDropdownRef = nil
            questDropdownRef = nil
            teleportSelection = nil
            questSelection = nil
            autofarmIslands = nil
        end)

        -- Destroy watermark and other created GUIs
        pcall(function() if WatermarkGui and WatermarkGui.Parent then WatermarkGui:Destroy() end end)
    end)

    print("🔄 Starting Seisen Hub cleanup...")
    -- Restore FPS Boost settings to normal
    print("🔧 Restoring graphics settings...")
    local Lighting = game:GetService("Lighting")
    local workspace = game:GetService("Workspace")
    pcall(function()
        if fpsBoostConnection then
            fpsBoostConnection:Disconnect()
            fpsBoostConnection = nil
            print("📊 FPS Boost connection disconnected")
        end
    end)
    
    pcall(function()
        if Lighting and originalLightingValues and originalLightingValues.GlobalShadows ~= nil then
            Lighting.GlobalShadows = originalLightingValues.GlobalShadows
            Lighting.FogEnd = originalLightingValues.FogEnd
            Lighting.Brightness = originalLightingValues.Brightness
            print("💡 Lighting settings restored")
        end
    end)
    
    pcall(function()
        if workspace:FindFirstChild("Terrain") and originalTerrainValues and originalTerrainValues.WaterWaveSize ~= nil then
            local Terrain = workspace.Terrain
            Terrain.WaterWaveSize = originalTerrainValues.WaterWaveSize
            Terrain.WaterWaveSpeed = originalTerrainValues.WaterWaveSpeed
            Terrain.WaterReflectance = originalTerrainValues.WaterReflectance
            Terrain.WaterTransparency = originalTerrainValues.WaterTransparency
            print("🌊 Terrain settings restored")
        end
    end)
    
    pcall(function()
        if originalFPSValues then
            for obj, props in pairs(originalFPSValues) do
                if obj and (obj.Parent or props.Type == "Effect" or props.Type == "Gui" or props.Type == "Sound" or props.Type == "RenderFidelity") then
                    if props.Type == "Decal" then
                        pcall(function() obj.Transparency = props.Transparency or 0 end)
                    elseif props.Type == "Emitter" then
                        pcall(function() obj.Enabled = (props.Enabled == nil) and true or props.Enabled end)
                    elseif props.Type == "Humanoid" then
                        if props.Tracks and type(props.Tracks) == "table" then
                            for _, track in ipairs(props.Tracks) do
                                pcall(function() track:Play() end)
                            end
                        end
                    elseif props.Type == "RenderFidelity" then
                        pcall(function() obj.RenderFidelity = props.RenderFidelity end)
                    elseif props.Type == "Sound" then
                        pcall(function() obj.Volume = props.Volume end)
                    elseif props.Type == "Effect" then
                        pcall(function() if obj and props.Parent then obj.Parent = props.Parent end end)
                    elseif props.Type == "Gui" then
                        pcall(function() obj.Enabled = props.Enabled end)
                    end
                end
            end
            print("🎨 Visual effects restored (Decals, Emitters, RenderFidelity, Sounds, GUIs, Effects)")
        end
    end)
    
    pcall(function()
        if settings().Rendering and originalRenderingQuality then
            settings().Rendering.QualityLevel = originalRenderingQuality
            print("⚙️ Rendering quality restored")
        end
    end)
    
    -- Clean up saved values
    originalFPSValues = {}
    originalLightingValues = {}
    originalTerrainValues = {}
    originalRenderingQuality = nil
    
    -- Disconnect workspace connection for ball circles
    pcall(function()
        if workspaceConnection then
            workspaceConnection:Disconnect()
            workspaceConnection = nil
            print("🔗 Workspace connections disconnected")
        end
    end)

    -- Stop watermark connection
    pcall(function()
        if WatermarkConnection then
            WatermarkConnection:Disconnect()
            print("🏷️ Watermark connection stopped")
        end
    end)
    
    -- Disconnect any remaining global input connections
    pcall(function()
        if inputChangedConnection then
            inputChangedConnection:Disconnect()
            print("🖱️ Input connections disconnected")
        end
        if inputEndedConnection then
            inputEndedConnection:Disconnect()
        end
    end)
    
    -- Remove custom watermark
    pcall(function()
        if WatermarkGui then
            WatermarkGui:Destroy()
            print("🗑️ Custom watermark removed")
        end
    end)

    -- Remove FPS screen overlay (white/black screen)
    pcall(function()
        local overlay = game:GetService("CoreGui"):FindFirstChild("FPSScreenOverlay")
        if overlay then
            overlay:Destroy()
            print("🗑️ FPS screen overlay removed")
        end
    end)

    -- Restore any overlay-related states if needed
    pcall(function()
        if _G.FPSScreenOverlayColor then _G.FPSScreenOverlayColor = nil end
        if _G.FPSScreenOverlayActive then _G.FPSScreenOverlayActive = nil end
    end)
    
    -- Final cleanup and proper unload
    pcall(function()
        if Library and Library.Unload then
            Library:Unload()
            print("📚 Library properly unloaded")
        end
    end)
    pcall(function()
        -- Stop enforcing WalkSpeed
        if enforceWalkConn then
            enforceWalkConn:Disconnect()
            enforceWalkConn = nil
        end

        -- Disable fly if enabled and clean up its objects/connections
        pcall(function()
            if disableFly then
                disableFly()
            end
        end)

        -- Restore original WalkSpeed for the local player's humanoid
        pcall(function()
            local pl = game:GetService("Players").LocalPlayer
            if pl and pl.Character then
                local humanoid = pl.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = originalWalkSpeed or 16
                end
            end
        end)
    end)
    
    print("✅ Seisen Hub completely unloaded and cleaned up!")
end)

-- Load the autoload config after all UI elements are setup
SaveManager:LoadAutoloadConfig()
