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


local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
local Window = Library:CreateWindow({
    Title = "Seisen Hub",
    Footer = "Anime Eternal",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Center = true,
    Icon = 125926861378074,
    AutoShow = true,
    ShowCustomCursor = true -- Enable custom cursor
})


local autoRollDragonRaceEnabled = false
local autoRollSaiyanEvolutionEnabled = false
local autoRollSwordsEnabled = false
local autoRollPirateCrewEnabled = false
local autoRollDemonFruitsEnabled = false
local autoRollReiatsuColorEnabled = false
local autoRollZanpakutoEnabled = false
local autoRollCursesEnabled = false
local autoRollDemonArtsEnabled = false
local autoRollGrimoireEnabled = false
local autoSoloHunterRankEnabled = false
local autoRollPowerEyesEnabled = false
local autoPsychicMayhemEnabled = false
local autoRollEnergyCardEnabled = false
local autoRollDamageCardEnabled = false
local autoRollFamiliesEnabled = false
local autoRollTitansEnabled = false
local autoRollSinsEnabled = false
local autoRollCommandmentsEnabled = false
local autoRollKaijuPowersEnabled = false
local autoRollAkumaPowersEnabled = false
local autoRollSpeciesEnabled = false
local autoRollUltimateSkillsEnabled = false
local autoRollPowerEnergyRunesEnabled = false
local autoRollStandsEnabled = false
local autoRollOnomatopoeiaEnabled = false
local autoRollKaguneEnabled = false
local autoRollInvestigatorEnabled = false
local autoRollDebiruHunterEnabled = false
local teleportSelectedEnemyTitles = {}
local teleportAndAttackEnabled = false

-- Auto Roll Stars globals
local autoRollEnabled = false
local selectedStar = "Star_1"
local delayBetweenRolls = 0.1
local autoDeleteEnabled = false
local selectedDeleteStar = "Star_1"
local selectedRarities = {}
local selectedRaritiesDisplay = {}
local autoDeleteWeaponEnabled = false
local selectedDeleteWeapon = "Common" -- or whatever your default should be
local selectedWeaponRarities = {}
local selectedWeaponRaritiesDisplay = {}

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
    Secret = "7"
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
    Secret = "7"
}
local selectedTitanRarities = {}
local selectedTitanRaritiesDisplay = {}


-- =====================
-- Ball Circle Config & Defaults (top of file)
-- =====================
local configFolder = "SeisenHub"
local configFile = configFolder .. "/seisen_hub_ae.txt"
local HttpService = game:GetService("HttpService")
local config = {}

-- Default values


-- Ensure folder exists
if not isfolder(configFolder) then
    makefolder(configFolder)
end

-- Load config if file exists
if isfile(configFile) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(configFile))
    end)
    if ok and type(data) == "table" then
        config = data
    end
end

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

local function saveConfig()
    config.AutoHideUIEnabled = autoHideUIEnabled
    writefile(configFile, HttpService:JSONEncode(config))
end

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
local RollGroupbox2 = RollTab:AddRightGroupbox("Auto Roll Tokens", "circle")


local RollTab2 = Window:AddTab("Rolls 2", "dice-5", "Auto Roll your Powers")
local RollBreathing = RollTab2:AddLeftGroupbox("Auto Roll Breathings", "wind")
local RollShadow = RollTab2:AddRightGroupbox("Auto Roll Shadows", "moon")
local RollTitan = RollTab2:AddLeftGroupbox("Auto Roll Titans", "person-standing")


local UP = Window:AddTab("Upgrades", "arrow-up", "Upgrade your Stats, Sins, Shadows and World")
local UpgradeGroupbox = UP:AddLeftGroupbox("Stats Upgrade", "anvil")
local SinUp = UP:AddLeftGroupbox("Sin Upgrade", "sin")
local ShadowUp = UP:AddLeftGroupbox("Shadow Upgrade", "moon")
local Upgrade2 = UP:AddRightGroupbox("World Upgrade", "archive")

local ShopTab = Window:AddTab("ExchangeShop", "star", "Exchange Items for Tokens and Keys")
local ExchangeW1t5 = ShopTab:AddLeftGroupbox("Exchange Shop World 1 to 5", "lasso-select")
local ExchangeW6t10 = ShopTab:AddRightGroupbox("Exchange Shop World 6 to 10", "minimize")
local ExchangeW11t15 = ShopTab:AddLeftGroupbox("Exchange Shop World 11 to 15", "loader-pinwheel")
local ExchangeW16t20 = ShopTab:AddRightGroupbox("Exchange Shop World 16 to 20", "ratio")
local ExchangeKeys = ShopTab:AddLeftGroupbox("Exchange Shop Keys", "key")
local ExchangePotion = ShopTab:AddRightGroupbox("Exchange Shop Potions", "milk")

local TokenTab = Window:AddTab("Token Exchange", "gem", "Exchange Tokens for Items")
local TokenW1t5 = TokenTab:AddLeftGroupbox("Token Exchange World 1 to 5", "circle-plus")
local TokenW6t10 = TokenTab:AddRightGroupbox("Token Exchange World 6 to 10", "database")
local TokenW11t15 = TokenTab:AddLeftGroupbox("Token Exchange World 11 to 15", "folder-kanban")
local TokenW16t20 = TokenTab:AddRightGroupbox("Token Exchange World 16 to 20", "file-code")

local JewelryTab = Window:AddTab("Jewelry Exchange", "diamond" , "Exchange Jewelry Coins and Items")
local ExchangeJewelry = JewelryTab:AddLeftGroupbox("Exchange Jewelry", "shell")
ExchangeJewelry:AddLabel("Exchange Items to Jewelry Coins")
local ExchangeJewelryS = JewelryTab:AddRightGroupbox("Exchange Jewelry Shop", "sparkles")
ExchangeJewelryS:AddLabel("Exchange Jewelry Coins to Items")

local SettingsTab = Window:AddTab("Settings", "settings", "Customize the UI")
local UISettingsGroup = SettingsTab:AddLeftGroupbox("UI Customization", "paintbrush")
local RedeemGroupbox = SettingsTab:AddRightGroupbox("Redeem Codes", "gift")
local InfoGroup = SettingsTab:AddRightGroupbox("Script Information", "info")

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenHub")
ThemeManager:ApplyToTab(SettingsTab)

InfoGroup:AddLabel("Script by: Seisen")
InfoGroup:AddLabel("Version: 8.0.0")
InfoGroup:AddLabel("Game: Anime Eternal")

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
            config.MonsterSelector = values
            saveConfig()
        end
    }
)

if config.MonsterSelector and monsterDropdown and typeof(monsterDropdown.SetValue) == "function" then
    monsterDropdown:SetValue(config.MonsterSelector)
end

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
    Default = killAuraDelay,
    Rounding = 2,
    Tooltip = "Delay between each attack (seconds)",
    Callback = function(val)
        killAuraDelay = val
    end
})

-- Flag to avoid multiple running loops
local teleportAndAttackRunning = false
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
        config.TeleportAndAttackToggle = Value
        saveConfig()
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


-- Startup
if config.TeleportAndAttackToggle then
    teleportAndAttackEnabled = true
    if LeftGroupbox.Flags and LeftGroupbox.Flags.TeleportAndAttackToggle then
        LeftGroupbox.Flags.TeleportAndAttackToggle:Set(true)
    end
    startTeleportAndAttack()
end

-- Utility: Shuffle table in place
local function shuffleTable(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- Avoid multiple loops
local farmAllRunning = false

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
        config.FarmAllEnemiesToggle = Value
        saveConfig()
        if Value then
            startFarmAllEnemies()
        else
            farmAllRunning = false -- ensure clean stop
        end
    end
})

if config.FarmAllEnemiesToggle then
    farmAllEnemiesEnabled = true
    if LeftGroupbox.Flags and LeftGroupbox.Flags.FarmAllEnemiesToggle then
        LeftGroupbox.Flags.FarmAllEnemiesToggle:Set(true)
    end
    startFarmAllEnemies()
end

LeftGroupbox:AddToggle(
        "KillAuraOnlyToggle",
        {
            Text = "Kill Aura Only",
            Default = config.KillAuraOnlyToggle or false,
            Tooltip = "Attacks nearest monster without teleporting.",
            Callback = function(Value)
                killAuraOnlyEnabled = Value
                config.KillAuraOnlyToggle = Value
                saveConfig()
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


    -- Auto-start logic for toggles after reload
if config.KillAuraOnlyToggle then
    killAuraOnlyEnabled = true
    if LeftGroupbox.Flags and LeftGroupbox.Flags.KillAuraOnlyToggle then
        LeftGroupbox.Flags.KillAuraOnlyToggle:Set(true)
    end
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
                    if nearest and nearestDist < 20 then
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
        while config.KillAuraToggle do
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
        Default = config.KillAuraToggle or false,
        Tooltip = "Automatically attacks all nearby monsters within range.",
        Callback = function(Value)
            config.KillAuraToggle = Value
            saveConfig()
            if Value then
                startKillAura()
            end
        end
    }
)

-- Auto-start if it was enabled last session
if config.KillAuraToggle then
    startKillAura()
end


-- Auto Rank Toggle
LeftGroupbox:AddToggle(
    "AutoRankToggle",
    {
        Text = "Auto Rank",
        Default = config.AutoRankToggle or false,
        Tooltip = "Automatically ranks up your character.",
        Callback = function(Value)
            autoRankEnabled = Value
            config.AutoRankToggle = Value
            saveConfig()
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


if config.AutoRankToggle then
    autoRankEnabled = true
    if LeftGroupbox.Flags and LeftGroupbox.Flags.AutoRankToggle then
        LeftGroupbox.Flags.AutoRankToggle:Set(true)
    end
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

-- Auto Avatar Leveling Toggle
LeftGroupbox:AddToggle(
    "AutoAvatarLevelingToggle",
    {
        Text = "Auto Avatar Leveling",
        Default = config.AutoAvatarLevelingToggle or false,
        Tooltip = "Automatically levels up only avatars that are equipped (have Equipped ImageLabel).",
        Callback = function(Value)
            autoAvatarLevelingEnabled = Value
            config.AutoAvatarLevelingToggle = Value
            saveConfig()

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

-- Trigger toggle if enabled in config
if config.AutoAvatarLevelingToggle then
    autoAvatarLevelingEnabled = true
    if LeftGroupbox.Flags and LeftGroupbox.Flags.AutoAvatarLevelingToggle then
        LeftGroupbox.Flags.AutoAvatarLevelingToggle:Set(true)
    end
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


-- Auto Accept Quests Toggle
LeftGroupbox:AddToggle(
    "AutoAcceptAllQuestsToggle",
    {
        Text = "Auto Accept & Claim All Quests",
        Default = config.AutoAcceptAllQuestsToggle or false,
        Tooltip = "Automatically accepts and claims all quests.",
        Callback = function(Value)
            autoAcceptAllQuestsEnabled = Value
            config.AutoAcceptAllQuestsToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    while autoAcceptAllQuestsEnabled and getgenv().SeisenHubRunning do
                        for questId = 1, 99 do
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

if config.AutoAcceptAllQuestsToggle then
    autoAcceptAllQuestsEnabled = true
    if LeftGroupbox.Flags and LeftGroupbox.Flags.AutoAcceptAllQuestsToggle then
        LeftGroupbox.Flags.AutoAcceptAllQuestsToggle:Set(true)
    end
    task.spawn(function()
        while autoAcceptAllQuestsEnabled and getgenv().SeisenHubRunning do
            for questId = 1, 99 do
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

-- Auto Claim Achievements Toggle
LeftGroupbox:AddToggle(
    "AutoClaimAchievement",
    {
        Text = "Auto Achievements",
        Default = config.AutoClaimAchievement or false,
        Tooltip = "Automatically claims achievements.",
        Callback = function(Value)
            autoClaimAchievementsEnabled = Value
            config.AutoClaimAchievement = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local achievements = {
                        Total_Energy = 50,
                        Total_Coins = 50,
                        Friends_Bonus = 50,
                        Time_Played = 50,
                        Stars = 50,
                        Defeats = 50,
                        Dungeon_Easy = 50,
                        Total_Dungeon_Easy = 50,
                        Dungeon_Medium = 50,
                        Total_Dungeon_Medium = 50,
                        Dungeon_Hard = 50,
                        Total_Dungeon_Hard = 50,
                        Dungeon_Insane = 50,
                        Total_Dungeon_Insane = 50,
                        Dungeon_Crazy = 50,
                        Total_Dungeon_Crazy = 50,
                        Leaf_Raid = 50,
                        Titan_Defense = 50,
                        Restaurant_Raid = 50,
                        Gleam_Raid  = 50,
                        Kaiju_Raid = 50,
                        Total_Kaiju_Raid = 50,
                        Ghoul_Raid = 50,
                        Progression_Raid = 50,
                        Progression_Raid_2 = 50,
                        Chainsaw_Defense = 50,
                        Tournament_Raid = 50,
                        Cursed_Raid = 50,
                        Netherworld_Defense = 50,
                        Sin_Raid = 50,
                        Green_Planet_Raid = 50,
                    }
                    local function toRoman(num)
                        local romanNumerals = {
                            [1] = "I", [2] = "II", [3] = "III", [4] = "IV", [5] = "V", [6] = "VI", [7] = "VII", [8] = "VIII", [9] = "IX", [10] = "X",
                            [11] = "XI", [12] = "XII", [13] = "XIII", [14] = "XIV", [15] = "XV", [16] = "XVI", [17] = "XVII", [18] = "XVIII", [19] = "XIX", [20] = "XX",
                            [21] = "XXI", [22] = "XXII", [23] = "XXIII", [24] = "XXIV", [25] = "XXV", [26] = "XXVI", [27] = "XXVII", [28] = "XXVIII", [29] = "XXIX", [30] = "XXX",
                            [31] = "XXXI", [32] = "XXXII", [33] = "XXXIII", [34] = "XXXIV", [35] = "XXXV", [36] = "XXXVI", [37] = "XXXVII", [38] = "XXXVIII", [39] = "XXXIX", [40] = "XL",
                            [41] = "XLI", [42] = "XLII", [43] = "XLIII", [44] = "XLIV", [45] = "XLV", [46] = "XLVI", [47] = "XLVII", [48] = "XLVIII", [49] = "XLIX", [50] = "L"
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


if config.AutoClaimAchievement then
    autoClaimAchievementsEnabled = true
    if LeftGroupbox.Flags and LeftGroupbox.Flags.AutoClaimAchievement then
        LeftGroupbox.Flags.AutoClaimAchievement:Set(true)
    end
    task.spawn(function()
        local achievements = {
            Total_Energy = 50,
            Total_Coins = 50,
            Friends_Bonus = 50,
            Time_Played = 50,
            Stars = 50,
            Defeats = 50,
            Dungeon_Easy = 50,
            Total_Dungeon_Easy = 50,
            Dungeon_Medium = 50,
            Total_Dungeon_Medium = 50,
            Dungeon_Hard = 50,
            Total_Dungeon_Hard = 50,
            Dungeon_Insane = 50,
            Total_Dungeon_Insane = 50,
            Dungeon_Crazy = 50,
            Total_Dungeon_Crazy = 50,
            Leaf_Raid = 50,
            Titan_Defense = 50,
            Restaurant_Raid = 50,
            Gleam_Raid  = 50,
            Kaiju_Raid = 50,
            Total_Kaiju_Raid = 50,
            Ghoul_Raid = 50,
            Progression_Raid = 50,
            Progression_Raid_2 = 50,
            Chainsaw_Defense = 50,
            Tournament_Raid = 50,
            Cursed_Raid = 50,
            Netherworld_Defense = 50,
            Sin_Raid = 50,
            Green_Planet_Raid = 50,
        }
        local function toRoman(num)
            local romanNumerals = {
                [1] = "I", [2] = "II", [3] = "III", [4] = "IV", [5] = "V", [6] = "VI", [7] = "VII", [8] = "VIII", [9] = "IX", [10] = "X",
                [11] = "XI", [12] = "XII", [13] = "XIII", [14] = "XIV", [15] = "XV", [16] = "XVI", [17] = "XVII", [18] = "XVIII", [19] = "XIX", [20] = "XX",
                [21] = "XXI", [22] = "XXII", [23] = "XXIII", [24] = "XXIV", [25] = "XXV", [26] = "XXVI", [27] = "XXVII", [28] = "XXVIII", [29] = "XXIX", [30] = "XXX",
                [31] = "XXXI", [32] = "XXXII", [33] = "XXXIII", [34] = "XXXIV", [35] = "XXXV", [36] = "XXXVI", [37] = "XXXVII", [38] = "XXXVIII", [39] = "XXXIX", [40] = "XL",
                [41] = "XLI", [42] = "XLII", [43] = "XLIII", [44] = "XLIV", [45] = "XLV", [46] = "XLVI", [47] = "XLVII", [48] = "XLVIII", [49] = "XLIX", [50] = "L"
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

LeftGroupbox:AddToggle(
    "AutoObeliskToggle",
    {
        Text = "Obelisk Upgrade",
        Default = config.AutoObeliskToggle or false,
        Tooltip = "Automatically upgrades your Obelisk.",
        Callback = function(Value)
            autoObeliskEnabled = Value
            config.AutoObeliskToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local obeliskTypes = {
                        "Dragon_Obelisk", "Pirate_Obelisk", "Soul_Obelisk", "Sorcerer_Obelisk",
                        "Slayer_Obelisk", "Solo_Obelisk", "Clover_Obelisk", "Leaf_Obelisk",
                        "Granny_Obelisk", "Hunter_Obelisk", "Titan_Obelisk"
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


if config.AutoObeliskToggle then
    autoObeliskEnabled = true
    if LeftGroupbox.Flags and LeftGroupbox.Flags.AutoObeliskToggle then
        LeftGroupbox.Flags.AutoObeliskToggle:Set(true)
    end
    task.spawn(function()
        local obeliskTypes = {
            "Dragon_Obelisk", "Pirate_Obelisk", "Soul_Obelisk", "Sorcerer_Obelisk",
            "Slayer_Obelisk", "Solo_Obelisk", "Clover_Obelisk", "Leaf_Obelisk"
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
            config.AutoStatSingleDropdown = Value
            saveConfig()
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
            config.AutoAssignStatToggle = Value
            saveConfig()
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
        Rounding = 1,
        Tooltip = "Set how many stat points to assign per second.",
        Callback = function(Value)
            pointsPerSecond = Value
            config.PointsPerSecondSlider = Value
            saveConfig()
        end
    }
)

-- Auto-start logic for toggle after controls
if autoStatsRunning and selectedStat and pointsPerSecond then
    if StatsGroupbox.Flags and StatsGroupbox.Flags.AutoAssignStatToggle then
        StatsGroupbox.Flags.AutoAssignStatToggle:Set(true)
    end
    local function startAutoStats()
        task.spawn(function()
            while autoStatsRunning and selectedStat do
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
                task.wait(1)
            end
        end)
    end
    startAutoStats()
end


RewardsGroupbox:AddToggle("AutoTimeRewardToggle", {
    Text = "Auto Time Reward",
    Default = isAutoTimeRewardEnabled,
    Tooltip = "Automatically claims hourly time rewards.",
    Callback = function(Value)
        isAutoTimeRewardEnabled = Value
        config.AutoTimeRewardToggle = Value
        saveConfig()
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
        config.AutoDailyChestToggle = Value
        saveConfig()
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
        config.AutoVipChestToggle = Value
        saveConfig()
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
        config.AutoGroupChestToggle = Value
        saveConfig()
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
        config.AutoPremiumChestToggle = Value
        saveConfig()
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

-- Auto-start logic for toggles after reload
if isAutoTimeRewardEnabled then
    if RewardsGroupbox.Flags and RewardsGroupbox.Flags.AutoTimeRewardToggle then
        RewardsGroupbox.Flags.AutoTimeRewardToggle:Set(true)
    end
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
if isAutoDailyChestEnabled then
    if RewardsGroupbox.Flags and RewardsGroupbox.Flags.AutoDailyChestToggle then
        RewardsGroupbox.Flags.AutoDailyChestToggle:Set(true)
    end
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
if isAutoVipChestEnabled then
    if RewardsGroupbox.Flags and RewardsGroupbox.Flags.AutoVipChestToggle then
        RewardsGroupbox.Flags.AutoVipChestToggle:Set(true)
    end
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
if isAutoGroupChestEnabled then
    if RewardsGroupbox.Flags and RewardsGroupbox.Flags.AutoGroupChestToggle then
        RewardsGroupbox.Flags.AutoGroupChestToggle:Set(true)
    end
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
if isAutoPremiumChestEnabled then
    if RewardsGroupbox.Flags and RewardsGroupbox.Flags.AutoPremiumChestToggle then
        RewardsGroupbox.Flags.AutoPremiumChestToggle:Set(true)
    end
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
    ["Energy Macaron"] = "1109",
    ["Coin Macaron"] = "1110",
    ["Damage Macaron"] = "1111",
    ["Luck Macaron"] = "1112",
    ["Drop Macaron"] = "1113"
}

-- prepare sorted potion names
local potionNames = {}
for name, _ in pairs(potions) do
    table.insert(potionNames, name)
end
table.sort(potionNames)

-- store selected potion IDs (as strings)
local selectedPotions = {}

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
    ["1109"] = "Energy_Macaron",
    ["1110"] = "Coin_Macaron",
    ["1111"] = "Damage_Macaron",
    ["1112"] = "Luck_Macaron",
    ["1113"] = "Drop_Macaron"
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
                    config.PotionDropdown = {}
                    saveConfig()
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
                config.PotionDropdown = selectedNames
                saveConfig()
        end
    }
)

-- Button: fire Use for each selected potion (small delay to avoid server spam)
PotionGroupbox:AddButton(
    {
        Text = "Use Selected Potions",
        Func = function()
            if #selectedPotions == 0 then
                warn("No potions selected!")
                return
            end
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
        end,
        DoubleClick = false
    }
)

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
            task.wait(0.5)
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


-- ✅ UI Toggle (unchanged)
if DungeonGroupbox and typeof(DungeonGroupbox.AddToggle) == "function" then
    DungeonGroupbox:AddToggle(
        "BasicAutoDungeonToggle",
        {
            Text = "Auto Dungeon",
            Default = config.BasicAutoDungeonToggle or false,
            Tooltip = "Teleports to nearest enemy ONCE and uses kill aura until it dies.",
            Callback = function(Value)
                basicAutoDungeonEnabled = Value
                config.BasicAutoDungeonToggle = Value
                saveConfig()
            end
        }
    )
end

-- Auto-start logic for BasicAutoDungeonToggle after reload
if config.BasicAutoDungeonToggle then
    basicAutoDungeonEnabled = true
    if DungeonGroupbox.Flags and DungeonGroupbox.Flags.BasicAutoDungeonToggle then
        DungeonGroupbox.Flags.BasicAutoDungeonToggle:Set(true)
    end
    -- Note: Auto dungeon is now handled by the unified watcher system
end

if not unifiedWatcherStarted then
    unifiedWatcherStarted = true

    local wasAutoFarmOnBeforeDungeon = false
    local lastUIVisible = false
    local lastHeaderVisible = false -- Track header state separately

    task.spawn(function()
        local player = game:GetService("Players").LocalPlayer

        -- Function to detect which specific dungeon the notification is for
        local function getNotificationDungeonType(notification)
            if not notification or not notification.Visible then
                return nil
            end
            
            -- Try to find text elements that indicate dungeon type
            local function searchForDungeonText(element)
                if element:IsA("TextLabel") or element:IsA("TextButton") then
                    local text = element.Text:lower()
                    
                    -- Check for each dungeon type in the text
                    if text:find("easy") then return "Dungeon_Easy"
                    elseif text:find("medium") then return "Dungeon_Medium"
                    elseif text:find("hard") then return "Dungeon_Hard"
                    elseif text:find("insane") then return "Dungeon_Insane"
                    elseif text:find("crazy") then return "Dungeon_Crazy"
                    elseif text:find("nightmare") then return "Dungeon_Nightmare"
                    elseif text:find("leaf") and text:find("raid") then return "Leaf_Raid"
                    elseif text:find("restaurant") then return "Restaurant_Raid"
                    elseif text:find("ghoul") then return "Ghoul_Raid"
                    elseif text:find("progression") then return "Progression_Raid"
                    elseif text:find("gleam") then return "Gleam_Raid"
                    elseif text:find("tournament") then return "Tournament_Raid"
                    elseif text:find("chainsaw") then return "Chainsaw_Defense"
                    elseif text:find("titan") then return "Titan_Defense"
                    elseif text:find("kaiju") then return "Kaiju_Dungeon"
                    end
                end
                
                -- Search children recursively
                for _, child in pairs(element:GetChildren()) do
                    local result = searchForDungeonText(child)
                    if result then return result end
                end
                
                return nil
            end
            
            return searchForDungeonText(notification)
        end

        while getgenv().SeisenHubRunning do
            local gui = player:FindFirstChild("PlayerGui")
            local dungeonGui = gui and gui:FindFirstChild("Dungeon")
            local notification = dungeonGui and dungeonGui:FindFirstChild("Dungeon_Notification")
            local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")

            -- Separate conditions for different features
            local headerVisible = (header and header.Visible)
            local notificationVisible = (notification and notification.Visible)

            -- 🎯 AUTO DUNGEON: Only triggered by Default_Header (when inside dungeon)
            if headerVisible and not lastHeaderVisible and basicAutoDungeonEnabled then
                task.spawn(startBasicAutoDungeon)
                Library:Notify({
                    Title = "Auto Dungeon Enabled",
                    Description = "Auto Dungeon has started.",
                    Time = 3
                })
            end

            -- 🎯 AUTO FARM PAUSING: Only triggered by Dungeon_Notification (for enabled dungeons in Auto Enter Dungeon)
            local notificationDungeonType = getNotificationDungeonType(notification)
            local isEnabledDungeon = false
            if notificationDungeonType and type(selectedDungeons) == "table" then
                for _, selectedDungeon in ipairs(selectedDungeons) do
                    if selectedDungeon == notificationDungeonType then
                        isEnabledDungeon = true
                        break
                    end
                end
            end

            -- 🟥 Pause Auto Farm ONLY if notification is visible AND for a dungeon enabled in Auto Enter Dungeon
            local shouldPauseAutoFarm = notificationVisible and isEnabledDungeon
            if shouldPauseAutoFarm and not lastUIVisible then
                wasAutoFarmOnBeforeDungeon = teleportAndAttackEnabled
                if teleportAndAttackEnabled then
                    teleportAndAttackEnabled = false
                    teleportAndAttackRunning = false
                    if LeftGroupbox.Flags and LeftGroupbox.Flags.TeleportAndAttackToggle then
                        LeftGroupbox.Flags.TeleportAndAttackToggle:Set(false)
                    end
                    Library:Notify({
                        Title = "Auto Farm Paused",
                        Description = "Auto Farm disabled - Enabled dungeon " .. (notificationDungeonType or "unknown") .. " available (Auto Enter enabled)",
                        Time = 3
                    })
                end
            end

            -- 🟢 Resume Auto Farm when notification hidden or not for enabled dungeon
            if not shouldPauseAutoFarm and lastUIVisible then
                if wasAutoFarmOnBeforeDungeon then
                    wasAutoFarmOnBeforeDungeon = false
                    teleportAndAttackEnabled = true
                    task.delay(0.1, startTeleportAndAttack)
                    if LeftGroupbox.Flags and LeftGroupbox.Flags.TeleportAndAttackToggle then
                        LeftGroupbox.Flags.TeleportAndAttackToggle:Set(true)
                    end
                    Library:Notify({
                        Title = "Auto Farm Resumed",
                        Description = "Auto Farm re-enabled after dungeon",
                        Time = 3
                    })
                end
            end

            lastUIVisible = shouldPauseAutoFarm
            lastHeaderVisible = headerVisible
            task.wait(0.3)
        end
    end)
end

-- Monitor Dungeon_Notification and auto-enter dungeons when visible
local function monitorDungeonNotificationAndEnter()
    local player = game:GetService("Players").LocalPlayer
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then
        return
    end
    local dungeonGui = gui:FindFirstChild("Dungeon")
    if not dungeonGui then
        return
    end
    local notification = dungeonGui:FindFirstChild("Dungeon_Notification")
    if not notification then
        return
    end
    local lastVisible = false
    task.spawn(
        function()
            while getgenv().SeisenHubRunning do
                if notification.Visible and not lastVisible then
                    lastVisible = true
                    -- Call each enabled dungeon once, 2s apart
                    for _, dungeon in ipairs(selectedDungeons) do
                        local header = dungeonGui:FindFirstChild("Default_Header")
                        if header and header.Visible then
                            break -- Stop entering if inside dungeon
                        end
                        local args = {
                            [1] = {
                                ["Action"] = "_Enter_Dungeon",
                                ["Name"] = dungeon
                            }
                        }
                        pcall(
                            function()
                                ToServer:FireServer(unpack(args))
                            end
                        )
                        task.wait(1)
                    end
                end
                if not notification.Visible then
                    lastVisible = false
                end
                task.wait(0.2)
            end
        end
    )
end

if monitorDungeonNotificationAndEnter then
    monitorDungeonNotificationAndEnter()
end

-- Dungeon Toggles
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
    local default = table.find(selectedDungeons, dungeon) ~= nil
    DungeonGroupbox:AddToggle(
        "Toggle_" .. dungeon,
        {
            Text = dungeon:gsub("_", " "),
            Default = default,
            Tooltip = "Enable or disable auto entry for this dungeon.",
            Callback = function(Value)
                if Value then
                    if not table.find(selectedDungeons, dungeon) then
                        table.insert(selectedDungeons, dungeon)
                    end
                else
                    for i, v in ipairs(selectedDungeons) do
                        if v == dungeon then
                            table.remove(selectedDungeons, i)
                            break
                        end
                    end
                end
                config.SelectedDungeons = selectedDungeons
                saveConfig()
            end
        }
    )
end

-- Toggle: Auto enter dungeon
DungeonGroupbox:AddToggle(
    "AutoEnterDungeonToggle",
    {
        Text = "Auto Enter Dungeon(s)",
        Default = config.AutoEnterDungeonToggle or false,
        Tooltip = "Automatically enters selected dungeons.",
        Callback = function(Value)
            autoEnterDungeon = Value
            config.AutoEnterDungeonToggle = Value
            saveConfig()
            if Value then
                monitorDungeonNotificationAndEnter()
            end
        end
    }
)

-- Auto-start logic for AutoEnterDungeonToggle after reload
if config.AutoEnterDungeonToggle then
    autoEnterDungeon = true
    if DungeonGroupbox.Flags and DungeonGroupbox.Flags.AutoEnterDungeonToggle then
        DungeonGroupbox.Flags.AutoEnterDungeonToggle:Set(true)
    end
    monitorDungeonNotificationAndEnter()
end


-- Auto enter Restaurant Raid toggle
RaidDefense:AddToggle(
    "AutoEnterRestaurantRaidToggle",
    {
        Text = "Auto Enter Restaurant Raid",
        Default = config.AutoEnterRestaurantRaidToggle or false,
        Tooltip = "Automatically enters Restaurant Raid when not in dungeon.",
        Callback = function(Value)
            config.AutoEnterRestaurantRaidToggle = Value
            saveConfig()
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

-- Auto-start logic for AutoEnterRestaurantRaidToggle after reload
if config.AutoEnterRestaurantRaidToggle then
    if DungeonGroupbox.Flags and DungeonGroupbox.Flags.AutoEnterRestaurantRaidToggle then
        DungeonGroupbox.Flags.AutoEnterRestaurantRaidToggle:Set(true)
    end
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
end

-- Auto enter Ghoul Raid toggle
RaidDefense:AddToggle(
    "AutoEnterGhoulRaidToggle",
    {
        Text = "Auto Enter Ghoul Raid",
        Default = config.AutoEnterGhoulRaidToggle or false,
        Tooltip = "Automatically enters Ghoul Raid when not in dungeon.",
        Callback = function(Value)
            config.AutoEnterGhoulRaidToggle = Value
            saveConfig()
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
            config.AutoEnterProgressionRaidToggle = Value
            saveConfig()
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
            config.AutoEnterGleamRaidToggle = Value
            saveConfig()
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
            config.AutoEnterTournamentRaidToggle = Value
            saveConfig()
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
            config.AutoEnterCursedRaidToggle = Value
            saveConfig()
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
            config.AutoEnterChainsawDefenseToggle = Value
            saveConfig()
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
            config.AutoEnterTitanDefenseToggle = Value
            saveConfig()
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
            config.AutoEnterKaijuDungeonToggle = Value
            saveConfig()
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
            config.AutoEnterSinRaidToggle = Value
            saveConfig()
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

-- Auto-start logic for AutoEnterGhoulRaidToggle after reload
if config.AutoEnterGhoulRaidToggle then
    if RaidDefense.Flags and RaidDefense.Flags.AutoEnterGhoulRaidToggle then
        RaidDefense.Flags.AutoEnterGhoulRaidToggle:Set(true)
    end
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
end

-- Auto-start logic for AutoEnterProgressionRaidToggle after reload
if config.AutoEnterProgressionRaidToggle then
    if RaidDefense.Flags and RaidDefense.Flags.AutoEnterProgressionRaidToggle then
        RaidDefense.Flags.AutoEnterProgressionRaidToggle:Set(true)
    end
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
end

-- Auto-start logic for AutoEnterGleamRaidToggle after reload
if config.AutoEnterGleamRaidToggle then
    if RaidDefense.Flags and RaidDefense.Flags.AutoEnterGleamRaidToggle then
        RaidDefense.Flags.AutoEnterGleamRaidToggle:Set(true)
    end
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
end

-- Auto-start logic for AutoEnterTournamentRaidToggle after reload
if config.AutoEnterTournamentRaidToggle then
    if RaidDefense.Flags and RaidDefense.Flags.AutoEnterTournamentRaidToggle then
        RaidDefense.Flags.AutoEnterTournamentRaidToggle:Set(true)
    end
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
end

-- Auto-start logic for AutoEnterCursedRaidToggle after reload
if config.AutoEnterCursedRaidToggle then
    if RaidDefense.Flags and RaidDefense.Flags.AutoEnterCursedRaidToggle then
        RaidDefense.Flags.AutoEnterCursedRaidToggle:Set(true)
    end
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
end

-- Auto-start logic for AutoEnterChainsawDefenseToggle after reload
if config.AutoEnterChainsawDefenseToggle then
    if RaidDefense.Flags and RaidDefense.Flags.AutoEnterChainsawDefenseToggle then
        RaidDefense.Flags.AutoEnterChainsawDefenseToggle:Set(true)
    end
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
end

-- Auto-start logic for AutoEnterTitanDefenseToggle after reload
if config.AutoEnterTitanDefenseToggle then
    if RaidDefense.Flags and RaidDefense.Flags.AutoEnterTitanDefenseToggle then
        RaidDefense.Flags.AutoEnterTitanDefenseToggle:Set(true)
    end
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
end

-- Auto-start logic for AutoEnterKaijuDungeonToggle after reload
if config.AutoEnterKaijuDungeonToggle then
    if RaidDefense.Flags and RaidDefense.Flags.AutoEnterKaijuDungeonToggle then
        RaidDefense.Flags.AutoEnterKaijuDungeonToggle:Set(true)
    end
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
end

-- Auto-start logic for AutoEnterSinRaidToggle after reload
if config.AutoEnterSinRaidToggle then
    if RaidDefense.Flags and RaidDefense.Flags.AutoEnterSinRaidToggle then
        RaidDefense.Flags.AutoEnterSinRaidToggle:Set(true)
    end
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
end

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
    ["Hollow World"] = "Hollow_World"
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
            "Hollow World"
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
            config.MainTeleportDropdown = selected
            saveConfig()
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
        if not config.AutoLeaveWaveToggle then return end
        
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
        
        while config.AutoLeaveWaveToggle do
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
        config.AutoLeaveWaveToggle = Value
        saveConfig()
        if Value then
            startHeaderWatcher()
        else
            stopHeaderWatcher()
        end
    end
})

-- Auto-start logic for AutoLeaveWaveToggle after reload
if config.AutoLeaveWaveToggle then
    if AdjustDungeon.Flags and AdjustDungeon.Flags.AutoLeaveWaveToggle then
        AdjustDungeon.Flags.AutoLeaveWaveToggle:Set(true)
    end
    startHeaderWatcher()
end

-- Dropdown UI
AdjustDungeon:AddDropdown("WaveDropdown", {
    Title = "Leave at Wave",
    Values = {"10", "20", "30", "50", "80", "100", "200", "300", "500", "800", "1000", "1100", "1200", "1300", "1400", "1500", "1600", "1700", "1800", "1900", "2000"},
    Multi = false,
    Default = tostring(config.LeaveWave or 500),
    Callback = function(Value)
        LeaveWave = tonumber(Value)
        config.LeaveWave = LeaveWave
        saveConfig()
    end
})

---========================================== Tab: Rolls 2 - Breathings, Shadows, Titans ==========================================---
-- Dropdown for Breathings selection
local autoRollBreathing = false
local selectedWeaponUniqueId = nil

local function shortenUniqueId(uniqueId)
    return string.sub(uniqueId, 1, 4) -- first 4 characters only
end

local function getWeaponOptions()
    local equippedOptions = {}
    local unequippedOptions = {}
    local weaponList = game:GetService("Players").LocalPlayer.PlayerGui.Inventory_1.Hub.Weapons.List_Frame.List

    for _, weaponBtn in ipairs(weaponList:GetChildren()) do
        if weaponBtn:IsA("ImageButton") then
            local inside = weaponBtn:FindFirstChild("Inside")
            local titleObj = inside and inside:FindFirstChild("Title")
            local equippedObj = inside and inside:FindFirstChild("Equipped")

            -- Skip certain weapons
            if not (titleObj and (titleObj.Text == "Yellow Nichirin" or titleObj.Text == "Zangetso")) then
                local displayName = titleObj and titleObj.Text or weaponBtn.Name
                local shortId = shortenUniqueId(weaponBtn.Name)

                -- Build the text: EQUIPPED first, then name, then short id
                local optionText
                if equippedObj and equippedObj:IsA("ImageLabel") and equippedObj.Visible == true then
                    optionText = string.format("EQUIPPED %s [%s]", displayName, shortId)
                    table.insert(equippedOptions, optionText)
                else
                    optionText = string.format("%s [%s]", displayName, shortId)
                    table.insert(unequippedOptions, optionText)
                end
            end
        end
    end

    -- Equipped first, then the rest
    for _, opt in ipairs(unequippedOptions) do
        table.insert(equippedOptions, opt)
    end
    return equippedOptions
end

RollBreathing:AddDropdown(
    "WeaponDropdown",
    {
        Text = "Select Weapon",
        Values = getWeaponOptions(),
        Multi = false,
        Default = nil,
        Tooltip = "Select which weapon to use for rolling Breathings.",
        Callback = function(selected)
            if selected then
                local shortId = selected:match("%[(.-)%]") -- get short id inside brackets
                local weaponList = game:GetService("Players").LocalPlayer.PlayerGui.Inventory_1.Hub.Weapons.List_Frame.List
                for _, weaponBtn in ipairs(weaponList:GetChildren()) do
                    if weaponBtn:IsA("ImageButton") and string.sub(weaponBtn.Name, 1, 4) == shortId then
                        selectedWeaponUniqueId = weaponBtn.Name
                        break
                    end
                end
            else
                selectedWeaponUniqueId = nil
            end
        end
    }
)

RollBreathing:AddToggle(
    "AutoRollBreathingToggle",
    {
        Text = "Auto Roll Breathings",
        Default = false,
        Tooltip = "Automatically rolls for Breathings on selected weapon.",
        Callback = function(Value)
            autoRollBreathing = Value
            if Value then
                task.spawn(function()
                    while autoRollBreathing do
                        local args = {
                            [1] = {
                                ["Type"] = "Enchant",
                                ["Action"] = "Enchantment",
                                ["Desired"] = {},
                                ["Enchantment_Name"] = "Breathings",
                                ["UniqueId"] = selectedWeaponUniqueId or "8391-f6cc7a10bb8126596cb65bdc4c39",
                            }
                        }
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
                        ToServer:FireServer(unpack(args))
                        task.wait(1)
                    end
                end)
            end
        end
    }
)


-- Shadow Leveling Automation
local autoRollShadowLeveling = false
local selectedShadowUniqueId = nil

-- We'll store a mapping of displayText -> full uniqueId
local shadowIdMap = {}

local function shortenUniqueId(uniqueId)
    return string.sub(uniqueId, 1, 4) -- first 4 characters for display
end

local function getShadowOptions()
    local shadowList = game:GetService("Players").LocalPlayer.PlayerGui.Inventory_1.Hub.Shadows.List_Frame.List
    local equippedOptions = {}
    local unequippedOptions = {}
    shadowIdMap = {} -- reset mapping

    for _, shadowBtn in ipairs(shadowList:GetChildren()) do
        if shadowBtn.Name:find("%-") then -- only valid shadow entries
            local displayName = shadowBtn.Name
            local titleObj = shadowBtn:FindFirstChild("Inside") and shadowBtn.Inside:FindFirstChild("Title")
            if titleObj and titleObj:IsA("TextLabel") then
                displayName = titleObj.Text
            end

            -- ✅ Get level text, strip any existing "Lv." prefix
            local levelNumber = ""
            local levelObj = shadowBtn:FindFirstChild("Inside") and shadowBtn.Inside:FindFirstChild("Level")
            if levelObj and levelObj:IsA("TextLabel") then
                levelNumber = levelObj.Text:gsub("Lv%.", "") -- remove "Lv." if present
                levelNumber = levelNumber:gsub("[^%d]", "")  -- keep only numbers
            end

            -- Detect equipped state
            local insideEquippedObj = shadowBtn:FindFirstChild("Inside") and shadowBtn.Inside:FindFirstChild("Equipped")
            local isEquipped = insideEquippedObj and insideEquippedObj:IsA("ImageLabel") and insideEquippedObj.Visible

            local shortId = shortenUniqueId(shadowBtn.Name)

            -- ✅ Build display text cleanly (only one "Lv.")
            local optionText
            if isEquipped then
                optionText = string.format("EQUIPPED Lv.%s %s [%s]", levelNumber, displayName, shortId)
                table.insert(equippedOptions, optionText)
            else
                optionText = string.format("Lv.%s %s [%s]", levelNumber, displayName, shortId)
                table.insert(unequippedOptions, optionText)
            end

            -- Store mapping of display -> full uniqueId
            shadowIdMap[optionText] = shadowBtn.Name
        end
    end

    -- Equipped first, unequipped after
    for _, opt in ipairs(unequippedOptions) do
        table.insert(equippedOptions, opt)
    end
    return equippedOptions
end

RollShadow:AddDropdown("ShadowLevelingDropdown", {
    Text = "Select Shadow",
    Values = getShadowOptions(),
    Multi = false,
    Default = nil,
    Tooltip = "Select which shadow to auto level.",
    Callback = function(selected)
        if selected then
            selectedShadowUniqueId = shadowIdMap[selected] -- get full uniqueId
        else
            selectedShadowUniqueId = nil
        end
    end
})


RollShadow:AddToggle("AutoRollShadowLevelingToggle", {
    Text = "Auto Roll Shadow Leveling",
    Default = false,
    Tooltip = "Automatically levels up the selected shadow.",
    Callback = function(Value)
        autoRollShadowLeveling = Value
        if Value then
            task.spawn(function()
                while autoRollShadowLeveling do
                    if selectedShadowUniqueId and selectedShadowUniqueId ~= "" then
                        local args = {
                            [1] = {
                                ["Bench_Name"] = "Shadow_Leveling",
                                ["UniqueId"] = selectedShadowUniqueId,
                                ["Action"] = "Prog_Lv_Items",
                                ["Upgrade_Name"] = "Level"
                            }
                        }
                        pcall(function()
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- Titan Injection Automation
local autoTitanInjection = false
local selectedTitanUniqueId = nil

-- Store mapping of displayText -> full uniqueId
local titanIdMap = {}

local function shortenUniqueId(uniqueId)
    return string.sub(uniqueId, 1, 4)
end

local function getTitanOptions()
    local titanList = game:GetService("Players").LocalPlayer.PlayerGui.Inventory_1.Hub.Titans.List_Frame.List
    local equippedOptions = {}
    local unequippedOptions = {}
    titanIdMap = {} -- reset mapping

    for _, titanBtn in ipairs(titanList:GetChildren()) do
        if titanBtn.Name:find("%-") then
            local displayName = titanBtn.Name
            local titleObj = titanBtn:FindFirstChild("Inside") and titanBtn.Inside:FindFirstChild("Title")
            if titleObj and titleObj:IsA("TextLabel") then
                displayName = titleObj.Text
            end

            -- Detect equipped state
            local insideEquippedObj = titanBtn:FindFirstChild("Inside") and titanBtn.Inside:FindFirstChild("Equipped")
            local isEquipped = insideEquippedObj and insideEquippedObj:IsA("ImageLabel") and insideEquippedObj.Visible

            local shortId = shortenUniqueId(titanBtn.Name)

            local optionText
            if isEquipped then
                optionText = string.format("EQUIPPED %s [%s]", displayName, shortId)
                table.insert(equippedOptions, optionText)
            else
                optionText = string.format("%s [%s]", displayName, shortId)
                table.insert(unequippedOptions, optionText)
            end

            titanIdMap[optionText] = titanBtn.Name
        end
    end

    for _, opt in ipairs(unequippedOptions) do
        table.insert(equippedOptions, opt)
    end
    return equippedOptions
end

local function updateTitanDropdown()
    local dropdown = RollShadow.Flags and RollShadow.Flags.TitanInjectionDropdown
    if dropdown then
        local newValues = getTitanOptions()
        if typeof(dropdown.SetValues) == "function" then
            dropdown:SetValues(newValues)
        elseif typeof(dropdown.Values) == "table" then
            dropdown.Values = newValues
        end
    end
end

-- Dropdown for selecting Titan
RollTitan:AddDropdown("TitanInjectionDropdown", {
    Text = "Select Titan",
    Values = getTitanOptions(),
    Multi = false,
    Default = nil,
    Tooltip = "Select which Titan to inject.",
    Callback = function(selected)
        if selected then
            selectedTitanUniqueId = titanIdMap[selected]
        else
            selectedTitanUniqueId = nil
        end
    end
})


-- Toggle for auto Titan injection
RollTitan:AddToggle("AutoTitanInjectionToggle", {
    Text = "Auto Titan Injection",
    Default = false,
    Tooltip = "Automatically injects selected Titan.",
    Callback = function(Value)
        autoTitanInjection = Value
        if Value then
            task.spawn(function()
                while autoTitanInjection do
                    if selectedTitanUniqueId and selectedTitanUniqueId ~= "" then
                        local args = {
                            [1] = {
                                ["Type"] = "Enchant",
                                ["Action"] = "Enchantment",
                                ["Enchantment_Name"] = "Titan_Injection",
                                ["UniqueId"] = selectedTitanUniqueId
                            }
                        }
                        pcall(function()
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events", 9e9)
                                :WaitForChild("To_Server", 9e9)
                                :FireServer(unpack(args))
                        end)
                    end
                    task.wait(1)
                end
            end)
        end
    end
})



---========================================== Tab: Auto Rolls ==========================================---

-- Auto Roll Feature
RollGroupbox:AddToggle(
    "AutoRollStarsToggle",
    {
    Text = "Stars",
    Default = config.AutoRollStarsToggle ~= nil and config.AutoRollStarsToggle or autoRollEnabled,
        Tooltip = "Automatically rolls for stars.",
        Callback = function(Value)
            autoRollEnabled = Value
            config.AutoRollStarsToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    while getgenv().SeisenHubRunning and autoRollEnabled do
                        pcall(function()
                            local cacheArgs = {
                                [1] = {
                                    ["Action"] = "Star_Cache_Request",
                                    ["Name"] = selectedStar
                                }
                            }
                            ToServer:FireServer(unpack(cacheArgs))
                            local rollArgs = {
                                [1] = {
                                    ["Open_Amount"] = 20,
                                    ["Action"] = "_Stars",
                                    ["Name"] = selectedStar
                                }
                            }
                            ToServer:FireServer(unpack(rollArgs))
                        end)
                        task.wait(delayBetweenRolls)
                    end
                end)
            end
        end
    }
)

local placeToStar = {
    ["Earth City"] = "Star_1",
    ["Windmill Island"] = "Star_2",
    ["Soul Society"] = "Star_3",
    ["Cursed School"] = "Star_4",
    ["Slayer Village"] = "Star_5",
    ["Solo Island"] = "Star_6",
    ["Clover Village"] = "Star_7",
    ["Leaf Village"] = "Star_8",
    ["Spirit Residence"] = "Star_9",
    ["Magic_Hunter_City"] = "Star_10",
    ["Titan City"] = "Star_11",
    ["Village of Sins"] = "Star_12",
    ["Kaiju Base"] = "Star_13",
    ["Tempest Capital"] = "Star_14",
    ["Virtual City"] = "Star_15",
    ["Cairo"] = "Star_16",
    ["Ghoul City"] = "Star_17",
    ["Chainsaw City"] = "Star_18",
    ["Tokyo Empire"] = "Star_19",
    ["Green Planet"] = "Star_20",
    ["Hollow World"] = "Star_21"
}
local starToPlace = {}
for place, star in pairs(placeToStar) do
    starToPlace[star] = place
end
-- Select Star Dropdown
RollGroupbox:AddDropdown(
    "SelectStarDropdown",
    {
        Values = {
            "Earth City",
            "Windmill Island",
            "Soul Society",
            "Cursed School",
            "Slayer Village",
            "Solo Island",
            "Clover Village",
            "Leaf Village",
            "Spirit Residence",
            "Magic_Hunter_City",
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
            "Hollow World"
        },
    Default = config.SelectStarDropdown ~= nil and starToPlace[config.SelectStarDropdown] or starToPlace[selectedStar] or "Earth City",
        Multi = false,
        Text = "Select Star (by Place)",
        Callback = function(Option)
            selectedStar = placeToStar[Option] or "Star_1"
            config.SelectStarDropdown = selectedStar
            saveConfig()
        end
    }
)

-- Delay Slider
RollGroupbox:AddSlider("DelayBetweenRollsSlider", {
    Text = "Delay Between Rolls",
    Min = 0.1,
    Max = 2,
    Default = config.DelayBetweenRollsSlider ~= nil and config.DelayBetweenRollsSlider or delayBetweenRolls,
    Rounding = 1, -- ✅ important for 0.1 steps
    Suffix = "s",
    Callback = function(Value)
        delayBetweenRolls = Value
        config.DelayBetweenRollsSlider = Value
        saveConfig()
    end
})

-- Auto Delete Toggle
AutoDeleteGroupbox:AddToggle(
    "AutoDeleteUnitsToggle",
    {
        Text = "Auto Delete Units",
    Default = config.AutoDeleteUnitsToggle ~= nil and config.AutoDeleteUnitsToggle or autoDeleteEnabled,
        Callback = function(Value)
            autoDeleteEnabled = Value
            config.AutoDeleteUnitsToggle = Value
            saveConfig()
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
                                        ["6"] = {"70006"}
                                    },
                                    ["Star_2"] = {
                                        ["1"] = {"70008"},
                                        ["2"] = {"70009"},
                                        ["3"] = {"70010"},
                                        ["4"] = {"70011"},
                                        ["5"] = {"70012"},
                                        ["6"] = {"70013"}
                                    },
                                    ["Star_3"] = {
                                        ["1"] = {"70015"},
                                        ["2"] = {"70016"},
                                        ["3"] = {"70017"},
                                        ["4"] = {"70018"},
                                        ["5"] = {"70019"},
                                        ["6"] = {"70020"}
                                    },
                                    ["Star_4"] = {
                                        ["1"] = {"70022"},
                                        ["2"] = {"70023"},
                                        ["3"] = {"70024"},
                                        ["4"] = {"70025"},
                                        ["5"] = {"70026"},
                                        ["6"] = {"70027"}
                                    },
                                    ["Star_5"] = {
                                        ["1"] = {"70029"},
                                        ["2"] = {"70030"},
                                        ["3"] = {"70031"},
                                        ["4"] = {"70032"},
                                        ["5"] = {"70033"},
                                        ["6"] = {"70034"}
                                    },
                                    ["Star_6"] = {
                                        ["1"] = {"70036"},
                                        ["2"] = {"70037"},
                                        ["3"] = {"70038"},
                                        ["4"] = {"70039"},
                                        ["5"] = {"70040"},
                                        ["6"] = {"70041"}
                                    },
                                    ["Star_7"] = {
                                        ["1"] = {"70043"},
                                        ["2"] = {"70044"},
                                        ["3"] = {"70045"},
                                        ["4"] = {"70046"},
                                        ["5"] = {"70047"},
                                        ["6"] = {"70048"}
                                    },
                                    ["Star_8"] = {
                                        ["1"] = {"70050"},
                                        ["2"] = {"70051"},
                                        ["3"] = {"70052"},
                                        ["4"] = {"70053"},
                                        ["5"] = {"70054"},
                                        ["6"] = {"70055"}
                                    },
                                    ["Star_9"] = {
                                        ["1"] = {"70057"},
                                        ["2"] = {"70058"},
                                        ["3"] = {"70059"},
                                        ["4"] = {"70060"},
                                        ["5"] = {"70061"},
                                        ["6"] = {"70062"}
                                    },
                                    ["Star_10"] = {
                                        ["1"] = {"70064"},
                                        ["2"] = {"70065"},
                                        ["3"] = {"70066"},
                                        ["4"] = {"70067"},
                                        ["5"] = {"70068"},
                                        ["6"] = {"70069"}
                                    },
                                    ["Star_11"] = {
                                        ["1"] = {"70071"},
                                        ["2"] = {"70072"},
                                        ["3"] = {"70073"},
                                        ["4"] = {"70074"},
                                        ["5"] = {"70075"},
                                        ["6"] = {"70076"}
                                    },
                                    ["Star_12"] = {
                                        ["1"] = {"70078"},
                                        ["2"] = {"70079"},
                                        ["3"] = {"70080"},
                                        ["4"] = {"70081"},
                                        ["5"] = {"70082"},
                                        ["6"] = {"70083"}
                                    },
                                    ["Star_13"] = {
                                        ["1"] = {"70085"},
                                        ["2"] = {"70086"},
                                        ["3"] = {"70087"},
                                        ["4"] = {"70088"},
                                        ["5"] = {"70089"},
                                        ["6"] = {"70090"}
                                    },
                                    ["Star_14"] = {
                                        ["1"] = {"70092"},
                                        ["2"] = {"70093"},
                                        ["3"] = {"70094"},
                                        ["4"] = {"70095"},
                                        ["5"] = {"70096"},
                                        ["6"] = {"70097"}
                                    },
                                    ["Star_15"] = {
                                        ["1"] = {"70099"},
                                        ["2"] = {"70100"},
                                        ["3"] = {"70101"},
                                        ["4"] = {"70102"},
                                        ["5"] = {"70103"},
                                        ["6"] = {"70104"}
                                    },
                                    ["Star_16"] = {
                                        ["1"] = {"70106"},
                                        ["2"] = {"70107"},
                                        ["3"] = {"70108"},
                                        ["4"] = {"70109"},
                                        ["5"] = {"70110"},
                                        ["6"] = {"70111"}
                                    },
                                    ["Star_17"] = {
                                        ["1"] = {"70113"},
                                        ["2"] = {"70114"},
                                        ["3"] = {"70115"},
                                        ["4"] = {"70116"},
                                        ["5"] = {"70117"},
                                        ["6"] = {"70118"}
                                    },
                                    ["Star_18"] = {
                                        ["1"] = {"70120"},
                                        ["2"] = {"70121"},
                                        ["3"] = {"70122"},
                                        ["4"] = {"70123"},
                                        ["5"] = {"70124"},
                                        ["6"] = {"70125"}
                                    },
                                    ["Star_19"] = {
                                        ["1"] = {"70127"},
                                        ["2"] = {"70128"},
                                        ["3"] = {"70129"},
                                        ["4"] = {"70130"},
                                        ["5"] = {"70131"},
                                        ["6"] = {"70132"}
                                    },
                                    ["Star_20"] = {
                                        ["1"] = {"70134"},
                                        ["2"] = {"70135"},
                                        ["3"] = {"70136"},
                                        ["4"] = {"70137"},
                                        ["5"] = {"70138"},
                                        ["6"] = {"70139"}
                                    },
                                    ["Star_21"] = {
                                        ["1"] = {"70141"},
                                        ["2"] = {"70142"},
                                        ["3"] = {"70143"},
                                        ["4"] = {"70144"},
                                        ["5"] = {"70145"},
                                        ["6"] = {"70146"}
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
                saveConfig()
        end
    }
)

-- Select Star for Auto Delete Dropdown
AutoDeleteGroupbox:AddDropdown(
    "SelectDeleteStarDropdown",
    {
        Values = {
            "Earth City",
            "Windmill Island",
            "Soul Society",
            "Cursed School",
            "Slayer Village",
            "Solo Island",
            "Clover Village",
            "Leaf Village",
            "Spirit Residence",
            "Magic_Hunter_City",
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
            "Hollow World"
        },
    Default = config.SelectDeleteStarDropdown ~= nil and starToPlace[config.SelectDeleteStarDropdown] or starToPlace[selectedDeleteStar] or "Earth City",
        Multi = false,
        Text = "Select Star for Auto Delete (by Place)",
        Callback = function(Option)
            selectedDeleteStar = placeToStar[Option] or "Star_1"
            config.SelectDeleteStarDropdown = selectedDeleteStar
            saveConfig()
        end
    }
)

local rarityMap = {
    Common = "1",
    Uncommon = "2",
    Rare = "3",
    Epic = "4",
    Legendary = "5",
    Mythical = "6"
}
for _, displayName in ipairs(selectedRaritiesDisplay) do
    if rarityMap[displayName] then
        selectedRarities[rarityMap[displayName]] = true
    end
end

-- Auto Delete Rarities Dropdown
AutoDeleteGroupbox:AddDropdown(
    "AutoDeleteRaritiesDropdown",
    {
        Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"},
    Default = config.AutoDeleteRaritiesDropdown ~= nil and config.AutoDeleteRaritiesDropdown or selectedRaritiesDisplay,
        Multi = true,
        Text = "Select Rarities to Delete",
        Callback = function(Selected)
            selectedRarities = {}
            for displayName, _ in pairs(Selected) do
                if rarityMap[displayName] then
                    selectedRarities[rarityMap[displayName]] = true
                end
            end
            config.AutoDeleteRaritiesDropdown = {}
            for displayName, _ in pairs(Selected) do
                table.insert(config.AutoDeleteRaritiesDropdown, displayName)
            end
            saveConfig()
        end
    }
)

-- Titan auto-delete dropdown
AutoDeleteTitan:AddDropdown(
    "AutoDeleteTitanRaritiesDropdown",
    {
        Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret"},
        Default = config.AutoDeleteTitanRaritiesDropdown ~= nil and config.AutoDeleteTitanRaritiesDropdown or selectedTitanRaritiesDisplay,
        Multi = true,
        Text = "Select Titan Rarities to Delete",
        Callback = function(Selected)
            selectedTitanRarities = {}
            for displayName, _ in pairs(Selected) do
                if titanRarityMap[displayName] then
                    selectedTitanRarities[titanRarityMap[displayName]] = true
                end
            end
            config.AutoDeleteTitanRaritiesDropdown = {}
            for displayName, _ in pairs(Selected) do
                table.insert(config.AutoDeleteTitanRaritiesDropdown, displayName)
            end
            saveConfig()
        end
    }
)


AutoDeleteGroupbox2:AddToggle(
    "AutoDeleteGachaUnitsToggle",
    {
        Text = "Auto Weapon Units",
    Default = config.AutoDeleteGachaUnitsToggle ~= nil and config.AutoDeleteGachaUnitsToggle or false,
        Callback = function(Value)
            config.AutoDeleteGachaUnitsToggle = Value
            saveConfig()
            if Value then
                -- ✅ If enabled, start auto-delete loop
                task.spawn(function()
                    while config.AutoDeleteGachaUnitsToggle and getgenv().SeisenHubRunning do
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
                -- ✅ If disabled, send "false" to turn it off server-side
                for rarity, enabled in pairs(selectedGachaRarities) do
                    if enabled then
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
        end
    }
)

-- Titan auto-delete toggle
AutoDeleteTitan:AddToggle(
    "AutoDeleteTitanUnitsToggle",
    {
        Text = "Auto Titan Units",
        Default = config.AutoDeleteTitanUnitsToggle ~= nil and config.AutoDeleteTitanUnitsToggle or false,
        Callback = function(Value)
            config.AutoDeleteTitanUnitsToggle = Value
            saveConfig()
            if Value then
                -- ✅ If enabled, start auto-delete loop for titans
                task.spawn(function()
                    while config.AutoDeleteTitanUnitsToggle and getgenv().SeisenHubRunning do
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
                end)
            else
                -- ✅ If disabled, send "false" to turn it off server-side
                for rarity, enabled in pairs(selectedTitanRarities) do
                    if enabled then
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
        end
    }
)


AutoDeleteGroupbox2:AddDropdown(
    "AutoDeleteGachaRaritiesDropdown",
    {
        Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret"},
    Default = config.AutoDeleteGachaRaritiesDropdown ~= nil and config.AutoDeleteGachaRaritiesDropdown or selectedGachaRarities,
        Multi = true,
        Text = "Select Gacha Rarities to Delete",
        Callback = function(Selected)
            selectedGachaRarities = {}
            for displayName, _ in pairs(Selected) do
                if gachaRarityMap[displayName] then
                    selectedGachaRarities[gachaRarityMap[displayName]] = true
                end
            end
            config.AutoDeleteGachaRaritiesDropdown = {}
            for displayName, _ in pairs(Selected) do
                table.insert(config.AutoDeleteGachaRaritiesDropdown, displayName)
            end
            saveConfig()
        end
    }
)


RollGroupbox2:AddToggle(
    "AutoRollDragonRaceToggle",
    {
        Text = "Dragon Race",
        Default = autoRollDragonRaceEnabled,
        Tooltip = "Automatically rolls for Dragon Race.",
        Callback = function(Value)
            autoRollDragonRaceEnabled = Value
            config.AutoRollDragonRaceToggle = Value
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
                    while getgenv().SeisenHubRunning and autoRollDragonRaceEnabled do
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
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)


RollGroupbox2:AddToggle(
    "AutoRollSaiyanEvolutionToggle",
    {
        Text = "Saiyan Evolution",
        Default = autoRollSaiyanEvolutionEnabled,
        Tooltip = "Automatically rolls for Saiyan Evolution.",
        Callback = function(Value)
            autoRollSaiyanEvolutionEnabled = Value
            config.AutoRollSaiyanEvolutionToggle = Value
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
                    task.wait(1)
                    while getgenv().SeisenHubRunning and autoRollSaiyanEvolutionEnabled do
                        local args = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Saiyan_Evolution"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(args)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)


RollGroupbox2:AddToggle(
    "AutoRollSwordsToggle",
    {
        Text = "Swords",
        Default = autoRollSwordsEnabled,
        Callback = function(Value)
            autoRollSwordsEnabled = Value
            config.AutoRollSwordsToggle = Value
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
                    while getgenv().SeisenHubRunning and autoRollSwordsEnabled do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Swords"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollPirateCrewToggle",
    {
        Text = "Pirate Crew",
        Default = autoRollPirateCrewEnabled,
        Callback = function(Value)
            autoRollPirateCrewEnabled = Value
            config.AutoRollPirateCrewToggle = Value
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
                    while getgenv().SeisenHubRunning and autoRollPirateCrewEnabled do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Pirate_Crew"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollDemonFruitsToggle",
    {
        Text = "Demon Fruits",
        Default = autoRollDemonFruitsEnabled,
        Callback = function(Value)
            autoRollDemonFruitsEnabled = Value
            config.AutoRollDemonFruitsToggle = Value
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
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Demon_Fruits"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollReiatsuColorToggle",
    {
        Text = "Reiatsu Color",
        Default = autoRollReiatsuColorEnabled,
        Callback = function(Value)
            autoRollReiatsuColorEnabled = Value
            config.AutoRollReiatsuColorToggle = Value
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
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Reiatsu_Color"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollZanpakutoToggle",
    {
        Text = "Zanpakuto",
        Default = autoRollZanpakutoEnabled,
        Callback = function(Value)
            autoRollZanpakutoEnabled = Value
            config.AutoRollZanpakutoToggle = Value
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
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Zanpakuto"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollCursesToggle",
    {
        Text = "Curses",
        Default = autoRollCursesEnabled,
        Callback = function(Value)
            autoRollCursesEnabled = Value
            config.AutoRollCursesToggle = Value
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
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Curses"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollDemonArtsToggle",
    {
        Text = "Demon Arts",
        Default = autoRollDemonArtsEnabled,
        Callback = function(Value)
            autoRollDemonArtsEnabled = Value
            config.AutoRollDemonArtsToggle = Value
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
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Demon_Arts"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoSoloHunterRankToggle",
    {
        Text = "Solo Rank",
        Default = autoSoloHunterRankEnabled,
        Callback = function(Value)
            autoSoloHunterRankEnabled = Value
            config.AutoSoloHunterRankToggle = Value
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
                    task.wait(1)
                    while autoSoloHunterRankEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Solo_Hunter_Rank"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollGrimoireToggle",
    {
        Text = "Grimoire",
        Default = config.AutoRollGrimoireToggle or false,
        Callback = function(Value)
            config.AutoRollGrimoireToggle = Value
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
                    task.wait(1)
                    while config.AutoRollGrimoireToggle and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Grimoire"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

RollGroupbox2:AddToggle(
    "AutoRollPowerEyesToggle",
    {
        Text = "Power Eyes",
        Default = config.AutoRollPowerEyesToggle or false,
        Callback = function(Value)
            config.AutoRollPowerEyesToggle = Value
            saveConfig()
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
                    task.wait(1)
                    while config.AutoRollPowerEyesToggle and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Power_Eyes"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
        Default = autoPsychicMayhemEnabled,
        Tooltip = "Automatically buys and rolls Psychic Mayhem.",
        Callback = function(Value)
            autoPsychicMayhemEnabled = Value
            config.AutoPsychicMayhemToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Psychic_Mayhem_Unlock"
                        }
                    }
                    ToServer:FireServer(unpack(buyArgs))
                    task.wait(0.5)
                    while autoPsychicMayhemEnabled do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Psychic_Mayhem"
                            }
                        }
                        ToServer:FireServer(unpack(rollArgs))
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
        Default = autoRollEnergyCardEnabled,
        Tooltip = "Automatically unlocks and rolls Energy Card.",
        Callback = function(Value)
            autoRollEnergyCardEnabled = Value
            config.AutoRollEnergyCardToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Energy_Card_Shop_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollEnergyCardEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Energy_Card_Shop"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
        Default = autoRollDamageCardEnabled,
        Tooltip = "Automatically unlocks and rolls Damage Card.",
        Callback = function(Value)
            autoRollDamageCardEnabled = Value
            config.AutoRollDamageCardToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Damage_Card_Shop_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollDamageCardEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Damage_Card_Shop"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
        Default = autoRollFamiliesEnabled,
        Tooltip = "Automatically unlocks and rolls Families.",
        Callback = function(Value)
            autoRollFamiliesEnabled = Value
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Families_Unlock";
                        };
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollFamiliesEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Families"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
        Default = autoRollTitansEnabled,
        Tooltip = "Automatically unlocks and rolls Titans.",
        Callback = function(Value)
            autoRollTitansEnabled = Value
            config.AutoRollTitansToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Titans_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollTitansEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Titans"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
        Default = autoRollSinsEnabled,
        Tooltip = "Automatically unlocks and rolls Sins.",
        Callback = function(Value)
            autoRollSinsEnabled = Value
            config.AutoRollSinsToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Sins_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollSinsEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Sins"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
        Default = autoRollCommandmentsEnabled,
        Tooltip = "Automatically unlocks and rolls Commandments.",
        Callback = function(Value)
            autoRollCommandmentsEnabled = Value
            config.AutoRollCommandmentsToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Commandments_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollCommandmentsEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Commandments"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
        Default = autoRollKaijuPowersEnabled,
        Tooltip = "Automatically unlocks and upgrades Kaiju Powers.",
        Callback = function(Value)
            autoRollKaijuPowersEnabled = Value
            config.AutoRollKaijuPowersToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Kaiju_Powers_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollKaijuPowersEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Kaiju_Powers"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollAkumaPowersToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Akuma_Powers_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollAkumaPowersEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Akuma_Powers"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollSpeciesToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Species_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollSpeciesEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Species"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollUltimateSkillsToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Ultimate_Skills_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollUltimateSkillsEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Ultimate_Skills"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollPowerEnergyRunesToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Power_Energy_Runes_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollPowerEnergyRunesEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Power_Energy_Runes"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollStandsToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Stands_Unlock";
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollStandsEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Stands"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollOnomatopoeiaToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Upgrade_Name"] = "Onomatopoeia_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollOnomatopoeiaEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Onomatopoeia"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollKaguneToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Kagune_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollKaguneEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Kagune"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollInvestigatorToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Investigators_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollInvestigatorEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Investigators"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollDebiruHunterToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Debiru_Hunter_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollDebiruHunterEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Debiru_Hunter"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollSpecialFireForceToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock",
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Special_Fire_Force_Buy"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollSpecialFireForceEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Special_Fire_Force"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollMushiBiteToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Mushi_Bite_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollMushiBiteEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Mushi_Bite"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollGrandElderPowerToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Grand_Elder_Power_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollGrandElderPowerEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Grand_Elder_Power"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollFrostDemonEvolutionToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Frost_Demon_Evolution_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollFrostDemonEvolutionEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Frost_Demon_Evolution"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollScythesToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Scythes_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollScythesEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Scythes"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
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
            config.AutoRollEspadaToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local buyArgs = {
                        [1] = {
                            ["Upgrading_Name"] = "Unlock";
                            ["Action"] = "_Upgrades";
                            ["Name"] = "Espada_Unlock"
                        }
                    }
                    pcall(function() ToServer:FireServer(unpack(buyArgs)) end)
                    task.wait(1)
                    while autoRollEspadaEnabled and getgenv().SeisenHubRunning do
                        local rollArgs = {
                            [1] = {
                                ["Open_Amount"] = 10,
                                ["Action"] = "_Gacha_Activate",
                                ["Name"] = "Espada"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(rollArgs)) end)
                        task.wait(1)
                    end
                end)
            end
        end
    }
)

----========================================== Tab: Upgrades - Sin, Shadow Upgrades ==========================================---

-- Sin Upgrades Automation UI (FIXED)
SinUp:AddDropdown("SinUpgradeDropdown", {
    Title = "Select Sin Upgrades",
    Values = {"Energy", "Coins", "Star_Luck"},
    Default = config.SinUpgradeDropdown or {},
    Multi = true,
    Callback = function(selection)
        -- Make sure we store it as a proper table
        config.SinUpgradeDropdown = selection
        saveConfig()
    end
})

SinUp:AddToggle("AutoSinUpgradeToggle", {
    Text = "Auto Sin Upgrades",
    Default = config.AutoSinUpgradeToggle or false,
    Tooltip = "Automatically upgrades selected Sin Upgrades.",
    Callback = function(Value)
        config.AutoSinUpgradeToggle = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while config.AutoSinUpgradeToggle and getgenv().SeisenHubRunning do
                    local selected = config.SinUpgradeDropdown or {}

                    -- FIX: Iterate over multi-select dropdown properly
                    for upgradeName, isSelected in pairs(selected) do
                        if isSelected then
                            local args = {
                                [1] = {
                                    ["Upgrading_Name"] = upgradeName,
                                    ["Action"] = "_Upgrades",
                                    ["Upgrade_Name"] = "Sin_Upgrades"
                                }
                            }
                            pcall(function()
                                game:GetService("ReplicatedStorage")
                                    :WaitForChild("Events", 9e9)
                                    :WaitForChild("To_Server", 9e9)
                                    :FireServer(unpack(args))
                            end)
                        end
                    end

                    task.wait(0.5)
                end
            end)
        end
    end
})

-- Auto-start logic for Sin Upgrades after reload
if config.AutoSinUpgradeToggle then
    if UpgradeGroupbox.Flags and UpgradeGroupbox.Flags.AutoSinUpgradeToggle then
        UpgradeGroupbox.Flags.AutoSinUpgradeToggle:Set(true)
    end
    task.spawn(function()
        while config.AutoSinUpgradeToggle and getgenv().SeisenHubRunning do
            local selected = config.SinUpgradeDropdown or {}
            for upgradeName, isSelected in pairs(selected) do
                if isSelected then
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = upgradeName,
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Sin_Upgrades"
                        }
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end)
                end
            end
            task.wait(0.5)
        end
    end)
end


-- Shadow Upgrades Automation UI
ShadowUp:AddDropdown("ShadowUpgradeDropdown", {
    Title = "Select Shadow Upgrades",
    Values = {"Shadow_Soul", "Shadow_Extra_Equip","Shadows_Inventory_Slots"},
    Default = config.ShadowUpgradeDropdown or {},
    Multi = true,
    Callback = function(selection)
        config.ShadowUpgradeDropdown = selection
        saveConfig()
    end
})

ShadowUp:AddToggle("AutoShadowUpgradeToggle", {
    Text = "Auto Shadow Upgrades",
    Default = config.AutoShadowUpgradeToggle or false,
    Tooltip = "Automatically upgrades selected Shadow Upgrades.",
    Callback = function(Value)
        config.AutoShadowUpgradeToggle = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while config.AutoShadowUpgradeToggle and getgenv().SeisenHubRunning do
                    local selected = config.ShadowUpgradeDropdown or {}
                    for upgradeName, isSelected in pairs(selected) do
                        if isSelected then
                            local args = {
                                [1] = {
                                    ["Upgrading_Name"] = upgradeName,
                                    ["Action"] = "_Upgrades",
                                    ["Upgrade_Name"] = "Shadow_Upgrades"
                                }
                            }
                            pcall(function()
                                game:GetService("ReplicatedStorage")
                                    :WaitForChild("Events", 9e9)
                                    :WaitForChild("To_Server", 9e9)
                                    :FireServer(unpack(args))
                            end)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- Auto-start logic for Shadow Upgrades after reload
if config.AutoShadowUpgradeToggle then
    if UpgradeGroupbox.Flags and UpgradeGroupbox.Flags.AutoShadowUpgradeToggle then
        UpgradeGroupbox.Flags.AutoShadowUpgradeToggle:Set(true)
    end
    task.spawn(function()
        while config.AutoShadowUpgradeToggle and getgenv().SeisenHubRunning do
            local selected = config.ShadowUpgradeDropdown or {}
            for upgradeName, isSelected in pairs(selected) do
                if isSelected then
                    local args = {
                        [1] = {
                            ["Upgrading_Name"] = upgradeName,
                            ["Action"] = "_Upgrades",
                            ["Upgrade_Name"] = "Shadow_Upgrades"
                        }
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Events", 9e9)
                            :WaitForChild("To_Server", 9e9)
                            :FireServer(unpack(args))
                    end)
                end
            end
            task.wait(0.5)
        end
    end)
end

-- Auto Upgrade Feature
UpgradeGroupbox:AddToggle(
    "AutoUpgradeToggle",
    {
        Text = "Upgrade",
        Default = config.AutoUpgradeToggle or false,
        Tooltip = "Automatically upgrades your character's stats.",
        Callback = function(Value)
            autoUpgradeEnabled = Value
            config.AutoUpgradeToggle = Value
            saveConfig()
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

-- Auto-start logic for upgrade after reload
if config.AutoUpgradeToggle then
    autoUpgradeEnabled = true
    if UpgradeGroupbox.Flags and UpgradeGroupbox.Flags.AutoUpgradeToggle then
        UpgradeGroupbox.Flags.AutoUpgradeToggle:Set(true)
    end
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
                config[upgradeName .. "_Toggle"] = Value
                enabledUpgrades[upgradeName] = Value
                saveConfig()
            end
        }
    )
    enabledUpgrades[upgradeName] = config[upgradeName .. "_Toggle"] or false
end



Upgrade2:AddToggle(
    "AutoAttackRange2UpgradeToggle",
    {
        Text = "Attack Range 2 Upgrade",
        Default = config.AutoAttackRange2UpgradeToggle or false,
        Tooltip = "Automatically unlocks and upgrades Attack Range 2.",
        Callback = function(Value)
            config.AutoAttackRange2UpgradeToggle = Value
            saveConfig()
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
                    while config.AutoAttackRange2UpgradeToggle and getgenv().SeisenHubRunning do
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
                        task.wait(1)
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
        Default = autoAttackRangeUpgradeEnabled,
        Tooltip = "Automatically upgrades attack range.",
        Callback = function(Value)
            autoAttackRangeUpgradeEnabled = Value
            config.AutoAttackRangeUpgradeToggle = Value
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
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

Upgrade2:AddToggle(
    "AutoHakiUpgradeToggle",
    {
        Text = "Haki Upgrade",
        Default = autoHakiUpgradeEnabled,
        Tooltip = "Automatically upgrades Haki.",
        Callback = function(Value)
            autoHakiUpgradeEnabled = Value
            config.AutoHakiUpgradeToggle = Value
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
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

Upgrade2:AddToggle(
    "AutoSpiritualPressureUpgradeToggle",
    {
        Text = "Spiritual Pressure Upgrade",
        Default = autoSpiritualPressureUpgradeEnabled,
        Tooltip = "Automatically upgrades spiritual pressure.",
        Callback = function(Value)
            autoSpiritualPressureUpgradeEnabled = Value
            config.AutoSpiritualPressureUpgradeToggle = Value
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
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

Upgrade2:AddToggle(
    "AutoCursedProgressionUpgradeToggle",
    {
        Text = "Cursed Progression Upgrade",
        Default = autoCursedProgressionUpgradeEnabled,
        Tooltip = "Automatically upgrades cursed progression.",
        Callback = function(Value)
            autoCursedProgressionUpgradeEnabled = Value
            config.AutoCursedProgressionUpgradeToggle = Value
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
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

Upgrade2:AddToggle(
    "AutoReawakeningProgressionUpgradeToggle",
    {
        Text = "Reawakening Progression Upgrade",
        Default = autoReawakeningProgressionUpgradeEnabled,
        Tooltip = "Automatically upgrades reawakening progression.",
        Callback = function(Value)
            autoReawakeningProgressionUpgradeEnabled = Value
            config.AutoReawakeningProgressionUpgradeToggle = Value
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
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

Upgrade2:AddToggle(
    "AutoMonarchProgressionUpgradeToggle",
    {
        Text = "Monarch Progression Upgrade",
        Default = autoMonarchProgressionUpgradeEnabled,
        Tooltip = "Automatically upgrades monarch progression.",
        Callback = function(Value)
            autoMonarchProgressionUpgradeEnabled = Value
            config.AutoMonarchProgressionUpgradeToggle = Value
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
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
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
            config.AutoWaterSpiritProgressionUpgradeToggle = Value
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
                    while config.AutoWaterSpiritProgressionUpgradeToggle and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Water_Spirit",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Water_Spirit_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
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
            config.AutoWindSpiritProgressionUpgradeToggle = Value
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
                    while config.AutoWindSpiritProgressionUpgradeToggle and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Wind_Spirit",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Wind_Spirit_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
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
            config.AutoFireSpiritProgressionUpgradeToggle = Value
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
                    while config.AutoFireSpiritProgressionUpgradeToggle and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrading_Name"] = "Fire_Spirit",
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Fire_Spirit_Progression"
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

Upgrade2:AddToggle(
    "AutoChakraProgressionUpgradeToggle",
    {
        Text = "Chakra Progression Upgrade",
        Default = autoChakraProgressionUpgradeEnabled,
        Tooltip = "Automatically upgrades chakra progression.",
        Callback = function(Value)
            autoChakraProgressionUpgradeEnabled = Value
            config.AutoChakraProgressionUpgradeToggle = Value
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
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

Upgrade2:AddToggle(
    "AutoSpiritualUpgradeToggle",
    {
        Text = "Spiritual Upgrade",
        Default = autoSpiritualUpgradeEnabled,
        Tooltip = "Automatically unlocks and upgrades spiritual upgrade.",
        Callback = function(Value)
            autoSpiritualUpgradeEnabled = Value
            config.AutoSpiritualUpgradeToggle = Value
            saveConfig()
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
                        task.wait(1)
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
        Default = autoLuckySpiritUpgradeEnabled,
        Tooltip = "Automatically upgrades Lucky Spirit.",
        Callback = function(Value)
            autoLuckySpiritUpgradeEnabled = Value
            config.AutoLuckySpiritUpgradeToggle = Value
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
                        task.wait(1)
                    end
                end)
            end
            saveConfig()
        end
    }
)

Upgrade2:AddToggle(
    "AutoTenProgressionUpgradeToggle",
    {
        Text = "Ten Progression Upgrade",
        Default = autoTenProgressionUpgradeEnabled,
        Tooltip = "Automatically upgrades Ten Progression.",
        Callback = function(Value)
            autoTenProgressionUpgradeEnabled = Value
            config.AutoTenProgressionUpgradeToggle = Value
            saveConfig()
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
                        task.wait(1)
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
        Default = autoContractOfGreedUpgradeEnabled,
        Tooltip = "Automatically upgrades Contract of Greed.",
        Callback = function(Value)
            autoContractOfGreedUpgradeEnabled = Value
            config.AutoContractOfGreedUpgradeToggle = Value
            saveConfig()
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
                        task.wait(1)
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
        Default = autoEnergyProgressionUpgradeEnabled,
        Tooltip = "Automatically upgrades Energy Progression.",
        Callback = function(Value)
            autoEnergyProgressionUpgradeEnabled = Value
            config.AutoEnergyProgressionUpgradeToggle = Value
            saveConfig()
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
                        task.wait(1)
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
            config.AutoFortitudeLevelUpgradeToggle = Value
            saveConfig()
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
                    while config.AutoFortitudeLevelUpgradeToggle and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Strenght",
                                ["Action"] = "_Progression",
                                ["Bench_Name"] = "Fortitude_Level",
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(1)
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
            config.AutoKaijuEnergyUpgradeToggle = Value
            saveConfig()
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
                    while config.AutoKaijuEnergyUpgradeToggle and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy",
                                ["Action"] = "_Progression",
                                ["Bench_Name"] = "Kaiju_Energy",
                            }
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(1)
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
            config.AutoDemonLordDamageUpgradeToggle = Value
            saveConfig()
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
                    while config.AutoDemonLordDamageUpgradeToggle and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Damage";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Demon_Lord_Damage";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(1)
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
            config.AutoDemonLordEnergyUpgradeToggle = Value
            saveConfig()
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
                    while config.AutoDemonLordEnergyUpgradeToggle and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Energy";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Demon_Lord_Energy";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(1)
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
            config.AutoDemonLordLuckUpgradeToggle = Value
            saveConfig()
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
                    while config.AutoDemonLordLuckUpgradeToggle and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Luck";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Demon_Lord_Luck";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(1)
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
            config.AutoDemonLordCoinsUpgradeToggle = Value
            saveConfig()
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
                    while config.AutoDemonLordCoinsUpgradeToggle and getgenv().SeisenHubRunning do
                        local upgradeArgs = {
                            [1] = {
                                ["Upgrade_Name"] = "Coins";
                                ["Action"] = "_Progression";
                                ["Bench_Name"] = "Demon_Lord_Coins";
                            };
                        }
                        pcall(function() ToServer:FireServer(unpack(upgradeArgs)) end)
                        task.wait(1)
                    end
                end)
            end
        end
    }
)


----========================================== Tab: Shops - Exchange, Tokens, Potions =======================================----
local shopProducts = {
    [ExchangeW1t5] = {
        name = "Exchange_Shop_World_1_to_5",
        items = {
            "Green Upgrade Token", "Dragon Race Token", "Saiyan Token",
            "Sword Token", "Pirate Crew Token", "Demon Fruit Token",
            "Haki Token", "Reiatsu Color Token", "Zanpakuto Token",
            "Pressure Token", "Cursed Token", "Cursed Finger",
            "Breathing Token", "Demon Art Token",
        }
    },
    [ExchangeW6t10] = {
        name = "Exchange_Shop_World_6_to_10",
        items = {
            "Hunter Rank Token", "ReAwakening Token", "Monarch Token", "Grimoire Token",
            "Water Spirit Token", "Wind Spirit Token", "Fire Spirit Token", "Chakra Token",
            "Eye Token", "Granny Token", "Gold Ball Token", "Energy TCG Token",
            "Damage TCG Token", "Ten Token", "Lucky Spirit Token", "Greedy Token",
        }
    },
    [ExchangeW11t15] = {
        name = "Exchange_Shop_World_11_to_15",
        items = {
            "Families Token", "Titan Token", "Spinal Fluid Token", "Sins Token",
            "Commandments Token", "Fortitude Token", "Kaiju Token", "Kaiju Energy Token",
            "Ultimate Skill Token", "Species Token", "Demon Energy Token",
            "Demon Damage Token", "Demon Luck Token", "Demon Coins Token",
            "Energy Rune Token", "Weapon Rune Token", "Swordsman Energy Token",
            "Swordsman Damage Token",
        }
    },
    [ExchangeW16t20] = {
        name = "Exchange_Shop_World_16_to_20",
        items = {
            "Stand Token", "Ripple Token", "Onomatopoeia Token", "Requiem Token",
            "CCG Token", "Kagune Token", "Kakuhou Token", "Flesh Token",
            "Debiru Token", "Akuma Token", "Akuma Damage Token", "Akuma Energy Token",
            "Pokita Token", "Mushi Token", "Infernal Token", "Flare Token", "Ignition Token",
            "HellFire Token", "Adolla Token", "Fire Company Token", "Adolla Blessing Token",
        }
    },
    [ExchangeKeys] = {
        name = "Exchange_Keys",
        items = {
            "Tournament Key","Restaurant Key","Progression Key","Titan Defense Key",
            "Kaiju Key","Gleam Key","Ghoul Key","Chainsaw Key","Progression Key 2",
            "Cursed Key", "Netherworld Key", "Sin Key",
        }
    },
    [ExchangePotion] = {
        name = "Exchange_Potion",
        items = {"Coins Potion","Damage Potion","Energy Potion","Luck Potion","Exp Potion","Soul Potion","Stats Reset",
        "Attack Range Potion 1","Small Coins Potion","Small Damage Potion","Small Energy Potion","Small Luck Potion",
        "Small Coins to Coins Potion","Small Damage to Damage Potion","Small Energy to Energy Potion","Small Luck to Luck Potion",
        "Stats Reset 2",
        }
    },


    [TokenW1t5] = {
        name = "Token_Exchange_World_1_to_5",
        items = {
            "Green Upgrade Token", "Dragon Race Token", "Saiyan Token",
            "Sword Token", "Pirate Crew Token", "Demon Fruit Token",
            "Haki Token", "Reiatsu Color Token", "Zanpakuto Token",
            "Pressure Token", "Cursed Token", "Cursed Finger",
            "Breathing Token", "Demon Art Token",
        }
    },
    [TokenW6t10] = {
        name = "Token_Exchange_World_6_to_10",
        items = {
            "Hunter Rank Token", "ReAwakening Token", "Monarch Token", "Grimoire Token",
            "Water Spirit Token", "Wind Spirit Token", "Fire Spirit Token", "Chakra Token",
            "Eye Token", "Granny Token", "Gold Ball Token", "Energy TCG Token",
            "Damage TCG Token", "Ten Token", "Lucky Spirit Token", "Greedy Token",
        }
    },
    [TokenW11t15] = {
        name = "Token_Exchange_World_11_to_15",
        items = {
            "Families Token", "Titan Token", "Spinal Fluid Token", "Sins Token",
            "Commandments Token", "Fortitude Token", "Kaiju Token", "Kaiju Energy Token",
            "Ultimate Skill Token", "Species Token", "Demon Energy Token",
            "Demon Damage Token", "Demon Luck Token", "Demon Coins Token",
            "Energy Rune Token", "Weapon Rune Token", "Swordsman Energy Token",
            "Swordsman Damage Token",
        }
    },
    [TokenW16t20] = {
        name = "Token_Exchange_World_16_to_20",
        items = {
            "Stand Token", "Ripple Token", "Onomatopoeia Token", "Requiem Token",
            "CCG Token", "Kagune Token", "Kakuhou Token", "Flesh Token",
            "Debiru Token", "Akuma Token", "Akuma Damage Token", "Akuma Energy Token",
            "Pokita Token", "Mushi Token", "Infernal Token", "Flare Token", "Ignition Token",
            "HellFire Token", "Adolla Token", "Fire Company Token", "Adolla Blessing Token",
        }
    },

    -- Jewelry Exchange Tabs
    [ExchangeJewelry] = {
        name = "Exchange_Jewelry",
        items = {
            "x1 Bronze Ring Part", "x1 Bronze Necklace Part", "x1 Silver Ring Part",
            "x1 Silver Necklace Part", "x1 Gold Ring Part", "x1 Gold Necklace Part",
            "x1 Rose Gold Ring Part", "x1 Rose Gold Necklace Part",
            "x1 Yellow Crystal", "x1 Red Crystal", "x1 Green Crystal", "x1 Blue Crystal",
            "x1 Bronze Earring Part", "x1 Silver Earring Part", "x1 Gold Earring Part",
            "x1 Rose Gold Earring Part",
        }
    },
    [ExchangeJewelryS] = {
        name = "Exchange_Jewelry_Shop",
        items = {
            "x1 Bronze Ring Part", "x1 Bronze Necklace Part", "x1 Silver Ring Part",
            "x1 Silver Necklace Part", "x1 Gold Ring Part", "x1 Gold Necklace Part",
            "x1 Rose Gold Ring Part", "x1 Rose Gold Necklace Part",
            "x1 Yellow Crystal", "x1 Red Crystal", "x1 Green Crystal", "x1 Blue Crystal",
            "x1 Bronze Earring Part", "x1 Silver Earring Part", "x1 Gold Earring Part",
            "x1 Rose Gold Earring Part",
        }
    }
}


local function BuildExchangeUI(groupbox, shopName, productList)
    local selectedProductId = 1
    local purchaseAmount = 1

    groupbox:AddDropdown("Dropdown_" .. shopName, {
        Text = "Select Item",
        Values = productList,
        Default = productList[1],
        Multi = false,
        Callback = function(Value)
            for i, v in ipairs(productList) do
                if v == Value then
                    selectedProductId = i
                    break
                end
            end
        end
    })

    groupbox:AddInput("Input_" .. shopName, {
        Text = "Amount",
        Default = "1",
        Tooltip = "Enter purchase amount",
        Numeric = true,
        Callback = function(Value)
            local num = tonumber(Value)
            purchaseAmount = (num and num > 0) and num or 1
        end
    })

    groupbox:AddButton("Purchase", function()
        local args = {
            [1] = {
                ["Amount"] = purchaseAmount,
                ["Product_Id"] = selectedProductId,
                ["Action"] = "Merchant_Purchase",
                ["Bench_Name"] = shopName,
            }
        }

        local success, err = pcall(function()
            game:GetService("ReplicatedStorage")
                :WaitForChild("Events", 9e9)
                :WaitForChild("To_Server", 9e9)
                :FireServer(unpack(args))
        end)

        if success then
            -- Purchase successful
        else
            warn("[SHOP] Purchase failed:", err)
        end
    end, "Buy selected product from this shop.")
end


for groupbox, data in pairs(shopProducts) do
    BuildExchangeUI(groupbox, data.name, data.items)
end

------======================================= Tab: Misc Settings ==================================------

-- Restore toggle states from config after UI is created
task.defer(function()
    if Library.Flags then
        if config.MutePetSoundsToggle ~= nil and Library.Flags.MutePetSoundsToggle then
            Library.Flags.MutePetSoundsToggle:Set(config.MutePetSoundsToggle)
        end
        if config.DisableNotificationsToggle ~= nil and Library.Flags.DisableNotificationsToggle then
            Library.Flags.DisableNotificationsToggle:Set(config.DisableNotificationsToggle)
        end
        if config.FPSBoostToggle ~= nil and Library.Flags.FPSBoostToggle then
            Library.Flags.FPSBoostToggle:Set(config.FPSBoostToggle)
        end
    end

    -- Auto-start logic for MutePetSoundsToggle
    if config.MutePetSoundsToggle then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        if not originalVolumes then originalVolumes = {} end
        local audioFolder = ReplicatedStorage:FindFirstChild("Audio")
        if audioFolder then
            local petSounds = {"Pets_Appearing_Sound", "Pets_Drumroll", "Loot"}
            for _, soundName in ipairs(petSounds) do
                local sound = audioFolder:FindFirstChild(soundName)
                if sound and sound:IsA("Sound") then
                    if not originalVolumes[soundName] then
                        originalVolumes[soundName] = sound.Volume
                    end
                    sound.Volume = 0
                end
            end
            local mergeFolder = audioFolder:FindFirstChild("Merge")
            if mergeFolder then
                local mergeSounds = {"PetsAppearingSound", "Drumroll", "ChestOpen"}
                for _, soundName in ipairs(mergeSounds) do
                    local sound = mergeFolder:FindFirstChild(soundName)
                    if sound and sound:IsA("Sound") then
                        if not originalVolumes[soundName] then
                            originalVolumes[soundName] = sound.Volume
                        end
                        sound.Volume = 0
                    end
                end
            end
        end
    end

    -- Auto-start logic for DisableNotificationsToggle
    if config.DisableNotificationsToggle then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        if player then
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local notifications = playerGui:FindFirstChild("Notifications")
                if notifications then
                    if notifications:IsA("ScreenGui") or notifications:IsA("BillboardGui") or notifications:IsA("SurfaceGui") then
                        notifications.Enabled = false
                    elseif notifications:IsA("GuiObject") then
                        notifications.Visible = false
                    end
                end
                local dropNotifications = playerGui:FindFirstChild("Drop_Notifications")
                if dropNotifications then
                    local drops = dropNotifications:FindFirstChild("Drops")
                    local dropsSmall = dropNotifications:FindFirstChild("Drops_Small")
                    for _, obj in ipairs({drops, dropsSmall}) do
                        if obj then
                            if obj:IsA("ScreenGui") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                                obj.Enabled = false
                            elseif obj:IsA("GuiObject") then
                                obj.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end

    -- Auto-start logic for FPSBoostToggle
    if config.FPSBoostToggle then
        local Lighting = game:GetService("Lighting")
        local workspace = game:GetService("Workspace")
        if not originalFPSValues then originalFPSValues = {} end
        if not originalLightingValues then originalLightingValues = {} end
        if not originalTerrainValues then originalTerrainValues = {} end
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
    end

    if autoHideUIEnabled then
        Library:Toggle(false)
        Library.ShowCustomCursor = false
    end
end)

UISettingsGroup:AddToggle("AutoHideUI", {
    Text = "Auto Hide UI",
    Default = autoHideUIEnabled,
    Tooltip = "Automatically hide the UI on script load",
    Callback = function(value)
        autoHideUIEnabled = value
        config.AutoHideUIEnabled = value
        saveConfig()
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
        Default = config.MutePetSoundsToggle ~= nil and config.MutePetSoundsToggle or mutePetSoundsEnabled,
        Callback = function(Value)
        mutePetSoundsEnabled = Value
        config.MutePetSoundsToggle = Value
        saveConfig()
        -- Robust inline logic
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            if not originalVolumes then originalVolumes = {} end
            local audioFolder = ReplicatedStorage:FindFirstChild("Audio")
            if audioFolder then
                local petSounds = {"Pets_Appearing_Sound", "Pets_Drumroll", "Loot"}
                for _, soundName in ipairs(petSounds) do
                    local sound = audioFolder:FindFirstChild(soundName)
                    if sound and sound:IsA("Sound") then
                        if mutePetSoundsEnabled then
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
                            if mutePetSoundsEnabled then
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
            saveConfig()
        end
    }
)

-- UI Settings
UISettingsGroup:AddToggle(
    "DisableNotificationsToggle",
    {
        Text = "Disable Notifications",
        Default = config.DisableNotificationsToggle ~= nil and config.DisableNotificationsToggle or disableNotificationsEnabled,
        Callback = function(Value)
        disableNotificationsEnabled = Value
        config.DisableNotificationsToggle = Value
        saveConfig()
        -- Robust inline logic
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            if player then
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    local notifications = playerGui:FindFirstChild("Notifications")
                    if notifications then
                        if disableNotificationsEnabled then
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
                                if disableNotificationsEnabled then
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
            saveConfig()
        end
    }
)

UISettingsGroup:AddToggle(
    "FPSBoostToggle",
    {
        Text = "FPS Boost (Lower Graphics)",
        Default = config.FPSBoostToggle ~= nil and config.FPSBoostToggle or fpsBoostEnabled,
        Callback = function(Value)
        fpsBoostEnabled = Value
        config.FPSBoostToggle = Value
        saveConfig()
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
            saveConfig()
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
            config.AntiAFKToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local vu = game:GetService("VirtualUser")
                    -- First click immediately
                    pcall(function()
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new())
                    end)
                    -- Then repeat every 10 seconds
                    while config.AntiAFKToggle and getgenv().SeisenHubRunning do
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
    -- Auto-start logic for AntiAFKToggle after reload
    if config.AntiAFKToggle then
        task.spawn(function()
            local vu = game:GetService("VirtualUser")
            -- First click immediately
            pcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
            -- Then repeat every 10 seconds
            while config.AntiAFKToggle and getgenv().SeisenHubRunning do
                task.wait(10)
                pcall(function()
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end)
            end
        end)
    end

-- === UI Setting: Server Hop Admin ===
-- Assuming you already have a UI settings table named config

config.ServerHopAdminToggle = config.ServerHopAdminToggle or false

UISettingsGroup:AddToggle("ServerHopAdminToggle", {
    Text = "Server Hop Admin",
    Default = config.ServerHopAdminToggle,
    Tooltip = "Automatically hops to a lower server if a listed admin is present.",
    Callback = function(Value)
        config.ServerHopAdminToggle = Value
        saveConfig() -- Save settings if you have a save function
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
    if not config.ServerHopAdminToggle then return end

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

game.Players.PlayerRemoving:Connect(function()
    task.wait(1)
    checkForAdmins()
end)

-- Initial check on script load
task.wait(1)
checkForAdmins()

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
        config.UIScale = value
        saveConfig()
        Library:SetWatermarkVisibility(false)
        Library:SetDPIScale(scaleMap[value])
    end
})

-- Auto start/apply UI scale on reload
if config.UIScale then
    local scaleMap = {
        ["30%"] = 30,
        ["50%"] = 50,
        ["75%"] = 75,
        ["100%"] = 100,
        ["125%"] = 125,
        ["150%"] = 150
    }
    Library:SetWatermarkVisibility(false)
    Library:SetDPIScale(scaleMap[config.UIScale] or 100)
    if uiScaleDropdownObj and type(uiScaleDropdownObj.SetValue) == "function" then
        uiScaleDropdownObj:SetValue(config.UIScale)
    end
end

local redeemCodes = {
    "33KPlayers", "150KLikes", "DungeonFall1", "Update13", "155KLikes", "350KFav", "360KFav", "40MVisits", "Shutdown123", "34KOnline",
    "35KCCU", "?43KRecord?", "?44KRecord?", "?Record45K?!", "?Record46K?!", "?NewRecord47k", "?SupaRecord48k", "?Supa49kRecord", "?Ultra50KRecord", "?Update14P2",
    "175KLikes", "180KLikes", "400KFav", "405KFav", "?Update14P3", "185KLikes", "190KLikes", "410KFav", "415KFav", "?51kPlayers",
    "?52kPlayers", "?53kPlayers", "Update15", "195KLikes", "200KLikes", "420KFav", "425KFav", "Update15Delay", "BugsUpdate15", "2BugsUpdate15",
    "51kPlayers", "52kPlayers", "53kPlayers", "Ultra50KRecord", "Supa49kRecord", "SupaRecord48k", "NewRecord47k", "Record45K?!", "?Record46K?!", "44KRecord??",
    "Update14P2", "175KLikes", "180KLikes", "400KFav", "405KFav", "?42K?", "SomeQuickFix1a", "SomeQuickFix2", "?41KRecord?", "40KRecord?",
    "39KRecordCcu", "Update14", "170KLikes", "50MVisits", "395KFav", "390KFav", "DungeonQuickFix", "Update13P3", "165KLikes", "375KFav",
    "380KFav", "385KFav", "1GhoulKeyNoMore", "IWantKey", "Online36K", "37KPlayersOn", "38KRecord", "Update13P2", "365KFav", "370KFav",
    "50K", "160KLikes", "Shutdown123", "Update13", "155KLikes", "350KFav", "360KFav", "40MVisits", "DungeonFall1", "Update12.5",
    "31KPlayers", "32KPlayers", "33KPlayers", "150KLikes", "Update12.2", "35MVisits", "140KLikes", "340KFav", "29KPlayers", "30kOnline",
    "Update12.2Late", "PotionFix1", "25KPlayers", "26KPlayers", "27KPlayers", "28KPlayers", "BugFixSome", "Update12", "Update15P2", "205KLikes", "210KLikes",
    "430KFav", "435KFav", "54kPlayers", "WhatPlayer62kRecord!", "DungeonUp15Fix", "65kRecord!", "66kRecord!", "63kRecord!", "CursedFixes", "64kRecord!",
    "55kPlayers", "56K?!", "57KNewRecord!!", "NoWay58KOnline", "59KOnlinePlayers?!", "ThereIsNoWay60k!", "61kThereIsNoWay", "Update16", "225KLikes", "230KLikes",
    "450KFav", "455KFav", "FunnyGreenPlanet", "FunnyGreenPlanetShutdown", "Update16P2","235KLikes","460KFav","465KFav","470KFav","80MVisits","Record67K?",
    "NewRecord68K?","NewRecord69K?","NoWayWeCanHit70K?","71KImpossibleRecord!","Insane72kPlayersOnline","73KPlayers","74KPlayers","Update16P2Fix","Update16P2Fix2",
    "Update16P3", "240KLikes", "245KLikes", "475KFav", "480KFav", "SaveMeUpdate16Part3Fix", "Update17" , "250KLikes","255KLikes","490KFav","495KFav","Update17BalanceWhatisThat?",
    "ShutdownCodeUpdate17"
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
        task.wait(0.5)
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
                            task.wait(0.5)
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


-- Hide UI on script load if enabled
if autoHideUIEnabled then
    task.defer(function()
        Library:Toggle(false)
        Library.ShowCustomCursor = false
    end)
end


UISettingsGroup:AddToggle("AutoHideUI", {
    Text = "Auto Hide UI",
    Default = autoHideUIEnabled,
    Tooltip = "Automatically hide the UI on script load",
    Callback = function(value)
        autoHideUIEnabled = value
        config.AutoHideUIEnabled = value
        saveConfig()
        if value then
            Library:Toggle(false) -- Hide UI
            Library.ShowCustomCursor = false -- Disable custom cursor
        else
            Library:Toggle(true) -- Show UI
            Library.ShowCustomCursor = true -- Enable custom cursor (restore)
        end
    end
})



UISettingsGroup:AddButton("Unload Script", function()
    getgenv().SeisenHubRunning = false
    autoRollDragonRaceEnabled = false
    autoRollSaiyanEvolutionEnabled = false
    autoRollSwordsEnabled = false
    autoRollPirateCrewEnabled = false
    autoRollDemonFruitsEnabled = false
    autoRollReiatsuColorEnabled = false
    autoRollZanpakutoEnabled = false
    autoRollCursesEnabled = false
    autoRollDemonArtsEnabled = false
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
    farmAllEnemiesEnabled = false
    killAuraOnlyEnabled = false
    autoRollEnabled = false
    autoDeleteEnabled = false
    autoDeleteWeaponEnabled = false
    farmAllEnemiesEnabled = false
    TeleportAndAttackToggle = false
    teleportAndAttackEnabled = false
    autoStatsRunning = false
    farmAllEnabled = false
    FarmAllEnemiesToggle = false
    DisableNotificationsToggle = false
    AutoRollBreathingToggle = false
    autoRollBreathing = false
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
    -- Set all enabledUpgrades to false
    if enabledUpgrades then
        for k in pairs(enabledUpgrades) do
            enabledUpgrades[k] = false
        end
    end
    -- Restore FPS Boost settings to normal
    local Lighting = game:GetService("Lighting")
    local workspace = game:GetService("Workspace")
    if fpsBoostConnection then
        fpsBoostConnection:Disconnect()
        fpsBoostConnection = nil
    end
    if Lighting and originalLightingValues and originalLightingValues.GlobalShadows ~= nil then
        Lighting.GlobalShadows = originalLightingValues.GlobalShadows
        Lighting.FogEnd = originalLightingValues.FogEnd
        Lighting.Brightness = originalLightingValues.Brightness
    end
    if workspace:FindFirstChild("Terrain") and originalTerrainValues and originalTerrainValues.WaterWaveSize ~= nil then
        local Terrain = workspace.Terrain
        Terrain.WaterWaveSize = originalTerrainValues.WaterWaveSize
        Terrain.WaterWaveSpeed = originalTerrainValues.WaterWaveSpeed
        Terrain.WaterReflectance = originalTerrainValues.WaterReflectance
        Terrain.WaterTransparency = originalTerrainValues.WaterTransparency
    end
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
    if settings().Rendering and originalRenderingQuality then
        settings().Rendering.QualityLevel = originalRenderingQuality
    end
    originalFPSValues = {}
    originalLightingValues = {}
    originalTerrainValues = {}
    originalRenderingQuality = nil
    
    -- Disconnect workspace connection for ball circles
    if workspaceConnection then
        workspaceConnection:Disconnect()
        workspaceConnection = nil
    end

    -- Stop watermark connection
    if WatermarkConnection then
        WatermarkConnection:Disconnect()
    end
    -- Disconnect any remaining global input connections
    if inputChangedConnection then
        inputChangedConnection:Disconnect()
    end
    if inputEndedConnection then
        inputEndedConnection:Disconnect()
    end
    -- Remove custom watermark
    if WatermarkGui then
        WatermarkGui:Destroy()
    end
    -- Proper unload using Library:Unload()
    if Library and Library.Unload then
        Library:Unload()
    end
    print("✅ Seisen Hub unloaded and cleaned up.")
end)


