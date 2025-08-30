-- Cleanup on reload
if getgenv().SeisenHubLoaded then
    if getgenv().SeisenHubUI and getgenv().SeisenHubUI.Parent then
        pcall(function()
            getgenv().SeisenHubUI:Destroy()
        end)
    end
    getgenv().SeisenHubRunning = false
    task.wait(0.25)
end

getgenv().SeisenHubLoaded = true
getgenv().SeisenHubRunning = true

-- Load Obsidian UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local Window = Library:CreateWindow({
    Title = "Seisen Hub",
    Footer = "Anime Eternal",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Center = true,
    AutoShow = true,
})

-- Store ScreenGui for cleanup
getgenv().SeisenHubUI = Library.Gui

-- Tabs & Groups

local MainTab = Window:AddTab("Main", "atom")
local LeftGroupbox = MainTab:AddLeftGroupbox("Automation")
local StatsGroupbox = MainTab:AddLeftGroupbox("Auto Stats")
local RewardsGroupbox = MainTab:AddRightGroupbox("Auto Rewards")
local PotionGroupbox = MainTab:AddRightGroupbox("Auto Potions")

local TeleportTab = Window:AddTab("Teleport & Dungeon", "map")
local TPGroupbox = TeleportTab:AddLeftGroupbox("Main Teleport")
local DungeonGroupbox = TeleportTab:AddRightGroupbox("Auto Dungeon")

local Roll = Window:AddTab("Rolls", "dice-5")
local RollGroupbox = Roll:AddLeftGroupbox("Auto Rolls")
local RollGroupbox2 = Roll:AddLeftGroupbox("Auto Roll Tokens")
local AutoDeleteGroupbox = Roll:AddRightGroupbox("Auto Delete Stars")
local AutoDeleteGroupbox2 = Roll:AddRightGroupbox("Auto Delete Sword")

local UP = Window:AddTab("Upgrades", "arrow-up")
local UpgradeGroupbox = UP:AddLeftGroupbox("Upgrades")
local Upgrade2 = UP:AddRightGroupbox("Upgrades 2")

local UISettings = Window:AddTab("UI Settings", "settings")
local UnloadGroupbox = UISettings:AddLeftGroupbox("Utilities")
local RedeemGroupbox = UISettings:AddRightGroupbox("Redeem Codes")
local UISettingsGroup = UISettings:AddLeftGroupbox("UI Customization")
local InfoGroup = UISettings:AddRightGroupbox("Script Information")

-- Script Information Section
InfoGroup:AddLabel("Script by: Seisen")
InfoGroup:AddLabel("Version: 4.5.0")
InfoGroup:AddLabel("Game: Anime Eternal")

InfoGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/F4sAf6z8Ph")
    -- Removed debug print
end)

-- Mobile detection and UI adjustments
if Library.IsMobile then
    InfoGroup:AddLabel("📱 Mobile Device Detected")
    InfoGroup:AddLabel("UI optimized for mobile")
else
    InfoGroup:AddLabel("🖥️ Desktop Device Detected")
end

-- UI Scale dropdown for mobile compatibility
UISettingsGroup:AddDropdown("UIScale", {
    Text = "UI Scale",
    Values = {"75%", "100%", "125%", "150%"},
    Default = 2, -- 100%
    Tooltip = "Adjust UI size for better mobile experience",
    Callback = function(value)
        local scaleMap = {
            ["75%"] = 75,
            ["100%"] = 100,
            ["125%"] = 125,
            ["150%"] = 150
        }
        
        -- Disable the library's watermark before scaling
        Library:SetWatermarkVisibility(false)
        
        -- Apply DPI scale to UI only
        Library:SetDPIScale(scaleMap[value])
        
        -- Don't re-enable the library watermark - we'll use our custom one
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
    "rbxassetid://121631680891470",
    "http://www.roblox.com/asset/?id=121631680891470",
    "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Fallback image
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


-- Services & Variables

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
local monstersFolder = Workspace:WaitForChild("Debris", 9e9):WaitForChild("Monsters", 9e9)

local localPlayer = Players.LocalPlayer
local teleportOffset = Vector3.new(0, 0, -3)

-- Initialize variables with explicit defaults

local config = getgenv().SeisenHubConfig or {}
local currentTarget = nil


local RunService = game:GetService("RunService")

local configFolder = "SeisenHub"
local configFile = configFolder .. "/seisen_hub_AE.txt"
local HttpService = game:GetService("HttpService")

-- Ensure folder exists
if not isfolder(configFolder) then
    makefolder(configFolder)
end

local config = getgenv().SeisenHubConfig or {}
if config.MonsterSelector and monsterDropdown and typeof(monsterDropdown.SetValue) == "function" then
    monsterDropdown:SetValue(config.MonsterSelector)
end
-- Load config if file exists
-- Auto load config on script start
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

task.defer(function()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
            local hrp = obj.HumanoidRootPart
            local billboard = hrp:FindFirstChild("BillboardGui")
            if billboard and billboard:FindFirstChild("Player_Name") then
                billboard.Player_Name.Visible = false
            end
        end
    end
    if config.AutoHideUIEnabled and Library and Library.Toggle then
        Library:Toggle()
        Library.ShowCustomCursor = false
    end
end)

-- Load config values with defaults
local isAuraEnabled = config.AutoFarmToggle or false
local fastKillAuraEnabled = config.FastKillAuraToggle or false
local autoRankEnabled = config.AutoRankToggle or false
local autoAvatarLevelingEnabled = config.AutoAvatarLevelingToggle or false
local autoAcceptAllQuestsEnabled = config.AutoAcceptAllQuestsToggle or false
local autoRollDragonRaceEnabled = config.AutoRollDragonRaceToggle or false
local autoRollSaiyanEvolutionEnabled = config.AutoRollSaiyanEvolutionToggle or false
local autoRollEnabled = config.AutoRollStarsToggle or false
local autoDeleteEnabled = config.AutoDeleteUnitsToggle or false
local autoClaimAchievementsEnabled = config.AutoClaimAchievement or false
local autoRollSwordsEnabled = config.AutoRollSwordsToggle or false
local autoRollPirateCrewEnabled = config.AutoRollPirateCrewToggle or false
local selectedStar = config.SelectStarDropdown or "Star_1"
local selectedDeleteStar = config.SelectDeleteStarDropdown or "Star_1"
local delayBetweenRolls = config.DelayBetweenRollsSlider or 0.5
local selectedRarities = config.AutoDeleteRaritiesDropdown or {}
local autoStatsRunning = config.AutoAssignStatToggle or false
local isAutoTimeRewardEnabled = config.AutoClaimTimeRewardToggle or false
local isAutoDailyChestEnabled = config.AutoClaimDailyChestToggle or false
local isAutoVipChestEnabled = config.AutoClaimVipChestToggle or false
local isAutoGroupChestEnabled = config.AutoClaimGroupChestToggle or false
local isAutoPremiumChestEnabled = config.AutoClaimPremiumChestToggle or false
local disableNotificationsEnabled = config.DisableNotificationsToggle or false
local autoUpgradeEnabled = config.AutoUpgradeToggle or false
local autoEnterDungeon = config.AutoEnterDungeonToggle or false
local selectedStat = config.AutoStatSingleDropdown or "Damage"
local autoHakiUpgradeEnabled = config.AutoHakiUpgradeToggle or false
local autoRollDemonFruitsEnabled = config.AutoRollDemonFruitsToggle or false
local autoAttackRangeUpgradeEnabled = config.AutoAttackRangeUpgradeToggle or false
local pointsPerSecond = config.PointsPerSecondSlider or 1
local autoSpiritualPressureUpgradeEnabled = config.AutoSpiritualPressureUpgradeToggle or false
local autoRollReiatsuColorEnabled = config.AutoRollReiatsuColorToggle or false
local mutePetSoundsEnabled = config.MutePetSoundsToggle or false
local selectedRaritiesDisplay = config.AutoDeleteRaritiesDropdown or {}
local selectedDungeons = config.SelectedDungeons or {"Dungeon_Easy"}
local autoRollZanpakutoEnabled = config.AutoRollZanpakutoToggle or false
local autoCursedProgressionUpgradeEnabled = config.AutoCursedProgressionUpgradeToggle or false
local autoRollCursesEnabled = config.AutoRollCursesToggle or false
local autoObeliskEnabled = config.AutoObeliskToggle or false
local selectedObeliskType = config.SelectedObeliskType or "Slayer_Obelisk"
local fpsBoostEnabled = config.FPSBoostToggle or false
local autoRollDemonArtsEnabled = config.AutoRollDemonArtsToggle or false
local selectedGachaRarities = config.AutoDeleteGachaRaritiesDropdown or {}
local autoChakraProgressionUpgradeEnabled = config.AutoChakraProgressionUpgradeToggle or false
local autoSoloHunterRankEnabled = config.AutoSoloHunterRankToggle or false
local autoReawakeningProgressionUpgradeEnabled = config.AutoReawakeningProgressionUpgradeToggle or false
local autoMonarchProgressionUpgradeEnabled = config.AutoMonarchProgressionUpgradeToggle or false
local autoPrestigeEnabled = config.AutoPrestigeToggle or false
local autoPsychicMayhemEnabled = config.AutoPsychicMayhemToggle or false
local autoDungeonEnabled = config.AutoDungeonToggle or false
local selectedMonsters = config.MonsterSelector or {}
local attackCooldown = config.AttackCooldownSlider or 0.15
local autoRollPowerEyesEnabled = config.AutoRollPowerEyesToggle or false
local autoSpiritualUpgradeEnabled = config.AutoSpiritualUpgradeToggle or false
local autoReiatsuColorEnabled = config.AutoReiatsuColorToggle or false
local autoHideUIEnabled = config.AutoHideUIEnabled or false

-- Load config values with defaults
isAuraEnabled = config.AutoFarmToggle or false
autoRankEnabled = config.AutoRankToggle or false
autoAvatarLevelingEnabled = config.AutoAvatarLevelingToggle or false
autoAcceptAllQuestsEnabled = config.AutoAcceptAllQuestsToggle or false
autoRollDragonRaceEnabled = config.AutoRollDragonRaceToggle or false
autoRollSaiyanEvolutionEnabled = config.AutoRollSaiyanEvolutionToggle or false
autoRollEnabled = config.AutoRollStarsToggle or false
autoDeleteEnabled = config.AutoDeleteUnitsToggle or false
autoClaimAchievementsEnabled = config.AutoClaimAchievement or false
autoRollSwordsEnabled = config.AutoRollSwordsToggle or false
autoRollPirateCrewEnabled = config.AutoRollPirateCrewToggle or false
selectedStar = config.SelectStarDropdown or "Star_1"
selectedDeleteStar = config.SelectDeleteStarDropdown or "Star_1"
delayBetweenRolls = config.DelayBetweenRollsSlider or 0.5
selectedRarities = config.AutoDeleteRaritiesDropdown or {}
autoStatsRunning = config.AutoAssignStatToggle or false
isAutoTimeRewardEnabled = config.AutoClaimTimeRewardToggle or false
isAutoDailyChestEnabled = config.AutoClaimDailyChestToggle or false
isAutoVipChestEnabled = config.AutoClaimVipChestToggle or false
isAutoGroupChestEnabled = config.AutoClaimGroupChestToggle or false
isAutoPremiumChestEnabled = config.AutoClaimPremiumChestToggle or false
disableNotificationsEnabled = config.DisableNotificationsToggle or false
autoUpgradeEnabled = config.AutoUpgradeToggle or false
autoEnterDungeon = config.AutoEnterDungeonToggle or false
selectedStat = config.AutoStatSingleDropdown or "Damage"
autoHakiUpgradeEnabled = config.AutoHakiUpgradeToggle or false
autoRollDemonFruitsEnabled = config.AutoRollDemonFruitsToggle or false
autoAttackRangeUpgradeEnabled = config.AutoAttackRangeUpgradeToggle or false
pointsPerSecond = config.PointsPerSecondSlider or 1
autoSpiritualPressureUpgradeEnabled = config.AutoSpiritualPressureUpgradeToggle or false
autoRollReiatsuColorEnabled = config.AutoRollReiatsuColorToggle or false
mutePetSoundsEnabled = config.MutePetSoundsToggle or false
selectedRaritiesDisplay = config.AutoDeleteRaritiesDropdown or {}
selectedDungeons = config.SelectedDungeons or {"Dungeon_Easy"}
autoRollZanpakutoEnabled = config.AutoRollZanpakutoToggle or false
autoCursedProgressionUpgradeEnabled = config.AutoCursedProgressionUpgradeToggle or false
autoRollCursesEnabled = config.AutoRollCursesToggle or false
autoObeliskEnabled = config.AutoObeliskToggle or false
selectedObeliskType = config.SelectedObeliskType or "Slayer_Obelisk"
fpsBoostEnabled = config.FPSBoostToggle or false
autoRollDemonArtsEnabled = config.AutoRollDemonArtsToggle or false
autoRedeemCodesEnabled = config.AutoRedeemCodesToggle or false
selectedGachaRarities = config.AutoDeleteGachaRaritiesDropdown or {}
autoChakraProgressionUpgradeEnabled = config.AutoChakraProgressionUpgradeToggle or false
autoDungeonEnabled = config.AutoDungeonToggle or false
selectedMonsters = config.MonsterSelector or {}
attackCooldown = config.AttackCooldownSlider or 0.15
autoRollPowerEyesEnabled = config.AutoRollPowerEyesToggle or false
autoSpiritualUpgradeEnabled = config.AutoSpiritualUpgradeToggle or false
autoReiatsuColorEnabled = config.AutoReiatsuColorToggle or false
autoPrestigeEnabled = config.AutoPrestigeToggle or false
autoPsychicMayhemEnabled = config.AutoPsychicMayhemToggle or false
autoHideUIEnabled = config.AutoHideUIEnabled or false
local originalVolumes = {}

-- Top config variables for new features
local autoSoloHunterRankEnabled = config.AutoSoloHunterRankToggle or false
local autoReawakeningProgressionUpgradeEnabled = config.AutoReawakeningProgressionUpgradeToggle or false
local autoMonarchProgressionUpgradeEnabled = config.AutoMonarchProgressionUpgradeToggle or false


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


local function saveConfig()
    config.SelectedDungeons = selectedDungeons
    config.AutoAssignStatToggle = autoStatsRunning
    config.AutoStatSingleDropdown = selectedStat
    config.PointsPerSecondSlider = pointsPerSecond
    config.AutoAvatarLevelingToggle = autoAvatarLevelingEnabled
    config.MutePetSoundsToggle = mutePetSoundsEnabled
    config.AutoSpiritualPressureUpgradeToggle = autoSpiritualPressureUpgradeEnabled
    config.AutoRollReiatsuColorToggle = autoRollReiatsuColorEnabled
    config.FPSBoostToggle = fpsBoostEnabled
    config.AutoRollDemonArtsToggle = autoRollDemonArtsEnabled
    config.AttackCooldownSlider = attackCooldown
    config.AutoDungeonToggle = config.AutoDungeonToggle or false
    config.DungeonTeleportRange = config.DungeonTeleportRange or 50
    getgenv().SeisenHubConfig = config
    writefile(configFile, HttpService:JSONEncode(config))
end

-- ========== Automations =========
-- Monitor dungeon state and disable Auto Farm/Farm All if both notification and header are visible
-- Removed UI monitor thread; logic now handled inside startAutoFarm and startFarmAll only
-- Auto Farm thread management
local killAuraOnlyEnabled = config.KillAuraOnlyToggle or false
local farmAllEnabled = config.FarmAllToggle or false
local autoFarmThread = nil
local autoFarmThreadStop = false

-- Helper functions for monster dropdown
-- Stop functions should reset enabled flags
local function stopAutoFarm()
    autoFarmThreadStop = true
    isAuraEnabled = false
end

getgenv().StopFarmAllThread = function()
    farmAllEnabled = false
end

-- Persistent watcher for Auto Farm and Farm All
task.spawn(function()
    while getgenv().SeisenHubRunning do
        local player = game:GetService("Players").LocalPlayer
        local gui = player and player:FindFirstChild("PlayerGui")
        local dungeonGui = gui and gui:FindFirstChild("Dungeon")
        local notification = dungeonGui and dungeonGui:FindFirstChild("Dungeon_Notification")
        local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
        local uiVisible = (notification and notification.Visible) or (header and header.Visible)

        -- Stop Auto Farm if UI is visible
        if uiVisible and isAuraEnabled then
            stopAutoFarm()
            if Library.Flags and Library.Flags.AutoFarmToggle then
                Library.Flags.AutoFarmToggle:Set(false)
            end
        end
        -- Start Auto Farm if UI is not visible and toggle is on
        if not uiVisible and config.AutoFarmToggle and not isAuraEnabled then
            isAuraEnabled = true
            startAutoFarm()
            if Library.Flags and Library.Flags.AutoFarmToggle then
                Library.Flags.AutoFarmToggle:Set(true)
            end
        end

        -- Stop Farm All if UI is visible
        if uiVisible and farmAllEnabled then
            if getgenv().StopFarmAllThread then getgenv().StopFarmAllThread() end
            if Library.Flags and Library.Flags.FarmAllToggle then
                Library.Flags.FarmAllToggle:Set(false)
            end
        end
        -- Start Farm All if UI is not visible and toggle is on
        if not uiVisible and config.FarmAllToggle and not farmAllEnabled then
            farmAllEnabled = true
            task.spawn(startFarmAll)
            if Library.Flags and Library.Flags.FarmAllToggle then
                Library.Flags.FarmAllToggle:Set(true)
            end
        end

        task.wait(0.2)
    end
end)
-- Persistent watcher for Auto Farm and Farm All
task.spawn(function()
    while getgenv().SeisenHubRunning do
        local player = game:GetService("Players").LocalPlayer
        local gui = player and player:FindFirstChild("PlayerGui")
        local dungeonGui = gui and gui:FindFirstChild("Dungeon")
        local notification = dungeonGui and dungeonGui:FindFirstChild("Dungeon_Notification")
        local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
        local uiVisible = (notification and notification.Visible) or (header and header.Visible)

        -- Stop Auto Farm if UI is visible
        if uiVisible and isAuraEnabled then
            isAuraEnabled = false
            stopAutoFarm()
            if Library.Flags and Library.Flags.AutoFarmToggle then
                Library.Flags.AutoFarmToggle:Set(false)
            end
        end
        -- Start Auto Farm if UI is not visible and toggle is on
        if not uiVisible and config.AutoFarmToggle and not isAuraEnabled then
            isAuraEnabled = true
            startAutoFarm()
            if Library.Flags and Library.Flags.AutoFarmToggle then
                Library.Flags.AutoFarmToggle:Set(true)
            end
        end

        -- Stop Farm All if UI is visible
        if uiVisible and farmAllEnabled then
            farmAllEnabled = false
            if getgenv().StopFarmAllThread then getgenv().StopFarmAllThread() end
            if Library.Flags and Library.Flags.FarmAllToggle then
                Library.Flags.FarmAllToggle:Set(false)
            end
        end
        -- Start Farm All if UI is not visible and toggle is on
        if not uiVisible and config.FarmAllToggle and not farmAllEnabled then
            farmAllEnabled = true
            task.spawn(startFarmAll)
            if Library.Flags and Library.Flags.FarmAllToggle then
                Library.Flags.FarmAllToggle:Set(true)
            end
        end

        task.wait(0.2)
    end
end)
local monsterDropdownValues = {}
local function getAllMonsterTitles()
    local titles = {}
    local seen = {}
    for _, monster in pairs(monstersFolder:GetChildren()) do
        local title = monster:GetAttribute("Title")
        if type(title) == "string" and not seen[title] then
            -- Removed debug print
            table.insert(titles, title)
            seen[title] = true
        end
    end
    return titles
end

local function refreshMonsterDropdown()
    if monsterDropdown then
        monsterDropdown:SetValues(getAllMonsterTitles())
    end
end



monstersFolder.ChildAdded:Connect(refreshMonsterDropdown)
monstersFolder.ChildRemoved:Connect(refreshMonsterDropdown)

local function disableAllAurasExcept(except)
    if except ~= "AutoFarm" then isAuraEnabled = false end
end


local function getNearestValidMonster()
    -- Removed debug print
    local allTitles = {}
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local closest, closestDist = nil, math.huge
    local myPos = character.HumanoidRootPart.Position

    for _, monster in pairs(monstersFolder:GetChildren()) do
        if monster:IsA("Model") then
            local hrp = monster:FindFirstChild("HumanoidRootPart")
            local hum = monster:FindFirstChild("Humanoid")
            local title = monster:GetAttribute("Title")
            if type(title) == "string" then
                table.insert(allTitles, title)
            end
            if hrp and hum and hum.Health > 0 and type(title) == "string" and type(monsterDropdownValues) == "table" and #monsterDropdownValues > 0 and table.find(monsterDropdownValues, title) then
                -- Removed debug print
                local dist = (hrp.Position - myPos).Magnitude
                if dist < closestDist then
                    closest = monster
                    closestDist = dist
                end
            end
        end
    end
    -- Removed debug print

    return closest
end

-- Teleport to monster
local function teleportToMonster(monster)
    local character = localPlayer.Character
    local myHRP = character and character:FindFirstChild("HumanoidRootPart")
    local targetHRP = monster and monster:FindFirstChild("HumanoidRootPart")
    if myHRP and targetHRP then
        pcall(function()
            myHRP.CFrame = CFrame.new(targetHRP.Position + teleportOffset)
        end)
    end
end

-- Task functions
function startKillAuraOnly()
    local player = game:GetService("Players").LocalPlayer
    while killAuraOnlyEnabled and getgenv().SeisenHubRunning do
        local monstersFolder = nil
        if workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Monsters") then
            monstersFolder = workspace.Debris.Monsters
        elseif workspace:FindFirstChild("Monsters") then
            monstersFolder = workspace.Monsters
        end
        if not monstersFolder then
            task.wait(1)
        else
            -- The rest of the loop logic goes here
        end
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
                pcall(function()
                    ToServer:FireServer(unpack(args))
                end)
            end
        end
        task.wait(0.05)
    end
end
function startFarmAll()
    local player = game:GetService("Players").LocalPlayer
    while getgenv().SeisenHubRunning do
        local player = game:GetService("Players").LocalPlayer
        local gui = player:FindFirstChild("PlayerGui")
        local dungeonGui = gui and gui:FindFirstChild("Dungeon")
        local notification = dungeonGui and dungeonGui:FindFirstChild("Dungeon_Notification")
        local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
        if (notification and notification.Visible) or (header and header.Visible) then
            farmAllEnabled = false
            config.FarmAllToggle = false
            if getgenv().StopFarmAllThread then getgenv().StopFarmAllThread() end
            break
        elseif config.FarmAllToggle and not farmAllEnabled and (not notification.Visible and not header.Visible) then
            farmAllEnabled = true
        end
        local monstersFolder = nil
        if workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Monsters") then
            monstersFolder = workspace.Debris.Monsters
        elseif workspace:FindFirstChild("Monsters") then
            monstersFolder = workspace.Monsters
        end
        if not monstersFolder then
            task.wait(1)
        else
            -- The rest of the loop logic goes here
        end
        local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local aliveMonsters = {}
        for _, monster in pairs(monstersFolder:GetChildren()) do
            if monster:IsA("Model") then
                local hrp = monster:FindFirstChild("HumanoidRootPart")
                local hum = monster:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    table.insert(aliveMonsters, monster)
                end
            end
        end
        if #aliveMonsters == 0 then
            -- No monsters left, wait before retrying to prevent freeze
            task.wait(0.5)
        else
            for _, monster in ipairs(aliveMonsters) do
                if not farmAllEnabled or not getgenv().SeisenHubRunning then return end
                teleportToMonster(monster)
                local hrp = monster:FindFirstChild("HumanoidRootPart")
                local hum = monster:FindFirstChild("Humanoid")
                -- Attack until dead or gone
                while hum and hum.Health > 0 and monster.Parent == monstersFolder and farmAllEnabled and getgenv().SeisenHubRunning do
                    if myHRP and hrp and (myHRP.Position - hrp.Position).Magnitude < 20 then
                        local args = {
                            [1] = {
                                ["Id"] = monster.Name,
                                ["Action"] = "_Mouse_Click",
                                ["Critical"] = true
                            }
                        }
                        pcall(function()
                            ToServer:FireServer(unpack(args))
                        end)
                    end
                    task.wait(math.max(attackCooldown or 0.15, 0.05))
                    -- Refresh references in case monster is removed
                    hrp = monster:FindFirstChild("HumanoidRootPart")
                    hum = monster:FindFirstChild("Humanoid")
                end
                -- After enemy is dead/gone, move to next
                if not farmAllEnabled or not getgenv().SeisenHubRunning then return end
            end
        end
    end
end
local function startAutoDelete()
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
            task.wait(2)
        end
    end)
end
local function startAutoFarm()
    if not config.AutoFarmToggle then
        stopAutoFarm()
        return
    end
    if autoFarmThread == nil or coroutine.status(autoFarmThread) == "dead" then
        autoFarmThreadStop = false
        autoFarmThread = coroutine.create(function()
            local currentTarget = nil
            while getgenv().SeisenHubRunning and config.AutoFarmToggle and not autoFarmThreadStop do
                local player = game:GetService("Players").LocalPlayer
                local gui = player:FindFirstChild("PlayerGui")
                local dungeonGui = gui and gui:FindFirstChild("Dungeon")
                local notification = dungeonGui and dungeonGui:FindFirstChild("Dungeon_Notification")
                local header = dungeonGui and dungeonGui:FindFirstChild("Default_Header")
                if (notification and notification.Visible) or (header and header.Visible) then
                    isAuraEnabled = false
                    config.AutoFarmToggle = false
                    stopAutoFarm()
                    break
                elseif config.AutoFarmToggle and not isAuraEnabled and (not notification.Visible and not header.Visible) then
                    isAuraEnabled = true
                end
                local char = localPlayer.Character
                local myHRP = char and char:FindFirstChild("HumanoidRootPart")

                -- Gather all alive selected monsters
                local aliveMonsters = {}
                for _, monster in pairs(monstersFolder:GetChildren()) do
                    if monster:IsA("Model") then
                        local title = monster:GetAttribute("Title")
                        local hrp = monster:FindFirstChild("HumanoidRootPart")
                        local hum = monster:FindFirstChild("Humanoid")
                        if type(title) == "string" and hrp and hum and hum.Health > 0 and type(monsterDropdownValues) == "table" and table.find(monsterDropdownValues, title) then
                            table.insert(aliveMonsters, monster)
                        end
                    end
                end

                -- If no alive monsters, wait a bit and continue
                if #aliveMonsters == 0 then
                    currentTarget = nil
                    task.wait(0.2)
                else
                    -- The rest of the loop logic goes here
                end

                -- If no current target, or it's dead/gone, or it's no longer in the selected list, pick a new one and teleport immediately
                local validTarget = false
                if currentTarget and currentTarget:IsDescendantOf(monstersFolder) and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 then
                    local title = currentTarget:GetAttribute("Title")
                    if type(title) == "string" and type(monsterDropdownValues) == "table" and table.find(monsterDropdownValues, title) then
                        validTarget = true
                    end
                end
                if not validTarget then
                    currentTarget = aliveMonsters[1]
                    if currentTarget then
                        teleportToMonster(currentTarget)
                    end
                end

                -- If current target dies or is gone, instantly teleport to next available
                if currentTarget and (not currentTarget:IsDescendantOf(monstersFolder) or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0) then
                    local nextTarget = aliveMonsters[1]
                    if nextTarget and nextTarget ~= currentTarget then
                        currentTarget = nextTarget
                        teleportToMonster(currentTarget)
                    end
                end

                -- Attack all alive selected monsters you are close to (no global lock)
                for _, monster in ipairs(aliveMonsters) do
                    local hrp = monster:FindFirstChild("HumanoidRootPart")
                    if myHRP and hrp and (myHRP.Position - hrp.Position).Magnitude < 20 then -- 20 studs range
                        local args = {
                            [1] = {
                                ["Id"] = monster.Name,
                                ["Action"] = "_Mouse_Click",
                                ["Critical"] = true
                            }
                        }
                        pcall(function()
                            ToServer:FireServer(unpack(args))
                        end)
                    end
                end

                task.wait(math.max(attackCooldown, 0.15)) -- throttle to minimum 0.15s for faster response
            end
        end)
        coroutine.resume(autoFarmThread)
    end
end

local function stopAutoFarm()
    autoFarmThreadStop = true
end
local lastScan = 0
local scanInterval = 0.5 -- scan every 0.3 seconds

local function getNearestMonsterThrottled()
    if tick() - lastScan > scanInterval then
        lastScan = tick()
        currentTarget = getNearestValidMonster()
    end
    return currentTarget
end

local function startSlowKillAura()
    task.spawn(function()
        local argsActivator = {
            [1] = {
                ["Value"] = true,
                ["Path"] = {
                    [1] = "Settings",
                    [2] = "Is_Auto_Clicker",
                },
                ["Action"] = "Settings",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(argsActivator))
        end)
        while slowKillAuraEnabled and getgenv().SeisenHubRunning do
            local monster = getNearestValidMonster()
            if monster then
                local hum = monster:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local argsAttack = {
                        [1] = {
                            ["Id"] = monster.Name,
                            ["Action"] = "_Mouse_Click",
                        }
                    }
                    pcall(function()
                        ToServer:FireServer(unpack(argsAttack))
                    end)
                end
            end
            task.wait(0.05) -- Much faster attack speed
        end
    end)
end

local function startAutoRank()
    task.spawn(function()
        while autoRankEnabled and getgenv().SeisenHubRunning do
            local args = {
                [1] = {
                    ["Upgrading_Name"] = "Rank",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Rank_Up",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(args))
            end)
            task.wait(1)
        end
    end)
end

local function startAutoAvatarLeveling()
    task.spawn(function()
        while getgenv().SeisenHubRunning and autoAvatarLevelingEnabled do
            local args = {
                [1] = {
                    ["Value"] = true,
                    ["Path"] = {
                        [1] = "Settings",
                        [2] = "Is_Auto_Avatar_Leveling",
                    },
                    ["Action"] = "Settings",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(args))
            end)
            task.wait(1)
        end
    end)
end

local function startAutoQuests()
    task.spawn(function()
        while autoAcceptAllQuestsEnabled and getgenv().SeisenHubRunning do
            for questId = 1, 99 do
                local argsAccept = {
                    [1] = {
                        ["Id"] = tostring(questId),
                        ["Type"] = "Accept",
                        ["Action"] = "_Quest",
                    }
                }
                pcall(function()
                    ToServer:FireServer(unpack(argsAccept))
                end)
                task.wait(0.05)
                local argsComplete = {
                    [1] = {
                        ["Id"] = tostring(questId),
                        ["Type"] = "Complete",
                        ["Action"] = "_Quest",
                    }
                }
                pcall(function()
                    ToServer:FireServer(unpack(argsComplete))
                end)
                task.wait(0.05)
            end
            task.wait(2)
        end
    end)
end

local function startAutoAchievements()
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
        }

        local function toRoman(num)
            local romanNumerals = {
                [1] = "I", [2] = "II", [3] = "III", [4] = "IV",
                [5] = "V", [6] = "VI", [7] = "VII", [8] = "VIII",
                [9] = "IX", [10] = "X", [11] = "XI", [12] = "XII",
                [13] = "XIII", [14] = "XIV", [15] = "XV", [16] = "XVI",
                [17] = "XVII", [18] = "XVIII", [19] = "XIX", [20] = "XX",
                [21] = "XXI", [22] = "XXII", [23] = "XXIII", [24] = "XXIV",
                [25] = "XXV", [26] = "XXVI", [27] = "XXVII", [28] = "XXVIII",
                [29] = "XXIX", [30] = "XXX", [31] = "XXXI", [32] = "XXXII",
                [33] = "XXXIII", [34] = "XXXIV", [35] = "XXXV", [36] = "XXXVI",
                [37] = "XXXVII", [38] = "XXXVIII", [39] = "XXXIX", [40] = "XL",
                [41] = "XLI", [42] = "XLII", [43] = "XLIII", [44] = "XLIV",
                [45] = "XLV", [46] = "XLVI", [47] = "XLVII", [48] = "XLVIII",
                [49] = "XLIX", [50] = "L"
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
                    pcall(function()
                        ToServer:FireServer(unpack(args))
                    end)
                    task.wait(0.2)
                end
            end
            task.wait(3)
        end
    end)
end

local function startAutoRollDragonRace()
    task.spawn(function()
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Dragon_Race_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        while getgenv().SeisenHubRunning and autoRollDragonRaceEnabled do
            local args = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Dragon_Race",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(args))
            end)
            task.wait(1)
        end
    end)
end

function startAutoRollSaiyanEvolution()
    task.spawn(function()
        -- Unlock Saiyan Evolution first
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Saiyan_Evolution_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        -- Wait to ensure unlock is processed
        task.wait(2) -- Adjust delay if needed based on server response time
        -- Now keep rolling while enabled
        while getgenv().SeisenHubRunning and autoRollSaiyanEvolutionEnabled do
            local args = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Saiyan_Evolution",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(args))
            end)
            task.wait(1)
        end
    end)
end

local function startAutoRollStars()
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

local function startAutoTimeReward()
    task.spawn(function()
        while isAutoTimeRewardEnabled and getgenv().SeisenHubRunning do
            local args = {
                [1] = {
                    ["Action"] = "_Hourly_Rewards",
                    ["Id"] = "All",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(args))
            end)
            task.wait(1)
        end
    end)
end

local function startAutoDailyChest()
    task.spawn(function()
        while isAutoDailyChestEnabled and getgenv().SeisenHubRunning do
            local args = {
                [1] = {
                    ["Action"] = "_Chest_Claim",
                    ["Name"] = "Daily",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(args))
            end)
            task.wait(1)
        end
    end)
end

local function startAutoVipChest()
    task.spawn(function()
        while isAutoVipChestEnabled and getgenv().SeisenHubRunning do
            local args = {
                [1] = {
                    ["Action"] = "_Chest_Claim",
                    ["Name"] = "Vip",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(args))
            end)
            task.wait(1)
        end
    end)
end

local function startAutoGroupChest()
    task.spawn(function()
        while isAutoGroupChestEnabled and getgenv().SeisenHubRunning do
            local args = {
                [1] = {
                    ["Action"] = "_Chest_Claim",
                    ["Name"] = "Group",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(args))
            end)
            task.wait(1)
        end
    end)
end

local function startAutoPremiumChest()
    task.spawn(function()
        while isAutoPremiumChestEnabled and getgenv().SeisenHubRunning do
            local args = {
                [1] = {
                    ["Action"] = "_Chest_Claim",
                    ["Name"] = "Premium",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(args))
            end)
            task.wait(1)
        end
    end)
end

local function startAutoUpgrade()
    task.spawn(function()
        while autoUpgradeEnabled and getgenv().SeisenHubRunning do
            pcall(function()
                for upgradeName, isEnabled in pairs(enabledUpgrades) do
                    if isEnabled then
                        local args = {
                            [1] = {
                                ["Upgrading_Name"] = upgradeName,
                                ["Action"] = "_Upgrades",
                                ["Upgrade_Name"] = "Upgrades",
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

local function startAutoRollSwords()
    task.spawn(function()
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Swords_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        while getgenv().SeisenHubRunning and autoRollSwordsEnabled do
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Swords",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(rollArgs))
            end)
            task.wait(1)
        end
    end)
end

local function startAutoRollPirateCrew()
    task.spawn(function()
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Pirate_Crew_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        while getgenv().SeisenHubRunning and autoRollPirateCrewEnabled do
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Pirate_Crew",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(rollArgs))
            end)
            task.wait(1)
        end
    end)
end

function startAutoHakiUpgrade()
    task.spawn(function()
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Haki_Upgrade_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        while autoHakiUpgradeEnabled and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Haki_Upgrade",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Haki_Upgrade",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end

function startAutoRollDemonFruits()
    task.spawn(function()
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Demon_Fruits_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        while autoRollDemonFruitsEnabled and getgenv().SeisenHubRunning do
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Demon_Fruits",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(rollArgs))
            end)
            task.wait(1)
        end
    end)
end

function startAutoAttackRangeUpgrade()
    task.spawn(function()
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Attack_Range_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        while autoAttackRangeUpgradeEnabled and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Attack_Range",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Attack_Range",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end

-- Add missing function for auto chakra progression upgrade
local function startAutoChakraProgressionUpgrade()
    task.spawn(function()
        -- Unlock Chakra Progression first (only once)
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Chakra_Progression_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        task.wait(2)
        -- Now keep upgrading while enabled
        while autoChakraProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Chakra",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Chakra_Progression",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end

local function applyNotificationsState()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 5)
    if not playerGui then return end

    local notifications = playerGui:WaitForChild("Notifications", 5)
    if not notifications then return end

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

local function applyMutePetSoundsState()
    local audioFolder = ReplicatedStorage:WaitForChild("Audio", 5)
    if not audioFolder then return end

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

task.defer(function()
    repeat task.wait() until Library.Flags
    for flag, value in pairs(config) do
        if Library.Flags[flag] then
            pcall(function()
                Library.Flags[flag]:Set(value)
            end)
        end
    end

    local maxRetries = 5
    local retryDelay = 1
    for i = 1, maxRetries do
        if disableNotificationsEnabled then
            applyNotificationsState()
            if Players.LocalPlayer:FindFirstChild("PlayerGui") and Players.LocalPlayer.PlayerGui:FindFirstChild("Notifications") then
                break
            end
        end
        task.wait(retryDelay)
    end
end)

function startAutoSpiritualPressureUpgrade()
    task.spawn(function()
        -- Unlock Spiritual Pressure first
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Spiritual_Pressure_Unlock"
            }
        }
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(unlockArgs))
        end)
        -- Wait to ensure unlock is processed
        task.wait(2) -- Adjust delay if needed based on server response time
        while autoSpiritualPressureUpgradeEnabled and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Spiritual_Pressure",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Spiritual_Pressure"
                }
            }
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end

function startAutoRollReiatsuColor()
    task.spawn(function()
        -- Unlock Reiatsu Color first (only once)
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Reiatsu_Color_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        -- Now keep rolling while enabled
        while autoRollReiatsuColorEnabled and getgenv().SeisenHubRunning do
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Reiatsu_Color",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(rollArgs))
            end)
            task.wait(1)
        end
    end)
end

local function startAutoRollZanpakuto()
    task.spawn(function()
        -- Unlock Zanpakuto first (only once)
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Zanpakuto_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        -- Now keep rolling while enabled
        while autoRollZanpakutoEnabled and getgenv().SeisenHubRunning do
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Zanpakuto",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(rollArgs))
            end)
            task.wait(1)
        end
    end)
end

function startAutoCursedProgressionUpgrade()
    task.spawn(function()
        -- Unlock Cursed Progression first (only once)
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Cursed_Progression_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        -- Wait to ensure unlock is processed
        task.wait(2) -- Adjust delay if needed based on server response time
        -- Now keep upgrading while enabled
        while autoCursedProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Curse",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Cursed_Progression",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end

local function startAutoRollCurses()
    task.spawn(function()
        -- Unlock Curses first (only once)
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Curses_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        -- Now keep rolling while enabled
        while autoRollCursesEnabled and getgenv().SeisenHubRunning do
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Curses",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(rollArgs))
            end)
            task.wait(1)
        end
    end)
end

function startAutoObelisk()
    task.spawn(function()
        local obeliskTypes = {
            "Dragon_Obelisk",
            "Pirate_Obelisk",
            "Soul_Obelisk",
            "Sorcerer_Obelisk",
            "Slayer_Obelisk",
            "Solo_Obelisk",
            "Clover_Obelisk",
            "Leaf_Obelisk",
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

function startAutoRollGrimoire()
    task.spawn(function()
        -- Unlock Grimoire first (buy logic)
        local unlockArgs = {
            [1] = {
                ["Open_Amount"] = 1,
                ["Action"] = "_Gacha_Activate",
                ["Name"] = "Grimoire_Buy",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        task.wait(2)
        -- Now keep rolling while enabled
        while config.AutoRollGrimoireToggle and getgenv().SeisenHubRunning do
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Grimoire",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(rollArgs))
            end)
            task.wait(1)
        end
    end)
end


-- 🧠 FPS Boost Logic
local originalFPSValues = {}
local originalLightingValues = {}
local originalTerrainValues = {}
local originalRenderingQuality = nil

local function applyFPSBoostToInstance(obj)
    if obj:IsA("Decal") or obj:IsA("Texture") then
        -- Save original transparency if not already saved
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

local function enableFPSBoost()
    if game:FindFirstChild("Lighting") then
        local Lighting = game.Lighting
        -- Save original lighting values
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
        -- Save original terrain values
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
        applyFPSBoostToInstance(obj)
    end

    if settings().Rendering then
        if not originalRenderingQuality then
            originalRenderingQuality = settings().Rendering.QualityLevel
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end
end

local fpsBoostConnection
local function setupFPSBoostListener()
    if fpsBoostConnection then
        fpsBoostConnection:Disconnect()
        fpsBoostConnection = nil
    end
    if fpsBoostEnabled then
        fpsBoostConnection = workspace.DescendantAdded:Connect(function(obj)
            applyFPSBoostToInstance(obj)
        end)
    end
end

local function disableFPSBoost()
    if fpsBoostConnection then
        fpsBoostConnection:Disconnect()
        fpsBoostConnection = nil
    end
    
    -- Restore original lighting values
    if game:FindFirstChild("Lighting") and originalLightingValues.GlobalShadows ~= nil then
        local Lighting = game.Lighting
        Lighting.GlobalShadows = originalLightingValues.GlobalShadows
        Lighting.FogEnd = originalLightingValues.FogEnd
        Lighting.Brightness = originalLightingValues.Brightness
    end

    -- Restore original terrain values
    if workspace:FindFirstChild("Terrain") and originalTerrainValues.WaterWaveSize ~= nil then
        local Terrain = workspace.Terrain
        Terrain.WaterWaveSize = originalTerrainValues.WaterWaveSize
        Terrain.WaterWaveSpeed = originalTerrainValues.WaterWaveSpeed
        Terrain.WaterReflectance = originalTerrainValues.WaterReflectance
        Terrain.WaterTransparency = originalTerrainValues.WaterTransparency
    end

    -- Restore original values for all affected objects
    for obj, props in pairs(originalFPSValues) do
        if obj and obj.Parent then
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = props.Transparency or 0
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = props.Enabled == nil and true or props.Enabled
            end
        end
    end
    
    -- Restore original rendering quality
    if settings().Rendering and originalRenderingQuality then
        settings().Rendering.QualityLevel = originalRenderingQuality
    end
    
    -- Clear all stored original values
    originalFPSValues = {}
    originalLightingValues = {}
    originalTerrainValues = {}
    originalRenderingQuality = nil
end

local function applyFPSBoostState()
    if fpsBoostEnabled then
        enableFPSBoost()
        setupFPSBoostListener()
    else
        disableFPSBoost()
    end
end

local function startAutoRollDemonArts()
    task.spawn(function()
        -- Unlock Demon Arts first (only once)
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Demon_Arts_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        -- Now keep rolling while enabled
        while autoRollDemonArtsEnabled and getgenv().SeisenHubRunning do
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Demon_Arts",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(rollArgs))
            end)
            task.wait(1)
        end
    end)
end



local redeemCodes = {
    "Update8", "JewelFix2", "240KFAV", "250KFAV", "Update8P2", "80KLIKES", "JewelFix", "12KPlayers", "13KPlayers",
    "14KPlayers", "Update8P1", "75KLIKES", "Update8", "70KLIKES", "11KPlayers", "230KFAV", "13MVISITS", "BugFixesUp7",
    "10KPlayers", "ObeliskBug", "Update7Part2", "220KFav", "12MVISITS", "65KLikes", "9KPlayers", "Update7Part1",
    "60KLIKES", "55KLIKES", "8KPlayers", "10MVISITS", "210KFav", "50KLikes", "195KAV", "200KFAV", "Update6QoL",
    "Refresh", "175KFAV", "Update6", "5MVisits", "6MVisits", "190KFAV", "Update5Part2", "45KLIKES", "140KFAV",
    "160KFAV", "4MVisits", "SorryForShutdown3", "SomeBugFix1", "40KLikes", "Update5Part1", "30KLIKES", "125KFAV",
    "7KPlayers", "35KLIKES", "SorryForShutdown2", "SorryForSouls", "3MVISITS", "SorryForDelay2", "60KFav", "75KFav",
    "2MVisits", "Update3Part2", "20KLikes", "SorryForDelay1", "6KPlayers", "Update4", "25KLIKES", "100KFAV",
    "Update10", "20MVisits", "280KFAV", "290KFAV", "105KLikes", "EnergyFix", "TinyCode", "Update10Part2", "25MVisits",
    "300KFAV", "110KLIKES", "DefenseRaidFix","Update11","115KLIKES","120KLIKES","310KFAV","17KPlayers","UpdateDelay",
    "BugFixUpdate11","18KPlayers","19KPlayers","20KPlayers","21KPlayers", "Update11.5", "320KFav","130KLikes","30MVisits",
    "TheEyes","Update12.2","35MVisits","140KLikes","340KFav","29KPlayers","30kOnline","Update12.2Late","Update12.5",
    "31KPlayers","32KPlayers","33KPlayers","150KLikes", "DungeonFall1",
}

local function redeemAllCodes()
    -- Removed debug print
    for _, code in ipairs(redeemCodes) do
    -- Removed debug print
        local args = {
            [1] = {
                ["Action"] = "_Redeem_Code",
                ["Text"] = code,
            }
        }
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
        end)
        task.wait(0.5)
    end
end


function startAutoDeleteGacha()
    task.spawn(function()
        while config.AutoDeleteGachaUnitsToggle and getgenv().SeisenHubRunning do
            for rarity, enabled in pairs(selectedGachaRarities) do
                if enabled then
                    local args = {
                        [1] = {
                            ["Value"] = true,
                            ["Path"] = {"Settings", "AutoDelete", "Gachas", "3000"..rarity, rarity},
                            ["Action"] = "Settings"
                        }
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
                    end)
                end
            end
            task.wait(2)
        end
    end)
end

local function startAutoReawakeningProgressionUpgrade()
    task.spawn(function()
        -- Unlock ReAwakening first
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "ReAwakening_Progression_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        task.wait(2)
        -- Now keep upgrading while enabled
        while autoReawakeningProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "ReAwakening",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "ReAwakening_Progression",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end

local function startAutoSoloHunterRank()
    task.spawn(function()
        -- Unlock Solo Hunter Rank first
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Solo_Hunter_Rank_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        task.wait(2)
        -- Now keep rolling while enabled
        while autoSoloHunterRankEnabled and getgenv().SeisenHubRunning do
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Solo_Hunter_Rank",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(rollArgs))
            end)
            task.wait(1)
        end
    end)
end

-- Auto Water Spirit Progression Upgrade
function startAutoWaterSpiritProgressionUpgrade()
    task.spawn(function()
        -- Unlock Water Spirit Progression first
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Water_Spirit_Progression_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        task.wait(2)
        -- Now keep upgrading while enabled
        while config.AutoWaterSpiritProgressionUpgradeToggle and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Water_Spirit",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Water_Spirit_Progression",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end

function startAutoWindSpiritProgressionUpgrade()
    task.spawn(function()
        -- Unlock Wind Spirit Progression first
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Wind_Spirit_Progression_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        task.wait(2)
        -- Now keep upgrading while enabled
        while config.AutoWindSpiritProgressionUpgradeToggle and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Wind_Spirit",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Wind_Spirit_Progression",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end

function startAutoFireSpiritProgressionUpgrade()
    task.spawn(function()
        -- Unlock Fire Spirit Progression first
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Fire_Spirit_Progression_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        task.wait(2)
        -- Now keep upgrading while enabled
        while config.AutoFireSpiritProgressionUpgradeToggle and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Fire_Spirit",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Fire_Spirit_Progression",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end

local function startAutoMonarchProgressionUpgrade()
    task.spawn(function()
        -- Unlock Monarch first
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Monarch_Progression_Unlock",
            }
        }
        pcall(function()
            ToServer:FireServer(unpack(unlockArgs))
        end)
        task.wait(2)
        -- Now keep upgrading while enabled
        while autoMonarchProgressionUpgradeEnabled and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Monarch",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Monarch_Progression",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end

local function teleportToNearestAliveMonster()
    local monstersFolder = workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Monsters")
    local character = game.Players.LocalPlayer.Character
    local myHRP = character and character:FindFirstChild("HumanoidRootPart")
    if not monstersFolder or not myHRP then return end

    local closestMonster, closestDist = nil, math.huge
    local myPos = myHRP.Position

    for _, monster in ipairs(monstersFolder:GetChildren()) do
        local hrp = monster:FindFirstChild("HumanoidRootPart")
        local hum = monster:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local dist = (hrp.Position - myPos).Magnitude
            if dist < closestDist then
                closestMonster = monster
                closestDist = dist
            end
        end
    end

    if closestMonster and closestMonster:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            myHRP.CFrame = CFrame.new(closestMonster.HumanoidRootPart.Position + Vector3.new(0, 0, -3))
        end)
        return closestMonster
    end
    return nil
end

local function startAutoRollPowerEyes()
    task.spawn(function()
        -- Unlock Power Eyes first (buy logic)
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Power_Eyes_Unlock",
            }
        }
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(unlockArgs))
        end)
        task.wait(2)
        -- Now keep rolling while enabled
        while config.AutoRollPowerEyesToggle and getgenv().SeisenHubRunning do
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Power_Eyes",
                }
            }
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(rollArgs))
            end)
            task.wait(1)
        end
    end)
end

function startAutoSpiritualUpgrade()
    task.spawn(function()
        -- Unlock Spiritual Upgrade first
        local unlockArgs = {
            [1] = {
                ["Upgrading_Name"] = "Unlock",
                ["Action"] = "_Upgrades",
                ["Upgrade_Name"] = "Spiritual_Upgrade_Unlock",
            }
        }
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(unlockArgs))
        end)
        task.wait(1)
        -- Upgrade Spiritual Upgrade while enabled
        while autoSpiritualUpgradeEnabled and getgenv().SeisenHubRunning do
            local upgradeArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Spiritual_Upgrade",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Spiritual_Upgrade",
                }
            }
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(upgradeArgs))
            end)
            task.wait(2)
        end
    end)
end


-- Auto Prestige Toggle
local autoPrestigeThread = nil
local function startAutoPrestige()
    if autoPrestigeThread then return end
    autoPrestigeThread = task.spawn(function()
        while autoPrestigeEnabled do
            local args = {
                [1] = {
                    ["Action"] = "Level_Up_Prestige";
                };
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(args))
            task.wait(1.5)
        end
    end)
end

-- Auto Buy Psychic Mayhem Toggle
local autoPsychicMayhemThread = nil
local function startAutoPsychicMayhem()
    if autoPsychicMayhemThread then return end
    autoPsychicMayhemThread = task.spawn(function()
        while autoPsychicMayhemEnabled do
            -- Buy Psychic Mayhem Unlock
            local buyArgs = {
                [1] = {
                    ["Upgrading_Name"] = "Unlock",
                    ["Action"] = "_Upgrades",
                    ["Upgrade_Name"] = "Psychic_Mayhem_Unlock",
                },
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(buyArgs))
            task.wait(0.5)
            -- Roll Psychic Mayhem
            local rollArgs = {
                [1] = {
                    ["Open_Amount"] = 1,
                    ["Action"] = "_Gacha_Activate",
                    ["Name"] = "Psychic_Mayhem",
                },
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9):FireServer(unpack(rollArgs))
            task.wait(1.5)
        end
    end)
end

local function stopAutoPsychicMayhem()
    autoPsychicMayhemEnabled = false
    if autoPsychicMayhemThread then
        autoPsychicMayhemThread = nil
    end
end

local function stopAutoPrestige()
    autoPrestigeEnabled = false
    if autoPrestigeThread then
        autoPrestigeThread = nil
    end
end


-- Monitor Dungeon_Notification and auto-enter dungeons when visible
local function monitorDungeonNotificationAndEnter()
    local player = game:GetService("Players").LocalPlayer
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return end
    local dungeonGui = gui:FindFirstChild("Dungeon")
    if not dungeonGui then return end
    local notification = dungeonGui:FindFirstChild("Dungeon_Notification")
    if not notification then return end
    local lastVisible = false
    task.spawn(function()
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
                        pcall(function()
                            ToServer:FireServer(unpack(args))
                        end)
                        task.wait(2)
                    end
                end
                if not notification.Visible then
                    lastVisible = false
                end
                task.wait(0.2)
            end
    end)
end

-- Auto Dungeon Entry
function startAutoDungeon()
    task.spawn(function()
        local player = game:GetService("Players").LocalPlayer
        local gui = player:FindFirstChild("PlayerGui")
        if not gui then return end
        local dungeonGui = gui:FindFirstChild("Dungeon")
        if not dungeonGui then return end
        local header = dungeonGui:FindFirstChild("Default_Header")
        local dungeonFarmRange = 140 -- Only target monsters within 30 studs
        while getgenv().SeisenHubRunning do
            if config.AutoDungeonToggle and header and header.Visible then
                task.wait(5)
                if header.Visible then
                    local monstersFolder = nil
                    if workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Monsters") then
                        monstersFolder = workspace.Debris.Monsters
                    elseif workspace:FindFirstChild("Monsters") then
                        monstersFolder = workspace.Monsters
                    end
                    if not monstersFolder then
                        task.wait(1)
                    else
                        -- The rest of the loop logic goes here
                    end
                    local char = player.Character
                    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
                    local aliveMonsters = {}
                    for _, monster in pairs(monstersFolder:GetChildren()) do
                        if monster:IsA("Model") then
                            local hrp = monster:FindFirstChild("HumanoidRootPart")
                            local hum = monster:FindFirstChild("Humanoid")
                            if hrp and hum and hum.Health > 0 and myHRP and (myHRP.Position - hrp.Position).Magnitude <= dungeonFarmRange then
                                table.insert(aliveMonsters, monster)
                            end
                        end
                    end
                    local currentTarget = nil
                    while config.AutoDungeonToggle and getgenv().SeisenHubRunning and header.Visible do
                        local monstersFolder = nil
                        if workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Monsters") then
                            monstersFolder = workspace.Debris.Monsters
                        elseif workspace:FindFirstChild("Monsters") then
                            monstersFolder = workspace.Monsters
                        end
                        if not monstersFolder then
                                task.wait(1)
                        else
                        end
                        local aliveMonsters = {}
                        local char = player.Character
                        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
                        for _, monster in pairs(monstersFolder:GetChildren()) do
                            if monster:IsA("Model") then
                                local hrp = monster:FindFirstChild("HumanoidRootPart")
                                local hum = monster:FindFirstChild("Humanoid")
                                if hrp and hum and hum.Health > 0 and myHRP and (myHRP.Position - hrp.Position).Magnitude <= dungeonFarmRange then
                                    table.insert(aliveMonsters, monster)
                                end
                            end
                        end
                        local validTarget = false
                        if currentTarget and currentTarget:IsDescendantOf(monstersFolder) and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 then
                            validTarget = true
                        end
                        if not validTarget then
                            currentTarget = aliveMonsters[1]
                            if currentTarget then
                                teleportToMonster(currentTarget)
                            end
                        end
                        if currentTarget then
                            local hrp = currentTarget:FindFirstChild("HumanoidRootPart")
                            local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if myHRP and hrp and (myHRP.Position - hrp.Position).Magnitude < 20 then
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
                        end
                        task.wait(math.max(attackCooldown or 0.15, 0.3))
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end



if autoRankEnabled then startAutoRank() end
if autoAvatarLevelingEnabled then startAutoAvatarLeveling() end
if autoAcceptAllQuestsEnabled then startAutoQuests() end
if autoClaimAchievementsEnabled then startAutoAchievements() end
if autoRollDragonRaceEnabled then startAutoRollDragonRace() end
if autoRollSaiyanEvolutionEnabled then startAutoRollSaiyanEvolution() end
if autoRollEnabled then startAutoRollStars() end
if autoDeleteEnabled then startAutoDelete() end
if autoStatsRunning then startAutoStats() end
if isAutoTimeRewardEnabled then startAutoTimeReward() end
if isAutoDailyChestEnabled then startAutoDailyChest() end
if isAutoVipChestEnabled then startAutoVipChest() end
if isAutoGroupChestEnabled then startAutoGroupChest() end
if isAutoPremiumChestEnabled then startAutoPremiumChest() end
if monitorDungeonNotificationAndEnter then monitorDungeonNotificationAndEnter() end
if autoUpgradeEnabled then startAutoUpgrade() end
if autoRollSwordsEnabled then startAutoRollSwords() end
if autoRollPirateCrewEnabled then startAutoRollPirateCrew() end
if autoRollDemonFruitsEnabled then startAutoRollDemonFruits() end
if autoHakiUpgradeEnabled then startAutoHakiUpgrade() end
if autoAttackRangeUpgradeEnabled then startAutoAttackRangeUpgrade() end
if autoRollReiatsuColorEnabled then startAutoRollReiatsuColor() end
if disableNotificationsEnabled then applyNotificationsState() end
if mutePetSoundsEnabled then applyMutePetSoundsState() end
if autoRollZanpakutoEnabled then startAutoRollZanpakuto() end
if autoCursedProgressionUpgradeEnabled then startAutoCursedProgressionUpgrade() end
if autoRollCursesEnabled then startAutoRollCurses() end
if autoObeliskEnabled then startAutoObelisk() end
if autoRollDemonArtsEnabled then startAutoRollDemonArts() end
if fpsBoostEnabled then applyFPSBoostState() end
if config.AutoDeleteGachaUnitsToggle then startAutoDeleteGacha() end
if config.AutoChakraProgressionUpgradeToggle then startAutoChakraProgressionUpgrade() end
if autoChakraProgressionUpgradeEnabled then startAutoChakraProgressionUpgrade() end
if autoSoloHunterRankEnabled then startAutoSoloHunterRank() end
if autoReawakeningProgressionUpgradeEnabled then startAutoReawakeningProgressionUpgrade() end
if autoMonarchProgressionUpgradeEnabled then startAutoMonarchProgressionUpgrade() end
if autoSpiritualPressureUpgradeEnabled then startAutoSpiritualPressureUpgrade() end
if config.AutoWaterSpiritProgressionUpgradeToggle then startAutoWaterSpiritProgressionUpgrade() end
if config.AutoWindSpiritProgressionUpgradeToggle then startAutoWindSpiritProgressionUpgrade() end
if config.AutoFireSpiritProgressionUpgradeToggle then startAutoFireSpiritProgressionUpgrade() end
if config.AutoDungeonToggle then startAutoDungeon() end
if config.AutoReiatsuColorToggle then startAutoReiatsuColor() end
if config.AutoSpiritualUpgradeToggle then startAutoSpiritualUpgrade() end
if autoPsychicMayhemEnabled then startAutoPsychicMayhem() end
if config.MonsterSelector and monsterDropdown and typeof(monsterDropdown.SetValue) == "function" then
    local value = config.MonsterSelector
    -- Convert array to dictionary if needed
    if type(value) == "table" and (#value > 0 or next(value)) then
        local isArray = true
        for k, v in pairs(value) do
            if type(k) ~= "number" then isArray = false break end
        end
        if isArray then
            local dict = {}
            for _, v in ipairs(value) do
                dict[v] = true
            end
            value = dict
        end
    end
    task.defer(function()
        monsterDropdown:SetValue(value)
    end)
end
if config.AttackCooldownSlider and Library.Flags and Library.Flags.AttackCooldownSlider then
    Library.Flags.AttackCooldownSlider:Set(config.AttackCooldownSlider)
end
if config.AutoRollPowerEyesToggle then startAutoRollPowerEyes() end

-- Auto Farm Toggle
LeftGroupbox:AddToggle("AutoFarmToggle", {
    Text = "Fast Auto Farm",
    Default = isAuraEnabled,
    Tooltip = "Automatically farms monsters for you.",
    Callback = function(Value)
        disableAllAurasExcept("AutoFarm")
        config.AutoFarmToggle = Value
        isAuraEnabled = Value
        if Value then startAutoFarm() end
        saveConfig()
    end
})


-- Monster selection dropdown (placed with toggles)
monsterDropdown = LeftGroupbox:AddDropdown("MonsterSelector", {
    Text = "Select Monster(s)",
    Values = getAllMonsterTitles(),
    Default = config.MonsterSelector or {},
    Multi = true,
    Tooltip = "Choose which monsters to target (by Title). Select multiple monsters to farm.",
    Callback = function(values)
        local HttpService = game:GetService("HttpService")
        -- Convert dictionary to array of selected titles
        local selectedTitles = {}
        if type(values) == "table" then
            for k, v in pairs(values) do
                if v then
                    table.insert(selectedTitles, k)
                end
            end
        end
        monsterDropdownValues = selectedTitles
        config.MonsterSelector = values
        saveConfig()
        local character = localPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and #monsterDropdownValues > 0 then
            local myPos = character.HumanoidRootPart.Position
            for _, selectedTitle in ipairs(monsterDropdownValues) do
                local closest, closestDist = nil, math.huge
                for _, monster in pairs(monstersFolder:GetChildren()) do
                    if monster:IsA("Model") then
                        local title = monster:GetAttribute("Title")
                        local hrp = monster:FindFirstChild("HumanoidRootPart")
                        if type(title) == "string" and title == selectedTitle and hrp then
                            local dist = (hrp.Position - myPos).Magnitude
                            if dist < closestDist then
                                closest = monster
                                closestDist = dist
                            end
                        end
                    end
                end
                if closest and closest:IsA("Model") then
                    local hrp = closest:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        pcall(function()
                            character.HumanoidRootPart.CFrame = CFrame.new(hrp.Position + teleportOffset)
                        end)
                        task.wait(0.2) -- short delay between teleports
                    end
                end
            end
        end
    end
})

if config.MonsterSelector and monsterDropdown and typeof(monsterDropdown.SetValue) == "function" then
    monsterDropdown:SetValue(config.MonsterSelector)
end

-- Ensure autofarm starts if toggle is on and monsters are selected when script loads
task.defer(function()
    if config.AutoFarmToggle and monsterDropdownValues and #monsterDropdownValues > 0 then
        startAutoFarm()
    end
end)

-- Attack Cooldown Slider
LeftGroupbox:AddSlider("AttackCooldownSlider", {
    Text = "Attack Cooldown",
    Min = 0.05,
    Max = 1,
    Default = attackCooldown,
    Suffix = "s",
    Rounding = 2,
    Tooltip = "Set the delay between attacks (lower = faster). Lower values increase attack speed.",
    Callback = function(Value)
        attackCooldown = Value
        config.AttackCooldownSlider = Value
        saveConfig()
    end
})


LeftGroupbox:AddToggle("FarmAllToggle", {
    Text = "Farm All (TP + Damage)",
    Default = farmAllEnabled,
    Tooltip = "Teleports and attacks all monsters, ignoring dropdown selection.",
    Callback = function(Value)
        farmAllEnabled = Value
        config.FarmAllToggle = Value
        if not Value and getgenv().StopFarmAllThread then getgenv().StopFarmAllThread() end
        if Value then startFarmAll() end
        saveConfig()
    end
})

LeftGroupbox:AddToggle("KillAuraOnlyToggle", {
    Text = "Kill Aura Only (No TP)",
    Default = killAuraOnlyEnabled,
    Tooltip = "Attacks nearest monster without teleporting.",
    Callback = function(Value)
        killAuraOnlyEnabled = Value
        config.KillAuraOnlyToggle = Value
        if Value then startKillAuraOnly() end
        saveConfig()
    end
})

-- Slow Auto Farm Toggle

-- Fast Kill Aura Toggle

-- Auto Rank Toggle
LeftGroupbox:AddToggle("AutoRankToggle", {
    Text = "Auto Rank",
    Default = autoRankEnabled,
    Tooltip = "Automatically ranks up your character.",
    Callback = function(Value)
        autoRankEnabled = Value
        config.AutoRankToggle = Value
        startAutoRank()
        saveConfig()
    end
})

-- Auto Avatar Leveling Toggle
LeftGroupbox:AddToggle("AutoAvatarLevelingToggle", {
    Text = "Auto Avatar Leveling",
    Default = autoAvatarLevelingEnabled,
    Tooltip = "Automatically levels up your avatar.",
    Callback = function(Value)
        autoAvatarLevelingEnabled = Value
        config.AutoAvatarLevelingToggle = Value
        startAutoAvatarLeveling()
        saveConfig()
    end
})

-- Auto Accept Quests Toggle
LeftGroupbox:AddToggle("AutoAcceptAllQuestsToggle", {
    Text = "Auto Accept & Claim All Quests",
    Default = autoAcceptAllQuestsEnabled,
    Tooltip = "Automatically accepts and claims all quests.",
    Callback = function(Value)
        autoAcceptAllQuestsEnabled = Value
        config.AutoAcceptAllQuestsToggle = Value
        startAutoQuests()
        saveConfig()
    end
})

-- Auto Claim Achievements Toggle
LeftGroupbox:AddToggle("AutoClaimAchievement", {
    Text = "Auto Achievements",
    Default = autoClaimAchievementsEnabled,
    Tooltip = "Automatically claims achievements.",
    Callback = function(Value)
        autoClaimAchievementsEnabled = Value
        config.AutoClaimAchievement = Value
        startAutoAchievements()
        saveConfig()
    end
})

LeftGroupbox:AddToggle("AutoObeliskToggle", {
    Text = "Auto Obelisk Upgrade",
    Default = autoObeliskEnabled,
    Tooltip = "Automatically upgrades your Obelisk.",
    Callback = function(Value)
        autoObeliskEnabled = Value
        config.AutoObeliskToggle = Value
        saveConfig()
        if Value then
            startAutoObelisk()
        end
    end
})


LeftGroupbox:AddToggle("AutoPrestigeToggle", {
    Text = "Auto Prestige",
    Default = autoPrestigeEnabled,
    Tooltip = "Automatically prestiges your character when possible.",
    Callback = function(Value)
        autoPrestigeEnabled = Value
        config.AutoPrestigeToggle = Value
        saveConfig()
        if Value then
            startAutoPrestige()
        else
            stopAutoPrestige()
        end
    end
})


-- Auto Roll Dragon Race Toggle
RollGroupbox2:AddToggle("AutoRollDragonRaceToggle", {
    Text = "Auto Roll Dragon Race",
    Default = autoRollDragonRaceEnabled,
        Tooltip = "Automatically rolls for Dragon Race.",
    Callback = function(Value)
        autoRollDragonRaceEnabled = Value
        config.AutoRollDragonRaceToggle = Value
        if Value then startAutoRollDragonRace() end
        saveConfig()
    end
})

RollGroupbox2:AddToggle("AutoRollSaiyanEvolutionToggle", {
    Text = "Auto Roll Saiyan Evolution",
    Default = autoRollSaiyanEvolutionEnabled,
        Tooltip = "Automatically rolls for Saiyan Evolution.",
    Callback = function(Value)
        autoRollSaiyanEvolutionEnabled = Value
        config.AutoRollSaiyanEvolutionToggle = Value
        if Value then startAutoRollSaiyanEvolution() end
        saveConfig()
    end
})

RollGroupbox:AddToggle("AutoRollStarsToggle", {
    Text = "Auto Roll Stars",
    Default = autoRollEnabled,
        Tooltip = "Automatically rolls for stars.",
    Callback = function(Value)
        autoRollEnabled = Value
        config.AutoRollStarsToggle = Value
        if Value then startAutoRollStars() end
        saveConfig()
    end
})

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
    ["Titan Village"] = "Star_11",
    ["Village of Sins"] = "Star_12",
    ["Kaiju Base"] = "Star_13",
    ["Tempest Capital"] = "Star_14",
    ["Virtual City"] = "Star_15"
}
local starToPlace = {}
for place, star in pairs(placeToStar) do
    starToPlace[star] = place
end
-- Select Star Dropdown
RollGroupbox:AddDropdown("SelectStarDropdown", {
    Values = {"Earth City", "Windmill Island", "Soul Society", "Cursed School", "Slayer Village", "Solo Island", "Clover Village", "Leaf Village", "Spirit Residence", "Magic_Hunter_City", "Titan Village", "Village of Sins", "Kaiju Base", "Tempest Capital", "Virtual City"},
    Default = starToPlace[selectedStar] or "Earth City",
    Multi = false,
    Text = "Select Star (by Place)",
    Callback = function(Option)
        selectedStar = placeToStar[Option] or "Star_1"
        config.SelectStarDropdown = selectedStar
        saveConfig()
    end
})

-- Delay Slider
RollGroupbox:AddSlider("DelayBetweenRollsSlider", {
    Text = "Delay Between Rolls",
    Min = 0.5,
    Max = 2,
    Default = delayBetweenRolls,
    Suffix = "s",
    Callback = function(Value)
        delayBetweenRolls = Value
        config.DelayBetweenRollsSlider = Value
        saveConfig()
    end
})

-- Auto Roll Swords
RollGroupbox2:AddToggle("AutoRollSwordsToggle", {
    Text = "Auto Roll Swords",
    Default = autoRollSwordsEnabled,
    Callback = function(Value)
        autoRollSwordsEnabled = Value
        config.AutoRollSwordsToggle = Value
        if Value then startAutoRollSwords() end
        saveConfig()
    end
})

-- Auto Roll Pirate Crew
RollGroupbox2:AddToggle("AutoRollPirateCrewToggle", {
    Text = "Auto Roll Pirate Crew",
    Default = autoRollPirateCrewEnabled,
    Callback = function(Value)
        autoRollPirateCrewEnabled = Value
        config.AutoRollPirateCrewToggle = Value
        if Value then startAutoRollPirateCrew() end
        saveConfig()
    end
})

-- Auto Roll Demon Fruits
RollGroupbox2:AddToggle("AutoRollDemonFruitsToggle", {
    Text = "Auto Roll Demon Fruits",
    Default = autoRollDemonFruitsEnabled,
    Callback = function(Value)
        autoRollDemonFruitsEnabled = Value
        config.AutoRollDemonFruitsToggle = Value
        if Value then startAutoRollDemonFruits() end
        saveConfig()
    end
})

RollGroupbox2:AddToggle("AutoRollReiatsuColorToggle", {
    Text = "Auto Roll Reiatsu Color",
    Default = autoRollReiatsuColorEnabled,
    Callback = function(Value)
        autoRollReiatsuColorEnabled = Value
        config.AutoRollReiatsuColorToggle = Value
        if Value then startAutoRollReiatsuColor() end
        saveConfig()
    end
})

RollGroupbox2:AddToggle("AutoRollZanpakutoToggle", {
    Text = "Auto Roll Zanpakuto",
    Default = autoRollZanpakutoEnabled,
    Callback = function(Value)
        autoRollZanpakutoEnabled = Value
        config.AutoRollZanpakutoToggle = Value
        if Value then startAutoRollZanpakuto() end
        saveConfig()
    end
})

RollGroupbox2:AddToggle("AutoRollCursesToggle", {
    Text = "Auto Roll Curses",
    Default = autoRollCursesEnabled,
    Callback = function(Value)
        autoRollCursesEnabled = Value
        config.AutoRollCursesToggle = Value
        if Value then startAutoRollCurses() end
        saveConfig()
    end
})

RollGroupbox2:AddToggle("AutoRollDemonArtsToggle", {
    Text = "Auto Roll Demon Arts",
    Default = autoRollDemonArtsEnabled,
    Callback = function(Value)
        autoRollDemonArtsEnabled = Value
        config.AutoRollDemonArtsToggle = Value
        if Value then startAutoRollDemonArts() end
        saveConfig()
    end
})
RollGroupbox2:AddToggle("AutoRollGrimoireToggle", {
    Text = "Auto Roll Grimoire",
    Default = config.AutoRollGrimoireToggle or false,
    Callback = function(Value)
        config.AutoRollGrimoireToggle = Value
        if Value then startAutoRollGrimoire() end
        saveConfig()
    end
})

RollGroupbox2:AddToggle("AutoSoloHunterRankToggle", {
    Text = "Auto Roll Solo Rank",
    Default = autoSoloHunterRankEnabled,
    Callback = function(Value)
        autoSoloHunterRankEnabled = Value
        config.AutoSoloHunterRankToggle = Value
        if Value then startAutoSoloHunterRank() end
        saveConfig()
    end
})


RollGroupbox2:AddToggle("AutoRollPowerEyesToggle", {
    Text = "Auto Roll Power Eyes",
    Default = config.AutoRollPowerEyesToggle or false,
    Callback = function(Value)
        config.AutoRollPowerEyesToggle = Value
        if Value then startAutoRollPowerEyes() end
        saveConfig()
    end
})


RollGroupbox2:AddToggle("AutoPsychicMayhemToggle", {
    Text = "Auto Roll Psychic Mayhem",
    Default = autoPsychicMayhemEnabled,
    Tooltip = "Automatically buys and rolls Psychic Mayhem.",
    Callback = function(Value)
        autoPsychicMayhemEnabled = Value
        config.AutoPsychicMayhemToggle = Value
        saveConfig()
        if Value then
            startAutoPsychicMayhem()
        else
            stopAutoPsychicMayhem()
        end
    end
})

-- Auto Delete Settings
AutoDeleteGroupbox:AddLabel("Auto Delete Settings")

-- Auto Delete Toggle
AutoDeleteGroupbox:AddToggle("AutoDeleteUnitsToggle", {
    Text = "Auto Delete Units",
    Default = autoDeleteEnabled,
    Callback = function(Value)
        autoDeleteEnabled = Value
        config.AutoDeleteUnitsToggle = Value
        if Value then startAutoDelete() end
        saveConfig()
    end
})

-- Select Star for Auto Delete Dropdown
AutoDeleteGroupbox:AddDropdown("SelectDeleteStarDropdown", {
    Values = {"Earth City", "Windmill Island", "Soul Society", "Cursed School", "Slayer Village", "Solo Island", "Clover Village", "Leaf Village", "Spirit Residence", "Magic_Hunter_City", "Titan Village", "Village of Sins", "Kaiju Base", "Tempest Capital", "Virtual City"},
    Default = starToPlace[selectedDeleteStar] or "Earth City",
    Multi = false,
    Text = "Select Star for Auto Delete (by Place)",
    Callback = function(Option)
        selectedDeleteStar = placeToStar[Option] or "Star_1"
        config.SelectDeleteStarDropdown = selectedDeleteStar
        saveConfig()
    end
})

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
AutoDeleteGroupbox:AddDropdown("AutoDeleteRaritiesDropdown", {
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"},
    Default = selectedRaritiesDisplay,
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
})

AutoDeleteGroupbox2:AddToggle("AutoDeleteGachaUnitsToggle", {
    Text = "Auto Delete Gacha Units",
    Default = config.AutoDeleteGachaUnitsToggle or false,
    Callback = function(Value)
        config.AutoDeleteGachaUnitsToggle = Value
        if Value then startAutoDeleteGacha() end
        saveConfig()
    end
})

AutoDeleteGroupbox2:AddDropdown("AutoDeleteGachaRaritiesDropdown", {
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret"},
    Default = selectedGachaRarities,
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
})

-- Auto Stats



StatsGroupbox:AddDropdown("AutoStatSingleDropdown", {
    Values = stats,
    Default = selectedStat, -- display name
    Multi = false,
    Text = "Select Stat",
    Tooltip = "Select which stat to auto assign points to.",
    Callback = function(Value)
        selectedStat = Value -- display name
        config.AutoStatSingleDropdown = Value
        saveConfig()
    end
})

StatsGroupbox:AddToggle("AutoAssignStatToggle", {
    Text = "Enable Auto Stat",
    Default = autoStatsRunning,
    Tooltip = "Enable automatic stat assignment.",
    Callback = function(Value)
        autoStatsRunning = Value
        config.AutoAssignStatToggle = Value
        if Value then startAutoStats() end
        saveConfig()
    end
})

StatsGroupbox:AddSlider("PointsPerSecondSlider", {
    Text = "Points/Second",
    Default = pointsPerSecond,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Tooltip = "Set how many stat points to assign per second.",
    Callback = function(Value)
        pointsPerSecond = Value
        config.PointsPerSecondSlider = Value
        saveConfig()
    end
})

-- Auto Collect Rewards
RewardsGroupbox:AddToggle("AutoClaimTimeRewardToggle", {
    Text = "Auto Claim Time Reward",
    Default = isAutoTimeRewardEnabled,
    Tooltip = "Automatically claims time-based rewards.",
    Callback = function(Value)
        isAutoTimeRewardEnabled = Value
        config.AutoClaimTimeRewardToggle = Value
        if Value then startAutoTimeReward() end
        saveConfig()
    end
})

RewardsGroupbox:AddToggle("AutoClaimDailyChestToggle", {
    Text = "Auto Claim Daily Chest",
    Default = isAutoDailyChestEnabled,
    Tooltip = "Automatically claims daily chest rewards.",
    Callback = function(Value)
        isAutoDailyChestEnabled = Value
        config.AutoClaimDailyChestToggle = Value
        if Value then startAutoDailyChest() end
        saveConfig()
    end
})

RewardsGroupbox:AddToggle("AutoClaimVipChestToggle", {
    Text = "Auto Claim Vip Chest (VIP Gamepass required)",
    Default = isAutoVipChestEnabled,
    Tooltip = "Automatically claims VIP chest rewards (VIP required).",
    Callback = function(Value)
        isAutoVipChestEnabled = Value
        config.AutoClaimVipChestToggle = Value
        if Value then startAutoVipChest() end
        saveConfig()
    end
})

RewardsGroupbox:AddToggle("AutoClaimGroupChestToggle", {
    Text = "Auto Claim Group Chest",
    Default = isAutoGroupChestEnabled,
    Tooltip = "Automatically claims group chest rewards.",
    Callback = function(Value)
        isAutoGroupChestEnabled = Value
        config.AutoClaimGroupChestToggle = Value
        if Value then startAutoGroupChest() end
        saveConfig()
    end
})

RewardsGroupbox:AddToggle("AutoClaimPremiumChestToggle", {
    Text = "Auto Claim Premium Chest (Premium User required)",
    Default = isAutoPremiumChestEnabled,
    Tooltip = "Automatically claims premium chest rewards (Premium required).",
    Callback = function(Value)
        isAutoPremiumChestEnabled = Value
        config.AutoClaimPremiumChestToggle = Value
        if Value then startAutoPremiumChest() end
        saveConfig()
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
    ["Energy Macaron"] = "1109",
    ["Coin Macaron"] = "1110",
    ["Damage Macaron"] = "1111",
    ["Luck Macaron"] = "1112",
    ["Drop Macaron"] = "1113",
}


-- prepare sorted potion names
local potionNames = {}
for name,_ in pairs(potions) do table.insert(potionNames, name) end
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
    ["1113"] = "Drop_Macaron",
}

-- robust callback that accepts:
--  * string (single selection)
--  * numeric array ({"A", "B"})
--  * map ({ ["A"] = true, ["B"] = true } or { [1]="A", [2]="B" })
PotionGroupbox:AddDropdown("PotionDropdown", {
    Title = "Select Potions",
    Values = potionNames,
    Default = {},
    Multi = true,
    Callback = function(selection)
        selectedPotions = {}

        if not selection then return end
        local t = type(selection)

        if t == "string" then
            local id = potions[selection]
            if id then table.insert(selectedPotions, id) end

        elseif t == "table" then
            -- check if numeric-array style (1..n)
            local isArray = false
            for i = 1, #selection do
                if selection[i] ~= nil then
                    isArray = true
                    break
                end
            end

            if isArray then
                for _, name in ipairs(selection) do
                    local id = potions[name]
                    if id then table.insert(selectedPotions, id) end
                end
            else
                -- treat as map: { ["Name"]=true } or { [1]="Name" } etc.
                for k, v in pairs(selection) do
                    if type(k) == "string" and (v == true or v == 1) then
                        local id = potions[k]
                        if id then table.insert(selectedPotions, id) end
                    elseif type(v) == "string" then
                        local id = potions[v]
                        if id then table.insert(selectedPotions, id) end
                    end
                end
            end
        end

        -- debug: prints selected IDs to executor console
        if #selectedPotions > 0 then
            print("[Potion] selected IDs: " .. table.concat(selectedPotions, ", "))
        else
            print("[Potion] selection cleared or no match found")
        end
    end
})

-- Button: fire Use for each selected potion (small delay to avoid server spam)
PotionGroupbox:AddButton({
    Text = "Use Selected Potions",
    Func = function()
        if #selectedPotions == 0 then
            warn("No potions selected!")
            return
        end
        for _, potionId in ipairs(selectedPotions) do
            local args = {
                [1] = {
                    ["Selected"] = { [1] = potionId },
                    ["Action"] = "Use",
                    ["Amount"] = 1,
                },
            }
            ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("Inventory", 9e9):FireServer(unpack(args))
            task.wait(0.08)
        end
    end,
    DoubleClick = false
})

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
    ["Titan Village"] = "Titan_Village",
    ["Village of Sins"] = "Village_of_Sins",
    ["Kaiju Base"] = "Kaiju_Base",
    ["Tempest Capital"] = "Tempest_Capital",
    ["Virtual City"] = "Virtual_City"
}

TPGroupbox:AddDropdown("MainTeleportDropdown", {
    Values = {"Dungeon Lobby 1", "Earth City",  "Windmill Island", "Soul Society", "Cursed School", "Slayer Village", "Solo Island", "Clover Village", "Leaf Village", "Spirit Residence", "Magic Hunter City", "Titan Village", "Village of Sins", "Kaiju Base", "Tempest Capital", "Virtual City"},
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
                    ["Action"] = "Teleport",
                }
            }
            pcall(function()
                ToServer:FireServer(unpack(args))
            end)
        end
        config.MainTeleportDropdown = selected
        saveConfig()
    end
})

-- Dungeon Toggles
local dungeonList = {
    "Dungeon_Easy",
    "Dungeon_Medium",
    "Dungeon_Hard",
    "Dungeon_Insane",
    "Dungeon_Crazy",
    "Dungeon_Nightmare",
    "Leaf_Raid"
}

-- Add button to enter Restaurant Raid
DungeonGroupbox:AddButton("Enter Restaurant Raid", function()
    local args = {
        [1] = {
            ["Action"] = "_Enter_Dungeon",
            ["Name"] = "Restaurant_Raid",
        },
    }
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ToServer = ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("To_Server", 9e9)
    ToServer:FireServer(unpack(args))
end, "Teleport into the Restaurant Raid dungeon.")

for _, dungeon in ipairs(dungeonList) do
    local default = table.find(selectedDungeons, dungeon) ~= nil
    DungeonGroupbox:AddToggle("Toggle_" .. dungeon, {
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
    })
end

-- Toggle: Auto enter dungeon
DungeonGroupbox:AddToggle("AutoEnterDungeonToggle", {
    Text = "Auto Enter Dungeon(s)",
    Default = autoEnterDungeon,
    Tooltip = "Automatically enters selected dungeons.",
    Callback = function(Value)
        autoEnterDungeon = Value
        config.AutoEnterDungeonToggle = Value
        saveConfig()
        if Value then
            monitorDungeonNotificationAndEnter()
        end
    end
})


DungeonGroupbox:AddToggle("AutoDungeonToggle", {
    Text = "Auto Dungeon",
    Default = config.AutoDungeonToggle or false,
    Tooltip = "Automatically runs dungeon logic.",
    Callback = function(Value)
        config.AutoDungeonToggle = Value
        saveConfig()
        if Value then
            startAutoDungeon()
        end
    end
})


UpgradeGroupbox:AddToggle("AutoUpgradeToggle", {
    Text = "Auto Upgrade",
    Default = autoUpgradeEnabled,
    Tooltip = "Automatically upgrades your character's stats.",
    Callback = function(Value)
        autoUpgradeEnabled = Value
        config.AutoUpgradeToggle = Value
        if Value then startAutoUpgrade() end
        saveConfig()
    end
})


local upgradeOptions = {
    "Star_Luck", "Damage", "Energy", "Coins", "Drops",
    "Avatar_Souls_Drop", "Movement_Speed", "Fast_Roll", "Star_Speed"
}


-- Working upgrade toggles: add individual toggles for each upgrade option
enabledUpgrades = enabledUpgrades or {}
for _, upgradeName in ipairs(upgradeOptions) do
    UpgradeGroupbox:AddToggle(upgradeName .. "_Toggle", {
        Text = upgradeName:gsub("_", " "),
        Default = config[upgradeName .. "_Toggle"] or false,
    Tooltip = "Enable or disable auto upgrade for " .. upgradeName:gsub("_", " ") .. ".",
    Callback = function(Value)
            config[upgradeName .. "_Toggle"] = Value
            enabledUpgrades[upgradeName] = Value
            saveConfig()
        end
    })
    enabledUpgrades[upgradeName] = config[upgradeName .. "_Toggle"] or false
end


-- Auto Upgrade Haki
Upgrade2:AddToggle("AutoHakiUpgradeToggle", {
    Text = "Auto Haki Upgrade",
    Default = autoHakiUpgradeEnabled,
    Tooltip = "Automatically upgrades Haki.",
    Callback = function(Value)
        autoHakiUpgradeEnabled = Value
        config.AutoHakiUpgradeToggle = Value
        if Value then startAutoHakiUpgrade() end
        saveConfig()
    end
})

Upgrade2:AddToggle("AutoAttackRangeUpgradeToggle", {
    Text = "Auto Attack Range Upgrade",
    Default = autoAttackRangeUpgradeEnabled,
    Tooltip = "Automatically upgrades attack range.",
    Callback = function(Value)
        autoAttackRangeUpgradeEnabled = Value
        config.AutoAttackRangeUpgradeToggle = Value
        if Value then startAutoAttackRangeUpgrade() end
        saveConfig()
    end
})

Upgrade2:AddToggle("AutoSpiritualPressureUpgradeToggle", {
    Text = "Auto Spiritual Pressure Upgrade",
    Default = autoSpiritualPressureUpgradeEnabled,
    Tooltip = "Automatically upgrades spiritual pressure.",
    Callback = function(Value)
        autoSpiritualPressureUpgradeEnabled = Value
        config.AutoSpiritualPressureUpgradeToggle = Value
        if Value then startAutoSpiritualPressureUpgrade() end
        saveConfig()
    end
})

Upgrade2:AddToggle("AutoCursedProgressionUpgradeToggle", {
    Text = "Auto Cursed Progression Upgrade",
    Default = autoCursedProgressionUpgradeEnabled,
    Tooltip = "Automatically upgrades cursed progression.",
    Callback = function(Value)
        autoCursedProgressionUpgradeEnabled = Value
        config.AutoCursedProgressionUpgradeToggle = Value
        if Value then startAutoCursedProgressionUpgrade() end
        saveConfig()
    end
})

Upgrade2:AddToggle("AutoReawakeningProgressionUpgradeToggle", {
    Text = "Auto Reawakening Progression Upgrade",
    Default = autoReawakeningProgressionUpgradeEnabled,
    Tooltip = "Automatically upgrades reawakening progression.",
    Callback = function(Value)
        autoReawakeningProgressionUpgradeEnabled = Value
        config.AutoReawakeningProgressionUpgradeToggle = Value
        if Value then startAutoReawakeningProgressionUpgrade() end
        saveConfig()
    end
})

Upgrade2:AddToggle("AutoMonarchProgressionUpgradeToggle", {
    Text = "Auto Monarch Progression Upgrade",
    Default = autoMonarchProgressionUpgradeEnabled,
    Tooltip = "Automatically upgrades monarch progression.",
    Callback = function(Value)
        autoMonarchProgressionUpgradeEnabled = Value
        config.AutoMonarchProgressionUpgradeToggle = Value
        if Value then startAutoMonarchProgressionUpgrade() end
        saveConfig()
    end
})


Upgrade2:AddToggle("AutoWaterSpiritProgressionUpgradeToggle", {
    Text = "Auto Water Spirit Progression Upgrade",
    Default = config.AutoWaterSpiritProgressionUpgradeToggle or false,
    Tooltip = "Automatically upgrades water spirit progression.",
    Callback = function(Value)
        config.AutoWaterSpiritProgressionUpgradeToggle = Value
        if Value then startAutoWaterSpiritProgressionUpgrade() end
        saveConfig()
    end
})

Upgrade2:AddToggle("AutoWindSpiritProgressionUpgradeToggle", {
    Text = "Auto Wind Spirit Progression Upgrade",
    Default = config.AutoWindSpiritProgressionUpgradeToggle or false,
    Tooltip = "Automatically upgrades wind spirit progression.",
    Callback = function(Value)
        config.AutoWindSpiritProgressionUpgradeToggle = Value
        if Value then startAutoWindSpiritProgressionUpgrade() end
        saveConfig()
    end
})

Upgrade2:AddToggle("AutoFireSpiritProgressionUpgradeToggle", {
    Text = "Auto Fire Spirit Progression Upgrade",
    Default = config.AutoFireSpiritProgressionUpgradeToggle or false,
    Tooltip = "Automatically upgrades fire spirit progression.",
    Callback = function(Value)
        config.AutoFireSpiritProgressionUpgradeToggle = Value
        if Value then startAutoFireSpiritProgressionUpgrade() end
        saveConfig()
    end
})

Upgrade2:AddToggle("AutoChakraProgressionUpgradeToggle", {
    Text = "Auto Chakra Progression Upgrade",
    Default = autoChakraProgressionUpgradeEnabled,
    Tooltip = "Automatically upgrades chakra progression.",
    Callback = function(Value)
        autoChakraProgressionUpgradeEnabled = Value
        config.AutoChakraProgressionUpgradeToggle = Value
        if Value then startAutoChakraProgressionUpgrade() end
        saveConfig()
    end
})

Upgrade2:AddToggle("AutoSpiritualUpgradeToggle", {
    Text = "Auto Spiritual Upgrade",
    Default = autoSpiritualUpgradeEnabled,
    Tooltip = "Automatically unlocks and upgrades spiritual upgrade.",
    Callback = function(Value)
        autoSpiritualUpgradeEnabled = Value
        config.AutoSpiritualUpgradeToggle = Value
        saveConfig()
        if Value then startAutoSpiritualUpgrade() end
    end
})



UnloadGroupbox:AddToggle("AutoHideUIToggle", {
    Text = "Auto Hide UI",
    Default = autoHideUIEnabled,
    Tooltip = "Automatically hide the UI and disable custom cursor on script load",
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
UnloadGroupbox:AddToggle("MutePetSoundsToggle", {
    Text = "Mute Pet Sounds",
    Default = mutePetSoundsEnabled,
    Callback = function(Value)
        mutePetSoundsEnabled = Value
        config.MutePetSoundsToggle = Value
        applyMutePetSoundsState()
        saveConfig()
    end
})

-- UI Settings
UnloadGroupbox:AddToggle("DisableNotificationsToggle", {
    Text = "Disable Notifications",
    Default = disableNotificationsEnabled,
    Callback = function(Value)
        disableNotificationsEnabled = Value
        config.DisableNotificationsToggle = Value
        applyNotificationsState()
        saveConfig()
    end
})

UnloadGroupbox:AddToggle("FPSBoostToggle", {
    Text = "FPS Boost (Lower Graphics)",
    Default = fpsBoostEnabled,
    Callback = function(Value)
        fpsBoostEnabled = Value
        config.FPSBoostToggle = Value
        applyFPSBoostState()
        saveConfig()
    end
})


RedeemGroupbox:AddToggle("AutoRedeemCodesToggle", {
    Text = "Auto Redeem All Codes",
    Default = autoRedeemCodesEnabled,
    Callback = function(Value)
        autoRedeemCodesEnabled = Value
        if Value then
            task.spawn(redeemAllCodes)
        end
    end
})


UnloadGroupbox:AddButton("Unload Seisen Hub", function()
    getgenv().SeisenHubRunning = false
    isAuraEnabled = false
    fastKillAuraEnabled = false
    slowKillAuraEnabled = false
    autoRankEnabled = false
    autoAvatarLevelingEnabled = false
    autoAcceptAllQuestsEnabled = false
    autoRollDragonRaceEnabled = false
    autoRollSaiyanEvolutionEnabled = false
    autoRollEnabled = false
    autoDeleteEnabled = false
    autoClaimAchievementsEnabled = false
    autoRollSwordsEnabled = false
    autoRollPirateCrewEnabled = false
    isAutoTimeRewardEnabled = false
    isAutoDailyChestEnabled = false
    isAutoVipChestEnabled = false
    isAutoGroupChestEnabled = false
    isAutoPremiumChestEnabled = false
    autoUpgradeEnabled = false
    autoEnterDungeon = false
    autoHakiUpgradeEnabled = false
    autoRollDemonFruitsEnabled = false
    autoAttackRangeUpgradeEnabled = false
    autoAvatarLevelingEnabled = false
    autoSpiritualPressureUpgradeEnabled = false
    selectedStat = false
    autoRollZanpakutoEnabledfalse = false
    autoCursedProgressionUpgradeEnabled = false
    autoChakraProgressionUpgradeEnabled = false
    autoSoloHunterRankEnabled = false
    autoReawakeningProgressionUpgradeEnabled = false
    autoMonarchProgressionUpgradeEnabled = false
    autoRollCursesEnabled = false
    autoObeliskEnabled = false
    selectedObeliskType = false
    selectedGachaRarities = false
    autoRollDemonArtsEnabled = false
    autoDungeonEnabled = false
    autoDungeonEnabled = false
    autoRollPowerEyesEnabled = false
    autoRollReiatsuColorEnabled = false
    autoSpiritualUpgradeEnabled = false
    autoPrestigeEnabled = false
    autoPsychicMayhemEnabled = false
    local argsOff = {
        [1] = {
            ["Value"] = false,
            ["Path"] = { "Settings", "Is_Auto_Clicker" },
            ["Action"] = "Settings",
        }
    }
    pcall(function()
        ToServer:FireServer(unpack(argsOff))
    end)

    if mutePetSoundsEnabled then
        local audioFolder = ReplicatedStorage:FindFirstChild("Audio")
        if audioFolder then
            local petSounds = {"Pets_Appearing_Sound", "Pets_Drumroll", "Loot"}
            for _, soundName in ipairs(petSounds) do
                local sound = audioFolder:FindFirstChild(soundName)
                if sound and sound:IsA("Sound") then
                    sound.Volume = originalVolumes[soundName] or 0.5
                end
            end
            local mergeFolder = audioFolder:FindFirstChild("Merge")
            if mergeFolder then
                local mergeSounds = {"PetsAppearingSound", "Drumroll", "ChestOpen"}
                for _, soundName in ipairs(mergeSounds) do
                    local sound = mergeFolder:FindFirstChild(soundName)
                    if sound and sound:IsA("Sound") then
                        sound.Volume = originalVolumes[soundName] or 0.5
                    end
                end
            end
        end
    end

    if disableNotificationsEnabled then
        local playerGui = ReplicatedStorage:FindFirstChild("PlayerGui")
        if playerGui then
            local notifications = playerGui:FindFirstChild("Notifications")
            if notifications then
                if notifications:IsA("ScreenGui") or notifications:IsA("BillboardGui") or notifications:IsA("SurfaceGui") then
                    notifications.Enabled = true
                elseif notifications:IsA("GuiObject") then
                    notifications.Visible = true
                end
            end
        end
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

    if getgenv().SeisenHubConnections then
        for _, conn in ipairs(getgenv().SeisenHubConnections) do
            pcall(function() conn:Disconnect() end)
        end
        getgenv().SeisenHubConnections = nil
    end

    -- Disable FPS boost and restore original settings
    if wasFPSBoostEnabled then
        disableFPSBoost()
    end

    getgenv().SeisenHubUI = nil
    getgenv().SeisenHubLoaded = nil
    getgenv().SeisenHubRunning = nil
    getgenv().SeisenHubConfig = nil
end)

task.defer(function()
    repeat task.wait() until Library.Flags
    for flag, value in pairs(config) do
        if Library.Flags[flag] then
            pcall(function()
                Library.Flags[flag]:Set(value)
            end)
        end
    end

    if disableNotificationsEnabled then
        local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local notifications = playerGui:FindFirstChild("Notifications")
            if notifications then
                if notifications:IsA("ScreenGui") or notifications:IsA("BillboardGui") or notifications:IsA("SurfaceGui") then
                    notifications.Enabled = false
                elseif notifications:IsA("GuiObject") then
                    notifications.Visible = false
                end
            end
        end
    end

    if mutePetSoundsEnabled then
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
end)
