game.StarterGui:SetCore("SendNotification", {
    Title = "Seisen Hub";
    Text = "Arise Crossover Script Loaded";
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


-- Passive Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
local Window = Library:CreateWindow({
    Title = "Seisen Hub",
    Footer = "Arise Crossover",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Center = true,
    Icon = 125926861378074,
    AutoShow = false,
    ShowCustomCursor = false -- Enable custom cursor
})

local configFolder = "SeisenHub"
local configFile = configFolder .. "/seisen_hub_ac.txt"
local HttpService = game:GetService("HttpService")
getgenv().SeisenHubConfig = getgenv().SeisenHubConfig or {}
local config = getgenv().SeisenHubConfig

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
        for k, v in pairs(data) do
            config[k] = v
        end
    end
end

-- Always use global autoMainQuestEnabled
getgenv().autoMainQuestEnabled = config.AutoMainQuestEnabled or false
-- =====================

local replicatedStorage = game:GetService("ReplicatedStorage")
local dataRemoteEvent = replicatedStorage:WaitForChild("BridgeNet2", 9e9):WaitForChild("dataRemoteEvent", 9e9)
local enemiesFolder = workspace:WaitForChild("__Main"):WaitForChild("__Enemies"):WaitForChild("Client")
local player = game.Players.LocalPlayer
local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")


-- Load custom cursor setting from config
local customCursorEnabled = config.CustomCursorEnabled
if customCursorEnabled == nil then
    customCursorEnabled = true -- default value
    config.CustomCursorEnabled = true
end
local killAuraEnabled = config.KillAuraEnabled or false
local autoTeleportToModelEnabled = config.AutoTeleportToModelEnabled or false
local selectedModelNameToTeleport = config.SelectedModelNameToTeleport or ""
local autoTargetEnabled = config.AutoTargetEnabled or false
local autoBuyWeaponEnabled = config.AutoBuyWeaponEnabled or false
local selectedWeaponShop = config.SelectedWeaponShop or "WeaponShop1"
local selectedWeaponIndex = config.SelectedWeaponIndex or 1
local autoAriseEnabled = config.AutoAriseEnabled or false
local autoDestroyEnabled = config.AutoDestroyEnabled or false
local autoSpinEnabled = config.AutoSpinEnabled or false
local autoDailyQuestEnabled = config.AutoDailyQuestEnabled or false
local autoWeeklyQuestEnabled = config.AutoWeeklyQuestEnabled or false
local autoMainQuestEnabled = config.AutoMainQuestEnabled or false
local autoDungeonEnabled = config.AutoDungeonEnabled or false
local selectedDungeonEnemyTitle = config.SelectedDungeonEnemyTitle or ""
selectedStat = config.SelectedStat or "Shadow Power"
autoStatsEnabled = config.AutoStatsEnabled or false
local autoDesertEnabled = config.AutoDesertEnabled or false

-- Load auto hide UI toggle from config
local autoHideUIEnabled = config.AutoHideUIEnabled or false

local function saveConfig()
    config.CustomCursorEnabled = customCursorEnabled
    config.AutoTeleportToModelEnabled = autoTeleportToModelEnabled
    config.SelectedModelNameToTeleport = selectedModelNameToTeleport
    config.KillAuraEnabled = killAuraEnabled
    config.AutoTargetEnabled = autoTargetEnabled
    config.SelectedWeaponShop = selectedWeaponShop
    config.SelectedWeaponIndex = selectedWeaponIndex
    config.AutoAriseEnabled = autoAriseEnabled
    config.AutoDestroyEnabled = autoDestroyEnabled
    config.AutoSpinEnabled = autoSpinEnabled
    config.AutoDailyQuestEnabled = autoDailyQuestEnabled
    config.AutoWeeklyQuestEnabled = autoWeeklyQuestEnabled
    config.AutoMainQuestEnabled = autoMainQuestEnabled
    config.AutoDungeonEnabled = autoDungeonEnabled
    config.SelectedDungeonEnemyTitle = selectedDungeonEnemyTitle
    config.AutoStatsEnabled = autoStatsEnabled
    config.SelectedStat = selectedStat
    config.AutoHideUIEnabled = autoHideUIEnabled
    writefile(configFile, HttpService:JSONEncode(config))
end


local MainTab = Window:AddTab("Main", "atom", "Main Features")
local MainGroup = MainTab:AddLeftGroupbox("Main Features", "airplay")
local Weapon = MainTab:AddRightGroupbox("Auto Buy Weapon", "swords")
local Auto1 = MainTab:AddRightGroupbox("Auto Collect/Spin", "loader-pinwheel")
local StatsGroup = MainTab:AddLeftGroupbox("Auto Stats", "activity")
local Keys = MainTab:AddRightGroupbox("Key Crafting", "key")
local Teleport2Group = MainTab:AddRightGroupbox("Mounts", "cat")
local ExtraLeftGroup = MainTab:AddLeftGroupbox("Dungeons", "archive-restore")
-- Add Shops Tab
local ShopsTab = Window:AddTab("Teleport and Shop", "archive", "Teleport to Shops and Buy Weapons")
local ShopsGroup = ShopsTab:AddLeftGroupbox("All Shops", "aperture")
ShopsGroup:AddLabel("If You're Too Far,")
ShopsGroup:AddLabel("Toggles Won't Work.")
local TeleportGroup = ShopsTab:AddRightGroupbox("World Teleport", "align-vertical-justify-end")
local DungeonGroup = ShopsTab:AddLeftGroupbox("Dungeons", "archive-restore")
Teleport2Group:AddLabel("⚠️ Dont Spam Teleport")
local Roll = Window:AddTab("Rolls", "gift", "Auto Rolls")
local RollShikais = Roll:AddLeftGroupbox("Shikais", "star-four-points")
local SettingsTab = Window:AddTab("Settings", "settings", "Customize the UI")
local UISettingsGroup = SettingsTab:AddLeftGroupbox("UI Customization", "paintbrush")
local InfoGroup = SettingsTab:AddRightGroupbox("Script Information", "info")



ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenHub")
ThemeManager:ApplyToTab(SettingsTab)

InfoGroup:AddLabel("Script by: Seisen")
InfoGroup:AddLabel("Version: 1.0.0")
InfoGroup:AddLabel("Game: Arise Crossover")

InfoGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/F4sAf6z8Ph")
        -- print removed
end)


-- Mobile detection and UI adjustments
if Library.IsMobile then
    InfoGroup:AddLabel("📱 Mobile Device Detected")
    InfoGroup:AddLabel("UI optimized for mobile")
else
    InfoGroup:AddLabel("🖥️ Desktop Device Detected")
end

-- Auto hide UI on script execution if enabled
task.defer(function()
    if autoHideUIEnabled and Library and Library.Toggle then
        Library:Toggle()
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = nil
local HumanoidRootPart = nil


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

local KILL_AURA_RANGE = 25
local KILL_AURA_DELAY = 0.05
local killAuraThread = nil

function startKillAura()
    if killAuraThread then return end
    killAuraThread = task.spawn(function()
        while killAuraEnabled do
            task.wait(KILL_AURA_DELAY)
            local char = player.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                if enemy:IsA("Model") then
                    local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
                    if enemyHRP and (hrp.Position - enemyHRP.Position).Magnitude <= KILL_AURA_RANGE then
                        dataRemoteEvent:FireServer({
                            {
                                Event = "PunchAttack",
                                Enemy = enemy.Name
                            },
                            "\4"
                        })
                    end
                end
            end
        end
    end)
end

function stopKillAura()
    killAuraEnabled = false
    if killAuraThread then
        killAuraThread = nil
    end
end



MainGroup:AddToggle("AutoTargetToggle", {
    Text = "Auto Target",
    Default = autoTargetEnabled,
    Tooltip = "Automatically targets the closest enemy.",
    Callback = function(value)
        autoTargetEnabled = value
        config.AutoTargetEnabled = value
        saveConfig()
        if value then
            startAutoTarget()
        else
            stopAutoTarget()
        end
    end
})

MainGroup:AddToggle("KillAuraToggle", {
    Text = "Kill Aura",
    Default = killAuraEnabled,
    Tooltip = "Automatically attacks all nearby enemies.",
    Callback = function(value)
        killAuraEnabled = value
        config.KillAuraEnabled = value
        saveConfig()
        if value then
            startKillAura()
        else
            stopKillAura()
        end
    end
})

MainGroup:AddToggle("AutoTeleportToModelToggle", {
    Text = "Auto Farm",
    Default = autoTeleportToModelEnabled,
    Tooltip = "Automatically Farm to Selected Enemy",
    Callback = function(value)
        autoTeleportToModelEnabled = value
        config.AutoTeleportToModelEnabled = value
        saveConfig()
    end
})

-- Auto Arise Settings
local AUTO_ARISE_RANGE = 50
local AUTO_ARISE_DELAY = 0.1
local autoAriseThread = nil

local function ariseEnemy(enemyId)
    dataRemoteEvent:FireServer({
        {
            Event = "EnemyCapture",
            Enemy = enemyId
        },
        "\4"
    })
end

local function startAutoArise()
    if autoAriseThread then return end
    autoAriseEnabled = true
    autoAriseThread = task.spawn(function()
        while autoAriseEnabled do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                    if enemy:IsA("Model") or enemy:IsA("Folder") then
                        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
                        if enemyRoot then
                            local dist = (enemyRoot.Position - hrp.Position).Magnitude
                            if dist <= AUTO_ARISE_RANGE then
                                ariseEnemy(enemy.Name)
                            end
                        end
                    end
                end
            end
            task.wait(AUTO_ARISE_DELAY)
        end
    end)
end

local function stopAutoArise()
    autoAriseEnabled = false
    if autoAriseThread then
        autoAriseThread = nil
    end
end

MainGroup:AddToggle("AutoAriseToggle", {
    Text = "Auto Arise",
    Default = autoAriseEnabled,
    Tooltip = "Automatically captures nearby enemies.",
    Callback = function(value)
        autoAriseEnabled = value
        config.AutoAriseEnabled = value
        saveConfig()
        if value then
            startAutoArise()
        else
            stopAutoArise()
        end
    end
})

local AUTO_DESTROY_RANGE = 50
local AUTO_DESTROY_DELAY = 0.1
local autoDestroyThread = nil
local function destroyEnemy(enemyId)
    dataRemoteEvent:FireServer({
        {
            Event = "EnemyDestroy",
            Enemy = enemyId
        },
        "\4"
    })
end

local function startAutoDestroy()
    if autoDestroyThread then return end
    autoDestroyEnabled = true
    autoDestroyThread = task.spawn(function()
        while autoDestroyEnabled do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                    if enemy:IsA("Model") or enemy:IsA("Folder") then
                        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
                        if enemyRoot then
                            local dist = (enemyRoot.Position - hrp.Position).Magnitude
                            if dist <= AUTO_DESTROY_RANGE then
                                destroyEnemy(enemy.Name)
                            end
                        end
                    end
                end
            end
            task.wait(AUTO_DESTROY_DELAY)
        end
    end)
end

local function stopAutoDestroy()
    autoDestroyEnabled = false
    if autoDestroyThread then
        autoDestroyThread = nil
    end
end
MainGroup:AddToggle("AutoDestroyToggle", {
    Text = "Auto Destroy",
    Default = autoDestroyEnabled,
    Tooltip = "Automatically destroys nearby enemies.",
    Callback = function(value)
        autoDestroyEnabled = value
        config.AutoDestroyEnabled = value
        saveConfig()
        if value then
            startAutoDestroy()
        else
            stopAutoDestroy()
        end
    end
})


    -- Auto Sell All Weapons Logic
    local autoSellAllWeaponsEnabled = false
    local autoSellAllWeaponsThread = nil

    local function startAutoSellAllWeapons()
        if autoSellAllWeaponsThread then return end
        autoSellAllWeaponsEnabled = true
        autoSellAllWeaponsThread = task.spawn(function()
            while autoSellAllWeaponsEnabled do
                    local weaponsFolder = game:GetService("Players").LocalPlayer:FindFirstChild("leaderstats")
                        and game:GetService("Players").LocalPlayer.leaderstats:FindFirstChild("Inventory")
                        and game:GetService("Players").LocalPlayer.leaderstats.Inventory:FindFirstChild("Weapons")
                    local weaponsList = game:GetService("Players").LocalPlayer.PlayerGui
                        and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Menus")
                        and game:GetService("Players").LocalPlayer.PlayerGui.Menus:FindFirstChild("Inventory")
                        and game:GetService("Players").LocalPlayer.PlayerGui.Menus.Inventory:FindFirstChild("Main")
                        and game:GetService("Players").LocalPlayer.PlayerGui.Menus.Inventory.Main:FindFirstChild("Lists")
                        and game:GetService("Players").LocalPlayer.PlayerGui.Menus.Inventory.Main.Lists:FindFirstChild("Weapons")
                    if weaponsFolder and weaponsList then
                        for _, weaponObj in ipairs(weaponsFolder:GetChildren()) do
                            if weaponObj and weaponObj.Name ~= "" then
                                local weaponUI = weaponsList:FindFirstChild(weaponObj.Name)
                                local equippedVisible = false
                                if weaponUI and weaponUI:FindFirstChild("Main") and weaponUI.Main:FindFirstChild("Equipped") then
                                    equippedVisible = weaponUI.Main.Equipped.Visible
                                end
                                if not equippedVisible then
                                    local args = {
                                        [1] = {
                                            [1] = {
                                                ["Weapons"] = { weaponObj.Name };
                                                ["Event"] = "WeaponAction";
                                                ["Action"] = "Sell";
                                            };
                                            [2] = "\r";
                                        };
                                    }
                                    game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2", 9e9):WaitForChild("dataRemoteEvent", 9e9):FireServer(unpack(args))
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                    task.wait(1) -- Adjust delay as needed
            end
        end)
    end

    local function stopAutoSellAllWeapons()
        autoSellAllWeaponsEnabled = false
        if autoSellAllWeaponsThread then
            autoSellAllWeaponsThread = nil
        end
    end

    MainGroup:AddToggle("AutoSellAllWeaponsToggle", {
        Text = "Auto Sell All Weapons",
        Default = false,
        Tooltip = "Automatically sells all weapons in your inventory.",
        Callback = function(value)
            autoSellAllWeaponsEnabled = value
            if value then
                startAutoSellAllWeapons()
            else
                stopAutoSellAllWeapons()
            end
        end
    })



local AUTO_SPIN_DELAY = 1 -- seconds between spins
local autoSpinThread = nil
local function startAutoSpin()
    if autoSpinThread then return end
    autoSpinEnabled = true
    autoSpinThread = task.spawn(function()
        while autoSpinEnabled do
            local args = {
                [1] = {
                    [1] = {
                        ["Event"] = "SpinWheel";
                    };
                    [2] = "\r";
                };
            }
            dataRemoteEvent:FireServer(unpack(args))
            task.wait(AUTO_SPIN_DELAY)
        end
    end)
end

local function stopAutoSpin()
    autoSpinEnabled = false
    if autoSpinThread then
        autoSpinThread = nil
    end
end
Auto1:AddToggle("AutoSpinToggle", {
    Text = "Auto Spin",
    Default = autoSpinEnabled,
    Tooltip = "Automatically spins the wheel.",
    Callback = function(value)
        autoSpinEnabled = value
        config.AutoSpinEnabled = value
        saveConfig()
        if value then
            startAutoSpin()
        else
            stopAutoSpin()
        end
    end
})

if autoSpinEnabled then
    startAutoSpin()
end

if autoDestroyEnabled then
    startAutoDestroy()
end


local function tweenToEnemy(enemyModel, maxDistance)
    if not (enemyModel and enemyModel:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid")) then return end
    local char = player.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    local targetPos = enemyModel.HumanoidRootPart.Position + (enemyModel.HumanoidRootPart.CFrame.LookVector * 5)
    humanoid.PlatformStand = true
    for i = 1, 2 do
        hrp.CFrame = CFrame.new(targetPos)
        task.wait(0.3)
    end
    humanoid.PlatformStand = false
end

local AUTO_DAILY_QUEST_DELAY = 5 -- seconds between claims
local autoDailyQuestThread = nil

-- List of daily quests to claim (add more Ids as needed)
local dailyQuests = {
    {Id = "DailyTime", Type = "Daily"},
    {Id = "DailyEnemy", Type = "Daily"},
    {Id = "DailyDungeon", Type = "Daily"},
    {Id = "DailyBrute", Type = "Daily"},
    {Id = "DailyArise", Type = "Daily"},
    {Id = "DailyCastle", Type = "Daily"},
    {Id = "DailyWinter", Type = "Daily"},
    {Id = "DailyDedu", Type = "Daily"},
    {Id = "DailyInfinite", Type = "Daily"},
    {Id = "DailyBeast", Type = "Daily"}
}
local function startAutoDailyQuest()
    if autoDailyQuestThread then return end
    autoDailyQuestEnabled = true
    autoDailyQuestThread = task.spawn(function()
        while autoDailyQuestEnabled do
            for _, quest in ipairs(dailyQuests) do
                dataRemoteEvent:FireServer({
                    {
                        Id = quest.Id,
                        Type = quest.Type,
                        Event = "ClaimQuest"
                    },
                    "\12"
                })
                task.wait(1)
            end
            task.wait(AUTO_DAILY_QUEST_DELAY)
        end
    end)
end

local function stopAutoDailyQuest()
    autoDailyQuestEnabled = false
    if autoDailyQuestThread then
        autoDailyQuestThread = nil
    end
end
Auto1:AddToggle("AutoDailyQuestToggle", {
    Text = "Auto Claim Daily Quests",
    Default = autoDailyQuestEnabled,
    Tooltip = "Automatically claims all daily quests.",
    Callback = function(value)
        autoDailyQuestEnabled = value
        config.AutoDailyQuestEnabled = value
        saveConfig()
        if value then
            startAutoDailyQuest()
        else
            stopAutoDailyQuest()
        end
    end
})

-- Ensure auto claim thread always starts if toggle is ON
task.spawn(function()
    task.wait(1)
    if autoDailyQuestEnabled then
        stopAutoDailyQuest()
        startAutoDailyQuest()
    end
end)


local AUTO_WEEKLY_QUEST_DELAY = 10 -- seconds between claims
local autoWeeklyQuestThread = nil

-- List of weekly quests to claim (add more Ids as needed)
local weeklyQuests = {
    {Id = "WeeklyArise", Type = "Weekly"},
    {Id = "WeeklyBrute", Type = "Weekly"},
    {Id = "WeeklyDungeon", Type = "Weekly"},
    {Id = "WeeklyEnemy", Type = "Weekly"},
    {Id = "WeeklyTime", Type = "Weekly"},
    {Id = "WeeklyCastle", Type = "Weekly"},
    {Id = "WeeklyInfinite", Type = "Weekly"},
    {Id = "WeeklyWinter", Type = "Weekly"},
    {Id = "WeeklyDedu", Type = "Weekly"},
    {Id = "WeeklyBeast", Type = "Weekly"}
}
local function startAutoWeeklyQuest()
    if autoWeeklyQuestThread then return end
    autoWeeklyQuestEnabled = true
    autoWeeklyQuestThread = task.spawn(function()
        while autoWeeklyQuestEnabled do
            for _, quest in ipairs(weeklyQuests) do
                dataRemoteEvent:FireServer({
                    {
                        Id = quest.Id,
                        Type = quest.Type,
                        Event = "ClaimQuest"
                    },
                    "\12"
                })
                task.wait(1)
            end
            task.wait(AUTO_WEEKLY_QUEST_DELAY)
        end
    end)
end

local function stopAutoWeeklyQuest()
    autoWeeklyQuestEnabled = false
    if autoWeeklyQuestThread then
        autoWeeklyQuestThread = nil
    end
end
Auto1:AddToggle("AutoWeeklyQuestToggle", {
    Text = "Auto Claim Weekly Quests",
    Default = autoWeeklyQuestEnabled,
    Tooltip = "Automatically claims all weekly quests.",
    Callback = function(value)
        autoWeeklyQuestEnabled = value
        config.AutoWeeklyQuestEnabled = value
        saveConfig()
        if value then
            startAutoWeeklyQuest()
        else
            stopAutoWeeklyQuest()
        end
    end
})

    local mainQuests = {
        {Id = "Solo1", Type = "Normal"}, {Id = "Solo2", Type = "Normal"}, {Id = "Solo3", Type = "Normal"}, {Id = "Solo4", Type = "Normal"}, {Id = "Solo5", Type = "Normal"}, {Id = "Solo6", Type = "Normal"}, {Id = "Solo7", Type = "Normal"}, {Id = "Solo8", Type = "Normal"}, {Id = "Solo9", Type = "Normal"}, {Id = "Solo10", Type = "Normal"},
        {Id = "SoloSub1", Type = "Normal"}, {Id = "SoloSub2", Type = "Normal"}, {Id = "SoloSub3", Type = "Normal"}, {Id = "SoloSub4", Type = "Normal"}, {Id = "SoloSub5", Type = "Normal"},
        {Id = "Grass1", Type = "Normal"}, {Id = "Grass2", Type = "Normal"}, {Id = "Grass3", Type = "Normal"}, {Id = "Grass4", Type = "Normal"}, {Id = "Grass5", Type = "Normal"},
        {Id = "GrassSub1", Type = "Normal"}, {Id = "GrassSub2", Type = "Normal"}, {Id = "GrassSub3", Type = "Normal"},
        {Id = "GrassSubWB1", Type = "Normal"},
        {Id = "OnePiece1", Type = "Normal"}, {Id = "OnePiece2", Type = "Normal"}, {Id = "OnePiece3", Type = "Normal"}, {Id = "OnePiece4", Type = "Normal"}, {Id = "OnePiece5", Type = "Normal"},
        {Id = "OnePieceSub1", Type = "Normal"}, {Id = "OnePieceSub2", Type = "Normal"},
        {Id = "OnePieceSubKey1", Type = "Normal"},
        {Id = "Bleach1", Type = "Normal"}, {Id = "Bleach2", Type = "Normal"}, {Id = "Bleach3", Type = "Normal"}, {Id = "Bleach4", Type = "Normal"}, {Id = "Bleach5", Type = "Normal"},
        {Id = "BleachSub1", Type = "Normal"}, {Id = "BleachSub2", Type = "Normal"}, {Id = "BleachSub3", Type = "Normal"},
        {Id = "BleachSubWB1", Type = "Normal"},
        {Id = "BlackClover1", Type = "Normal"}, {Id = "BlackClover2", Type = "Normal"}, {Id = "BlackClover3", Type = "Normal"}, {Id = "BlackClover4", Type = "Normal"}, {Id = "BlackClover5", Type = "Normal"},
        {Id = "BlackCloverSub1", Type = "Normal"}, {Id = "BlackCloverSub2", Type = "Normal"}, {Id = "BlackCloverSub3", Type = "Normal"}, {Id = "BlackCloverSub4", Type = "Normal"},
        {Id = "BlackCloverSubKey1", Type = "Normal"},
        {Id = "Chainsaw1", Type = "Normal"}, {Id = "Chainsaw2", Type = "Normal"}, {Id = "Chainsaw3", Type = "Normal"}, {Id = "Chainsaw4", Type = "Normal"}, {Id = "Chainsaw5", Type = "Normal"},
        {Id = "ChainsawSub1", Type = "Normal"}, {Id = "ChainsawSub2", Type = "Normal"}, {Id = "ChainsawSub3", Type = "Normal"}, {Id = "ChainsawSub4", Type = "Normal"}, {Id = "ChainsawSub5", Type = "Normal"},
        {Id = "ChainsawSubWB1", Type = "Normal"},
        {Id = "Jojo1", Type = "Normal"}, {Id = "Jojo2", Type = "Normal"}, {Id = "Jojo3", Type = "Normal"}, {Id = "Jojo4", Type = "Normal"}, {Id = "Jojo5", Type = "Normal"},
        {Id = "JojoSub1", Type = "Normal"}, {Id = "JojoSub2", Type = "Normal"}, {Id = "JojoSub3", Type = "Normal"}, {Id = "JojoSub4", Type = "Normal"}, {Id = "JojoSub5", Type = "Normal"},
        {Id = "JojoSubKey2", Type = "Normal"},
        {Id = "DB1", Type = "Normal"}, {Id = "DB2", Type = "Normal"}, {Id = "DB3", Type = "Normal"}, {Id = "DB4", Type = "Normal"}, {Id = "DB5", Type = "Normal"},
        {Id = "DBSub1", Type = "Normal"}, {Id = "DBSub2", Type = "Normal"}, {Id = "DBSub3", Type = "Normal"}, {Id = "DBSub4", Type = "Normal"},
        {Id = "DBSubWB1", Type = "Normal"},
        {Id = "OPM1", Type = "Normal"}, {Id = "OPM2", Type = "Normal"}, {Id = "OPM3", Type = "Normal"}, {Id = "OPM4", Type = "Normal"}, {Id = "OPM5", Type = "Normal"},
        {Id = "OPMSub1", Type = "Normal"}, {Id = "OPMSub2", Type = "Normal"}, {Id = "OPMSub3", Type = "Normal"}, {Id = "OPMSub4", Type = "Normal"},
        {Id = "OPMSubKey2", Type = "Normal"},
        {Id = "Dan1", Type = "Normal"}, {Id = "Dan2", Type = "Normal"}, {Id = "Dan3", Type = "Normal"}, {Id = "Dan4", Type = "Normal"}, {Id = "Dan5", Type = "Normal"},
        {Id = "DanSub1", Type = "Normal"}, {Id = "DanSub2", Type = "Normal"}, {Id = "DanSub3", Type = "Normal"},
        {Id = "DanSubWB1", Type = "Normal"},
        {Id = "SL2_0", Type = "Normal"}, {Id = "SL2_1", Type = "Normal"}, {Id = "SL2_2", Type = "Normal"}, {Id = "SL2_3", Type = "Normal"}, {Id = "SL2_4", Type = "Normal"},
        {Id = "SL2Sub1", Type = "Normal"}, {Id = "SL2Sub2", Type = "Normal"}, {Id = "SL2Sub3", Type = "Normal"},
        {Id = "SL2SubKey1", Type = "Normal"},
        {Id = "HxH1", Type = "Normal"}, {Id = "HxH2", Type = "Normal"}, {Id = "HxH3", Type = "Normal"}, {Id = "HxH4", Type = "Normal"},
        {Id = "HxHSub1", Type = "Normal"}, {Id = "HxHSub2", Type = "Normal"},
        {Id = "HxHSubWB1", Type = "Normal"},
        {Id = "SLM_0", Type = "Normal"}, {Id = "SLM_1", Type = "Normal"}, {Id = "SLM_2", Type = "Normal"}, {Id = "SLM_3", Type = "Normal"}, {Id = "SLM_4", Type = "Normal"},
        {Id = "SLMSub1", Type = "Normal"}, {Id = "SLMSub2", Type = "Normal"},
        {Id = "SLMSubKey1", Type = "Normal"},
        {Id = "JJK_0", Type = "Normal"}, {Id = "JJK_1", Type = "Normal"}, {Id = "JJK_2", Type = "Normal"}, {Id = "JJK_3", Type = "Normal"}, {Id = "JJK_4", Type = "Normal"},
        {Id = "JJKSub1", Type = "Normal"}, {Id = "JJKSub2", Type = "Normal"},
        {Id = "JJKSubWB1", Type = "Normal"},
        {Id = "DS_0", Type = "Normal"}, {Id = "DS_1", Type = "Normal"}, {Id = "DS_2", Type = "Normal"}, {Id = "DS_3", Type = "Normal"}, {Id = "DS_4", Type = "Normal"},
        {Id = "DSSub1", Type = "Normal"}, {Id = "DSSub2", Type = "Normal"},
        {Id = "DSSubKey1", Type = "Normal"},
        {Id = "KJ_0", Type = "Normal"}, {Id = "KJ_1", Type = "Normal"}, {Id = "KJ_2", Type = "Normal"}, {Id = "KJ_3", Type = "Normal"}, {Id = "KJ_4", Type = "Normal"},
        {Id = "KJSub1", Type = "Normal"},
        {Id = "KJSubWB1", Type = "Normal"},
        {Id = "AOT_0", Type = "Normal"}, {Id = "AOT_1", Type = "Normal"}, {Id = "AOT_2", Type = "Normal"}, {Id = "AOT_3", Type = "Normal"}, {Id = "AOT_4", Type = "Normal"},
        {Id = "AOTSub1", Type = "Normal"},
        {Id = "AOTSubKey1", Type = "Normal"},
        {Id = "Dedu4", Type = "Normal"}, {Id = "Dedu5", Type = "Normal"},
        {Id = "WRed1", Type = "Normal"}, {Id = "WRed2", Type = "Normal"}, {Id = "WRed3", Type = "Normal"}, {Id = "WRed4", Type = "Normal"}, {Id = "WRed5", Type = "Normal"},
        {Id = "Beast1", Type = "Normal"}, {Id = "Beast2", Type = "Normal"}, {Id = "Beast3", Type = "Normal"}, {Id = "Beast4", Type = "Normal"},
        {Id = "WRedSub1", Type = "Normal"},
        {Id = "WRedFinal", Type = "Normal"},
        {Id = "WBMaster1", Type = "Normal"},
        {Id = "KeyDungeonMaster", Type = "Normal"},
        {Id = "IDesertSub5", Type = "Normal"}, {Id = "IDesertSub10", Type = "Normal"}, {Id = "IDesertSub15", Type = "Normal"}, {Id = "IDesertSub20", Type = "Normal"}, {Id = "IDesertSub25", Type = "Normal"}, {Id = "IDesertSub30", Type = "Normal"}, {Id = "IDesertSub35", Type = "Normal"}, {Id = "IDesertSub40", Type = "Normal"}, {Id = "IDesertSub50", Type = "Normal"}, {Id = "IDesertSub60", Type = "Normal"}, {Id = "IDesertSub70", Type = "Normal"}, {Id = "IDesertSub80", Type = "Normal"}, {Id = "IDesertSub90", Type = "Normal"}, {Id = "IDesertSub100", Type = "Normal"},
        {Id = "RankGM", Type = "Normal"}, {Id = "RankGMPlus", Type = "Normal"}, {Id = "RankUGM", Type = "Normal"}, {Id = "RankUGMPlus", Type = "Normal"}, {Id = "RankHGM", Type = "Normal"}, {Id = "RankHGMPlus", Type = "Normal"}
    }

    autoMainQuestEnabled = getgenv().autoMainQuestEnabled
    local autoMainQuestThread = nil
    local AUTO_MAIN_QUEST_DELAY = 0.1 -- seconds between main quest cycles

    local function startAutoMainQuest()
        if autoMainQuestThread then return end
        autoMainQuestEnabled = true
        autoMainQuestThread = task.spawn(function()
            while autoMainQuestEnabled do
                local questData = player and player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Quests") and player.leaderstats.Quests:FindFirstChild("Normal")
                if questData then
                    for _, quest in ipairs(mainQuests) do
                        local questObj = questData:FindFirstChild(quest.Id)
                        if questObj then
                            -- Only claim if the quest exists in leaderstats.Quests.Normal
                            local args = {
                                [1] = {
                                    ["Id"] = quest.Id;
                                    ["Type"] = quest.Type;
                                    ["Event"] = "ClaimQuest";
                                };
                                [2] = "\r";
                            }
                            dataRemoteEvent:FireServer(unpack(args))
                            task.wait(0.1)
                        end
                    end
                end
                task.wait(AUTO_MAIN_QUEST_DELAY)
            end
        end)
    end

    local function stopAutoMainQuest()
        autoMainQuestEnabled = false
        if autoMainQuestThread then
            autoMainQuestThread = nil
        end
    end

    Auto1:AddToggle("AutoMainQuestToggle", {
        Text = "Auto Claim Main Quests",
    Default = autoMainQuestEnabled,
        Tooltip = "Automatically claims all main quests (Solo1, Solo2, ...)",
        Callback = function(value)
            autoMainQuestEnabled = value
            config.AutoMainQuestEnabled = value
            saveConfig()
            if value then
                startAutoMainQuest()
            else
                stopAutoMainQuest()
            end
        end
    })

-- Ensure auto claim thread always starts if toggle is ON
task.spawn(function()
    task.wait(1)
    if autoDailyQuestEnabled then
        stopAutoDailyQuest()
        startAutoDailyQuest()
    end
    if autoWeeklyQuestEnabled then
        stopAutoWeeklyQuest()
        startAutoWeeklyQuest()
    end
    if autoMainQuestEnabled then
        stopAutoMainQuest()
        startAutoMainQuest()
    end
end)

local autoBuyWeaponThread = nil
local function startAutoBuyWeapon()
    if autoBuyWeaponThread then return end
    autoBuyWeaponThread = task.spawn(function()
        while autoBuyWeaponEnabled do
            local shop = selectedWeaponShop
            local weapon = shopWeapons[shop] and shopWeapons[shop][selectedWeaponIndex]
            if shop and weapon then
                dataRemoteEvent:FireServer({
                    {
                        Shop = shop,
                        Action = "Buy",
                        Amount = 1,
                        Event = "ItemShopAction",
                        Item = weapon.Internal
                    },
                    "\12"
                })
            end
            task.wait(0.5)
        end
    end)
end

local function stopAutoBuyWeapon()
    autoBuyWeaponEnabled = false
    if autoBuyWeaponThread then
        autoBuyWeaponThread = nil
    end
end


local autoBuyWeaponEnabled = false
local selectedWeaponShop = nil
local selectedWeaponIndex = nil
local autoBuyWeaponThread = nil
local shopWeapons = {
    WeaponShop1 = {
        {Display="Spiked Maul", Internal="SpikeMace"},
        {Display="Jeweled Rod", Internal="GemStaff"},
        {Display="Twin Kando Blades", Internal="DualKando"},
        {Display="Prism Scepter", Internal="CrystalScepter"},
        {Display="Twin Bone Crushers", Internal="DualBoneMace"},
        {Display="Twin Iron Naginatas", Internal="TwinIronNaginatas"}
    },
    WeaponShop2 = {
        {Display="Beast Bane", Internal="MonsterSlayer"},
        {Display="Twin Simple Wands", Internal="DualBasicStaffs"},
        {Display="Corsair Blade", Internal="PirateSaber"},
        {Display="Hybrid War Axe", Internal="MixedBattleAxe"},
        {Display="Bronze War Axe", Internal="BronzeGreatAxe"},
        {Display="Twin Relic Maces", Internal="DualAncientMace"}
    },
    WeaponShop3 = {
        {Display="Twin Corsair Blades", Internal="DualPirateSaber"},
        {Display="Twin Iron Sabers", Internal="DualSteelSabers"},
        {Display="Iron Saber", Internal="SteelSaber"},
        {Display="Iron Wingblade", Internal="DualSteelButterfly"},
        {Display="Twin Iron Wingblades", Internal="DualSteelButterfly"},
        {Display="Iron Kando Blade", Internal="SteelKando"}
    },
    WeaponShop4 = {
        {Display="Iron Naginata", Internal="SteelNaginata"},
        {Display="Titan Khopesh", Internal="GreatKopesh"},
        {Display="Bone Crusher", Internal="BoneMace"},
        {Display="Relic Mace", Internal="AncientMace"},
        {Display="Scarlet Staff", Internal="CrimsonStaff"},
        {Display="Colossal Saber", Internal="GreatSaber"}
    },
    WeaponShop5 = {
        {Display="Twin Colossal Sabers", Internal="DualGreatSaber"},
        {Display="Simple Staff", Internal="BasicStaff"},
        {Display="Steel Khopesh", Internal="StellKopesh"},
        {Display="Titan Trident", Internal="GreatTrident"},
        {Display="Twin Prism Scepters", Internal="DualCrystalScepter"},
        {Display="Twin Tridents", Internal="DualTrident"}
    },
    WeaponShop6 = {
        {Display="Emerald Blade", Internal="OzSword2"},
        {Display="Prism Blade", Internal="CrystalSword2"},
        {Display="Obsidian Axe", Internal="ObsidianDualAxe2"},
        {Display="Argent Spear", Internal="SilverSpear2"},
        {Display="Draconic Axe", Internal="DragonAxe2"},
        {Display="Twin Sacred Axe", Internal="DualDivineAxe2"}
    },
    WeaponShop7 = {
        {Display="Crimson Rod", Internal="BloodStaff2"},
        {Display="Twin Crimson Rods", Internal="DualCrimsonStaff2"},
        {Display="Twin Jeweled Rods", Internal="DualGemStaff2"},
        {Display="Colossal Scythe", Internal="GreatScythe2"},
        {Display="Dual Obsidian Axes", Internal="TwinObsidianDualStaff2"},
        {Display="Reaper's Scythe", Internal="SlayerScythe2"}
    },
    WeaponShop8 = {
        {Display="Eye Rod", Internal="BeholderStaff2"},
        {Display="Dual Hybrid Axes", Internal="TwinMixedAxe2"},
        {Display="Double Troll Bane", Internal="TwinTrollSlayer2"},
        {Display="Runic Axe", Internal="RuneAxe2"},
        {Display="Twin Argent Spears", Internal="DualSilverSpear2"},
        {Display="Twin Draconic Axes", Internal="DualDragonAxe2"}
    },
    WeaponShop9 = {
        {Display="Steel Sword", Internal="SteelSword2"},
        {Display="Steel Spear", Internal="SteelSpear2"},
        {Display="Stellar Lance", Internal="StarSpear2"},
        {Display="Bone Staff", Internal="BoneStaff2"},
        {Display="Solar War Axe", Internal="SunGreatAxe2"},
        {Display="Charged Blade", Internal="EnergyGreatSword2"}
    },
    WeaponShop10 = {
        {Display="Steel Axe", Internal="SteelAxe2"},
        {Display="Steel Great Axe", Internal="SteelGreatAxe2"},
        {Display="Dual Beholder Rods", Internal="TwinBeholderStaffs2"},
        {Display="Obsidian Glaive", Internal="ObsidianGlaive2"},
        {Display="Twin Solar Axes", Internal="DualSunGreatAxe2"},
        {Display="Sacred Maul", Internal="DivineHammer2"}
    },
    WeaponShop11 = {
        {Display="Cruciform Blade", Internal="CrossSword2"},
        {Display="Twin Holy War Axes", Internal="DualDivineBattleAxe2"},
        {Display="Oculus Blade", Internal="EyeSword2"},
        {Display="Blessed Blade", Internal="FaithSword2"},
        {Display="Twin Leviathan Blades", Internal="DualKrakenSword2"},
        {Display="Archmage's Staff", Internal="ArchamageStaff2"}
    },
    WeaponShop12 = {
        {Display="Whirling Fang", Internal="Chakram"},
        {Display="Silent Fang", Internal="ShortSword"},
        {Display="Lunar Disc", Internal="MoonChackram"},
        {Display="Iron Judgment", Internal="Mace"},
        {Display="Iron Halberd", Internal="Halberd"},
        {Display="Gilded Reaver", Internal="GoldAxe"}
    },
    WeaponShop13 = {
        {Display="Nomad's Axe", Internal="RusticAxe"},
        {Display="Warcry Maul", Internal="WarHammer"},
        {Display="Riftfang Glaive", Internal="HookedGlaive"},
        {Display="Moonfang Dagger", Internal="CurvedDagger"},
        {Display="Duskpiercer Rapier", Internal="ClassicRapier"},
        {Display="Silver Thorn", Internal="ElegantRapier"}
    },
    WeaponShop14 = {
        {Display="Twinspike Sai", Internal="SaiDagger"},
        {Display="Glory Sabre", Internal="GoldenSabre"},
        {Display="Cursed Katana", Internal="CursedKatana"},
        {Display="Cursed Staff", Internal="CursedStaff"},
        {Display="Cursed Blade", Internal="CursedBlade"},
        {Display="Cursed Bow", Internal="CursedBow"}
    },
    WeaponShop15 = {
        {Display="Stonebrand", Internal="ShortBroadsword"},
        {Display="Sentinel Saber", Internal="GuardedSaber"},
        {Display="Stormbite Trident", Internal="SteelTrident"},
        {Display="Mooncleaver", Internal="LunarTwinAxe"},
        {Display="Titan Edge", Internal="BroadBlade"},
        {Display="Soul Reaper", Internal="BlueReaperScythe"}
    },
    WeaponShop16 = {
        {Display="Ironskull axe", Internal="SteelAxe"},
        {Display="Sunclaw Glaive", Internal="EasternGlaive"},
        {Display="Stonebreaker", Internal="CrusherHammer"},
        {Display="Viperfang Kris", Internal="SerpentDagger"},
        {Display="Shadowpiercer Kunai", Internal="SimpleKunai"},
        {Display="Shard fang", Internal="CrystalDagger"}
    },
    WeaponShop17 = {
        {Display="Basic Great Axe", Internal="BasicGAxe"},
        {Display="Novice Steal Dagger", Internal="BaseDagger"},
        {Display="Harvest Scythe", Internal="BasicScythe"},
        {Display="Azure Bone Dagger", Internal="SkullDaggerBlue"},
        {Display="Barbed Steal Saber", Internal="SpikedSaber"},
        {Display="Tide Bringer", Internal="RoyalTrident"}
    },
    WeaponShop18 = {
        {Display="Steel Training Knife", Internal="BasicKnife"},
        {Display="Titan Blade Set", Internal="BiggerSwords"},
        {Display="Ironwood Spear", Internal="BasicSpear"},
        {Display="Golden Dragon Blade", Internal="GoldenDragonSword"},
        {Display="Barbed Star Mace", Internal="SpikedStar"},
        {Display="Crescent Doom", Internal="DarkGlaive"}
    },
}
Weapon:AddButton("Buy Weapon", function()
    task.spawn(function()
        if selectedWeaponShop and selectedWeaponIndex then
            local weapon = shopWeapons[selectedWeaponShop][selectedWeaponIndex]
            if weapon then
                dataRemoteEvent:FireServer({
                    {
                        Shop = selectedWeaponShop,
                        Action = "Buy",
                        Amount = 1,
                        Event = "ItemShopAction",
                        Item = weapon.Internal
                    },
                    "\12"
                })
            end
        end
    end)
end, {
    Text = "Buy Selected Weapon",
    Tooltip = "Buys the selected weapon from the selected shop once."
})
local shopMapNames = {
    ["WeaponShop1"] = "Leveling City",
    ["WeaponShop2"] = "Grass Village",
    ["WeaponShop3"] = "Brum Island",
    ["WeaponShop4"] = "Faceheal Town",
    ["WeaponShop5"] = "Lucky Kingdom",
    ["WeaponShop6"] = "Nipon City",
    ["WeaponShop7"] = "Mori Town",
    ["WeaponShop8"] = "Dragon City",
    ["WeaponShop9"] = "XZ City",
    ["WeaponShop10"] = "Kindama City",
    ["WeaponShop11"] = "Hunter City",
    ["WeaponShop12"] = "Nen City",
    ["WeaponShop13"] = "Hurricane Town",
    ["WeaponShop14"] = "Cursed High",
    ["WeaponShop15"] = "Slayer's Village",
    ["WeaponShop16"] = "Kaiju City",
    ["WeaponShop17"] = "Wall Kingdom",
    ["WeaponShop18"] = "Mage Town"
}
local shopKeys = {}
local shopDisplayNames = {}
for i = 1, 18 do
    local key = "WeaponShop" .. i
    if shopMapNames[key] then
        table.insert(shopKeys, key)
        table.insert(shopDisplayNames, shopMapNames[key])
    end
end
Weapon:AddDropdown("WeaponShopDropdown", {
    Text = "Weapon Shop",
    Values = shopDisplayNames,
    Default = shopDisplayNames[1],
    Tooltip = "Select the weapon shop (by map name).",
    Callback = function(value)
        -- Find the internal shop key by display name
        local selectedKey = nil
        for i, name in ipairs(shopDisplayNames) do
            if name == value then
                selectedKey = shopKeys[i]
                break
            end
        end
        selectedWeaponShop = selectedKey
        if shopWeapons[selectedWeaponShop] then
            selectedWeaponIndex = 1
        else
            selectedWeaponIndex = nil
        end
        saveConfig()
        if weaponDropdown and weaponDropdown.SetValues and shopWeapons[selectedWeaponShop] then
            local weaponNames = {}
            for i, w in ipairs(shopWeapons[selectedWeaponShop]) do
                table.insert(weaponNames, w.Display)
            end
            weaponDropdown:SetValues(weaponNames)
            weaponDropdown:SetValue(weaponNames[1])
        end
    end
})

local function getWeaponNames(shop)
    local names = {}
    if shopWeapons[shop] then
        for i, w in ipairs(shopWeapons[shop]) do
            table.insert(names, w.Display)
        end
    end
    return names
end

weaponDropdown = Weapon:AddDropdown("WeaponDropdown", {
    Text = "Weapon",
    Values = getWeaponNames(shopKeys[1]),
    Default = getWeaponNames(shopKeys[1])[1],
    Tooltip = "Select the weapon to buy.",
    Callback = function(value)
        if selectedWeaponShop then
            for i, w in ipairs(shopWeapons[selectedWeaponShop]) do
                if w.Display == value then
                    selectedWeaponIndex = i
                    saveConfig()
                    break
                end
            end
        end
    end
})

local autoTargetThread = nil

function startAutoTarget()
    if autoTargetThread then return end
    autoTargetEnabled = true
    autoTargetThread = task.spawn(function()
        while autoTargetEnabled do
            task.wait(0.1)
            local char = player.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local closestEnemy, closestDistance = nil, math.huge
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                if enemy:IsA("Model") then
                    local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
                    if enemyHRP then
                        local dist = (hrp.Position - enemyHRP.Position).Magnitude
                        if dist < closestDistance then
                            closestEnemy, closestDistance = enemy, dist
                        end
                    end
                end
            end

            if closestEnemy then
                dataRemoteEvent:FireServer({
                    {
                        Event = "PunchAttack",
                        Enemy = closestEnemy.Name
                    },
                    "\4"
                })
            end
        end
    end)
end

function stopAutoTarget()
    autoTargetEnabled = false
    if autoTargetThread then
        autoTargetThread = nil
    end
end

TeleportGroup:AddLabel("Quick teleport to World 1 Location")

TeleportGroup:AddButton("Teleport To Guild Hall", function()
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart

    -- Mimic server attributes
    player.Character:SetAttribute("InGuild", true)
    player.Character:SetAttribute("InTp", true)

    -- Move to the correct Guild Hall TP position
    local guildPos = CFrame.new(9557.0703125, -166.3654327392578, 315.9495544433594) * CFrame.Angles(0, math.pi, 0)
    hrp.CFrame = guildPos

    -- Optional short wait
    task.wait(0.1)

    -- Reset InTp
    player.Character:SetAttribute("InTp", false)
end)



    TeleportGroup:AddButton("Teleport to Arena", function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local ground = workspace:FindFirstChild("__Main")
            if ground then
                local worlds = ground:FindFirstChild("__World")
                if worlds and worlds:FindFirstChild("Arena") then
                    local arena = worlds["Arena"]
                    if arena and arena:FindFirstChild("Main") then
                        local main = arena.Main
                        if main and main:FindFirstChild("Part") then
                            local target = main.Part
                            local targetPos = target.Position + Vector3.new(0, 15, 0)
                            local hrp = char.HumanoidRootPart
                            local humanoid = char.Humanoid
                            humanoid.PlatformStand = true
                            for i = 1, 3 do
                                hrp.CFrame = CFrame.new(targetPos)
                                task.wait(0.05)
                            end
                            humanoid.PlatformStand = false
                        end
                    end
                end
            end
        end
    end)

TeleportGroup:AddButton("Teleport to Leveling City", function()
    local ground = workspace:FindFirstChild("__Main")
    if ground then
        local world1 = ground:FindFirstChild("__World")
        if world1 and world1:FindFirstChild("World 1") then
            local mainPart = world1["World 1"]:FindFirstChild("MainPart")
            if mainPart and mainPart:FindFirstChild("Part") then
                local target = mainPart["Part"]
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local hrp = player.Character.HumanoidRootPart
                    local humanoid = player.Character.Humanoid
                    local targetPos = target.Position + Vector3.new(0, 15, 0)
                    humanoid.PlatformStand = true
                    for i = 1, 3 do
                        hrp.CFrame = CFrame.new(targetPos)
                        task.wait(0.05)
                    end
                    humanoid.PlatformStand = false
                end
            end
        end
    end
end)

-- Moved to Teleportation groupbox below
TeleportGroup:AddButton("Teleport to Grass Village", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local ground = workspace:FindFirstChild("__Main")
        if ground then
            local world2 = ground:FindFirstChild("__World")
            if world2 and world2:FindFirstChild("World 2") then
                local mainPart = world2["World 2"]:FindFirstChild("MainPart")
                if mainPart and mainPart:FindFirstChild("Meshes/ground") then
                    local target = mainPart["Meshes/ground"]
                    local targetPos = target.Position + Vector3.new(0, 15, 0)
                    local hrp = char.HumanoidRootPart
                    local humanoid = char.Humanoid
                    humanoid.PlatformStand = true
                    for i = 1, 3 do
                        hrp.CFrame = CFrame.new(targetPos)
                        task.wait(0.05)
                    end
                    humanoid.PlatformStand = false
                end
            end
        end
    end
end)

TeleportGroup:AddButton("Teleport to Brum Island", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local ground = workspace:FindFirstChild("__Main")
        if ground then
            local world3 = ground:FindFirstChild("__World")
            if world3 and world3:FindFirstChild("World 3") then
                local mainPart = world3["World 3"]:FindFirstChild("MainPart")
                if mainPart then
                    local children = mainPart:GetChildren()
                    if #children >= 3 and children[3]:IsA("BasePart") then
                        local target = children[3]
                        local targetPos = target.Position + Vector3.new(0, 15, 0)
                        local hrp = char.HumanoidRootPart
                        local humanoid = char.Humanoid
                        humanoid.PlatformStand = true
                        for i = 1, 3 do
                            hrp.CFrame = CFrame.new(targetPos)
                            task.wait(0.05)
                        end
                        humanoid.PlatformStand = false
                    end
                end
            end
        end
    end
end)

TeleportGroup:AddButton("Teleport to Faceheal Town", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local ground = workspace:FindFirstChild("__Main")
        if ground then
            local world4 = ground:FindFirstChild("__World")
            if world4 and world4:FindFirstChild("World 4") then
                local mainPart = world4["World 4"]:FindFirstChild("MainPart")
                if mainPart and mainPart:FindFirstChild("Part") then
                    local target = mainPart["Part"]
                    local targetPos = target.Position + Vector3.new(0, 15, 0)
                    local hrp = char.HumanoidRootPart
                    local humanoid = char.Humanoid
                    humanoid.PlatformStand = true
                    for i = 1, 3 do
                        hrp.CFrame = CFrame.new(targetPos)
                        task.wait(0.05)
                    end
                    humanoid.PlatformStand = false
                end
            end
        end
    end
end)

    TeleportGroup:AddButton("Teleport to Lucky Kingdom", function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local ground = workspace:FindFirstChild("__Main")
            if ground then
                local worlds = ground:FindFirstChild("__World")
                if worlds and worlds:FindFirstChild("World 5") then
                    local world5 = worlds["World 5"]
                    local blackCover = world5:FindFirstChild("black cover")
                    if blackCover and blackCover:FindFirstChild("MainPart") then
                        local mainPart = blackCover.MainPart
                        local children = mainPart:GetChildren()
                        if #children >= 2 and children[2]:IsA("BasePart") then
                            local target = children[2]
                            local targetPos = target.Position + Vector3.new(0, 15, 0)
                            local hrp = char.HumanoidRootPart
                            local humanoid = char.Humanoid
                            humanoid.PlatformStand = true
                            for i = 1, 3 do
                                hrp.CFrame = CFrame.new(targetPos)
                                task.wait(0.05)
                            end
                            humanoid.PlatformStand = false
                        end
                    end
                end
            end
        end
    end)

    TeleportGroup:AddButton("Teleport to Nipon City", function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local ground = workspace:FindFirstChild("__Main")
            if ground then
                local worlds = ground:FindFirstChild("__World")
                if worlds and worlds:FindFirstChild("World 6") then
                    local world6 = worlds["World 6"]
                    if world6 and world6:FindFirstChild("MainPart") then
                        local mainPart = world6.MainPart
                        if mainPart and mainPart:FindFirstChild("Part") then
                            local target = mainPart.Part
                            local targetPos = target.Position + Vector3.new(0, 15, 0)
                            local hrp = char.HumanoidRootPart
                            local humanoid = char.Humanoid
                            humanoid.PlatformStand = true
                            for i = 1, 3 do
                                hrp.CFrame = CFrame.new(targetPos)
                                task.wait(0.05)
                            end
                            humanoid.PlatformStand = false
                        end
                    end
                end
            end
        end
    end)

    TeleportGroup:AddButton("Teleport to Mori Town", function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local ground = workspace:FindFirstChild("__Main")
            if ground then
                local worlds = ground:FindFirstChild("__World")
                if worlds and worlds:FindFirstChild("World 7") then
                    local world7 = worlds["World 7"]
                    if world7 and world7:FindFirstChild("MainPart") then
                        local mainPart = world7.MainPart
                        if mainPart and mainPart:FindFirstChild("Part") then
                            local target = mainPart.Part
                            local targetPos = target.Position + Vector3.new(0, 15, 0)
                            local hrp = char.HumanoidRootPart
                            local humanoid = char.Humanoid
                            humanoid.PlatformStand = true
                            for i = 1, 3 do
                                hrp.CFrame = CFrame.new(targetPos)
                                task.wait(0.05)
                            end
                            humanoid.PlatformStand = false
                        end
                    end
                end
            end
        end
    end)
TeleportGroup:AddButton("Teleport to Dragon City", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local targetPos = Vector3.new(-2540.677001953125, 28.198110580444336, 5844.87939453125)
        local hrp = char.HumanoidRootPart
        local humanoid = char.Humanoid

        humanoid.PlatformStand = true
        for i = 1, 3 do
            hrp.CFrame = CFrame.new(targetPos)
            task.wait(0.05)
        end
        humanoid.PlatformStand = false
    end
end)

        TeleportGroup:AddButton("Teleport to XZ City", function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local ground = workspace:FindFirstChild("__Main")
            if ground then
                local worlds = ground:FindFirstChild("__World")
                if worlds and worlds:FindFirstChild("World 9") then
                    local world9 = worlds["World 9"]
                    if world9 and world9:FindFirstChild("one punch") then
                        local onePunch = world9["one punch"]
                        if onePunch and onePunch:FindFirstChild("MainPart") then
                            local mainPart = onePunch.MainPart
                            if mainPart and mainPart:FindFirstChild("Part") then
                                local target = mainPart.Part
                                local targetPos = target.Position + Vector3.new(0, 15, 0)
                                local hrp = char.HumanoidRootPart
                                local humanoid = char.Humanoid
                                humanoid.PlatformStand = true
                                for i = 1, 3 do
                                    hrp.CFrame = CFrame.new(targetPos)
                                    task.wait(0.05)
                                end
                                humanoid.PlatformStand = false
                            end
                        end
                    end
                end
            end
        end
    end)

TeleportGroup:AddButton("Teleport to Kindama City", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local targetPos = Vector3.new(-3379.10791015625, 21.962032318115234, -96.6770248413086)
        local hrp = char.HumanoidRootPart
        local humanoid = char.Humanoid

        humanoid.PlatformStand = true
        for i = 1, 3 do
            hrp.CFrame = CFrame.new(targetPos)
            task.wait(0.05)
        end
        humanoid.PlatformStand = false
    end
end)

TeleportGroup:AddLabel("Quick teleport to World 2 Location")
TeleportGroup:AddButton("Teleport To Guild Hall", function()
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end

    -- Set attributes server expects
    player.Character:SetAttribute("InGuild", true)
    player.Character:SetAttribute("InTp", true)

    -- Teleport to Guild Hall TP position
    local guildPos = CFrame.new(9556.99609375, -166.3654327392578, 312.87945556640625) * CFrame.Angles(0, math.pi, 0)
    hrp.CFrame = guildPos

    -- Optional wait
    task.wait(0.1)

    if humanoid then humanoid.PlatformStand = false end
    player.Character:SetAttribute("InTp", false)
end)


-- Hunter City
TeleportGroup:AddButton("Teleport to Hunter City", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local targetPos = Vector3.new(-206.60409545898438, 24.16905403137207, -14.835261344909668)
        local hrp = char.HumanoidRootPart
        local humanoid = char.Humanoid

        humanoid.PlatformStand = true
        for i = 1, 3 do
            hrp.CFrame = CFrame.new(targetPos)
            task.wait(0.05)
        end
        humanoid.PlatformStand = false
    end
end)


-- Nen City
TeleportGroup:AddButton("Teleport to Nen City", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local ground = workspace:FindFirstChild("__Main")
        if ground then
            local worlds = ground:FindFirstChild("__World")
            if worlds and worlds:FindFirstChild("World 12") then
                local world12 = worlds["World 12"]
                if world12 and world12:FindFirstChild("MainGround") then
                    local mainGround = world12.MainGround
                    local target = mainGround:GetChildren()[2]
                    if target then
                        local targetPos = target.Position + Vector3.new(0, 15, 0)
                        local hrp = char.HumanoidRootPart
                        local humanoid = char.Humanoid
                        humanoid.PlatformStand = true
                        for i = 1, 3 do
                            hrp.CFrame = CFrame.new(targetPos)
                            task.wait(0.05)
                        end
                        humanoid.PlatformStand = false
                    end
                end
            end
        end
    end
end)
TeleportGroup:AddButton("Teleport to Hurricane Town!", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hrp = char.HumanoidRootPart
        local humanoid = char.Humanoid

        humanoid.PlatformStand = true  -- disable movement temporarily

        -- Teleport directly to the specified position
        local targetPos = Vector3.new(-1290.896240234375, 3.439640522003174, -4548.544921875)
        for i = 1, 3 do
            hrp.CFrame = CFrame.new(targetPos)
            task.wait(0.05)
        end

        humanoid.PlatformStand = false  -- re-enable movement
    end
end)

-- Cursed High
TeleportGroup:AddButton("Teleport to Cursed High", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local ground = workspace:FindFirstChild("__Main")
        if ground then
            local worlds = ground:FindFirstChild("__World")
            if worlds and worlds:FindFirstChild("World 14") then
                local world14 = worlds["World 14"]
                if world14 and world14:FindFirstChild("jujusto") then
                    local jujusto = world14.jujusto
                    if jujusto and jujusto:FindFirstChild("Ground") then
                        local groundPart = jujusto.Ground
                        if groundPart and groundPart:FindFirstChild("Part") then
                            local target = groundPart.Part
                            local targetPos = target.Position + Vector3.new(0, 15, 0)
                            local hrp = char.HumanoidRootPart
                            local humanoid = char.Humanoid
                            humanoid.PlatformStand = true
                            for i = 1, 3 do
                                hrp.CFrame = CFrame.new(targetPos)
                                task.wait(0.05)
                            end
                            humanoid.PlatformStand = false
                        end
                    end
                end
            end
        end
    end
end)

-- Slayer's Village
TeleportGroup:AddButton("Teleport to Slayer's Village", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local ground = workspace:FindFirstChild("__Main")
        if ground then
            local worlds = ground:FindFirstChild("__World")
            if worlds and worlds:FindFirstChild("World 15") then
                local world15 = worlds["World 15"]
                if world15 and world15:FindFirstChild("World 15") then
                    local innerWorld = world15["World 15"]
                    if innerWorld and innerWorld:FindFirstChild("Model") then
                        local model = innerWorld.Model
                        if model and model:FindFirstChild("Part") then
                            local target = model.Part
                            local targetPos = target.Position + Vector3.new(0, 15, 0)
                            local hrp = char.HumanoidRootPart
                            local humanoid = char.Humanoid
                            humanoid.PlatformStand = true
                            for i = 1, 3 do
                                hrp.CFrame = CFrame.new(targetPos)
                                task.wait(0.05)
                            end
                            humanoid.PlatformStand = false
                        end
                    end
                end
            end
        end
    end
end)

-- Kaiju City
TeleportGroup:AddButton("Teleport to Kaiju City", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local ground = workspace:FindFirstChild("__Main")
        if ground then
            local worlds = ground:FindFirstChild("__World")
            if worlds and worlds:FindFirstChild("World 16") then
                local world16 = worlds["World 16"]
                if world16 and world16:FindFirstChild("Buildings") then
                    local buildings = world16.Buildings
                    local targetBuilding = buildings:GetChildren()[34]
                    if targetBuilding and targetBuilding:FindFirstChild("Model") then
                        local model = targetBuilding.Model
                        if model and model:FindFirstChild("Part") then
                            local target = model.Part
                            local targetPos = target.Position + Vector3.new(0, 15, 0)
                            local hrp = char.HumanoidRootPart
                            local humanoid = char.Humanoid
                            humanoid.PlatformStand = true
                            for i = 1, 3 do
                                hrp.CFrame = CFrame.new(targetPos)
                                task.wait(0.05)
                            end
                            humanoid.PlatformStand = false
                        end
                    end
                end
            end
        end
    end
end)
-- Wall Kingdom
TeleportGroup:AddButton("Teleport to Wall Kingdom", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local ground = workspace:FindFirstChild("__Main")
        if ground then
            local worlds = ground:FindFirstChild("__World")
            if worlds and worlds:FindFirstChild("World 17") then
                local world17 = worlds["World 17"]
                if world17 and world17:FindFirstChild("attack on titan") then
                    local attackTitan = world17["attack on titan"]
                    if attackTitan and attackTitan:FindFirstChild("cais") then
                        local cais = attackTitan.cais
                        if cais and cais:FindFirstChild("Model") then
                            local model = cais.Model
                            local target = model.bodybox:GetChildren()[6]
                            if target then
                                local targetPos = target.Position + Vector3.new(0, 15, 0)
                                local hrp = char.HumanoidRootPart
                                local humanoid = char.Humanoid
                                humanoid.PlatformStand = true
                                for i = 1, 3 do
                                    hrp.CFrame = CFrame.new(targetPos)
                                    task.wait(0.05)
                                end
                                humanoid.PlatformStand = false
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Mage Town!
TeleportGroup:AddButton("Teleport to Mage Town!", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local ground = workspace:FindFirstChild("__Main")
        if ground then
            local worlds = ground:FindFirstChild("__World")
            if worlds and worlds:FindFirstChild("World 18") then
                local world18 = worlds["World 18"]
                if world18 and world18:FindFirstChild("frieren") then
                    local frieren = world18.frieren
                    if frieren and frieren:FindFirstChild("entrada") then
                        local entrada = frieren.entrada
                        if entrada and entrada:FindFirstChild("Model") then
                            local model = entrada.Model
                            local target = model:GetChildren()[16]
                            if target then
                                local targetPos = target.Position + Vector3.new(0, 15, 0)
                                local hrp = char.HumanoidRootPart
                                local humanoid = char.Humanoid
                                humanoid.PlatformStand = true
                                for i = 1, 3 do
                                    hrp.CFrame = CFrame.new(targetPos)
                                    task.wait(0.05)
                                end
                                humanoid.PlatformStand = false
                            end
                        end
                    end
                end
            end
        end
    end
end)

TeleportGroup:AddButton("Teleport to Shield Kingdom", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local targetPos = Vector3.new(2451.678466796875, 30.995227813720703, -3821.3974609375)
        local hrp = char.HumanoidRootPart
        local humanoid = char.Humanoid

        humanoid.PlatformStand = true
        for i = 1, 3 do
            hrp.CFrame = CFrame.new(targetPos)
            task.wait(0.05)
        end
        humanoid.PlatformStand = false
    end
end)


TeleportGroup:AddButton("Teleport to Jungle Island", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hrp = char.HumanoidRootPart
        local humanoid = char.Humanoid

        humanoid.PlatformStand = true  -- disable movement temporarily

        -- Teleport directly to the specified position
        local targetPos = Vector3.new(-2044.61865234375, 38.887359619140625, 5714.43310546875)
        for i = 1, 3 do
            hrp.CFrame = CFrame.new(targetPos)
            task.wait(0.05)
        end

        humanoid.PlatformStand = false  -- re-enable movement
    end
end)
TeleportGroup:AddButton("Teleport to Winter Island", function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hrp = char.HumanoidRootPart
        local humanoid = char.Humanoid

        humanoid.PlatformStand = true  -- disable movement temporarily

        -- Teleport directly to the specified position
        local targetPos = Vector3.new(4957.60009765625, 26.3306884765625, -2154.28515625)
        for i = 1, 3 do
            hrp.CFrame = CFrame.new(targetPos)
            task.wait(0.05)
        end

        humanoid.PlatformStand = false  -- re-enable movement
    end
end)

-- Auto Desert Logic
local autoDesertThread = nil
local function startAutoDesert()
    if autoDesertThread then return end
    autoDesertEnabled = true
    autoDesertThread = task.spawn(function()
        local lastEnemyId = nil
        local DISTANCE_THRESHOLD = 300 -- Change this value as needed
        while autoDesertEnabled do
            local main = workspace:FindFirstChild("__Main")
            local enemiesFolder = main and main:FindFirstChild("__Enemies") and main.__Enemies:FindFirstChild("Client")
            if enemiesFolder and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerPos = player.Character.HumanoidRootPart.Position
                local closestEnemy = nil
                local closestDist = math.huge
                for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                    if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                        local healthAmount = 0
                        local amountObj = enemy:FindFirstChild("HealthBar")
                            and enemy.HealthBar:FindFirstChild("Main")
                            and enemy.HealthBar.Main:FindFirstChild("Bar")
                            and enemy.HealthBar.Main.Bar:FindFirstChild("Amount")
                        if amountObj and amountObj:IsA("TextLabel") then
                            local text = amountObj.Text or ""
                            local num = tonumber(string.match(text, "[%d]+")) or 0
                            healthAmount = num
                        end
                        if healthAmount > 0 then
                            local dist = (enemy.HumanoidRootPart.Position - playerPos).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestEnemy = enemy
                            end
                        end
                    end
                end
                if closestEnemy then
                    local enemyId = closestEnemy:GetDebugId()
                    local amountObj = closestEnemy:FindFirstChild("HealthBar")
                        and closestEnemy.HealthBar:FindFirstChild("Main")
                        and closestEnemy.HealthBar.Main:FindFirstChild("Bar")
                        and closestEnemy.HealthBar.Main.Bar:FindFirstChild("Amount")
                    local healthAmount = 0
                    if amountObj and amountObj:IsA("TextLabel") then
                        local text = amountObj.Text or ""
                        local num = tonumber(string.match(text, "[%d]+")) or 0
                        healthAmount = num
                    end
                    -- If enemy is too far, teleport to it first
                    if closestDist > DISTANCE_THRESHOLD then
                        tweenToEnemy(closestEnemy)
                        wait(0.2)
                    end
                    if enemyId ~= lastEnemyId or not closestEnemy:FindFirstChild("HumanoidRootPart") or healthAmount <= 0 then
                        tweenToEnemy(closestEnemy)
                        lastEnemyId = enemyId
                        wait(0.2)
                    end
                else
                    lastEnemyId = nil
                end
            else
                lastEnemyId = nil
            end
            wait(0.1)
        end
    end)
end

local function stopAutoDesert()
    autoDesertEnabled = false
    if autoDesertThread then
        autoDesertThread = nil
    end
end

-- Auto Enter Dungeon Toggle Logic

-- Dungeon Info Label Logic
local function getCurrentDungeonModel()
    return workspace:FindFirstChild("__Main")
        and workspace.__Main:FindFirstChild("__Dungeon")
        and workspace.__Main.__Dungeon:FindFirstChild("Dungeon")
end

local dungeonLabel = ExtraLeftGroup:AddLabel("Dungeon: ?")
local mapLabel = ExtraLeftGroup:AddLabel("Map: ?")
local rankLabel = ExtraLeftGroup:AddLabel("Rank: ?")

task.spawn(function()
    while true do
        local dungeonModel = getCurrentDungeonModel()
        if dungeonModel then
            local dungeonMap = dungeonModel:GetAttribute("DungeonMap") or "?"
            local mapName = dungeonModel:GetAttribute("MapName") or "?"
            local dungeonRank = dungeonModel:GetAttribute("DungeonRank") or "?"
            if dungeonLabel and dungeonLabel.SetText then dungeonLabel:SetText("Dungeon: " .. dungeonMap) end
            if mapLabel and mapLabel.SetText then mapLabel:SetText("Map: " .. mapName) end
            if rankLabel and rankLabel.SetText then rankLabel:SetText("Rank: " .. dungeonRank) end
        else
            if dungeonLabel and dungeonLabel.SetText then dungeonLabel:SetText("Dungeon: N/A") end
            if mapLabel and mapLabel.SetText then mapLabel:SetText("Map: N/A") end
            if rankLabel and rankLabel.SetText then rankLabel:SetText("Rank: N/A") end
        end
        task.wait(2)
    end
end)

local autoEnterDungeonEnabled = false
local autoEnterDungeonThread = nil

local function isDungeonUIVisible()
    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
    local hud = playerGui:FindFirstChild("Hud")
    if hud then
        local upContainer = hud:FindFirstChild("UpContanier")
        return upContainer and upContainer.Visible
    end
    return false
end

local function getDungeonStatusText()
    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
    local hud = playerGui:FindFirstChild("Hud")
    if hud then
        local upContainer = hud:FindFirstChild("UpContanier")
        if upContainer then
            local dungeonInfo = upContainer:FindFirstChild("DungeonInfo")
            if dungeonInfo then
                local textLabel = dungeonInfo:FindFirstChild("TextLabel")
                if textLabel and textLabel:IsA("TextLabel") then
                    return textLabel.Text or ""
                end
            end
        end
    end
    return ""
end

local function isDungeonEnded()
    local statusText = getDungeonStatusText()
    return string.find(statusText:lower(), "dungeon ends") ~= nil
end

local function enterDungeon()
    -- Buy dungeon ticket
    local buyArgs = {
        [1] = {
            [1] = {
                ["Type"] = "Gems";
                ["Event"] = "DungeonAction";
                ["Action"] = "BuyTicket";
            };
            [2] = "\r";
        };
    }
    game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2", 9e9):WaitForChild("dataRemoteEvent", 9e9):FireServer(unpack(buyArgs))
    task.wait(0.5)
    
    -- Create dungeon
    local createArgs = {
        [1] = {
            [1] = {
                ["Event"] = "DungeonAction";
                ["Action"] = "Create";
            };
            [2] = "\r";
        };
    }
    game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2", 9e9):WaitForChild("dataRemoteEvent", 9e9):FireServer(unpack(createArgs))
    task.wait(0.5)
    
    -- Start dungeon with player's UserId
    local startArgs = {
        [1] = {
            [1] = {
                ["Dungeon"] = player.UserId;
                ["Event"] = "DungeonAction";
                ["Action"] = "Start";
            };
            [2] = "\r";
        };
    }
    game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2", 9e9):WaitForChild("dataRemoteEvent", 9e9):FireServer(unpack(startArgs))
end

local function startAutoEnterDungeon()
    if autoEnterDungeonThread then return end
    autoEnterDungeonEnabled = true
    autoEnterDungeonThread = task.spawn(function()
        -- First run - enter dungeon immediately
        if autoEnterDungeonEnabled then
            print("[Auto Enter Dungeon] Starting first dungeon...")
            enterDungeon()
            task.wait(3) -- Wait for dungeon to start
        end
        
        while autoEnterDungeonEnabled do
            if isDungeonUIVisible() then
                -- We're in a dungeon, check if it's ending
                if isDungeonEnded() then
                    print("[Auto Enter Dungeon] Dungeon ending detected, entering new dungeon...")
                    enterDungeon()
                    task.wait(3) -- Wait for new dungeon to start
                else
                    -- Dungeon is still active, wait a bit
                    task.wait(1)
                end
            else
                -- No dungeon UI visible, enter a new dungeon
                print("[Auto Enter Dungeon] No active dungeon detected, entering new dungeon...")
                enterDungeon()
                task.wait(3) -- Wait for dungeon to start
            end
            
            task.wait(0.5) -- Small delay between checks
        end
    end)
end

local function stopAutoEnterDungeon()
    autoEnterDungeonEnabled = false
    if autoEnterDungeonThread then
        autoEnterDungeonThread = nil
    end
end

ExtraLeftGroup:AddToggle("AutoEnterDungeonToggle", {
    Text = "Auto Enter Dungeon",
    Default = config.AutoEnterDungeonEnabled or false,
    Tooltip = "Automatically creates and enters dungeons. Waits for current dungeon to end before starting new one.",
    Callback = function(value)
        autoEnterDungeonEnabled = value
        config.AutoEnterDungeonEnabled = value
        if type(saveConfig) == "function" then saveConfig() end
        if value then
            startAutoEnterDungeon()
        else
            stopAutoEnterDungeon()
        end
    end
})
-- Auto start logic for Auto Enter Dungeon
task.spawn(function()
    task.wait(1)
    if config and config.AutoEnterDungeonEnabled then
        autoEnterDungeonEnabled = true
        startAutoEnterDungeon()
    end
end)

local montanhaLowParts = {}
local montanhaLowDropdownObj = nil
local function getFullPath(part)
    local path = {}
    local current = part
    while current and current ~= workspace do
        table.insert(path, 1, current.Name)
        current = current.Parent
    end
    return table.concat(path, ".")
end

local function updateMontanhaLowParts()
    montanhaLowParts = {}
    local wilds = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__World") and workspace.__Main.__World:FindFirstChild("Wilds")
    if wilds then
        local function deepSearch(parent)
            for _, child in ipairs(parent:GetChildren()) do
                if child.Name == "montanha_low" then
                    table.insert(montanhaLowParts, child)
                end
                deepSearch(child)
            end
        end
        deepSearch(wilds)
    end
end

local function getMontanhaLowDropdownValues()
    local values = {}
    for i, part in ipairs(montanhaLowParts) do
        local displayName = "Mount Island " .. i
        table.insert(values, displayName)
    end
    return values
end

montanhaLowDropdownObj = Teleport2Group:AddDropdown("MontanhaLowDropdown", {
    Text = "Mounts Island",
    Values = getMontanhaLowDropdownValues(),
    Default = getMontanhaLowDropdownValues()[1],
    Tooltip = "Select a mount island to teleport to.",
    Callback = function(selected)
        for i, part in ipairs(montanhaLowParts) do
            local displayName = "Mount Island " .. i
            if displayName == selected then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local hrp = player.Character.HumanoidRootPart
                    local humanoid = player.Character.Humanoid
                    local targetPos = part.Position + Vector3.new(0, 15, 0)
                    humanoid.PlatformStand = true
                    for j = 1, 3 do
                        hrp.CFrame = CFrame.new(targetPos)
                        task.wait(0.05)
                    end
                    humanoid.PlatformStand = false
                    print("Teleported to ", displayName)
                end
                break
            end
        end
    end
})

task.spawn(function()
    while true do
        updateMontanhaLowParts()
        if montanhaLowDropdownObj and montanhaLowDropdownObj.SetValues then
            montanhaLowDropdownObj:SetValues(getMontanhaLowDropdownValues())
        end
        task.wait(2)
    end
end)
-- Shadow Upgrader Toggle Logic
local normalRange = 10
local infiniteRange = 999999999999999999999999
local prompt = nil
local toggled = false
local shadowUpgraderInteraction = nil

local function findZonePrompt()
    local others = workspace:FindFirstChild("__Extra") and workspace.__Extra:FindFirstChild("__Interactions") and workspace.__Extra.__Interactions:FindFirstChild("Others")
    if others then
        local upgrader = others:FindFirstChild("Upgrader1")
        if upgrader and upgrader:FindFirstChild("Model") and upgrader.Model:FindFirstChild("ZonePrompt") then
            return upgrader.Model.ZonePrompt
        end
    end
    return nil
end

local function findShadowUpgraderInteraction()
    local others = workspace:FindFirstChild("__Extra") and workspace.__Extra:FindFirstChild("__Interactions") and workspace.__Extra.__Interactions:FindFirstChild("Others")
    if others then
        local upgrader = others:FindFirstChild("Upgrader1")
        if upgrader and upgrader:FindFirstChild("Model") then
            local children = upgrader.Model:GetChildren()
            if #children >= 6 then
                return children[6]
            end
        end
    end
    return nil
end

ShopsGroup:AddToggle("ShadowUpgraderToggle", {
    Text = "Shadow Upgrader",
    Default = false,
    Tooltip = "Toggle infinite range for the Shadow Upgrader zone prompt.",
    Callback = function(value)
        toggled = value
        if not prompt or not prompt.Parent then prompt = findZonePrompt() end
        if not shadowUpgraderInteraction or not shadowUpgraderInteraction.Parent then shadowUpgraderInteraction = findShadowUpgraderInteraction() end
        if not prompt and not shadowUpgraderInteraction then
            warn("Shadow Upgrader ZonePrompt/Interaction not found!")
            prompt = nil
            shadowUpgraderInteraction = nil
            return
        end
        if value then
            if prompt and prompt:IsA("ProximityPrompt") then prompt.MaxActivationDistance = infiniteRange end
            if shadowUpgraderInteraction and shadowUpgraderInteraction:IsA("ProximityPrompt") then shadowUpgraderInteraction.MaxActivationDistance = infiniteRange end
            print("[Shadow Upgrader] Range set to INFINITE")
            -- Face camera to specified position
            local camera = workspace.CurrentCamera
            if camera and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local targetPos = Vector3.new(594.5536499023438, 28.08351707458496, 189.5341796875)
                camera.CFrame = CFrame.new(hrp.Position, targetPos)
            end
        else
            if prompt and prompt:IsA("ProximityPrompt") then prompt.MaxActivationDistance = normalRange end
            if shadowUpgraderInteraction and shadowUpgraderInteraction:IsA("ProximityPrompt") then shadowUpgraderInteraction.MaxActivationDistance = normalRange end
            print("[Shadow Upgrader] Range reset to NORMAL (" .. normalRange .. ")")
        end
    end
})


-- Weapon Shop Toggle Logic
-- Helper to get Blacksmith models (Blacksmith1 and Blacksmith2)
local function getBlacksmithModels()
    local models = {}
    local shops = workspace:FindFirstChild("__Extra") and workspace.__Extra:FindFirstChild("__Interactions") and workspace.__Extra.__Interactions:FindFirstChild("Shops")
    if shops then
        for _, name in ipairs({
            "Blacksmith1", "Blacksmith2", "Blacksmith3", "Blacksmith4", "Blacksmith5", "Blacksmith6", "Blacksmith7", "Blacksmith8", "Blacksmith9",
            "Blacksmith10", "Blacksmith11", "Blacksmith12", "Blacksmith13", "Blacksmith14", "Blacksmith15", "Blacksmith16", "Blacksmith17", "Blacksmith18", "Blacksmith19"
        }) do
            local bs = shops:FindFirstChild(name)
            if bs and bs:FindFirstChild("Model") then
                table.insert(models, bs.Model)
            end
        end
    end
    return models
end

-- Helper to get ZonePrompt and interaction for a Blacksmith model
local function getBlacksmithZonePromptAndInteraction(model)
    local zonePrompt = model:FindFirstChild("ZonePrompt")
    local interaction = nil
    local children = model:GetChildren()
    if model.Parent and model.Parent.Name == "Blacksmith4" and #children >= 6 then
        interaction = children[6]
    elseif model.Parent and model.Parent.Name == "Blacksmith5" and #children >= 14 then
        interaction = children[14]
    elseif model.Parent and model.Parent.Name == "Blacksmith6" and #children >= 7 then
        interaction = children[7]
    elseif model.Parent and model.Parent.Name == "Blacksmith7" and #children >= 12 then
        interaction = children[12]
    elseif model.Parent and model.Parent.Name == "Blacksmith8" and #children >= 9 then
        interaction = children[9]
    elseif model.Parent and model.Parent.Name == "Blacksmith9" and #children >= 8 then
        interaction = children[8]
    elseif model.Parent and model.Parent.Name == "Blacksmith10" and #children >= 8 then
        interaction = children[8]
    elseif model.Parent and model.Parent.Name == "Blacksmith11" and #children >= 7 then
        interaction = children[7]
    elseif model.Parent and model.Parent.Name == "Blacksmith12" and #children >= 10 then
        interaction = children[10]
    elseif model.Parent and model.Parent.Name == "Blacksmith13" and #children >= 13 then
        interaction = children[13]
    elseif model.Parent and model.Parent.Name == "Blacksmith14" and #children >= 14 then
        interaction = children[14]
    elseif model.Parent and model.Parent.Name == "Blacksmith15" and #children >= 6 then
        interaction = children[6]
    elseif model.Parent and model.Parent.Name == "Blacksmith16" and #children >= 7 then
        interaction = children[7]
    elseif model.Parent and model.Parent.Name == "Blacksmith17" and #children >= 14 then
        interaction = children[14]
    elseif model.Parent and model.Parent.Name == "Blacksmith18" and #children >= 10 then
        interaction = children[10]
    elseif model.Parent and model.Parent.Name == "Blacksmith19" and #children >= 7 then
        interaction = children[7]
    else
        -- Find the first ProximityPrompt in the children (excluding ZonePrompt itself)
        for _, child in ipairs(children) do
            if child:IsA("ProximityPrompt") and child ~= zonePrompt then
                interaction = child
                break
            end
        end
    end
    return zonePrompt, interaction
end

-- Helper to get position for camera facing
local function getBlacksmithPosition(model)
    if model.Parent and model.Parent.Name == "Blacksmith2" then
        return Vector3.new(-3423.2763671875, 29.826623916625977, 2281.03173828125)
    elseif model.Parent and model.Parent.Name == "Blacksmith3" then
        return Vector3.new(-2830.96337890625, 49.78124237060547, -2035.2493896484375)
    elseif model.Parent and model.Parent.Name == "Blacksmith4" then
        return Vector3.new(2600.25146484375, 46.42755126953125, -2718.678955078125)
    elseif model.Parent and model.Parent.Name == "Blacksmith5" then
        return Vector3.new(189.26866149902344, 37.85315704345703, 4394.74072265625)
    elseif model.Parent and model.Parent.Name == "Blacksmith6" then
        return Vector3.new(290.38397216796875, 32.89610290527344, -4414.7177734375)
    elseif model.Parent and model.Parent.Name == "Blacksmith7" then
        return Vector3.new(4884.89990234375, 41.03144073486328, -74.8937759399414)
    elseif model.Parent and model.Parent.Name == "Blacksmith8" then
        return Vector3.new(-6332.99658203125, 26.775508880615234, 10104.55859375)
    elseif model.Parent and model.Parent.Name == "Blacksmith9" then
        return Vector3.new(3276.05224609375, 26.1219539642334, 6421.46533203125)
    elseif model.Parent and model.Parent.Name == "Blacksmith10" then
        return Vector3.new(-6545.13232421875, 21.53952980041504, -909.49267578125)
    elseif model.Parent and model.Parent.Name == "Blacksmith11" then
        return Vector3.new(1455.4693603515625, 24.106775283813477, -2673.127685546875)
    elseif model.Parent and model.Parent.Name == "Blacksmith12" then
        return Vector3.new(-4850.826171875, 33.52973556518555, -2685.71630859375)
    elseif model.Parent and model.Parent.Name == "Blacksmith13" then
        return Vector3.new(-1323.5699462890625, 24.910598754882812, -4585.32666015625)
    elseif model.Parent and model.Parent.Name == "Blacksmith14" then
        return Vector3.new(565.022216796875, 31.208229064941406, 4507.0283203125)
    elseif model.Parent and model.Parent.Name == "Blacksmith15" then
        return Vector3.new(-6283.4443359375, 25.666419982910156, 1198.1107177734375)
    elseif model.Parent and model.Parent.Name == "Blacksmith16" then
        return Vector3.new(4486.53369140625, 21.545522689819336, 175.52232360839844)
    elseif model.Parent and model.Parent.Name == "Blacksmith17" then
        return Vector3.new(-8406.8408203125, 40.31238555908203, -1743.3988037109375)
    elseif model.Parent and model.Parent.Name == "Blacksmith18" then
        return Vector3.new(-4681.4111328125, 43.5290641784668, -7619.16552734375)
    elseif model.Parent and model.Parent.Name == "Blacksmith19" then
        return Vector3.new(2403.55810546875, 30.59404754638672, -3736.408203125)
    else
        return Vector3.new(539.83251953125, 27.940507888793945, 250.15574645996094)
    end
end

-- Find closest Blacksmith model to player
local function findClosestBlacksmithModel()
    local models = getBlacksmithModels()
    local closestModel = nil
    local closestDist = math.huge
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        for _, model in ipairs(models) do
            local zonePrompt = model:FindFirstChild("ZonePrompt")
            if zonePrompt then
                local pos = nil
                if zonePrompt.Parent and (zonePrompt.Parent:IsA("BasePart") or zonePrompt.Parent:IsA("Attachment")) then
                    pos = zonePrompt.Parent.Position
                end
                if not pos then
                    pos = getBlacksmithPosition(model)
                end
                local dist = (hrp.Position - pos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestModel = model
                end
            end
        end
    end
    return closestModel
end

ShopsGroup:AddToggle("BlacksmithToggle", {
    Text = "Weapon Shop",
    Default = false,
    Tooltip = "Toggle infinite range for the closest Blacksmith zone prompt.",
    Callback = function(value)
        local closestModel = findClosestBlacksmithModel()
        if not closestModel then
            warn("No Blacksmith found!")
            return
        end
        local zonePrompt, interaction = getBlacksmithZonePromptAndInteraction(closestModel)
        
        if value then
            if zonePrompt and zonePrompt:IsA("ProximityPrompt") then zonePrompt.MaxActivationDistance = infiniteRange end
            if interaction and interaction:IsA("ProximityPrompt") then interaction.MaxActivationDistance = infiniteRange end
            print("[Blacksmith] Range set to INFINITE for closest Blacksmith")
            -- Face camera to closest Blacksmith
            local camera = workspace.CurrentCamera
            if camera and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local targetPos = getBlacksmithPosition(closestModel)
                camera.CFrame = CFrame.new(hrp.Position, targetPos)
            end
        else
            -- Reset both Blacksmiths to normal range
            for _, model in ipairs(getBlacksmithModels()) do
                local zp, inter = getBlacksmithZonePromptAndInteraction(model)
                if zp and zp:IsA("ProximityPrompt") then zp.MaxActivationDistance = normalRange end
                if inter and inter:IsA("ProximityPrompt") then inter.MaxActivationDistance = normalRange end
            end
            print("[Blacksmith] Range reset to NORMAL (" .. normalRange .. ") for all Blacksmiths")
        end
    end
})

-- Weapon Shop Toggle Logic
local weaponShopPrompt = nil
local weaponShopToggled = false
local weaponShopInteraction = nil

local function findWeaponShopZonePrompt()
    return workspace.__Extra.__Interactions.Others.Enchanter1.Model.ZonePrompt
end

local function findWeaponShopInteraction()
    return workspace.__Extra.__Interactions.Others.Enchanter1.Model:GetChildren()[12]
end

ShopsGroup:AddToggle("WeaponShopToggle", {
    Text = "Enchanter",
    Default = false,
    Tooltip = "Toggle infinite range for the Enchanter zone prompt.",
    Callback = function(value)
        weaponShopToggled = value
        if not weaponShopPrompt then weaponShopPrompt = findWeaponShopZonePrompt() end
        if not weaponShopInteraction then weaponShopInteraction = findWeaponShopInteraction() end
        if not weaponShopPrompt and not weaponShopInteraction then
            warn("Enchanter ZonePrompt/Interaction not found!")
            return
        end
        if value then
            if weaponShopPrompt then weaponShopPrompt.MaxActivationDistance = infiniteRange end
            if weaponShopInteraction and weaponShopInteraction.MaxActivationDistance ~= nil then weaponShopInteraction.MaxActivationDistance = infiniteRange end
            print("[Enchanter] Range set to INFINITE")
            -- Face camera to specified position
            local camera = workspace.CurrentCamera
            if camera and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local targetPos = Vector3.new(612.509765625, 28.0839900970459, 226.7568817138672)
                camera.CFrame = CFrame.new(hrp.Position, targetPos)
            end
        else
            if weaponShopPrompt then weaponShopPrompt.MaxActivationDistance = normalRange end
            if weaponShopInteraction and weaponShopInteraction.MaxActivationDistance ~= nil then weaponShopInteraction.MaxActivationDistance = normalRange end
            print("[Enchanter] Range reset to NORMAL (" .. normalRange .. ")")
        end
    end
})

-- Boat Seller Toggle Logic
-- Crafts Toggle Logic

-- Helper to get BoatSeller models (BoatSeller1 and BoatSeller2)
local function getBoatSellerModels()
    local models = {}
    local shops = workspace:FindFirstChild("__Extra") and workspace.__Extra:FindFirstChild("__Interactions") and workspace.__Extra.__Interactions:FindFirstChild("Shops")
    if shops then
        for _, name in ipairs({
            "BoatSeller1", "BoatSeller2", "BoatSeller3", "BoatSeller4", "BoatSeller5", "BoatSeller6", "BoatSeller7", "BoatSeller8",
            "BoatSeller9", "BoatSeller10", "BoatSeller11", "BoatSeller12", "BoatSeller13", "BoatSeller14", "BoatSeller15", "BoatSeller16", "BoatSeller17", "BoatSeller18", "BoatSeller19"
        }) do
            local bs = shops:FindFirstChild(name)
            if bs and bs:FindFirstChild("Model") then
                table.insert(models, bs.Model)
            end
        end
    end
    return models
end

-- Helper to get ZonePrompt and interaction for a BoatSeller model
local function getBoatSellerZonePromptAndInteraction(model)
    local zonePrompt = model:FindFirstChild("ZonePrompt")
    local interaction = nil
    local children = model:GetChildren()
    if model.Parent and model.Parent.Name == "BoatSeller1" and #children >= 5 then
        interaction = children[5]
    elseif model.Parent and model.Parent.Name == "BoatSeller2" and #children >= 6 then
        interaction = children[6]
    elseif model.Parent and model.Parent.Name == "BoatSeller3" and #children >= 10 then
        interaction = children[10]
    elseif model.Parent and model.Parent.Name == "BoatSeller4" and #children >= 9 then
        interaction = children[9]
    elseif model.Parent and model.Parent.Name == "BoatSeller5" and #children >= 8 then
        interaction = children[8]
    elseif model.Parent and model.Parent.Name == "BoatSeller6" and #children >= 3 then
        interaction = children[3]
    elseif model.Parent and model.Parent.Name == "BoatSeller7" and #children >= 7 then
        interaction = children[7]
    elseif model.Parent and model.Parent.Name == "BoatSeller8" and #children >= 5 then
        interaction = children[5]
    elseif model.Parent and model.Parent.Name == "BoatSeller9" and #children >= 10 then
        interaction = children[10]
    elseif model.Parent and model.Parent.Name == "BoatSeller10" and #children >= 5 then
        interaction = children[5]
    elseif model.Parent and model.Parent.Name == "BoatSeller11" and #children >= 6 then
        interaction = children[6]
    elseif model.Parent and model.Parent.Name == "BoatSeller12" and #children >= 10 then
        interaction = children[10]
    elseif model.Parent and model.Parent.Name == "BoatSeller13" and #children >= 10 then
        interaction = children[10]
    elseif model.Parent and model.Parent.Name == "BoatSeller14" and #children >= 6 then
        interaction = children[6]
    elseif model.Parent and model.Parent.Name == "BoatSeller15" and #children >= 11 then
        interaction = children[11]
    elseif model.Parent and model.Parent.Name == "BoatSeller16" and #children >= 11 then
        interaction = children[11]
    elseif model.Parent and model.Parent.Name == "BoatSeller17" and #children >= 6 then
        interaction = children[6]
    elseif model.Parent and model.Parent.Name == "BoatSeller18" and #children >= 10 then
        interaction = children[10]
    elseif model.Parent and model.Parent.Name == "BoatSeller19" and #children >= 4 then
        interaction = children[4]
    end
    return zonePrompt, interaction
end

-- Helper to get position for camera facing
local function getBoatSellerPosition(model)

    if model.Parent and model.Parent.Name == "BoatSeller2" then
        return Vector3.new(-3661.37353515625, 24.10602378845215, 2363.49267578125)
    elseif model.Parent and model.Parent.Name == "BoatSeller3" then
        return Vector3.new(-2790.7216796875, 30.246509552001953, -2014.2769775390625)
    elseif model.Parent and model.Parent.Name == "BoatSeller4" then
        return Vector3.new(2474.9384765625, 46.58359146118164, -2842.829833984375)
    elseif model.Parent and model.Parent.Name == "BoatSeller5" then
        return Vector3.new(210.8640594482422, 38.86373519897461, 4255.52392578125)
    elseif model.Parent and model.Parent.Name == "BoatSeller6" then
        return Vector3.new(94.77432250976562, 21.119211196899414, -4237.11279296875)
    elseif model.Parent and model.Parent.Name == "BoatSeller7" then
        return Vector3.new(4815.90869140625, 30.006729125976562, -95.53572082519531)
    elseif model.Parent and model.Parent.Name == "BoatSeller8" then
        return Vector3.new(-2529.31982421875, 27.157434463500977, 5762.9970703125)
    elseif model.Parent and model.Parent.Name == "BoatSeller9" then
        return Vector3.new(3343.68212890625, 26.573043823242188, 6323.29345703125)
    elseif model.Parent and model.Parent.Name == "BoatSeller10" then
        return Vector3.new(-3360.84619140625, 21.56800079345703, -160.28204345703125)
    elseif model.Parent and model.Parent.Name == "BoatSeller11" then
        return Vector3.new(1415.3555908203125, 20.288488388061523, -2571.559326171875)
    elseif model.Parent and model.Parent.Name == "BoatSeller12" then
        return Vector3.new(-4829.244140625, 34.5832633972168, -2648.64892578125)
    elseif model.Parent and model.Parent.Name == "BoatSeller13" then
        return Vector3.new(-1313.1663818359375, 23.42242431640625, -4524.83984375)
    elseif model.Parent and model.Parent.Name == "BoatSeller14" then
        return Vector3.new(613.509033203125, 30.65240478515625, 4420.54345703125)
    elseif model.Parent and model.Parent.Name == "BoatSeller15" then
        return Vector3.new(-6165.73486328125, 26.003768920898438, 1138.8572998046875)
    elseif model.Parent and model.Parent.Name == "BoatSeller16" then
        return Vector3.new(4411.025390625, 20.84771156311035, 169.190673828125)
    elseif model.Parent and model.Parent.Name == "BoatSeller17" then
        return Vector3.new(-8336.1455078125, 20.385845184326172, -1826.774169921875)
    elseif model.Parent and model.Parent.Name == "BoatSeller18" then
        return Vector3.new(-4548.71630859375, 30.603622436523438, -7479.779296875)
    elseif model.Parent and model.Parent.Name == "BoatSeller19" then
        return Vector3.new(2471.48828125, 33.78651428222656, -3783.58984375)
    else
        return Vector3.new(422.62750244140625, 28.300968170166016, 388.5313415527344)
    end
end

-- Find closest BoatSeller model to player
local function findClosestBoatSellerModel()
    local models = getBoatSellerModels()
    local closestModel = nil
    local closestDist = math.huge
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        for _, model in ipairs(models) do
            local zonePrompt = model:FindFirstChild("ZonePrompt")
            if zonePrompt then
                local pos = nil
                if zonePrompt.Parent and (zonePrompt.Parent:IsA("BasePart") or zonePrompt.Parent:IsA("Attachment")) then
                    pos = zonePrompt.Parent.Position
                end
                if not pos then
                    pos = getBoatSellerPosition(model)
                end
                local dist = (hrp.Position - pos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestModel = model
                end
            end
        end
    end
    return closestModel
end

ShopsGroup:AddToggle("BoatSellerToggle", {
    Text = "Boat Seller",
    Default = false,
    Tooltip = "Toggle infinite range for the closest Boat Seller (ZonePrompt and interaction).",
    Callback = function(value)
        local closestModel = findClosestBoatSellerModel()
        if not closestModel then
            warn("No Boat Seller found!")
            return
        end
        local zonePrompt, interaction = getBoatSellerZonePromptAndInteraction(closestModel)
        if value then
            if zonePrompt and zonePrompt:IsA("ProximityPrompt") then zonePrompt.MaxActivationDistance = infiniteRange end
            if interaction and interaction:IsA("ProximityPrompt") then interaction.MaxActivationDistance = infiniteRange end
            print("[Boat Seller] Range set to INFINITE for closest Boat Seller")
            -- Face camera to closest Boat Seller
            local camera = workspace.CurrentCamera
            if camera and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local targetPos = getBoatSellerPosition(closestModel)
                camera.CFrame = CFrame.new(hrp.Position, targetPos)
            end
        else
            -- Reset both Boat Sellers to normal range
            for _, model in ipairs(getBoatSellerModels()) do
                local zp, inter = getBoatSellerZonePromptAndInteraction(model)
                if zp and zp:IsA("ProximityPrompt") then zp.MaxActivationDistance = normalRange end
                if inter and inter:IsA("ProximityPrompt") then inter.MaxActivationDistance = normalRange end
            end
            print("[Boat Seller] Range reset to NORMAL (" .. normalRange .. ") for all Boat Sellers")
        end
    end
})

DungeonGroup:AddLabel("Enter the Desert Dungeon below:")
DungeonGroup:AddButton("Enter Desert Dungeon", function()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local bridgeNet2 = replicatedStorage:WaitForChild("BridgeNet2", 9e9)
    local dataRemoteEvent = bridgeNet2:WaitForChild("dataRemoteEvent", 9e9)
    -- First: Create InfiniteMode
    local createArgs = {
        [1] = {
            [1] = {
                ["Event"] = "InfiniteModeAction",
                ["Action"] = "Create",
            },
            [2] = "\r",
        },
    }
    dataRemoteEvent:FireServer(unpack(createArgs))
    -- Then: Start Desert Dungeon using LocalPlayer's UserId
    local player = game:GetService("Players").LocalPlayer
    local startArgs = {
        [1] = {
            [1] = {
                ["Dungeon"] = player.UserId,
                ["Event"] = "InfiniteModeAction",
                ["Action"] = "Start",
            },
            [2] = "\r",
        },
    }
    dataRemoteEvent:FireServer(unpack(startArgs))
end)

DungeonGroup:AddLabel("Enter the Castle Dungeon below:")
DungeonGroup:AddButton("Enter Castle", function()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local bridgeNet2 = replicatedStorage:WaitForChild("BridgeNet2", 9e9)
    local dataRemoteEvent = bridgeNet2:WaitForChild("dataRemoteEvent", 9e9)

    -- Auto Join Castle
    local args = {
        [1] = {
            [1] = {
                ["Check"] = false,
                ["Event"] = "CastleAction",
                ["Action"] = "Join",
            },
            [2] = "\r",
        },
    }
    dataRemoteEvent:FireServer(unpack(args))
end)

DungeonGroup:AddLabel("Enter the Rank Test below:")
DungeonGroup:AddButton("Enter Rank Test", function()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local bridgeNet2 = replicatedStorage:WaitForChild("BridgeNet2", 9e9)
    local dataRemoteEvent = bridgeNet2:WaitForChild("dataRemoteEvent", 9e9)

    local args = {
        [1] = {
            [1] = {
                ["Event"] = "DungeonAction",
                ["Action"] = "TestEnter",
            },
            [2] = "\r",
        },
    }

    dataRemoteEvent:FireServer(unpack(args))
end)



-- Server Hop Button
ShopsTab:AddRightGroupbox("Server", "shuffle"):AddButton("Server Hop", function()
    local TeleportService = game:GetService("TeleportService")
    local player = game.Players.LocalPlayer
    local placeId = game.PlaceId
    local servers = {}
    local function serverHop()
        local req = syn and syn.request or http and http.request or http_request or request
        if req then
            local response = req({
                Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", placeId),
                Method = "GET"
            })
            local data = response and response.Body and game:GetService("HttpService"):JSONDecode(response.Body)
            if data and data.data then
                for _, v in pairs(data.data) do
                    if v.playing < v.maxPlayers and v.id ~= game.JobId then
                        table.insert(servers, v.id)
                    end
                end
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], player)
        else
            TeleportService:Teleport(placeId, player)
        end
    end
    serverHop()
end, {
    Text = "Server Hop",
    Tooltip = "Teleport to a different server."
})



local statOptions = {
    {Display = "Shadow Power", Internal = "ShadowDamage"},
    {Display = "Shadow Agility", Internal = "ShadowSpeed"},
    {Display = "Shadow Reach", Internal = "ShadowRange"},
    {Display = "Player Speed", Internal = "PlayerSpeed"},
    {Display = "Weapon Mastery", Internal = "WeaponDamage"},
    {Display = "Player Experience", Internal = "PlayerExp"}
}

local autoStatsThread = nil

local statsDropdownObj = StatsGroup:AddDropdown("StatsDropdown", {
    Text = "Select Stat",
    Values = (function()
        local names = {}
        for i, v in ipairs(statOptions) do
            table.insert(names, v.Display)
        end
        return names
    end)(),
    Default = (function()
        local valid = false
        for i, v in ipairs(statOptions) do
            if v.Display == config.SelectedStat then
                valid = true
                break
            end
        end
        return valid and config.SelectedStat or statOptions[1].Display
    end)(),
    Tooltip = "Choose which stat to auto-upgrade.",
    Callback = function(value)
        selectedStat = value
        config.SelectedStat = value
        saveConfig()
    end
})

local function startAutoStats()
    if autoStatsThread then return end
    autoStatsEnabled = true
    autoStatsThread = task.spawn(function()
        while autoStatsEnabled do
            local internalStat = nil
            for i, v in ipairs(statOptions) do
                if v.Display == selectedStat then
                    internalStat = v.Internal
                    break
                end
            end
            if internalStat then
                dataRemoteEvent:FireServer({
                    {
                        Stats = internalStat,
                        Event = "StatsUp",
                        Points = 1
                    },
                    "\12"
                })
            end
            task.wait(0.2)
        end
    end)
end

local function stopAutoStats()
    autoStatsEnabled = false
    if autoStatsThread then
        autoStatsThread = nil
    end
end

StatsGroup:AddToggle("AutoStatsToggle", {
    Text = "Auto Upgrade Stat",
    Default = config.AutoStatsEnabled or false,
    Tooltip = "Automatically upgrades the selected stat.",
    Callback = function(value)
        autoStatsEnabled = value
        config.AutoStatsEnabled = value
        saveConfig()
        if value then
            startAutoStats()
        else
            stopAutoStats()
        end
    end
})

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
            -- Removed debug print
            break
        elseif i == #imageFormats then
            -- If all formats fail, use a text fallback
            -- Removed debug print
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
                        -- Removed debug print
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

-- AutoDungeon Toggle and Dropdown
local autoDungeonThread = nil
local function startAutoDungeon()
    if autoDungeonThread then return end
    autoDungeonEnabled = true
    autoDungeonThread = task.spawn(function()
        local lastEnemyId = nil
        local DISTANCE_THRESHOLD = 2000 -- Increased range for far enemies
        while autoDungeonEnabled do
            local main = workspace:FindFirstChild("__Main")
            local world = main and main:FindFirstChild("__World")
            local foundRoom = false
            if world then
                for i = 1, 21 do
                    if world:FindFirstChild("Room_" .. i) then
                        foundRoom = true
                        break
                    end
                end
            end
            if not foundRoom then
                lastEnemyId = nil
                wait(1)
                continue
            end
            local enemiesFolder = main and main:FindFirstChild("__Enemies") and main.__Enemies:FindFirstChild("Client")
            if enemiesFolder and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerPos = player.Character.HumanoidRootPart.Position
                local closestEnemy = nil
                local closestDist = math.huge
                for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                    if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                        local healthAmount = 0
                        local amountObj = enemy:FindFirstChild("HealthBar")
                            and enemy.HealthBar:FindFirstChild("Main")
                            and enemy.HealthBar.Main:FindFirstChild("Bar")
                            and enemy.HealthBar.Main.Bar:FindFirstChild("Amount")
                        if amountObj and amountObj:IsA("TextLabel") then
                            local text = amountObj.Text or ""
                            local num = tonumber(string.match(text, "[%d]+")) or 0
                            healthAmount = num
                        end
                        if healthAmount > 0 then
                            local dist = (enemy.HumanoidRootPart.Position - playerPos).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestEnemy = enemy
                            end
                        end
                    end
                end
                if closestEnemy then
                    local enemyId = closestEnemy:GetDebugId()
                    local amountObj = closestEnemy:FindFirstChild("HealthBar")
                        and closestEnemy.HealthBar:FindFirstChild("Main")
                        and closestEnemy.HealthBar.Main:FindFirstChild("Bar")
                        and closestEnemy.HealthBar.Main.Bar:FindFirstChild("Amount")
                    local healthAmount = 0
                    if amountObj and amountObj:IsA("TextLabel") then
                        local text = amountObj.Text or ""
                        local num = tonumber(string.match(text, "[%d]+")) or 0
                        healthAmount = num
                    end
                    -- If enemy is too far, teleport to it first
                    if closestDist > DISTANCE_THRESHOLD then
                        tweenToEnemy(closestEnemy)
                        wait(0.2)
                    end
                    if enemyId ~= lastEnemyId or not closestEnemy:FindFirstChild("HumanoidRootPart") or healthAmount <= 0 then
                        tweenToEnemy(closestEnemy)
                        lastEnemyId = enemyId
                        wait(0.2)
                    end
                else
                    lastEnemyId = nil
                end
            else
                lastEnemyId = nil
            end
            wait(0.1)
        end
    end)
end

local function stopAutoDungeon()
    autoDungeonEnabled = false
    if autoDungeonThread then
        autoDungeonThread = nil
    end
end

MainGroup:AddToggle("AutoDungeonToggle", {
    Text = "Auto Farm Dungeon",
    Default = autoDungeonEnabled,
    Tooltip = "Automatically farms any detected dungeon enemy.",
    Callback = function(value)
        autoDungeonEnabled = value
        config.AutoDungeonEnabled = value
        saveConfig()
        if value then
            startAutoDungeon()
        else
            stopAutoDungeon()
        end
    end
})

MainGroup:AddToggle("AutoDesertToggle", {
    Text = "Auto Farm Desert",
    Default = autoDesertEnabled,
    Tooltip = "Automatically teleports to desert enemies.",
    Callback = function(value)
        autoDesertEnabled = value
        config.AutoDesertEnabled = value
        saveConfig()
        if value then
            startAutoDesert()
        else
            stopAutoDesert()
        end
    end
})


-- Key Crafting UI
-- Friendly key display names mapped to internal key names
local keyDisplayMap = {
    ["Leveling City"] = "SoloKey",
    ["Slime Island"] = "SlimeKey",
    ["Brum Island"] = "OpKey",
    ["Kingdom Dungeon"] = "AotKey",
    ["Lucky Kingdom"] = "BCKey",
    ["Mori Island"] = "JojoKey",
    ["OpmKey for ???"] = "OpmKey",
    ["Solo2Key for ???"] = "Solo2Key",
    ["DSKey for ???"] = "DSKey",
}
local keyDisplayNames = {}
for display, _ in pairs(keyDisplayMap) do table.insert(keyDisplayNames, display) end
table.sort(keyDisplayNames)
local selectedKeyDisplay = keyDisplayNames[1]
Keys:AddDropdown("KeyCraftDropdown", {
    Text = "Select Key to Craft",
    Values = keyDisplayNames,
    Default = keyDisplayNames[1],
    Tooltip = "Choose which key to craft.",
    Callback = function(value)
        selectedKeyDisplay = value
    end
})

Keys:AddButton("Craft Selected Key", function()
    local internalKeyName = keyDisplayMap[selectedKeyDisplay] or selectedKeyDisplay
    local args = {
        [1] = {
            [1] = {
                ["Event"] = "CraftItem",
                ["Name"] = internalKeyName,
            },
            [2] = "\12",
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2", 9e9):WaitForChild("dataRemoteEvent", 9e9):FireServer(unpack(args))
end, {
    Tooltip = "Craft the selected key using the dropdown above."
})

-- Auto Start Key Dungeon Toggle Logic
local autoStartKeyDungeonEnabled = false
local autoStartKeyDungeonThread = nil
local keyDungeonPrompt = nil

local function findKeyDungeonPrompt()
    local main = workspace:FindFirstChild("__Main")
    if main then
        local world = main:FindFirstChild("__World")
        if world then
            local spawn = world:FindFirstChild("Spawn")
            if spawn then
                local keyStart = spawn:FindFirstChild("KeyStart")
                if keyStart then
                    local podium = keyStart:FindFirstChild("Podium")
                    if podium then
                        local mids = podium:FindFirstChild("Mids")
                        if mids then
                            local promptObj = mids:FindFirstChild("ProximityPrompt")
                            if promptObj and promptObj:IsA("ProximityPrompt") then
                                return promptObj
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function startAutoStartKeyDungeon()
    if autoStartKeyDungeonThread then return end
    autoStartKeyDungeonEnabled = true
    autoStartKeyDungeonThread = task.spawn(function()
        while autoStartKeyDungeonEnabled do
            if not keyDungeonPrompt or not keyDungeonPrompt.Parent then
                keyDungeonPrompt = findKeyDungeonPrompt()
            end
            if keyDungeonPrompt then
                keyDungeonPrompt.MaxActivationDistance = infiniteRange
                -- Hold to activate: fire HoldBegin, wait, then fire HoldEnd
                keyDungeonPrompt:InputHoldBegin()
                task.wait(0.2)
                keyDungeonPrompt:InputHoldEnd()
            end
            task.wait(0.2)
        end
    end)
end

local function stopAutoStartKeyDungeon()
    autoStartKeyDungeonEnabled = false
    if autoStartKeyDungeonThread then
        autoStartKeyDungeonThread = nil
    end
    if keyDungeonPrompt then
        keyDungeonPrompt.MaxActivationDistance = normalRange
    end
end

ShopsGroup:AddToggle("AutoStartKeyDungeonToggle", {
    Text = "Auto Start Key Dungeon",
    Default = false,
    Tooltip = "Makes the Key Dungeon ProximityPrompt infinite and holds it to activate repeatedly.",
    Callback = function(value)
        autoStartKeyDungeonEnabled = value
        if value then
            startAutoStartKeyDungeon()
        else
            stopAutoStartKeyDungeon()
        end
    end
})

-- Toggle for auto Key Dungeon ProximityPrompt
local autoKeyPromptEnabled = false
local autoKeyPromptThread = nil

local function startAutoKeyPrompt()
    if autoKeyPromptThread then return end
    autoKeyPromptEnabled = true
    autoKeyPromptThread = task.spawn(function()
        while autoKeyPromptEnabled do
            local prompt = workspace:FindFirstChild("__Main")
            if prompt then
                prompt = prompt:FindFirstChild("__World")
                if prompt then
                    prompt = prompt:FindFirstChild("Spawn")
                    if prompt then
                        prompt = prompt:FindFirstChild("KeyStart")
                        if prompt then
                            prompt = prompt:FindFirstChild("Podium")
                            if prompt then
                                prompt = prompt:FindFirstChild("Mids")
                                if prompt then
                                    prompt = prompt:FindFirstChild("ProximityPrompt")
                                    if prompt then
                                        prompt.MaxActivationDistance = math.huge
                                        fireproximityprompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

local function stopAutoKeyPrompt()
    autoKeyPromptEnabled = false
    if autoKeyPromptThread then
        autoKeyPromptThread = nil
    end
end

MainGroup:AddToggle("AutoKeyDungeonPromptToggle", {
    Text = "Auto Key Dungeon",
    Default = false,
    Tooltip = "Automatically triggers the Key Dungeon ProximityPrompt every second with infinite range.",
    Callback = function(value)
        autoKeyPromptEnabled = value
        if value then
            startAutoKeyPrompt()
        else
            stopAutoKeyPrompt()
        end
    end
})
-- =====================
-- Logic/Functions
-- =====================

local function getModelTitle(enemyModel)
    if enemyModel:FindFirstChild("HealthBar") and enemyModel.HealthBar:FindFirstChild("Main") and enemyModel.HealthBar.Main:FindFirstChild("Title") then
        local titleObj = enemyModel.HealthBar.Main.Title
        if titleObj:IsA("TextLabel") and typeof(titleObj.Text) == "string" then
            return titleObj.Text
        end
    end
    return enemyModel.Name
end

local function getModelHealth(enemyModel)
    if enemyModel:FindFirstChild("HealthBar") and enemyModel.HealthBar:FindFirstChild("Main") and enemyModel.HealthBar.Main:FindFirstChild("Title") then
        local healthBar = enemyModel.HealthBar.Main:FindFirstChild("Health")
        if healthBar and healthBar:IsA("TextLabel") and tonumber(healthBar.Text) then
            return tonumber(healthBar.Text)
        end
    end
    return nil
end

local function parseAmountText(text)
    -- Remove non-numeric characters and handle K/M/B suffixes
    if not text or text == "" then return 0 end
    text = string.gsub(text, "[^%d%.KMB]", "")
    local num = tonumber(string.match(text, "[%d%.]+")) or 0
    if string.find(text, "K") then
        num = num * 1000
    elseif string.find(text, "M") then
        num = num * 1000000
    elseif string.find(text, "B") then
        num = num * 1000000000
    end
    return num
end

local function getModelAmount(enemyModel)
    if enemyModel:FindFirstChild("HealthBar") and enemyModel.HealthBar:FindFirstChild("Main") and enemyModel.HealthBar.Main:FindFirstChild("Bar") and enemyModel.HealthBar.Main.Bar:FindFirstChild("Amount") then
        local amountObj = enemyModel.HealthBar.Main.Bar.Amount
        if amountObj:IsA("TextLabel") then
            local attr = amountObj:GetAttribute("Text")
            local rawText = attr or amountObj.Text
            return parseAmountText(rawText)
        end
    end
    return 0
end

local function getModelTitles()
    local titles = {}
    local seen = {}
    for _, enemyModel in pairs(enemiesFolder:GetChildren()) do
        local title = getModelTitle(enemyModel)
        if not seen[title] then
            table.insert(titles, title)
            seen[title] = true
        end
    end
    return titles
end

local function findModelByTitle(title)
    for _, enemyModel in pairs(enemiesFolder:GetChildren()) do
        if getModelTitle(enemyModel) == title then
            return enemyModel
        end
    end
    return nil
end

local function findClosestModelByTitle(title)
    local closestModel = nil
    local closestDist = math.huge
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local playerPos = player.Character.HumanoidRootPart.Position
        for _, enemyModel in pairs(enemiesFolder:GetChildren()) do
            if getModelTitle(enemyModel) == title and enemyModel:FindFirstChild("HumanoidRootPart") then
                local dist = (enemyModel.HumanoidRootPart.Position - playerPos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestModel = enemyModel
                end
            end
        end
    end
    return closestModel
end

local function findClosestAliveModelByTitle(title)
    local closestModel = nil
    local closestDist = math.huge
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local playerPos = player.Character.HumanoidRootPart.Position
        for _, enemyModel in pairs(enemiesFolder:GetChildren()) do
            if getModelTitle(enemyModel) == title and enemyModel:FindFirstChild("HumanoidRootPart") then
                local health = getModelHealth(enemyModel)
                if health and health > 0 then
                    local dist = (enemyModel.HumanoidRootPart.Position - playerPos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestModel = enemyModel
                    end
                end
            end
        end
    end
    return closestModel
end


if killAuraEnabled then
    startKillAura()
end

-- Auto Arise: start if enabled in config
if autoAriseEnabled then
    startAutoArise()
end

local teleportDropdown = MainGroup:AddDropdown("TeleportModelTitleDropdown", {
    Text = "Teleport to Model Title",
    Values = getModelTitles(),
    Default = selectedModelNameToTeleport ~= "" and selectedModelNameToTeleport or {},
    Multi = false,
    Tooltip = "Select one or more model titles to teleport to.",
    Callback = function(selectedValues)
        selectedModelNameToTeleport = selectedValues
        config.SelectedModelNameToTeleport = selectedValues
        saveConfig()
    end
})

-- Force dropdown to select saved value on load so auto farm works immediately
if selectedModelNameToTeleport ~= "" and teleportDropdown and teleportDropdown.SetValue then
    teleportDropdown:SetValue(selectedModelNameToTeleport)
end


-- =====================
-- Auto start auto stats if enabled in config
if autoStatsEnabled then startAutoStats() end
if autoDungeonEnabled then startAutoDungeon() end
if autoTargetEnabled then startAutoTarget() end
if autoTeleportToModelEnabled then
    spawn(function()
        local lastModelId = nil
        while autoTeleportToModelEnabled do
            if selectedModelNameToTeleport ~= "" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetModels = {}
                for _, enemyModel in pairs(enemiesFolder:GetChildren()) do
                    if getModelTitle(enemyModel) == selectedModelNameToTeleport and enemyModel:FindFirstChild("HumanoidRootPart") and (getModelHealth(enemyModel) or 0) > 0 then
                        table.insert(targetModels, enemyModel)
                    end
                end
                -- Only focus on one enemy at a time
                local lockedModel = nil
                if #targetModels > 0 then
                    lockedModel = targetModels[1] -- Pick the first found (could sort by distance if needed)
                end
                if lockedModel then
                    local modelId = lockedModel:GetDebugId()
                    if modelId ~= lastModelId then
                        tweenToEnemy(lockedModel)
                        lastModelId = modelId
                    end
                    -- Stay at this enemy until its HP is 0
                    while autoTeleportToModelEnabled and lockedModel and lockedModel:FindFirstChild("HumanoidRootPart") and (getModelHealth(lockedModel) or 0) > 0 do
                        wait(0.2)
                    end
                else
                    lastModelId = nil
                end
            else
                lastModelId = nil
            end
            wait(0.2)
        end
    end)
end


-- Periodically update the dropdown values to include new monsters
spawn(function()
    while true do
        local titles = getModelTitles()
        if teleportDropdown and teleportDropdown.SetValues then
            teleportDropdown:SetValues(titles)
        end
        wait(2)
    end
end)

spawn(function()
    local lastModelId = nil
    while true do
        if autoTeleportToModelEnabled and selectedModelNameToTeleport ~= "" then
            local model = nil
            for _, enemyModel in pairs(enemiesFolder:GetChildren()) do
                if getModelTitle(enemyModel) == selectedModelNameToTeleport and enemyModel:FindFirstChild("HumanoidRootPart") and (getModelHealth(enemyModel) or 1) > 0 then
                    model = enemyModel
                    break
                end
            end
            local modelId = model and model:GetDebugId() or nil
            if model and modelId ~= lastModelId then
                tweenToEnemy(model)
                lastModelId = modelId
            elseif not model then
                lastModelId = nil
            end
        else
            lastModelId = nil
        end
        wait(0.5)
    end
end)


spawn(function()
    while true do
        if autoTeleportToModelEnabled and selectedModelNameToTeleport ~= "" then
            -- Always find the closest alive monster with the selected title
            local closestModel = nil
            local closestDist = math.huge
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerPos = player.Character.HumanoidRootPart.Position
                for _, enemyModel in pairs(enemiesFolder:GetChildren()) do
                    if getModelTitle(enemyModel) == selectedModelNameToTeleport and enemyModel:FindFirstChild("HumanoidRootPart") and getModelAmount(enemyModel) > 0 then
                        local dist = (enemyModel.HumanoidRootPart.Position - playerPos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestModel = enemyModel
                        end
                    end
                end
            end
            if closestModel then
                tweenToEnemy(closestModel)
            end
        end
        wait(0.5)
    end
end)


local petPositions = {}

local function cachePets()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find(LocalPlayer.Name) then
            petPositions[obj.Name] = obj:GetPivot().Position
        end
    end
end

local function refreshPetPositions()
    for key, _ in pairs(petPositions) do
        local petModel = workspace:FindFirstChild(key, true)
        if petModel then
            petPositions[key] = petModel:GetPivot().Position
        end
    end
end

local function getClosestEnemyKey()
    local character = LocalPlayer.Character
    if not character or not character.PrimaryPart then return nil end

    local closest, minDist = nil, math.huge
    local enemyFolder = workspace:FindFirstChild("__Main", true)
    if enemyFolder and enemyFolder:FindFirstChild("__Enemies") then
        local clientFolder = enemyFolder.__Enemies:FindFirstChild("Client")
        if clientFolder then
            for _, obj in ipairs(clientFolder:GetChildren()) do
                if obj:IsA("Model") and obj.PrimaryPart then
                    local dist = (character.PrimaryPart.Position - obj.PrimaryPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = obj.Name
                    end
                end
            end
        end
    end
    return closest
end

cachePets()
local firstPetKey = next(petPositions)
if firstPetKey then
    dataRemoteEvent:FireServer({
        {
            Event = "Closest",
            Pet = firstPetKey
        },
        "\5"
    })
end

spawn(function()
    while true do
        if autoTargetEnabled then
            refreshPetPositions()
            local enemyKey = getClosestEnemyKey()
            if enemyKey and next(petPositions) then
                dataRemoteEvent:FireServer({
                    {
                        PetPos = petPositions,
                        AttackType = "All",
                        Event = "Attack",
                        Enemy = enemyKey
                    },
                    "\5"
                })
            end
        end
        task.wait(0.2)
    end
end)

-- Auto Roll Shikai Logic]
local autoRollShikaiEnabled = false
local autoRollShikaiThread = nil

local function startAutoRollShikai()
    if autoRollShikaiThread then return end
    autoRollShikaiEnabled = true
    autoRollShikaiThread = task.spawn(function()
        while autoRollShikaiEnabled do
            local args = {
                [1] = {
                    [1] = {
                        ["GachaName"] = "BleachShikais";
                        ["Event"] = "Gacha";
                        ["Action"] = "Roll";
                    };
                    [2] = "\r";
                };
            }
            game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2", 9e9):WaitForChild("dataRemoteEvent", 9e9):FireServer(unpack(args))
            task.wait(1) -- Adjust delay as needed
        end
    end)
end

local function stopAutoRollShikai()
    autoRollShikaiEnabled = false
    if autoRollShikaiThread then
        autoRollShikaiThread = nil
    end
end

RollShikais:AddToggle("AutoRollShikaiToggle", {
    Text = "Auto Roll Shikai",
    Default = false,
    Tooltip = "Automatically rolls Bleach Shikai Gacha.",
    Callback = function(value)
    autoRollShikaiEnabled = value
    config.AutoRollShikaiEnabled = value
    if type(saveConfig) == "function" then saveConfig() end
        if value then
            startAutoRollShikai()
        else
            stopAutoRollShikai()
        end
    end
})


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

-- Auto start/auto load for FPSBoostToggle
if config.FPSBoostToggle then
    fpsBoostEnabled = true
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


UISettingsGroup:AddButton("Unload Script", function()
    -- Stop all running logic and reset variables
    getgenv().SeisenHubRunning = false
    autoTargetEnabled = false
    autoTeleportToModelEnabled = false
    customCursorEnabled = false
    autoAriseEnabled = false
    autoDestroyEnabled = false
    autoSpinEnabled = false
    autoDailyQuestEnabled = false
    autoWeeklyQuestEnabled = false
    autoMainQuestEnabled = false
    autoDungeonEnabled = false
    autoStatsEnabled = false

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

    -- Threads will exit naturally since flags are set to false
    if WatermarkConnection then
        WatermarkConnection:Disconnect()
        WatermarkConnection = nil
    end
    if inputChangedConnection then
        inputChangedConnection:Disconnect()
        inputChangedConnection = nil
    end
    if inputEndedConnection then
        inputEndedConnection:Disconnect()
        inputEndedConnection = nil
    end
    if WatermarkGui then
        WatermarkGui:Destroy()
        WatermarkGui = nil
    end
    getgenv().SeisenHubUI = nil
    getgenv().SeisenHubLoaded = nil
    getgenv().SeisenHubConfig = nil
    if getgenv().SeisenHubConnections then
        for _, conn in ipairs(getgenv().SeisenHubConnections) do
            pcall(function() conn:Disconnect() end)
        end
        getgenv().SeisenHubConnections = nil
    end
    if Library and Library.Unload then
        pcall(function()
            Library:Unload()
        end) 
    elseif getgenv().SeisenHubUI and getgenv().SeisenHubUI.Parent then
        pcall(function()
            getgenv().SeisenHubUI:Destroy()
        end)
    end
    for _, v in pairs(getgenv()) do
        if typeof(v) == "RBXScriptConnection" then
            pcall(function() v:Disconnect() end)
        elseif typeof(v) == "thread" then
            pcall(function() coroutine.close(v) end)
        end
    end
        stopKillAura()
end)