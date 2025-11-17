getgenv().SeisenHubRunning = true

game.StarterGui:SetCore("SendNotification", {
    Title = "Seisen Hub";
    Text = "Anime Eternal Script Loaded";
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
local ALLOWED_GAME_IDS = {7882829745} -- TODO: replace with your game's GameId(s) (universe id)

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

local Window = Library:CreateWindow({
    Title = "Seisen Hub",
    Footer = "Anime Eternal",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Center = true,
    Icon = 125926861378074,
    AutoShow = true,
    ShowCustomCursor = true -- Enable custom cursor
})



autoRollDragonRaceEnabled = false
fightersKillAuraEnabled = false
autoRollSaiyanEvolutionEnabled = false
autoRollSwordsEnabled = false
autoRollPirateCrewEnabled = false
autoRollDemonFruitsEnabled = false
autoRollReiatsuColorEnabled = false
autoRollZanpakutoEnabled = false
autoRollCursesEnabled = false
autoRollDemonArtsEnabled = false
autoRollGrimoireEnabled = false
autoSoloHunterRankEnabled = false
autoRollPowerEyesEnabled = false
autoPsychicMayhemEnabled = false
autoRollEnergyCardEnabled = false
autoRollDamageCardEnabled = false
autoRollFamiliesEnabled = false
autoRollTitansEnabled = false
autoRollSinsEnabled = false
autoRollCommandmentsEnabled = false
autoRollKaijuPowersEnabled = false
autoRollAkumaPowersEnabled = false
autoRollSpeciesEnabled = false
autoRollUltimateSkillsEnabled = false
autoRollPowerEnergyRunesEnabled = false
autoRollStandsEnabled = false
autoRollOnomatopoeiaEnabled = false
autoRollKaguneEnabled = false
autoRollInvestigatorEnabled = false
autoRollDebiruHunterEnabled = false
teleportSelectedEnemyTitles = {}
teleportAndAttackEnabled = false

-- Auto Roll Stars globals
autoRollEnabled = false
selectedStar = "Star_1"
delayBetweenRolls = 0.1
autoDeleteEnabled = false
selectedDeleteStar = "Star_1"
selectedRarities = {}
selectedRaritiesDisplay = {}
autoDeleteWeaponEnabled = false
selectedDeleteWeapon = "Common" -- or whatever your default should be
selectedWeaponRarities = {}
selectedWeaponRaritiesDisplay = {}

-- Stats options (display names)
local stats = {
    "Damage",
    "Energy",
    "Coins",
    "Luck"
}

-- Internal stat mapping
local statMap = {
    Damage = "Primary_Damage",
    Energy = "Primary_Energy",
    Coins = "Primary_Coins",
    Luck = "Primary_Luck"
}
local gachaRarityMap = {
    Common = "1",
    Uncommon = "2",
    Rare = "3",
    Epic = "4",
    Legendary = "5",
    Mythical = "6",
    Phantom = "7",
    Supreme = "8"
}
local selectedGachaRarities = {}

-- Titan rarity mapping (1-7)
local titanRarityMap = {
    Common = "1",
    Uncommon = "2",
    Rare = "3",
    Epic = "4",
    Legendary = "5",
    Mythical = "6",
    Phantom = "7"
}

-- Stand rarity mapping (1-8)
local standRarityMap = {
    Common = "1",
    Uncommon = "2",
    Rare = "3",
    Epic = "4",
    Legendary = "5",
    Mythical = "6",
    Phantom = "7",
    Supreme = "8",
}
local selectedStandRarities = {}
local selectedStandRaritiesDisplay = {}

-- Load old config if exists to migrate settings (optional)
local config = {}

-- Initialize variables with old config values or defaults
local selectedDungeons = config.SelectedDungeons or {}
selectedPotions = config.PotionDropdown or {}
isAutoTimeRewardEnabled = config.AutoTimeRewardToggle or false
isAutoDailyChestEnabled = config.AutoDailyChestToggle or false
isAutoVipChestEnabled = config.AutoVipChestToggle or false
isAutoGroupChestEnabled = config.AutoGroupChestToggle or false
isAutoPremiumChestEnabled = config.AutoPremiumChestToggle or false
teleportSelectedEnemyTitles = config.TeleportEnemyDropdown or {}
local autoHideUIEnabled = config.AutoHideUIEnabled or false
selectedStat = config.AutoStatSingleDropdown or stats[1]
pointsPerSecond = config.PointsPerSecondSlider or 1
autoStatsRunning = config.AutoAssignStatToggle or false


local MainTab = Window:AddTab("Main", "atom", "Main Features")
local LeftGroupbox = MainTab:AddLeftGroupbox("Automation", "sun-moon")
local StatsGroupbox = MainTab:AddRightGroupbox("Auto Stats", "chart-no-axes-combined")
local RewardsGroupbox = MainTab:AddRightGroupbox("Auto Rewards", "gift")
local PotionGroupbox = MainTab:AddRightGroupbox("Auto Potions", "bottle-wine")

local TeleportTab = Window:AddTab("Teleport & Dungeon", "map" , "Teleport to Enemies and Dungeons")
local TPGroupbox = TeleportTab:AddLeftGroupbox("Main Teleport", "headset")
local AdjustDungeon = TeleportTab:AddLeftGroupbox("Auto Leave Dungeon in Wave", "waves")
local DungeonGroupbox = TeleportTab:AddLeftGroupbox("Auto Dungeon", "badge")
local RaidDefense = TeleportTab:AddRightGroupbox("Auto Raid Defense", "shield-check")

local RollTab = Window:AddTab("Rolls", "dice-5", "Auto Roll your Powers")
local RollGroupbox = RollTab:AddLeftGroupbox("Auto Roll Star", "circle")
local AutoDeleteGroupbox = RollTab:AddLeftGroupbox("Auto Delete Units", "trash")
local AutoDeleteGroupbox2 = RollTab:AddLeftGroupbox("Auto Delete Weapons", "trash")
local AutoDeleteTitan = RollTab:AddLeftGroupbox("Auto Delete Titans", "trash")
local AutoDeleteStand = RollTab:AddLeftGroupbox("Auto Delete Stands", "trash")
local RollGroupbox2 = RollTab:AddRightGroupbox("Auto Roll Tokens", "circle")


local UP = Window:AddTab("Upgrades", "arrow-up", "Upgrade your Stats, Sins, Shadows and World")
local UpgradeGroupbox = UP:AddLeftGroupbox("Stats Upgrade", "anvil")
local SinUp = UP:AddLeftGroupbox("Sin Upgrade", "angry")
local ShadowUp = UP:AddLeftGroupbox("Shadow Upgrade", "moon")
local Upgrade2 = UP:AddRightGroupbox("World Upgrade", "archive")

local LevelTab = Window:AddTab("Leveling/Enhance", "star", "Level Up Your Power")
local LevelUp = LevelTab:AddLeftGroupbox("Leveling", "fire")
local Enhance = LevelTab:AddRightGroupbox("Enhance", "hammer")

local EventTab = Window:AddTab("Events", "gift", "Special In-Game Events")
local HalloweenEvent = EventTab:AddLeftGroupbox("Halloween Event", "bomb")
local HalloweenEvent2 = EventTab:AddRightGroupbox("Halloween Event World", "snowflake")



local ShopTab = Window:AddTab("ExchangeShop", "star", "Exchange Items for Tokens and Keys")
local ExchangeW1t5 = ShopTab:AddLeftGroupbox("Exchange Shop World 1 to 5", "lasso-select")
local ExchangeW6t10 = ShopTab:AddRightGroupbox("Exchange Shop World 6 to 10", "minimize")
local ExchangeW11t15 = ShopTab:AddLeftGroupbox("Exchange Shop World 11 to 15", "loader-pinwheel")
local ExchangeW16t19 = ShopTab:AddRightGroupbox("Exchange Shop World 16 to 20", "ratio")
local ExchangeKeys = ShopTab:AddLeftGroupbox("Exchange Shop Keys", "key")
local ExchangePotion = ShopTab:AddRightGroupbox("Exchange Shop Potions", "milk")

local TokenTab = Window:AddTab("Token Exchange", "gem", "Exchange Tokens for Items")
local TokenW1t5 = TokenTab:AddLeftGroupbox("Token Exchange World 1 to 5", "circle-plus")
local TokenW6t10 = TokenTab:AddRightGroupbox("Token Exchange World 6 to 10", "database")
local TokenW11t15 = TokenTab:AddLeftGroupbox("Token Exchange World 11 to 15", "folder-kanban")
local TokenW16t19 = TokenTab:AddRightGroupbox("Token Exchange World 16 to 20", "file-code")

local JewelryTab = Window:AddTab("Jewelry Exchange", "diamond" , "Exchange Jewelry Coins and Items")
local ExchangeJewelry = JewelryTab:AddLeftGroupbox("Exchange Jewelry", "shell")
ExchangeJewelry:AddLabel("Exchange Items to Jewelry Coins")
local ExchangeJewelryS = JewelryTab:AddRightGroupbox("Exchange Jewelry Shop", "sparkles")
ExchangeJewelryS:AddLabel("Exchange Jewelry Coins to Items")

local SettingsTab = Window:AddTab("Settings", "settings", "Customize the UI")
local UISettingsGroup = SettingsTab:AddLeftGroupbox("UI Customization", "paintbrush")
local RedeemGroupbox = SettingsTab:AddRightGroupbox("Redeem Codes", "gift")
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
SaveManager:SetFolder("SeisenHub/AnimeEternal")
SaveManager:SetSubFolder("Configs") -- Optional subfolder for better organization
SaveManager:BuildConfigSection(UiSettingsTab)

-- Configure ThemeManager  
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenHub")
ThemeManager:ApplyToTab(UiSettingsTab)

InfoGroup:AddLabel("Script by: Seisen")
InfoGroup:AddLabel("Version: 8.0.0")
InfoGroup:AddLabel("Game: Anime Eternal")
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


local Players = game:GetService("Players")
local Character = nil
local HumanoidRootPart = nil
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
local monstersFolder = Workspace:WaitForChild("Debris", 9e9):WaitForChild("Monsters", 9e9)
local localPlayer = Players.LocalPlayer
local Workspace = workspace
local To_Server = ReplicatedStorage.Events:WaitForChild("To_Server")

------========================================== Tab: Main Features ==========================================---
-- Helper: Get all monster titles dynamically
local function getAllMonsterTitles()
    local monstersFolder = Workspace:FindFirstChild("Debris") and Workspace.Debris:FindFirstChild("Monsters")
    if not monstersFolder then
        monstersFolder = Workspace:FindFirstChild("Monsters")
    end
    local titles = {}
    local seen = {}
    if monstersFolder then
        for _, monster in ipairs(monstersFolder:GetChildren()) do
            local title = monster:GetAttribute("Title") or monster.Name
            if type(title) == "string" and not seen[title] then
                table.insert(titles, title)
                seen[title] = true
            end
        end
    end
    return titles
end

-- Function: Perform attack with correct Id
local function performAttack(monster)
    if monster and monster.Name then
        pcall(function()
            To_Server:FireServer({
                Id = monster.Name,
                Action = "_Mouse_Click"
            })
        end)
    end
end

-- Multi-select dropdown for enemies (by Title)
local monsterDropdown = LeftGroupbox:AddDropdown(
    "MonsterSelector",
    {
        Text = "Select Monster(s)",
        Values = getAllMonsterTitles(),
        Default = config.MonsterSelector or {},
        Multi = true,
        Tooltip = "Choose which monsters to target (by Title). Select multiple monsters to farm.",
        Callback = function(values)
            local selectedTitles = {}
            if type(values) == "table" then
                for k, v in pairs(values) do
                    if v then
                        table.insert(selectedTitles, k)
                    end
                end
            end
            teleportSelectedEnemyTitles = selectedTitles
            -- SaveManager automatically saves this dropdown's value
        end
    }
)

local function refreshMonsterDropdown()
    if monsterDropdown then
        monsterDropdown:SetValues(getAllMonsterTitles())
    end
end

local monstersFolder = Workspace:FindFirstChild("Debris") and Workspace.Debris:FindFirstChild("Monsters")
if not monstersFolder then
    monstersFolder = Workspace:FindFirstChild("Monsters")
end
if monstersFolder then
    monstersFolder.ChildAdded:Connect(refreshMonsterDropdown)
    monstersFolder.ChildRemoved:Connect(refreshMonsterDropdown)
end

-- Robust real-time monster dropdown updater
local monsterFolderConnections = {}
local lastMonstersFolder = nil

local function disconnectMonsterFolderConnections()
    for _, conn in ipairs(monsterFolderConnections) do
        pcall(function() conn:Disconnect() end)
    end
    monsterFolderConnections = {}
end

local function getCurrentMonstersFolder()
    local folder = Workspace:FindFirstChild("Debris") and Workspace.Debris:FindFirstChild("Monsters")
    if not folder then
        folder = Workspace:FindFirstChild("Monsters")
    end
    return folder
end

local updateScheduled = false
local function scheduleDropdownUpdate()
    if not updateScheduled then
        updateScheduled = true
        task.spawn(function()
            game:GetService("RunService").RenderStepped:Wait()
            updateScheduled = false
            if teleportDropdown and typeof(teleportDropdown.SetValues) == "function" then
                local titles = getAllUniqueMonsterTitles()
                teleportDropdown:SetValues(titles)
                -- Removed SetSelected call to avoid error
            end
        end)
    end
end

local function connectMonsterFolderEvents(monstersFolder)
    disconnectMonsterFolderConnections()
    if monstersFolder then
        table.insert(monsterFolderConnections, monstersFolder.ChildAdded:Connect(scheduleDropdownUpdate))
        table.insert(monsterFolderConnections, monstersFolder.ChildRemoved:Connect(scheduleDropdownUpdate))
    end
end

-- Watch for monsters folder changes and reconnect listeners
task.spawn(function()
    while getgenv().SeisenHubRunning do
        local monstersFolder = getCurrentMonstersFolder()
        if monstersFolder ~= lastMonstersFolder then
            lastMonstersFolder = monstersFolder
            connectMonsterFolderEvents(monstersFolder)
            if teleportDropdown and typeof(teleportDropdown.SetValues) == "function" then
                teleportDropdown:SetValues(getAllUniqueMonsterTitles())
            end
        end
        task.wait(1)
    end
end)

-- Configurable attack delay
local killAuraDelay = 0.15 -- default value


-- Slider for Kill Aura delay
LeftGroupbox:AddSlider("KillAuraDelaySlider", {
    Text = "Auto Farm Delay Attack",
    Min = 0.05,
    Max = 1,
    Default = config.KillAuraDelaySlider or 0.15,
    Rounding = 2,
    Tooltip = "Delay between each attack (seconds)",
    Callback = function(val)
        killAuraDelay = val
        -- SaveManager automatically saves this slider's value
    end
})

-- Flag to avoid multiple running loops
local teleportAndAttackThread = nil -- store the running thread

local function startTeleportAndAttack()
    -- Kill any existing thread first (safety)
    if teleportAndAttackThread and coroutine.status(teleportAndAttackThread) ~= "dead" then
        teleportAndAttackEnabled = false
        teleportAndAttackRunning = false
        coroutine.close(teleportAndAttackThread)
        teleportAndAttackThread = nil
        task.wait() -- give time for cleanup
    end

    teleportAndAttackRunning = true
    teleportAndAttackThread = task.spawn(function()
        local player = Players.LocalPlayer
        while teleportAndAttackEnabled do
            local monstersFolder = Workspace:FindFirstChild("Debris") and Workspace.Debris:FindFirstChild("Monsters")
            local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if monstersFolder and #teleportSelectedEnemyTitles > 0 and myHRP then
                local matchingMonsters = {}
                for _, monster in ipairs(monstersFolder:GetChildren()) do
                    if monster:IsA("Model") and table.find(teleportSelectedEnemyTitles, monster:GetAttribute("Title")) then
                        local hum = monster:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then
                            table.insert(matchingMonsters, monster)
                        end
                    end
                end

                table.sort(matchingMonsters, function(a, b)
                    local aHRP, bHRP = a:FindFirstChild("HumanoidRootPart"), b:FindFirstChild("HumanoidRootPart")
                    if aHRP and bHRP then
                        return (myHRP.Position - aHRP.Position).Magnitude < (myHRP.Position - bHRP.Position).Magnitude
                    end
                    return false
                end)

                for _, monster in ipairs(matchingMonsters) do
                    if not teleportAndAttackEnabled then break end
                    local hrp = monster:FindFirstChild("HumanoidRootPart")
                    local hum = monster:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local targetPos = hrp.Position + (hrp.CFrame.LookVector * 3)
                        myHRP.CFrame = CFrame.new(targetPos, hrp.Position)


                        repeat
                            task.wait(killAuraDelay)
                            performAttack(monster)
                            hum = monster:FindFirstChild("Humanoid")
                        until not hum or hum.Health <= 0 or not teleportAndAttackEnabled
                    end
                end
            else
                task.wait(0.5)
            end
            task.wait(0.2)
        end

        teleportAndAttackRunning = false -- loop ended
        teleportAndAttackThread = nil
    end)
end

-- Toggle
LeftGroupbox:AddToggle("TeleportAndAttackToggle", {
    Text = "Auto Farm",
    Default = config.TeleportAndAttackToggle or false,
    Tooltip = "Teleports to every selected enemy (one by one) and attacks until dead.",
    Callback = function(Value)
        teleportAndAttackEnabled = Value
        -- SaveManager automatically saves this toggle's value
        if Value then
            startTeleportAndAttack()
        else
            teleportAndAttackEnabled = false
            teleportAndAttackRunning = false
            if teleportAndAttackThread and coroutine.status(teleportAndAttackThread) ~= "dead" then
                coroutine.close(teleportAndAttackThread)
                teleportAndAttackThread = nil
            end

        end
    end
})

-- Utility: Shuffle table in place
local function shuffleTable(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- Avoid multiple loops

local function startFarmAllEnemies()
    if farmAllRunning then return end
    farmAllRunning = true

    task.spawn(function()
        local player = Players.LocalPlayer
        while farmAllEnemiesEnabled do
            local monstersFolder = Workspace:FindFirstChild("Debris") and Workspace.Debris:FindFirstChild("Monsters")
            local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if monstersFolder and myHRP then
                local allMonsters = {}
                for _, monster in ipairs(monstersFolder:GetChildren()) do
                    if monster:IsA("Model") then
                        local hum = monster:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then
                            local monsterRank = monster:GetAttribute("Rank")
                            if not (monsterRank and string.find(monsterRank, "SS")) then
                                table.insert(allMonsters, monster)
                            else

                            end
                        end
                    end
                end

                shuffleTable(allMonsters)

                for _, monster in ipairs(allMonsters) do
                    if not farmAllEnemiesEnabled then break end
                    local hrp = monster:FindFirstChild("HumanoidRootPart")
                    local hum = monster:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local targetPos = hrp.Position + (hrp.CFrame.LookVector * 3)
                        myHRP.CFrame = CFrame.new(targetPos, hrp.Position)


                        repeat
                            task.wait(killAuraDelay)
                            performAttack(monster)
                            hum = monster:FindFirstChild("Humanoid")
                        until not hum or hum.Health <= 0 or not farmAllEnemiesEnabled
                    end
                end
            else
                task.wait(0.5)
            end
            task.wait(0.2)
        end

        farmAllRunning = false -- loop ended
    end)
end

LeftGroupbox:AddToggle("FarmAllEnemiesToggle", {
    Text = "Farm ALL Enemies",
    Default = config.FarmAllEnemiesToggle or false,
    Tooltip = "Farm Teleports + attacks all enemies randomly.",
    Callback = function(Value)
        farmAllEnemiesEnabled = Value
        -- SaveManager automatically saves this toggle's value
        if Value then
            startFarmAllEnemies()
        else
            farmAllRunning = false -- ensure clean stop
        end
    end
})

LeftGroupbox:AddToggle(
        "KillAuraOnlyToggle",
        {
            Text = "Kill Aura Only",
            Default = config.KillAuraOnlyToggle or false,
            Tooltip = "Attacks nearest monster without teleporting.",
            Callback = function(Value)
                killAuraOnlyEnabled = Value
                -- SaveManager automatically saves this toggle's value
                if Value then
                    task.spawn(function()
                        local player = game:GetService("Players").LocalPlayer
                        while killAuraOnlyEnabled and getgenv().SeisenHubRunning do
                            local monstersFolder = workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Monsters") or workspace:FindFirstChild("Monsters")
                            if not monstersFolder then
                                task.wait(1)
                            else
                                local nearest = nil
                                local nearestDist = math.huge
                                local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if myHRP then
                                    for _, monster in pairs(monstersFolder:GetChildren()) do
                                        if monster:IsA("Model") then
                                            local hrp = monster:FindFirstChild("HumanoidRootPart")
                                            local hum = monster:FindFirstChild("Humanoid")
                                            if hrp and hum and hum.Health > 0 then
                                                local dist = (myHRP.Position - hrp.Position).Magnitude
                                                if dist < nearestDist then
                                                    nearest = monster
                                                    nearestDist = dist
                                                end
                                            end
                                        end
                                    end
                                    if nearest and nearestDist < 99999 then
                                        local args = {
                                            [1] = {
                                                ["Id"] = nearest.Name,
                                                ["Action"] = "_Mouse_Click"
                                            }
                                        }
                                        pcall(function() ToServer:FireServer(unpack(args)) end)
                                    end
                                end
                            end
                            task.wait(0.05)
                        end
                    end)
                end
            end
        }
    )


-- Adjustable settings
local ATTACK_DELAY = 0.1 -- lower = faster
local ATTACK_RANGE = 10   -- studs (change to 100 for wider aura)

-- Get Titan UniqueId
local function getUniqueIds()
    local ids = {}
    local titanFolder = workspace:WaitForChild("Equipment", 9e9):FindFirstChild(localPlayer.Name)
    if titanFolder then
        if titanFolder:FindFirstChild("Titans") then
            for _, titan in ipairs(titanFolder.Titans:GetChildren()) do
                table.insert(ids, titan.Name)
            end
        end
        if titanFolder:FindFirstChild("Shadows") then
            for _, shadow in ipairs(titanFolder.Shadows:GetChildren()) do
                table.insert(ids, shadow.Name)
            end
        end
        if titanFolder:FindFirstChild("Stands") then
            for _, stand in ipairs(titanFolder.Stands:GetChildren()) do
                table.insert(ids, stand.Name)
            end
        end
    end
    return ids
end

-- Calculate distance
local function getDistance(a, b)
    return (a - b).Magnitude
end

-- Kill Aura Loop
local killAuraThread

local function startKillAura()
    if killAuraThread then return end
    killAuraThread = task.spawn(function()
        while fightersKillAuraEnabled do
            local uniqueIds = getUniqueIds()
            local character = localPlayer.Character
            if #uniqueIds > 0 and character and character:FindFirstChild("HumanoidRootPart") then
                local charPos = character.HumanoidRootPart.Position
                local monstersFolder = getCurrentMonstersFolder()

                -- Attack monsters in the world
                if monstersFolder then
                    for _, monster in ipairs(monstersFolder:GetChildren()) do
                        if monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                            local monsterRoot = monster:FindFirstChild("HumanoidRootPart")
                            if monsterRoot and getDistance(charPos, monsterRoot.Position) <= ATTACK_RANGE then
                                for _, uniqueId in ipairs(uniqueIds) do
                                    ToServer:FireServer({
                                        UniqueId = uniqueId,
                                        Action = "Fighter_Attack",
                                        Target_Id = monster.Name
                                    })
                                end
                            end
                        end
                    end
                end

                -- Attack player's Titans
                local titanFolder = workspace:FindFirstChild("Equipment") and workspace.Equipment:FindFirstChild(localPlayer.Name)
                if titanFolder and titanFolder:FindFirstChild("Titans") then
                    for _, titan in ipairs(titanFolder.Titans:GetChildren()) do
                        if titan:FindFirstChild("Humanoid") and titan.Humanoid.Health > 0 then
                            local titanRoot = titan:FindFirstChild("HumanoidRootPart")
                            if titanRoot and getDistance(charPos, titanRoot.Position) <= ATTACK_RANGE then
                                for _, uniqueId in ipairs(uniqueIds) do
                                    ToServer:FireServer({
                                        UniqueId = uniqueId,
                                        Action = "Fighter_Attack",
                                        Target_Id = titan.Name
                                    })
                                end
                            end
                        end
                    end
                end

                -- Attack player's Shadows
                if titanFolder and titanFolder:FindFirstChild("Shadows") then
                    for _, shadow in ipairs(titanFolder.Shadows:GetChildren()) do
                        if shadow:FindFirstChild("Humanoid") and shadow.Humanoid.Health > 0 then
                            local shadowRoot = shadow:FindFirstChild("HumanoidRootPart")
                            if shadowRoot and getDistance(charPos, shadowRoot.Position) <= ATTACK_RANGE then
                                for _, uniqueId in ipairs(uniqueIds) do
                                    ToServer:FireServer({
                                        UniqueId = uniqueId,
                                        Action = "Fighter_Attack",
                                        Target_Id = shadow.Name
                                    })
                                end
                            end
                        end
                    end
                end

                -- Attack player's Stands
                if titanFolder and titanFolder:FindFirstChild("Stands") then
                    for _, stand in ipairs(titanFolder.Stands:GetChildren()) do
                        if stand:FindFirstChild("Humanoid") and stand.Humanoid.Health > 0 then
                            local standRoot = stand:FindFirstChild("HumanoidRootPart")
                            if standRoot and getDistance(charPos, standRoot.Position) <= ATTACK_RANGE then
                                for _, uniqueId in ipairs(uniqueIds) do
                                    ToServer:FireServer({
                                        UniqueId = uniqueId,
                                        Action = "Fighter_Attack",
                                        Target_Id = stand.Name
                                    })
                                end
                            end
                        end
                    end
                end

            end
            task.wait(ATTACK_DELAY)
        end
        killAuraThread = nil
    end)
end

-- Toggle for Obsidian UI v3
LeftGroupbox:AddToggle(
    "KillAuraToggle",
    {
        Text = "Fighters Kill Aura",
        Default = fightersKillAuraEnabled,
        Tooltip = "Automatically attacks all nearby monsters within range.",
        Callback = function(Value)
            fightersKillAuraEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                startKillAura()
            end
        end
    }
)

-- Auto Rank Toggle
LeftGroupbox:AddToggle(
    "AutoRankToggle",
    {
        Text = "Auto Rank",
        Default = config.AutoRankToggle or false,
        Tooltip = "Automatically ranks up your character.",
        Callback = function(Value)
            autoRankEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                task.spawn(function()
                    while autoRankEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrading_Name"] = "Rank",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Rank_Up"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(1)
                    end
                end)
            end
        end
    }
)

-- Auto Avatar Leveling Toggle
LeftGroupbox:AddToggle(
    "AutoAvatarLevelingToggle",
    {
        Text = "Auto Avatar Leveling",
        Default = config.AutoAvatarLevelingToggle or false,
        Tooltip = "Automatically levels up only avatars that are equipped (have Equipped ImageLabel).",
        Callback = function(Value)
            autoAvatarLevelingEnabled = Value
            -- SaveManager automatically saves this toggle's value

            if Value then
                task.spawn(function()
                    local player = game:GetService("Players").LocalPlayer
                    local avatarList = player.PlayerGui.Inventory_1.Hub.Avatars.List_Frame.List
                    local toServer = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("To_Server")

                    while getgenv().SeisenHubRunning and autoAvatarLevelingEnabled do
                        for _, avatarFrame in pairs(avatarList:GetChildren()) do
                            if avatarFrame:FindFirstChild("Inside") 
                            and avatarFrame.Inside:FindFirstChild("Equipped") then
                                
                                local args = {
                                    [1] = {
                                        ["UniqueId"] = avatarFrame.Name,
                                        ["Action"] = "Leveling_Items",
                                        ["Bench_Name"] = "Avatar_Leveling",
                                    }
                                }
                                pcall(function()
                                    toServer:FireServer(unpack(args))
                                end)
                            end
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    }
)

-- Auto Accept Quests Toggle
LeftGroupbox:AddToggle(
    "AutoAcceptAllQuestsToggle",
    {
        Text = "Auto Accept & Claim All Quests",
        Default = config.AutoAcceptAllQuestsToggle or false,
        Tooltip = "Automatically accepts and claims all quests.",
        Callback = function(Value)
            autoAcceptAllQuestsEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                task.spawn(function()
                    while autoAcceptAllQuestsEnabled and getgenv().SeisenHubRunning do
                        for questId = 1, 150 do
                            local argsAccept = {
                                [1] = {
                                    ["Id"] = tostring(questId),
                                    ["Type"] = "Accept",
                                    ["Action"] = "_Quest"
                                }
                            }
                            pcall(function() ToServer:FireServer(unpack(argsAccept)) end)
                            task.wait(0.05)
                            local argsComplete = {
                                [1] = {
                                    ["Id"] = tostring(questId),
                                    ["Type"] = "Complete",
                                    ["Action"] = "_Quest"
                                }
                            }
                            pcall(function() ToServer:FireServer(unpack(argsComplete)) end)
                            task.wait(0.05)
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    }
)

-- Auto Claim Achievements Toggle
LeftGroupbox:AddToggle(
    "AutoClaimAchievement",
    {
        Text = "Auto Achievements",
        Default = config.AutoClaimAchievement or false,
        Tooltip = "Automatically claims achievements.",
        Callback = function(Value)
            autoClaimAchievementsEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                task.spawn(function()
                    local achievements = {
                        Total_Energy = 51,
                        Total_Coins = 27,
                        Friends_Bonus = 5,
                        Time_Played = 10,
                        Stars = 10,
                        Defeats = 15,
                        Dungeon_Easy = 5,
                        Total_Dungeon_Easy = 5,
                        Dungeon_Medium = 5,
                        Total_Dungeon_Medium = 5,
                        Dungeon_Hard = 5,
                        Total_Dungeon_Hard = 5,
                        Dungeon_Insane = 5,
                        Total_Dungeon_Insane = 5,
                        Dungeon_Crazy = 5,
                        Total_Dungeon_Crazy = 5,
                        Dungeon_Nightmare = 5,
                        Total_Dungeon_Nightmare = 5,
                        Leaf_Raid = 16,
                        Titan_Defense = 11,
                        Restaurant_Raid = 11,
                        Gleam_Raid  = 9,
                        Kaiju_Dungeon = 5,
                        Total_Kaiju_Dungeon = 5,
                        Ghoul_Raid = 16,
                        Progression_Raid = 11,
                        Progression_Raid_2 = 11,
                        Chainsaw_Defense = 11,
                        Tournament_Raid = 30,
                        Cursed_Raid = 11,
                        Netherworld_Defense = 6,
                        Sin_Raid = 11,
                        Green_Planet_Raid = 11,
                        Dungeon_Suffering = 5,
                        Total_Dungeon_Suffering = 5,
                        Mundo_Raid = 9,
                        Hollow_Riad = 11,
                        Dragon_Room_Raid = 20,
                        Total_Running_Track_Raid = 10,
                        Halloween_Raid = 20,
                        Graveyard__Defense = 20,
                        Dungeon_Adventurer = 5,
                        Total_Dungeon_Adventurer = 5,
                        Dungeon_Torment = 5,
                        Total_Dungeon_Torment = 5,
                    }
                    local function toRoman(num)
                        local romanNumerals = {
                            [1] = "I", [2] = "II", [3] = "III", [4] = "IV", [5] = "V", [6] = "VI", [7] = "VII", [8] = "VIII", [9] = "IX", [10] = "X",
                            [11] = "XI", [12] = "XII", [13] = "XIII", [14] = "XIV", [15] = "XV", [16] = "XVI", [17] = "XVII", [18] = "XVIII", [19] = "XIX", [20] = "XX",
                            [21] = "XXI", [22] = "XXII", [23] = "XXIII", [24] = "XXIV", [25] = "XXV", [26] = "XXVI", [27] = "XXVII", [28] = "XXVIII", [29] = "XXIX", [30] = "XXX",
                            [31] = "XXXI", [32] = "XXXII", [33] = "XXXIII", [34] = "XXXIV", [35] = "XXXV", [36] = "XXXVI", [37] = "XXXVII", [38] = "XXXVIII", [39] = "XXXIX", [40] = "XL",
                            [41] = "XLI", [42] = "XLII", [43] = "XLIII", [44] = "XLIV", [45] = "XLV", [46] = "XLVI", [47] = "XLVII", [48] = "XLVIII", [49] = "XLIX", [50] = "L",
                            [51] = "LI", [52] = "LII", [53] = "LIII", [54] = "LIV", [55] = "LV", [56] = "LVI", [57] = "LVII", [58] = "LVIII", [59] = "LIX", [60] = "LX",
                            [61] = "LXI", [62] = "LXII", [63] = "LXIII", [64] = "LXIV", [65] = "LXV", [66] = "LXVI", [67] = "LXVII", [68] = "LXVIII", [69] = "LXIX", [70] = "LXX",
                            [71] = "LXXI", [72] = "LXXII", [73] = "LXXIII", [74] = "LXXIV", [75] = "LXXV", [76] = "LXXVI", [77] = "LXXVII", [78] = "LXXVIII", [79] = "LXXIX", [80] = "LXXX",
                            [81] = "LXXXI", [82] = "LXXXII", [83] = "LXXXIII", [84] = "LXXXIV", [85] = "LXXXV", [86] = "LXXXVI", [87] = "LXXXVII", [88] = "LXXXVIII", [89] = "LXXXIX", [90] = "XC",
                            [91] = "XCI", [92] = "XCII", [93] = "XCIII", [94] = "XCIV", [95] = "XCV", [96] = "XCVI", [97] = "XCVII", [98] = "XCVIII", [99] = "XCIX", [100] = "C",
                        }
                        return romanNumerals[num]
                    end
                    while autoClaimAchievementsEnabled and getgenv().SeisenHubRunning do
                        for name, maxLevel in pairs(achievements) do
                            for i = 1, maxLevel do
                                local id = name .. "_" .. toRoman(i)
                                local args = {
                                    [1] = {
                                        ["Action"] = "Achievements",
                                        ["Id"] = id
                                    }
                                }
                                pcall(function() ToServer:FireServer(unpack(args)) end)
                                task.wait(0.2)
                            end
                        end
                        task.wait(3)
                    end
                end)
            end
        end
    }
)

-- Auto Accept Hero Quest Toggle
LeftGroupbox:AddToggle(
    "AutoAcceptHeroQuestToggle",
    {
        Text = "Auto Accept Hero Quests",
        Default = false,
        Tooltip = "Automatically accepts all Hero Quests (Id 2501 to 2528) every 2 seconds.",
        Callback = function(Value)
            autoAcceptHeroQuestEnabled = Value
            if Value then
                task.spawn(function()
                    while autoAcceptHeroQuestEnabled and getgenv().SeisenHubRunning do
                        for questId = 2501, 2544 do
                            -- Accept quest
                            local argsAccept = {
                                [1] = {
                                    ["Id"] = tostring(questId),
                                    ["Type"] = "Accept",
                                    ["Action"] = "_Quest",
                                }
                            }
                            pcall(function()
                                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(argsAccept))
                            end)
                            task.wait(0.1)
                            -- Complete quest
                            local argsComplete = {
                                [1] = {
                                    ["Id"] = tostring(questId),
                                    ["Type"] = "Complete",
                                    ["Action"] = "_Quest",
                                }
                            }
                            pcall(function()
                                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(argsComplete))
                            end)
                            task.wait(0.1)
                        end
                        task.wait(2)
                    end
                end)
            end
        end
    }
)

LeftGroupbox:AddToggle(
    "AutoObeliskToggle",
    {
        Text = "Obelisk Upgrade",
        Default = config.AutoObeliskToggle or false,
        Tooltip = "Automatically upgrades your Obelisk.",
        Callback = function(Value)
            autoObeliskEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                task.spawn(function()
                    local obeliskTypes = {
                        "Dragon_Obelisk", "Pirate_Obelisk", "Soul_Obelisk", "Sorcerer_Obelisk",
                        "Slayer_Obelisk", "Solo_Obelisk", "Clover_Obelisk", "Leaf_Obelisk",
                        "Granny_Obelisk", "Hunter_Obelisk", "Titan_Obelisk", "Sin_Obelisk",
                        "Kaiju_Obelisk", "Slime_Obelisk", "Sword_Art_Obelisk", "JoJo_Obelisk",
                        "Ghoul_Obelisk", "Chainsaw_Obelisk",
                    }
                    while autoObeliskEnabled and getgenv().SeisenHubRunning do
                        for _, obeliskType in ipairs(obeliskTypes) do
                            pcall(function()
                                ToServer:FireServer({
                                    Upgrading_Name = "Obelisk",
                                    Action = "_Upgrades",
                                    Upgrade_Name = obeliskType
                                })
                            end)
                            task.wait(0.2)
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    }
)

LeftGroupbox:AddToggle("AutoPrestigeToggle", {
    Text = "Auto Prestige",
    Default = config.AutoPrestigeToggle or false,
    Tooltip = "Automatically levels up prestige.",
    Callback = function(Value)
        autoPrestigeEnabled = Value
        config.AutoPrestigeToggle = Value
    end
})

task.spawn(function()
    while task.wait(0.5) do
        if autoPrestigeEnabled then
            local args = {
                [1] = {
                    ["Action"] = "Level_Up_Prestige",
                }
            }
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
            end)
        end
    end
end)

StatsGroupbox:AddDropdown(
    "AutoStatSingleDropdown",
    {
        Values = stats,
        Default = selectedStat,
        Multi = false,
        Text = "Select Stat",
        Tooltip = "Select which stat to auto assign points to.",
        Callback = function(Value)
            selectedStat = Value -- display name
            -- SaveManager automatically saves this dropdown's value
        end
    }
)

StatsGroupbox:AddToggle(
    "AutoAssignStatToggle",
    {
        Text = "Enable Auto Stat",
        Default = autoStatsRunning,
        Tooltip = "Enable automatic stat assignment.",
        Callback = function(Value)
            autoStatsRunning = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                local function startAutoStats()
                    task.spawn(function()
                        while task.wait(1) do
                            if autoStatsRunning and selectedStat then
                                if not statMap then
                                    warn("statMap is nil!")
                                    return
                                end
                                local statName = statMap[selectedStat]
                                if not statName then
                                    warn("Invalid stat selected:", selectedStat)
                                    return
                                end
                                local args = {
                                    [1] = {
                                        ["Name"] = statName,
                                        ["Action"] = "Assign_Level_Stats",
                                        ["Amount"] = pointsPerSecond
                                    }
                                }
                                pcall(function()
                                    ToServer:FireServer(unpack(args))
                                end)
                            end
                        end
                    end)
                end
                startAutoStats()
            end
        end
    }
)

StatsGroupbox:AddSlider(
    "PointsPerSecondSlider",
    {
        Text = "Points/Second",
        Default = pointsPerSecond,
        Min = 1,
        Max = 10,
        Rounding = 0,
        Tooltip = "Set how many stat points to assign per second.",
        Callback = function(Value)
            pointsPerSecond = Value
            -- SaveManager automatically saves this slider's value
        end
    }
)

RewardsGroupbox:AddToggle("AutoTimeRewardToggle", {
    Text = "Auto Time Reward",
    Default = isAutoTimeRewardEnabled,
    Tooltip = "Automatically claims hourly time rewards.",
    Callback = function(Value)
        isAutoTimeRewardEnabled = Value
        -- SaveManager automatically saves this toggle's value
        if Value then
            task.spawn(function()
                while isAutoTimeRewardEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Action"] = "_Hourly_Rewards",
                            ["Id"] = "All"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

RewardsGroupbox:AddToggle("AutoDailyChestToggle", {
    Text = "Auto Daily Chest",
    Default = isAutoDailyChestEnabled,
    Tooltip = "Automatically claims daily chest.",
    Callback = function(Value)
        isAutoDailyChestEnabled = Value
        -- SaveManager automatically saves this toggle's value
        if Value then
            task.spawn(function()
                while isAutoDailyChestEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Action"] = "_Chest_Claim",
                            ["Name"] = "Daily"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

RewardsGroupbox:AddToggle("AutoVipChestToggle", {
    Text = "Auto VIP Chest",
    Default = isAutoVipChestEnabled,
    Tooltip = "Automatically claims VIP chest.",
    Callback = function(Value)
        isAutoVipChestEnabled = Value
        -- SaveManager automatically saves this toggle's value
        if Value then
            task.spawn(function()
                while isAutoVipChestEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Action"] = "_Chest_Claim",
                            ["Name"] = "Vip"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

RewardsGroupbox:AddToggle("AutoGroupChestToggle", {
    Text = "Auto Group Chest",
    Default = isAutoGroupChestEnabled,
    Tooltip = "Automatically claims group chest.",
    Callback = function(Value)
        isAutoGroupChestEnabled = Value
        -- SaveManager automatically saves this toggle's value
        if Value then
            task.spawn(function()
                while isAutoGroupChestEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Action"] = "_Chest_Claim",
                            ["Name"] = "Group"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

RewardsGroupbox:AddToggle("AutoPremiumChestToggle", {
    Text = "Auto Premium Chest",
    Default = isAutoPremiumChestEnabled,
    Tooltip = "Automatically claims premium chest.",
    Callback = function(Value)
        isAutoPremiumChestEnabled = Value
        -- SaveManager automatically saves this toggle's value
        if Value then
            task.spawn(function()
                while isAutoPremiumChestEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Action"] = "_Chest_Claim",
                            ["Name"] = "Premium"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

--// Potion list (name -> id)
local potions = {
    ["Coins Potion"] = "1001",
    ["Damage Potion"] = "1002",
    ["Energy Potion"] = "1003",
    ["Luck Potion"] = "1004",
    ["Drop Potion"] = "1005",
    ["Exp Potion"] = "1006",
    ["Soul Potion"] = "1007",

    ["Small Coin Potion"] = "1011",
    ["Small Damage Potion"] = "1012",
    ["Small Energy Potion"] = "1013",
    ["Small Luck Potion"] = "1014",
    ["Small Drop Potion"] = "1015",
    ["Shadow Soul Potion"] = "1016",

    ["Chocolate Bar"] = "1101",
    ["Cheese Pizza Slice"] = "1102",
    ["Milk"] = "1103",
    ["Green Gummy Bear"] = "1104",
    ["Hot Sauce"] = "1105",
    ["Coffee"] = "1106",
    ["Doughnut"] = "1107",
    ["Fried Egg"] = "1108",

    ["Energy Macaron"] = "1109",
    ["Coin Macaron"] = "1110",
    ["Damage Macaron"] = "1111",
    ["Luck Macaron"] = "1112",
    ["Exp Macaron"] = "1113",
    ["Star Macaron"] = "1114",
    ["Soul Macaron"] = "1115",
    ["Drop Macaron"] = "1116",
    ["Waffle"] = "1117",
}

-- prepare sorted potion names
local potionNames = {}
for name, _ in pairs(potions) do
    table.insert(potionNames, name)
end
-- Sort potion names by their numeric ID (ascending)
table.sort(potionNames, function(a, b)
    local ai = tonumber(potions[a]) or 0
    local bi = tonumber(potions[b]) or 0
    return ai < bi
end)

-- store selected potion IDs (as strings)
local selectedPotions = {}
local autoUsePotionsThread = nil

-- map potion id to internal name for pause
local potionIdToInternal = {
    ["1001"] = "Coins_Potion",
    ["1002"] = "Damage_Potion",
    ["1003"] = "Energy_Potion",
    ["1004"] = "Luck_Potion",
    ["1005"] = "Drop_Potion",
    ["1006"] = "Exp_Potion",
    ["1007"] = "Soul_Potion",
    ["1011"] = "Small_Coin_Potion",
    ["1012"] = "Small_Damage_Potion",
    ["1013"] = "Small_Energy_Potion",
    ["1014"] = "Small_Luck_Potion",
    ["1015"] = "Small_Drop_Potion",
    ["1101"] = "Chocolate_Bar",
    ["1102"] = "Cheese_Pizza_Slice",
    ["1103"] = "Milk",
    ["1104"] = "Green_Gummy_Bear",
    ["1105"] = "Hot_Sauce",
    ["1106"] = "Coffee",
    ["1107"] = "Doughnut",
    ["1108"] = "Fried_Egg",
    ["1109"] = "Energy_Macaron",
    ["1110"] = "Coin_Macaron",
    ["1111"] = "Damage_Macaron",
    ["1112"] = "Luck_Macaron",
    ["1113"] = "Exp_Macaron",
    ["1114"] = "Star_Macaron",
    ["1115"] = "Soul_Macaron",
    ["1116"] = "Drop_Macaron",
    ["1117"] = "Waffle",
}

PotionGroupbox:AddDropdown(
    "PotionDropdown",
    {
            Title = "Select Potions",
            Values = potionNames,
            Default = config.PotionDropdown or {},
            Multi = true,
            Callback = function(selection)
                selectedPotions = {}
                local selectedNames = {}
                if not selection then
                    return
                end
                local t = type(selection)
                if t == "string" then
                    local id = potions[selection]
                    if id then
                        table.insert(selectedPotions, id)
                    end
                    table.insert(selectedNames, selection)
                elseif t == "table" then
                    for k, v in pairs(selection) do
                        if type(k) == "string" and (v == true or v == 1) then
                            local id = potions[k]
                            if id then
                                table.insert(selectedPotions, id)
                            end
                            table.insert(selectedNames, k)
                        elseif type(v) == "string" then
                            local id = potions[v]
                            if id then
                                table.insert(selectedPotions, id)
                            end
                            table.insert(selectedNames, v)
                        end
                    end
                end
                -- If auto-use is enabled, restart the thread to use the new selection
                if autoUsePotionsEnabled then
                    autoUsePotionsEnabled = false
                    task.wait(0.1)
                    autoUsePotionsEnabled = true
                    if autoUsePotionsThread == nil then
                        autoUsePotionsThread = task.spawn(function()
                            while autoUsePotionsEnabled do
                                if #selectedPotions == 0 then
                                    task.wait(0.5)
                                else
                                    for _, potionId in ipairs(selectedPotions) do
                                        local args = {
                                            [1] = {
                                                ["Selected"] = {[1] = potionId},
                                                ["Action"] = "Use",
                                                ["Amount"] = 100
                                            }
                                        }
                                        ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("Inventory", 9e9):FireServer(unpack(args))
                                        task.wait(0.08)
                                    end
                                end
                                task.wait(0.5)
                            end
                            autoUsePotionsThread = nil
                        end)
                    end
                end
            end
    }
)

-- Button: fire Use for each selected potion (small delay to avoid server spam)
PotionGroupbox:AddToggle("AutoUsePotionsToggle", {
    Text = "Auto Use Selected Potions",
    Default = false,
    Tooltip = "Continuously uses all selected potions while enabled.",
    Callback = function(state)
        if state then
            autoUsePotionsEnabled = true
            if autoUsePotionsThread == nil then
                autoUsePotionsThread = task.spawn(function()
                    while autoUsePotionsEnabled do
                        if #selectedPotions == 0 then
                            task.wait(0.5)
                        else
                            for _, potionId in ipairs(selectedPotions) do
                                local args = {
                                    [1] = {
                                        ["Selected"] = {[1] = potionId},
                                        ["Action"] = "Use",
                                        ["Amount"] = 1
                                    }
                                }
                                ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("Inventory", 9e9):FireServer(unpack(args))
                                task.wait(0.08)
                            end
                        end
                        task.wait(0.5)
                    end
                    autoUsePotionsThread = nil
                end)
            end
        else
            autoUsePotionsEnabled = false
        end
    end
})

---========================================== Tab: Teleport & Dungeon ==========================================---
-- Tp and Dungeon Feature
function startBasicAutoDungeon()
    local player = game:GetService("Players").LocalPlayer
    local myHRP = nil
    local currentTarget = nil
    local teleported = false -- ✅ Make sure we teleport only once per enemy

    while basicAutoDungeonEnabled and getgenv().SeisenHubRunning do
        myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then
            task.wait(1)
            continue
        end

        -- ✅ Dungeon UI check
        local gui = player:FindFirstChild("PlayerGui")
        local dungeonGui = gui and gui:FindFirstChild("Dungeon")
        local notification = dungeonGui and dungeonGui:FindFirstChild("Dungeon_Notification")
        local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
        local shouldRun = (notification and notification.Visible) or (header and header.Visible)

        if not shouldRun then
            currentTarget = nil
            teleported = false
            task.wait(1)
            continue
        end

        -- ✅ Find a target ONLY if we don't have one
        if not currentTarget then
            local monstersFolder = workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Monsters")
                or workspace:FindFirstChild("Monsters")

            if monstersFolder then
                local nearestMonster, nearestDist = nil, math.huge
                for _, monster in pairs(monstersFolder:GetChildren()) do
                    if monster:IsA("Model") then
                        local hrp = monster:FindFirstChild("HumanoidRootPart")
                        local hum = monster:FindFirstChild("Humanoid")
                        if hrp and hum and hum.Health > 0 then
                            local dist = (myHRP.Position - hrp.Position).Magnitude
                            if dist < nearestDist and dist <= 300 then
                                nearestDist = dist
                                nearestMonster = monster
                            end
                        end
                    end
                end

                if nearestMonster then
                    currentTarget = nearestMonster
                    teleported = false -- Reset teleport flag for new enemy
                end
            end
        end

        -- ✅ Teleport ONCE in front of target
        if currentTarget and not teleported then
            local hrp = currentTarget:FindFirstChild("HumanoidRootPart")
            local hum = currentTarget:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                myHRP.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 3)
                teleported = true -- ✅ Teleport only once
            else
                -- Target is gone, reset
                currentTarget = nil
            end
        end

        -- ✅ Attack current target
        if currentTarget and teleported then
            local hum = currentTarget:FindFirstChild("Humanoid")
            local hrp = currentTarget:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                if (myHRP.Position - hrp.Position).Magnitude < 25 then
                    local args = {
                        [1] = {
                            ["Id"] = currentTarget.Name,
                            ["Action"] = "_Mouse_Click",
                            ["Critical"] = true
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                end
            else
                -- ✅ Enemy dead or removed → reset so next loop can teleport to next enemy
                currentTarget = nil
                teleported = false
            end
        end

        task.wait(killAuraDelay or 0.25) -- Use global killAuraDelay
    end
end



-- Auto Dungeon Toggle
DungeonGroupbox:AddToggle(
    "BasicAutoDungeonToggle",
    {
        Text = "Auto Dungeon",
        Default = config.BasicAutoDungeonToggle or false,
        Tooltip = "Teleports to nearest enemy ONCE and uses kill aura until it dies.",
        Callback = function(Value)
            basicAutoDungeonEnabled = Value
            -- SaveManager automatically saves this toggle's value
        end
    }
)

-- Unified watcher for pausing Auto Farm and running Auto Dungeon based on Default_Header visibility
if not unifiedWatcherStarted then
    unifiedWatcherStarted = true
    local wasAutoFarmOnBeforeDungeon = false
    local lastHeaderVisible = false
    task.spawn(function()
        local player = game:GetService("Players").LocalPlayer
        while getgenv().SeisenHubRunning do
            local gui = player:FindFirstChild("PlayerGui")
            local dungeonGui = gui and gui:FindFirstChild("Dungeon")
            local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
            local headerVisible = (header and header.Visible)

            -- Pause Auto Farm and start Auto Dungeon when inside dungeon (header visible)
            if headerVisible and not lastHeaderVisible then
                if teleportAndAttackEnabled then
                    wasAutoFarmOnBeforeDungeon = true
                    teleportAndAttackEnabled = false
                    teleportAndAttackRunning = false
                    if LeftGroupbox.Flags and LeftGroupbox.Flags.TeleportAndAttackToggle then
                        LeftGroupbox.Flags.TeleportAndAttackToggle:Set(false)
                    end
                end
                if basicAutoDungeonEnabled then
                    task.spawn(startBasicAutoDungeon)
                end
            end

            -- Resume Auto Farm when leaving dungeon (header not visible)
            if not headerVisible and lastHeaderVisible then
                if wasAutoFarmOnBeforeDungeon then
                    wasAutoFarmOnBeforeDungeon = false
                    teleportAndAttackEnabled = true
                    task.delay(0.1, startTeleportAndAttack)
                    if LeftGroupbox.Flags and LeftGroupbox.Flags.TeleportAndAttackToggle then
                        LeftGroupbox.Flags.TeleportAndAttackToggle:Set(true)
                    end
                end
            end

            lastHeaderVisible = headerVisible
            task.wait(0.3)
        end
    end)
end

-- Dungeon Toggles (per-dungeon auto-enter)
local dungeonList = {
    "Dungeon_Easy",
    "Dungeon_Medium",
    "Dungeon_Hard",
    "Dungeon_Insane",
    "Dungeon_Crazy",
    "Dungeon_Nightmare",
    "Leaf_Raid",
}

for _, dungeon in ipairs(dungeonList) do
    local default = (type(selectedDungeons) == "table" and table.find(selectedDungeons, dungeon) ~= nil) or false
    DungeonGroupbox:AddToggle(
        "Toggle_" .. dungeon,
        {
            Text = dungeon:gsub("_", " "),
            Default = default,
            Tooltip = "Enable Auto Enter for " .. dungeon:gsub("_", " "),
            Callback = function(Value)
                -- Update selectedDungeons for the monitor
                if type(selectedDungeons) ~= "table" then selectedDungeons = {} end
                if Value then
                    if not table.find(selectedDungeons, dungeon) then
                        table.insert(selectedDungeons, dungeon)
                    end
                    -- Immediately try to enter the dungeon, but only if we're not already inside a dungeon
                    local player = game:GetService("Players").LocalPlayer
                    local gui = player and player:FindFirstChild("PlayerGui")
                    local dungeonGui = gui and gui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    if not (header and header.Visible) then
                        -- Intentionally do NOT call server here. Selected dungeons are processed
                        -- by the AutoEnterOnNotification watcher when a notification appears.
                    end
                else
                    for i, v in ipairs(selectedDungeons) do
                        if v == dungeon then
                            table.remove(selectedDungeons, i)
                            break
                        end
                    end
                end
            end
        }
    )
end

local function startAutoEnterOnNotification()
    if autoEnterNotificationThread then return end
    autoEnterNotificationThread = task.spawn(function()
        local lastText = ""
        while autoEnterOnNotificationEnabled and getgenv().SeisenHubRunning do
            local player = game:GetService("Players").LocalPlayer
            local gui = player and player:FindFirstChild("PlayerGui")
            local dungeonGui = gui and gui:FindFirstChild("Dungeon")
            local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
            local notification = dungeonGui and dungeonGui:FindFirstChild("Dungeon_Notification")

            -- If the dungeon header is already visible we're inside a dungeon/session.
            -- Do not try to auto-enter while header is visible.
            if header and header.Visible then
                lastText = ""
                task.wait(1.5)
            elseif notification and notification.Visible then
                local textLabel = notification:FindFirstChild("TextLabel")
                local raw = textLabel and textLabel.Text or ""
                -- strip simple html tags like <font ...>
                local clean = raw:gsub("<.->", "")
                if clean ~= lastText and clean ~= "" then
                    lastText = clean
                    local lower = clean:lower()
                    for _, dungeon in ipairs(dungeonList) do
                        local display = dungeon:gsub("_", " "):lower()
                        if lower:find(display) then
                            -- Only enter if that dungeon is enabled in selectedDungeons
                            if type(selectedDungeons) ~= "table" then selectedDungeons = {} end
                            if table.find(selectedDungeons, dungeon) then
                                local args = {
                                    [1] = {
                                        ["Action"] = "_Enter_Dungeon",
                                        ["Name"] = dungeon,
                                    }
                                }
                                pcall(function()
                                    ToServer:FireServer(unpack(args))
                                end)
                            end
                            break
                        end
                    end
                end
            else
                lastText = ""
            end
            task.wait(1.5)
        end
        autoEnterNotificationThread = nil
    end)
end

DungeonGroupbox:AddToggle("AutoEnterOnNotificationToggle", {
    Text = "Auto Enter Dungeon",
    Default = config.AutoEnterOnNotificationToggle or false,
    Tooltip = "",
    Callback = function(Value)
        autoEnterOnNotificationEnabled = Value
        if Value then
            startAutoEnterOnNotification()
        else
            autoEnterOnNotificationEnabled = false
        end
    end
})


-- Auto enter Restaurant Raid toggle
RaidDefense:AddToggle(
    "AutoEnterRestaurantRaidToggle",
    {
        Text = "Auto Enter Restaurant Raid",
        Default = config.AutoEnterRestaurantRaidToggle or false,
        Tooltip = "Automatically enters Restaurant Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterRestaurantRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterRestaurantRaidConnection then autoEnterRestaurantRaidConnection:Disconnect() end
                autoEnterRestaurantRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    -- Check if Restaurant Raid header is NOT visible or doesn't contain "Restaurant Raid"
                    if not (header and header.Visible and title and string.find(title.Text or "", "Restaurant")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Restaurant_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3) -- Check every 3 seconds
                end)
            else
                if autoEnterRestaurantRaidConnection then
                    autoEnterRestaurantRaidConnection:Disconnect()
                    autoEnterRestaurantRaidConnection = nil
                end
            end
        end
    }
)

-- Auto enter Ghoul Raid toggle
RaidDefense:AddToggle(
    "AutoEnterGhoulRaidToggle",
    {
        Text = "Auto Enter Ghoul Raid",
        Default = config.AutoEnterGhoulRaidToggle or false,
        Tooltip = "Automatically enters Ghoul Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterGhoulRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterGhoulRaidConnection then autoEnterGhoulRaidConnection:Disconnect() end
                autoEnterGhoulRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    if not (header and header.Visible and title and string.find(title.Text or "", "Ghoul")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Ghoul_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterGhoulRaidConnection then
                    autoEnterGhoulRaidConnection:Disconnect()
                    autoEnterGhoulRaidConnection = nil
                end
            end
        end
    }
)

-- Auto enter Progression Raid toggle
RaidDefense:AddToggle(
    "AutoEnterProgressionRaidToggle",
    {
        Text = "Auto Enter Progression Raid",
        Default = config.AutoEnterProgressionRaidToggle or false,
        Tooltip = "Automatically enters Progression Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterProgressionRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterProgressionRaidConnection then autoEnterProgressionRaidConnection:Disconnect() end
                autoEnterProgressionRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    if not (header and header.Visible and title and string.find(title.Text or "", "Progression")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Progression_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterProgressionRaidConnection then
                    autoEnterProgressionRaidConnection:Disconnect()
                    autoEnterProgressionRaidConnection = nil
                end
            end
        end
    }
)

-- Auto enter Gleam Raid toggle
RaidDefense:AddToggle(
    "AutoEnterGleamRaidToggle",
    {
        Text = "Auto Enter Gleam Raid",
        Default = config.AutoEnterGleamRaidToggle or false,
        Tooltip = "Automatically enters Gleam Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterGleamRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterGleamRaidConnection then autoEnterGleamRaidConnection:Disconnect() end
                autoEnterGleamRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    if not (header and header.Visible and title and string.find(title.Text or "", "Gleam")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Gleam_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterGleamRaidConnection then
                    autoEnterGleamRaidConnection:Disconnect()
                    autoEnterGleamRaidConnection = nil
                end
            end
        end
    }
)

-- Auto enter Tournament Raid toggle
RaidDefense:AddToggle(
    "AutoEnterTournamentRaidToggle",
    {
        Text = "Auto Enter Tournament Raid",
        Default = config.AutoEnterTournamentRaidToggle or false,
        Tooltip = "Automatically enters Tournament Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterTournamentRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterTournamentRaidConnection then autoEnterTournamentRaidConnection:Disconnect() end
                autoEnterTournamentRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    if not (header and header.Visible and title and string.find(title.Text or "", "Tournament")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Tournament_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterTournamentRaidConnection then
                    autoEnterTournamentRaidConnection:Disconnect()
                    autoEnterTournamentRaidConnection = nil
                end
            end
        end
    }
)

-- Auto enter Cursed Raid toggle
RaidDefense:AddToggle(
    "AutoEnterCursedRaidToggle",
    {
        Text = "Auto Enter Cursed Raid",
        Default = config.AutoEnterCursedRaidToggle or false,
        Tooltip = "Automatically enters Cursed Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterCursedRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterCursedRaidConnection then autoEnterCursedRaidConnection:Disconnect() end
                autoEnterCursedRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    if not (header and header.Visible and title and string.find(title.Text or "", "Cursed")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Cursed_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterCursedRaidConnection then
                    autoEnterCursedRaidConnection:Disconnect()
                    autoEnterCursedRaidConnection = nil
                end
            end
        end
    }
)

-- Auto enter Chainsaw Defense toggle
RaidDefense:AddToggle(
    "AutoEnterChainsawDefenseToggle",
    {
        Text = "Auto Enter Chainsaw Defense",
        Default = config.AutoEnterChainsawDefenseToggle or false,
        Tooltip = "Automatically enters Chainsaw Defense when not in dungeon.",
        Callback = function(Value)
            autoEnterChainsawDefenseEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterChainsawDefenseConnection then autoEnterChainsawDefenseConnection:Disconnect() end
                autoEnterChainsawDefenseConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    if not (header and header.Visible and title and string.find(title.Text or "", "Chainsaw")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Chainsaw_Defense"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterChainsawDefenseConnection then
                    autoEnterChainsawDefenseConnection:Disconnect()
                    autoEnterChainsawDefenseConnection = nil
                end
            end
        end
    }
)

-- Auto enter Titan Defense toggle
RaidDefense:AddToggle(
    "AutoEnterTitanDefenseToggle",
    {
        Text = "Auto Enter Titan Defense",
        Default = config.AutoEnterTitanDefenseToggle or false,
        Tooltip = "Automatically enters Titan Defense when not in dungeon.",
        Callback = function(Value)
            autoEnterTitanDefenseEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterTitanDefenseConnection then autoEnterTitanDefenseConnection:Disconnect() end
                autoEnterTitanDefenseConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    if not (header and header.Visible and title and string.find(title.Text or "", "Titan")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Titan_Defense"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterTitanDefenseConnection then
                    autoEnterTitanDefenseConnection:Disconnect()
                    autoEnterTitanDefenseConnection = nil
                end
            end
        end
    }
)

-- Auto enter Kaiju Dungeon toggle
RaidDefense:AddToggle(
    "AutoEnterKaijuDungeonToggle",
    {
        Text = "Auto Enter Kaiju Dungeon",
        Default = config.AutoEnterKaijuDungeonToggle or false,
        Tooltip = "Automatically enters Kaiju Dungeon when not in dungeon.",
        Callback = function(Value)
            autoEnterKaijuDungeonEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterKaijuDungeonConnection then autoEnterKaijuDungeonConnection:Disconnect() end
                autoEnterKaijuDungeonConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    if not (header and header.Visible and title and string.find(title.Text or "", "Kaiju")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Kaiju_Dungeon"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterKaijuDungeonConnection then
                    autoEnterKaijuDungeonConnection:Disconnect()
                    autoEnterKaijuDungeonConnection = nil
                end
            end
        end
    }
)

-- Auto enter Sin Raid toggle
RaidDefense:AddToggle(
    "AutoEnterSinRaidToggle",
    {
        Text = "Auto Enter Sin Raid",
        Default = config.AutoEnterSinRaidToggle or false,
        Tooltip = "Automatically enters Sin Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterSinRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterSinRaidConnection then autoEnterSinRaidConnection:Disconnect() end
                autoEnterSinRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    if not (header and header.Visible and title and string.find(title.Text or "", "Sin")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Sin_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterSinRaidConnection then
                    autoEnterSinRaidConnection:Disconnect()
                    autoEnterSinRaidConnection = nil
                end
            end
        end
    }
)

-- Auto enter Sin Raid toggle
RaidDefense:AddToggle(
    "AutoEnterDungeonSufferingToggle",
    {
        Text = "Auto Enter Dungeon Suffering",
        Default = config.AutoEnterDungeonSufferingToggle or false,
        Tooltip = "Automatically enters Dungeon Suffering when not in dungeon.",
        Callback = function(Value)
            autoEnterDungeonSufferingEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterDungeonSufferingConnection then autoEnterDungeonSufferingConnection:Disconnect() end
                autoEnterDungeonSufferingConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")

                    if not (header and header.Visible and title and string.find(title.Text or "", "Suffering")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Dungeon_Suffering"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterDungeonSufferingConnection then
                    autoEnterDungeonSufferingConnection:Disconnect()
                    autoEnterDungeonSufferingConnection = nil
                end
            end
        end
    }
)


-- Auto enter Sin Raid toggle
RaidDefense:AddToggle(
    "AutoEnterMundoRaidToggle",
    {
        Text = "Auto Enter Mundo Raid",
        Default = config.AutoEnterMundoRaidToggle or false,
        Tooltip = "Automatically enters Mundo Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterMundoRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterMundoRaidConnection then autoEnterMundoRaidConnection:Disconnect() end
                autoEnterMundoRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    if not (header and header.Visible and title and string.find(title.Text or "", "Mundo")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Mundo_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterMundoRaidConnection then
                    autoEnterMundoRaidConnection:Disconnect()
                    autoEnterMundoRaidConnection = nil
                end
            end
        end
    }
)


-- Auto enter Dragon Room toggle
RaidDefense:AddToggle(
    "AutoEnterDragonRoomRaidToggle",
    {
        Text = "Auto Enter Dragon Room Raid",
        Default = config.AutoEnterDragonRoomRaidToggle or false,
        Tooltip = "Automatically enters Dragon Room Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterDragonRoomRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterDragonRoomRaidConnection then autoEnterDragonRoomRaidConnection:Disconnect() end
                autoEnterDragonRoomRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")

                    if not (header and header.Visible and title and string.find(title.Text or "", "Dragon")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Dragon_Room_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterDragonRoomRaidConnection then
                    autoEnterDragonRoomRaidConnection:Disconnect()
                    autoEnterDragonRoomRaidConnection = nil
                end
            end
        end
    }
)

-- Auto enter Tomb Arena toggle
RaidDefense:AddToggle(
    "AutoEnterTombArenaRaidToggle",
    {
        Text = "Auto Enter Tomb Arena Raid",
        Default = config.AutoEnterTombArenaRaidToggle or false,
        Tooltip = "Automatically enters Tomb Arena Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterTombArenaRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterTombArenaRaidConnection then autoEnterTombArenaRaidConnection:Disconnect() end
                autoEnterTombArenaRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")

                    if not (header and header.Visible and title and string.find(title.Text or "", "Tomb")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Tomb_Arena_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterTombArenaRaidConnection then
                    autoEnterTombArenaRaidConnection:Disconnect()
                    autoEnterTombArenaRaidConnection = nil
                end
            end
        end
    }
)

-- Auto enter Hollow Raid toggle (duplicate of Tomb Arena behavior)
RaidDefense:AddToggle(
    "AutoEnterHollowRaidToggle",
    {
        Text = "Auto Enter Hollow Raid",
        Default = config.AutoEnterHollowRaidToggle or false,
        Tooltip = "Automatically enters Hollow Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterHollowRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterHollowRaidConnection then autoEnterHollowRaidConnection:Disconnect() end
                autoEnterHollowRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")

                    if not (header and header.Visible and title and string.find(title.Text or "", "Hollow")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Hollow_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterHollowRaidConnection then
                    autoEnterHollowRaidConnection:Disconnect()
                    autoEnterHollowRaidConnection = nil
                end
            end
        end
    }
)

-- Auto enter Restaurant Raid toggle
RaidDefense:AddToggle(
    "AutoEnterDungeonAdventurerToggle",
    {
        Text = "Auto Enter Dungeon Adventurer",
        Default = config.AutoEnterDungeonAdventurerToggle or false,
        Tooltip = "Automatically enters Dungeon Adventurer Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterDungeonAdventurerEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterDungeonAdventurerConnection then autoEnterDungeonAdventurerConnection:Disconnect() end
                autoEnterDungeonAdventurerConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    -- Check if Dungeon Adventurer header is NOT visible or doesn't contain "Dungeon Adventurer"
                    if not (header and header.Visible and title and string.find(title.Text or "", "Dungeon Adventurer")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Dungeon_Adventurer"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3) -- Check every 3 seconds
                end)
            else
                if autoEnterDungeonAdventurerConnection then
                    autoEnterDungeonAdventurerConnection:Disconnect()
                    autoEnterDungeonAdventurerConnection = nil
                end
            end
        end
    }
)

-- Auto enter Restaurant Raid toggle
RaidDefense:AddToggle(
    "AutoEnterDungeonTormentToggle",
    {
        Text = "Auto Enter Dungeon Torment",
        Default = config.AutoEnterDungeonTormentToggle or false,
        Tooltip = "Automatically enters Dungeon Torment Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterDungeonTormentEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterDungeonTormentConnection then autoEnterDungeonTormentConnection:Disconnect() end
                autoEnterDungeonTormentConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")
                    
                    -- Check if Dungeon Torment header is NOT visible or doesn't contain "Dungeon Torment"
                    if not (header and header.Visible and title and string.find(title.Text or "", "Dungeon Torment")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Dungeon_Torment"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3) -- Check every 3 seconds
                end)
            else
                if autoEnterDungeonTormentConnection then
                    autoEnterDungeonTormentConnection:Disconnect()
                    autoEnterDungeonTormentConnection = nil
                end
            end
        end
    }
)

-- Auto enter Running Track Raid toggle
RaidDefense:AddToggle(
    "AutoEnterRunningTrackRaidToggle",
    {
        Text = "Auto Enter Running Track Raid",
        Default = config.AutoEnterRunningTrackRaidToggle or false,
        Tooltip = "Automatically enters Running Track Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterRunningTrackRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                    if autoEnterRunningTrackRaidConnection then
                        autoEnterRunningTrackRaidConnection:Disconnect()
                        autoEnterRunningTrackRaidConnection = nil
                    end

                    local RunService = game:GetService("RunService")
                    local lastAttempt = 0
                    local autoRunningTrackFarmActive = false
                    local prevFarmAllEnabled = nil

                    autoEnterRunningTrackRaidConnection = RunService.Heartbeat:Connect(function()
                        local now = tick()
                        local player = game:GetService("Players").LocalPlayer
                        local playerGui = player and player:FindFirstChild("PlayerGui")
                        local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                        local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                        local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")

                        -- If we're INSIDE the Running Track raid, ensure farming starts
                        if header and header.Visible and title and string.find(title.Text or "", "Running Track") then
                            if not autoRunningTrackFarmActive then
                                autoRunningTrackFarmActive = true
                                -- preserve user's previous farm-all state
                                prevFarmAllEnabled = farmAllEnemiesEnabled
                                farmAllEnemiesEnabled = true
                                -- start the shared FarmAll routine
                                pcall(function()
                                    startFarmAllEnemies()
                                end)
                            end
                        else
                            -- Not inside the raid: attempt to enter (debounced)
                            if now - lastAttempt >= 3 then
                                lastAttempt = now
                                local args = {
                                    [1] = {
                                        ["Action"] = "_Enter_Dungeon",
                                        ["Name"] = "Running_Track_Raid"
                                    }
                                }
                                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                                local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                                pcall(function()
                                    ToServer:FireServer(unpack(args))
                                end)
                            end

                            -- If we were farming for the Running Track and left, restore previous farm state
                            if autoRunningTrackFarmActive then
                                autoRunningTrackFarmActive = false
                                farmAllEnemiesEnabled = prevFarmAllEnabled or false
                                prevFarmAllEnabled = nil
                            end
                        end

                        task.wait(0.1)
                    end)
            else
                    if autoEnterRunningTrackRaidConnection then
                        autoEnterRunningTrackRaidConnection:Disconnect()
                        autoEnterRunningTrackRaidConnection = nil
                    end
                    -- If we were farming because of the running track, restore previous state
                    if autoRunningTrackFarmActive then
                        autoRunningTrackFarmActive = false
                        farmAllEnemiesEnabled = prevFarmAllEnabled or false
                        prevFarmAllEnabled = nil
                    end
            end
        end
    }
)
-- Teleport
local teleportLocations = {
    ["Dungeon Lobby 1"] = "Dungeon_Lobby_1",
    ["Earth City"] = "Earth_City",
    ["Windmill Island"] = "Windmill_Island",
    ["Soul Society"] = "Soul_Society",
    ["Cursed School"] = "Cursed_School",
    ["Slayer Village"] = "Slayer_Village",
    ["Solo Island"] = "Solo_Island",
    ["Clover Village"] = "Clover_Village",
    ["Leaf Village"] = "Leaf_Village",
    ["Spirit Residence"] = "Spirit_Residence",
    ["Magic Hunter City"] = "Magic_Hunter_City",
    ["Titan City"] = "Titan_City",
    ["Village of Sins"] = "Village_of_Sins",
    ["Kaiju Base"] = "Kaiju_Base",
    ["Tempest Capital"] = "Tempest_Capital",
    ["Virtual City"] = "Virtual_City",
    ["Cairo"] = "Cairo",
    ["Ghoul City"] = "Ghoul_City",
    ["Chainsaw City"] = "Chainsaw_City",
    ["Tokyo Empire"] = "Tokyo_Empire",
    ["Green Planet"] = "Green_Planet",
    ["Hollow World"] = "Hollow_World",
    ["Shadow Academy"] = "Shadow_Academy",
    ["Z City"] = "Z_City",
    ["Great Tomb"] = "Great_Tomb",
    ["Thriller Park"] = "Thriller_Park",
    ["Amusement Park"] = "Amusement_Park",
    ["Re:Manor"] = "Re:Manor",
    ["Asfordo Academy"] = "Asfordo_Academy"
}

TPGroupbox:AddDropdown(
    "MainTeleportDropdown",
    {
        Values = {
            "Dungeon Lobby 1",
            "Earth City",
            "Windmill Island",
            "Soul Society",
            "Cursed School",
            "Slayer Village",
            "Solo Island",
            "Clover Village",
            "Leaf Village",
            "Spirit Residence",
            "Magic Hunter City",
            "Titan City",
            "Village of Sins",
            "Kaiju Base",
            "Tempest Capital",
            "Virtual City",
            "Cairo",
            "Ghoul City",
            "Chainsaw City",
            "Tokyo Empire",
            "Green Planet",
            "Hollow World",
            "Shadow Academy",
            "Z City",
            "Great Tomb",
            "Thriller Park",
            "Amusement Park",
            "Re:Manor",
            "Asfordo_Academy"
        },
        Default = config.MainTeleportDropdown or "Earth City",
        Multi = false,
        Text = "Teleport To",
        Tooltip = "Teleport to the selected location.",
        Callback = function(selected)
            local locationKey = teleportLocations[selected]
            if locationKey then
                local args = {
                    [1] = {
                        ["Location"] = locationKey,
                        ["Type"] = "Map",
                        ["Action"] = "Teleport"
                    }
                }
                pcall(
                    function()
                        ToServer:FireServer(unpack(args))
                    end
                )
            end
            -- SaveManager automatically saves this dropdown's value
        end
    }
)

-- Auto Leave Wave System - Event-driven approach
local LeaveWave = config.LeaveWave or 500
local autoLeaveConnection = nil
local headerWatcher = nil
local currentWaveLabel = nil

local function disconnectAutoLeave()
    if autoLeaveConnection then
        autoLeaveConnection:Disconnect()
        autoLeaveConnection = nil
    end
end

local function connectToWaveLabel(waveLabel)
    if not waveLabel or not waveLabel:IsA("TextLabel") then
        return false
    end
    
    disconnectAutoLeave()
    currentWaveLabel = waveLabel
    
    local function checkWave()
        if not autoLeaveWaveEnabled then return end
        
        local currentWave = tonumber(string.match(waveLabel.Text or "", "%d+"))
        if currentWave then
            if currentWave >= LeaveWave then
                task.spawn(function()
                    pcall(function()
                        local args = { [1] = { ["Action"] = "Dungeon_Leave" } }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end)
                end)
            end
        end
    end
    
    -- Check immediately
    checkWave()
    
    -- Connect to text changes
    autoLeaveConnection = waveLabel:GetPropertyChangedSignal("Text"):Connect(checkWave)
    return true
end

local function findAndConnectWaveLabel()
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player and player:FindFirstChild("PlayerGui")
    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header", true)
    
    if header then
        -- Try to find Wave label
        local waveLabel = header:FindFirstChild("Wave", true)
        if not (waveLabel and waveLabel:IsA("TextLabel")) then
            -- Search through all descendants for a TextLabel
            for _, descendant in ipairs(header:GetDescendants()) do
                if descendant:IsA("TextLabel") and descendant.Name:lower():find("wave") then
                    waveLabel = descendant
                    break
                end
            end
            -- If still not found, try any TextLabel that might contain wave info
            if not waveLabel then
                for _, descendant in ipairs(header:GetDescendants()) do
                    if descendant:IsA("TextLabel") and string.match(descendant.Text or "", "%d+") then
                        waveLabel = descendant
                        break
                    end
                end
            end
        end
        
        if waveLabel and connectToWaveLabel(waveLabel) then
            return true
        end
    end
    return false
end

local function startHeaderWatcher()
    if headerWatcher then return end
    
    headerWatcher = task.spawn(function()
        local lastHeaderInstance = nil
        
        while autoLeaveWaveEnabled do
            local player = game:GetService("Players").LocalPlayer
            local playerGui = player and player:FindFirstChild("PlayerGui")
            local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
            local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header", true)
            
            -- Check if header instance changed (new dungeon session)
            if header ~= lastHeaderInstance then
                lastHeaderInstance = header
                disconnectAutoLeave() -- Clear old connection
                
                if header then
                    task.wait(0.5) -- Give UI time to load
                    findAndConnectWaveLabel()
                else
                end
            end
            
            -- If we have a header but no connection, try to reconnect
            if header and not autoLeaveConnection then
                findAndConnectWaveLabel()
            end
            
            task.wait(1)
        end
        
        headerWatcher = nil
        disconnectAutoLeave()
    end)
end

local function stopHeaderWatcher()
    if headerWatcher then
        headerWatcher = nil -- Will cause the loop to exit
    end
    disconnectAutoLeave()
end

-- Toggle UI
AdjustDungeon:AddToggle("AutoLeaveWaveToggle", {
    Text = "Enable Auto Leave on Wave",
    Default = config.AutoLeaveWaveToggle or false,
    Tooltip = "Automatically leave dungeon at selected wave.",
    Callback = function(Value)
        autoLeaveWaveEnabled = Value
        -- SaveManager automatically saves this toggle's value
        if Value then
            startHeaderWatcher()
        else
            stopHeaderWatcher()
        end
    end
})

-- Dropdown UI
AdjustDungeon:AddDropdown("WaveDropdown", {
    Title = "Leave at Wave",
    Values = {"10", "20", "30", "50", "80", "100", "200", "300", "500", "800", "1000", "1100", "1200", "1300", "1400", "1500", "1600", "1700", "1800", "1900", "2000"},
    Multi = false,
    Default = tostring(config.LeaveWave or 500),
    Callback = function(Value)
        LeaveWave = tonumber(Value)
        -- SaveManager automatically saves this dropdown's value
    end
})

-- Auto Leave Room System - Similar to wave system but for rooms
local LeaveRoom = config.LeaveRoom or 50
local autoLeaveRoomConnection = nil
local roomHeaderWatcher = nil
local currentRoomLabel = nil

local function disconnectAutoLeaveRoom()
    if autoLeaveRoomConnection then
        autoLeaveRoomConnection:Disconnect()
        autoLeaveRoomConnection = nil
    end
end

local function connectToRoomLabel(roomLabel)
    if not roomLabel or not roomLabel:IsA("TextLabel") then
        return false
    end
    
    disconnectAutoLeaveRoom()
    currentRoomLabel = roomLabel
    
    local function checkRoom()
        if not autoLeaveRoomEnabled then return end
        
        -- Extract room number from "Room Cleared: 7" format
        local currentRoom = tonumber(string.match(roomLabel.Text or "", "Room Cleared:%s*(%d+)"))
        if currentRoom then
            if currentRoom >= LeaveRoom then
                task.spawn(function()
                    pcall(function()
                        local args = { [1] = { ["Action"] = "Dungeon_Leave" } }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end)
                end)
            end
        end
    end
    
    -- Check immediately
    checkRoom()
    
    -- Connect to text changes
    autoLeaveRoomConnection = roomLabel:GetPropertyChangedSignal("Text"):Connect(checkRoom)
    return true
end

local function findAndConnectRoomLabel()
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player and player:FindFirstChild("PlayerGui")
    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
    
    if header then
        -- Use the exact path you provided: Default_Header.Main.Main.Room
        local roomLabel = header:FindFirstChild("Main") and 
                         header.Main:FindFirstChild("Main") and 
                         header.Main.Main:FindFirstChild("Room")
        
        if roomLabel and roomLabel:IsA("TextLabel") then
            if connectToRoomLabel(roomLabel) then
                return true
            end
        else
            -- Fallback: Search through all descendants for a TextLabel containing "Room Cleared"
                for _, descendant in ipairs(header:GetDescendants()) do
                    if descendant:IsA("TextLabel") and string.match(descendant.Text or "", "Room Cleared") then
                        roomLabel = descendant
                        if connectToRoomLabel(roomLabel) then
                            return true
                        end
                    end
                end
        end
    else
        -- header not found
    end
    return false
end

local function startRoomHeaderWatcher()
    if roomHeaderWatcher then return end
    
    roomHeaderWatcher = task.spawn(function()
        local lastHeaderInstance = nil
        
        while autoLeaveRoomEnabled do
            local player = game:GetService("Players").LocalPlayer
            local playerGui = player and player:FindFirstChild("PlayerGui")
            local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
            local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header", true)
            
            -- Check if header instance changed (new dungeon session)
            if header ~= lastHeaderInstance then
                lastHeaderInstance = header
                disconnectAutoLeaveRoom() -- Clear old connection
                
                if header then
                    task.wait(0.5) -- Give UI time to load
                    findAndConnectRoomLabel()
                end
            end
            
            -- If we have a header but no connection, try to reconnect
            if header and not autoLeaveRoomConnection then
                findAndConnectRoomLabel()
            end
            
            task.wait(1)
        end
        
        roomHeaderWatcher = nil
        disconnectAutoLeaveRoom()
    end)
end

local function stopRoomHeaderWatcher()
    if roomHeaderWatcher then
        roomHeaderWatcher = nil -- Will cause the loop to exit
    end
    disconnectAutoLeaveRoom()
end

-- Room Toggle UI
AdjustDungeon:AddToggle("AutoLeaveRoomToggle", {
    Text = "Enable Auto Leave on Room",
    Default = config.AutoLeaveRoomToggle or false,
    Tooltip = "Automatically leave dungeon at selected room count.",
    Callback = function(Value)
        autoLeaveRoomEnabled = Value
        -- SaveManager automatically saves this toggle's value
        if Value then
            startRoomHeaderWatcher()
        else
            stopRoomHeaderWatcher()
        end
    end
})

-- Room Dropdown UI
AdjustDungeon:AddDropdown("RoomDropdown", {
    Title = "Leave at Room",
    Values = {"5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "60", "70", "80", "90", "100"},
    Multi = false,
    Default = tostring(config.LeaveRoom or 50),
    Callback = function(Value)
        LeaveRoom = tonumber(Value)
        -- SaveManager automatically saves this dropdown's value
    end
})

----========================================== Tab: Upgrades - Sin, Shadow Upgrades ==========================================---


-- Sin Upgrade toggles (replaces dropdown)
SinUp:AddToggle("AutoEnergyUpgradeToggle", {
    Text = "Auto Energy Upgrade",
    Default = config.AutoEnergyUpgradeToggle or false,
    Tooltip = "Automatically upgrades Energy.",
    Callback = function(Value)
        autoEnergyUpgradeEnabled = Value
        if Value then
            task.spawn(function()
                while autoEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Energy",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Sin_Upgrades"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(0.25)
                end
            end)
        end
        -- SaveManager automatically saves this toggle's value
    end
})

SinUp:AddToggle("AutoCoinsUpgradeToggle", {
    Text = "Auto Coins Upgrade",
    Default = config.AutoCoinsUpgradeToggle or false,
    Tooltip = "Automatically upgrades Coins.",
    Callback = function(Value)
        autoCoinsUpgradeEnabled = Value
        if Value then
            task.spawn(function()
                while autoCoinsUpgradeEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Coins",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Sin_Upgrades"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(0.25)
                end
            end)
        end
        -- SaveManager automatically saves this toggle's value
    end
})

SinUp:AddToggle("AutoStarLuckUpgradeToggle", {
    Text = "Auto Star Luck Upgrade",
    Default = config.AutoStarLuckUpgradeToggle or false,
    Tooltip = "Automatically upgrades Star Luck.",
    Callback = function(Value)
        autoStarLuckUpgradeEnabled = Value
        if Value then
            task.spawn(function()
                while autoStarLuckUpgradeEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Star_Luck",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Sin_Upgrades"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(0.25)
                end
            end)
        end
        -- SaveManager automatically saves this toggle's value
    end
})


-- Shadow Upgrade toggles (replaces dropdown)
ShadowUp:AddToggle("AutoShadowSoulUpgradeToggle", {
    Text = "Auto Shadow Soul Upgrade",
    Default = config.AutoShadowSoulUpgradeToggle or false,
    Tooltip = "Automatically upgrades Shadow Soul.",
    Callback = function(Value)
        autoShadowSoulUpgradeEnabled = Value
        if Value then
            task.spawn(function()
                while autoShadowSoulUpgradeEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Shadow_Soul",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Shadow_Upgrades"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(0.25)
                end
            end)
        end
        -- SaveManager automatically saves this toggle's value
    end
})

ShadowUp:AddToggle("AutoShadowExtraEquipUpgradeToggle", {
    Text = "Auto Shadow Extra Equip Upgrade",
    Default = config.AutoShadowExtraEquipUpgradeToggle or false,
    Tooltip = "Automatically upgrades Shadow Extra Equip.",
    Callback = function(Value)
        autoShadowExtraEquipUpgradeEnabled = Value
        if Value then
            task.spawn(function()
                while autoShadowExtraEquipUpgradeEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Shadow_Extra_Equip",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Shadow_Upgrades"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(0.25)
                end
            end)
        end
        -- SaveManager automatically saves this toggle's value
    end
})

ShadowUp:AddToggle("AutoShadowsInventorySlotsUpgradeToggle", {
    Text = "Auto Shadows Inventory Slots Upgrade",
    Default = config.AutoShadowsInventorySlotsUpgradeToggle or false,
    Tooltip = "Automatically upgrades Shadows Inventory Slots.",
    Callback = function(Value)
        autoShadowsInventorySlotsUpgradeEnabled = Value
        if Value then
            task.spawn(function()
                while autoShadowsInventorySlotsUpgradeEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Shadows_Inventory_Slots",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Shadow_Upgrades"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(0.25)
                end
            end)
        end
        -- SaveManager automatically saves this toggle's value
    end
})

ShadowUp:AddToggle("AutoX2ShadowSoulUpgradeToggle", {
    Text = "Auto x2 Shadow Soul Upgrade",
    Default = config.AutoX2ShadowSoulUpgradeToggle or false,
    Tooltip = "Automatically upgrades x2 Shadow Soul.",
    Callback = function(Value)
        autoX2ShadowSoulUpgradeEnabled = Value
        if Value then
            task.spawn(function()
                while autoX2ShadowSoulUpgradeEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "x2_Shadow_Soul",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Shadow_Upgrades"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(0.25)
                end
            end)
        end
        -- SaveManager automatically saves this toggle's value
    end
})


-- Auto Upgrade Feature
UpgradeGroupbox:AddToggle(
    "AutoUpgradeToggle",
    {
        Text = "Upgrade",
        Default = config.AutoUpgradeToggle or false,
        Tooltip = "Automatically upgrades your character's stats.",
        Callback = function(Value)
            autoUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    while autoUpgradeEnabled and getgenv().SeisenHubRunning do
                        pcall(function()
                            for upgradeName, isEnabled in pairs(enabledUpgrades) do
                                if isEnabled then
                                    local args = {
                                        [1] = {
                                            ["Upgrading_Name"] = upgradeName,
                                            ["Action"] = "_Upgrades",
                                            ["Upgrade_Name"] = "Upgrades"
                                        }
                                    }
                                    ToServer:FireServer(unpack(args))
                                end
                            end
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

local upgradeOptions = {
    "Star_Luck",
    "Damage",
    "Energy",
    "Coins",
    "Drops",
    "Avatar_Souls_Drop",
    "Movement_Speed",
    "Fast_Roll",
    "Star_Speed",
    "Energy_Critical_Chance",
    "Critical_Energy",
    "Exp"
}

-- Working upgrade toggles: add individual toggles for each upgrade option
enabledUpgrades = enabledUpgrades or {}
for _, upgradeName in ipairs(upgradeOptions) do
    UpgradeGroupbox:AddToggle(
        upgradeName .. "_Toggle",
        {
            Text = upgradeName:gsub("_", " "),
            Default = config[upgradeName .. "_Toggle"] or false,
            Tooltip = "Enable or disable auto upgrade for " .. upgradeName:gsub("_", " ") .. ".",
            Callback = function(Value)
                enabledUpgrades[upgradeName] = Value
            end
        }
    )
    enabledUpgrades[upgradeName] = config[upgradeName .. "_Toggle"] or false
end
-- Auto Running Track Upgrade Toggle
Upgrade2:AddToggle(
    "AutoRunningTrackUpgradeToggle",
    {
        Text = "Running Track Upgrade",
        Default = config.AutoRunningTrackUpgradeToggle or false,
        Tooltip = "Automatically upgrades Running Track.",
        Callback = function(Value)
            autoRunningTrackUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    while autoRunningTrackUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Running_Track_Progression";
                            };
                        }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Auto Obelisk Upgrade Toggle
Upgrade2:AddToggle(
    "AutoObeliskUpgradeToggle",
    {
        Text = "Obelisk Energy Upgrade",
        Default = config.AutoObeliskUpgradeToggle or false,
        Tooltip = "Automatically upgrades Energy Obelisk.",
        Callback = function(Value)
            autoObeliskUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    while autoObeliskUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy",
                                ["Action"] = "_Progression",
                                ["Bench_Name"] = "Energy_Obelisk",
                            }
                        }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Auto Obelisk Damage Upgrade Toggle
Upgrade2:AddToggle(
    "AutoObeliskDamageUpgradeToggle",
    {
        Text = "Obelisk Damage Upgrade",
        Default = config.AutoObeliskDamageUpgradeToggle or false,
        Tooltip = "Automatically upgrades Damage Obelisk.",
        Callback = function(Value)
            autoObeliskDamageUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    while autoObeliskDamageUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Damage",
                                ["Action"] = "_Progression",
                                ["Bench_Name"] = "Damage_Obelisk",
                            }
                        }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Auto Obelisk Damage Upgrade Toggle
Upgrade2:AddToggle(
    "AutoObeliskLuckUpgradeToggle",
    {
        Text = "Obelisk Luck Upgrade",
        Default = config.AutoObeliskLuckUpgradeToggle or false,
        Tooltip = "Automatically upgrades Damage Obelisk.",
        Callback = function(Value)
            autoObeliskLuckUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    while autoObeliskLuckUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Luck",
                                ["Action"] = "_Progression",
                                ["Bench_Name"] = "Luck_Obelisk",
                            }
                        }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoAttackRange2UpgradeToggle",
    {
        Text = "Attack Range 2 Upgrade",
        Default = config.AutoAttackRange2UpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Attack Range 2.",
        Callback = function(Value)
            autoAttackRange2UpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    -- First, unlock Attack Range 2
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Attack_Range_2_Unlock"
                        }
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(unlockArgs))
                    end)
                    -- Then, repeatedly upgrade Attack Range 2
                    while autoAttackRange2UpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Attack_Range",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Attack_Range_2"
                            }
                        }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(upgradeArgs))
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoAttackRangeUpgradeToggle",
    {
        Text = "Attack Range Upgrade",
        Default = config.AutoAttackRangeUpgradeToggle or false,
        Tooltip = "Automatically upgrades attack range.",
        Callback = function(Value)
            autoAttackRangeUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Attack_Range_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoAttackRangeUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Attack_Range",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Attack_Range"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoHakiUpgradeToggle",
    {
        Text = "Haki Upgrade",
        Default = config.AutoHakiUpgradeToggle or false,
        Tooltip = "Automatically upgrades Haki.",
        Callback = function(Value)
            autoHakiUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Haki_Upgrade_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoHakiUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Haki_Upgrade",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Haki_Upgrade"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoSpiritualPressureUpgradeToggle",
    {
        Text = "Spiritual Pressure Upgrade",
        Default = config.AutoSpiritualPressureUpgradeToggle or false,
        Tooltip = "Automatically upgrades spiritual pressure.",
        Callback = function(Value)
            autoSpiritualPressureUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Spiritual_Pressure_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoSpiritualPressureUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Spiritual_Pressure",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Spiritual_Pressure"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoCursedProgressionUpgradeToggle",
    {
        Text = "Cursed Progression Upgrade",
        Default = config.AutoCursedProgressionUpgradeToggle or false,
        Tooltip = "Automatically upgrades cursed progression.",
        Callback = function(Value)
            autoCursedProgressionUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Cursed_Progression_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoCursedProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Curse",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Cursed_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoReawakeningProgressionUpgradeToggle",
    {
        Text = "Reawakening Progression Upgrade",
        Default = config.AutoReawakeningProgressionUpgradeToggle or false,
        Tooltip = "Automatically upgrades reawakening progression.",
        Callback = function(Value)
            autoReawakeningProgressionUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "ReAwakening_Progression_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoReawakeningProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "ReAwakening",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "ReAwakening_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoMonarchProgressionUpgradeToggle",
    {
        Text = "Monarch Progression Upgrade",
        Default = config.AutoMonarchProgressionUpgradeToggle or false,
        Tooltip = "Automatically upgrades monarch progression.",
        Callback = function(Value)
            autoMonarchProgressionUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Monarch_Progression_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoMonarchProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Monarch",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Monarch_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoWaterSpiritProgressionUpgradeToggle",
    {
        Text = "Water Spirit Progression Upgrade",
        Default = config.AutoWaterSpiritProgressionUpgradeToggle or false,
        Tooltip = "Automatically upgrades water spirit progression.",
        Callback = function(Value)
            autoWaterSpiritProgressionUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Water_Spirit_Progression_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoWaterSpiritProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Water_Spirit",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Water_Spirit_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoWindSpiritProgressionUpgradeToggle",
    {
        Text = "Wind Spirit Progression Upgrade",
        Default = config.AutoWindSpiritProgressionUpgradeToggle or false,
        Tooltip = "Automatically upgrades wind spirit progression.",
        Callback = function(Value)
            autoWindSpiritProgressionUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Wind_Spirit_Progression_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoWindSpiritProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Wind_Spirit",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Wind_Spirit_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoFireSpiritProgressionUpgradeToggle",
    {
        Text = "Fire Spirit Progression Upgrade",
        Default = config.AutoFireSpiritProgressionUpgradeToggle or false,
        Tooltip = "Automatically upgrades fire spirit progression.",
        Callback = function(Value)
            autoFireSpiritProgressionUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Fire_Spirit_Progression_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoFireSpiritProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Fire_Spirit",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Fire_Spirit_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoChakraProgressionUpgradeToggle",
    {
        Text = "Chakra Progression Upgrade",
        Default = config.AutoChakraProgressionUpgradeToggle or false,
        Tooltip = "Automatically upgrades chakra progression.",
        Callback = function(Value)
            autoChakraProgressionUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Chakra_Progression_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoChakraProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Chakra",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Chakra_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoSpiritualUpgradeToggle",
    {
        Text = "Spiritual Upgrade",
        Default = config.AutoSpiritualUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades spiritual upgrade.",
        Callback = function(Value)
            autoSpiritualUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Spiritual_Upgrade_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoSpiritualUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Spiritual_Upgrade",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Spiritual_Upgrade"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoLuckySpiritUpgradeToggle",
    {
        Text = "Lucky Spirit Upgrade",
        Default = config.AutoLuckySpiritUpgradeToggle or false,
        Tooltip = "Automatically upgrades Lucky Spirit.",
        Callback = function(Value)
            autoLuckySpiritUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Lucky_Spirit_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoLuckySpiritUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Luck",
                                ["Action"] = "_Progression",
                                ["Bench_Name"] = "Lucky_Spirit"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoTenProgressionUpgradeToggle",
    {
        Text = "Ten Progression Upgrade",
        Default = config.AutoTenProgressionUpgradeToggle or false,
        Tooltip = "Automatically upgrades Ten Progression.",
        Callback = function(Value)
            autoTenProgressionUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Ten_Progression_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoTenProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Ten",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Ten_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)


Upgrade2:AddToggle(
    "AutoContractOfGreedUpgradeToggle",
    {
        Text = "Contract of Greed Upgrade",
        Default = config.AutoContractOfGreedUpgradeToggle or false,
        Tooltip = "Automatically upgrades Contract of Greed.",
        Callback = function(Value)
            autoContractOfGreedUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Contract_of_Greed_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoContractOfGreedUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Coins",
                                ["Action"] = "_Progression",
                                ["Bench_Name"] = "Contract_of_Greed"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoEnergyProgressionUpgradeToggle",
    {
        Text = "Energy Progression Upgrade",
        Default = config.AutoEnergyProgressionUpgradeToggle or false,
        Tooltip = "Automatically upgrades Energy Progression.",
        Callback = function(Value)
            autoEnergyProgressionUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Progression",
                            ["Upgrade_Name"] = "Energy_Progression_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoEnergyProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Strenght",
                                ["Action"] = "_Progression",
                                ["Bench_Name"] = "Energy_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)


Upgrade2:AddToggle(
    "AutoFortitudeLevelUpgradeToggle",
    {
        Text = "Fortitude Level Progression Upgrade",
        Default = config.AutoFortitudeLevelUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Fortitude Level progression.",
        Callback = function(Value)
            autoFortitudeLevelUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Fortitude_Level_Unlock",
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoFortitudeLevelUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Strenght",
                                ["Action"] = "_Progression",
                                ["Bench_Name"] = "Fortitude_Level",
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoKaijuEnergyUpgradeToggle",
    {
        Text = "Kaiju Energy Progression Upgrade",
        Default = config.AutoKaijuEnergyUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Kaiju Energy progression.",
        Callback = function(Value)
            autoKaijuEnergyUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Kaiju_Energy_Unlock",
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoKaijuEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy",
                                ["Action"] = "_Progression",
                                ["Bench_Name"] = "Kaiju_Energy",
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)


Upgrade2:AddToggle(
    "AutoDemonLordDamageUpgradeToggle",
    {
        Text = "Demon Lord Damage Upgrade",
        Default = config.AutoDemonLordDamageUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Demon Lord Damage progression.",
        Callback = function(Value)
            autoDemonLordDamageUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Demon_Lord_Damage_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoDemonLordDamageUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Damage";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Demon_Lord_Damage";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoDemonLordEnergyUpgradeToggle",
    {
        Text = "Demon Lord Energy Upgrade",
        Default = config.AutoDemonLordEnergyUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Demon Lord Energy progression.",
        Callback = function(Value)
            autoDemonLordEnergyUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Demon_Lord_Energy_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoDemonLordEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Demon_Lord_Energy";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoDemonLordLuckUpgradeToggle",
    {
        Text = "Demon Lord Luck Upgrade",
        Default = config.AutoDemonLordLuckUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Demon Lord Luck progression.",
        Callback = function(Value)
            autoDemonLordLuckUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Demon_Lord_Luck_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoDemonLordLuckUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Luck";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Demon_Lord_Luck";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoDemonLordCoinsUpgradeToggle",
    {
        Text = "Demon Lord Coins Upgrade",
        Default = config.AutoDemonLordCoinsUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Demon Lord Coins progression.",
        Callback = function(Value)
            autoDemonLordCoinsUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Demon_Lord_Coins_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoDemonLordCoinsUpgradeEnabled and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Coins";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Demon_Lord_Coins";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Swordsman Damage Upgrade
Upgrade2:AddToggle(
    "AutoSwordsmanDamageUpgradeToggle",
    {
        Text = "Swordsman Damage Upgrade",
        Default = config.AutoSwordsmanDamageUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Swordsman Damage progression.",
        Callback = function(Value)
            autoSwordsmanDamageUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Swordsman_Damage_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoSwordsmanDamageUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Damage";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Swordsman_Damage";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Swordsman Energy Upgrade
Upgrade2:AddToggle(
    "AutoSwordsmanEnergyUpgradeToggle",
    {
        Text = "Swordsman Energy Upgrade",
        Default = config.AutoSwordsmanEnergyUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Swordsman Energy progression.",
        Callback = function(Value)
            autoSwordsmanEnergyUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Swordsman_Energy_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoSwordsmanEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Swordsman_Energy";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Eminence Energy Upgrade
Upgrade2:AddToggle(
    "AutoRippleEnergyUpgradeToggle",
    {
        Text = "Ripple Energy Upgrade",
        Default = config.AutoRippleEnergyUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Ripple Energy progression.",
        Callback = function(Value)
            autoRippleEnergyUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Ripple_Energy_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoRippleEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Ripple_Energy";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Eminence Energy Upgrade
Upgrade2:AddToggle(
    "AutoDamageCellsUpgradeToggle",
    {
        Text = "Damage Cells Upgrade",
        Default = config.AutoDamageCellsUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Damage Cells progression.",
        Callback = function(Value)
            autoInvestigatorsEnergyUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Damage_Cells_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoInvestigatorsEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Damage";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Damage_Cells";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)


-- Eminence Energy Upgrade
Upgrade2:AddToggle(
    "AutoAkumaDamageUpgradeToggle",
    {
        Text = "Akuma Damage Upgrade",
        Default = config.AutoAkumaDamageUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Akuma Damage progression.",
        Callback = function(Value)
            autoAkumaDamageUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Akuma_Damage_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoAkumaDamageUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Damage";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Akuma_Damage";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoAkumaEnergyUpgradeToggle",
    {
        Text = "Akuma Energy Upgrade",
        Default = config.AutoAkuma_EnergyUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Akuma Energy progression.",
        Callback = function(Value)
            autoAkumaEnergyUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Akuma_Energy_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoAkumaEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Akuma_Energy";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoPyrokineticsUpgradeToggle",
    {
        Text = "Pyrokinetics Upgrade",
        Default = config.AutoPyrokineticsUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Pyrokinetics progression.",
        Callback = function(Value)
            autoPyrokineticsUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Pyrokinetics_Evolve_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoPyrokineticsUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Pyro";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Pyrokinetics_Evolve";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoAdollaBlessingUpgradeToggle",
    {
        Text = "Adolla Blessing Upgrade",
        Default = config.AutoAdollaBlessingUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Adolla Blessing progression.",
        Callback = function(Value)
            autoAdollaBlessingUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Adolla_Blessing_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoAdollaBlessingUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Adolla";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Adolla_Blessing";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoDragonEnergyUpgradeToggle",
    {
        Text = "Dragon Energy Upgrade",
        Default = config.AutoDragonEnergyUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Dragon Energy progression.",
        Callback = function(Value)
            autoDragonEnergyUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Dragon_Energy_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoDragonEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Dragon_Energy";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoDragonDamageUpgradeToggle",
    {
        Text = "Dragon Damage Upgrade",
        Default = config.AutoDragonDamageUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Dragon Damage progression.",
        Callback = function(Value)
            autoDragonDamageUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Dragon_Damage_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoDragonDamageUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Damage";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Dragon_Damage";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Eminence Energy Upgrade
Upgrade2:AddToggle(
    "AutoEminenceEnergyUpgradeToggle",
    {
        Text = "Eminence Energy Upgrade",
        Default = config.AutoEminenceEnergyUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Eminence Energy progression.",
        Callback = function(Value)
            autoEminenceEnergyUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Eminence_Energy_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoEminenceEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Eminence_Energy";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)


-- Eminence Damage Upgrade
Upgrade2:AddToggle(
    "AutoEminenceDamageUpgradeToggle",
    {
        Text = "Eminence Damage Upgrade",
        Default = config.AutoEminenceDamageUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Eminence Damage progression.",
        Callback = function(Value)
            autoEminenceDamageUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Eminence_Damage_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoEminenceDamageUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Damage";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Eminence_Damage";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Eminence Luck Upgrade
Upgrade2:AddToggle(
    "AutoEminenceLuckUpgradeToggle",
    {
        Text = "Eminence Luck Upgrade",
        Default = config.AutoEminenceLuckUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Eminence Luck progression.",
        Callback = function(Value)
            autoEminenceLuckUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Eminence_Luck_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoEminenceLuckUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Luck";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Eminence_Luck";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoEminenceCoinsUpgradeToggle",
    {
        Text = "Eminence Coins Upgrade",
        Default = config.AutoEminenceCoinsUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Eminence Coins progression.",
        Callback = function(Value)
            autoEminenceCoinsUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Eminence_Coins_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoEminenceCoinsUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Coins";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Eminence_Coins";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)


-- Mana Growth Upgrade
Upgrade2:AddToggle(
    "AutoManaGrowthUpgradeToggle",
    {
        Text = "Mana Growth Upgrade",
        Default = config.AutoManaGrowthUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Mana Growth progression.",
        Callback = function(Value)
            autoManaGrowthUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Mana_Growth_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoManaGrowthUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Mana_Growth";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Ultimate Cast Upgrade
Upgrade2:AddToggle(
    "AutoUltimateCastUpgradeToggle",
    {
        Text = "Ultimate Cast Upgrade",
        Default = config.AutoUltimateCastUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Ultimate Cast progression.",
        Callback = function(Value)
            autoUltimateCastUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Ultimate_Cast_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoUltimateCastUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Luck";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Ultimate_Cast";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoAssassinEnergyUpgradeToggle",
    {
        Text = "Assassin Energy Upgrade",
        Default = config.AutoAssassinEnergyUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Assassin Energy progression.",
        Callback = function(Value)
            autoAssassinEnergyUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Assassin_Energy_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoAssassinEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Assassin_Energy";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoAssassinDamageUpgradeToggle",
    {
        Text = "Assassin Damage Upgrade",
        Default = config.AutoAssassinDamageUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Assassin Damage progression.",
        Callback = function(Value)
            autoAssassinDamageUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Assassin_Damage_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoAssassinDamageUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Damage";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Assassin_Damage";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoAssassinCriticalEnergyUpgradeToggle",
    {
        Text = "Assassin Critical Energy Upgrade",
        Default = config.AutoAssassinCriticalEnergyUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Assassin Critical Energy progression.",
        Callback = function(Value)
            autoAssassinCriticalEnergyUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Assassin_Critical_Energy_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoAssassinCriticalEnergyUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Critical_Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Assassin_Critical_Energy";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

Upgrade2:AddToggle(
    "AutoAssassinCriticalDamageUpgradeToggle",
    {
        Text = "Assassin Critical Damage Upgrade",
        Default = config.AutoAssassinCriticalDamageUpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Assassin Critical Damage progression.",
        Callback = function(Value)
            autoAssassinCriticalDamageUpgradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Assassin_Critical_Damage_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    while autoAssassinCriticalDamageUpgradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Critical_Damage";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Assassin_Critical_Damage";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)
---========================================== Tab: Auto Rolls ==========================================---

-- Dropdown to choose which Star to roll (Star_1 .. Star_25)
-- Dropdown to choose which Star to roll (friendly display -> internal Star_# mapping)
do
    -- Exact ordered friendly names mapping to Star_1 .. Star_25
    local starFriendlyNames = {
        "Earth City",
        "Windmill Island",
        "Soul Society",
        "Cursed School",
        "Slayer Village",
        "Solo Island",
        "Clover Village",
        "Leaf Village",
        "Spirit Residence",
        "Magic Hunter City",
        "Titan City",
        "Village of Sins",
        "Kaiju Base",
        "Tempest Capital",
        "Virtual City",
        "Cairo",
        "Ghoul City",
        "Chainsaw City",
        "Tokyo Empire",
        "Green Planet",
        "Hollow World",
        "Shadow Academy",
        "Z City",
        "Great Tomb",
        "Thriller Park",
        "Amusement Park",
        "Re:Manor",
        "Asfordo Academy"
    }

    local starDisplayMap = {}
    local displayList = {}
    for i, name in ipairs(starFriendlyNames) do
        starDisplayMap[name] = "Star_" .. i
        table.insert(displayList, name)
    end

    local function findDisplayForInternal(internal)
        for d, v in pairs(starDisplayMap) do
            if v == internal then return d end
        end
        return nil
    end

    local defaultInternal = config.AutoRollStarsDropdown or selectedStar or "Star_1"
    local defaultDisplay = nil
    if type(defaultInternal) == "string" then
        if starDisplayMap[defaultInternal] then
            defaultDisplay = defaultInternal
        else
            defaultDisplay = findDisplayForInternal(defaultInternal) or displayList[1]
        end
    end

    RollGroupbox:AddDropdown(
        "AutoRollStarsDropdown",
        {
            Title = "Star To Roll",
            Values = displayList,
            Multi = false,
            Default = defaultDisplay or displayList[1],
            Callback = function(Value)
                local mapped = starDisplayMap[Value]
                if mapped then
                    selectedStar = mapped
                else
                    selectedStar = Value
                end
            end
        }
    )
end

selectedStar = selectedStar or "Star_1"
delayBetweenRolls = delayBetweenRolls or 2 -- safer default

RollGroupbox:AddToggle(
    "AutoRollStarsToggle",
    {
        Text = "Stars",
        Default = config.AutoRollStarsToggle or false,
        Tooltip = "Automatically rolls for stars.",
        Callback = function(Value)
            autoRollEnabled = Value
            if autoRollThread then
                autoRollEnabled = false
                autoRollThread = nil
            end
            if Value then
                autoRollThread = task.spawn(function()
                    while getgenv().SeisenHubRunning and autoRollEnabled do
                        pcall(function()
                            if not selectedStar then
                                warn("selectedStar is nil! Defaulting to Star_1")
                                selectedStar = "Star_1"
                            end
                            print("Rolling for star:", selectedStar)
                            local cacheArgs = {
                                [1] = {
                                    ["Action"] = "Star_Cache_Request",
                                    ["Name"] = selectedStar
                                }
                            }
                            ToServer:FireServer(unpack(cacheArgs))
                            local args = {
                                [1] = {
                                    ["Open_Amount"] = 20,
                                    ["Action"] = "_Stars",
                                    ["Name"] = selectedStar
                                }
                            }
                            ToServer:FireServer(unpack(args))
                        end)
                        task.wait(delayBetweenRolls or 2)
                    end
                end)
            end
        end
    }
)


-- Auto Delete Toggle
AutoDeleteGroupbox:AddToggle(
    "AutoDeleteUnitsToggle",
    {
        Text = "Auto Delete Units",
        Default = config.AutoDeleteUnitsToggle or false,
        Callback = function(Value)
            autoDeleteEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                task.spawn(function()
                    while autoDeleteEnabled and getgenv().SeisenHubRunning do
                        pcall(function()
                            local starRarityMap = {
                                    ["Star_1"] = {
                                        ["1"] = {"70001"},
                                        ["2"] = {"70002"},
                                        ["3"] = {"70003"},
                                        ["4"] = {"70004"},
                                        ["5"] = {"70005"},
                                        ["6"] = {"70006"},
                                        ["7"] = {"70007"},
                                    },
                                    ["Star_2"] = {
                                        ["1"] = {"70008"},
                                        ["2"] = {"70009"},
                                        ["3"] = {"70010"},
                                        ["4"] = {"70011"},
                                        ["5"] = {"70012"},
                                        ["6"] = {"70013"},
                                        ["7"] = {"70014"},
                                    },
                                    ["Star_3"] = {
                                        ["1"] = {"70015"},
                                        ["2"] = {"70016"},
                                        ["3"] = {"70017"},
                                        ["4"] = {"70018"},
                                        ["5"] = {"70019"},
                                        ["6"] = {"70020"},
                                        ["7"] = {"70021"},
                                    },
                                    ["Star_4"] = {
                                        ["1"] = {"70022"},
                                        ["2"] = {"70023"},
                                        ["3"] = {"70024"},
                                        ["4"] = {"70025"},
                                        ["5"] = {"70026"},
                                        ["6"] = {"70027"},
                                        ["7"] = {"70028"},
                                    },
                                    ["Star_5"] = {
                                        ["1"] = {"70029"},
                                        ["2"] = {"70030"},
                                        ["3"] = {"70031"},
                                        ["4"] = {"70032"},
                                        ["5"] = {"70033"},
                                        ["6"] = {"70034"},
                                        ["7"] = {"70035"},
                                    },
                                    ["Star_6"] = {
                                        ["1"] = {"70036"},
                                        ["2"] = {"70037"},
                                        ["3"] = {"70038"},
                                        ["4"] = {"70039"},
                                        ["5"] = {"70040"},
                                        ["6"] = {"70041"},
                                        ["7"] = {"70042"},
                                    },
                                    ["Star_7"] = {
                                        ["1"] = {"70043"},
                                        ["2"] = {"70044"},
                                        ["3"] = {"70045"},
                                        ["4"] = {"70046"},
                                        ["5"] = {"70047"},
                                        ["6"] = {"70048"},
                                        ["7"] = {"70049"},
                                    },
                                    ["Star_8"] = {
                                        ["1"] = {"70050"},
                                        ["2"] = {"70051"},
                                        ["3"] = {"70052"},
                                        ["4"] = {"70053"},
                                        ["5"] = {"70054"},
                                        ["6"] = {"70055"},
                                        ["7"] = {"70056"},
                                    },
                                    ["Star_9"] = {
                                        ["1"] = {"70057"},
                                        ["2"] = {"70058"},
                                        ["3"] = {"70059"},
                                        ["4"] = {"70060"},
                                        ["5"] = {"70061"},
                                        ["6"] = {"70062"},
                                        ["7"] = {"70063"},
                                    },
                                    ["Star_10"] = {
                                        ["1"] = {"70064"},
                                        ["2"] = {"70065"},
                                        ["3"] = {"70066"},
                                        ["4"] = {"70067"},
                                        ["5"] = {"70068"},
                                        ["6"] = {"70069"},
                                        ["7"] = {"70070"},
                                    },
                                    ["Star_11"] = {
                                        ["1"] = {"70071"},
                                        ["2"] = {"70072"},
                                        ["3"] = {"70073"},
                                        ["4"] = {"70074"},
                                        ["5"] = {"70075"},
                                        ["6"] = {"70076"},
                                        ["7"] = {"70077"},
                                    },
                                    ["Star_12"] = {
                                        ["1"] = {"70078"},
                                        ["2"] = {"70079"},
                                        ["3"] = {"70080"},
                                        ["4"] = {"70081"},
                                        ["5"] = {"70082"},
                                        ["6"] = {"70083"},
                                        ["7"] = {"70084"},
                                    },
                                    ["Star_13"] = {
                                        ["1"] = {"70085"},
                                        ["2"] = {"70086"},
                                        ["3"] = {"70087"},
                                        ["4"] = {"70088"},
                                        ["5"] = {"70089"},
                                        ["6"] = {"70090"},
                                        ["7"] = {"70091"},
                                    },
                                    ["Star_14"] = {
                                        ["1"] = {"70092"},
                                        ["2"] = {"70093"},
                                        ["3"] = {"70094"},
                                        ["4"] = {"70095"},
                                        ["5"] = {"70096"},
                                        ["6"] = {"70097"},
                                        ["7"] = {"70098"},
                                    },
                                    ["Star_15"] = {
                                        ["1"] = {"70099"},
                                        ["2"] = {"70100"},
                                        ["3"] = {"70101"},
                                        ["4"] = {"70102"},
                                        ["5"] = {"70103"},
                                        ["6"] = {"70104"},
                                        ["7"] = {"70105"},
                                    },
                                    ["Star_16"] = {
                                        ["1"] = {"70106"},
                                        ["2"] = {"70107"},
                                        ["3"] = {"70108"},
                                        ["4"] = {"70109"},
                                        ["5"] = {"70110"},
                                        ["6"] = {"70111"},
                                        ["7"] = {"70112"},
                                    },
                                    ["Star_17"] = {
                                        ["1"] = {"70113"},
                                        ["2"] = {"70114"},
                                        ["3"] = {"70115"},
                                        ["4"] = {"70116"},
                                        ["5"] = {"70117"},
                                        ["6"] = {"70118"},
                                        ["7"] = {"70119"},
                                    },
                                    ["Star_18"] = {
                                        ["1"] = {"70120"},
                                        ["2"] = {"70121"},
                                        ["3"] = {"70122"},
                                        ["4"] = {"70123"},
                                        ["5"] = {"70124"},
                                        ["6"] = {"70125"},
                                        ["7"] = {"70126"},
                                        ["8"] = {"70127"}
                                    },
                                    ["Star_19"] = {
                                        ["1"] = {"70128"},
                                        ["2"] = {"70129"},
                                        ["3"] = {"70130"},
                                        ["4"] = {"70131"},
                                        ["5"] = {"70132"},
                                        ["6"] = {"70133"},
                                        ["7"] = {"70134"},
                                        ["8"] = {"70135"}
                                    },
                                    ["Star_20"] = {
                                        ["1"] = {"70136"},
                                        ["2"] = {"70137"},
                                        ["3"] = {"70138"},
                                        ["4"] = {"70139"},
                                        ["5"] = {"70140"},
                                        ["6"] = {"70141"},
                                        ["7"] = {"70142"},
                                        ["8"] = {"70143"}
                                    },
                                    ["Star_21"] = {
                                        ["1"] = {"70144"},
                                        ["2"] = {"70145"},
                                        ["3"] = {"70146"},
                                        ["4"] = {"70147"},
                                        ["5"] = {"70148"},
                                        ["6"] = {"70149"},
                                        ["7"] = {"70150"},
                                        ["8"] = {"70151"}
                                    },
                                    ["Star_22"] = {
                                        ["1"] = {"70152"},
                                        ["2"] = {"70153"},
                                        ["3"] = {"70154"},
                                        ["4"] = {"70155"},
                                        ["5"] = {"70156"},
                                        ["6"] = {"70157"},
                                        ["7"] = {"70158"},
                                        ["8"] = {"70159"}
                                    },
                                    ["Star_23"] = {
                                        ["1"] = {"70160"},
                                        ["2"] = {"70161"},
                                        ["3"] = {"70162"},
                                        ["4"] = {"70163"},
                                        ["5"] = {"70164"},
                                        ["6"] = {"70165"},
                                        ["7"] = {"70166"},
                                        ["8"] = {"70167"}
                                    },
                                    ["Star_24"] = {
                                        ["1"] = {"70168"},
                                        ["2"] = {"70169"},
                                        ["3"] = {"70170"},
                                        ["4"] = {"70171"},
                                        ["5"] = {"70172"},
                                        ["6"] = {"70173"},
                                        ["7"] = {"70174"},
                                        ["8"] = {"70175"}
                                    },
                                    ["Star_25"] = {
                                        ["1"] = {"70176"},
                                        ["2"] = {"70177"},
                                        ["3"] = {"70178"},
                                        ["4"] = {"70179"},
                                        ["5"] = {"70180"},
                                        ["6"] = {"70181"},
                                        ["7"] = {"70182"},
                                        ["8"] = {"70183"}
                                    },
                                    ["Star_26"] = {
                                        ["1"] = {"70184"},
                                        ["2"] = {"70185"},
                                        ["3"] = {"70186"},
                                        ["4"] = {"70187"},
                                        ["5"] = {"70188"},
                                        ["6"] = {"70189"},
                                        ["7"] = {"70190"},
                                        ["8"] = {"70191"}
                                    },
                                    ["Star_27"] = {
                                        ["1"] = {"70192"},
                                        ["2"] = {"70193"},
                                        ["3"] = {"70194"},
                                        ["4"] = {"70195"},
                                        ["5"] = {"70196"},
                                        ["6"] = {"70197"},
                                        ["7"] = {"70198"},
                                        ["8"] = {"70199"}
                                    },
                                    ["Star_28"] = {
                                        ["1"] = {"70200"},
                                        ["2"] = {"70201"},
                                        ["3"] = {"70202"},
                                        ["4"] = {"70203"},
                                        ["5"] = {"70204"},
                                        ["6"] = {"70205"},
                                        ["7"] = {"70206"},
                                        ["8"] = {"70207"}
                                    }
                                }
                                for star, rarities in pairs(starRarityMap) do
                                    for rarity, ids in pairs(rarities) do
                                        for _, id in ipairs(ids) do
                                            local args = {
                                                [1] = {
                                                    ["Value"] = false,
                                                    ["Path"] = {"Settings", "AutoDelete", "Stars", id, tostring(rarity)},
                                                    ["Action"] = "Settings"
                                                }
                                            }
                                            ToServer:FireServer(unpack(args))
                                        end
                                    end
                                end

                                local rarities = starRarityMap[selectedDeleteStar]
                                if rarities then
                                    if type(selectedRarities) ~= "table" then selectedRarities = {} end
                                    for rarity, _ in pairs(selectedRarities) do
                                        local ids = rarities[rarity]
                                        if ids then
                                            for _, id in ipairs(ids) do
                                                local args = {
                                                    [1] = {
                                                        ["Value"] = true,
                                                        ["Path"] = {"Settings", "AutoDelete", "Stars", id, rarity},
                                                        ["Action"] = "Settings"
                                                    }
                                                }
                                                pcall(function()
                                                    ToServer:FireServer(unpack(args))
                                                end)
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(1)
                        end
                    end)
                end
                end
    }
)

        do
            -- Map places to Star internal names for Auto Delete selection
            local starToPlace = {
            ["Star_1"] = "Earth City",
            ["Star_2"] = "Windmill Island",
            ["Star_3"] = "Soul Society",
            ["Star_4"] = "Cursed School",
            ["Star_5"] = "Slayer Village",
            ["Star_6"] = "Solo Island",
            ["Star_7"] = "Clover Village",
            ["Star_8"] = "Leaf Village",
            ["Star_9"] = "Spirit Residence",
            ["Star_10"] = "Magic Hunter City",
            ["Star_11"] = "Titan City",
            ["Star_12"] = "Village of Sins",
            ["Star_13"] = "Kaiju Base",
            ["Star_14"] = "Tempest Capital",
            ["Star_15"] = "Virtual City",
            ["Star_16"] = "Cairo",
            ["Star_17"] = "Ghoul City",
            ["Star_18"] = "Chainsaw City",
            ["Star_19"] = "Tokyo Empire",
            ["Star_20"] = "Green Planet",
            ["Star_21"] = "Hollow World",
            ["Star_22"] = "Shadow Academy",
            ["Star_23"] = "Z City",
            ["Star_24"] = "Great Tomb",
            ["Star_25"] = "Thriller Park",
            ["Star_26"] = "Amusement Park",
            ["Star_27"] = "Re:Manor",
            ["Star_28"] = "Asfordo Academy"
        }
        local placeToStar = {}
        local starPlaces = {}
        for k, v in pairs(starToPlace) do
            placeToStar[v] = k
            table.insert(starPlaces, v)
        end

        -- Ensure order matches Star_1..Star_25
        table.sort(starPlaces, function(a, b)
            local ai = tonumber((placeToStar[a] or "Star_1"):match("Star_(%d+)") or 0)
            local bi = tonumber((placeToStar[b] or "Star_1"):match("Star_(%d+)") or 0)
            return ai < bi
        end)

        -- Populate any previously selectedDeleteStar into display form (display string expected)
        local SelectDeleteStarDefault = nil
        if config.SelectDeleteStarDropdown then
            -- config may contain either the display name or the internal Star_x; handle both
            if placeToStar[config.SelectDeleteStarDropdown] then
                -- config contains a display name
                SelectDeleteStarDefault = config.SelectDeleteStarDropdown
            elseif starToPlace[config.SelectDeleteStarDropdown] then
                -- config contains internal name like "Star_1"
                SelectDeleteStarDefault = starToPlace[config.SelectDeleteStarDropdown]
            end
        end
        SelectDeleteStarDefault = SelectDeleteStarDefault or starToPlace[selectedDeleteStar] or starPlaces[1]

        -- Dropdown: choose which Star/place to auto-delete
        AutoDeleteGroupbox:AddDropdown(
            "SelectDeleteStarDropdown",
            {
                Title = "Select Star for Auto Delete (by Place)",
                Values = starPlaces,
                Default = SelectDeleteStarDefault,
                Multi = false,
                Callback = function(Option)
                    selectedDeleteStar = placeToStar[Option] or "Star_1"
                    -- SaveManager automatically saves this dropdown's value
                end
            }
        )

        local rarityMap = {
            Common = "1",
            Uncommon = "2",
            Rare = "3",
            Epic = "4",
            Legendary = "5",
            Mythical = "6",
            Phantom = "7",
            Supreme = "8"
        }

            -- Initialize selectedRarities from selectedRaritiesDisplay (if any)
            if type(selectedRaritiesDisplay) == "table" then
                for _, displayName in ipairs(selectedRaritiesDisplay) do
                    if rarityMap[displayName] then
                        selectedRarities[rarityMap[displayName]] = true
                    end
                end
            end

            -- Auto Delete Rarities Dropdown
            AutoDeleteGroupbox:AddDropdown(
            "AutoDeleteRaritiesDropdown",
            {
                Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Phantom", "Supreme"},
                Default = config.AutoDeleteRaritiesDropdown or selectedRaritiesDisplay,
                Multi = true,
                Text = "Select Rarities to Delete",
                Callback = function(Selected)
                    selectedRarities = {}
                    selectedRaritiesDisplay = {}
                    for displayName, _ in pairs(Selected) do
                        if rarityMap[displayName] then
                            selectedRarities[rarityMap[displayName]] = true
                            table.insert(selectedRaritiesDisplay, displayName)
                        end
                    end
                    -- SaveManager automatically saves this dropdown's value
                end
            }
        )
        end

AutoDeleteGroupbox2:AddDropdown(
    "AutoDeleteGachaRaritiesDropdown",
    {
        Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Phantom"},
        Default = config.AutoDeleteGachaRaritiesDropdown or selectedGachaRarities,
        Multi = true,
        Text = "Select Gacha Rarities to Delete",
        Callback = function(Selected)
            selectedGachaRarities = {}
            for displayName, _ in pairs(Selected) do
                if gachaRarityMap[displayName] then
                    selectedGachaRarities[gachaRarityMap[displayName]] = true
                end
            end
            -- SaveManager automatically saves this dropdown's value
        end
    }
)


AutoDeleteGroupbox2:AddToggle(
    "AutoDeleteGachaUnitsToggle",
    {
        Text = "Auto Weapon Units",
        Default = config.AutoDeleteGachaUnitsToggle or false,
        Callback = function(Value)
            autoDeleteWeaponEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                -- ✅ If enabled, start auto-delete loop
                task.spawn(function()
                    while autoDeleteWeaponEnabled and getgenv().SeisenHubRunning do
                        for rarity, enabled in pairs(selectedGachaRarities) do
                            if enabled then
                                local args = {
                                    [1] = {
                                        ["Value"] = true,
                                        ["Path"] = {"Settings", "AutoDelete", "Gachas", "3000" .. rarity, rarity},
                                        ["Action"] = "Settings"
                                    }
                                }
                                pcall(function()
                                    game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                                end)
                            end
                        end
                        task.wait(1)
                    end
                end)
            else
                -- ✅ If disabled, send "false" to turn it off server-side for all rarities (unselect delete)
                for rarityStr, rarity in pairs(gachaRarityMap) do
                    local args = {
                        [1] = {
                            ["Value"] = false,
                            ["Path"] = {"Settings", "AutoDelete", "Gachas", "3000" .. rarity, rarity},
                            ["Action"] = "Settings"
                        }
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                    end)
                end
            end
        end
    }
)

-- Titan auto-delete dropdown
AutoDeleteTitan:AddDropdown(
    "AutoDeleteTitanRaritiesDropdown",
    {
        Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Phantom"},
        Default = config.AutoDeleteTitanRaritiesDropdown or selectedTitanRaritiesDisplay,
        Multi = true,
        Text = "Select Titan Rarities to Delete",
        Callback = function(Selected)
            selectedTitanRarities = {}
            for displayName, _ in pairs(Selected) do
                if titanRarityMap[displayName] then
                    selectedTitanRarities[titanRarityMap[displayName]] = true
                end
            end
            -- SaveManager automatically saves this dropdown's value
        end
    }
)

-- Titan auto-delete toggle
AutoDeleteTitan:AddToggle(
    "AutoDeleteTitanUnitsToggle",
    {
        Text = "Auto Titan Units",
        Default = config.AutoDeleteTitanUnitsToggle or false,
        Callback = function(Value)
            autoDeleteTitanEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                -- ✅ If enabled, start auto-delete loop for titans
                task.spawn(function()
                    while autoDeleteTitanEnabled and getgenv().SeisenHubRunning do
                        -- selectedTitanRarities may be nil if the dropdown hasn't been used yet.
                        if type(selectedTitanRarities) ~= "table" then
                            task.wait(1)
                        else
                            for rarity, enabled in pairs(selectedTitanRarities) do
                                if enabled then
                                    local args = {
                                        [1] = {
                                            ["Value"] = true,
                                            ["Path"] = {"Settings", "AutoDelete", "Gachas", "10000" .. rarity, rarity},
                                            ["Action"] = "Settings"
                                        }
                                    }
                                    pcall(function()
                                        game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                                    end)
                                end
                            end
                            task.wait(1)
                        end
                    end
                end)
            else
                -- ✅ If disabled, send "false" to turn it off server-side for all rarities (unselect delete)
                for rarityStr, _ in pairs(titanRarityMap) do
                    local rarity = titanRarityMap[rarityStr]
                    local args = {
                        [1] = {
                            ["Value"] = false,
                            ["Path"] = {"Settings", "AutoDelete", "Gachas", "10000" .. rarity, rarity},
                            ["Action"] = "Settings"
                        }
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                    end)
                end
            end
        end
    }
)

-- Stand auto-delete dropdown
AutoDeleteStand:AddDropdown(
    "AutoDeleteStandRaritiesDropdown",
    {
        Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Phantom", "Supreme"},
        Default = config.AutoDeleteStandRaritiesDropdown or selectedStandRaritiesDisplay,
        Multi = true,
        Text = "Select Stand Rarities to Delete",
        Callback = function(Selected)
            selectedStandRarities = {}
            for displayName, _ in pairs(Selected) do
                if standRarityMap[displayName] then
                    selectedStandRarities[standRarityMap[displayName]] = true
                end
            end
            -- SaveManager automatically saves this dropdown's value
        end
    }
)


-- Stand auto-delete toggle
AutoDeleteStand:AddToggle(
    "AutoDeleteStandUnitsToggle",
    {
        Text = "Auto Stand Units",
        Default = config.AutoDeleteStandUnitsToggle or false,
        Callback = function(Value)
            autoDeleteStandEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                -- ✅ If enabled, start auto-delete loop for stands
                task.spawn(function()
                    while autoDeleteStandEnabled and getgenv().SeisenHubRunning do
                        for rarity, enabled in pairs(selectedStandRarities) do
                            if enabled then
                                local args = {
                                    [1] = {
                                        ["Value"] = true,
                                        ["Path"] = {"Settings", "AutoDelete", "Gachas", "11000" .. rarity, rarity},
                                        ["Action"] = "Settings"
                                    }
                                }
                                pcall(function()
                                    game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                                end)
                            end
                        end
                        task.wait(1)
                    end
                end)
            else
                -- ✅ If disabled, send "false" to turn it off server-side for all rarities (unselect delete)
                for rarity, _ in pairs(selectedStandRarities) do
                    local args = {
                        [1] = {
                            ["Value"] = false,
                            ["Path"] = {"Settings", "AutoDelete", "Gachas", "11000" .. rarity, rarity},
                            ["Action"] = "Settings"
                        }
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                    end)
                end
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollDragonRaceToggle",
    {
        Text = "Dragon Race",
        Default = config.AutoRollDragonRaceToggle or false,
        Tooltip = "Automatically rolls for Dragon Race.",
        Callback = function(Value)
            autoRollDragonRaceEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Dragon_Race_Unlock"
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(unlockArgs))
                    end)
                    while autoRollDragonRaceEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Dragon_Race"
                            }
                        }
                        pcall(function()
                            ToServer:FireServer(unpack(args))
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)


RollGroupbox2:AddToggle(
    "AutoRollSaiyanEvolutionToggle",
    {
        Text = "Saiyan Evolution",
        Default = config.AutoRollSaiyanEvolutionToggle or false,
        Tooltip = "Automatically rolls for Saiyan Evolution.",
        Callback = function(Value)
            autoRollSaiyanEvolutionEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Saiyan_Evolution_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    task.wait(0.5)
                    while autoRollSaiyanEvolutionEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Saiyan_Evolution"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)


RollGroupbox2:AddToggle(
    "AutoRollSwordsToggle",
    {
        Text = "Swords",
        Default = config.AutoRollSwordsToggle or false,
        Callback = function(Value)
            autoRollSwordsEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Swords_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoRollSwordsEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Swords"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollPirateCrewToggle",
    {
        Text = "Pirate Crew",
        Default = config.AutoRollPirateCrewToggle or false,
        Callback = function(Value)
            autoRollPirateCrewEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Pirate_Crew_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoRollPirateCrewEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Pirate_Crew"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollDemonFruitsToggle",
    {
        Text = "Demon Fruits",
        Default = config.AutoRollDemonFruitsToggle or false,
        Callback = function(Value)
            autoRollDemonFruitsEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Demon_Fruits_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoRollDemonFruitsEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Demon_Fruits"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollReiatsuColorToggle",
    {
        Text = "Reiatsu Color",
        Default = config.AutoRollReiatsuColorToggle or false,
        Callback = function(Value)
            autoRollReiatsuColorEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Reiatsu_Color_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoRollReiatsuColorEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Reiatsu_Color"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollZanpakutoToggle",
    {
        Text = "Zanpakuto",
        Default = config.AutoRollZanpakutoToggle or false,
        Callback = function(Value)
            autoRollZanpakutoEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Zanpakuto_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoRollZanpakutoEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Zanpakuto"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollCursesToggle",
    {
        Text = "Curses",
        Default = config.AutoRollCursesToggle or false,
        Callback = function(Value)
            autoRollCursesEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Curses_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoRollCursesEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Curses"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollDemonArtsToggle",
    {
        Text = "Demon Arts",
        Default = config.AutoRollDemonArtsToggle or false,
        Callback = function(Value)
            autoRollDemonArtsEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Demon_Arts_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    while autoRollDemonArtsEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Demon_Arts"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoSoloHunterRankToggle",
    {
        Text = "Solo Rank",
        Default = config.AutoSoloHunterRankToggle or false,
        Callback = function(Value)
            autoSoloHunterRankEnabled = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Solo_Hunter_Rank_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    task.wait(0.5)
                    while autoSoloHunterRankEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Solo_Hunter_Rank"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollGrimoireToggle",
    {
        Text = "Grimoire",
        Default = config.AutoRollGrimoireToggle or false,
        Callback = function(Value)
            autoRollGrimoireToggle = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Grimoire_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    task.wait(0.5)
                    while autoRollGrimoireToggle and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Grimoire"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollPowerEyesToggle",
    {
        Text = "Power Eyes",
        Default = config.AutoRollPowerEyesToggle or false,
        Callback = function(Value)
            autoRollPowerEyesToggle = Value
            if Value then
                task.spawn(function()
                    local unlockArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Power_Eyes_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(unlockArgs)) end)
                    task.wait(0.5)
                    while autoRollPowerEyesToggle and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Power_Eyes"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoPsychicMayhemToggle",
    {
        Text = "Psychic Mayhem",
        Default = config.AutoPsychicMayhemToggle or false,
        Tooltip = "Automatically buys and rolls Psychic Mayhem.",
        Callback = function(Value)
            autoPsychicMayhemEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Psychic_Mayhem_Unlock"
                        }
                    }
                    ToServer:FireServer(unpack(args))
                    task.wait(0.5)
                    while autoPsychicMayhemEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Psychic_Mayhem"
                            }
                        }
                        ToServer:FireServer(unpack(args))
                        task.wait(1.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollEnergyCardToggle",
    {
        Text = "Energy Card Shop",
        Default = config.AutoRollEnergyCardToggle or false,
        Tooltip = "Automatically unlocks and rolls Energy Card.",
        Callback = function(Value)
            autoRollEnergyCardEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Energy_Card_Shop_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollEnergyCardEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Energy_Card_Shop"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollDamageCardToggle",
    {
        Text = "Damage Card Shop",
        Default = config.AutoRollDamageCardToggle or false,
        Tooltip = "Automatically unlocks and rolls Damage Card.",
        Callback = function(Value)
            autoRollDamageCardEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Damage_Card_Shop_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollDamageCardEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Damage_Card_Shop"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollFamiliesToggle",
    {
        Text = "Families",
        Default = config.AutoRollFamiliesToggle or false,
        Tooltip = "Automatically unlocks and rolls Families.",
        Callback = function(Value)
            autoRollFamiliesEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Families_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollFamiliesEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Families"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollTitansToggle",
    {
        Text = "Titans",
        Default = config.AutoRollTitansToggle or false,
        Tooltip = "Automatically unlocks and rolls Titans.",
        Callback = function(Value)
            autoRollTitansEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Titans_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollTitansEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Titans"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollSinsToggle",
    {
        Text = "Sins",
        Default = config.AutoRollSinsToggle or false,
        Tooltip = "Automatically unlocks and rolls Sins.",
        Callback = function(Value)
            autoRollSinsEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Sins_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollSinsEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Sins"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollCommandmentsToggle",
    {
        Text = "Commandments",
        Default = config.AutoRollCommandmentsToggle or false,
        Tooltip = "Automatically unlocks and rolls Commandments.",
        Callback = function(Value)
            autoRollCommandmentsEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Commandments_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollCommandmentsEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Commandments"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollKaijuPowersToggle",
    {
        Text = "Kaiju Powers",
        Default = config.AutoRollKaijuPowersToggle or false,
        Tooltip = "Automatically unlocks and upgrades Kaiju Powers.",
        Callback = function(Value)
            autoRollKaijuPowersEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Kaiju_Powers_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollKaijuPowersEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Kaiju_Powers"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollSpeciesToggle",
    {
        Text = "Species",
        Default = config.AutoRollSpeciesToggle or false,
        Tooltip = "Automatically unlocks and rolls Species.",
        Callback = function(Value)
            autoRollSpeciesEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Species_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollSpeciesEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Species"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollUltimateSkillsToggle",
    {
        Text = "Ultimate Skills",
        Default = config.AutoRollUltimateSkillsToggle or false,
        Tooltip = "Automatically unlocks and rolls Ultimate Skills.",
        Callback = function(Value)
            autoRollUltimateSkillsEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Ultimate_Skills_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollUltimateSkillsEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Ultimate_Skills"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollPowerEnergyRunesToggle",
    {
        Text = "Power Energy Runes",
        Default = config.AutoRollPowerEnergyRunesToggle or false,
        Tooltip = "Automatically unlocks and rolls Power Energy Runes.",
        Callback = function(Value)
            autoRollPowerEnergyRunesEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Power_Energy_Runes_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollPowerEnergyRunesEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10;
                                ["Action"] = "_Gacha_Activate";
                                ["Name"] = "Power_Energy_Runes";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollStandsToggle",
    {
        Text = "Stands",
        Default = config.AutoRollStandsToggle or false,
        Tooltip = "Automatically unlocks and rolls Stands.",
        Callback = function(Value)
            autoRollStandsEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Stands_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollStandsEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Stands"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollOnomatopoeiaToggle",
    {
        Text = "Onomatopoeia",
        Default = config.AutoRollOnomatopoeiaToggle or false,
        Tooltip = "Automatically unlocks and rolls Onomatopoeia.",
        Callback = function(Value)
            autoRollOnomatopoeiaEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Onomatopoeia_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollOnomatopoeiaEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Onomatopoeia"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollKaguneToggle",
    {
        Text = "Kagune",
        Default = config.AutoRollKaguneToggle or false,
        Tooltip = "Automatically unlocks and rolls Kagune.",
        Callback = function(Value)
            autoRollKaguneEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Kagune_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollKaguneEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Kagune"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollInvestigatorToggle",
    {
        Text = "Investigator",
        Default = config.AutoRollInvestigatorToggle or false,
        Tooltip = "Automatically unlocks and rolls Investigator.",
        Callback = function(Value)
            autoRollInvestigatorEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Investigators_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollInvestigatorEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Investigators"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollDebiruHunterToggle",
    {
        Text = "Debiru Hunter",
        Default = config.AutoRollDebiruHunterToggle or false,
        Tooltip = "Automatically unlocks and rolls Debiru Hunter.",
        Callback = function(Value)
            autoRollDebiruHunterEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Debiru_Hunter_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollDebiruHunterEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Debiru_Hunter"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollAkumaPowersToggle",
    {
        Text = "Akuma Powers",
        Default = config.AutoRollAkumaPowersToggle or false,
        Tooltip = "Automatically unlocks and rolls Akuma Powers.",
        Callback = function(Value)
            autoRollAkumaPowersEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Akuma_Powers_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollAkumaPowersEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Akuma_Powers"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)


RollGroupbox2:AddToggle(
    "AutoRollSpecialFireForceToggle",
    {
        Text = "Special Fire Force",
        Default = config.AutoRollSpecialFireForceToggle or false,
        Tooltip = "Automatically unlocks and rolls Special Fire Force.",
        Callback = function(Value)
            autoRollSpecialFireForceEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Special_Fire_Force_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollSpecialFireForceEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Special_Fire_Force"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollMushiBiteToggle",
    {
        Text = "Mushi Bite",
        Default = config.AutoRollMushiBiteToggle or false,
        Tooltip = "Automatically unlocks and rolls Mushi Bite.",
        Callback = function(Value)
            autoRollMushiBiteEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Mushi_Bite_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollMushiBiteEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Mushi_Bite"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Auto Roll Grand Elder Power
RollGroupbox2:AddToggle(
    "AutoRollGrandElderPowerToggle",
    {
        Text = "Grand Elder Power",
        Default = config.AutoRollGrandElderPowerToggle or false,
        Tooltip = "Automatically unlocks and rolls Grand Elder Power.",
        Callback = function(Value)
            autoRollGrandElderPowerEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Grand_Elder_Power_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollGrandElderPowerEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Grand_Elder_Power"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Auto Roll Frost Demon Evolution
RollGroupbox2:AddToggle(
    "AutoRollFrostDemonEvolutionToggle",
    {
        Text = "Frost Demon Evolution",
        Default = config.AutoRollFrostDemonEvolutionToggle or false,
        Tooltip = "Automatically unlocks and rolls Frost Demon Evolution.",
        Callback = function(Value)
            autoRollFrostDemonEvolutionEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Frost_Demon_Evolution_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollFrostDemonEvolutionEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Frost_Demon_Evolution"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)
-- Auto Roll Scythes
RollGroupbox2:AddToggle(
    "AutoRollScythesToggle",
    {
        Text = "Scythes",
        Default = config.AutoRollScythesToggle or false,
        Tooltip = "Automatically unlocks and rolls Scythes.",
        Callback = function(Value)
            autoRollScythesEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Scythes_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollScythesEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Scythes"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)
-- Auto Roll Espada
RollGroupbox2:AddToggle(
    "AutoRollEspadaToggle",
    {
        Text = "Espada",
        Default = config.AutoRollEspadaToggle or false,
        Tooltip = "Automatically unlocks and rolls Espada.",
        Callback = function(Value)
            autoRollEspadaEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Espada_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollEspadaEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Espada"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollGrandElderPowerToggle",
    {
        Text = "Grand Elder Power",
        Default = config.AutoRollGrandElderPowerToggle or false,
        Tooltip = "Automatically unlocks and rolls Grand Elder Power.",
        Callback = function(Value)
            autoRollGrandElderPowerEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Grand_Elder_Power"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollGrandElderPowerEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 4;
                                ["Action"] = "_Gacha_Activate";
                                ["Name"] = "Grand_Elder_Power";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Auto Roll Shadow Garden
RollGroupbox2:AddToggle(
    "AutoRollShadowGardenToggle",
    {
        Text = "Shadow Garden",
        Default = config.AutoRollShadowGardenToggle or false,
        Tooltip = "Automatically unlocks and rolls Shadow Garden.",
        Callback = function(Value)
            autoRollShadowGardenEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Shadow_Garden_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollShadowGardenEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Shadow_Garden"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

-- Auto Roll Shadow Arts
RollGroupbox2:AddToggle(
    "AutoRollShadowArtsToggle",
    {
        Text = "Shadow Arts",
        Default = config.AutoRollShadowArtsToggle or false,
        Tooltip = "Automatically unlocks and rolls Shadow Arts.",
        Callback = function(Value)
            autoRollShadowArtsEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Shadow_Arts_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollShadowArtsEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Shadow_Arts"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollPunchPowerToggle",
    {
        Text = "Punch Power",
        Default = config.AutoRollPunchPowerToggle or false,
        Tooltip = "Automatically unlocks and rolls Punch Power.",
        Callback = function(Value)
            autoRollPunchPowerEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Punch_Power_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollPunchPowerEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Punch_Power"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollEnergyThreatLevelToggle",
    {
        Text = "Energy Threat Level",
        Default = config.AutoRollEnergy_Threat_LevelToggle or false,
        Tooltip = "Automatically unlocks and rolls Energy Threat Level.",
        Callback = function(Value)
            autoRollEnergyThreatLevelEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Energy_Threat_Level_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollEnergyThreatLevelEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Energy_Threat_Level"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollAdventurerRankToggle",
    {
        Text = "Adventurer Rank",
        Default = config.AutoRollAdventurerRankToggle or false,
        Tooltip = "Automatically unlocks and rolls Adventurer Rank.",
        Callback = function(Value)
            autoRollAdventurerRankEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Adventurer_Rank_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollAdventurerRankEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Adventurer_Rank"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollMagicTierToggle",
    {
        Text = "Magic Tier",
        Default = config.AutoRollMagicTierToggle or false,
        Tooltip = "Automatically unlocks and rolls Magic Tier.",
        Callback = function(Value)
            autoRollMagicTierEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Magic_Tier_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollMagicTierEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Magic_Tier"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollThrillerZombieToggle",
    {
        Text = "Thriller Zombie",
        Default = config.AutoRollThrillerZombieToggle or false,
        Tooltip = "Automatically unlocks and rolls Magic Tier.",
        Callback = function(Value)
            autoRollThrillerZombieEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Thriller_Zombie_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollThrillerZombieEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Thriller_Zombie"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollNightmareEvolutionToggle",
    {
        Text = "Nightmare Evolution",
        Default = config.AutoRollNightmareEvolutionToggle or false,
        Tooltip = "Automatically unlocks and rolls Nightmare Evolution.",
        Callback = function(Value)
            autoRollNightmareEvolutionEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Nightmare_Evolution_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollNightmareEvolutionEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Nightmare_Evolution"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollSpecialZombieToggle",
    {
        Text = "Special Zombie",
        Default = config.AutoRollSpecialZombieToggle or false,
        Tooltip = "Automatically unlocks and rolls Special Zombie.",
        Callback = function(Value)
            autoRollSpecialZombieEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Special_Zombie_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollSpecialZombieEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Special_Zombie"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollAssassinGradeToggle",
    {
        Text = "Assassin Grade",
        Default = config.AutoRollAssassinGradeToggle or false,
        Tooltip = "Automatically unlocks and rolls Assassin Grade.",
        Callback = function(Value)
            autoRollAssassinGradeEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Assassin_Grade_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollAssassinGradeEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Assassin_Grade"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollAssassinSkillsToggle",
    {
        Text = "Assassin Skills",
        Default = config.AutoRollAssassinSkillsToggle or false,
        Tooltip = "Automatically unlocks and rolls Assassin Skills.",
        Callback = function(Value)
            autoRollAssassinSkillsEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Assassin_Skills_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollAssassinSkillsEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Assassin_Skills"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollWitchFactorToggle",
    {
        Text = "Witch Factor",
        Default = config.AutoRollWitchFactorToggle or false,
        Tooltip = "Automatically unlocks and rolls Witch Factor.",
        Callback = function(Value)
            autoRollWitchFactorEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Witch_Factor_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollWitchFactorEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Witch_Factor"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollSpiritPactToggle",
    {
        Text = "Spirit Pact",
        Default = config.AutoRollSpiritPactToggle or false,
        Tooltip = "Automatically unlocks and rolls Spirit Pact.",
        Callback = function(Value)
            autoRollSpiritPactEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Spirit_Pact_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollSpiritPactEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Spirit_Pact"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollWitchAuthorityToggle",
    {
        Text = "Witch Authority",
        Default = config.AutoRollWitchAuthorityToggle or false,
        Tooltip = "Automatically unlocks and rolls Witch Authority.",
        Callback = function(Value)
            autoRollWitchAuthorityEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Witch_Authority_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollWitchAuthorityEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Witch_Authority"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollGeassPotentialToggle",
    {
        Text = "Geass Potential",
        Default = config.AutoRollGeassPotentialToggle or false,
        Tooltip = "Automatically unlocks and rolls Geass Potential.",
        Callback = function(Value)
            autoRollGeassPotentialEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Geass_Potential_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollGeassPotentialEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Geass_Potential"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollKnightmareFramesToggle",
    {
        Text = "Knightmare Frames",
        Default = config.AutoRollKnightmareFramesToggle or false,
        Tooltip = "Automatically unlocks and rolls Knightmare Frames.",
        Callback = function(Value)
            autoRollKnightmareFramesEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Knightmare_Frames_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollKnightmareFramesEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Knightmare_Frames"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)



---=========================================Leveling==========================================---

-- Auto Roll Breathing Toggle
Enhance:AddToggle(
    "AutoLevelingToggle",
    {
        Text = "Auto Roll Breathing",
        Default = config.AutoLevelingToggle or false,
        Tooltip = "Automatically rolls breathing on the equipped weapon.",
        Callback = function(Value)
            autoLevelingEnabled = Value
            config.AutoLevelingToggle = Value        end
    }
)

-- Loop for Auto Roll Breathing
task.spawn(function()
    while task.wait(0.5) do
        if autoLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Weapons.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    -- Found equipped UniqueId
                    local uniqueId = item.Name

                    local args = {
                        [1] = {
                            ["Type"] = "Enchant",
                            ["Action"] = "Enchantment",
                            ["Enchantment_Name"] = "Breathings",
                            ["UniqueId"] = uniqueId,
                        }
                    }

                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Events", 9e9)
                        :WaitForChild("To_Server", 9e9)
                        :FireServer(unpack(args))
                end
            end
        end
    end
end)

-- Auto Shadow Enhancer Toggle
Enhance:AddToggle(
    "AutoShadowEnhancerToggle",
    {
        Text = "Auto Shadow Enhancer",
        Default = config.AutoShadowEnhancerToggle or false,
        Tooltip = "Automatically enchants equipped shadow with Shadow Enhancer.",
        Callback = function(Value)
            autoShadowEnhancerEnabled = Value
            config.AutoShadowEnhancerToggle = Value
        end
    }
)

-- Loop for Auto Shadow Enhancer
task.spawn(function()
    while task.wait(0.5) do
        if autoShadowEnhancerEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Shadows.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    -- Found equipped UniqueId
                    local uniqueId = item.Name

                    local args = {
                        [1] = {
                            ["Type"] = "Enchant",
                            ["Action"] = "Enchantment",
                            ["Enchantment_Name"] = "Shadow_Enhancer",
                            ["UniqueId"] = uniqueId,
                        }
                    }

                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Events", 9e9)
                        :WaitForChild("To_Server", 9e9)
                        :FireServer(unpack(args))
                end
            end
        end
    end
end)

Enhance:AddToggle(
    "AutoRollWeaponRunesToggle",
    {
        Text = "Auto Roll Weapon Runes",
        Default = config.AutoRollWeaponRunesToggle or false,
        Tooltip = "Automatically rolls weapon runes on the equipped weapon.",
        Callback = function(Value)
            autoRollWeaponRunesEnabled = Value
            config.AutoRollWeaponRunesToggle = Value
        end
    }
)

-- Loop for Auto Roll Weapon Runes
task.spawn(function()
    while task.wait(0.5) do
        if autoRollWeaponRunesEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Weapons.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    -- Found equipped UniqueId
                    local uniqueId = item.Name

                    local args = {
                        [1] = {
                            ["Type"] = "Enchant",
                            ["Action"] = "Enchantment",
                            ["Enchantment_Name"] = "Weapon_Runes",
                            ["UniqueId"] = uniqueId,
                        }
                    }

                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Events", 9e9)
                        :WaitForChild("To_Server", 9e9)
                        :FireServer(unpack(args))
                end
            end
        end
    end
end)


-- Auto Roll Shadow Toggle
LevelUp:AddToggle(
    "AutoRollShadowToggle",
    {
        Text = "Auto Shadow Leveling",
        Default = config.AutoRollShadowToggle or false,
        Tooltip = "Automatically upgrades equipped shadow.",
        Callback = function(Value)
            autoRollShadowEnabled = Value
            config.AutoRollShadowToggle = Value
        end
    }
)

task.spawn(function()
    while task.wait(0.5) do
        if autoRollShadowEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Shadows.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    -- Found equipped UniqueId
                    local uniqueId = item.Name

                    local args = {
                        [1] = {
                            ["Upgrade_Name"] = "Level",
                            ["UniqueId"] = uniqueId,
                            ["Action"] = "Prog_Lv_Items",
                            ["Bench_Name"] = "Shadow_Leveling",
                        }
                    }

                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Events", 9e9)
                        :WaitForChild("To_Server", 9e9)
                        :FireServer(unpack(args))
                end
            end
        end
    end
end)


-- Auto Roll Titan Toggle
LevelUp:AddToggle(
    "AutoRollTitanToggle",
    {
        Text = "Titan Injection",
        Default = config.AutoRollTitanToggle or false,
        Tooltip = "Automatically injects equipped titan with Titan Injection.",
        Callback = function(Value)
            autoRollTitanEnabled = Value
            config.AutoRollTitanToggle = Value
        end
    }
)

-- Loop for Auto Roll Titan
task.spawn(function()
    while task.wait(0.5) do
        if autoRollTitanEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Titans.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    -- Found equipped UniqueId
                    local uniqueId = item.Name

                    local args = {
                        [1] = {
                            ["Type"] = "Enchant",
                            ["Action"] = "Enchantment",
                            ["Enchantment_Name"] = "Titan_Injection",
                            ["UniqueId"] = uniqueId,
                        }
                    }

                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Events", 9e9)
                        :WaitForChild("To_Server", 9e9)
                        :FireServer(unpack(args))
                end
            end
        end
    end
end)

-- Auto Roll Stand Toggle
LevelUp:AddToggle(
    "AutoRollStandToggle",
    {
        Text = "Stands Requiem Injection",
        Default = config.AutoRollStandToggle or false,
        Tooltip = "Automatically injects equipped stand.",
        Callback = function(Value)
            autoRollStandEnabled = Value
            config.AutoRollStandToggle = Value
        end
    }
)

-- Loop for Auto Roll Stand
task.spawn(function()
    while task.wait(0.5) do
        if autoRollStandEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Stands.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    -- Found equipped UniqueId
                    local uniqueId = item.Name

                    local args = {
                        [1] = {
                            ["Type"] = "Enchant",
                            ["Action"] = "Enchantment",
                            ["Enchantment_Name"] = "Requiem_Injection",
                            ["UniqueId"] = uniqueId,
                        }
                    }

                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Events", 9e9)
                        :WaitForChild("To_Server", 9e9)
                        :FireServer(unpack(args))
                end
            end
        end
    end
end)

-- Auto Kagune Leveling Toggle
LevelUp:AddToggle(
    "AutoKaguneLevelingToggle",
    {
        Text = "Auto Kagune Leveling",
        Default = config.AutoKaguneLevelingToggle or false,
        Tooltip = "Automatically levels up equipped Kagune if it matches Hakuja, Mukada, or Koumyaku.",
        Callback = function(Value)
            autoKaguneLevelingEnabled = Value
            config.AutoKaguneLevelingToggle = Value
        end
    }
)

-- Loop for Auto Kagune Leveling
task.spawn(function()
    local validTitles = {
        ["Hakuja"] = true,
        ["Mukada"] = true,
        ["Koumyaku"] = true
    }
    while task.wait(0.5) do
        if autoKaguneLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and validTitles[titleObj.Text] == true then
                        -- Only upgrade Kagune, never Halloween bags
                        if titleObj.Text ~= "Common Halloween Bag" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Leveling_Items",
                                    ["Bench_Name"] = "Kagune_Leveling",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)


        -- Auto Pokita Leveling Toggle
        LevelUp:AddToggle(
            "AutoPokitaLevelingToggle",
            {
                Text = "Auto Pokita Leveling",
                Default = config.AutoPokitaLevelingToggle or false,
                Tooltip = "Automatically levels up equipped Pokita if it matches Mythical, Phantom, or Supreme Pokita.",
                Callback = function(Value)
                    autoPokitaLevelingEnabled = Value
                    config.AutoPokitaLevelingToggle = Value
                end
            }
        )

        -- Loop for Auto Pokita Leveling
        task.spawn(function()
            local validTitles = {
                ["Mythical Pokita"] = true,
                ["Phantom Pokita"] = true,
                ["Supreme Pokita"] = true
            }
            while task.wait(0.5) do
                if autoPokitaLevelingEnabled then
                    local list = game:GetService("Players").LocalPlayer.PlayerGui
                        .Inventory_1.Hub.Powers.List_Frame.List

                    for _, item in pairs(list:GetChildren()) do
                        local inside = item:FindFirstChild("Inside")
                        if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                            local titleObj = inside:FindFirstChild("Title")
                            if titleObj and type(titleObj.Text) == "string" and validTitles[titleObj.Text] == true then
                                -- Only upgrade Pokita, never Halloween bags
                                if titleObj.Text ~= "Common Halloween Bag" then
                                    local uniqueId = item.Name
                                    local args = {
                                        [1] = {
                                            ["UniqueId"] = uniqueId,
                                            ["Action"] = "Leveling_Items",
                                            ["Bench_Name"] = "Pokita_Leveling",
                                        }
                                    }
                                    game:GetService("ReplicatedStorage")
                                        :WaitForChild("Events", 9e9)
                                        :WaitForChild("To_Server", 9e9)
                                        :FireServer(unpack(args))
                                end
                            end
                        end
                    end
                end
            end
        end)




-- Auto 1st Generation Leveling Toggle
LevelUp:AddToggle("Auto1stGenLevelingToggle", {
    Text = "Auto 1st Gen Leveling",
    Default = config.Auto1stGenLevelingToggle or false,
    Tooltip = "Automatically levels up equipped 1st Generation items.",
    Callback = function(Value)
        auto1stGenLevelingEnabled = Value
        config.Auto1stGenLevelingToggle = Value
    end
})

-- Loop for Auto 1st Generation Leveling
task.spawn(function()
    local validTitles = {
        ["1st Generation"] = true,
        ["1st Gen"] = true,
        ["First Generation"] = true
    }
    while task.wait(0.5) do
        if auto1stGenLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List
            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and validTitles[titleObj.Text] == true then
                        -- Skip Halloween bags
                        if titleObj.Text ~= "Common Halloween Bag" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Leveling_Items",
                                    ["Bench_Name"] = "1st_Gen_Leveling",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)

    

-- Auto 2nd Generation Leveling Toggle
LevelUp:AddToggle("Auto2ndGenLevelingToggle", {
    Text = "Auto 2nd Gen Leveling",
    Default = config.Auto2ndGenLevelingToggle or false,
    Tooltip = "Automatically levels up equipped 2nd Generation items.",
    Callback = function(Value)
        auto2ndGenLevelingEnabled = Value
        config.Auto2ndGenLevelingToggle = Value
    end
})

-- Loop for Auto 2nd Generation Leveling
task.spawn(function()
    local validTitles = {
        ["2nd Generation"] = true,
        ["2nd Gen"] = true,
        ["Second Generation"] = true
    }
    while task.wait(0.5) do
        if auto2ndGenLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List
            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and validTitles[titleObj.Text] == true then
                        -- Skip Halloween bags
                        if titleObj.Text ~= "Common Halloween Bag" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Leveling_Items",
                                    ["Bench_Name"] = "2nd_Gen_Leveling",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)


        -- Auto 3rd Generation Leveling Toggle

LevelUp:AddToggle("Auto3rdGenLevelingToggle", {
    Text = "Auto 3rd Gen Leveling",
    Default = config.Auto3rdGenLevelingToggle or false,
    Tooltip = "Automatically levels up equipped 3rd Generation items.",
    Callback = function(Value)
        auto3rdGenLevelingEnabled = Value
        config.Auto3rdGenLevelingToggle = Value
    end
})

-- Loop for Auto 3rd Generation Leveling
task.spawn(function()
    local validTitles = {
        ["3rd Generation"] = true,
        ["3rd Gen"] = true,
        ["Third Generation"] = true
    }
    while task.wait(0.5) do
        if auto3rdGenLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List
            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and validTitles[titleObj.Text] == true then
                        -- Skip Halloween bags
                        if titleObj.Text ~= "Common Halloween Bag" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Leveling_Items",
                                    ["Bench_Name"] = "3rd_Gen_Leveling",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Hybrid Leveling Toggle
LevelUp:AddToggle("AutoHybridLevelingToggle", {
    Text = "Auto Hybrid Leveling",
    Default = config.AutoHybridLevelingToggle or false,
    Tooltip = "Automatically levels up equipped Hybrid items.",
    Callback = function(Value)
        autoHybridLevelingEnabled = Value
        config.AutoHybridLevelingToggle = Value
    end
})

-- Loop for Auto Hybrid Leveling
task.spawn(function()
    local validTitles = {
        ["Hybrid"] = true,
        ["Hybrid Gen"] = true,
        ["Hybrid Generation"] = true
    }
    while task.wait(0.5) do
        if autoHybridLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List
            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and validTitles[titleObj.Text] == true then
                        -- Skip Halloween bags
                        if titleObj.Text ~= "Common Halloween Bag" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Leveling_Items",
                                    ["Bench_Name"] = "Hybrid_Leveling",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Hybrid Leveling Toggle
LevelUp:AddToggle("AutoAdollaLevelingToggle", {
    Text = "Auto Adolla Leveling",
    Default = config.AutoAdollaLevelingToggle or false,
    Tooltip = "Automatically levels up equipped Adolla items.",
    Callback = function(Value)
        autoAdollaLevelingEnabled = Value
        config.AutoAdollaLevelingToggle = Value
    end
})

-- Loop for Auto Hybrid Leveling
task.spawn(function()
    local validTitles = {
        ["Adolla User"] = true
    }
    while task.wait(0.5) do
        if autoAdollaLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List
            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and validTitles[titleObj.Text] == true then
                        -- Skip Halloween bags
                        if titleObj.Text ~= "Common Halloween Bag" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Leveling_Items",
                                    ["Bench_Name"] = "Adolla_Leveling",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Hybrid Leveling Toggle
LevelUp:AddToggle("AutoDragonRaceLevelingToggle", {
    Text = "Auto Dragon Race Leveling",
    Default = config.AutoDragonRaceLevelingToggle or false,
    Tooltip = "Automatically levels up equipped Dragon Race items.",
    Callback = function(Value)
        autoDragonRaceLevelingEnabled = Value
        config.AutoDragonRaceLevelingToggle = Value
    end
})

-- Loop for Auto Hybrid Leveling
task.spawn(function()
    local validTitles = {
        ["Saiyan"] = true,
        ["Half-Saiyan"] = true,
    }
    while task.wait(0.5) do
        if autoDragonRaceLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List
            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and validTitles[titleObj.Text] == true then
                        -- Skip Halloween bags
                        if titleObj.Text ~= "Common Halloween Bag" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Leveling_Items",
                                    ["Bench_Name"] = "Dragon_Race_Leveling",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Hybrid Leveling Toggle
LevelUp:AddToggle("AutoSaiyanEvolutionLevelingToggle", {
    Text = "Auto Saiyan Evolution Leveling",
    Default = config.AutoSaiyanEvolutionLevelingToggle or false,
    Tooltip = "Automatically levels up equipped Saiyan Evolution items.",
    Callback = function(Value)
        autoSaiyanEvolutionLevelingEnabled = Value
        config.AutoSaiyanEvolutionLevelingToggle = Value
    end
})

-- Loop for Auto Hybrid Leveling
task.spawn(function()
    local validTitles = {
        ["Super Saiyan 2"] = true,
        ["Super Saiyan 3"] = true,
    }
    while task.wait(0.5) do
        if autoSaiyanEvolutionLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List
            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and validTitles[titleObj.Text] == true then
                        -- Skip Halloween bags
                        if titleObj.Text ~= "Common Halloween Bag" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Leveling_Items",
                                    ["Bench_Name"] = "Saiyan_Evolution_Leveling",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Hybrid Leveling Toggle
LevelUp:AddToggle("AutoEternalDragonLevelingToggle", {
    Text = "Auto Eternal Dragon Leveling",
    Default = config.AutoEternalDragonLevelingToggle or false,
    Tooltip = "Automatically levels up equipped Eternal Dragon items.",
    Callback = function(Value)
        autoEternalDragonLevelingEnabled = Value
        config.AutoEternalDragonLevelingToggle = Value
    end
})

-- Loop for Auto Hybrid Leveling
task.spawn(function()
    local validTitles = {
        ["Eternal Dragon"] = true,
    }
    while task.wait(0.5) do
        if autoEternalDragonLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List
            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and validTitles[titleObj.Text] == true then
                        -- Skip Halloween bags
                        if titleObj.Text ~= "Common Halloween Bag" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Leveling_Items",
                                    ["Bench_Name"] = "Eternal_Dragon_Leveling",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)
----==========================Event========================----
-- Auto enter Halloween Raid toggle
HalloweenEvent:AddToggle(
    "AutoEnterHalloweenRaidToggle",
    {
        Text = "Auto Enter Halloween Raid",
        Default = config.AutoEnterHalloweenRaidToggle or false,
        Tooltip = "Automatically enters Halloween Raid when not in dungeon.",
        Callback = function(Value)
            autoEnterHalloweenRaidEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterHalloweenRaidConnection then autoEnterHalloweenRaidConnection:Disconnect() end
                autoEnterHalloweenRaidConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")

                    local titleText = (title and title.Text) or ""
                    if not (header and header.Visible and title and (string.find(titleText, "Halloween") or string.find(titleText, "Graveyard"))) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Halloween_Raid"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterHalloweenRaidConnection then
                    autoEnterHalloweenRaidConnection:Disconnect()
                    autoEnterHalloweenRaidConnection = nil
                end
            end
        end
    }
)

HalloweenEvent:AddDivider()
local halloweenProductIds = {
    "Spooky Coins Potion",
    "Spooky Damage Potion",
    "Spooky Energy Potion",
    "Spooky Luck Potion",
    "Spooky Exp Potion",
    "Spooky Soul Potion",
    "Spooky Shadow Soul Potion",
    -- newly added products (IDs correspond to keys in halloweenCraftingSelected)
    "Spooky Coins Potion 2",
    "Spooky Damage Potion 2",
    "Spooky Energy Potion 2",
    "Spooky Luck Potion 2",
    "Spooky Exp Potion 2",
    "Spooky Soul Potion 2",
    "Spooky Shadow Soul Potion 2",
    "Yellow Ghost = Halloween Eyeball",
    "Red Ghost = Halloween Eyeball",
    "Blue Ghost = Halloween Eyeball",
    "Green Ghost = Halloween Eyeball",
    "Pink Ghost = Halloween Eyeball",
    "Orange Ghost = Halloween Eyeball",
    "Purple Ghost = Halloween Eyeball",
}
local halloweenProductIdMap = {
    ["Spooky Coins Potion"] = "1",
    ["Spooky Damage Potion"] = "2",
    ["Spooky Energy Potion"] = "3",
    ["Spooky Luck Potion"] = "4",
    ["Spooky Exp Potion"] = "5",
    ["Spooky Soul Potion"] = "6",
    ["Spooky Shadow Soul Potion"] = "7",
    ["Spooky Coins Potion 2"] = "8",
    ["Spooky Damage Potion 2"] = "9",
    ["Spooky Energy Potion 2"] = "10",
    ["Spooky Luck Potion 2"] = "11",
    ["Spooky Exp Potion 2"] = "12",
    ["Spooky Soul Potion 2"] = "13",
    ["Spooky Shadow Soul Potion 2"] = "14",
    ["Yellow Ghost = Halloween Eyeball"] = "16",
    ["Red Ghost = Halloween Eyeball"] = "17",
    ["Blue Ghost = Halloween Eyeball"] = "18",
    ["Green Ghost = Halloween Eyeball"] = "19",
    ["Pink Ghost = Halloween Eyeball"] = "20",
    ["Orange Ghost = Halloween Eyeball"] = "21",
    ["Purple Ghost = Halloween Eyeball"] = "22",
}
local selectedHalloweenProductName = "Spooky Coins Potion"
local selectedHalloweenProductId = "1"

-- Table mapping Product_Id to correct Selected array
local halloweenCraftingSelected = {
    [1] = {
        {
            Completed = true, Found = 92, Required = 1, Amount = -1, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 140, Required = 100, Amount = -100, Id = "Yellow_Bone",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9053, Sell_Rewards = {}, Equip_Slots = {}, Name = "Yellow_Bone", Category = "Resources", ImageId = "rbxassetid://139139269703796", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9053"}
        },
        {
            Completed = true, Found = 8778.7, Required = 500, Amount = -500, Id = "Halloween_Candy",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9051, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113, Skills = {}, SortWith = "Tokens", Name = "Halloween_Candy", Category = "Resources", ImageId = "rbxassetid://108948106232204", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9051"}
        }
    },
    [2] = {
        {
            Completed = true, Found = 91, Required = 1, Amount = -1, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 294, Required = 100, Amount = -100, Id = "Red_Bone",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9054, Sell_Rewards = {}, Equip_Slots = {}, Name = "Red_Bone", Category = "Resources", ImageId = "rbxassetid://123358065241772", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9054"}
        },
        {
            Completed = true, Found = 8278.7, Required = 500, Amount = -500, Id = "Halloween_Candy",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9051, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113, Skills = {}, SortWith = "Tokens", Name = "Halloween_Candy", Category = "Resources", ImageId = "rbxassetid://108948106232204", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9051"}
        }
    },
    [3] = {
        {
            Completed = true, Found = 90, Required = 1, Amount = -1, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 291, Required = 100, Amount = -100, Id = "Blue_Bone",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9055, Sell_Rewards = {}, Equip_Slots = {}, Name = "Blue_Bone", Category = "Resources", ImageId = "rbxassetid://126421297474584", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9055"}
        },
        {
            Completed = true, Found = 7778.7, Required = 500, Amount = -500, Id = "Halloween_Candy",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9051, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113, Skills = {}, SortWith = "Tokens", Name = "Halloween_Candy", Category = "Resources", ImageId = "rbxassetid://108948106232204", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9051"}
        }
    },
    [4] = {
        {
            Completed = true, Found = 87, Required = 1, Amount = -1, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 277, Required = 100, Amount = -100, Id = "Green_Bone",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9056, Sell_Rewards = {}, Equip_Slots = {}, Name = "Green_Bone", Category = "Resources", ImageId = "rbxassetid://116347553314061", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9056"}
        },
        {
            Completed = true, Found = 6778.7, Required = 500, Amount = -500, Id = "Halloween_Candy",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9051, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113, Skills = {}, SortWith = "Tokens", Name = "Halloween_Candy", Category = "Resources", ImageId = "rbxassetid://108948106232204", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9051"}
        }
    },
    [5] = {
        {
            Completed = true, Found = 86, Required = 1, Amount = -1, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 281, Required = 100, Amount = -100, Id = "Pink_Bone",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9057, Sell_Rewards = {}, Equip_Slots = {}, Name = "Pink_Bone", Category = "Resources", ImageId = "rbxassetid://89858508043540", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9057"}
        },
        {
            Completed = true, Found = 6278.7, Required = 500, Amount = -500, Id = "Halloween_Candy",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9051, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113, Skills = {}, SortWith = "Tokens", Name = "Halloween_Candy", Category = "Resources", ImageId = "rbxassetid://108948106232204", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9051"}
        }
    },
    [6] = {
        {
            Completed = true, Found = 85, Required = 1, Amount = -1, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 292, Required = 100, Amount = -100, Id = "Orange_Bone",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9058, Sell_Rewards = {}, Equip_Slots = {}, Name = "Orange_Bone", Category = "Resources", ImageId = "rbxassetid://118191791346525", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9058"}
        },
        {
            Completed = true, Found = 5778.7, Required = 500, Amount = -500, Id = "Halloween_Candy",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9051, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113, Skills = {}, SortWith = "Tokens", Name = "Halloween_Candy", Category = "Resources", ImageId = "rbxassetid://108948106232204", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9051"}
        }
    },
    [7] = {
        {
            Completed = true, Found = 84, Required = 1, Amount = -1, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 315, Required = 100, Amount = -100, Id = "Purple_Bone",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9059, Sell_Rewards = {}, Equip_Slots = {}, Name = "Purple_Bone", Category = "Resources", ImageId = "rbxassetid://120326515141525", Skills = {}, Is_Stat_Exist = {}, Description = "Used to craft Spooky Potions."
            },
            List = {"9059"}
        },
        {
            Completed = true, Found = 5278.7, Required = 500, Amount = -500, Id = "Halloween_Candy",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9051, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113, Skills = {}, SortWith = "Tokens", Name = "Halloween_Candy", Category = "Resources", ImageId = "rbxassetid://108948106232204", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9051"}
        }
    },
    [8] = {
        {
            Completed = true, Found = 470, Required = 10, Amount = -10, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, SortWith = "Materials",
                Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Description = "Used to craft Spooky Potions.", Is_Stat_Exist = {}
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 212, Required = 200, Amount = -200, Id = "Yellow_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9062, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Yellow_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://111979708881983", Is_Stat_Exist = {}
            },
            List = {"9062"}
        },
        {
            Completed = true, Found = 1361.7, Required = 1000, Amount = -1000, Id = "Halloween_Eyeball",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9060, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113,
                Skills = {}, SortWith = "Tokens", Name = "Halloween_Eyeball", Category = "Resources", ImageId = "rbxassetid://96989976757873", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9060"}
        }
    },
    [9] = {
        {
            Completed = true, Found = 745, Required = 10, Amount = -10, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, SortWith = "Materials",
                Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Description = "Used to craft Spooky Potions.", Is_Stat_Exist = {}
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 744, Required = 200, Amount = -200, Id = "Red_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9063, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Red_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://80284615384314", Is_Stat_Exist = {}
            },
            List = {"9063"}
        },
        {
            Completed = true, Found = 19524.4, Required = 1000, Amount = -1000, Id = "Halloween_Eyeball",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9060, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113,
                Skills = {}, SortWith = "Tokens", Name = "Halloween_Eyeball", Category = "Resources", ImageId = "rbxassetid://96989976757873", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9060"}
        }
    },
    [10] = {
        {
            Completed = true, Found = 735, Required = 10, Amount = -10, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, SortWith = "Materials",
                Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Description = "Used to craft Spooky Potions.", Is_Stat_Exist = {}
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 770, Required = 200, Amount = -200, Id = "Blue_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9064, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Blue_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://127653885520280", Is_Stat_Exist = {}
            },
            List = {"9064"}
        },
        {
            Completed = true, Found = 18524.4, Required = 1000, Amount = -1000, Id = "Halloween_Eyeball",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9060, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113,
                Skills = {}, SortWith = "Tokens", Name = "Halloween_Eyeball", Category = "Resources", ImageId = "rbxassetid://96989976757873", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9060"}
        }
    },
    [11] = {
        {
            Completed = true, Found = 725, Required = 10, Amount = -10, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, SortWith = "Materials",
                Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Description = "Used to craft Spooky Potions.", Is_Stat_Exist = {}
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 774, Required = 200, Amount = -200, Id = "Green_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9065, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Green_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://77978137176827", Is_Stat_Exist = {}
            },
            List = {"9065"}
        },
        {
            Completed = true, Found = 17524.4, Required = 1000, Amount = -1000, Id = "Halloween_Eyeball",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9060, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113,
                Skills = {}, SortWith = "Tokens", Name = "Halloween_Eyeball", Category = "Resources", ImageId = "rbxassetid://96989976757873", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9060"}
        }
    },
    [12] = {
        {
            Completed = true, Found = 715, Required = 10, Amount = -10, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, SortWith = "Materials",
                Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Description = "Used to craft Spooky Potions.", Is_Stat_Exist = {}
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 791, Required = 200, Amount = -200, Id = "Pink_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9066, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Pink_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://138383473880731", Is_Stat_Exist = {}
            },
            List = {"9066"}
        },
        {
            Completed = true, Found = 16524.4, Required = 1000, Amount = -1000, Id = "Halloween_Eyeball",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9060, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113,
                Skills = {}, SortWith = "Tokens", Name = "Halloween_Eyeball", Category = "Resources", ImageId = "rbxassetid://96989976757873", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9060"}
        }
    },
    [13] = {
        {
            Completed = true, Found = 705, Required = 10, Amount = -10, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, SortWith = "Materials",
                Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Description = "Used to craft Spooky Potions.", Is_Stat_Exist = {}
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 761, Required = 200, Amount = -200, Id = "Orange_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9067, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Orange_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://87514108731936", Is_Stat_Exist = {}
            },
            List = {"9067"}
        },
        {
            Completed = true, Found = 15524.4, Required = 1000, Amount = -1000, Id = "Halloween_Eyeball",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9060, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113,
                Skills = {}, SortWith = "Tokens", Name = "Halloween_Eyeball", Category = "Resources", ImageId = "rbxassetid://96989976757873", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9060"}
        }
    },
    [14] = {
        {
            Completed = true, Found = 695, Required = 10, Amount = -10, Id = "Spooky_Empty_Flask",
            db_item = {
                Stats = {}, Rarity = 113, Maximum = 1e32, Id = 9052, Sell_Rewards = {}, Equip_Slots = {}, SortWith = "Materials",
                Name = "Spooky_Empty_Flask", Category = "Resources", ImageId = "rbxassetid://106235404427016", Skills = {}, Description = "Used to craft Spooky Potions.", Is_Stat_Exist = {}
            },
            List = {"9052"}
        },
        {
            Completed = true, Found = 797, Required = 200, Amount = -200, Id = "Purple_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9068, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Purple_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://125928039569290", Is_Stat_Exist = {}
            },
            List = {"9068"}
        },
        {
            Completed = true, Found = 14524.4, Required = 1000, Amount = -1000, Id = "Halloween_Eyeball",
            db_item = {
                Type = "Token", Stats = {}, Description = "Halloween Currency.", Maximum = 1e32, Id = 9060, Is_Stat_Exist = {}, Equip_Slots = {}, Rarity = 113,
                Skills = {}, SortWith = "Tokens", Name = "Halloween_Eyeball", Category = "Resources", ImageId = "rbxassetid://96989976757873", Is_Decimal = true, Sell_Rewards = {}, Drop_Type = "Token"
            },
            List = {"9060"}
        }
    },
    [16] = {
        {
            Completed = true, Found = 580, Required = 500, Amount = -500, Id = "Yellow_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9062, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Yellow_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://111979708881983", Is_Stat_Exist = {}
            },
            List = {"9062"}
        }
    },
    [17] = {
        {
            Completed = true, Found = 544, Required = 500, Amount = -500, Id = "Red_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9063, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Red_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://80284615384314", Is_Stat_Exist = {}
            },
            List = {"9063"}
        }
    },
    [18] = {
        {
            Completed = true, Found = 570, Required = 500, Amount = -500, Id = "Blue_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9064, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Blue_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://127653885520280", Is_Stat_Exist = {}
            },
            List = {"9064"}
        }
    },
    [19] = {
        {
            Completed = true, Found = 574, Required = 500, Amount = -500, Id = "Green_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9065, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Green_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://77978137176827", Is_Stat_Exist = {}
            },
            List = {"9065"}
        }
    },
    [20] = {
        {
            Completed = true, Found = 591, Required = 500, Amount = -500, Id = "Pink_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9066, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Pink_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://138383473880731", Is_Stat_Exist = {}
            },
            List = {"9066"}
        }
    },
    [21] = {
        {
            Completed = true, Found = 561, Required = 500, Amount = -500, Id = "Orange_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9067, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Orange_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://87514108731936", Is_Stat_Exist = {}
            },
            List = {"9067"}
        }
    },
    [22] = {
        {
            Completed = true, Found = 597, Required = 500, Amount = -500, Id = "Purple_Ghost",
            db_item = {
                Stats = {}, Description = "Used to craft Spooky Potions.", Maximum = 1e32, Id = 9068, Sell_Rewards = {}, Equip_Slots = {}, Type = "Materials",
                Rarity = 113, Name = "Purple_Ghost", Category = "Resources", SortWith = "Materials", Skills = {}, ImageId = "rbxassetid://125928039569290", Is_Stat_Exist = {}
            },
            List = {"9068"}
        }
    },
}

HalloweenEvent:AddDropdown("HalloweenProductDropdown", {
    Values = halloweenProductIds,
    Default = "Spooky Coins Potion",
    Multi = false,
    Text = "Select Halloween Potion",
    Tooltip = "Choose which Halloween potion to craft.",
    Callback = function(Value)
        selectedHalloweenProductName = Value
        selectedHalloweenProductId = halloweenProductIdMap[Value]
    end
})

HalloweenEvent:AddButton("Craft Halloween Potion", function()
    local pid = tonumber(selectedHalloweenProductId)
    local selected = halloweenCraftingSelected[pid]
    if not selected then
        return
    end
    local args = {
        [1] = {
            ["Crafting_Name"] = "Halloween_Crafting",
            ["Product_Id"] = pid,
            ["Action"] = "Crafting",
            ["Selected"] = selected
        }
    }
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
    end)
end)


HalloweenEvent:AddDivider()

-- Auto Halloween Bag Leveling Toggle
HalloweenEvent:AddToggle(
    "HalloweenBagLevelingToggle",
    {
        Text = "Halloween Bag Leveling",
        Default = config.HalloweenBagLevelingToggle or false,
        Tooltip = "Automatically levels up equipped Halloween Bags.",
        Callback = function(Value)
            HalloweenBagLevelingEnabled = Value
            config.HalloweenBagLevelingToggle = Value
        end
    }
)

-- Auto Rare Halloween Bag Leveling Toggle
HalloweenEvent:AddToggle(
    "RareHalloweenBagLevelingToggle",
    {
        Text = "Rare Halloween Bag Leveling",
        Default = config.RareHalloweenBagLevelingToggle or false,
        Tooltip = "Automatically levels up equipped Rare Halloween Bags.",
        Callback = function(Value)
            RareHalloweenBagLevelingEnabled = Value
            config.RareHalloweenBagLevelingToggle = Value
        end
    }
)

-- Auto Legendary Halloween Bag Leveling Toggle
HalloweenEvent:AddToggle(
    "LegendaryHalloweenBagLevelingToggle",
    {
        Text = "Legendary Halloween Bag Leveling",
        Default = config.LegendaryHalloweenBagLevelingToggle or false,
        Tooltip = "Automatically levels up equipped Legendary Halloween Bags.",
        Callback = function(Value)
            LegendaryHalloweenBagLevelingEnabled = Value
            config.LegendaryHalloweenBagLevelingToggle = Value
        end
    }
)

-- Auto Mythical Halloween Bag Leveling Toggle (Level 4)
HalloweenEvent:AddToggle(
    "MythicalHalloweenBagLevelingToggle",
    {
        Text = "Mythical Halloween Bag Leveling",
        Default = config.MythicalHalloweenBagLevelingToggle or false,
        Tooltip = "Automatically levels up equipped Mythical Halloween Bags.",
        Callback = function(Value)
            MythicalHalloweenBagLevelingEnabled = Value
            config.MythicalHalloweenBagLevelingToggle = Value
        end
    }
)

-- Auto Phantom Halloween Bag Leveling Toggle (Level 5)
HalloweenEvent:AddToggle(
    "PhantomHalloweenBagLevelingToggle",
    {
        Text = "Phantom Halloween Bag Leveling",
        Default = config.PhantomHalloweenBagLevelingToggle or false,
        Tooltip = "Automatically levels up equipped Phantom Halloween Bags.",
        Callback = function(Value)
            PhantomHalloweenBagLevelingEnabled = Value
            config.PhantomHalloweenBagLevelingToggle = Value
        end
    }
)

HalloweenEvent:AddToggle(
    "SupremeHalloweenBagLevelingToggle",
    {
        Text = "Supreme Halloween Bag Leveling",
        Default = config.SupremeHalloweenBagLevelingToggle or false,
        Tooltip = "Automatically levels up equipped Supreme Halloween Bags.",
        Callback = function(Value)
            SupremeHalloweenBagLevelingEnabled = Value
            config.SupremeHalloweenBagLevelingToggle = Value
        end
    }
)

-- Loop for Halloween Bag Leveling
task.spawn(function()
    while task.wait(0.5) do
        if HalloweenBagLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Common Halloween Bag" then
                        -- Only upgrade Halloween bags, never Kagune
                        local uniqueId = item.Name
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Level",
                                ["UniqueId"] = uniqueId,
                                ["Action"] = "Prog_Lv_Items",
                                ["Bench_Name"] = "Halloween_Leveling_1",
                            }
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

-- Loop for Rare Halloween Bag Leveling
task.spawn(function()
    while task.wait(0.5) do
        if RareHalloweenBagLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Rare Halloween Bag" then
                        local uniqueId = item.Name
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Level",
                                ["UniqueId"] = uniqueId,
                                ["Action"] = "Prog_Lv_Items",
                                ["Bench_Name"] = "Halloween_Leveling_2",
                            }
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

-- Loop for Legendary Halloween Bag Leveling
task.spawn(function()
    while task.wait(0.5) do
        if LegendaryHalloweenBagLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Legendary Halloween Bag" then
                        local uniqueId = item.Name
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Level",
                                ["UniqueId"] = uniqueId,
                                ["Action"] = "Prog_Lv_Items",
                                ["Bench_Name"] = "Halloween_Leveling_3",
                            }
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

-- Loop for Mythical (Level 4) Halloween Bag Leveling
task.spawn(function()
    while task.wait(0.5) do
        if MythicalHalloweenBagLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Mythical Halloween Bag" then
                        local uniqueId = item.Name
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Level",
                                ["UniqueId"] = uniqueId,
                                ["Action"] = "Prog_Lv_Items",
                                ["Bench_Name"] = "Halloween_Leveling_4",
                            }
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

-- Loop for Phantom (Level 5) Halloween Bag Leveling
task.spawn(function()
    while task.wait(0.5) do
        if PhantomHalloweenBagLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Phantom Halloween Bag" then
                        local uniqueId = item.Name
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Level",
                                ["UniqueId"] = uniqueId,
                                ["Action"] = "Prog_Lv_Items",
                                ["Bench_Name"] = "Halloween_Leveling_5",
                            }
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if SupremeHalloweenBagLevelingEnabled then
            local list = game:GetService("Players").LocalPlayer.PlayerGui
                .Inventory_1.Hub.Powers.List_Frame.List

            for _, item in pairs(list:GetChildren()) do
                local inside = item:FindFirstChild("Inside")
                if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                    local titleObj = inside:FindFirstChild("Title")
                    if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Supreme Halloween Bag" then
                        local uniqueId = item.Name
                        local args = {
                            [1] = {
                                ["Upgrade_Name"] = "Level",
                                ["UniqueId"] = uniqueId,
                                ["Action"] = "Prog_Lv_Items",
                                ["Bench_Name"] = "Halloween_Leveling_6",
                            }
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

HalloweenEvent:AddDivider()
HalloweenEvent:AddToggle(
    "AutoRollHalloweenGachaToggle",
    {
        Text = "Halloween Gacha",
        Default = config.AutoRollHalloweenGachaToggle or false,
        Tooltip = "Automatically unlocks and rolls Halloween Gacha.",
        Callback = function(Value)
            autoRollHalloweenGachaEnabled = Value
            if Value then
                task.spawn(function()
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Halloween_Gacha_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(args)) end)
                    task.wait(0.5)
                    while autoRollHalloweenGachaEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Halloween_Gacha"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    }
)
-- Auto enter Halloween Defense toggle
HalloweenEvent2:AddToggle(
    "AutoEnterGraveyardDefenseToggle",
    {
        Text = "Auto Enter Graveyard Defense",
        Default = config.AutoEnterGraveyardDefenseToggle or false,
        Tooltip = "Automatically enters Graveyard Defense when not in dungeon.",
        Callback = function(Value)
            autoEnterGraveyardDefenseEnabled = Value
            -- SaveManager automatically saves this toggle's value
            if Value then
                if autoEnterGraveyardDefenseConnection then autoEnterGraveyardDefenseConnection:Disconnect() end
                autoEnterGraveyardDefenseConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local playerGui = player:FindFirstChild("PlayerGui")
                    local dungeonGui = playerGui and playerGui:FindFirstChild("Dungeon")
                    local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                    local title = header and header:FindFirstChild("Main") and header.Main:FindFirstChild("Main") and header.Main.Main:FindFirstChild("Title")

                    if not (header and header.Visible and title and string.find(title.Text or "", "Graveyard Defense")) then
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = "Graveyard_Defense"
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                    end
                    task.wait(3)
                end)
            else
                if autoEnterHalloweenDefenseConnection then
                    autoEnterHalloweenDefenseConnection:Disconnect()
                    autoEnterHalloweenDefenseConnection = nil
                end
            end
        end
    }
)

-- Teleport button: send player to Halloween event world
HalloweenEvent2:AddButton("Teleport To Halloween Event", function()
    local args = {
        [1] = {
            ["Location"] = "Halloween_Event_World";
            ["Type"] = "Map";
            ["Action"] = "Teleport";
        };
    }
    pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Events", 9e9)
            :WaitForChild("To_Server", 9e9)
            :FireServer(unpack(args))
    end)
end)

HalloweenEvent2:AddDivider()
local selectedHalloweenShopProductId = 1 -- keep selected id in outer scope for the auto-buy toggle

do
    -- scoped helpers and dropdown object (won't leak to outer scope)
    local halloweenShopProductIds = {
        ["Candy X500 = Key"] = 1, ["Credit X50 = Key"] = 2, ["Candy X100 = Token X10"] = 3, ["Empty Flask X5 = Token X1"] = 4, ["Yellow Bone X20 = Token X10"] = 5, ["Red Bone X20 = Token X10"] = 6, ["Blue Bone X20 = Token X10"] = 7, ["Green Bone X20 = Token X10"] = 8, ["Pink Bone X20 = Token X10"] = 9, ["Orange Bone X20 = Token X10"] = 10, ["Purple Bone X20 = Token X10"] = 11, ["Eyeball X50 = Token x10"] = 12, ["Yellow Ghost x10 = Token x20 "] = 13, ["Red Ghost x10 = Token x20 "] = 14, ["Blue Ghost x10 = Token x20 "] = 15, ["Green Ghost x10 = Token x20 "] = 16, ["Pink Ghost x10 = Token x20 "] = 17, ["Orange Ghost x10 = Token x20 "] = 18, ["Purple Ghost x10 = Token x20 "] = 19, ["Zombie Head = Token x200"] = 20, ["Zombie Torso = Token x200"] = 21, ["Zombie LeftArm = Token x200"] = 22, ["Zombie RightArm = Token x200"] = 23, ["Zombie LeftLeg = Token x200"] = 24, ["Zombie Rightleg = Token x200"] = 25,
        ["Yellow Ghost x10 = Token x10 "] = 26, ["Red Ghost x10 = Token x10 "] = 27, ["Blue Ghost x10 = Token x10 "] = 28, ["Green Ghost x10 = Token x10 "] = 29, ["Pink Ghost x10 = Token x10 "] = 30, ["Orange Ghost x10 = Token x10 "] = 31, ["Purple Ghost x10 = Token x10 "] = 32, ["Zombie Head = Token x100"] = 33, ["Zombie Torso = Token x100"] = 34, ["Zombie LeftArm = Token x100"] = 35, ["Zombie RightArm = Token x100"] = 36, ["Zombie LeftLeg = Token x100"] = 37, ["Zombie Rightleg = Token x100"] = 38
    }

    local shopDropdown = HalloweenEvent2:AddDropdown("HalloweenShopProductDropdown", {
        Text = "Select Halloween Shop Item",
        Values = {"Candy X500 = Key","Credit X50 = Key","Candy X100 = Token X10","Empty Flask X5 = Token X1","Yellow Bone X20 = Token X10","Red Bone X20 = Token X10","Blue Bone X20 = Token X10","Green Bone X20 = Token X10","Pink Bone X20 = Token X10","Orange Bone X20 = Token X10","Purple Bone X20 = Token X10","Eyeball X50 = Token x10","Yellow Ghost x10 = Token x20 ","Red Ghost x10 = Token x20 ","Blue Ghost x10 = Token x20 ","Green Ghost x10 = Token x20 ","Pink Ghost x10 = Token x20 ","Orange Ghost x10 = Token x20 ","Purple Ghost x10 = Token x20 ","Zombie Head = Token x200","Zombie Torso = Token x200","Zombie LeftArm = Token x200","Zombie RightArm = Token x200","Zombie LeftLeg = Token x200","Zombie Rightleg = Token x200","Yellow Ghost x10 = Token x10 ","Red Ghost x10 = Token x10 ","Blue Ghost x10 = Token x10 ","Green Ghost x10 = Token x10 ","Pink Ghost x10 = Token x10 ","Orange Ghost x10 = Token x10 ","Purple Ghost x10 = Token x10 ","Zombie Head = Token x100","Zombie Torso = Token x100","Zombie LeftArm = Token x100","Zombie RightArm = Token x100","Zombie LeftLeg = Token x100","Zombie Rightleg = Token x100"},
        Default = 1, -- index, not string
        Multi = false,
        Tooltip = "Choose which item to buy from the Halloween Shop.",
        Callback = function(Value)
            selectedHalloweenShopProductId = halloweenShopProductIds[Value] or 1
        end
    })
end

-- Toggle: Auto-buy selected Halloween shop item while enabled
HalloweenEvent2:AddToggle("AutoBuyHalloweenShopToggle", {
    Text = "Auto Buy Halloween Shop Item",
    Default = config.AutoBuyHalloweenShopToggle or false,
    Tooltip = "Continuously buys the selected Halloween shop item while enabled.",
    Callback = function(Value)
        autoBuyHalloweenShopEnabled = Value
        config.AutoBuyHalloweenShopToggle = Value
        if Value then
            task.spawn(function()
                while autoBuyHalloweenShopEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Amount"] = 1,
                            ["Product_Id"] = selectedHalloweenShopProductId,
                            ["Action"] = "Merchant_Purchase",
                            ["Bench_Name"] = "Halloween_Shop",
                        }
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

HalloweenEvent2:AddDivider()

    -- Auto Halloween Ghost Leveling Toggle (Common)
    HalloweenEvent2:AddToggle(
        "HalloweenGhostLevelingToggle",
        {
            Text = "Halloween Ghost Leveling",
            Default = config.HalloweenGhostLevelingToggle or false,
            Tooltip = "Automatically levels up equipped Halloween Ghosts.",
            Callback = function(Value)
                HalloweenGhostLevelingEnabled = Value
                config.HalloweenGhostLevelingToggle = Value
            end
        }
    )

    -- Auto Uncommon Halloween Ghost Leveling Toggle
    HalloweenEvent2:AddToggle(
        "UncommonHalloweenGhostLevelingToggle",
        {
            Text = "Uncommon Halloween Ghost Leveling",
            Default = config.UncommonHalloweenGhostLevelingToggle or false,
            Tooltip = "Automatically levels up equipped Uncommon Halloween Ghosts.",
            Callback = function(Value)
                UncommonHalloweenGhostLevelingEnabled = Value
                config.UncommonHalloweenGhostLevelingToggle = Value
            end
        }
    )

    -- Auto Rare Halloween Ghost Leveling Toggle
    HalloweenEvent2:AddToggle(
        "RareHalloweenGhostLevelingToggle",
        {
            Text = "Rare Halloween Ghost Leveling",
            Default = config.RareHalloweenGhostLevelingToggle or false,
            Tooltip = "Automatically levels up equipped Rare Halloween Ghosts.",
            Callback = function(Value)
                RareHalloweenGhostLevelingEnabled = Value
                config.RareHalloweenGhostLevelingToggle = Value
            end
        }
    )

    -- Auto Epic Halloween Ghost Leveling Toggle
    HalloweenEvent2:AddToggle(
        "EpicHalloweenGhostLevelingToggle",
        {
            Text = "Epic Halloween Ghost Leveling",
            Default = config.EpicHalloweenGhostLevelingToggle or false,
            Tooltip = "Automatically levels up equipped Epic Halloween Ghosts.",
            Callback = function(Value)
                EpicHalloweenGhostLevelingEnabled = Value
                config.EpicHalloweenGhostLevelingToggle = Value
            end
        }
    )

    -- Loop for Halloween Ghost Leveling (Common)
    task.spawn(function()
        while task.wait(0.5) do
            if HalloweenGhostLevelingEnabled then
                local list = game:GetService("Players").LocalPlayer.PlayerGui
                    .Inventory_1.Hub.Powers.List_Frame.List

                for _, item in pairs(list:GetChildren()) do
                    local inside = item:FindFirstChild("Inside")
                    if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                        local titleObj = inside:FindFirstChild("Title")
                        if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Common Halloween Ghost" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["Upgrade_Name"] = "Level",
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Prog_Lv_Items",
                                    ["Bench_Name"] = "Ghost_Leveling_1",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)

    -- Loop for Uncommon Halloween Ghost Leveling
    task.spawn(function()
        while task.wait(0.5) do
            if UncommonHalloweenGhostLevelingEnabled then
                local list = game:GetService("Players").LocalPlayer.PlayerGui
                    .Inventory_1.Hub.Powers.List_Frame.List

                for _, item in pairs(list:GetChildren()) do
                    local inside = item:FindFirstChild("Inside")
                    if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                        local titleObj = inside:FindFirstChild("Title")
                        if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Uncommon Halloween Ghost" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["Upgrade_Name"] = "Level",
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Prog_Lv_Items",
                                    ["Bench_Name"] = "Ghost_Leveling_2",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)

    -- Loop for Rare Halloween Ghost Leveling
    task.spawn(function()
        while task.wait(0.5) do
            if RareHalloweenGhostLevelingEnabled then
                local list = game:GetService("Players").LocalPlayer.PlayerGui
                    .Inventory_1.Hub.Powers.List_Frame.List

                for _, item in pairs(list:GetChildren()) do
                    local inside = item:FindFirstChild("Inside")
                    if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                        local titleObj = inside:FindFirstChild("Title")
                        if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Rare Halloween Ghost" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["Upgrade_Name"] = "Level",
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Prog_Lv_Items",
                                    ["Bench_Name"] = "Ghost_Leveling_3",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)

    -- Loop for Epic Halloween Ghost Leveling
    task.spawn(function()
        while task.wait(0.5) do
            if EpicHalloweenGhostLevelingEnabled then
                local list = game:GetService("Players").LocalPlayer.PlayerGui
                    .Inventory_1.Hub.Powers.List_Frame.List

                for _, item in pairs(list:GetChildren()) do
                    local inside = item:FindFirstChild("Inside")
                    if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                        local titleObj = inside:FindFirstChild("Title")
                        if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Epic Halloween Ghost" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["Upgrade_Name"] = "Level",
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Prog_Lv_Items",
                                    ["Bench_Name"] = "Ghost_Leveling_4",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)

    -- Additional rarities: Legendary, Mythical, Phantom, Supreme
    HalloweenEvent2:AddToggle(
        "LegendaryHalloweenGhostLevelingToggle",
        {
            Text = "Legendary Halloween Ghost Leveling",
            Default = config.LegendaryHalloweenGhostLevelingToggle or false,
            Tooltip = "Automatically levels up equipped Legendary Halloween Ghosts.",
            Callback = function(Value)
                LegendaryHalloweenGhostLevelingEnabled = Value
                config.LegendaryHalloweenGhostLevelingToggle = Value
            end
        }
    )

    HalloweenEvent2:AddToggle(
        "MythicalHalloweenGhostLevelingToggle",
        {
            Text = "Mythical Halloween Ghost Leveling",
            Default = config.MythicalHalloweenGhostLevelingToggle or false,
            Tooltip = "Automatically levels up equipped Mythical Halloween Ghosts.",
            Callback = function(Value)
                MythicalHalloweenGhostLevelingEnabled = Value
                config.MythicalHalloweenGhostLevelingToggle = Value
            end
        }
    )

    HalloweenEvent2:AddToggle(
        "PhantomHalloweenGhostLevelingToggle",
        {
            Text = "Phantom Halloween Ghost Leveling",
            Default = config.PhantomHalloweenGhostLevelingToggle or false,
            Tooltip = "Automatically levels up equipped Phantom Halloween Ghosts.",
            Callback = function(Value)
                PhantomHalloweenGhostLevelingEnabled = Value
                config.PhantomHalloweenGhostLevelingToggle = Value
            end
        }
    )

    HalloweenEvent2:AddToggle(
        "SupremeHalloweenGhostLevelingToggle",
        {
            Text = "Supreme Halloween Ghost Leveling",
            Default = config.SupremeHalloweenGhostLevelingToggle or false,
            Tooltip = "Automatically levels up equipped Supreme Halloween Ghosts.",
            Callback = function(Value)
                SupremeHalloweenGhostLevelingEnabled = Value
                config.SupremeHalloweenGhostLevelingToggle = Value
            end
        }
    )

    -- Loop for Legendary Halloween Ghost Leveling
    task.spawn(function()
        while task.wait(0.5) do
            if LegendaryHalloweenGhostLevelingEnabled then
                local list = game:GetService("Players").LocalPlayer.PlayerGui
                    .Inventory_1.Hub.Powers.List_Frame.List

                for _, item in pairs(list:GetChildren()) do
                    local inside = item:FindFirstChild("Inside")
                    if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                        local titleObj = inside:FindFirstChild("Title")
                        if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Legendary Halloween Ghost" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["Upgrade_Name"] = "Level",
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Prog_Lv_Items",
                                    ["Bench_Name"] = "Ghost_Leveling_5",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)

    -- Loop for Mythical Halloween Ghost Leveling
    task.spawn(function()
        while task.wait(0.5) do
            if MythicalHalloweenGhostLevelingEnabled then
                local list = game:GetService("Players").LocalPlayer.PlayerGui
                    .Inventory_1.Hub.Powers.List_Frame.List

                for _, item in pairs(list:GetChildren()) do
                    local inside = item:FindFirstChild("Inside")
                    if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                        local titleObj = inside:FindFirstChild("Title")
                        if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Mythical Halloween Ghost" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["Upgrade_Name"] = "Level",
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Prog_Lv_Items",
                                    ["Bench_Name"] = "Ghost_Leveling_6",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)

    -- Loop for Phantom Halloween Ghost Leveling
    task.spawn(function()
        while task.wait(0.5) do
            if PhantomHalloweenGhostLevelingEnabled then
                local list = game:GetService("Players").LocalPlayer.PlayerGui
                    .Inventory_1.Hub.Powers.List_Frame.List

                for _, item in pairs(list:GetChildren()) do
                    local inside = item:FindFirstChild("Inside")
                    if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                        local titleObj = inside:FindFirstChild("Title")
                        if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Phantom Halloween Ghost" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["Upgrade_Name"] = "Level",
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Prog_Lv_Items",
                                    ["Bench_Name"] = "Ghost_Leveling_7",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)

    -- Loop for Supreme Halloween Ghost Leveling
    task.spawn(function()
        while task.wait(0.5) do
            if SupremeHalloweenGhostLevelingEnabled then
                local list = game:GetService("Players").LocalPlayer.PlayerGui
                    .Inventory_1.Hub.Powers.List_Frame.List

                for _, item in pairs(list:GetChildren()) do
                    local inside = item:FindFirstChild("Inside")
                    if inside and inside:FindFirstChild("Equipped") and inside.Equipped.Visible then
                        local titleObj = inside:FindFirstChild("Title")
                        if titleObj and type(titleObj.Text) == "string" and titleObj.Text == "Supreme Halloween Ghost" then
                            local uniqueId = item.Name
                            local args = {
                                [1] = {
                                    ["Upgrade_Name"] = "Level",
                                    ["UniqueId"] = uniqueId,
                                    ["Action"] = "Prog_Lv_Items",
                                    ["Bench_Name"] = "Ghost_Leveling_8",
                                }
                            }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)

    HalloweenEvent2:AddDivider()
    
    -- Dropdown + Toggle: Auto Upgrade Zombie (Inventory Slots / Extra Equip)
do
    local zombieUpgradeOptions = {"Inventory Slots", "Extra Equip"}
    local zombieUpgradeMap = {
        ["Inventory Slots"] = "Zombie_Inventory_Slots",
        ["Extra Equip"] = "Zombie_Extra_Equip"
    }
    local selectedZombieUpgrade = zombieUpgradeMap[zombieUpgradeOptions[1]] or "Zombie_Inventory_Slots"

    local zombieDropdown = HalloweenEvent2:AddDropdown("ZombieUpgradeDropdown", {
        Text = "Select Zombie Upgrade",
        Values = zombieUpgradeOptions,
        Default = config.ZombieUpgradeDropdown or 1,
        Multi = false,
        Tooltip = "Choose which zombie upgrade to purchase repeatedly.",
        Callback = function(Value)
            selectedZombieUpgrade = zombieUpgradeMap[Value] or selectedZombieUpgrade
            config.ZombieUpgradeDropdown = Value
        end
    })

    HalloweenEvent2:AddToggle("AutoUpgradeZombieToggle", {
        Text = "Auto Upgrade Zombie",
        Default = config.AutoUpgradeZombieToggle or false,
        Tooltip = "Continuously sends the Zombie upgrade RPC while enabled.",
        Callback = function(Value)
            autoUpgradeZombieEnabled = Value
            config.AutoUpgradeZombieToggle = Value
            if Value then
                task.spawn(function()
                    while autoUpgradeZombieEnabled and getgenv().SeisenHubRunning do
                        local args = {
                            [1] = {
                                ["Upgrading_Name"] = selectedZombieUpgrade,
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Zombie_Upgrades",
                            }
                        }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                        end)
                        task.wait(1)
                    end
                end)
            end
        end
    })
end


HalloweenEvent2:AddToggle("AutoZombieCraftingToggle", {
    Text = "Auto Zombie Crafting",
    Default = config.AutoZombieCraftingToggle or false,
    Tooltip = "Automatically crafts the Zombie Fighter using Zombie_Crafting.",
    Callback = function(Value)
        -- Use a shared flag so the background thread can observe toggle changes
        autoZombieCraftingEnabled = Value
        config.AutoZombieCraftingToggle = Value
        if Value then
            -- start crafting thread if not already running
            if zombieCraftingThread and coroutine.status(zombieCraftingThread) ~= "dead" then return end
            zombieCraftingThread = task.spawn(function()
                while autoZombieCraftingEnabled and getgenv().SeisenHubRunning do
                    local args = {
                        [1] = {
                            ["Crafting_Name"] = "Zombie_Crafting",
                            ["Product_Id"] = 1,
                            ["Action"] = "Crafting",
                            ["Selected"] = {
                                [1] = {
                                    ["Completed"] = true,
                                    ["Found"] = 1,
                                    ["Required"] = 1,
                                    ["Amount"] = -1,
                                    ["Id"] = "Zombie_Head",
                                    ["db_item"] = {
                                        ["Stats"] = {},
                                        ["Description"] = "Used to craft a Zombie Fighter.",
                                        ["Maximum"] = 1e+32,
                                        ["Id"] = 9070,
                                        ["Sell_Rewards"] = {},
                                        ["Equip_Slots"] = {},
                                        ["Type"] = "Materials",
                                        ["Rarity"] = 113,
                                        ["Name"] = "Zombie_Head",
                                        ["Category"] = "Resources",
                                        ["SortWith"] = "Materials",
                                        ["Skills"] = {},
                                        ["ImageId"] = "rbxassetid://89428778620726",
                                        ["Is_Stat_Exist"] = {},
                                    },
                                    ["List"] = {[1] = "9070"},
                                },
                                [2] = {
                                    ["Completed"] = true,
                                    ["Found"] = 2,
                                    ["Required"] = 1,
                                    ["Amount"] = -1,
                                    ["Id"] = "Zombie_Right_Arm",
                                    ["db_item"] = {
                                        ["Stats"] = {},
                                        ["Description"] = "Used to craft a Zombie Fighter.",
                                        ["Maximum"] = 1e+32,
                                        ["Id"] = 9073,
                                        ["Sell_Rewards"] = {},
                                        ["Equip_Slots"] = {},
                                        ["Type"] = "Materials",
                                        ["Rarity"] = 113,
                                        ["Name"] = "Zombie_Right_Arm",
                                        ["Category"] = "Resources",
                                        ["SortWith"] = "Materials",
                                        ["Skills"] = {},
                                        ["ImageId"] = "rbxassetid://120184188388808",
                                        ["Is_Stat_Exist"] = {},
                                    },
                                    ["List"] = {[1] = "9073"},
                                },
                                [3] = {
                                    ["Completed"] = true,
                                    ["Found"] = 2,
                                    ["Required"] = 1,
                                    ["Amount"] = -1,
                                    ["Id"] = "Zombie_Left_Arm",
                                    ["db_item"] = {
                                        ["Stats"] = {},
                                        ["Description"] = "Used to craft a Zombie Fighter.",
                                        ["Maximum"] = 1e+32,
                                        ["Id"] = 9072,
                                        ["Sell_Rewards"] = {},
                                        ["Equip_Slots"] = {},
                                        ["Type"] = "Materials",
                                        ["Rarity"] = 113,
                                        ["Name"] = "Zombie_Left_Arm",
                                        ["Category"] = "Resources",
                                        ["SortWith"] = "Materials",
                                        ["Skills"] = {},
                                        ["ImageId"] = "rbxassetid://98405217735855",
                                        ["Is_Stat_Exist"] = {},
                                    },
                                    ["List"] = {[1] = "9072"},
                                },
                                [4] = {
                                    ["Completed"] = true,
                                    ["Found"] = 1,
                                    ["Required"] = 1,
                                    ["Amount"] = -1,
                                    ["Id"] = "Zombie_Torso",
                                    ["db_item"] = {
                                        ["Stats"] = {},
                                        ["Description"] = "Used to craft a Zombie Fighter.",
                                        ["Maximum"] = 1e+32,
                                        ["Id"] = 9071,
                                        ["Sell_Rewards"] = {},
                                        ["Equip_Slots"] = {},
                                        ["Type"] = "Materials",
                                        ["Rarity"] = 113,
                                        ["Name"] = "Zombie_Torso",
                                        ["Category"] = "Resources",
                                        ["SortWith"] = "Materials",
                                        ["Skills"] = {},
                                        ["ImageId"] = "rbxassetid://124181410459312",
                                        ["Is_Stat_Exist"] = {},
                                    },
                                    ["List"] = {[1] = "9071"},
                                },
                                [5] = {
                                    ["Completed"] = true,
                                    ["Found"] = 2,
                                    ["Required"] = 1,
                                    ["Amount"] = -1,
                                    ["Id"] = "Zombie_Right_Leg",
                                    ["db_item"] = {
                                        ["Stats"] = {},
                                        ["Description"] = "Used to craft a Zombie Fighter.",
                                        ["Maximum"] = 1e+32,
                                        ["Id"] = 9075,
                                        ["Sell_Rewards"] = {},
                                        ["Equip_Slots"] = {},
                                        ["Type"] = "Materials",
                                        ["Rarity"] = 113,
                                        ["Name"] = "Zombie_Right_Leg",
                                        ["Category"] = "Resources",
                                        ["SortWith"] = "Materials",
                                        ["Skills"] = {},
                                        ["ImageId"] = "rbxassetid://81184679071968",
                                        ["Is_Stat_Exist"] = {},
                                    },
                                    ["List"] = {[1] = "9075"},
                                },
                                [6] = {
                                    ["Completed"] = true,
                                    ["Found"] = 1,
                                    ["Required"] = 1,
                                    ["Amount"] = -1,
                                    ["Id"] = "Zombie_Left_Leg",
                                    ["db_item"] = {
                                        ["Stats"] = {},
                                        ["Description"] = "Used to craft a Zombie Fighter.",
                                        ["Maximum"] = 1e+32,
                                        ["Id"] = 9074,
                                        ["Sell_Rewards"] = {},
                                        ["Equip_Slots"] = {},
                                        ["Type"] = "Materials",
                                        ["Rarity"] = 113,
                                        ["Name"] = "Zombie_Left_Leg",
                                        ["Category"] = "Resources",
                                        ["SortWith"] = "Materials",
                                        ["Skills"] = {},
                                        ["ImageId"] = "rbxassetid://93915084224907",
                                        ["Is_Stat_Exist"] = {},
                                    },
                                    ["List"] = {[1] = "9074"},
                                },
                            },
                        },
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(1)
                end
                -- clear thread reference when finished
                zombieCraftingThread = nil
            end)
        else
            -- setting autoZombieCraftingEnabled = false above will cause the thread to exit
        end
    end
})
------======================================= Tab: Misc Settings ==================================------

UISettingsGroup:AddToggle("AutoHideUI", {
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


-- Disable Sound
UISettingsGroup:AddToggle(
    "MutePetSoundsToggle",
    {
        Text = "Mute Star Roll Sounds",
        Default = config.MutePetSoundsToggle or false,
        Callback = function(Value)
        -- Robust inline logic
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            if not originalVolumes then originalVolumes = {} end
            local audioFolder = ReplicatedStorage:FindFirstChild("Audio")
            if audioFolder then
                local petSounds = {"Pets_Appearing_Sound", "Pets_Drumroll", "Loot"}
                for _, soundName in ipairs(petSounds) do
                    local sound = audioFolder:FindFirstChild(soundName)
                    if sound and sound:IsA("Sound") then
                        if Value then
                            if not originalVolumes[soundName] then
                                originalVolumes[soundName] = sound.Volume
                            end
                            sound.Volume = 0
                        else
                            sound.Volume = originalVolumes[soundName] or 0.5
                        end
                    end
                end
                local mergeFolder = audioFolder:FindFirstChild("Merge")
                if mergeFolder then
                    local mergeSounds = {"PetsAppearingSound", "Drumroll", "ChestOpen"}
                    for _, soundName in ipairs(mergeSounds) do
                        local sound = mergeFolder:FindFirstChild(soundName)
                        if sound and sound:IsA("Sound") then
                            if Value then
                                if not originalVolumes[soundName] then
                                    originalVolumes[soundName] = sound.Volume
                                end
                                sound.Volume = 0
                            else
                                sound.Volume = originalVolumes[soundName] or 0.5
                            end
                        end
                    end
                end
            end
        end
    }
)

-- UI Settings
UISettingsGroup:AddToggle(
    "DisableNotificationsToggle",
    {
        Text = "Disable Notifications",
        Default = config.DisableNotificationsToggle or false,
        Callback = function(Value)
        -- Robust inline logic
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            if player then
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    local notifications = playerGui:FindFirstChild("Notifications")
                    if notifications then
                        if Value then
                            if notifications:IsA("ScreenGui") or notifications:IsA("BillboardGui") or notifications:IsA("SurfaceGui") then
                                notifications.Enabled = false
                            elseif notifications:IsA("GuiObject") then
                                notifications.Visible = false
                            end
                        else
                            if notifications:IsA("ScreenGui") or notifications:IsA("BillboardGui") or notifications:IsA("SurfaceGui") then
                                notifications.Enabled = true
                            elseif notifications:IsA("GuiObject") then
                                notifications.Visible = true
                            end
                        end
                    end
                    -- Also handle Drop_Notifications.Drops and Drops_Small
                    local dropNotifications = playerGui:FindFirstChild("Drop_Notifications")
                    if dropNotifications then
                        local drops = dropNotifications:FindFirstChild("Drops")
                        local dropsSmall = dropNotifications:FindFirstChild("Drops_Small")
                        for _, obj in ipairs({drops, dropsSmall}) do
                            if obj then
                                if Value then
                                    if obj:IsA("ScreenGui") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                                        obj.Enabled = false
                                    elseif obj:IsA("GuiObject") then
                                        obj.Visible = false
                                    end
                                else
                                    if obj:IsA("ScreenGui") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                                        obj.Enabled = true
                                    elseif obj:IsA("GuiObject") then
                                        obj.Visible = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    }
)

UISettingsGroup:AddToggle(
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
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Decal") or obj:IsA("Texture") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Transparency = obj.Transparency}
                        end
                        obj.Transparency = 1
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Enabled = obj.Enabled}
                        end
                        obj.Enabled = false
                    end
                end
                if settings().Rendering then
                    if not originalRenderingQuality then
                        originalRenderingQuality = settings().Rendering.QualityLevel
                    end
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                end
                if fpsBoostConnection then
                    fpsBoostConnection:Disconnect()
                    fpsBoostConnection = nil
                end
                fpsBoostConnection = workspace.DescendantAdded:Connect(function(obj)
                    if obj:IsA("Decal") or obj:IsA("Texture") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Transparency = obj.Transparency}
                        end
                        obj.Transparency = 1
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Enabled = obj.Enabled}
                        end
                        obj.Enabled = false
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
                    if obj and obj.Parent then
                        if obj:IsA("Decal") or obj:IsA("Texture") then
                            obj.Transparency = props.Transparency or 0
                        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                            obj.Enabled = props.Enabled == nil and true or props.Enabled
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

UISettingsGroup:AddToggle(
    "AntiAFKToggle",
    {
        Text = "Anti AFK",
        Default = config.AntiAFKToggle or false,
        Tooltip = "Prevents Roblox from kicking you for being AFK by simulating a click every 10 seconds.",
        Callback = function(Value)
            if Value then
                task.spawn(function()
                    local vu = game:GetService("VirtualUser")
                    -- First click immediately
                    pcall(function()
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new())
                    end)
                    -- Then repeat every 10 seconds
                    while Value and getgenv().SeisenHubRunning do
                        task.wait(10)
                        pcall(function()
                            vu:CaptureController()
                            vu:ClickButton2(Vector2.new())
                        end)
                    end
                end)
            end
        end
    }
)

-- === UI Setting: Server Hop Admin ===
-- Assuming you already have a UI settings table named config

UISettingsGroup:AddToggle("ServerHopAdminToggle", {
    Text = "Server Hop Admin",
    Default = config.ServerHopAdminToggle or false,
    Tooltip = "Automatically hops to a lower server if a listed admin is present.",
    Callback = function(Value)
        if Value then
            checkForAdmins() -- Run check immediately if toggled on
        end
    end
})

-- === Admin List ===
local adminIDs = {
    [4879627095] = true,
    [3630367496] = true,
    [4782775196] = true,
    [2756892761] = true,
    [8563638467] = true,
    [382171914]  = true,
    [1012691646] = true,
    [2272933353] = true,
    [1521443670] = true,
}

-- === Function: Check for Admins ===
function checkForAdmins()
    for _, player in ipairs(game.Players:GetPlayers()) do
        if adminIDs[player.UserId] then
            warn("[⚠] Admin Detected: " .. player.Name .. " (" .. player.UserId .. ")")
            serverHop()
            return
        end
    end
end

-- === Function: Server Hop ===
function serverHop()
    -- Get a list of public servers and teleport to a lower-populated one
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId

    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", PlaceId)
        ))
    end)

    if success and servers and servers.data then
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                warn("[🌐] Hopping to Server ID: " .. server.id .. " | Players: " .. server.playing)
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id)
                return
            end
        end
        warn("[❗] No lower servers found, staying in current server.")
    else
        warn("[❗] Failed to fetch server list for hopping.")
    end
end

-- === Connect to PlayerAdded/Removed so we check dynamically ===
game.Players.PlayerAdded:Connect(function()
    task.wait(1)
    checkForAdmins()
end)

-- UI Scale dropdown for mobile compatibility
local uiScaleOptions = {"30%", "50%", "75%", "100%", "125%", "150%"}
local uiScaleDefault = config.UIScale or "100%"
local uiScaleDropdownObj = UISettingsGroup:AddDropdown("UIScale", {
    Text = "UI Scale",
    Values = uiScaleOptions,
    Default = table.find(uiScaleOptions, uiScaleDefault) or 4,
    Tooltip = "Adjust UI size for better mobile experience",
    Callback = function(value)
        local scaleMap = {
            ["30%"] = 30,
            ["50%"] = 50,
            ["75%"] = 75,
            ["100%"] = 100,
            ["125%"] = 125,
            ["150%"] = 150
        }
        Library:SetWatermarkVisibility(false)
        Library:SetDPIScale(scaleMap[value])
    end
})

local redeemCodes = {
    "33KPlayers", "150KLikes", "DungeonFall1", "Update13", "155KLikes", "350KFav", "360KFav", "40MVisits", "Shutdown123", "34KOnline", "35KCCU", "?43KRecord?", "?44KRecord?", "?Record45K?!", "?Record46K?!", "?NewRecord47k", "?SupaRecord48k", "?Supa49kRecord", "?Ultra50KRecord", "?Update14P2", "175KLikes", "180KLikes", "400KFav", "405KFav", "?Update14P3", "185KLikes", "190KLikes", "410KFav", "415KFav", "?51kPlayers", "?52kPlayers", "?53kPlayers", "Update15", "195KLikes", "200KLikes", "420KFav", "425KFav", "Update15Delay", "BugsUpdate15", "2BugsUpdate15", "51kPlayers", "52kPlayers", "53kPlayers", "Ultra50KRecord", "Supa49kRecord", "SupaRecord48k", "NewRecord47k", "Record45K?!", "?Record46K?!", "44KRecord??", "Update14P2", "175KLikes", "180KLikes", "400KFav", "405KFav", "?42K?","Update23", "680KFav", "685KFav", "375KLikes", "215MVisits", "Update23Restart",
    "Update24", "710KFav", "715KFav", "CodeGeass", "385KLikes","Update23P3", "700KFav", "705KFav", "225MVisits", "Update23P3Code", "Update23P2", "690KFav", "695KFav", "380KLikes", "Update23Code","CodeGeass2",
    "SomeQuickFix1a", "SomeQuickFix2", "?41KRecord?", "40KRecord?", "39KRecordCcu", "Update14", "170KLikes", "50MVisits", "395KFav", "390KFav", "DungeonQuickFix", "Update13P3", "165KLikes", "375KFav", "380KFav", "385KFav", "1GhoulKeyNoMore", "IWantKey", "Online36K", "37KPlayersOn", "38KRecord", "Update13P2", "365KFav", "370KFav", "50K", "160KLikes", "Shutdown123", "Update13", "155KLikes", "350KFav", "360KFav", "40MVisits", "DungeonFall1", "Update12.5", "31KPlayers", "32KPlayers", "33KPlayers", "150KLikes", "Update12.2", "35MVisits", "140KLikes", "340KFav", "29KPlayers", "30kOnline", "Update12.2Late", "PotionFix1", "25KPlayers", "26KPlayers", "27KPlayers", "28KPlayers", "BugFixSome", "Update12", "Update15P2", "205KLikes", "210KLikes", "430KFav",
    "435KFav", "54kPlayers", "WhatPlayer62kRecord!", "DungeonUp15Fix", "65kRecord!", "66kRecord!", "63kRecord!", "CursedFixes", "64kRecord!", "55kPlayers", "56K?!", "57KNewRecord!!", "NoWay58KOnline", "59KOnlinePlayers?!", "ThereIsNoWay60k!", "61kThereIsNoWay", "Update16", "225KLikes", "230KLikes", "450KFav", "455KFav", "FunnyGreenPlanet", "FunnyGreenPlanetShutdown", "Update16P2", "235KLikes", "460KFav", "465KFav", "470KFav", "80MVisits", "Record67K?", "NewRecord68K?", "NewRecord69K?", "NoWayWeCanHit70K?", "71KImpossibleRecord!", "Insane72kPlayersOnline", "73KPlayers", "74KPlayers", "Update16P2Fix", "Update16P2Fix2", "Update16P3", "240KLikes", "245KLikes", "475KFav", "480KFav", "SaveMeUpdate16Part3Fix", "Update17", "250KLikes", "255KLikes", "490KFav", "495KFav", "Update17BalanceWhatisThat?", "ShutdownCodeUpdate17", "Update17P2260KLikes", "265KLikes", "500KFav", "505KFav",
    "Record75K?", "Record76K?", "People82KPlaying", "ThereIs83KPlayersOn?!", "Record77K?", "InsaneRecord78K?", "NoWayRecord79K?!", "80KPeoplePlaying?!", "PeoplePlayingAt81K", "ThisIsSuperCoolCodeFor84k", "OkayWhat?!85K", "NoWayWeWillHit86k", "87kNoWay!!", "Super88KOnlineCode", "OnlineCodeSuper89K!", "JustOneMoreUpdate17P2Code", "Update17P3", "270KLikes", "275KLikes", "510KFav", "515KFav", "100MVisits", "RandomCodeUPD17P3", "Update18", "280KLikes", "520KFav", "525KFav", "530KFav", "ImBombastic", "ImAtomic!", "IThinkYouAreLying", "NiceOnUpdate18?", "Update18P2", "285KLikes", "535KFav", "540KFav", "545KFav", "Upd18Code", "Update18P3", "290KLikes", "295KLikes", "550KFav", "555KFav", "Code2Upd18", "Update18P3Keys", "Update19", "300KLikes", "305KLikes", "560KFav", "565KFav",
    "Update19Delay", "JustACodeFor19Upd", "Update19P2", "310KLikes", "570KFav", "575KFav", "125MVisits", "Update19P2Delay", "Update19P2Shutdown", "RandomUpdate19P2Code?", "Update19P2Shutdown2", "Update19P3", "315KLikes", "580KFav", "585KFav", "150MVisits", "Update20", "320KLikes", "325KLikes", "590KFav", "595KFav", "Update20P2", "HalloweenPart1", "330KLikes", "600KFav", "605KFav", "91kOnline", "92kOnline", "93kOnline", "Super94kOnlineCode!", "NoWay95KPlayers", "NoWay96KPlayers", "JustACodeFor97KPlayers", "Ummm98KPlayers?!", "RobloxWasBroken", "Update20P3", "335KLikes", "340KLikes", "610KFav", "615KFav", "Update20P3HalloweenCode", "Update21", "345KLikes", "350KLikes", "620KFav", "625KFav", "Update21P2", "HalloweenPart2", "355KLikes", "630KFav", "635KFav", "Update21P3", "360KLikes", "175MVisits", "640KFav", "645KFav", "Update22", "365KLikes", "650KFav", "655KFav", "HalloweenPart3ThisSunday",
    "Update22P2","370KLikes","660KFav","665KFav","HalloweenPart3", "Update22P3","670KFav","675KFav","200MVisits","LastHalloweenCode","HalloweenPart3Delay","HalloweenEyes","HalloweenEyes2",
}

local function redeemAllCodes()
    for _, code in ipairs(redeemCodes) do
        local args = {
            [1] = {
                ["Action"] = "_Redeem_Code",
                ["Text"] = code
            }
        }

        pcall(
            function()
                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(
                    unpack(args)
                )
            end
        )
        task.wait(0.2)
    end
end


RedeemGroupbox:AddToggle(
    "AutoRedeemCodesToggle",
    {
        Text = "Auto Redeem All Codes",
        Default = autoRedeemCodesEnabled,
        Callback = function(Value)
            autoRedeemCodesEnabled = Value
            if Value then
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Events = ReplicatedStorage:FindFirstChild("Events")
                local ToServer = Events and Events:FindFirstChild("To_Server")
                if ToServer then
                    task.spawn(function()
                        for _, code in ipairs(redeemCodes) do
                            local args = {
                                [1] = {
                                    ["Action"] = "_Redeem_Code",
                                    ["Text"] = code
                                }
                            }
                            pcall(function()
                                ToServer:FireServer(unpack(args))
                            end)
                            task.wait(0.2)
                        end
                    end)
                end
            end
        end
    }
)

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
            break
        elseif i == #imageFormats then
            -- If all formats fail, use a text fallback
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

UISettingsGroup:AddButton("Unload Script", function()
    
    -- Set main running flag first to stop all loops
    getgenv().SeisenHubRunning = false
    
    -- Stop all automation flags
    autoRollDragonRaceEnabled = false
    autoRollSaiyanEvolutionEnabled = false
    autoRollSwordsEnabled = false
    autoRollPirateCrewEnabled = false
    autoRollDemonFruitsEnabled = false
    autoRollReiatsuColorEnabled = false
    autoRollZanpakutoEnabled = false
    autoRollCursesEnabled = false
    autoRollDemonArtsEnabled = false
    autoRollGrimoireEnabled = false
    autoSoloHunterRankEnabled = false
    autoRollPowerEyesEnabled = false
    autoPsychicMayhemEnabled = false
    autoRollEnergyCardEnabled = false
    autoRollDamageCardEnabled = false
    autoRollFamiliesEnabled = false
    autoRollTitansEnabled = false
    autoRollSinsEnabled = false
    autoRollCommandmentsEnabled = false
    autoRollKaijuPowersEnabled = false
    autoRollAkumaPowersEnabled = false
    autoRollSpeciesEnabled = false
    autoRollUltimateSkillsEnabled = false
    autoRollPowerEnergyRunesEnabled = false
    autoRollStandsEnabled = false
    autoRollOnomatopoeiaEnabled = false
    autoRollKaguneEnabled = false
    autoRollInvestigatorEnabled = false
    autoRollDebiruHunterEnabled = false
    
    -- Combat & Farming flags
    farmAllEnemiesEnabled = false
    killAuraOnlyEnabled = false
    fightersKillAuraEnabled = false
    teleportAndAttackEnabled = false
    autoRankEnabled = false
    autoAvatarLevelingEnabled = false
    autoAcceptAllQuestsEnabled = false
    autoClaimAchievementsEnabled = false
    autoAcceptHeroQuestEnabled = false
    autoObeliskEnabled = false
    autoUsePotionsEnabled = false
    
    
    -- Roll & Delete flags  
    autoRollEnabled = false
    autoDeleteEnabled = false
    autoDeleteWeaponEnabled = false
    
    -- Stats & Rewards flags
    autoStatsRunning = false
    isAutoTimeRewardEnabled = false
    isAutoDailyChestEnabled = false
    isAutoVipChestEnabled = false
    isAutoGroupChestEnabled = false
    isAutoPremiumChestEnabled = false
    
    -- Upgrades
    autoUpgradeEnabled = false
    autoHakiUpgradeEnabled = false
    autoAttackRangeUpgradeEnabled = false
    autoSpiritualPressureUpgradeEnabled = false
    autoCursedProgressionUpgradeEnabled = false
    autoReawakeningProgressionUpgradeEnabled = false
    autoMonarchProgressionUpgradeEnabled = false
    autoChakraProgressionUpgradeEnabled = false
    autoSpiritualUpgradeEnabled = false
    autoLuckySpiritUpgradeEnabled = false
    autoTenProgressionUpgradeEnabled = false
    autoEnergyProgressionUpgradeEnabled = false
    autoContractOfGreedUpgradeEnabled = false
    
    -- Dungeon
    autoEnterDungeon = false
    basicAutoDungeonEnabled = false
    
    -- Auto Raid/Dungeon flags
    autoEnterRestaurantRaidEnabled = false
    autoEnterGhoulRaidEnabled = false
    autoEnterProgressionRaidEnabled = false
    autoEnterGleamRaidEnabled = false
    autoEnterTournamentRaidEnabled = false
    autoEnterCursedRaidEnabled = false
    autoEnterChainsawDefenseEnabled = false
    autoEnterTitanDefenseEnabled = false
    autoEnterKaijuDungeonEnabled = false
    autoEnterSinRaidEnabled = false
    autoEnterMundoRaidEnabled = false
    autoEnterSufferingRaidEnabled = false
    autoEnterHalloweenRaidEnabled = false
    autoLevelingEnabled = false
    autoRollShadowEnabled = false
    autoRollTitanEnabled = false
    
    -- Auto Leave flags
    autoLeaveWaveEnabled = false
    autoLeaveRoomEnabled = false
    autoRedeemCodesEnabled = false
    DisableNotificationsToggle = false

    -- Set all enabledUpgrades to false
    if enabledUpgrades then
        for k in pairs(enabledUpgrades) do
            enabledUpgrades[k] = false
        end
    end
    
    -- Wait a moment for all loops to recognize the stop flags
    task.wait(0.5)
    
    -- Disconnect all specific threads and connections
    pcall(function()
        if teleportAndAttackThread and coroutine.status(teleportAndAttackThread) ~= "dead" then
            coroutine.close(teleportAndAttackThread)
            teleportAndAttackThread = nil
        end
    end)
    
    pcall(function()
        if killAuraThread and coroutine.status(killAuraThread) ~= "dead" then
            coroutine.close(killAuraThread)
            killAuraThread = nil
        end
    end)
    
    -- Disconnect monster folder connections
    pcall(function()
        disconnectMonsterFolderConnections()
    end)
    
    -- Restore FPS Boost settings to normal
    local Lighting = game:GetService("Lighting")
    local workspace = game:GetService("Workspace")
    pcall(function()
        if fpsBoostConnection then
            fpsBoostConnection:Disconnect()
            fpsBoostConnection = nil
        end
    end)
    
    pcall(function()
        if Lighting and originalLightingValues and originalLightingValues.GlobalShadows ~= nil then
            Lighting.GlobalShadows = originalLightingValues.GlobalShadows
            Lighting.FogEnd = originalLightingValues.FogEnd
            Lighting.Brightness = originalLightingValues.Brightness
        end
    end)
    
    pcall(function()
        if workspace:FindFirstChild("Terrain") and originalTerrainValues and originalTerrainValues.WaterWaveSize ~= nil then
            local Terrain = workspace.Terrain
            Terrain.WaterWaveSize = originalTerrainValues.WaterWaveSize
            Terrain.WaterWaveSpeed = originalTerrainValues.WaterWaveSpeed
            Terrain.WaterReflectance = originalTerrainValues.WaterReflectance
            Terrain.WaterTransparency = originalTerrainValues.WaterTransparency
        end
    end)
    
    pcall(function()
        if originalFPSValues then
            for obj, props in pairs(originalFPSValues) do
                if obj and obj.Parent then
                    if obj:IsA("Decal") or obj:IsA("Texture") then
                        obj.Transparency = props.Transparency or 0
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                        obj.Enabled = props.Enabled == nil and true or props.Enabled
                    end
                end
            end
        end
    end)
    
    pcall(function()
        if settings().Rendering and originalRenderingQuality then
            settings().Rendering.QualityLevel = originalRenderingQuality
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
        end
    end)

    -- Stop watermark connection
    pcall(function()
        if WatermarkConnection then
            WatermarkConnection:Disconnect()
        end
    end)
    
    -- Disconnect any remaining global input connections
    pcall(function()
        if inputChangedConnection then
            inputChangedConnection:Disconnect()
        end
        if inputEndedConnection then
            inputEndedConnection:Disconnect()
        end
    end)
    
    -- Remove custom watermark
    pcall(function()
        if WatermarkGui then
            WatermarkGui:Destroy()
        end
    end)
    
    -- Final cleanup and proper unload
    pcall(function()
        if Library and Library.Unload then
            Library:Unload()
        end
    end)
    
    print("✅ Seisen Hub completely unloaded and cleaned up!")
end)

-- Load the autoload config after all UI elements are setup
SaveManager:LoadAutoloadConfig()
