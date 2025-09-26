game.StarterGui:SetCore("SendNotification", {
    Title = "Seisen Hub";
    Text = "Build a Zoo Script Loaded";
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
    Footer = "Build a Zoo",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Center = true,
    Icon = 125926861378074,
    AutoShow = true,
    ShowCustomCursor = true -- Enable custom cursor
})

-- =====================
-- Ball Circle Config & Defaults (top of file)
-- =====================
local configFolder = "SeisenHub"
local configFile = configFolder .. "/seisen_hub_baz.txt"
local HttpService = game:GetService("HttpService")
local config = {}

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
local autoBuyIslandEggEnabled = config.AutoBuyIslandEggEnabled or false
local autoPlaceEggEnabled = config.AutoPlaceEggEnabled or false

local function saveConfig()
    config.AutoHideUIEnabled = autoHideUIEnabled
    writefile(configFile, HttpService:JSONEncode(config))
end

local MainTab = Window:AddTab("Main", "atom")
local MainGroup = MainTab:AddLeftGroupbox("Main Features", "annoyed")
local EventTab = Window:AddTab("Events", "calendar")
local SettingsTab = Window:AddTab("Settings", "settings", "Customize the UI")
local UISettingsGroup = SettingsTab:AddLeftGroupbox("UI Customization", "paintbrush")
local PlayerSettings = SettingsTab:AddRightGroupbox("Player Settings", "crown")
local InfoGroup = SettingsTab:AddRightGroupbox("Script Information", "info")
-- ThemeManager integration
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenHub")
ThemeManager:ApplyToTab(SettingsTab)

InfoGroup:AddLabel("Script by: Seisen")
InfoGroup:AddLabel("Version: 1.0.0")
InfoGroup:AddLabel("Game: Build a Zoo")

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

local autoBuyIslandEggEnabled = config.AutoBuyIslandEggEnabled or false

local eggTypeMap = {
    ["Basic Egg"] = "BasicEgg",
    ["Rare Egg"] = "RareEgg",
    ["Super Rare Egg"] = "SuperRareEgg",
    ["Epic Egg"] = "EpicEgg",
    ["Legend Egg"] = "LegendEgg",
    ["Snow Bunny Egg"] = "SnowbunnyEgg",
    ["Prismatic Egg"] = "PrismaticEgg",
    ["Hyper Egg"] = "HyperEgg",
    ["Dark Goaty Egg"] = "DarkGoatyEgg",
    ["Void Egg"] = "VoidEgg",
    ["Bowser Egg"] = "BowserEgg",
    ["Demon Egg"] = "DemonEgg",
    ["Rhino Rock Egg"] = "RhinoRockEgg",
    ["Corn Egg"] = "CornEgg",
    ["Bone Dragon Egg"] = "BoneDragonEgg",
    ["Ultra Egg"] = "UltraEgg",
    ["Dino Egg"] = "DinoEgg",
    ["Fly Egg"] = "FlyEgg",
    ["Saber Cub Egg"] = "SaberCubEgg",
    ["Unicorn Egg"] = "UnicornEgg",
    ["Ancient Egg"] = "AncientEgg",
    ["Unicorn Pro Egg"] = "UnicornProEgg",
    ["General Kong Egg"] = "GeneralKongEgg",
    ["Pegasus Egg"] = "PegasusEgg",
}

local orderedEggTypeNames = {
    "Basic Egg",
    "Rare Egg",
    "Super Rare Egg",
    "Epic Egg",
    "Legend Egg",
    "Snow Bunny Egg",
    "Prismatic Egg",
    "Hyper Egg",
    "Dark Goaty Egg",
    "Void Egg",
    "Bowser Egg",
    "Demon Egg",
    "Rhino Rock Egg",
    "Corn Egg",
    "Bone Dragon Egg",
    "Ultra Egg",
    "Dino Egg",
    "Fly Egg",
    "Saber Cub Egg",
    "Unicorn Egg",
    "Ancient Egg",
    "Unicorn Pro Egg",
    "General Kong Egg",
    "Pegasus Egg"
}
availableIslandEggTypeNames = orderedEggTypeNames

-- Load saved egg types
local selectedIslandEggTypeNames = {}
if config.SelectedIslandEggTypeNames and type(config.SelectedIslandEggTypeNames) == "table" then
    selectedIslandEggTypeNames = config.SelectedIslandEggTypeNames
else
    selectedIslandEggTypeNames = {availableIslandEggTypeNames[1]} -- Default to first egg
end

-- Variants setup
local availableVariants = {"None", "Diamond", "Golden", "Snow", "Electric", "Fire"}
local selectedVariants = {[availableVariants[1]] = true} -- Default: "None"
if config.SelectedEggVariants and type(config.SelectedEggVariants) == "table" then
    selectedVariants = config.SelectedEggVariants
end

-- Convert saved variants into array for dropdown Default
local defaultVariantList = {}
for v, active in pairs(selectedVariants) do
    if active then table.insert(defaultVariantList, v) end
end

local AutoBuyIslandEggGroup = MainTab:AddRightGroupbox("Auto Buy Egg", "apple")

-- Dropdown for egg types (multi-select)
AutoBuyIslandEggGroup:AddDropdown("IslandEggTypeDropdown", {
    Text = "Select Egg(s) to Buy",
    Values = availableIslandEggTypeNames,
    Multi = true,
    Default = selectedIslandEggTypeNames,
    Tooltip = "Choose which Island_3 egg types to auto-buy",
    Callback = function(values)
        selectedIslandEggTypeNames = {}
        for name, active in pairs(values) do
            if active then table.insert(selectedIslandEggTypeNames, name) end
        end
        config.SelectedIslandEggTypeNames = selectedIslandEggTypeNames
        saveConfig()
    end
})

-- Dropdown for variants (multi-select, FIXED)
AutoBuyIslandEggGroup:AddDropdown("EggVariantDropdown", {
    Text = "Select Variant(s)",
    Values = availableVariants,
    Multi = true,
    Default = defaultVariantList, -- ✅ FIX: Correctly preloads saved variants
    Tooltip = "Choose one or more variants (e.g., Diamond, Golden) to auto-buy",
    Callback = function(values)
        selectedVariants = values
        local selectedList = {}
        for v, active in pairs(values) do
            if active then table.insert(selectedList, v) end
        end
        config.SelectedEggVariants = selectedVariants
        saveConfig()
    end
})

AutoBuyIslandEggGroup:AddToggle("AutoBuyIslandEggToggle", {
    Text = "Auto Buy Selected Egg ",
    Default = autoBuyIslandEggEnabled,
    Tooltip = "Automatically fires RemoteEvent for all eggs of selected type (T) in Island_3",
    Callback = function(state)
        autoBuyIslandEggEnabled = state
        config.AutoBuyIslandEggEnabled = state
        saveConfig()
    end
})

-- Main auto-buy loop
task.spawn(function()
    while task.wait(1) do
        if autoBuyIslandEggEnabled and selectedIslandEggTypeNames and #selectedIslandEggTypeNames > 0 then
            local selectedTs = {}
            for _, name in ipairs(selectedIslandEggTypeNames) do
                table.insert(selectedTs, eggTypeMap[name])
            end
            local eggsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Eggs")
            if eggsFolder and #selectedTs > 0 then
                -- Detect island name from LocalPlayer's AssignedIslandName attribute
                local islandName = nil
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                if LocalPlayer and LocalPlayer:GetAttribute("AssignedIslandName") then
                    islandName = LocalPlayer:GetAttribute("AssignedIslandName")
                end
                if islandName then
                    local islandFolder = eggsFolder:FindFirstChild(islandName)
                    if islandFolder then
                        for _, obj in ipairs(islandFolder:GetChildren()) do
                            local t = obj:GetAttribute("T")
                            local m = obj:GetAttribute("M")
                            local match = false
                            for v, active in pairs(selectedVariants) do
                                if active then
                                    if v == "None" and (m == nil or m == "") then
                                        match = true
                                    elseif v ~= "None" and m == v then
                                        match = true
                                    end
                                end
                            end
                            if t and table.find(selectedTs, t) and match then
                                local uid = obj.Name
                                local args = {
                                    [1] = "BuyEgg",
                                    [2] = uid
                                }
                                game:GetService("ReplicatedStorage")
                                    :WaitForChild("Remote", 9e9)
                                    :WaitForChild("CharacterRE", 9e9)
                                    :FireServer(unpack(args))
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================
local autoPlaceEggEnabled = config.AutoPlaceEggEnabled or false
local selectedEggTypeNames = {} -- Multi-select support
local eggTypeMap = {
    ["Basic Egg"] = "BasicEgg",
    ["Rare Egg"] = "RareEgg",
    ["Super Rare Egg"] = "SuperRareEgg",
    ["Epic Egg"] = "EpicEgg",
    ["Legend Egg"] = "LegendEgg",
    ["Snow Bunny Egg"] = "SnowbunnyEgg",
    ["Prismatic Egg"] = "PrismaticEgg",
    ["Hyper Egg"] = "HyperEgg",
    ["Dark Goaty Egg"] = "DarkGoatyEgg",
    ["Void Egg"] = "VoidEgg",
    ["Bowser Egg"] = "BowserEgg",
    ["Demon Egg"] = "DemonEgg",
    ["Rhino Rock Egg"] = "RhinoRockEgg",
    ["Corn Egg"] = "CornEgg",
    ["Bone Dragon Egg"] = "BoneDragonEgg",
    ["Ultra Egg"] = "UltraEgg",
    ["Dino Egg"] = "DinoEgg",
    ["Fly Egg"] = "FlyEgg",
    ["Saber Cub Egg"] = "SaberCubEgg",
    ["Unicorn Egg"] = "UnicornEgg",
    ["Ancient Egg"] = "AncientEgg",
    ["Unicorn Pro Egg"] = "UnicornProEgg",
    ["General Kong Egg"] = "GeneralKongEgg",
    ["Pegasus Egg"] = "PegasusEgg"
}

local orderedEggTypeNames = {
    "Basic Egg",
    "Rare Egg",
    "Super Rare Egg",
    "Epic Egg",
    "Legend Egg",
    "Snow Bunny Egg",
    "Prismatic Egg",
    "Hyper Egg",
    "Dark Goaty Egg",
    "Void Egg",
    "Bowser Egg",
    "Demon Egg",
    "Rhino Rock Egg",
    "Corn Egg",
    "Bone Dragon Egg",
    "Ultra Egg",
    "Dino Egg",
    "Fly Egg",
    "Saber Cub Egg",
    "Unicorn Egg",
    "Ancient Egg",
    "Unicorn Pro Egg",
    "General Kong Egg",
    "Pegasus Egg"
}

local availableEggTypeNames = orderedEggTypeNames
selectedEggTypeNames = {availableEggTypeNames[1]} -- Default to first
local availablePetDropdown = {}
local availablePlacePositions = {}
local lastPlaceIndex = 1

local function scanAvailablePets()
    availablePetDropdown = {}
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local eggFolder = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Data") and LocalPlayer.PlayerGui.Data:FindFirstChild("Egg")
    if eggFolder and selectedEggTypeNames and #selectedEggTypeNames > 0 then
        local selectedTs = {}
        for _, name in ipairs(selectedEggTypeNames) do
            table.insert(selectedTs, eggTypeMap[name])
        end
        for _, obj in ipairs(eggFolder:GetChildren()) do
            local uid = obj.Name
            local t = obj:GetAttribute("T")
            if t and table.find(selectedTs, t) and not obj:FindFirstChild("DI") then
                local displayName = (t or "Unknown") .. " (" .. uid .. ")"
                table.insert(availablePetDropdown, {uid = uid, display = displayName})
            end
        end
    end
    if #availablePetDropdown == 0 then
        availablePetDropdown = {{uid = "", display = "No pets found"}}
    end
end

local function scanPlacePositions()
    availablePlacePositions = {}
    local workspaceArt = workspace:FindFirstChild("Art")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local islandName = nil
    if LocalPlayer and LocalPlayer:GetAttribute("AssignedIslandName") then
        islandName = LocalPlayer:GetAttribute("AssignedIslandName")
    end
    if workspaceArt and islandName then
        local islandFolder = workspaceArt:FindFirstChild(islandName)
        if islandFolder then
            local children = islandFolder:GetChildren()
            table.sort(children, function(a, b) return a.Name < b.Name end)
            for _, obj in ipairs(children) do
                if obj:IsA("BasePart") and obj.Name:find("Farm_split") then
                    table.insert(availablePlacePositions, obj.Position)
                end
            end
        end
    end
end

scanAvailablePets()
scanPlacePositions()

if config.SelectedEggTypeNames and type(config.SelectedEggTypeNames) == "table" and #config.SelectedEggTypeNames > 0 then
    selectedEggTypeNames = config.SelectedEggTypeNames
end

local AutoPlaceEggGroup = MainTab:AddRightGroupbox("Auto Place Egg", "egg-fried")
AutoPlaceEggGroup:AddLabel("Complete Your Plot for")
AutoPlaceEggGroup:AddLabel("Accurate placing")


AutoPlaceEggGroup:AddDropdown("EggTypeToPlaceDropdown", {
    Text = "Select Egg(s) to Auto Place",
    Values = availableEggTypeNames,
    Multi = true, -- Correct property for Obsidian multi-select
    Default = selectedEggTypeNames,
    Tooltip = "Choose which egg types to auto place (all pets of these types without DI)",
    Callback = function(values)
        selectedEggTypeNames = {}
        for name, active in pairs(values) do
            if active then table.insert(selectedEggTypeNames, name) end
        end
        config.SelectedEggTypeNames = selectedEggTypeNames
        saveConfig()
        scanAvailablePets()
    end
})

AutoPlaceEggGroup:AddToggle("AutoPlaceEggToggle", {
    Text = "Auto Place Selected Pets",
    Default = autoPlaceEggEnabled,
    Tooltip = "Automatically places all pets of the selected type (without DI) at the next valid Farm_split positions",
    Callback = function(state)
        autoPlaceEggEnabled = state
        config.AutoPlaceEggEnabled = state
        saveConfig()
    end
})


task.spawn(function()
    if autoBuyIslandEggEnabled then
    end
    if autoPlaceEggEnabled then
    end
    while task.wait(1) do
        scanPlacePositions()

        if config.SelectedEggTypeNames and type(config.SelectedEggTypeNames) == "table" then
            selectedEggTypeNames = config.SelectedEggTypeNames
        end
        scanAvailablePets()
        if autoPlaceEggEnabled and #availablePetDropdown > 0 and #availablePlacePositions > 0 then
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local eggFolder = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Data") and LocalPlayer.PlayerGui.Data:FindFirstChild("Egg")
            for i, pet in ipairs(availablePetDropdown) do
                local petObj = eggFolder and eggFolder:FindFirstChild(pet.uid)
                if petObj and not petObj:FindFirstChild("DI") then
                    if lastPlaceIndex > #availablePlacePositions then lastPlaceIndex = 1 end
                    local dst = availablePlacePositions[lastPlaceIndex]
                    -- Add 10 studs to the Y (height) position
                    dst = Vector3.new(dst.X, dst.Y + 10, dst.Z)
                    lastPlaceIndex = lastPlaceIndex + 1
                    -- Focus first
                    local focusArgs = {
                        [1] = "Focus",
                        [2] = pet.uid
                    }
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Remote", 9e9)
                        :WaitForChild("CharacterRE", 9e9)
                        :FireServer(unpack(focusArgs))
                    -- Place after focus
                    local args = {
                        [1] = "Place",
                        [2] = {
                            ["DST"] = dst,
                            ["ID"] = pet.uid,
                        }
                    }
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Remote", 9e9)
                        :WaitForChild("CharacterRE", 9e9)
                        :FireServer(unpack(args))
                end
            end
        end
    end
end)


-- ==========================
-- Auto Hatch Setup
local autoHatchEnabled = config.AutoHatchEnabled or false

MainGroup:AddToggle("AutoHatchToggle", {
    Text = "Auto Hatch Eggs",
    Default = autoHatchEnabled,
    Tooltip = "Automatically hatches ALL eggs found in PlayerBuiltBlocks (non-blocking)",
    Callback = function(state)
        autoHatchEnabled = state
        config.AutoHatchEnabled = state
        saveConfig()
    end
})


task.spawn(function()
    while task.wait(0.5) do
        if autoHatchEnabled then
            local blocks = workspace:FindFirstChild("PlayerBuiltBlocks")
            if blocks then
                for _, obj in ipairs(blocks:GetChildren()) do
                    local root = obj:FindFirstChild("RootPart")
                    if root and root:FindFirstChild("RF") then
                        task.spawn(function()
                            -- ✅ Call in a separate thread so we don't block the main loop
                            local success, err = pcall(function()
                                root.RF:InvokeServer("Hatch")
                            end)
                            if success then
                            else
                                warn("❌ Failed to hatch:", obj.Name, err)
                            end
                        end)
                        task.wait(0.1) -- small delay between spawns (avoid spam kick)
                    end
                end
            end
        end
    end
end)

-- ==========================


-- ✅ Auto Sell Setup
local autoSellEnabled = config.AutoSellEnabled or false


MainGroup:AddToggle("AutoSellToggle", {
    Text = "Auto Sell Pets + Eggs",
    Default = autoSellEnabled,
    Tooltip = "Automatically sells all pets and eggs on a short interval",
    Callback = function(state)
        autoSellEnabled = state
        config.AutoSellEnabled = state
        saveConfig()
    end
})

-- 🏃‍♂️ Auto Sell Loop
task.spawn(function()
    while task.wait(5) do -- every 5 seconds to avoid spam
        if autoSellEnabled then
            task.spawn(function()
                local success, err = pcall(function()
                    local args = { "SellAll", "All", "All" }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("PetRE", 9e9):FireServer(unpack(args))
                end)
                if success then
                else
                    warn("❌ Auto Sell failed:", err)
                end
            end)
        end
    end
end)



local autoClaimAllPetsEnabled = false
if config.AutoClaimAllPetsEnabled ~= nil then
    autoClaimAllPetsEnabled = config.AutoClaimAllPetsEnabled
end
local autoClaimPetIndex = 1

MainGroup:AddToggle("AutoClaimAllPetsToggle", {
    Text = "Auto Collect Coin Pets",
    Default = autoClaimAllPetsEnabled,
    Tooltip = "Automatically claims all pets in Data.Pets every 5 seconds",
    Callback = function(state)
        autoClaimAllPetsEnabled = state
        config.AutoClaimAllPetsEnabled = state
        saveConfig()
    end
})

    task.spawn(function()
        while true do
            if autoClaimAllPetsEnabled then
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local petsFolder = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Data") and LocalPlayer.PlayerGui.Data:FindFirstChild("Pets")
                if petsFolder then
                    local claimedCount = 0
                    for _, petObj in ipairs(petsFolder:GetChildren()) do
                        local uid = petObj.Name
                        local args = { [1] = "Claim" }
                        local petBlock = workspace:FindFirstChild("Pets") and workspace.Pets:FindFirstChild(uid)
                        if petBlock and petBlock:FindFirstChild("RootPart") and petBlock.RootPart:FindFirstChild("RE") then
                            petBlock.RootPart.RE:FireServer(unpack(args))
                            claimedCount = claimedCount + 1
                        end
                    end
                    if claimedCount > 0 then
                    end
                end
            end
            task.wait(1)
        end
    end)


    

-- ⚙️ CONFIG + STATE
local autoClaimPassEnabled = config.AutoClaimSeasonPass or false
local maxSeasonPassLevel = 50 -- levels 1 to 50

-- 🔧 Helper: claim a specific level
local function claimSeasonPassLevel(lv)
    local args = {
        [1] = {
            ["LV"] = lv;
            ["T"] = "Claim";
        };
    }

    game:GetService("ReplicatedStorage")
        :WaitForChild("Remote", 9e9)
        :WaitForChild("SeasonPassRE", 9e9)
        :FireServer(unpack(args))

end

-- 🔁 Claim ALL levels function
local function claimAllSeasonPass()
    for i = 1, maxSeasonPassLevel do
        claimSeasonPassLevel(i)
        task.wait(0.2) -- delay to prevent spamming
    end
end

MainGroup:AddToggle("AutoClaimSeasonPassToggle", {
    Text = "Auto-Claim Season Pass (1-50)",
    Default = autoClaimPassEnabled,
    Tooltip = "Automatically claim rewards from all Season Pass levels",
    Callback = function(state)
        autoClaimPassEnabled = state
        config.AutoClaimSeasonPass = state
        saveConfig()
    end
})

-- Background auto-claim loop
task.spawn(function()
    while task.wait(15) do -- runs every 15s
        if autoClaimPassEnabled then
            claimAllSeasonPass()
        end
    end
end)



-- Auto Buy Food (preserve exact table order & support multi-select)
local autoBuyFoodEnabled = config.AutoBuyFoodEnabled or false

-- Map (displayName -> callName) — exactly as you provided
local foodDisplayMap = {
    ["Strawberry"] = "Strawberry",
    ["Blueberry"] = "Blueberry",
    ["Watermelon"] = "Watermelon",
    ["Apple"] = "Apple",
    ["Orange"] = "Orange",
    ["Corn"] = "Corn",
    ["Banana"] = "Banana",
    ["Grape"] = "Grape",
    ["Pear"] = "Pear",
    ["Pine Apple"] = "PineApple",
    ["Dragon Fruit"] = "DragonFruit",
    ["Gold Mango"] = "GoldMango",
    ["Bloodstone Cycad"] = "BloodstoneCycad",
    ["Colossal Pinecone"] = "ColossalPinecone",
    ["Volt Ginkgo"] = "VoltGinkgo",
    ["Deepsea Pearl Fruit"] = "DeepseaPearlFruit",
    ["Durian"] = "Durian"
}

-- EXACT ordered list (preserves the order you specified)
local availableFoodDisplayNames = {
    "Strawberry",
    "Blueberry",
    "Watermelon",
    "Apple",
    "Orange",
    "Corn",
    "Banana",
    "Grape",
    "Pear",
    "Pine Apple",
    "Dragon Fruit",
    "Gold Mango",
    "Bloodstone Cycad",
    "Colossal Pinecone",
    "Volt Ginkgo",
    "Deepsea Pearl Fruit",
    "Durian"
}

-- Load saved config (config.SelectedFoods stores CALL names like "PineApple")
local selectedFoodDisplays = {}
if config.SelectedFoods and type(config.SelectedFoods) == "table" then
    -- build a set of saved call names for quick lookup
    local savedSet = {}
    for _, callName in ipairs(config.SelectedFoods) do
        savedSet[callName] = true
    end
    -- keep order by iterating availableFoodDisplayNames
    for _, displayName in ipairs(availableFoodDisplayNames) do
        local callName = foodDisplayMap[displayName]
        if savedSet[callName] then
            table.insert(selectedFoodDisplays, displayName)
        end
    end
end
if #selectedFoodDisplays == 0 then
    selectedFoodDisplays = { availableFoodDisplayNames[1] } -- default to first if nothing saved
end

-- UI
local AutoBuyFoodGroup = MainTab:AddLeftGroupbox("Auto Buy Food", "meat")

AutoBuyFoodGroup:AddDropdown("FoodDropdown", {
    Text = "Select Food(s) to Buy",
    Values = availableFoodDisplayNames,
    Multi = true,
    Default = selectedFoodDisplays, -- array of display names (order preserved)
    Tooltip = "Choose which food to auto-buy from FoodStore",
    Callback = function(values)
        -- `values` is expected to be a table mapping displayName -> boolean
        selectedFoodDisplays = {}
        local selectedCallNames = {}
        for _, displayName in ipairs(availableFoodDisplayNames) do
            if values[displayName] then
                table.insert(selectedFoodDisplays, displayName)
                table.insert(selectedCallNames, foodDisplayMap[displayName])
            end
        end
        -- save as CALL names so reloads are consistent
        config.SelectedFoods = selectedCallNames
        saveConfig()
    end
})

AutoBuyFoodGroup:AddToggle("AutoBuyFoodToggle", {
    Text = "Auto Buy Selected Food",
    Default = autoBuyFoodEnabled,
    Tooltip = "Automatically buys selected food items at a short interval",
    Callback = function(state)
        autoBuyFoodEnabled = state
        config.AutoBuyFoodEnabled = state
        saveConfig()
    end
})

-- Auto Buy Loop
task.spawn(function()
    while task.wait(1) do
        if autoBuyFoodEnabled and selectedFoodDisplays and #selectedFoodDisplays > 0 then
            for _, displayName in ipairs(selectedFoodDisplays) do
                local callName = foodDisplayMap[displayName]
                if callName then
                    local args = { callName }
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Remote", 9e9)
                            :WaitForChild("FoodStoreRE", 9e9)
                            :FireServer(unpack(args))
                    end)
                    if ok then
                    else
                        warn("❌ Auto Buy Food failed for", callName, ":", err)
                    end
                end
            end
        end
    end
end)


-- ===========================
-- Auto Buy Fishing Bait (dropdown + toggle)
-- ===========================
local autoBuyBaitEnabled = config.AutoBuyBaitEnabled or false

local baitDisplayMap = {
    ["Cheese Bait"] = "FishingBait1",
    ["Fly Bait"] = "FishingBait2",
    ["Fish Bait"] = "FishingBait3",
}

local availableBaitDisplayNames = {
    "Cheese Bait",
    "Fly Bait",
    "Fish Bait"
}

-- Load saved baits (stores CALL names in config)
local selectedBaitDisplays = {}
if config.SelectedBaits and type(config.SelectedBaits) == "table" then
    local savedSet = {}
    for _, callName in ipairs(config.SelectedBaits) do
        savedSet[callName] = true
    end
    for _, displayName in ipairs(availableBaitDisplayNames) do
        local callName = baitDisplayMap[displayName]
        if savedSet[callName] then
            table.insert(selectedBaitDisplays, displayName)
        end
    end
end
if #selectedBaitDisplays == 0 then
    selectedBaitDisplays = { availableBaitDisplayNames[1] }
end

local AutoBuyBaitGroup = MainTab:AddLeftGroupbox("Auto Buy Bait", "shrimp")

AutoBuyBaitGroup:AddDropdown("BaitDropdown", {
    Text = "Select Bait(s) to Buy",
    Values = availableBaitDisplayNames,
    Multi = true,
    Default = selectedBaitDisplays,
    Tooltip = "Choose which fishing bait(s) to auto-buy",
    Callback = function(values)
        selectedBaitDisplays = {}
        local selectedCallNames = {}
        for _, displayName in ipairs(availableBaitDisplayNames) do
            if values[displayName] then
                table.insert(selectedBaitDisplays, displayName)
                table.insert(selectedCallNames, baitDisplayMap[displayName])
            end
        end
        config.SelectedBaits = selectedCallNames
        saveConfig()
    end
})

AutoBuyBaitGroup:AddToggle("AutoBuyBaitToggle", {
    Text = "Auto Buy Selected Bait",
    Default = autoBuyBaitEnabled,
    Tooltip = "Automatically buys selected fishing bait(s) every few seconds",
    Callback = function(state)
        autoBuyBaitEnabled = state
        config.AutoBuyBaitEnabled = state
        saveConfig()
    end
})

-- Auto Buy Bait Loop (separate loop)
task.spawn(function()
    while task.wait(1) do
        if autoBuyBaitEnabled and selectedBaitDisplays and #selectedBaitDisplays > 0 then
            for _, displayName in ipairs(selectedBaitDisplays) do
                local callName = baitDisplayMap[displayName]
                if callName then
                    local args = {
                        [1] = "buy",
                        [2] = callName
                    }
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Remote", 9e9)
                            :WaitForChild("FishingRE", 9e9)
                            :FireServer(unpack(args))
                    end)
                    if ok then
                    else
                        warn("❌ Auto Buy Bait failed for", callName, ":", err)
                    end
                end
            end
        end
    end
end)

-- ===========================
-- Auto Fish + Auto Reel + NoClip (with Focus, Start & Exit)
-- ===========================
local autoFishEnabled = config.AutoFishEnabled or false
local selectedFishingBait = config.SelectedFishingBait or "FishingBait1"

local fishingBaitDisplayMap = {
    ["Cheese Bait"] = "FishingBait1",
    ["Fly Bait"] = "FishingBait2",
    ["Fish Bait"] = "FishingBait3",
}

local fishingBaitDisplayNames = {"Cheese Bait", "Fly Bait", "Fish Bait"}
local selectedFishingBaitDisplay = nil
for display, call in pairs(fishingBaitDisplayMap) do
    if call == selectedFishingBait then
        selectedFishingBaitDisplay = display
        break
    end
end
if not selectedFishingBaitDisplay then
    selectedFishingBaitDisplay = fishingBaitDisplayNames[1]
    selectedFishingBait = fishingBaitDisplayMap[selectedFishingBaitDisplay]
end

local AutoFishGroup = MainTab:AddLeftGroupbox("Auto Fish", "fish")

AutoFishGroup:AddDropdown("AutoFishBaitDropdown", {
    Text = "Select Bait",
    Values = fishingBaitDisplayNames,
    Multi = false,
    Default = selectedFishingBaitDisplay,
    Tooltip = "Choose which bait to use for auto fishing",
    Callback = function(value)
        selectedFishingBaitDisplay = value
        selectedFishingBait = fishingBaitDisplayMap[value]
        config.SelectedFishingBait = selectedFishingBait
        saveConfig()
    end
})

-- Function to enable/disable NoClip
local function setNoClip(state)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local Character = LocalPlayer and LocalPlayer.Character
    if not Character then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide ~= nil then
            part.CanCollide = not state
        end
    end
end

AutoFishGroup:AddToggle("AutoFishToggle", {
    Text = "Enable Auto Fish (NoClip Included)",
    Default = autoFishEnabled,
    Tooltip = "Automatically focuses FishRob, starts fishing, throws line, reels in, and disables collisions",
    Callback = function(state)
        autoFishEnabled = state
        config.AutoFishEnabled = state
        saveConfig()

        local remoteFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9)

        if state then
            -- ✅ Do Focus & Start when enabling
            local success, err = pcall(function()
                remoteFolder:WaitForChild("CharacterRE", 9e9):FireServer("Focus", "FishRob")
                remoteFolder:WaitForChild("FishingRE", 9e9):FireServer("Start")
            end)
            if not success then
                warn("⚠️ Failed to Focus/Start fishing:", err)
            end

            setNoClip(true)
        else
            -- ✅ Send EXIT when disabling
            local success, err = pcall(function()
                remoteFolder:WaitForChild("FishingRE", 9e9):FireServer("EXIT")
            end)
            if not success then
                warn("⚠️ Failed to send EXIT:", err)
            end

            setNoClip(false)
        end
    end
})

-- Auto Fish Throw Loop
task.spawn(function()
    while task.wait(3) do
        if autoFishEnabled and selectedFishingBait then
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local charPos = LocalPlayer.Character.HumanoidRootPart.Position
                local throwPos = charPos + Vector3.new(0, -5, -15) -- throw forward
                local args = {
                    [1] = "Throw",
                    [2] = {
                        ["Bait"] = selectedFishingBait,
                        ["Pos"] = throwPos,
                    }
                }
                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Remote", 9e9)
                        :WaitForChild("FishingRE", 9e9)
                        :FireServer(unpack(args))
                end)
            end
        end
    end
end)

-- Auto Reel (UI Click Spam)
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    while task.wait(0.05) do
        if autoFishEnabled then
            local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            local screenFishing = playerGui and playerGui:FindFirstChild("ScreenFishing")
            if screenFishing and screenFishing.Enabled and screenFishing:FindFirstChild("PBar") and screenFishing.PBar.Visible then
                -- Simulate left mouse click at the center of the screen
                pcall(function()
                    local camera = workspace.CurrentCamera
                    local centerX = camera.ViewportSize.X / 2
                    local centerY = camera.ViewportSize.Y / 2
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                end)
            end
        end
    end
end)


-- ===========================
-- Auto Place Fish Egg (Dynamic WaterFarm Detection)
-- ===========================
local autoPlaceFishEggEnabled = config.AutoPlaceFishEggEnabled or false

local fishEggDisplayMap = {
    ["Seaweed Egg"] = "SeaweedEgg",
    ["Clownfish Egg"] = "ClownfishEgg",
    ["Lionfish Egg"] = "LionfishEgg",
    ["Shark Egg"] = "SharkEgg",
    ["Anglerfish Egg"] = "AnglerfishEgg",
    ["Octopus Egg"] = "OctopusEgg",
    ["Sea Dragon Egg"] = "SeaDragonEgg"
}

local fishEggDisplayNames = {
    "Seaweed Egg",
    "Clownfish Egg",
    "Lionfish Egg",
    "Shark Egg",
    "Anglerfish Egg",
    "Octopus Egg",
    "Sea Dragon Egg"
}


-- Load saved config
local selectedFishEggs = {}
if config.SelectedFishEggs and type(config.SelectedFishEggs) == "table" then
    selectedFishEggs = config.SelectedFishEggs
else
    selectedFishEggs = {["Seaweed Egg"] = true} -- Default
end

-- Dynamic scan function for WaterFarm parts
local waterFarmParts = {}
local function scanWaterFarmParts()
    waterFarmParts = {}
    local artFolder = workspace:FindFirstChild("Art")
    local islandName = nil
    local player = game:GetService("Players").LocalPlayer
    if player and player:GetAttribute("AssignedIslandName") then
        islandName = player:GetAttribute("AssignedIslandName")
    end
    local islandFolder = artFolder and islandName and artFolder:FindFirstChild(islandName)
    if islandFolder then
        for _, obj in ipairs(islandFolder:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name:find("^WaterFarm") then
                table.insert(waterFarmParts, obj)
            end
        end
        table.sort(waterFarmParts, function(a, b) return a.Name < b.Name end)
    end
end
scanWaterFarmParts()

local currentPlaceIndex = 1

-- GUI setup
local AutoPlaceFishEggGroup = MainTab:AddRightGroupbox("Auto Place Fish Egg", "fish-symbol")

AutoPlaceFishEggGroup:AddDropdown("AutoPlaceFishEggDropdown", {
    Text = "Select Fish Egg(s)",
    Values = fishEggDisplayNames,
    Multi = true,
    Default = (function()
        local defaults = {}
        for k, active in pairs(selectedFishEggs) do
            if active then table.insert(defaults, k) end
        end
        return defaults
    end)(),
    Tooltip = "Choose which fish eggs to auto-place",
    Callback = function(values)
        selectedFishEggs = values
        config.SelectedFishEggs = selectedFishEggs
        saveConfig()
        local selectedList = {}
        for n, active in pairs(values) do if active then table.insert(selectedList, n) end end
    end
})

AutoPlaceFishEggGroup:AddToggle("AutoPlaceFishEggToggle", {
    Text = "Enable Auto Place Fish Egg",
    Default = autoPlaceFishEggEnabled,
    Tooltip = "Automatically places selected fish eggs into WaterFarm spots",
    Callback = function(state)
        autoPlaceFishEggEnabled = state
        config.AutoPlaceFishEggEnabled = state
        saveConfig()
    end
})

-- Placement loop (UPDATED with Unique ID + Attribute T)
task.spawn(function()
    while task.wait(2) do
        if autoPlaceFishEggEnabled then
            scanWaterFarmParts()
            if #waterFarmParts == 0 then
            end

            local player = game:GetService("Players").LocalPlayer
            local eggFolder = player.PlayerGui and player.PlayerGui:FindFirstChild("Data") and player.PlayerGui.Data:FindFirstChild("Egg")

            if eggFolder and #waterFarmParts > 0 then
                for _, egg in ipairs(eggFolder:GetChildren()) do
                    -- 🔑 Get unique ID and Type from attributes
                    local eggUID = egg.Name
                    local eggType = egg:GetAttribute("T")  -- "SeaweedEgg", "ClownfishEgg", etc.

                    -- Check if egg matches our selected ones
                    for displayName, callName in pairs(fishEggDisplayMap) do
                        if selectedFishEggs[displayName] and eggType == callName then
                            local dst = waterFarmParts[currentPlaceIndex].Position + Vector3.new(0, 10, 0) -- Place 10 studs above
                            currentPlaceIndex = currentPlaceIndex + 1
                            if currentPlaceIndex > #waterFarmParts then currentPlaceIndex = 1 end

                            -- Focus then Place
                            pcall(function()
                                local remoteFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9)
                                remoteFolder:WaitForChild("CharacterRE", 9e9):FireServer("Focus", eggUID)
                                task.wait(0.2)
                                remoteFolder:WaitForChild("CharacterRE", 9e9):FireServer("Place", {
                                    ["DST"] = dst,
                                    ["ID"] = eggUID
                                })
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 🔧 CONFIG + STATE
local autoFeedEnabled = config.AutoFeedEnabled or false
local selectedCategory = config.SelectedFeedCategory or "Ocean"
local selectedFeedPetTypes = config.SelectedFeedPetTypes or {} -- saved as array
local selectedFood = config.SelectedFood or "Watermelon"

-- Static lists you provided
local mountainPets = {
    "Capy1", "Capy2", "Pig", "Capy3", "Dog", "Cat", "CapyL1", "Cow", "CapyL2", "Sheep", "CapyL3",
    "Horse", "Zebra", "Giraffe", "Hippo", "Elephant", "Rabbit", "Mouse", "Tiger", "Fox", "Panda",
    "Toucan", "Snake", "Butterfly", "Seaturtle", "Bear", "Lion", "Rhino", "Kangroo", "Gorilla",
    "Rex", "Dragon", "Griffin", "Unicorn", "Wolverine", "Okapi", "Panther", "Wolf", "Alpaca",
    "Phoenix", "Peacock", "Sheep_E1", "Horse_E1", "Zebra_E1", "Giraffe_E1", "Hippo_E1",
    "Ankylosaurus","Velociraptor","Stegosaurus","Triceratops","Brontosaurus","Pterosaur","Pachycephalosaur",
    "Plesiosaur","Tyrannosaurus",
}

local oceanPets = {
    "AngelFish", "Bighead", "Butterflyfish", "Needlefish", "Hairtail", "Tuna", "Catfish",
    "Tigerfish", "Flounder", "Lionfish", "Alligator", "Sawfish", "ElectricEel", "Dolphin",
    "Shark","Anglerfish","Manta"
}

-- 🥦 Food Map (DisplayName -> InternalName)
local foodDisplayMap = {
    ["Strawberry"] = "Strawberry",
    ["Blueberry"] = "Blueberry",
    ["Watermelon"] = "Watermelon",
    ["Apple"] = "Apple",
    ["Orange"] = "Orange",
    ["Corn"] = "Corn",
    ["Banana"] = "Banana",
    ["Grape"] = "Grape",
    ["Pear"] = "Pear",
    ["Pine Apple"] = "PineApple",
    ["Dragon Fruit"] = "DragonFruit",
    ["Gold Mango"] = "GoldMango",
    ["Bloodstone Cycad"] = "BloodstoneCycad",
    ["Colossal Pinecone"] = "ColossalPinecone",
    ["Volt Ginkgo"] = "VoltGinkgo",
    ["Deepsea Pearl Fruit"] = "DeepseaPearlFruit",
    ["Durian"] = "Durian"
}

-- Build display list for dropdown
local foodDisplayList = {}
for i, displayName in ipairs(availableFoodDisplayNames) do
    table.insert(foodDisplayList, displayName)
end

-- Helper: get pets based on category
local function getFilteredPets(category)
    return category == "Mountain" and mountainPets or oceanPets
end

-- Helper: safe dropdown updater
local function updatePetDropdownValues(control, newValues, defaults)
    if not control then return end
    pcall(function()
        if control.SetOptions then control:SetOptions(newValues) end
        if control.SetValues then control:SetValues(newValues) end
        if control.UpdateValues then control:UpdateValues(newValues) end
        if control.Values then control.Values = newValues end
        if defaults and control.SetValue then control:SetValue(defaults) end
    end)
end

-- 🔽 UI CREATION
local FeedGroup = MainTab:AddRightGroupbox("Auto Feed Pets", "beef")
local categoryControl, petControl, foodControl

-- 1️⃣ Category Dropdown
categoryControl = FeedGroup:AddDropdown("PetCategoryDropdown", {
    Text = "Select Category",
    Values = {"Mountain", "Ocean"},
    Default = selectedCategory,
    Multi = false,
    Callback = function(value)
        selectedCategory = value
        config.SelectedFeedCategory = value
        saveConfig()

        local petList = getFilteredPets(value)
        local filteredSelected = {}
        for _, s in ipairs(selectedFeedPetTypes) do
            if table.find(petList, s) then table.insert(filteredSelected, s) end
        end
        selectedFeedPetTypes = filteredSelected
        config.SelectedFeedPetTypes = filteredSelected
        saveConfig()

        updatePetDropdownValues(petControl, petList, filteredSelected)
    end
})

-- 2️⃣ Pet Dropdown (multi)
petControl = FeedGroup:AddDropdown("FeedPetDropdown", {
    Text = "Select Pet(s) to Feed",
    Values = getFilteredPets(selectedCategory),
    Default = selectedFeedPetTypes,
    Multi = true,
    Callback = function(values)
        selectedFeedPetTypes = {}
        if type(values) == "table" then
            local isMap = false
            for k,v in pairs(values) do
                if type(k) == "string" and type(v) == "boolean" then isMap = true break end
            end
            if isMap then
                for taskName, active in pairs(values) do
                    if active then table.insert(selectedFeedPetTypes, taskName) end
                end
            else
                for _, petName in ipairs(values) do
                    table.insert(selectedFeedPetTypes, petName)
                end
            end
        end
        config.SelectedFeedPetTypes = selectedFeedPetTypes
        saveConfig()
    end
})

-- 3️⃣ Food Dropdown (uses display names but stores internal name)
foodControl = FeedGroup:AddDropdown("FoodDropdown", {
    Text = "Select Food",
    Values = foodDisplayList,
    Default = selectedFood, -- NOTE: this should match a DISPLAY name, not internal key
    Multi = false,
    Callback = function(displayValue)
        local internalValue = foodDisplayMap[displayValue] or displayValue
        selectedFood = internalValue
        config.SelectedFood = internalValue
        saveConfig()
    end
})

-- 🔛 Toggle (Auto Feed + Focus)
FeedGroup:AddToggle("AutoFeedToggle", {
    Text = "Enable Auto Feed",
    Default = autoFeedEnabled,
    Callback = function(state)
        autoFeedEnabled = state
        config.AutoFeedEnabled = state
        saveConfig()

        local charRE = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 9e9):WaitForChild("CharacterRE", 9e9)
        if state then
            charRE:FireServer("Focus", selectedFood)
        else
            charRE:FireServer("Focus")
        end
    end
})

-- 🔁 Auto Feed Loop
task.spawn(function()
    while task.wait(1) do
        if autoFeedEnabled and #selectedFeedPetTypes > 0 then
            local player = game:GetService("Players").LocalPlayer
            local petFolder = player.PlayerGui:WaitForChild("Data", 9e9):WaitForChild("Pets", 9e9)

            for _, pet in ipairs(petFolder:GetChildren()) do
                local petType = pet:GetAttribute("T")
                if petType and table.find(selectedFeedPetTypes, petType) then
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Remote", 9e9)
                        :WaitForChild("PetRE", 9e9)
                        :FireServer("Feed", pet.Name)
                end
            end
        end
    end
end)

-- ===========================
-- EVENT MUST DELETE LATER FOR UPDATE
-- ===========================
local IceEvent = EventTab:AddLeftGroupbox("Ice Event", "snowflake")


-- Helper: get keys from a dictionary
local function getTableKeys(tbl)
    local keys = {}
    for k,_ in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- Task List (from your dump)
local snowTasks = {
    ["Hatch Ice Egg (x5)"] = "Task_1",
    ["Sell Pets (x5)"] = "Task_3",
    ["Buy Evolution Egg (x3)"] = "Task_4",
    ["Buy Ice Egg (x1)"] = "Task_5",
    ["Hatch Evolution Egg (x10)"] = "Task_7",
    ["Stay Online (20 min)"] = "Task_8",
}

-- Config state
autoClaimEnabled = config.AutoClaimSnowTask or false -- shared global so toggle works
local selectedSnowTasks = config.SelectedSnowTasks or { "Task_8" } -- now array for multi-select

-- Helper: claim function
local function claimSnowTask(taskId)
    local args = {
        [1] = {
            ["event"] = "claimreward",
            ["id"] = taskId
        }
    }
    game:GetService("ReplicatedStorage")
        :WaitForChild("Remote", 9e9)
        :WaitForChild("DinoEventRE", 9e9)
        :FireServer(unpack(args))
end

-- Build keys list for dropdown
local snowTaskKeys = getTableKeys(snowTasks)

-- Find which display names match selected task IDs
local function getDisplayNamesForTasks(taskIds)
    local names = {}
    for _,tid in ipairs(taskIds) do
        for name,id in pairs(snowTasks) do
            if id == tid then table.insert(names, name) end
        end
    end
    return names
end

-- Dropdown (multi-select)
IceEvent:AddDropdown("SnowTaskDropdown", {
    Text = "Select Task(s)",
    Values = snowTaskKeys,
    Default = getDisplayNamesForTasks(selectedSnowTasks),
    Multi = true,
    Callback = function(values)
        selectedSnowTasks = {}
        if type(values) == "table" then
            local isMap = false
            for k,v in pairs(values) do
                if type(k) == "string" and type(v) == "boolean" then
                    isMap = true break
                end
            end
            if isMap then
                for taskName, active in pairs(values) do
                    if active and snowTasks[taskName] then
                        table.insert(selectedSnowTasks, snowTasks[taskName])
                    end
                end
            else
                for _,taskName in ipairs(values) do
                    if snowTasks[taskName] then
                        table.insert(selectedSnowTasks, snowTasks[taskName])
                    end
                end
            end
        end
        config.SelectedSnowTasks = selectedSnowTasks
        saveConfig()
    end
})

-- Toggle for auto-claim
IceEvent:AddToggle("AutoClaimSnowTaskToggle", {
    Text = "Auto-Claim Selected Task(s)",
    Default = autoClaimEnabled,
    Callback = function(state)
        autoClaimEnabled = state -- ✅ Shared variable
        config.AutoClaimSnowTask = state
        saveConfig()
    end
})

-- Add a logo/icon on top of the groupbox
IceEvent:AddLabel("❄️ Auto-Claim Snow Tasks ❄️")

-- Loop to auto-claim all selected tasks
task.spawn(function()
    while true do
        task.wait(1) -- run every 10 seconds
        if autoClaimEnabled then
            if selectedSnowTasks and #selectedSnowTasks > 0 then
                for _, taskId in ipairs(selectedSnowTasks) do
                    claimSnowTask(taskId)
                end
            end
        end
    end
end)


local SnowShop = EventTab:AddRightGroupbox("Snow Shop Rewards", "gift")

-- ✅ NEW: Snow Shop Rewards System (Order Preserved)
local snowRewards = {
    ["Luck Potion (x3)"] = "Reward_101",
    ["Orange (x1)"] = "Reward_102",
    ["Lottery Ticket (x1)"] = "Reward_103",
    ["Banana (x1)"] = "Reward_104",
    ["Hatch Potion (x5)"] = "Reward_105",
    ["Snow Bunny Egg"] = "Reward_106",
    ["Dark Goaty Egg"] = "Reward_107",
    ["Pear (x1)"] = "Reward_108",
    ["Rhino Rock Egg"] = "Reward_109",
    ["Saber Cub Egg"] = "Reward_110",
    ["Pineapple (x1)"] = "Reward_111",
    ["General Kong Egg"] = "Reward_112",
    ["Bloodstone Cycad"] = "Reward_113",
    ["Gold Mango (x1)"] = "Reward_114",
    ["Dragon Fruit (x1)"] = "Reward_115",
    ["Deepsea Pearl Fruit"] = "Reward_116",
    ["Colossal Pinecone"] = "Reward_117",
    ["Volt Ginkgo"] = "Reward_118",
    ["Durian (x1)"] = "Reward_119",
    ["Snow Weather"] = "Reward_120",
}

autoExchangeEnabled = config.AutoExchangeSnowReward or false
local selectedRewards = config.SelectedSnowRewards or { "Reward_101" }

-- Convert dictionary into array while keeping your given order
local rewardKeysOrdered = {}
for name, _ in pairs(snowRewards) do
    table.insert(rewardKeysOrdered, name)
end

-- But pairs() does not guarantee order, so let's just manually use your keys
rewardKeysOrdered = {
    "Luck Potion (x3)",
    "Orange (x1)",
    "Lottery Ticket (x1)",
    "Banana (x1)",
    "Hatch Potion (x5)",
    "Snow Bunny Egg",
    "Dark Goaty Egg",
    "Pear (x1)",
    "Rhino Rock Egg",
    "Saber Cub Egg",
    "Pineapple (x1)",
    "General Kong Egg",
    "Bloodstone Cycad",
    "Gold Mango (x1)",
    "Dragon Fruit (x1)",
    "Deepsea Pearl Fruit",
    "Colossal Pinecone",
    "Volt Ginkgo",
    "Durian (x1)",
    "Snow Weather"
}

-- Claim function
local function exchangeReward(rewardId)
    local args = {
        [1] = {
            ["event"] = "exchange",
            ["id"] = rewardId
        }
    }
    game:GetService("ReplicatedStorage")
        :WaitForChild("Remote", 9e9)
        :WaitForChild("DinoEventRE", 9e9)
        :FireServer(unpack(args))

end

-- Get display names for selected rewards
local function getDisplayNamesForRewards(ids)
    local names = {}
    for _,rid in ipairs(ids) do
        for name,id in pairs(snowRewards) do
            if id == rid then table.insert(names, name) end
        end
    end
    return names
end

-- Dropdown (multi-select, ordered)
SnowShop:AddDropdown("SnowRewardDropdown", {
    Text = "Select Reward(s)",
    Values = rewardKeysOrdered, -- use our manual order
    Default = getDisplayNamesForRewards(selectedRewards),
    Multi = true,
    Callback = function(values)
        selectedRewards = {}
        for rewardName, active in pairs(values) do
            if active and snowRewards[rewardName] then
                table.insert(selectedRewards, snowRewards[rewardName])
            end
        end
        config.SelectedSnowRewards = selectedRewards
        saveConfig()
    end
})

-- Toggle
SnowShop:AddToggle("AutoExchangeSnowRewardToggle", {
    Text = "Auto-Exchange Selected Reward(s)",
    Default = autoExchangeEnabled,
    Callback = function(state)
        autoExchangeEnabled = state
        config.AutoExchangeSnowReward = state
        saveConfig()
    end
})

SnowShop:AddLabel("⛄ Auto-Exchange Snow Shop Rewards ⛄")

-- Auto-loop
task.spawn(function()
    while task.wait(1) do
        if autoExchangeEnabled and #selectedRewards > 0 then
            for _, rewardId in ipairs(selectedRewards) do
                exchangeReward(rewardId)
            end
        end
    end
end)



local SnowCurrencyGroup = EventTab:AddLeftGroupbox("Snow Event Currency", "snowflake")
local snowCurrencyLabel = SnowCurrencyGroup:AddLabel("Snow Coins: ...")

-- Function to update snow currency label
local function updateSnowCurrencyLabel()
    local player = game:GetService("Players").LocalPlayer
    local gui = player:FindFirstChild("PlayerGui")
    if gui then
        local screenDinoStore = gui:FindFirstChild("ScreenDinoStore")
        if screenDinoStore and screenDinoStore:FindFirstChild("Root") then
            local root = screenDinoStore.Root
            if root:FindFirstChild("Coin") and root.Coin:FindFirstChild("TextLabel") then
                local coinText = root.Coin.TextLabel.Text
                snowCurrencyLabel:SetText("Snow Coins: " .. tostring(coinText))
            end
        end
    end
end

-- Update every 0.5 seconds
spawn(function()
    while true do
        updateSnowCurrencyLabel()
        wait(0.5)
    end
end)

local EventEgg = EventTab:AddRightGroupbox("Auto Place Event Eggs", "egg")
-- Custom Event Eggs
-- Event Egg display-to-type mapping
local eventEggTypeMap = {
    ["Snow Bunny Egg"] = "SnowBunnyEgg",
    ["Dark Goaty Egg"] = "DarkGoatyEgg",
    ["Rhino Rock Egg"] = "RhinoRockEgg",
    ["Saber Cub Egg"] = "SaberCubEgg",
    ["General Kong Egg"] = "GeneralKongEgg"
}
local eventEggDisplayNames = {
    "Snow Bunny Egg",
    "Dark Goaty Egg",
    "Rhino Rock Egg",
    "Saber Cub Egg",
    "General Kong Egg"
}
-- Load saved config (store type names for consistency)
local selectedEventEggTypes = {}
if config.SelectedEventEggTypes and type(config.SelectedEventEggTypes) == "table" then
    selectedEventEggTypes = config.SelectedEventEggTypes
else
    selectedEventEggTypes = {eventEggTypeMap["Snow Bunny Egg"]} -- Default
end
local autoPlaceEventEggEnabled = config.AutoPlaceEventEggEnabled or false
-- Dropdown for Event Eggs (multi-select, display names)
EventEgg:AddDropdown("EventEggTypeDropdown", {
    Text = "Select Event Egg(s) to Auto Place",
    Values = eventEggDisplayNames,
    Multi = true,
    Default = (function()
        local defaults = {}
        for _, display in ipairs(eventEggDisplayNames) do
            local typeName = eventEggTypeMap[display]
            if table.find(selectedEventEggTypes, typeName) then
                table.insert(defaults, display)
            end
        end
        return defaults
    end)(),
    Tooltip = "Choose which event eggs to auto place",
    Callback = function(values)
        selectedEventEggTypes = {}
        for display, active in pairs(values) do
            if active and eventEggTypeMap[display] then
                table.insert(selectedEventEggTypes, eventEggTypeMap[display])
            end
        end
        config.SelectedEventEggTypes = selectedEventEggTypes
        saveConfig()
        scanAvailablePets() -- optional if you want to refresh available pets
    end
})
-- Toggle for Event Egg Auto-Place
EventEgg:AddToggle("AutoPlaceEventEggToggle", {
    Text = "Auto Place Selected Event Eggs",
    Default = autoPlaceEventEggEnabled,
    Tooltip = "Automatically places all selected event eggs at the next valid Farm_split positions",
    Callback = function(state)
        autoPlaceEventEggEnabled = state
        config.AutoPlaceEventEggEnabled = state
        saveConfig()
    end
})
-- Auto-placing loop for event eggs (match by type, not name)
task.spawn(function()
    while task.wait(0.3) do
        scanPlacePositions()
        if autoPlaceEventEggEnabled and #selectedEventEggTypes > 0 and #availablePlacePositions > 0 then
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local eggFolder = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Data") and LocalPlayer.PlayerGui.Data:FindFirstChild("Egg")
            if eggFolder then
                for _, petObj in ipairs(eggFolder:GetChildren()) do
                    local petType = petObj:GetAttribute("T")
                    if petType and table.find(selectedEventEggTypes, petType) and not petObj:FindFirstChild("DI") then
                        if lastPlaceIndex > #availablePlacePositions then lastPlaceIndex = 1 end
                        local dst = availablePlacePositions[lastPlaceIndex] + Vector3.new(0, 10, 0) -- Place 10 studs above
                        lastPlaceIndex = lastPlaceIndex + 1
                        -- Focus first
                        local focusArgs = {
                            [1] = "Focus",
                            [2] = petObj.Name
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Remote", 9e9)
                            :WaitForChild("CharacterRE", 9e9)
                            :FireServer(unpack(focusArgs))
                        -- Place after focus
                        local args = {
                            [1] = "Place",
                            [2] = {
                                ["DST"] = dst,
                                ["ID"] = petObj.Name,
                            }
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Remote", 9e9)
                            :WaitForChild("CharacterRE", 9e9)
                            :FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)



-- ✅ Load saved config or defaults
config.PlayerWalkSpeed = config.PlayerWalkSpeed or 30
config.PlayerJumpPower = config.PlayerJumpPower or 50
config.PlayerFlyEnabled = config.PlayerFlyEnabled or false
config.PlayerAntiAFK = config.PlayerAntiAFK or false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")



-- 🔧 Helper: Apply WalkSpeed
local function setWalkSpeed(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
    end
end

-- 🔧 Helper: Apply JumpPower
local function setJumpPower(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.UseJumpPower = true -- ✅ Needed for JumpPower to work
        hum.JumpPower = value
    end
end

-- ✅ Fly Logic
local flying = false
local flyConnection
local flyVelocity

local function toggleFly(state)
    flying = state
    if state then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyVelocity.Velocity = Vector3.zero
            flyVelocity.Parent = char.HumanoidRootPart

            flyConnection = RunService.RenderStepped:Connect(function()
                if not flying then return end
                local direction = Vector3.zero
                local cam = workspace.CurrentCamera
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    direction = direction + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    direction = direction - Vector3.new(0, 1, 0)
                end
                flyVelocity.Velocity = direction * (config.PlayerWalkSpeed * 3)
            end)
        end
    else
        if flyConnection then flyConnection:Disconnect() end
        if flyVelocity then flyVelocity:Destroy() end
    end
end

-- ✅ UI Elements
PlayerSettings:AddSlider("WalkSpeedSlider", {
    Text = "WalkSpeed",
    Min = 30,
    Max = 300,
    Default = config.PlayerWalkSpeed,
    Callback = function(value)
        config.PlayerWalkSpeed = value
        saveConfig()
        setWalkSpeed(value)
    end
})

PlayerSettings:AddSlider("JumpPowerSlider", {
    Text = "JumpPower",
    Min = 50,
    Max = 300,
    Default = config.PlayerJumpPower,
    Callback = function(value)
        config.PlayerJumpPower = value
        saveConfig()
        setJumpPower(value)
    end
})

PlayerSettings:AddToggle("FlyToggle", {
    Text = "Fly",
    Default = config.PlayerFlyEnabled,
    Callback = function(state)
        config.PlayerFlyEnabled = state
        saveConfig()
        toggleFly(state)
    end
})

PlayerSettings:AddToggle("AntiAFKToggle", {
    Text = "Anti-AFK",
    Default = config.PlayerAntiAFK,
    Callback = function(state)
        config.PlayerAntiAFK = state
        saveConfig()
        if state then
            LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

-- ✅ Auto-load logic when script runs
task.defer(function()
    setWalkSpeed(config.PlayerWalkSpeed)
    setJumpPower(config.PlayerJumpPower)
    if config.PlayerFlyEnabled then
        toggleFly(true)
    end
    if config.PlayerAntiAFK then
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
        end)
    end
end)


-- ==========================
-- Auto Hide UI on load

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


-- ==========================
-- FPS Boost Toggle (Lower Graphics)
local fpsBoostEnabled = config.FPSBoostToggle or false
local originalFPSValues = {}
local originalLightingValues = {}
local originalTerrainValues = {}
local originalRenderingQuality = nil
local fpsBoostConnection = nil

UISettingsGroup:AddToggle(
    "FPSBoostToggle",
    {
        Text = "FPS Boost (Lower Graphics)",
        Default = config.FPSBoostToggle ~= nil and config.FPSBoostToggle or false,
        Callback = function(Value)
            fpsBoostEnabled = Value
            config.FPSBoostToggle = Value
            saveConfig()
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
                    elseif obj:IsA("BasePart") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Material = obj.Material}
                        end
                        obj.Material = Enum.Material.SmoothPlastic
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
                    elseif obj:IsA("BasePart") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Material = obj.Material}
                        end
                        obj.Material = Enum.Material.SmoothPlastic
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
                        elseif obj:IsA("BasePart") then
                            obj.Material = props.Material or Enum.Material.Plastic
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

-- Auto-start FPS Boost if enabled in config
if config.FPSBoostToggle then
    fpsBoostEnabled = true
    config.FPSBoostToggle = true
    -- Directly run FPS boost logic as if toggled on
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
        elseif obj:IsA("BasePart") then
            if originalFPSValues[obj] == nil then
                originalFPSValues[obj] = {Material = obj.Material}
            end
            obj.Material = Enum.Material.SmoothPlastic
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
        elseif obj:IsA("BasePart") then
            if originalFPSValues[obj] == nil then
                originalFPSValues[obj] = {Material = obj.Material}
            end
            obj.Material = Enum.Material.SmoothPlastic
        end
    end)
end

UISettingsGroup:AddButton("Unload Script", function()
    -- Disable all toggles and update config
    autoFeedEnabled = false
    autoBuyIslandEggEnabled = false
    autoPlaceEggEnabled = false
    autoHatchEnabled = false
    autoSellEnabled = false
    autoClaimAllPetsEnabled = false
    autoBuyFoodEnabled = false
    autoBuyBaitEnabled = false
    autoFishEnabled = false
    autoPlaceFishEggEnabled = false
    autoHideUIEnabled = false
    autoClaimEnabled = false
    autoExchangeEnabled = false -- Disable Snow Shop auto-exchange
    autoClaimEnabled = false    -- Disable Snow Event auto-claim
    config.AutoFeedEnabled = false
    config.AutoBuyIslandEggEnabled = false
    config.AutoPlaceEggEnabled = false
    config.AutoHatchEnabled = false
    config.AutoSellEnabled = false
    config.AutoClaimAllPetsEnabled = false
    config.AutoBuyFoodEnabled = false
    config.AutoBuyBaitEnabled = false
    config.AutoFishEnabled = false
    config.AutoPlaceFishEggEnabled = false
    config.AutoHideUIEnabled = false
    config.AutoClaimSnowTask = false
    config.AutoExchangeSnowReward = false -- Disable Snow Shop auto-exchange in config
    config.PlayerWalkSpeed = 16 -- Reset WalkSpeed
    config.PlayerJumpPower = 50 -- Reset JumpPower
    config.PlayerFlyEnabled = false -- Disable Fly
    saveConfig()
    -- Reset WalkSpeed and JumpPower immediately
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = 30
        hum.UseJumpPower = true
        hum.JumpPower = 50
    end
    -- Disable fly logic if active
    if flying then
        flying = false
        if flyConnection then flyConnection:Disconnect() end
        if flyVelocity then flyVelocity:Destroy() end
    end

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
    print("✅ Seisen Hub unloaded and cleaned up. All auto functions disabled.")
    -- FPS Boost: Restore graphics settings if enabled
    if fpsBoostEnabled then
        fpsBoostEnabled = false
        config.FPSBoostToggle = false
        -- Disconnect FPS boost connection
        if fpsBoostConnection then
            fpsBoostConnection:Disconnect()
            fpsBoostConnection = nil
        end
        local Lighting = game:GetService("Lighting")
        local workspace = game:GetService("Workspace")
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
                elseif obj:IsA("BasePart") then
                    obj.Material = props.Material or Enum.Material.Plastic
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
end)
