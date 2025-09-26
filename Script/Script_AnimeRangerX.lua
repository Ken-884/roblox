
-- Luarmor runtime key check (kicks if expired/invalid)
local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
api.script_id = "155c15b02119f3bce3a806a2336bfe80" -- your script id or project id

local script_key = rawget(_G, "script_key") or getgenv().script_key or getgenv().LUARMOR_KEY
local player = game.Players.LocalPlayer
if not script_key or #script_key < 32 then
    player:Kick("No or invalid Luarmor key provided.")
    return
end

local status = api.check_key(script_key)
if status.code == "KEY_VALID" then
    -- continue script
elseif status.code == "KEY_EXPIRED" then
    player:Kick("Your Luarmor key is expired. Please get a new key from the checkpoint.")
    return
else
    player:Kick("Key check failed: " .. tostring(status.message or "Unknown error") .. " Code: " .. tostring(status.code or "?"))
    return
end




-- ...existing code...

game.StarterGui:SetCore("SendNotification", {
    Title = "Seisen Hub";
    Text = "Anime Ranger X Script Loaded";
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
    Footer = "Anime Ranger X",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Icon = 125926861378074,
    Center = true,
    AutoShow = true,
    ShowCustomCursor = true
})

-- =====================
-- Ball Circle Config & Defaults (top of file)
-- =====================
local configFolder = "SeisenHub"
local configFile = configFolder .. "/seisen_hub_arx.txt"
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

local autoHideUIEnabled = config.AutoHideUIEnabled or false

local function saveConfig()
    config.AutoHideUIEnabled = autoHideUIEnabled
    writefile(configFile, HttpService:JSONEncode(config))
end

-- Debug function to show deployed units and cooldowns
local function debugDeployedUnits()
    local player = game:GetService("Players").LocalPlayer
    local deployedUnits = {}
    
    print("🔍 SCANNING FOR DEPLOYED UNITS:")
    for _, child in pairs(player:GetChildren()) do
        if child.Name:find(" / Send CD") then
            local unitTag = child.Name:gsub(" / Send CD", "")
            local cooldown = child.Value or 0
            deployedUnits[unitTag] = cooldown
            print(string.format("📍 Found: %s (Tag: %s, Cooldown: %.1fs)", child.Name, unitTag, cooldown))
        end
    end
    
    if next(deployedUnits) == nil then
        print("❌ No deployed units found with Send CD tags")
    else
        print(string.format("✅ Found %d deployed units", #deployedUnits))
    end
    
    return deployedUnits
end

-- Make debug function globally accessible
getgenv().debugDeployedUnits = debugDeployedUnits

local MainTab = Window:AddTab("Main", "atom")
local MainGroup = MainTab:AddLeftGroupbox("Automation", "shell")
local AutoSummonGroup = MainTab:AddRightGroupbox("Auto Summon", "dice")
local AutoSellGroup = MainTab:AddRightGroupbox("Auto Sell", "money")
local AutoClaimGroup = MainTab:AddLeftGroupbox("Auto Claim", "gift")
local AcceptQuest = MainTab:AddRightGroupbox("Accept Quest", "check")


local PlayTab = Window:AddTab("Stage", "gamepad")
local StoryGroup = PlayTab:AddLeftGroupbox("Story Mode", "book-alert")
local RangerGroup = PlayTab:AddLeftGroupbox("Ranger Mode", "bow-arrow")
local RaidGroup = PlayTab:AddRightGroupbox("Raid Mode", "shield")
local ChalGroup = PlayTab:AddRightGroupbox("Challenge Mode", "trophy")


local LobbyTab = Window:AddTab("Lobby", "airplay")
local AutoPlay = LobbyTab:AddLeftGroupbox("Auto Event", "play")
local Enter = LobbyTab:AddLeftGroupbox("Enter Game Mode", "joystick")
local traitGroup = LobbyTab:AddLeftGroupbox("Trait Reroll", "star")
local MerchantShopGroup = LobbyTab:AddRightGroupbox("Merchant Shop", "store")
local RaidShop = LobbyTab:AddRightGroupbox("Raid Shop", "shopping-cart")
local RaidShop2Group = LobbyTab:AddRightGroupbox("Raid Shop 2", "shopping-cart")
local RiftStormShopGroup = LobbyTab:AddRightGroupbox("Rift Storm Exchange", "activity")
local FallEventExchangeGroup = LobbyTab:AddRightGroupbox("Fall Event Exchange", "leaf")

local MacroTab = Window:AddTab("Macro", "keyboard")

local SettingsTab = Window:AddTab("Settings", "settings")
local UISettingsGroup = SettingsTab:AddLeftGroupbox("UI Customization", "paintbrush")
local WebhookGroup = SettingsTab:AddRightGroupbox("Webhook Settings", "link")
local InfoGroup = SettingsTab:AddRightGroupbox("Script Information", "info")

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenHub")
ThemeManager:ApplyToTab(SettingsTab)

InfoGroup:AddLabel("Script by: Seisen")
InfoGroup:AddLabel("Version: 2.0.0")
InfoGroup:AddLabel("Game: Anime Ranger X")

InfoGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/F4sAf6z8Ph")
    print("Copied Discord Invite!")
end)


-- Mobile detection and UI adjustments
if Library.IsMobile then
    InfoGroup:AddLabel("📱 Mobile Device Detected")
    InfoGroup:AddLabel("UI optimized for mobile")
else
    InfoGroup:AddLabel("🖥️ Desktop Device Detected")
end

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

-- Main Feature - Enhanced Auto Deploy with Cooldown Detection
MainGroup:AddToggle("AutoDeployUnits", {
    Text = "Auto Deploy Units",
    Default = config.AutoDeployUnitsToggle or false,
    Tooltip = "Automatically deploy all units with smart cooldown detection.",
    Callback = function(value)
        if value then
            autoDeployEnabled = true
            config.AutoDeployUnitsToggle = true
            saveConfig()
            if autoDeployConnection then autoDeployConnection:Disconnect() end
            local unitCooldowns = {}
            
            -- Enhanced deployment function with cooldown detection
            local function checkUnitCooldown(unitName, unitTag)
                local player = game:GetService("Players").LocalPlayer
                local cooldownTag = unitTag .. " / Send CD"
                
                -- Check if the cooldown tag exists
                local cooldownValue = player:FindFirstChild(cooldownTag)
                if cooldownValue then
                    local cd = cooldownValue.Value or 0
                    print(string.format("🕐 Unit %s cooldown: %.1fs", unitName, cd))
                    return cd > 0, cd
                end
                return false, 0
            end
            
            -- Get all deployed units and their tags
            local function getDeployedUnits()
                local deployedUnits = {}
                local player = game:GetService("Players").LocalPlayer
                
                -- Scan for Send CD tags to identify deployed units
                for _, child in pairs(player:GetChildren()) do
                    if child.Name:find(" / Send CD") then
                        local unitTag = child.Name:gsub(" / Send CD", "")
                        local cooldown = child.Value or 0
                        deployedUnits[unitTag] = {
                            cooldown = cooldown,
                            isOnCooldown = cooldown > 0
                        }
                        print(string.format("📍 Detected deployed unit: %s (CD: %.1fs)", unitTag, cooldown))
                    end
                end
                return deployedUnits
            end
            
            autoDeployConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local playerData = ReplicatedStorage:FindFirstChild("Player_Data")
                if not playerData then return end
                
                -- Get currently deployed units
                local deployedUnits = getDeployedUnits()
                
                for _, playerObj in ipairs(playerData:GetChildren()) do
                    local collection = playerObj:FindFirstChild("Collection")
                    if not collection then continue end
                    local localUnitsFolder = game:GetService("Players").LocalPlayer:FindFirstChild("UnitsFolder")
                    if not localUnitsFolder then continue end

                    for _, unit in ipairs(collection:GetChildren()) do
                        local localUnit = localUnitsFolder:FindFirstChild(unit.Name)
                        if localUnit then
                            local unitLevel = unit:FindFirstChild("Level")
                            local localUnitLevel = localUnit:FindFirstChild("Level")
                            local unitTag = unit:FindFirstChild("Tag")
                            
                            if unitLevel and localUnitLevel and unitLevel.Value == localUnitLevel.Value and unitTag then
                                local tagValue = unitTag.Value
                                
                                -- Check if unit is already deployed and on cooldown
                                local deployedInfo = deployedUnits[tagValue]
                                local isOnCooldown = false
                                local cooldownTime = 0
                                
                                if deployedInfo then
                                    isOnCooldown = deployedInfo.isOnCooldown
                                    cooldownTime = deployedInfo.cooldown
                                end
                                
                                -- Only deploy if not on cooldown
                                if not isOnCooldown then
                                    local args = {
                                        [1] = unit,
                                        [2] = true
                                    }
                                    local remote = ReplicatedStorage:FindFirstChild("Remote")
                                    if remote then
                                        local server = remote:FindFirstChild("Server")
                                        if server then
                                            local units = server:FindFirstChild("Units")
                                            if units then
                                                local deployment = units:FindFirstChild("Deployment")
                                                if deployment then
                                                    print(string.format("🚀 Deploying unit: %s (Tag: %s)", unit.Name, tagValue))
                                                    deployment:FireServer(unpack(args))
                                                    
                                                    -- Track deployment
                                                    unitCooldowns[unit.Name] = {
                                                        tag = tagValue,
                                                        deployTime = tick()
                                                    }
                                                end
                                            end
                                        end
                                    end
                                else
                                    -- Unit is on cooldown, skip deployment
                                    if cooldownTime > 0 then
                                        print(string.format("⏰ Skipping %s - on cooldown for %.1fs", unit.Name, cooldownTime))
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end)
        else
            autoDeployEnabled = false
            config.AutoDeployUnitsToggle = false
            saveConfig()
            if autoDeployConnection then
                autoDeployConnection:Disconnect()
                autoDeployConnection = nil
            end
        end
    end
})

-- Auto start AutoDeployUnits ONLY if enabled on reload with enhanced cooldown detection
if config.AutoDeployUnitsToggle then
    autoDeployEnabled = true
    if autoDeployConnection then autoDeployConnection:Disconnect() end
    local unitCooldowns = {}
    
    -- Enhanced deployment function with cooldown detection
    local function checkUnitCooldown(unitName, unitTag)
        local player = game:GetService("Players").LocalPlayer
        local cooldownTag = unitTag .. " / Send CD"
        
        -- Check if the cooldown tag exists
        local cooldownValue = player:FindFirstChild(cooldownTag)
        if cooldownValue then
            local cd = cooldownValue.Value or 0
            return cd > 0, cd
        end
        return false, 0
    end
    
    -- Get all deployed units and their tags
    local function getDeployedUnits()
        local deployedUnits = {}
        local player = game:GetService("Players").LocalPlayer
        
        -- Scan for Send CD tags to identify deployed units
        for _, child in pairs(player:GetChildren()) do
            if child.Name:find(" / Send CD") then
                local unitTag = child.Name:gsub(" / Send CD", "")
                local cooldown = child.Value or 0
                deployedUnits[unitTag] = {
                    cooldown = cooldown,
                    isOnCooldown = cooldown > 0
                }
            end
        end
        return deployedUnits
    end
    
    autoDeployConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local playerData = ReplicatedStorage:FindFirstChild("Player_Data")
        if not playerData then return end
        
        -- Get currently deployed units
        local deployedUnits = getDeployedUnits()
        
        for _, playerObj in ipairs(playerData:GetChildren()) do
            local collection = playerObj:FindFirstChild("Collection")
            if not collection then continue end
            local localUnitsFolder = game:GetService("Players").LocalPlayer:FindFirstChild("UnitsFolder")
            if not localUnitsFolder then continue end

            for _, unit in ipairs(collection:GetChildren()) do
                local localUnit = localUnitsFolder:FindFirstChild(unit.Name)
                if localUnit then
                    local unitLevel = unit:FindFirstChild("Level")
                    local localUnitLevel = localUnit:FindFirstChild("Level")
                    local unitTag = unit:FindFirstChild("Tag")
                    
                    if unitLevel and localUnitLevel and unitLevel.Value == localUnitLevel.Value and unitTag then
                        local tagValue = unitTag.Value
                        
                        -- Check if unit is already deployed and on cooldown
                        local deployedInfo = deployedUnits[tagValue]
                        local isOnCooldown = false
                        
                        if deployedInfo then
                            isOnCooldown = deployedInfo.isOnCooldown
                        end
                        
                        -- Only deploy if not on cooldown
                        if not isOnCooldown then
                            local args = {
                                [1] = unit,
                                [2] = true
                            }
                            local remote = ReplicatedStorage:FindFirstChild("Remote")
                            if remote then
                                local server = remote:FindFirstChild("Server")
                                if server then
                                    local units = server:FindFirstChild("Units")
                                    if units then
                                        local deployment = units:FindFirstChild("Deployment")
                                        if deployment then
                                            deployment:FireServer(unpack(args))
                                            
                                            -- Track deployment
                                            unitCooldowns[unit.Name] = {
                                                tag = tagValue,
                                                deployTime = tick()
                                            }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end)
end


MainGroup:AddToggle("AutoAutoVote", {
    Text = "Auto Vote",
    Default = config.AutoAutoVote or false,
    Tooltip = "Automatically votes.",
    Callback = function(value)
        if value then
            autoAutoVoteEnabled = true
            config.AutoAutoVote = true
            saveConfig()
            if autoAutoVoteConnection then autoAutoVoteConnection:Disconnect() end
            autoAutoVoteConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local player = game:GetService("Players").LocalPlayer
                local playerGui = player:FindFirstChild("PlayerGui")
                local hud = playerGui and playerGui:FindFirstChild("HUD")
                local inGame = hud and hud:FindFirstChild("InGame")
                local votePlaying = inGame and inGame:FindFirstChild("VotePlaying")
                if votePlaying and votePlaying.Visible then
                    local args = {}
                    local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Server", 9e9):WaitForChild("OnGame", 9e9):WaitForChild("Voting", 9e9):WaitForChild("VotePlaying", 9e9)
                    remote:FireServer(unpack(args))
                end
                task.wait(3)
            end)
        else
            autoAutoVoteEnabled = false
            config.AutoAutoVote = false
            saveConfig()
            if autoAutoVoteConnection then
                autoAutoVoteConnection:Disconnect()
                autoAutoVoteConnection = nil
            end
        end
    end
})

-- Auto start AutoAutoVote ONLY if enabled on reload
if config.AutoAutoVote then
    autoAutoVoteEnabled = true
    if autoAutoVoteConnection then autoAutoVoteConnection:Disconnect() end
    autoAutoVoteConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local player = game:GetService("Players").LocalPlayer
        local playerGui = player:FindFirstChild("PlayerGui")
        local hud = playerGui and playerGui:FindFirstChild("HUD")
        local inGame = hud and hud:FindFirstChild("InGame")
        local votePlaying = inGame and inGame:FindFirstChild("VotePlaying")
        if votePlaying and votePlaying.Visible then
            local args = {}
            local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Server", 9e9):WaitForChild("OnGame", 9e9):WaitForChild("Voting", 9e9):WaitForChild("VotePlaying", 9e9)
            remote:FireServer(unpack(args))
        end
        task.wait(3)
    end)
end

MainGroup:AddToggle("AutoUpgradeMaxYen", {
    Text = "Auto Upgrade Max Yen",
    Default = config.AutoUpgradeMaxYen or false,
    Tooltip = "Automatically upgrades Maximum Yen.",
    Callback = function(value)
        if value then
            autoUpgradeMaxYenEnabled = true
            config.AutoUpgradeMaxYen = true
            saveConfig()
            if autoUpgradeMaxYenConnection then autoUpgradeMaxYenConnection:Disconnect() end
            autoUpgradeMaxYenConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local args = { [1] = "MaximumYen" }
                local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Server", 9e9):WaitForChild("Gameplay", 9e9):WaitForChild("StatsManager", 9e9)
                remote:FireServer(unpack(args))
                task.wait(2)
            end)
        else
            autoUpgradeMaxYenEnabled = false
            config.AutoUpgradeMaxYen = false
            saveConfig()
            if autoUpgradeMaxYenConnection then
                autoUpgradeMaxYenConnection:Disconnect()
                autoUpgradeMaxYenConnection = nil
            end
        end
    end
})

-- Auto start AutoUpgradeMaxYen ONLY if enabled on reload
if config.AutoUpgradeMaxYen then
    autoUpgradeMaxYenEnabled = true
    if autoUpgradeMaxYenConnection then autoUpgradeMaxYenConnection:Disconnect() end
    autoUpgradeMaxYenConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local args = { [1] = "MaximumYen" }
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Server", 9e9):WaitForChild("Gameplay", 9e9):WaitForChild("StatsManager", 9e9)
        remote:FireServer(unpack(args))
        task.wait(2)
    end)
end

MainGroup:AddToggle("AutoUpgradeUnitsFolder", {
    Text = "Auto Upgrade All Units",
    Default = config.AutoUpgradeUnitsFolderEnabled or false,
    Tooltip = "Automatically upgrades everyone",
    Callback = function(value)
        if value then
            autoUpgradeUnitsFolderEnabled = true
            config.AutoUpgradeUnitsFolderEnabled = true
            saveConfig()
            if autoUpgradeUnitsFolderConnection then autoUpgradeUnitsFolderConnection:Disconnect() end
            autoUpgradeUnitsFolderConnection = game:GetService("RunService").Heartbeat:Connect(function()
                for _, playerObj in ipairs(game:GetService("Players"):GetPlayers()) do
                    local unitsFolder = playerObj:FindFirstChild("UnitsFolder")
                    if not unitsFolder then continue end
                    for _, unit in ipairs(unitsFolder:GetChildren()) do
                        local args = { [1] = unit }
                        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Server", 9e9):WaitForChild("Units", 9e9):WaitForChild("Upgrade", 9e9)
                        remote:FireServer(unpack(args))
                    end
                end
                task.wait(5)
            end)
        else
            autoUpgradeUnitsFolderEnabled = false
            config.AutoUpgradeUnitsFolderEnabled = false
            saveConfig()
            if autoUpgradeUnitsFolderConnection then
                autoUpgradeUnitsFolderConnection:Disconnect()
                autoUpgradeUnitsFolderConnection = nil
            end
        end
    end
})

-- Auto start AutoUpgradeUnitsFolder ONLY if enabled on reload
if config.AutoUpgradeUnitsFolderEnabled then
    autoUpgradeUnitsFolderEnabled = true
    if autoUpgradeUnitsFolderConnection then autoUpgradeUnitsFolderConnection:Disconnect() end
    autoUpgradeUnitsFolderConnection = game:GetService("RunService").Heartbeat:Connect(function()
        for _, playerObj in ipairs(game:GetService("Players"):GetPlayers()) do
            local unitsFolder = playerObj:FindFirstChild("UnitsFolder")
            if not unitsFolder then continue end
            for _, unit in ipairs(unitsFolder:GetChildren()) do
                local args = { [1] = unit }
                local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Server", 9e9):WaitForChild("Units", 9e9):WaitForChild("Upgrade", 9e9)
                remote:FireServer(unpack(args))
            end
        end
        task.wait(5)
    end)
end

MainGroup:AddToggle("AutoNextActionToggle", {
    Text = "Auto Next/Replay/Leave",
    Default = config.AutoNextActionEnabled or false,
    Tooltip = "Auto Next/Replay/Leave",
    Callback = function(value)
        if value then
            autoNextActionEnabled = true
            config.AutoNextActionEnabled = true
            saveConfig()
            StartAutoNextAction()
        else
            autoNextActionEnabled = false
            config.AutoNextActionEnabled = false
            saveConfig()
            StopAutoNextAction()
        end
    end
})

local autoNextRemotes = {
    ["Next"] = game:GetService("ReplicatedStorage").Remote.Server.OnGame.Voting.VoteNext,
    ["Replay"] = game:GetService("ReplicatedStorage").Remote.Server.OnGame.Voting.VoteRetry,
    ["Leave"] = game:GetService("ReplicatedStorage").Remote.Server.OnGame.Voting.VotePlaying,
}

function StartAutoNextAction()
    if autoNextActionConnection then autoNextActionConnection:Disconnect() end
    autoNextActionConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local player = game:GetService("Players").LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui", 5)
        local rewardsUI = playerGui and playerGui:FindFirstChild("RewardsUI")
        if rewardsUI and rewardsUI.Enabled then
            local remote = autoNextRemotes[autoNextAction]
            if remote then
                remote:FireServer()
            end
        end
        task.wait(3)
    end)
end

function StopAutoNextAction()
    if autoNextActionConnection then
        autoNextActionConnection:Disconnect()
        autoNextActionConnection = nil
    end
end

MainGroup:AddDropdown("AutoNextActionDropdown", {
    Text = "Auto Next Action",
    Values = {"Next", "Replay", "Leave"},
    Default = config.AutoNextAction or "Next",
    Tooltip = "Select which action to auto-fire when RewardsUI is visible.",
    Callback = function(selected)
        autoNextAction = selected
        config.AutoNextAction = selected
        saveConfig()
    end
})

-- Auto start for AutoNextActionToggle and AutoNextActionDropdown
if config.AutoNextActionEnabled then
    autoNextActionEnabled = true
    -- Set dropdown value before starting automation to avoid nil errors
    autoNextAction = config.AutoNextAction or "Next"
    -- Set the toggle UI state
    if MainGroup.Flags and MainGroup.Flags.AutoNextActionToggle then
        MainGroup.Flags.AutoNextActionToggle:Set(true)
    end
    -- Set the dropdown UI state
    if MainGroup.Flags and MainGroup.Flags.AutoNextActionDropdown then
        MainGroup.Flags.AutoNextActionDropdown:SetValue(autoNextAction)
    end
    StartAutoNextAction()
end



local gameSpeedValue = config.GameSpeedDropdown or "1"
local gameSpeedDropdownObj = MainGroup:AddDropdown("GameSpeedDropdown", {
    Text = "Game Speed",
    Values = {"1", "2"},
    Default = gameSpeedValue,
    Tooltip = "Select your game speed.",
    Callback = function(selected)
        gameSpeedValue = selected
        config.GameSpeedDropdown = selected
        saveConfig()
        if type(SetGameSpeed) == "function" then
            SetGameSpeed(selected)
        else
            warn("SetGameSpeed function is missing or not defined!")
        end
    end
})

-- Ensure dropdown displays saved value after reload
if gameSpeedDropdownObj and type(gameSpeedDropdownObj.SetValue) == "function" then
    gameSpeedDropdownObj:SetValue(gameSpeedValue)
end

function SetGameSpeed(value)
    gameSpeedValue = value
    local speedValue = tonumber(value)
    if speedValue then
        local args = { [1] = speedValue }
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("SpeedGamepass", 9e9)
        remote:FireServer(unpack(args))
        task.wait(0.5)
    end
end

-- Auto start GameSpeed on reload
if gameSpeedValue then
    SetGameSpeed(gameSpeedValue)
end

-- Debug button for deployment system
MainGroup:AddButton("Debug Deployed Units", function()
    print("🔍 DEBUGGING DEPLOYED UNITS:")
    local deployedUnits = debugDeployedUnits()
    
    local player = game:GetService("Players").LocalPlayer
    print("\n📋 ALL PLAYER CHILDREN (looking for Send CD tags):")
    local cdCount = 0
    for _, child in pairs(player:GetChildren()) do
        if child.Name:find("Send CD") or child.Name:find("/") then
            print(string.format("  🏷️ %s = %s", child.Name, tostring(child.Value or "N/A")))
            cdCount = cdCount + 1
        end
    end
    
    if cdCount == 0 then
        print("❌ No Send CD tags found in player children")
    else
        print(string.format("✅ Found %d potential cooldown tags", cdCount))
    end
    
    -- Also check collection units and their tags
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local playerData = ReplicatedStorage:FindFirstChild("Player_Data")
    if playerData then
        for _, playerObj in ipairs(playerData:GetChildren()) do
            local collection = playerObj:FindFirstChild("Collection")
            if collection then
                print(string.format("\n📦 COLLECTION UNITS (Player: %s):", playerObj.Name))
                for _, unit in ipairs(collection:GetChildren()) do
                    local unitTag = unit:FindFirstChild("Tag")
                    local tagValue = unitTag and unitTag.Value or "NO TAG"
                    print(string.format("  🎯 %s - Tag: %s", unit.Name, tagValue))
                end
                break
            end
        end
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Debug Complete";
        Text = string.format("Found %d cooldown tags - check console", cdCount);
        Duration = 5;
    })
end)

AutoClaimGroup:AddToggle("AutoClaimBattlepass", {
    Text = "Auto Claim Battlepass",
    Default = config.AutoClaimBattlepass or false,
    Tooltip = "Automatically claim all Battlepass rewards.",
    Callback = function(enabled)
        autoClaimBattlepassEnabled = enabled
        config.AutoClaimBattlepass = enabled
        saveConfig()
        if enabled then
            if autoClaimBattlepassConnection then autoClaimBattlepassConnection:Disconnect() end
            autoClaimBattlepassConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoClaimBattlepassEnabled then
                    local args = { [1] = "Claim All" }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Events", 9e9):WaitForChild("ClaimBp", 9e9):FireServer(unpack(args))
                    task.wait(5)
                end
            end)
        else
            if autoClaimBattlepassConnection then
                autoClaimBattlepassConnection:Disconnect()
                autoClaimBattlepassConnection = nil
            end
        end
    end
})

AutoClaimGroup:AddToggle("AutoClaimSwarmBattlepass", {
    Text = "Auto Claim Swarm Battlepass",
    Default = config.AutoClaimSwarmBattlepass or false,
    Tooltip = "Automatically claim all Swarm Battlepass rewards.",
    Callback = function(enabled)
        autoClaimSwarmBattlepassEnabled = enabled
        config.AutoClaimSwarmBattlepass = enabled
        saveConfig()
        if enabled then
            if autoClaimSwarmBattlepassConnection then autoClaimSwarmBattlepassConnection:Disconnect() end
            autoClaimSwarmBattlepassConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoClaimSwarmBattlepassEnabled then
                    local args = { [1] = "Claim All" }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Events", 9e9):WaitForChild("EventClaimBp", 9e9):FireServer(unpack(args))
                    task.wait(5)
                end
            end)
        else
            if autoClaimSwarmBattlepassConnection then
                autoClaimSwarmBattlepassConnection:Disconnect()
                autoClaimSwarmBattlepassConnection = nil
            end
        end
    end
})

AutoClaimGroup:AddToggle("AutoClaimAllQuest", {
    Text = "Auto Claim All Quest",
    Default = config.AutoClaimAllQuest or false,
    Tooltip = "Automatically claim all quest rewards.",
    Callback = function(enabled)
        autoClaimAllQuestEnabled = enabled
        config.AutoClaimAllQuest = enabled
        saveConfig()
        if enabled then
            if autoClaimAllQuestConnection then autoClaimAllQuestConnection:Disconnect() end
            autoClaimAllQuestConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoClaimAllQuestEnabled then
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local playerData = ReplicatedStorage:WaitForChild("Player_Data", 9e9):WaitForChild("seisen119", 9e9)
                    local dailyQuest = playerData:WaitForChild("DailyQuest", 9e9):WaitForChild("Summon Ranger II", 9e9)
                    local args = { [1] = "ClaimAll", [2] = dailyQuest }
                    ReplicatedStorage:WaitForChild("Remote", 9e9):WaitForChild("Server", 9e9):WaitForChild("Gameplay", 9e9):WaitForChild("QuestEvent", 9e9):FireServer(unpack(args))
                    task.wait(5)
                end
            end)
        else
            if autoClaimAllQuestConnection then
                autoClaimAllQuestConnection:Disconnect()
                autoClaimAllQuestConnection = nil
            end
        end
    end
})

-- Auto start for AutoClaimBattlepass
if config.AutoClaimBattlepass then
    autoClaimBattlepassEnabled = true
    if autoClaimBattlepassConnection then autoClaimBattlepassConnection:Disconnect() end
    autoClaimBattlepassConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if autoClaimBattlepassEnabled then
            local args = { [1] = "Claim All" }
            game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Events", 9e9):WaitForChild("ClaimBp", 9e9):FireServer(unpack(args))
            task.wait(5)
        end
    end)
end

-- Auto start for AutoClaimSwarmBattlepass
if config.AutoClaimSwarmBattlepass then
    autoClaimSwarmBattlepassEnabled = true
    if autoClaimSwarmBattlepassConnection then autoClaimSwarmBattlepassConnection:Disconnect() end
    autoClaimSwarmBattlepassConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if autoClaimSwarmBattlepassEnabled then
            local args = { [1] = "Claim All" }
            game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Events", 9e9):WaitForChild("EventClaimBp", 9e9):FireServer(unpack(args))
            task.wait(5)
        end
    end)
end

-- Auto start for AutoClaimAllQuest
if config.AutoClaimAllQuest then
    autoClaimAllQuestEnabled = true
    if autoClaimAllQuestConnection then autoClaimAllQuestConnection:Disconnect() end
    autoClaimAllQuestConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if autoClaimAllQuestEnabled then
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local playerData = ReplicatedStorage:WaitForChild("Player_Data", 9e9):WaitForChild("seisen119", 9e9)
            local dailyQuest = playerData:WaitForChild("DailyQuest", 9e9):WaitForChild("Summon Ranger II", 9e9)
            local args = { [1] = "ClaimAll", [2] = dailyQuest }
            ReplicatedStorage:WaitForChild("Remote", 9e9):WaitForChild("Server", 9e9):WaitForChild("Gameplay", 9e9):WaitForChild("QuestEvent", 9e9):FireServer(unpack(args))
            task.wait(5)
        end
    end)
end


local function summon(type)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                            :WaitForChild("Server", 9e9)
                            :WaitForChild("Gambling", 9e9)
                            :WaitForChild("UnitsGacha", 9e9)

    local autoSellTable = {}
    if autoSellRareEnabled then autoSellTable["Rare"] = true end
    if autoSellEpicEnabled then autoSellTable["Epic"] = true end
    if autoSellLegendaryEnabled then autoSellTable["Legendary"] = true end
    if autoSellShinyEnabled then autoSellTable["Shiny"] = true end
    if autoSellMyhicEnabled then autoSellTable["Mythic"] = true end

    local args = {
        [1] = type,
        [2] = "Standard",
        [3] = autoSellTable,
    }
    remote:FireServer(unpack(args))
end

local autoSummonRateup1xEnabled = false
local autoSummonRateup10xEnabled = false

local function summonRateup(type)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                              :WaitForChild("Server", 9e9)
                              :WaitForChild("Gambling", 9e9)
                              :WaitForChild("UnitsGacha", 9e9)
    local autoSellTable = {}
    if autoSellRareEnabled then autoSellTable["Rare"] = true end
    if autoSellEpicEnabled then autoSellTable["Epic"] = true end
    if autoSellLegendaryEnabled then autoSellTable["Legendary"] = true end
    if autoSellShinyEnabled then autoSellTable["Shiny"] = true end
    if autoSellMyhicEnabled then autoSellTable["Mythic"] = true end
    local args = {
        [1] = type,
        [2] = "Rateup",
        [3] = autoSellTable,
    }
    remote:FireServer(unpack(args))
end


AutoSummonGroup:AddToggle("AutoSummon1x", {
    Text = "Auto Summon 1x",
    Default = false,
    Callback = function(enabled)
        autoSummon1xEnabled = enabled
        if enabled then
            if autoSummon1xConnection then autoSummon1xConnection:Disconnect() end
            autoSummon1xConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoSummon1xEnabled then
                    summon("1x")
                    task.wait(0.05)
                end
            end)
        else
            if autoSummon1xConnection then
                autoSummon1xConnection:Disconnect()
                autoSummon1xConnection = nil
            end
        end
    end
})

AutoSummonGroup:AddToggle("AutoSummon10x", {
    Text = "Auto Summon 10x",
    Default = false,
    Callback = function(enabled)
        autoSummon10xEnabled = enabled
        if enabled then
            if autoSummon10xConnection then autoSummon10xConnection:Disconnect() end
            autoSummon10xConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoSummon10xEnabled then
                    summon("10x")
                    task.wait(0.05)
                end
            end)
        else
            if autoSummon10xConnection then
                autoSummon10xConnection:Disconnect()
                autoSummon10xConnection = nil
            end
        end
    end
})

AutoSummonGroup:AddToggle("AutoSummonRateup1xToggle", {
    Text = "Auto Rateup Summon x1",
    Default = false,
    Tooltip = "Automatically summon x1 on Rateup banner.",
    Callback = function(enabled)
        autoSummonRateup1xEnabled = enabled
        if enabled then
            if autoSummonRateup1xConnection then autoSummonRateup1xConnection:Disconnect() end
            autoSummonRateup1xConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoSummonRateup1xEnabled then
                    summonRateup("1x")
                    task.wait(0.05)
                end
            end)
        else
            if autoSummonRateup1xConnection then
                autoSummonRateup1xConnection:Disconnect()
                autoSummonRateup1xConnection = nil
            end
        end
    end
})

AutoSummonGroup:AddToggle("AutoSummonRateup10xToggle", {
    Text = "Auto Rateup Summon x10",
    Default = false,
    Tooltip = "Automatically summon x10 on Rateup banner.",
    Callback = function(enabled)
        autoSummonRateup10xEnabled = enabled
        if enabled then
            if autoSummonRateup10xConnection then autoSummonRateup10xConnection:Disconnect() end
            autoSummonRateup10xConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoSummonRateup10xEnabled then
                    summonRateup("10x")
                    task.wait(0.05)
                end
            end)
        else
            if autoSummonRateup10xConnection then
                autoSummonRateup10xConnection:Disconnect()
                autoSummonRateup10xConnection = nil
            end
        end
    end
})


-- Auto Sell toggles (Right Groupbox)
local autoSellOptions = {
    {key = "AutoSellRare", label = "Sell Auto Rare"},
    {key = "AutoSellEpic", label = "Sell Auto Epic"},
    {key = "AutoSellLegendary", label = "Sell Auto Legendary"},
    {key = "AutoSellShiny", label = "Sell Auto Shiny"},
    {key = "AutoSellMyhic", label = "Sell Auto Myhic"}
}

for _, opt in ipairs(autoSellOptions) do
    AutoSellGroup:AddToggle(opt.key, {
        Text = opt.label,
        Default = config[opt.key] or false,
        Callback = function(enabled)
            if opt.key == "AutoSellRare" then autoSellRareEnabled = enabled end
            if opt.key == "AutoSellEpic" then autoSellEpicEnabled = enabled end
            if opt.key == "AutoSellLegendary" then autoSellLegendaryEnabled = enabled end
            if opt.key == "AutoSellShiny" then autoSellShinyEnabled = enabled end
            if opt.key == "AutoSellMyhic" then autoSellMyhicEnabled = enabled end
            config[opt.key] = enabled
            saveConfig()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                                :WaitForChild("Server", 9e9)
                                :WaitForChild("Settings", 9e9)
                                :WaitForChild("Setting_Event", 9e9)
            remote:FireServer(opt.label, enabled)
        end
    })
end

-- Auto start/auto load for auto sell toggles
if config.AutoSellRare then
    autoSellRareEnabled = true
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
        :WaitForChild("Server", 9e9)
        :WaitForChild("Settings", 9e9)
        :WaitForChild("Setting_Event", 9e9)
    remote:FireServer("Sell Auto Rare", true)
end
if config.AutoSellEpic then
    autoSellEpicEnabled = true
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
        :WaitForChild("Server", 9e9)
        :WaitForChild("Settings", 9e9)
        :WaitForChild("Setting_Event", 9e9)
    remote:FireServer("Sell Auto Epic", true)
end
if config.AutoSellLegendary then
    autoSellLegendaryEnabled = true
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
        :WaitForChild("Server", 9e9)
        :WaitForChild("Settings", 9e9)
        :WaitForChild("Setting_Event", 9e9)
    remote:FireServer("Sell Auto Legendary", true)
end
if config.AutoSellShiny then
    autoSellShinyEnabled = true
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
        :WaitForChild("Server", 9e9)
        :WaitForChild("Settings", 9e9)
        :WaitForChild("Setting_Event", 9e9)
    remote:FireServer("Sell Auto Shiny", true)
end
if config.AutoSellMyhic then
    autoSellMyhicEnabled = true
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
        :WaitForChild("Server", 9e9)
        :WaitForChild("Settings", 9e9)
        :WaitForChild("Setting_Event", 9e9)
    remote:FireServer("Sell Auto Myhic", true)
end

-- Auto sell logic after summon (called inside summon/summonRateup functions)
local function autoSellUnits()
    local player = game:GetService("Players").LocalPlayer
    local unitsFolder = player:FindFirstChild("UnitsFolder")
    if unitsFolder then
        for _, unit in ipairs(unitsFolder:GetChildren()) do
            local rarity = unit:FindFirstChild("Rarity") and unit.Rarity.Value or nil
            if rarity then
                local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9)
                                :WaitForChild("Server", 9e9)
                                :WaitForChild("Units", 9e9)
                                :WaitForChild("Sell", 9e9)
                if autoSellRareEnabled and rarity == "Rare" then
                    remote:FireServer(unit)
                elseif autoSellEpicEnabled and rarity == "Epic" then
                    remote:FireServer(unit)
                elseif autoSellLegendaryEnabled and rarity == "Legendary" then
                    remote:FireServer(unit)
                elseif autoSellShinyEnabled and rarity == "Shiny" then
                    remote:FireServer(unit)
                elseif autoSellMyhicEnabled and rarity == "Mythic" then
                    remote:FireServer(unit)
                end
            end
        end
    end
end


-- Accept Quest Section

local questOptions = {
    {name = "Pucci", remote = "Pucci_MIH"},
    {name = "Dio", remote = "Dio_OverHeaven"},
    {name = "Aizen", remote = "AizenQuest"},
}
local questNames = {}
for _, q in ipairs(questOptions) do table.insert(questNames, q.name) end
local selectedQuest = questNames[1]
local autoQuestEnabled = false

AcceptQuest:AddDropdown("AutoQuestDropdown", {
    Text = "Select Quest",
    Values = questNames,
    Default = questNames[1],
    Callback = function(val)
        selectedQuest = val
    end
})

AcceptQuest:AddToggle("AutoQuestToggle", {
    Text = "Auto Quest",
    Default = false,
    Callback = function(enabled)
        autoQuestEnabled = enabled
        if enabled then
            spawn(function()
                while autoQuestEnabled do
                    for _, q in ipairs(questOptions) do
                        if q.name == selectedQuest then
                            game:GetService("ReplicatedStorage").Remote.Server.Quest.QuestLine:FireServer(q.remote)
                            break
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})


local worldInternalNames = {
    "OnePiece",
    "Namek",
    "DemonSlayer",
    "Naruto",
    "OPM",
    "TokyoGhoul",
    "JojoPart1",
    "BizzareRace",
    "SoulSociety",
    "ChainsawMan",
    "SAO",
    "DBZ2",
    "Berserk"
}
local worldDisplayNames = {
    OnePiece = "Voocha Village",
    Namek = "Green Planet",
    DemonSlayer = "Demon Forest",
    Naruto = "Leaf Village",
    OPM = "Z City",
    TokyoGhoul = "Ghoul City",
    JojoPart1 = "Night Colosseum",
    BizzareRace = "Bizzare Race",
    SoulSociety = "Spirit Realm",
    ChainsawMan = "The City",
    SAO = "Virtual Sword",
    DBZ2 = "Ruined Future City",
    Berserk = "Lake of Sacrifice"
}
local worlds = {}
for _, internal in ipairs(worldInternalNames) do
    table.insert(worlds, worldDisplayNames[internal])
end

local chapters = {}
local chapterDisplayNames = {}
local chapterInternalNames = {}
for _, internal in ipairs(worldInternalNames) do
    local display = worldDisplayNames[internal]
    chapterDisplayNames[display] = {}
    chapterInternalNames[display] = {}
    for i = 1, 10 do
        table.insert(chapterDisplayNames[display], "Chapter " .. i)
        table.insert(chapterInternalNames[display], internal .. "_Chapter" .. i)
    end
end

local selectedWorld = worlds[1]
local selectedWorldInternal = worldInternalNames[1]
local selectedChapter = chapterInternalNames[selectedWorld][1]

local function updateSelectedWorld(worldDisplay)
    selectedWorld = worldDisplay
    for internal, display in pairs(worldDisplayNames) do
        if display == worldDisplay then
            selectedWorldInternal = internal
            break
        end
    end
    selectedChapter = chapterInternalNames[selectedWorld][1]
end

local function updateSelectedChapter(chapterDisplay)
    local idx = nil
    for i, v in ipairs(chapterDisplayNames[selectedWorld]) do
        if v == chapterDisplay then idx = i break end
    end
    if idx then
        selectedChapter = chapterInternalNames[selectedWorld][idx]
    end
end

local function StartPlayRoom(selectedWorldInternal, selectedChapter)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                            :WaitForChild("Server", 9e9)
                            :WaitForChild("PlayRoom", 9e9)
                            :WaitForChild("Event", 9e9)

    remote:FireServer("Create")
    remote:FireServer("Change-World", {World = selectedWorldInternal})
    remote:FireServer("Change-Chapter", {Chapter = selectedChapter})
    remote:FireServer("Submit")
    remote:FireServer("Start")
end

local chapterDropdown = StoryGroup:AddDropdown("ChapterDropdown", {
    Text = "Select Chapter",
    Values = chapterDisplayNames[selectedWorld],
    Default = chapterDisplayNames[selectedWorld][1],
    Callback = function(chapterDisplay)
        updateSelectedChapter(chapterDisplay)
        saveConfig()
    end
})

StoryGroup:AddDropdown("WorldDropdown", {
    Text = "Select Stage",
    Values = worlds,
    Default = worlds[1],
    Callback = function(worldDisplay)
        updateSelectedWorld(worldDisplay)
        chapterDropdown:SetValues(chapterDisplayNames[selectedWorld])
        chapterDropdown:SetValue(chapterDisplayNames[selectedWorld][1])
        if chapterDropdown.Refresh then
            chapterDropdown:Refresh()
        end
        saveConfig()
    end
})

StoryGroup:AddButton("Start", function()
    StartPlayRoom(selectedWorldInternal, selectedChapter)
end)


-- Ranger Mode dropdowns
local rangerWorldDropdown = RangerGroup:AddDropdown("RangerWorldDropdown", {
    Text = "Select Stage",
    Values = worlds,
    Default = worlds[1],
})

local rangerChapterDisplayNames = {}
local rangerChapterInternalNames = {}
for _, internal in ipairs(worldInternalNames) do
    local display = worldDisplayNames[internal]
    rangerChapterDisplayNames[display] = {}
    rangerChapterInternalNames[display] = {}
    for i = 1, 3 do
        table.insert(rangerChapterDisplayNames[display], "Act " .. i)
        table.insert(rangerChapterInternalNames[display], internal .. "_RangerStage" .. i)
    end
end

local selectedRangerWorld = worlds[1]
local selectedRangerWorldInternal = worldInternalNames[1]
local selectedRangerChapter = rangerChapterInternalNames[selectedRangerWorld][1]

rangerWorldDropdown:SetValue(selectedRangerWorld)

local rangerChapterDropdown = RangerGroup:AddDropdown("RangerChapterDropdown", {
    Text = "Select Ranger Stage",
    Values = rangerChapterDisplayNames[selectedRangerWorld],
    Default = rangerChapterDisplayNames[selectedRangerWorld][1],
})

-- Update logic for dropdowns
rangerWorldDropdown.Callback = function(worldDisplay)
    selectedRangerWorld = worldDisplay
    for internal, display in pairs(worldDisplayNames) do
        if display == worldDisplay then
            selectedRangerWorldInternal = internal
            break
        end
    end
    rangerChapterDropdown:SetValues(rangerChapterDisplayNames[selectedRangerWorld])
    rangerChapterDropdown:SetValue(rangerChapterDisplayNames[selectedRangerWorld][1])
    if rangerChapterDropdown.Refresh then
        rangerChapterDropdown:Refresh()
    end
    selectedRangerChapter = rangerChapterInternalNames[selectedRangerWorld][1]
end

-- When updating selectedRangerChapter, use the correct mapping
rangerChapterDropdown.Callback = function(chapterDisplay)
    local idx = nil
    for i, v in ipairs(rangerChapterDisplayNames[selectedRangerWorld]) do
        if v == chapterDisplay then idx = i break end
    end
    if idx then
        selectedRangerChapter = rangerChapterInternalNames[selectedRangerWorld][idx]
    end
end

RangerGroup:AddButton("Start Ranger Mode", function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                            :WaitForChild("Server", 9e9)
                            :WaitForChild("PlayRoom", 9e9)
                            :WaitForChild("Event", 9e9)
    -- Change Mode
    remote:FireServer("Create")
    remote:FireServer("Change-Mode", {Mode = "Ranger Stage"})
    remote:FireServer("Change-World", {World = selectedRangerWorldInternal})
    remote:FireServer("Change-Chapter", {Chapter = selectedRangerChapter})
    remote:FireServer("Submit")
    remote:FireServer("Start")
end)


-- Raid Mode dropdowns
local raidWorlds = {"SteelBlitzRush", "TheGraveyard", "TheGatedCity"}
local raidWorldDisplayNames = {SteelBlitzRush = "Steel Blitz Rush", TheGraveyard = "The Graveyard", TheGatedCity = "The Gated City"}
local raidChapterDisplayNames = {}
local raidChapterInternalNames = {}
for _, world in ipairs(raidWorlds) do
    raidChapterDisplayNames[world] = {}
    raidChapterInternalNames[world] = {}
    for i = 1, 4 do
        raidChapterDisplayNames[world][i] = "Act " .. i
        raidChapterInternalNames[world][i] = world .. "_Chapter" .. i
    end
end

local selectedRaidWorld = raidWorlds[1]
local selectedRaidChapter = raidChapterInternalNames[selectedRaidWorld][1]

local raidWorldDropdown = RaidGroup:AddDropdown("RaidWorldDropdown", {
    Text = "Select Raid",
    Values = {raidWorldDisplayNames[raidWorlds[1]], raidWorldDisplayNames[raidWorlds[2]], raidWorldDisplayNames[raidWorlds[3]]},
    Default = raidWorldDisplayNames[selectedRaidWorld],
    Callback = function(worldDisplay)
        for internal, display in pairs(raidWorldDisplayNames) do
            if display == worldDisplay then
                selectedRaidWorld = internal
                break
            end
        end
        raidChapterDropdown:SetValues(raidChapterDisplayNames[selectedRaidWorld])
        raidChapterDropdown:SetValue(raidChapterDisplayNames[selectedRaidWorld][1])
        if raidChapterDropdown.Refresh then
            raidChapterDropdown:Refresh()
        end
        selectedRaidChapter = raidChapterInternalNames[selectedRaidWorld][1]
    end
})

local raidChapterDropdown = RaidGroup:AddDropdown("RaidChapterDropdown", {
    Text = "Select Chapter",
    Values = raidChapterDisplayNames[selectedRaidWorld],
    Default = raidChapterDisplayNames[selectedRaidWorld][1],
    Callback = function(chapterDisplay)
        local idx = nil
        for i, v in ipairs(raidChapterDisplayNames[selectedRaidWorld]) do
            if v == chapterDisplay then idx = i break end
        end
        if idx then
            selectedRaidChapter = raidChapterInternalNames[selectedRaidWorld][idx]
        end
    end
})

RaidGroup:AddButton("Start Raid", function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                            :WaitForChild("Server", 9e9)
                            :WaitForChild("PlayRoom", 9e9)
                            :WaitForChild("Event", 9e9)
    remote:FireServer("Change-Mode", {Mode = "Raids Stage"})
    remote:FireServer("Change-World", {World = selectedRaidWorld})
    remote:FireServer("Change-Chapter", {Chapter = selectedRaidChapter})
    remote:FireServer("Submit")
    remote:FireServer("Start")
end)

ChalGroup:AddButton("Enter Challenge Mode", function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9):WaitForChild("Server", 9e9):WaitForChild("PlayRoom", 9e9):WaitForChild("Event", 9e9)
    local argsCreate = {
        [1] = "Create",
        [2] = {
            ["CreateChallengeRoom"] = true,
        },
    }
    remote:FireServer(unpack(argsCreate))
    task.wait(0.5)
    local argsStart = {
        [1] = "Start",
    }
    remote:FireServer(unpack(argsStart))
end)

-- LOBBY TAB
-- Auto Deploy Equipped Units by Tag
local function deployRandomEquippedUnit()
    local player = game:GetService("Players").LocalPlayer
    local playerName = player.Name
    local unitsFolder = player:FindFirstChild("UnitsFolder")
    local collection = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data", 9e9):WaitForChild(playerName, 9e9):WaitForChild("Collection", 9e9)
    if unitsFolder and collection then
        local equippedUnits = unitsFolder:GetChildren()
        if #equippedUnits > 0 then
            for attempt = 1, 3 do
                local idx = math.random(1, #equippedUnits)
                local equippedUnit = equippedUnits[idx]
                local tagValue = equippedUnit:FindFirstChild("Tag") and equippedUnit.Tag.Value
                if tagValue then
                    -- Find all collection units with same name and tag
                    local matchingCollectionUnits = {}
                    for _, collectionUnit in ipairs(collection:GetChildren()) do
                        if collectionUnit.Name == equippedUnit.Name and collectionUnit:FindFirstChild("Tag") and collectionUnit.Tag.Value == tagValue then
                            table.insert(matchingCollectionUnits, collectionUnit)
                        end
                    end
                    if #matchingCollectionUnits > 0 then
                        local chosenCollectionUnit = matchingCollectionUnits[math.random(1, #matchingCollectionUnits)]
                        local args = {
                            [1] = chosenCollectionUnit,
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Remote", 9e9)
                            :WaitForChild("Server", 9e9)
                            :WaitForChild("Units", 9e9)
                            :WaitForChild("Deployment", 9e9)
                            :FireServer(unpack(args))
                        task.wait(0.15)
                    end
                end
            end
        end
    end
end

-- Smart cooldown-aware deployment for Boss Rush
local function deployUnitWithCooldownCheck()
    local success, result = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local playerName = player.Name
        local unitsFolder = player:FindFirstChild("UnitsFolder")
        local collection = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data", 9e9):WaitForChild(playerName, 9e9):WaitForChild("Collection", 9e9)
        
        if not unitsFolder or not collection then
            return false
        end
        
        -- Get deployed units and their cooldowns
        local deployedUnits = {}
        for _, child in ipairs(player:GetChildren()) do
            if child.Name:find(" / Send CD") then
                local unitTag = child.Name:gsub(" / Send CD", "")
                deployedUnits[unitTag] = true
                if config and config.DebugMode then
                    print("[Boss Rush] Unit on cooldown:", unitTag)
                end
            end
        end
        
        local equippedUnits = unitsFolder:GetChildren()
        if #equippedUnits == 0 then
            return false
        end
        
        -- Try to find an available unit (not on cooldown)
        local availableUnits = {}
        for _, equippedUnit in ipairs(equippedUnits) do
            local tagValue = equippedUnit:FindFirstChild("Tag") and equippedUnit.Tag.Value
            if tagValue and not deployedUnits[tagValue] then
                -- Find all collection units with same name and tag
                for _, collectionUnit in ipairs(collection:GetChildren()) do
                    if collectionUnit.Name == equippedUnit.Name and collectionUnit:FindFirstChild("Tag") and collectionUnit.Tag.Value == tagValue then
                        table.insert(availableUnits, collectionUnit)
                    end
                end
            end
        end
        
        if #availableUnits > 0 then
            local chosenUnit = availableUnits[math.random(1, #availableUnits)]
            local unitTag = chosenUnit:FindFirstChild("Tag") and chosenUnit.Tag.Value or "Unknown"
            
            if config and config.DebugMode then
                print("[Boss Rush] Deploying unit:", chosenUnit.Name, "with tag:", unitTag)
            end
            
            local args = {
                [1] = chosenUnit,
            }
            game:GetService("ReplicatedStorage")
                :WaitForChild("Remote", 9e9)
                :WaitForChild("Server", 9e9)
                :WaitForChild("Units", 9e9)
                :WaitForChild("Deployment", 9e9)
                :FireServer(unpack(args))
            
            return true
        else
            if config and config.DebugMode then
                print("[Boss Rush] No units available (all on cooldown)")
            end
            return false
        end
    end)
    
    if not success then
        print("[Boss Rush] Error in deployUnitWithCooldownCheck:", result)
        return false
    end
    
    return result
end


AutoPlay:AddLabel("Auto Boss Rush and Rift Storm")
AutoPlay:AddLabel("Dont Use Auto Deploy")
local autoBossRushEnabled = (config and config.AutoBossRushEnabled) or false
local autoBossRushConnection

AutoPlay:AddToggle("AutoBossRushToggle", {
    Text = "Auto Play",
    Default = autoBossRushEnabled,
    Tooltip = "Automatically cycles Boss Rush ways (1-4) every 3 seconds",
    Callback = function(enabled)
        autoBossRushEnabled = enabled
        
        -- Ensure config exists
        if not config then
            config = {}
        end
        config.AutoBossRushEnabled = enabled
        
        -- Safe config saving with error handling
        local success, err = pcall(function()
            writefile(configFile, HttpService:JSONEncode(config))
        end)
        if not success then
            print("[Boss Rush] Config save error:", err)
        end
        
        if enabled then
            if autoBossRushConnection and type(autoBossRushConnection) == "table" and type(autoBossRushConnection.Disconnect) == "function" then
                autoBossRushConnection:Disconnect()
            end
            -- Safety check before calling the function
            if deployUnitWithCooldownCheck then
                deployUnitWithCooldownCheck() -- deploy immediately on toggle with cooldown check
            end
            autoBossRushConnection = task.spawn(function()
                local success, err = pcall(function()
                    local way = 1
                    while autoBossRushEnabled do
                        local args = {
                            [1] = way,
                            [2] = false,
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Remote", 9e9)
                            :WaitForChild("Server", 9e9)
                            :WaitForChild("Units", 9e9)
                            :WaitForChild("SelectWay", 9e9)
                            :FireServer(unpack(args))
                        task.wait(0.05)
                        -- Smart deployment with cooldown checking
                        local deployed = false
                        if deployUnitWithCooldownCheck then
                            deployed = deployUnitWithCooldownCheck()
                        end
                        if config and config.DebugMode then
                            print("[Boss Rush] Way", way, "- Unit deployed:", deployed)
                        end
                        local t = 0
                        while t < 1.75 and autoBossRushEnabled do
                            task.wait(0.1)
                            t = t + 0.1
                        end
                        way = way + 1
                        if way > 4 then way = 1 end
                    end
                end)
                if not success then
                    print("[Boss Rush] Loop error:", err)
                end
            end)
        else
            if autoBossRushConnection and type(autoBossRushConnection) == "table" and type(autoBossRushConnection.Disconnect) == "function" then
                autoBossRushConnection:Disconnect()
                autoBossRushConnection = nil
            end
        end
    end
})

-- Auto-start logic for AutoBossRushToggle after reload
if config and config.AutoBossRushEnabled then
    autoBossRushEnabled = true
    if Enter.Flags and Enter.Flags.AutoBossRushToggle then
        Enter.Flags.AutoBossRushToggle:Set(true)
    end
    -- Disconnect any previous thread (if not a Roblox connection)
    if autoBossRushConnection then
        if typeof(autoBossRushConnection) == "Instance" or (type(autoBossRushConnection) == "table" and type(autoBossRushConnection.Disconnect) == "function") then
            autoBossRushConnection:Disconnect(); autoBossRushConnection = nil
        else
            autoBossRushConnection = nil
        end
    end
    -- Safety check before calling the function
    if deployUnitWithCooldownCheck then
        deployUnitWithCooldownCheck() -- deploy immediately on auto-start with cooldown check
    end
    autoBossRushConnection = task.spawn(function()
        local success, err = pcall(function()
            local way = 1
            while autoBossRushEnabled do
                local args = {
                    [1] = way,
                    [2] = false,
                }
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Remote", 9e9)
                    :WaitForChild("Server", 9e9)
                    :WaitForChild("Units", 9e9)
                    :WaitForChild("SelectWay", 9e9)
                    :FireServer(unpack(args))
                task.wait(0.05)
                -- Smart deployment with cooldown checking
                local deployed = false
                if deployUnitWithCooldownCheck then
                    deployed = deployUnitWithCooldownCheck()
                end
                if config and config.DebugMode then
                    print("[Boss Rush] Way", way, "- Unit deployed:", deployed)
                end
                local t = 0
                while t < 1.75 and autoBossRushEnabled do
                    task.wait(0.1)
                    t = t + 0.1
                end
                way = way + 1
                if way > 4 then way = 1 end
            end
        end)
        if not success then
            print("[Boss Rush] Loop error:", err)
        end
    end)
end

Enter:AddButton("Enter RiftStorm", function()
    local remote = game:GetService("ReplicatedStorage")
        :WaitForChild("Remote", 9e9)
        :WaitForChild("Server", 9e9)
        :WaitForChild("PlayRoom", 9e9)
        :WaitForChild("Event", 9e9)

    local args = {
        [1] = "RiftStorm";
    }
    remote:FireServer(unpack(args))
    remote:FireServer("Start")
end)

Enter:AddButton("Enter BossRush", function()
    local remote = game:GetService("ReplicatedStorage")
        :WaitForChild("Remote", 9e9)
        :WaitForChild("Server", 9e9)
        :WaitForChild("PlayRoom", 9e9)
        :WaitForChild("Event", 9e9)

    remote:FireServer("BossRush")
    remote:FireServer("Start")
end)

Enter:AddButton("Enter Infinite Mode", function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                            :WaitForChild("Server", 9e9)
                            :WaitForChild("PlayRoom", 9e9)
                            :WaitForChild("Event", 9e9)
                            :WaitForChild("Start", 9e9)
    remote:FireServer("Infinite Mode")
end)

Enter:AddButton("Enter Swarm Event", function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                            :WaitForChild("Server", 9e9)
                            :WaitForChild("PlayRoom", 9e9)
                            :WaitForChild("Event", 9e9)
                            :WaitForChild("Start", 9e9)
    remote:FireServer("Swarm Event")
end)

Enter:AddButton("Enter Tournament", function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                            :WaitForChild("Server", 9e9)
                            :WaitForChild("Tournament", 9e9)
                            :WaitForChild("Start", 9e9)
    remote:FireServer(false)
end)

-- Get trait list from GUI and sort by chance
local traitFrame = game:GetService("Players").LocalPlayer.PlayerGui.Traits.Main.Base.Chances.ScrollingFrame
local traitEntries = {}
for _, child in ipairs(traitFrame:GetChildren()) do
    if child:FindFirstChild("Trait") then
        local traitName = child.Trait.Text
        local percent = 0
        if child:FindFirstChild("Chance") then
            local chanceText = child.Chance.Text
            percent = tonumber((chanceText:match("([%d%.]+)%%"))) or 0
        end
        table.insert(traitEntries, {name = traitName, percent = percent})
    end
end
-- Sort by percent descending
 table.sort(traitEntries, function(a, b) return a.percent > b.percent end)
local traitNames = {}
for _, entry in ipairs(traitEntries) do
    table.insert(traitNames, entry.name)
end

local selectedTrait = traitNames[1] or ""
local selectedTraits = {traitNames[1]} -- multi-select support

local collectionUnitNames = {}

do
    local player = game:GetService("Players").LocalPlayer
    local playerName = player.Name
    local units = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data", 9e9):WaitForChild(playerName, 9e9):WaitForChild("Collection", 9e9):GetChildren()
    for _, unit in ipairs(units) do
        local displayName = unit.Name
        local level = unit:FindFirstChild("Level") and unit.Level.Value or "?"
        table.insert(collectionUnitNames, displayName .. " Level " .. tostring(level))
    end
end


local selectedCollectionUnit = collectionUnitNames[1] or ""
local autoRerollEnabled = false

local collectionUnitDropdown = traitGroup:AddDropdown("CollectionUnitDropdown", {
    Text = "Select Unit to Reroll",
    Values = collectionUnitNames,
    Default = collectionUnitNames[1],
    Callback = function(display)
        -- Parse the name and level from 'Ichigoat Level 57'
        local name, level = display:match("^(.-) Level (%d+)")
        selectedCollectionUnit = {name = name or display, level = tonumber(level) or nil}
    end
})


    -- Button to refresh the unit dropdown
    traitGroup:AddButton("Refresh Units", function()
        -- Re-fetch units from ReplicatedStorage
        local player = game:GetService("Players").LocalPlayer
        local playerName = player.Name
        local units = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data", 9e9):WaitForChild(playerName, 9e9):WaitForChild("Collection", 9e9):GetChildren()
        collectionUnitNames = {}
        for _, unit in ipairs(units) do
            local displayName = unit.Name
            local level = unit:FindFirstChild("Level") and unit.Level.Value or "?"
            table.insert(collectionUnitNames, displayName .. " Level " .. tostring(level))
        end
        -- Use the stored dropdown reference
        if collectionUnitDropdown then
            collectionUnitDropdown:SetValues(collectionUnitNames)
            local firstUnit = collectionUnitNames[1] or ""
            collectionUnitDropdown:SetValue(firstUnit)
            if collectionUnitDropdown.Refresh then collectionUnitDropdown:Refresh() end
            -- Update selectedCollectionUnit to match the first unit
            local name, level = firstUnit:match("^(.-) Level (%d+)")
            selectedCollectionUnit = {name = name or firstUnit, level = tonumber(level) or nil}
        end
    end)

traitGroup:AddDropdown("TraitDropdown", {
    Text = "Select Trait",
    Values = traitNames,
    Default = traitNames[1],
    Callback = function(trait)
        selectedTraits = {trait}
    end
})

traitGroup:AddToggle("AutoRerollToggle", {
    Text = "Auto Reroll",
    Default = false,
    Callback = function(enabled)
        autoRerollEnabled = enabled
        if enabled then
            -- Start auto reroll loop
            spawn(function()
                while autoRerollEnabled do
                    local traitObj = game:GetService("Players").LocalPlayer.PlayerGui.Traits.Main.Base.Main_Trait:FindFirstChild("Trait")
                    local traitText = traitObj and traitObj.Text or ""
                    -- Robust trait comparison: trim, lowercase, ignore extra spaces and roman numerals
                    local function normalize(str)
                        str = str or ""
                        -- Remove non-printable characters
                        str = str:gsub("[^%w%sIVXLCDM]", "")
                        -- Convert Unicode roman numerals to ASCII
                        str = str:gsub("Ⅰ", "I"):gsub("Ⅱ", "II"):gsub("Ⅲ", "III"):gsub("Ⅳ", "IV"):gsub("Ⅴ", "V")
                        str = string.lower(str)
                        str = str:gsub("^%s*(.-)%s*$", "%1") -- trim
                        str = str:gsub("%s+", " ") -- collapse spaces
                        return str
                    end
                    print("Raw traitText:", traitText, "Raw trait(s):", table.concat(selectedTraits, ", "))
                    local traitTextNorm = normalize(traitText)
                    for _, trait in ipairs(selectedTraits) do
                        local traitNorm = normalize(trait)
                        print("Comparing:", traitTextNorm, "vs", traitNorm) -- debug
                        if traitTextNorm == traitNorm then
                            autoRerollEnabled = false
                            if Library.Flags and Library.Flags.AutoRerollToggle then
                                Library.Flags.AutoRerollToggle:Set(false)
                            end
                            break
                        end
                    end
                    if not autoRerollEnabled then break end
                    -- Find the selected unit object in the collection
                    local player = game:GetService("Players").LocalPlayer
                    local playerName = player.Name
                    local collection = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data", 9e9):WaitForChild(playerName, 9e9):WaitForChild("Collection", 9e9):GetChildren()
                    local unitObj = nil
                    for _, unit in ipairs(collection) do
                        local unitLevel = unit:FindFirstChild("Level") and unit.Level.Value or nil
                        if unit.Name == selectedCollectionUnit.name and unitLevel == selectedCollectionUnit.level then
                            unitObj = unit
                            break
                        end
                    end
                    if unitObj then
                        local args = {
                            [1] = unitObj,
                            [2] = "Reroll",
                            [3] = "Main",
                            [4] = "Shards",
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("Server", 9e9):WaitForChild("Gambling", 9e9):WaitForChild("RerollTrait", 9e9):FireServer(unpack(args))
                    end
                    task.wait(0.8)
                end
                autoRerollEnabled = false
            end)
        end
    end
})


local riftStormShopFrame = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("RiftStormExchange").Main.Base.Main.ScrollingFrame
local riftStormShopItems = {}
for _, child in ipairs(riftStormShopFrame:GetChildren()) do
    if child:IsA("GuiObject") then
        table.insert(riftStormShopItems, child.Name)
    end
end

local selectedRiftStormShopItem = riftStormShopItems[1] or ""

-- Fall Event Exchange Shop
local fallShopFrame = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("FallShopExchange").Main.Base.Main.ScrollingFrame
local fallShopItems = {}
for _, child in ipairs(fallShopFrame:GetChildren()) do
    if child:IsA("GuiObject") then
        table.insert(fallShopItems, child.Name)
    end
end

local selectedFallShopItem = fallShopItems[1] or ""
FallEventExchangeGroup:AddDropdown("FallShopDropdown", {
    Text = "Select Fall Event Item",
    Values = fallShopItems,
    Default = fallShopItems[1],
    Callback = function(item)
        selectedFallShopItem = item
    end
})

local autoBuyFallShopEnabled = false
local autoBuyFallShopConnection

FallEventExchangeGroup:AddToggle("AutoBuyFallShopToggle", {
    Text = "Auto Buy Fall Event Item",
    Default = false,
    Tooltip = "Automatically buy the selected Fall Event item every 1s until toggled off.",
    Callback = function(enabled)
        autoBuyFallShopEnabled = enabled
        if enabled then
            if autoBuyFallShopConnection then autoBuyFallShopConnection:Disconnect() end
            autoBuyFallShopConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoBuyFallShopEnabled then
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                        :WaitForChild("Server", 9e9)
                        :WaitForChild("Gameplay", 9e9)
                        :WaitForChild("FallShopExchange", 9e9)
                    local args = {
                        [1] = selectedFallShopItem,
                        [2] = 1,
                    }
                    remote:FireServer(unpack(args))
                    task.wait(1)
                end
            end)
        else
            if autoBuyFallShopConnection then
                autoBuyFallShopConnection:Disconnect()
                autoBuyFallShopConnection = nil
            end
        end
    end
})

RiftStormShopGroup:AddDropdown("RiftStormShopDropdown", {
    Text = "Select Rift Storm Item",
    Values = riftStormShopItems,
    Default = riftStormShopItems[1],
    Callback = function(item)
        selectedRiftStormShopItem = item
    end
})

local autoBuyRiftStormShopEnabled = false
local autoBuyRiftStormShopConnection

RiftStormShopGroup:AddToggle("AutoBuyRiftStormShopToggle", {
    Text = "Auto Buy Rift Storm Item",
    Default = false,
    Tooltip = "Automatically buy the selected Rift Storm shop item every 1s until toggled off.",
    Callback = function(enabled)
        autoBuyRiftStormShopEnabled = enabled
        if enabled then
            if autoBuyRiftStormShopConnection then autoBuyRiftStormShopConnection:Disconnect() end
            autoBuyRiftStormShopConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoBuyRiftStormShopEnabled then
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                        :WaitForChild("Server", 9e9)
                        :WaitForChild("Gameplay", 9e9)
                        :WaitForChild("RiftStormExchange", 9e9)
                    local args = {
                        [1] = selectedRiftStormShopItem,
                        [2] = 1,
                    }
                    remote:FireServer(unpack(args))
                    task.wait(1)
                end
            end)
        else
            if autoBuyRiftStormShopConnection then
                autoBuyRiftStormShopConnection:Disconnect()
                autoBuyRiftStormShopConnection = nil
            end
        end
    end
})

local merchantShopFrame = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Merchant").Main.Base.Main.ScrollingFrame
local merchantShopItems = {}
for _, child in ipairs(merchantShopFrame:GetChildren()) do
    if child:IsA("GuiObject") then
        table.insert(merchantShopItems, child.Name)
    end
end

local selectedMerchantShopItem = merchantShopItems[1] or ""

MerchantShopGroup:AddDropdown("MerchantShopDropdown", {
    Text = "Select Merchant Shop Item",
    Values = merchantShopItems,
    Default = merchantShopItems[1],
    Callback = function(item)
        selectedMerchantShopItem = item
    end
})

local autoBuyMerchantShopEnabled = false
local autoBuyMerchantShopConnection

MerchantShopGroup:AddToggle("AutoBuyMerchantShopToggle", {
    Text = "Auto Buy Merchant Shop Item",
    Default = false,
    Tooltip = "Automatically buy the selected merchant shop item every 1s until toggled off.",
    Callback = function(enabled)
        autoBuyMerchantShopEnabled = enabled
        if enabled then
            if autoBuyMerchantShopConnection then autoBuyMerchantShopConnection:Disconnect() end
            autoBuyMerchantShopConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoBuyMerchantShopEnabled then
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                        :WaitForChild("Server", 9e9)
                        :WaitForChild("Gameplay", 9e9)
                        :WaitForChild("Merchant", 9e9)
                    local args = {
                        [1] = selectedMerchantShopItem,
                        [2] = 1,
                    }
                    remote:FireServer(unpack(args))
                    task.wait(1)
                end
            end)
        else
            if autoBuyMerchantShopConnection then
                autoBuyMerchantShopConnection:Disconnect()
                autoBuyMerchantShopConnection = nil
            end
        end
    end
})

local autoBuyMerchantEnabled = config.AutoBuyMerchantEnabled or false
local autoBuyMerchantItem = config.AutoBuyMerchantItem or merchantShopItems[1]
local autoBuyMerchantConnection

MerchantShopGroup:AddDropdown("AutoBuyMerchantDropdown", {
    Text = "Auto Buy Item",
    Values = merchantShopItems,
    Default = autoBuyMerchantItem,
    Callback = function(item)
        autoBuyMerchantItem = item
        config.AutoBuyMerchantItem = item
        writefile(configFile, HttpService:JSONEncode(config))
    end
})

MerchantShopGroup:AddToggle("AutoBuyMerchantToggle", {
    Text = "Auto Buy Every 50s",
    Default = autoBuyMerchantEnabled,
    Callback = function(enabled)
        autoBuyMerchantEnabled = enabled
        config.AutoBuyMerchantEnabled = enabled
        writefile(configFile, HttpService:JSONEncode(config))
        if enabled then
            if autoBuyMerchantConnection then autoBuyMerchantConnection:Disconnect() end
            autoBuyMerchantConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoBuyMerchantEnabled then
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                        :WaitForChild("Server", 9e9)
                        :WaitForChild("Gameplay", 9e9)
                        :WaitForChild("Merchant", 9e9)
                    local args = {
                        [1] = autoBuyMerchantItem,
                        [2] = 1,
                    }
                    remote:FireServer(unpack(args))
                    task.wait(50)
                end
            end)
        else
            if autoBuyMerchantConnection then
                autoBuyMerchantConnection:Disconnect()
                autoBuyMerchantConnection = nil
            end
        end
    end
})

-- Auto start on reload
if autoBuyMerchantEnabled then
    if autoBuyMerchantConnection then autoBuyMerchantConnection:Disconnect() end
    autoBuyMerchantConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if autoBuyMerchantEnabled then
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                :WaitForChild("Server", 9e9)
                :WaitForChild("Gameplay", 9e9)
                :WaitForChild("Merchant", 9e9)
            local args = {
                [1] = autoBuyMerchantItem,
                [2] = 1,
            }
            remote:FireServer(unpack(args))
            task.wait(50)
        end
    end)
end

-- Raid Shop 2 Buy Section
local raidCSWShopFrame = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("RaidCSW_Shop").Main.Base.Main.ScrollingFrame
local raidCSWShopItems = {}
for _, child in ipairs(raidCSWShopFrame:GetChildren()) do
    if child:IsA("GuiObject") then
        table.insert(raidCSWShopItems, child.Name)
    end
end

local selectedRaidCSWShopItem = raidCSWShopItems[1] or ""

RaidShop2Group:AddDropdown("RaidCSWShopDropdown", {
    Text = "Select Raid Shop 2 Item",
    Values = raidCSWShopItems,
    Default = raidCSWShopItems[1],
    Callback = function(item)
        selectedRaidCSWShopItem = item
    end
})

local autoBuyRaidCSWShopEnabled = false
local autoBuyRaidCSWShopConnection

RaidShop2Group:AddToggle("AutoBuyRaidCSWShopToggle", {
    Text = "Auto Buy RaidCSW Shop Item",
    Default = false,
    Tooltip = "Automatically buy the selected RaidCSW shop item every 1s until toggled off.",
    Callback = function(enabled)
        autoBuyRaidCSWShopEnabled = enabled
        if enabled then
            if autoBuyRaidCSWShopConnection then autoBuyRaidCSWShopConnection:Disconnect() end
            autoBuyRaidCSWShopConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoBuyRaidCSWShopEnabled then
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                        :WaitForChild("Server", 9e9)
                        :WaitForChild("Gameplay", 9e9)
                        :WaitForChild("RaidCSW_Shop", 9e9)
                    local args = {
                        [1] = selectedRaidCSWShopItem,
                        [2] = 1,
                    }
                    remote:FireServer(unpack(args))
                    task.wait(1)
                end
            end)
        else
            if autoBuyRaidCSWShopConnection then
                autoBuyRaidCSWShopConnection:Disconnect()
                autoBuyRaidCSWShopConnection = nil
            end
        end
    end
})

-- Raid Shop Buy Section
local raidShopFrame = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Raid_Shop").Main.Base.Main.ScrollingFrame
local raidShopItems = {}
for _, child in ipairs(raidShopFrame:GetChildren()) do
    if child:IsA("GuiObject") then
        table.insert(raidShopItems, child.Name)
    end
end

local selectedRaidShopItem = raidShopItems[1] or ""

RaidShop:AddDropdown("RaidShopDropdown", {
    Text = "Select Raid Shop Item",
    Values = raidShopItems,
    Default = raidShopItems[1],
    Callback = function(item)
        selectedRaidShopItem = item
    end
})

local autoBuyRaidShopEnabled = false
local autoBuyRaidShopConnection

RaidShop:AddToggle("AutoBuyRaidShopToggle", {
    Text = "Auto Buy Raid Shop Item",
    Default = false,
    Tooltip = "Automatically buy the selected raid shop item every 1s until toggled off.",
    Callback = function(enabled)
        autoBuyRaidShopEnabled = enabled
        if enabled then
            if autoBuyRaidShopConnection then autoBuyRaidShopConnection:Disconnect() end
            autoBuyRaidShopConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoBuyRaidShopEnabled then
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local remote = ReplicatedStorage:WaitForChild("Remote", 9e9)
                        :WaitForChild("Server", 9e9)
                        :WaitForChild("Gameplay", 9e9)
                        :WaitForChild("Raid_Shop", 9e9)
                    local args = {
                        [1] = selectedRaidShopItem,
                        [2] = 1,
                    }
                    remote:FireServer(unpack(args))
                    task.wait(1)
                end
            end)
        else
            if autoBuyRaidShopConnection then
                autoBuyRaidShopConnection:Disconnect()
                autoBuyRaidShopConnection = nil
            end
        end
    end
})

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

--// Detect available HTTP function
local requestFunction = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request)
if not requestFunction then
    warn("No HTTP request function found. Your executor may not support webhooks.")
end

--// Remotes
local UnitsGacha = ReplicatedStorage.Remote.Server.Gambling.UnitsGacha
local Summon_Visual = ReplicatedStorage.Remote.Client.UI:FindFirstChild("Summon_Visual")
-- === Hourly Banner Info Webhook ===
local function sendBannerInfoToDiscord()
    if not (config.EnableWebhookSender) then return end
    if not webhookUrl or webhookUrl == "" or not requestFunction then return end
    local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    local banner = playerGui and playerGui:FindFirstChild("UnitsGacha")
        and playerGui.UnitsGacha:FindFirstChild("Main")
        and playerGui.UnitsGacha.Main:FindFirstChild("Standard_Banner")
    if not banner then return end

    local function getBannerSection(section)
        local sectionObj = banner:FindFirstChild(section)
        if not sectionObj then return nil end
        local names = sectionObj:FindFirstChild("Names") and sectionObj.Names.Text or "?"
        local rarity = sectionObj:FindFirstChild("Rarity") and sectionObj.Rarity.Text or "?"
        local rate = sectionObj:FindFirstChild("Rate") and sectionObj.Rate.Text or "?"
        -- Try to get rarity attribute from the section object
        local rarityAttr = sectionObj:GetAttribute("LastRarity") or "?"
        return {
            names = names,
            rarity = rarity,
            rate = rate,
            rarityAttr = rarityAttr
        }
    end

    local center = getBannerSection("CenterText")
    local left = getBannerSection("LeftText")

    local lines = {}
    if center then
        table.insert(lines, string.format("Center: %s | Rarity: %s (%s) | Rate: %s", center.names, center.rarity, center.rarityAttr, center.rate))
    end
    if left then
        table.insert(lines, string.format("Left: %s | Rarity: %s (%s) | Rate: %s", left.names, left.rarity, left.rarityAttr, left.rate))
    end

    local embed = {
        title = "Banner Info",
        description = table.concat(lines, "\n"),
        color = 5814783,
        footer = { text = "Seisen Hub" }
    }
    local payload = HttpService:JSONEncode({
        username = "Seisen Hub",
        embeds = {embed}
    })
    pcall(function()
        requestFunction({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload
        })
    end)
end

-- Hourly timer
task.spawn(function()
    while true do
        if config.EnableWebhookSender then
            sendBannerInfoToDiscord()
        end
        local now = os.time()
        local nextHour = now - (now % 3600) + 3600
        task.wait(nextHour - now)
    end
end)

--// Your Discord webhook
local webhookUrl = config.WebhookUrl or ""
WebhookGroup:AddInput("WebhookInput", {
    Text = "Discord Webhook URL",
    Default = webhookUrl,
    Tooltip = "Paste your Discord webhook URL here to receive summon results.",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(value)
        webhookUrl = value
        config.WebhookUrl = value
        saveConfig()
    -- ...existing code...
    end
})

local webhookHourlyBannerEnabled = config.EnableWebhookSender or false
WebhookGroup:AddToggle("EnableWebhookSender", {
    Text = "Send Hourly Banner Info",
    Default = webhookHourlyBannerEnabled,
    Tooltip = "Enable to send hourly banner info to Discord.",
    Callback = function(enabled)
        webhookHourlyBannerEnabled = enabled
        config.EnableWebhookSender = enabled
        saveConfig()
    end
})

-- Toggle for which webhook results to send
local webhookSummonEnabled = config.WebhookSummonEnabled ~= false -- default true
WebhookGroup:AddToggle("WebhookSummonToggle", {
    Text = "Send Summon Results",
    Default = config.EnableWebhookSender or false,
    Tooltip = "Enable to send summon results to Discord webhook.",
    Callback = function(enabled)
        webhookSummonEnabled = enabled
        config.WebhookSummonEnabled = enabled
        saveConfig()
    -- ...existing code...
    end
})

local webhookStageRewardsEnabled = config.WebhookStageRewardsEnabled ~= false -- default true
WebhookGroup:AddToggle("WebhookStageRewardsToggle", {
    Text = "Send Stage Rewards",
    Default = webhookStageRewardsEnabled,
    Tooltip = "Enable to send stage rewards to Discord webhook when stage ends.",
    Callback = function(enabled)
        webhookStageRewardsEnabled = enabled
        config.WebhookStageRewardsEnabled = enabled
        saveConfig()
    -- ...existing code...
    end
})

--// Function to send summon result to Discord

-- Embed webhook for summon result
local function sendSummonResultEmbedToDiscord(resultTable)
    if not webhookSummonEnabled then return end
    if not requestFunction then return end
    if not webhookUrl or webhookUrl == "" then return end

    -- Count duplicates
    local nameCounts = {}
    for _, v in ipairs(resultTable) do
        local name = (typeof(v) == "Instance" and v.Name) or tostring(v)
        name = string.lower(name)
        nameCounts[name] = (nameCounts[name] or 0) + 1
    end

    local rewardLines = {}
    for name, count in pairs(nameCounts) do
        local displayName = name:gsub("^%l", string.upper) -- Capitalize first letter
        if count > 1 then
            table.insert(rewardLines, string.format("- %s x%d", displayName, count))
        else
            table.insert(rewardLines, string.format("- %s", displayName))
        end
    end
    table.sort(rewardLines)

    local embed = {
        title = "Summon Result",
        description = table.concat(rewardLines, "\n"),
        color = 5814783,
        thumbnail = {
            url = "https://cdn.discordapp.com/attachments/1057384125482410145/1405495922007343197/letter-s.png?ex=68ac3894&is=68aae714&hm=cbbd213417888454c0e545067640a1ccd6de603b6d83d06efd69fc8be791691d&"
        },
        footer = { text = "Seisen Hub" }
    }
    local payload = HttpService:JSONEncode({
        username = "Seisen Hub",
        embeds = {embed}
    })
    pcall(function()
        requestFunction({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload
        })
    end)
end

-- Embed webhook for stage rewards
local function sendStageRewardEmbedToDiscord(rewardLines)
    if not webhookStageRewardsEnabled then return end
    if not requestFunction then return end
    if not webhookUrl or webhookUrl == "" then return end

    -- Get extra info from RewardsUI
    local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    local leftSide = playerGui and playerGui:FindFirstChild("RewardsUI")
        and playerGui.RewardsUI:FindFirstChild("Main")
        and playerGui.RewardsUI.Main:FindFirstChild("LeftSide")
    local chapter = leftSide and leftSide:FindFirstChild("Chapter") and leftSide.Chapter.Text or "?"
    local difficulty = leftSide and leftSide:FindFirstChild("Difficulty") and leftSide.Difficulty.Text or "?"
    local gameStatus = leftSide and leftSide:FindFirstChild("GameStatus") and leftSide.GameStatus.Text or "?"
    local mode = leftSide and leftSide:FindFirstChild("Mode") and leftSide.Mode.Text or "?"
    local totalTime = leftSide and leftSide:FindFirstChild("TotalTime") and leftSide.TotalTime.Text or "?"
    local world = leftSide and leftSide:FindFirstChild("World") and leftSide.World.Text or "?"

    -- Set color based on win/lose
    local color = 5814783 -- default blue
    local statusLower = tostring(gameStatus):lower()
    if statusLower:find("win") or statusLower:find("won") then
        color = 3066993 -- green
    elseif statusLower:find("lose") or statusLower:find("lost") or statusLower:find("defeat") then
        color = 15158332 -- red
    end

    local headerInfo = string.format(
        "World: %s\nDifficulty: %s\nMode: %s\nGame Status: %s\nTotal Time: %s\n",
        world, difficulty, mode, gameStatus, totalTime
    )

    local description = nil
    if rewardLines and #rewardLines > 0 then
        description = headerInfo .. "Rewards:\n" .. table.concat(rewardLines, "\n")
        -- Discord embed description max length is 2048
        if #description > 2000 then
            description = string.sub(description, 1, 2000) .. "..."
        end
    else
        description = headerInfo .. "No rewards found."
    end

    local embed = {
        title = "Stage Reward",
        description = description,
        color = color,
        thumbnail = {
            url = "https://cdn.discordapp.com/attachments/1057384125482410145/1405495922007343197/letter-s.png?ex=68ac3894&is=68aae714&hm=cbbd213417888454c0e545067640a1ccd6de603b6d83d06efd69fc8be791691d&"
        },
        footer = { text = "Seisen Hub" }
    }
    local payload = HttpService:JSONEncode({
        username = "Seisen Hub",
        embeds = {embed}
    })
    pcall(function()
        requestFunction({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload
        })
    end)
end

--// Buffer for summon results
local summonBuffer = {}
local flushTimer = nil

--// Flush function (called on SummonEnd or timeout)
local function flushSummonBuffer()
    if #summonBuffer > 0 then
        sendSummonResultEmbedToDiscord(summonBuffer)
        summonBuffer = {}
    end
    flushTimer = nil
end

--// Listen for summon result
if Summon_Visual and Summon_Visual:IsA("RemoteEvent") then
    Summon_Visual.OnClientEvent:Connect(function(eventType, summonCount, resultTable)
        warn("Summon Event Fired:", eventType, summonCount)

        if eventType == "Summon" and typeof(resultTable) == "table" then
            -- Add results to buffer
            for i, v in ipairs(resultTable) do
                table.insert(summonBuffer, (typeof(v) == "Instance" and v.Name) or tostring(v))
                -- ...existing code...
            end

            -- Start/refresh flush timer (in case SummonEnd never comes)
            if flushTimer then
                task.cancel(flushTimer)
            end
            flushTimer = task.delay(2, flushSummonBuffer)

        elseif eventType == "SummonEnd" then
            -- If SummonEnd explicitly fires, flush immediately
            flushSummonBuffer()
        else
            warn("Unexpected event data format:", eventType, resultTable)
        end
    end)
else
    warn("Summon_Visual RemoteEvent not found.")
end

-- Listen for stage end and send rewards to Discord webhook

-- Send stage reward webhook when RewardsUI becomes visible
local player = game:GetService("Players").LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui")
local lastSent = false
if playerGui then
    local rewardsUI = playerGui:FindFirstChild("RewardsUI")
    if rewardsUI then
        rewardsUI:GetPropertyChangedSignal("Enabled"):Connect(function()
            if rewardsUI.Enabled and not lastSent then
                lastSent = true
                -- Fetch all info from UI
                local leftSide = rewardsUI:FindFirstChild("Main") and rewardsUI.Main:FindFirstChild("LeftSide")
                local itemsList = leftSide and leftSide:FindFirstChild("Rewards") and leftSide.Rewards:FindFirstChild("ItemsList")
                local rewardLines = {}
                if itemsList then
                    for _, rewardObj in ipairs(itemsList:GetChildren()) do
                        if rewardObj:IsA("Frame") or rewardObj:IsA("TextLabel") or rewardObj:IsA("ImageLabel") or rewardObj:IsA("GuiObject") then
                            local rewardName = rewardObj.Name
                            local info = nil
                            if rewardObj:FindFirstChild("Exp") and rewardObj.Exp:FindFirstChild("Frame") and rewardObj.Exp.Frame:FindFirstChild("ItemFrame") and rewardObj.Exp.Frame.ItemFrame:FindFirstChild("Info") then
                                info = rewardObj.Exp.Frame.ItemFrame.Info
                            elseif rewardObj:FindFirstChild("Frame") and rewardObj.Frame:FindFirstChild("ItemFrame") and rewardObj.Frame.ItemFrame:FindFirstChild("Info") then
                                info = rewardObj.Frame.ItemFrame.Info
                            end
                            if info then
                                local nameObj = info:FindFirstChild("ItemsNames") or info:FindFirstChild("ItemName") or info:FindFirstChild("Name")
                                local amountObj = info:FindFirstChild("DropAmonut") or info:FindFirstChild("Amount")
                                local nameText = nameObj and nameObj.Text or rewardName
                                local amountText = amountObj and amountObj.Text or "?"
                                table.insert(rewardLines, string.format("- %s: %s", nameText, amountText))
                            end
                        end
                    end
                end
                -- ...existing code...
                sendStageRewardEmbedToDiscord(rewardLines)
            elseif not rewardsUI.Enabled then
                lastSent = false
            end
        end)
    end
end

UISettingsGroup:AddToggle("AutoHideUI", {
    Text = "Auto Hide UI",
    Default = config.AutoHideUIEnabled ~= nil and config.AutoHideUIEnabled or autoHideUIEnabled,
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

-- Auto start logic for Auto Hide UI
if config.AutoHideUIEnabled ~= nil and config.AutoHideUIEnabled then
    autoHideUIEnabled = true
    Library:Toggle(false)
    Library.ShowCustomCursor = false
end

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
        Tooltip = "Bypasses AFK by simulating input signals.",
        Callback = function(Value)
            config.AntiAFKToggle = Value
            saveConfig()
            if Value then
                task.spawn(function()
                    local UIS = game:GetService("UserInputService")
                    while config.AntiAFKToggle and getgenv().SeisenHubRunning do
                        task.wait(60) -- every minute
                        pcall(function()
                            -- Fake keyboard press
                            firesignal(UIS.InputBegan, {KeyCode = Enum.KeyCode.W, UserInputType = Enum.UserInputType.Keyboard}, false)
                            firesignal(UIS.InputEnded, {KeyCode = Enum.KeyCode.W, UserInputType = Enum.UserInputType.Keyboard}, false)
                            -- Fake mouse move
                            firesignal(UIS.InputChanged, {UserInputType = Enum.UserInputType.MouseMovement, Position = Vector3.new()}, false)
                        end)
                    end
                end)
            end
        end
    }
)

-- Auto-load and auto-start logic for AntiAFKToggle after reload
if config.AntiAFKToggle then
    if UISettingsGroup.Flags and UISettingsGroup.Flags.AntiAFKToggle then
        UISettingsGroup.Flags.AntiAFKToggle:Set(true)
    end
    task.spawn(function()
        local UIS = game:GetService("UserInputService")
        while config.AntiAFKToggle and getgenv().SeisenHubRunning do
            task.wait(60)
            pcall(function()
                firesignal(UIS.InputBegan, {KeyCode = Enum.KeyCode.W, UserInputType = Enum.UserInputType.Keyboard}, false)
                firesignal(UIS.InputEnded, {KeyCode = Enum.KeyCode.W, UserInputType = Enum.UserInputType.Keyboard}, false)
                firesignal(UIS.InputChanged, {UserInputType = Enum.UserInputType.MouseMovement, Position = Vector3.new()}, false)
            end)
        end
    end)
end



UISettingsGroup:AddButton("Unload Script", function()
    getgenv().SeisenHubRunning = false
    -- Only stop features with auto start/auto load logic
    autoDeployEnabled = false
    autoAutoVoteEnabled = false
    autoUpgradeMaxYenEnabled = false
    autoUpgradeUnitsFolderEnabled = false
    autoNextActionEnabled = false
    autoClaimBattlepassEnabled = false
    autoClaimSwarmBattlepassEnabled = false
    autoClaimAllQuestEnabled = false
    autoSellRareEnabled = false
    autoSellEpicEnabled = false
    autoSellLegendaryEnabled = false
    autoSellShinyEnabled = false
    autoSellMyhicEnabled = false
    autoBossRushEnabled = false
    autoBuyMerchantEnabled = false
    fpsBoostEnabled = false
    AntiAFKToggle = false
    config.AutoHideUIEnabled = false
    saveConfig()
    local Lighting = game:GetService("Lighting")
    local workspace = game:GetService("Workspace")
    -- Disconnect all connections
    if fpsBoostConnection then fpsBoostConnection:Disconnect(); fpsBoostConnection = nil end
    if autoDeployConnection then autoDeployConnection:Disconnect(); autoDeployConnection = nil end
    if autoAutoVoteConnection then autoAutoVoteConnection:Disconnect(); autoAutoVoteConnection = nil end
    if autoUpgradeMaxYenConnection then autoUpgradeMaxYenConnection:Disconnect(); autoUpgradeMaxYenConnection = nil end
    if autoUpgradeUnitsFolderConnection then autoUpgradeUnitsFolderConnection:Disconnect(); autoUpgradeUnitsFolderConnection = nil end
    if autoNextActionConnection then autoNextActionConnection:Disconnect(); autoNextActionConnection = nil end
    if autoClaimBattlepassConnection then autoClaimBattlepassConnection:Disconnect(); autoClaimBattlepassConnection = nil end
    if autoClaimSwarmBattlepassConnection then autoClaimSwarmBattlepassConnection:Disconnect(); autoClaimSwarmBattlepassConnection = nil end
    if autoClaimAllQuestConnection then autoClaimAllQuestConnection:Disconnect(); autoClaimAllQuestConnection = nil end
    if autoBossRushConnection then
        if typeof(autoBossRushConnection) == "Instance" or (type(autoBossRushConnection) == "table" and type(autoBossRushConnection.Disconnect) == "function") then
            autoBossRushConnection:Disconnect(); autoBossRushConnection = nil
        else
            autoBossRushConnection = nil
        end
    end
    if autoBuyMerchantConnection then autoBuyMerchantConnection:Disconnect(); autoBuyMerchantConnection = nil end
    if autoBuyFallShopConnection then autoBuyFallShopConnection:Disconnect(); autoBuyFallShopConnection = nil end
    if autoBuyRiftStormShopConnection then autoBuyRiftStormShopConnection:Disconnect(); autoBuyRiftStormShopConnection = nil end
    if autoBuyMerchantShopConnection then autoBuyMerchantShopConnection:Disconnect(); autoBuyMerchantShopConnection = nil end
    if autoBuyRaidCSWShopConnection then autoBuyRaidCSWShopConnection:Disconnect(); autoBuyRaidCSWShopConnection = nil end
    if autoBuyRaidShopConnection then autoBuyRaidShopConnection:Disconnect(); autoBuyRaidShopConnection = nil end
    -- Restore graphics and UI
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
    -- Restore full UI cleanup
    if WatermarkConnection then WatermarkConnection:Disconnect(); WatermarkConnection = nil end
    if inputChangedConnection then inputChangedConnection:Disconnect(); inputChangedConnection = nil end
    if inputEndedConnection then inputEndedConnection:Disconnect(); inputEndedConnection = nil end
    if WatermarkGui then WatermarkGui:Destroy(); WatermarkGui = nil end
    if Library and Library.Unload then Library:Unload() end
    print("✅ Seisen Hub unloaded and cleaned up.")
end)
