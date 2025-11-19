game.StarterGui:SetCore("SendNotification", {
    Title = "Seisen Hub";
    Text = "Restaurant Tycoon 3 Script Loaded";
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
    Footer = "Restaurant Tycoon 3",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Icon = 125926861378074,
    Center = true,
    AutoShow = true,
    ShowCustomCursor = true -- Enable custom cursor
})

-- =====================
-- =====================
-- Automation Thread Watchdog (auto-restart)
local function automationWatchdog()
    task.spawn(function()
        while true do
            -- SendToTable
            if sendToTableEnabled and not sendToTableThread then
                startSendToTable()
            end
            -- AutoAcceptOrder
            if autoAcceptOrderEnabled and not autoAcceptOrderThread then
                startAutoAcceptOrder()
            end
            -- AutoCook
            if autoCookEnabled and not autoCookThread then
                startAutoCook()
            end
            -- AutoCollectCash
            if autoCollectCashEnabled and not autoCollectCashThread then
                startAutoCollectCash()
            end
            -- AutoCollectDishes
            if autoCollectDishesEnabled and not autoCollectDishesThread then
                startAutoCollectDishes()
            end
            -- AutoServe
            if autoServeEnabled and not autoServeThread then
                startAutoServe()
            end
            -- AutoDailyReward
            if autoDailyRewardEnabled and not autoDailyRewardThread then
                startAutoDailyReward()
            end
            -- AutoCollectTiles
            if autoCollectTilesEnabled and not autoCollectTilesThread then
                startAutoCollectTiles()
            end
            -- AutoPlant
            if autoPlantEnabled and not autoPlantThread then
                if autoPlantThread == nil then
                    autoPlantThread = task.spawn(function()
                        while autoPlantEnabled do
                            local crop = cropMap[selectedCrop]
                            for _, tile in ipairs(tileNames) do
                                local args = {crop, tile}
                                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
                                    :WaitForChild("Farming", 9e9)
                                    :WaitForChild("RequestCropPlant", 9e9)
                                    :InvokeServer(unpack(args))
                                print("AutoPlant: Planted", crop, "on", tile)
                            end
                            task.wait(5)
                        end
                        autoPlantThread = nil
                    end)
                end
            end
            -- AutoCollectTipJar
            if autoCollectTipJarEnabled and not autoCollectTipJarThread then
                startAutoCollectTipJar()
            end
            task.wait(10) -- Check every 10 seconds
        end
    end)
end

automationWatchdog()
-- Ball Circle Config & Defaults (top of file)
-- =====================
local configFolder = "SeisenHub"
local configFile = configFolder .. "/seisen_hub_rt3.txt"
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
local sendToTableEnabled = config.SendToTableEnabled or false
local autoAcceptOrderEnabled = config.AutoAcceptOrderEnabled or false
local autoCookEnabled = config.AutoCookEnabled or false
local autoCollectCashEnabled = config.AutoCollectCashEnabled or false
local autoCollectDishesEnabled = config.AutoCollectDishesEnabled or false
local autoServeEnabled = config.AutoServeEnabled or false
local autoDailyRewardEnabled = config.AutoDailyRewardEnabled or false
local autoCollectTilesEnabled = config.AutoCollectTilesEnabled or false
local autoPlantEnabled = config.AutoPlantEnabled or false
local advertiseChatEnabled = config.AdvertiseChatEnabled or false
local autoCollectTipJarEnabled = config.AutoCollectTipJarEnabled or false
local autoMagnetEnabled = config.AutoMagnetEnabled or false
local selectedFarmShopIngredient = config.SelectedFarmShopIngredient or "Tomato"

local function saveConfig()
    config.AutoHideUIEnabled = autoHideUIEnabled
    config.SendToTableEnabled = sendToTableEnabled
    config.AutoAcceptOrderEnabled = autoAcceptOrderEnabled
    config.AutoCookEnabled = autoCookEnabled
    config.AutoCollectCashEnabled = autoCollectCashEnabled
    config.AutoCollectDishesEnabled = autoCollectDishesEnabled
    config.AutoServeEnabled = autoServeEnabled
    config.AutoDailyRewardEnabled = autoDailyRewardEnabled
    config.AutoCollectTilesEnabled = autoCollectTilesEnabled
    config.AutoPlantEnabled = autoPlantEnabled
    config.AdvertiseChatEnabled = advertiseChatEnabled
    config.AutoCollectTipJarEnabled = autoCollectTipJarEnabled
    config.AutoMagnetEnabled = autoMagnetEnabled
    config.SelectedFarmShopIngredient = selectedFarmShopIngredient
    writefile(configFile, HttpService:JSONEncode(config))
end

local MainTab = Window:AddTab("Main", "box")
local MainGroup = MainTab:AddLeftGroupbox("Main Features", "atom")
local ButcherGroup = MainTab:AddRightGroupbox("Butcher Shop", "beef")
local UpgradeGroup = MainTab:AddLeftGroupbox("Upgrades", "circle-fading-arrow-up")
local FarmingGroup = MainTab:AddLeftGroupbox("Auto Plant", "flower-2")
local FishGroup = MainTab:AddRightGroupbox("Fish Shop", "fish")
local SupermarketGroup = MainTab:AddRightGroupbox("Supermarket", "shopping-cart")
local BakeryGroup = MainTab:AddRightGroupbox("Bakery", "croissant")
local FarmGroup = MainTab:AddRightGroupbox("Farm Shop", "tractor")
local SettingsTab = Window:AddTab("Settings", "settings", "Customize the UI")
local PlayerGroup = SettingsTab:AddRightGroupbox("Player Controls", "user")
local UISettingsGroup = SettingsTab:AddLeftGroupbox("UI Customization", "paintbrush")
local InfoGroup = SettingsTab:AddRightGroupbox("Script Information", "info")

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenHub")
ThemeManager:ApplyToTab(SettingsTab)

InfoGroup:AddLabel("Script by: Seisen")
InfoGroup:AddLabel("Version: 1.0.0")
InfoGroup:AddLabel("Game: Restaurant Tycoon 3")

InfoGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/F4sAf6z8Ph")
    print("Copied Discord Invite!")
end)



local advertiseChatThread = nil

InfoGroup:AddToggle("AdvertiseChatToggle", {
    Text = "Advertise Seisen Hub",
    Default = advertiseChatEnabled,
    Tooltip = "Automatically sends an advertisement message for seisen hub in chat every 30 minutes.",
    Callback = function(Value)
        advertiseChatEnabled = Value
        config.AdvertiseChatEnabled = Value
        saveConfig()
        if advertiseChatEnabled then
            if not advertiseChatThread then
                advertiseChatThread = task.spawn(function()
                    local Players = game:GetService("Players")
                    local TextChatService = game:GetService("TextChatService")
                    local player = Players.LocalPlayer
                    local message = "Seisen Hub Best Restaurant Tycoon 3 Script!!!"
                    task.wait(1)
                    while advertiseChatEnabled do
                        local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                        if channel then
                            channel:SendAsync(message)
                            print("Advertised in chat:", message)
                        else
                            warn("No default TextChat channel found. Chat may be disabled or renamed.")
                        end
                        task.wait(1800) -- 30 minutes
                    end
                    advertiseChatThread = nil
                end)
            end
        else
            advertiseChatEnabled = false
        end
    end
})

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
-- =====================
-- Logic/Functions 
-- Passive Anti-AFK
local function startAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
end

startAntiAFK()
-- =====================
local taskCompleted = ReplicatedStorage:WaitForChild("Events", 9e9)
    :WaitForChild("Restaurant", 9e9)
    :WaitForChild("TaskCompleted", 9e9)

local sendToTableThread = nil

local function findTycoon()
    local tycoonsFolder = Workspace:WaitForChild("Tycoons", 9e9)
    for _, tycoon in ipairs(tycoonsFolder:GetChildren()) do
        local playerVal = tycoon:FindFirstChild("Player")
        if playerVal and playerVal:IsA("ObjectValue") and playerVal.Value == LocalPlayer then
            return tycoon
        end
    end
    return nil
end

local function startSendToTable()
    if sendToTableThread then return end
    sendToTableThread = task.spawn(function()
        local tycoon = findTycoon()
        if not tycoon then
            warn("Could not find your tycoon!")
            sendToTableThread = nil
            return
        end
        local surfaceFolder = tycoon:WaitForChild("Items", 9e9):WaitForChild("Surface", 9e9)
        while sendToTableEnabled do
            local clientCustomers = tycoon:FindFirstChild("ClientCustomers")
            local groupIds = {}
            if clientCustomers then
                for _, customer in ipairs(clientCustomers:GetChildren()) do
                    if customer and customer.Name and tonumber(customer.Name) then
                        table.insert(groupIds, customer.Name)
                    end
                end
            end
            for _, tableObj in ipairs(surfaceFolder:GetChildren()) do
                if tableObj:IsA("Model") or tableObj:IsA("Part") then
                    for _, groupId in ipairs(groupIds) do
                        if not sendToTableEnabled then break end
                        local args = {
                            [1] = {
                                ["FurnitureModel"] = tableObj,
                                ["Tycoon"] = tycoon,
                                ["Name"] = "SendToTable",
                                ["GroupId"] = groupId,
                            },
                        }
                        taskCompleted:FireServer(unpack(args))
                        task.wait(0.05) -- reduced from 0.2 for faster processing
                    end
                end
            end
            task.wait(0.5) -- reduced from 2 for faster loop
        end
        sendToTableThread = nil
    end)
end
-- Auto start if enabled
if sendToTableEnabled then
    startSendToTable()
end

local autoAcceptOrderThread = nil

local function startAutoAcceptOrder()
    if autoAcceptOrderThread then return end
    autoAcceptOrderThread = task.spawn(function()
        local tycoon = findTycoon()
        if not tycoon then
            warn("Could not find your tycoon!")
            autoAcceptOrderThread = nil
            return
        end
        local clientCustomers = tycoon:FindFirstChild("ClientCustomers")
        while autoAcceptOrderEnabled do
            if clientCustomers then
                for _, group in ipairs(clientCustomers:GetChildren()) do
                    for _, customer in ipairs(group:GetChildren()) do
                        if customer and customer.Name and tonumber(customer.Name) then
                            local args = {
                                [1] = {
                                    ["CustomerId"] = customer.Name,
                                    ["Tycoon"] = tycoon,
                                    ["Name"] = "TakeOrder",
                                    ["GroupId"] = group.Name,
                                },
                            }
                            taskCompleted:FireServer(unpack(args))
                            task.wait(0.05) -- reduced from 0.1 for faster processing
                        end
                    end
                end
            end
            task.wait(0.2) -- reduced from 1 for faster loop
        end
        autoAcceptOrderThread = nil
    end)
end

if autoAcceptOrderEnabled then
    startAutoAcceptOrder()
end


-- Services
local RS = game:GetService("ReplicatedStorage")
local interacted = RS:WaitForChild("Events", 9e9)
    :WaitForChild("Restaurant", 9e9)
    :WaitForChild("Interactions", 9e9)
    :WaitForChild("Interacted", 9e9)

local tempFolder = workspace:WaitForChild("Temp", 9e9)
local function findTycoon()
    local tycoonsFolder = workspace:WaitForChild("Tycoons", 9e9)
    for _, tycoon in ipairs(tycoonsFolder:GetChildren()) do
        local playerVal = tycoon:FindFirstChild("Player")
        if playerVal and playerVal:IsA("ObjectValue") and playerVal.Value == game:GetService("Players").LocalPlayer then
            return tycoon
        end
    end
    return nil
end

local function getSurfaceFolder()
    local tycoon = findTycoon()
    if tycoon then
        return tycoon.Items:WaitForChild("Surface", 9e9)
    end
    return nil
end

-- Pick any Surface model dynamically (first or random)
local function getAnySurfaceModel()
    local surfaceFolder = getSurfaceFolder()
    if not surfaceFolder then return nil end
    local children = surfaceFolder:GetChildren()
    if #children > 0 then
        return children[math.random(1, #children)]
    end
    return nil
end

-- Fire event for a Temp part
local function interactWithTempPart(tempPart)
    -- Find a ProximityPrompt or any numeric child name (ID)
    local prompt
    for _, child in ipairs(tempPart:GetChildren()) do
        if child:IsA("ProximityPrompt") or tonumber(child.Name) then
            prompt = child
            break
        end
    end
    if not prompt then return end

    local tycoon = findTycoon()
    if not tycoon then return end
    local model = getAnySurfaceModel()
    if not model then return end

    local args = {
        [1] = tycoon;
        [2] = {
            ["WorldPosition"] = tempPart.Position;
            ["HoldDuration"] = 0.375;
            ["Id"] = prompt.Name;
            ["TemporaryPart"] = tempPart;
            ["Model"] = model;
            ["Part"] = tempPart;
            ["Prompt"] = prompt;
            ["ActionText"] = "Cook";
            ["InteractionType"] = "OrderCounter";
        };
    }

    interacted:FireServer(unpack(args))
    print("Fired Interacted for Temp:", tempPart.Name, "using model:", model.Name)

        -- Additional CookInputRequested logic (dynamic, player's own tycoon)
        local cookEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
            :WaitForChild("Cook", 9e9)
            :WaitForChild("CookInputRequested", 9e9)
        local tycoon = findTycoon()
        if tycoon then
            local surfaceFolder = tycoon:WaitForChild("Items", 9e9):WaitForChild("Surface", 9e9)
            -- Fire for all Kitchen objects
            for _, obj in ipairs(surfaceFolder:GetChildren()) do
                if obj.Name:lower():find("kitchen") or obj.Name:lower():find("k") then
                    cookEvents:FireServer("Interact", obj, "Kitchen")
                    cookEvents:FireServer("CompleteTask", obj, "Kitchen")
                end
            end
            -- Fire for all Oven objects
            for _, obj in ipairs(surfaceFolder:GetChildren()) do
                if obj.Name:lower():find("oven") then
                    cookEvents:FireServer("Interact", obj, "Oven")
                    cookEvents:FireServer("CompleteTask", obj, "Oven", false)
                end
            end
        end
end

-- Continuous loop to handle new Temp parts
local autoCookThread = nil

local function startAutoCook()
    if autoCookThread then return end
    autoCookThread = task.spawn(function()
        while autoCookEnabled do
            for _, tempPart in ipairs(tempFolder:GetChildren()) do
                interactWithTempPart(tempPart)
            end
            task.wait(0.05) -- reduced from 0.1 for faster processing
        end
        autoCookThread = nil
    end)
end

if autoCookEnabled then
    startAutoCook()
end


local autoCollectCashThread = nil

local function startAutoCollectCash()
    if autoCollectCashThread then return end
    autoCollectCashThread = task.spawn(function()
        local tycoon = findTycoon()
        if not tycoon then
            warn("Could not find your tycoon!")
            autoCollectCashThread = nil
            return
        end
        local surfaceFolder = tycoon:WaitForChild("Items", 9e9):WaitForChild("Surface", 9e9)
        while autoCollectCashEnabled do
            for _, surfaceObj in ipairs(surfaceFolder:GetChildren()) do
                if surfaceObj:IsA("Model") or surfaceObj:IsA("Part") then
                    local args = {
                        [1] = {
                            ["Tycoon"] = tycoon,
                            ["Name"] = "CollectBill",
                            ["FurnitureModel"] = surfaceObj,
                        },
                    }
                    taskCompleted:FireServer(unpack(args))
                    task.wait(0.05) -- reduced from 0.2 for faster processing
                end
            end
            task.wait(0.2) -- reduced from 2 for faster loop
        end
        autoCollectCashThread = nil
    end)
end

if autoCollectCashEnabled then
    startAutoCollectCash()
end


local autoCollectDishesThread = nil

local function startAutoCollectDishes()
    if autoCollectDishesThread then return end
    autoCollectDishesThread = task.spawn(function()
        local tycoon = findTycoon()
        if not tycoon then
            warn("Could not find your tycoon!")
            autoCollectDishesThread = nil
            return
        end
        local surfaceFolder = tycoon:WaitForChild("Items", 9e9):WaitForChild("Surface", 9e9)
        while autoCollectDishesEnabled do
            for _, surfaceObj in ipairs(surfaceFolder:GetChildren()) do
                if surfaceObj:IsA("Model") or surfaceObj:IsA("Part") then
                    local args = {
                        [1] = {
                            ["Tycoon"] = tycoon,
                            ["Name"] = "CollectDishes",
                            ["FurnitureModel"] = surfaceObj,
                        },
                    }
                    taskCompleted:FireServer(unpack(args))
                    task.wait(0.05) -- reduced from 0.2 for faster processing
                end
            end
            task.wait(0.2) -- reduced from 2 for faster loop
        end
        autoCollectDishesThread = nil
    end)
end

if autoCollectDishesEnabled then
    startAutoCollectDishes()
end


local autoServeThread = nil

local function startAutoServe()
    if autoServeThread then return end
    autoServeThread = task.spawn(function()
        local tycoon = findTycoon()
        if not tycoon then
            warn("Could not find your tycoon!")
            autoServeThread = nil
            return
        end
        local foodFolder = tycoon:WaitForChild("Objects", 9e9):WaitForChild("Food", 9e9)
        local clientCustomers = tycoon:FindFirstChild("ClientCustomers")
        while autoServeEnabled do
            -- Grab all food models
            for _, foodModel in ipairs(foodFolder:GetChildren()) do
                -- GrabFood event
                local grabFoodEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
                    :WaitForChild("Restaurant", 9e9)
                    :WaitForChild("GrabFood", 9e9)
                grabFoodEvent:InvokeServer(foodModel)
                task.wait(0.01) -- reduced from 0.03 for faster processing
                -- Serve logic for each customer in each group
                if clientCustomers then
                    for _, group in ipairs(clientCustomers:GetChildren()) do
                        for _, customer in ipairs(group:GetChildren()) do
                            if customer and customer.Name and tonumber(customer.Name) then
                                local args = {
                                    [1] = {
                                        ["Name"] = "Serve",
                                        ["GroupId"] = group.Name,
                                        ["Tycoon"] = tycoon,
                                        ["FoodModel"] = foodModel,
                                        ["CustomerId"] = customer.Name,
                                    },
                                }
                                taskCompleted:FireServer(unpack(args))
                                task.wait(0.01) -- reduced from 0.03 for faster processing
                            end
                        end
                    end
                end
            end
            task.wait(0.05) -- reduced from 0.2 for faster loop
        end
        autoServeThread = nil
    end)
end

if autoServeEnabled then
    startAutoServe()
end


local autoDailyRewardThread = nil
local function startAutoDailyReward()
    if autoDailyRewardThread then return end
    autoDailyRewardThread = task.spawn(function()
        local dailyRewardEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
            :WaitForChild("DailyRewards", 9e9)
            :WaitForChild("DailyRewardClaimed", 9e9)
        while autoDailyRewardEnabled do
            local args = {}
            dailyRewardEvent:FireServer(unpack(args))
            task.wait(60) -- claim every 60 seconds
        end
        autoDailyRewardThread = nil
    end)
end

if autoDailyRewardEnabled then
    startAutoDailyReward()
end


local tileNames = {"Tile1", "Tile2", "Tile3", "Tile4", "Tile5", "Tile6", "Tile7", "Tile8"}
local autoCollectTilesThread = nil

local function startAutoCollectTiles()
    if autoCollectTilesThread then return end
    autoCollectTilesThread = task.spawn(function()
        while autoCollectTilesEnabled do
            for _, tile in ipairs(tileNames) do
                local args = {tile}
                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
                    :WaitForChild("Farming", 9e9)
                    :WaitForChild("RequestHarvest", 9e9)
                    :InvokeServer(unpack(args))
                print("AutoCollectTiles: Harvested", tile)
            end
            task.wait(5) -- harvest interval
        end
        autoCollectTilesThread = nil
    end)
end

if autoCollectTilesEnabled then
    startAutoCollectTiles()
end

-- Butcher Shop ingredient selection and auto-buy
local ingredientPrices = {
    ["Lamb"] = 75,
    ["Chicken"] = 35,
    ["Pork"] = 45,
    ["Beef"] = 65
}
local ingredientNames = {"Lamb ($75)", "Chicken ($35)", "Pork ($45)", "Beef ($65)"}
local ingredientMap = {
    ["Lamb ($75)"] = "Lamb",
    ["Chicken ($35)"] = "Chicken",
    ["Pork ($45)"] = "Pork",
    ["Beef ($65)"] = "Beef"
}
local selectedIngredient = ingredientNames[1]
local autoBuyIngredientEnabled = false
local autoBuyIngredientThread = nil


-- Farming controls
local cropNames = {
    "Onion (15m)", "Wheat (25m)", "Sugarcane (45m)", "Tomato (1h)", "Potato (1h 15m)", "Carrot (1h 30m)", "Berry Bush (2h)", "Lettuce (2h 30m)", "Apple Tree (3h)"
}
local cropMap = {
    ["Onion (15m)"] = "Onion",
    ["Wheat (25m)"] = "Wheat",
    ["Sugarcane (45m)"] = "Sugar",
    ["Tomato (1h)"] = "Tomato",
    ["Potato (1h 15m)"] = "Potato",
    ["Carrot (1h 30m)"] = "Carrot",
    ["Berry Bush (2h)"] = "Berries",
    ["Lettuce (2h 30m)"] = "Lettuce",
    ["Apple Tree (3h)"] = "Apple"
}

local selectedCrop = cropNames[1]
local autoPlantThread = nil
local autoCollectTilesThread = nil


local autoCollectTipJarThread = nil

local function findTycoon()
    local tycoonsFolder = workspace:FindFirstChild("Tycoons")
    if not tycoonsFolder then return nil end
    for _, tycoon in ipairs(tycoonsFolder:GetChildren()) do
        local playerVal = tycoon:FindFirstChild("Player")
        if playerVal and playerVal:IsA("ObjectValue") and playerVal.Value == game:GetService("Players").LocalPlayer then
            return tycoon
        end
    end
    return nil
end

local function startAutoCollectTipJar()
    if autoCollectTipJarThread then return end
    autoCollectTipJarThread = task.spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local TipsCollected = ReplicatedStorage:WaitForChild("Events", 9e9)
            :WaitForChild("Restaurant", 9e9)
            :WaitForChild("TipsCollected", 9e9)
        while autoCollectTipJarEnabled do
            local tycoon = findTycoon()
            if tycoon then
                local args = {tycoon}
                TipsCollected:FireServer(unpack(args))
            end
            task.wait(60) -- collect every 60 seconds
        end
        autoCollectTipJarThread = nil
    end)
end



-- =====================
-- Toggles and UI Elements
-- =====================


MainGroup:AddToggle("SendToTableToggle", {
    Text = "Auto Send To Table",
    Default = sendToTableEnabled,
    Tooltip = "Automatically sends to table for GroupId 1 and 2.",
    Callback = function(Value)
        sendToTableEnabled = Value
        config.SendToTableEnabled = Value
        saveConfig()
        if sendToTableEnabled then
            startSendToTable()
        end
    end
})


MainGroup:AddToggle("AutoAcceptOrderToggle", {
    Text = "Auto Accept Order",
    Default = autoAcceptOrderEnabled,
    Tooltip = "Automatically accepts orders for active customers.",
    Callback = function(Value)
        autoAcceptOrderEnabled = Value
        config.AutoAcceptOrderEnabled = Value
        saveConfig()
        if autoAcceptOrderEnabled then
            startAutoAcceptOrder()
        end
    end
})

MainGroup:AddToggle("AutoCookToggle", {
    Text = "Auto Cook",
    Default = autoCookEnabled,
    Tooltip = "Automatically cooks using detected temp parts and prompts.",
    Callback = function(Value)
        autoCookEnabled = Value
        config.AutoCookEnabled = Value
        saveConfig()
        if autoCookEnabled then
            startAutoCook()
        end
    end
})

MainGroup:AddToggle("AutoCollectCashToggle", {
    Text = "Auto Collect Cash",
    Default = autoCollectCashEnabled,
    Tooltip = "Automatically collects cash from all surfaces in your tycoon.",
    Callback = function(Value)
        autoCollectCashEnabled = Value
        config.AutoCollectCashEnabled = Value
        saveConfig()
        if autoCollectCashEnabled then
            startAutoCollectCash()
        end
    end
})

MainGroup:AddToggle("AutoCollectDishesToggle", {
    Text = "Auto Collect Dishes",
    Default = autoCollectDishesEnabled,
    Tooltip = "Automatically collects dishes from all surfaces in your tycoon.",
    Callback = function(Value)
        autoCollectDishesEnabled = Value
        config.AutoCollectDishesEnabled = Value
        saveConfig()
        if autoCollectDishesEnabled then
            startAutoCollectDishes()
        end
    end
})

MainGroup:AddToggle("AutoServeToggle", {
    Text = "Auto Serve",
    Default = autoServeEnabled,
    Tooltip = "Automatically grabs and serves food to all customers in your tycoon.",
    Callback = function(Value)
        autoServeEnabled = Value
        config.AutoServeEnabled = Value
        saveConfig()
        if autoServeEnabled then
            startAutoServe()
        end
    end
})

MainGroup:AddToggle("AutoDailyRewardToggle", {
    Text = "Auto Daily Reward",
    Default = autoDailyRewardEnabled,
    Tooltip = "Automatically claims daily rewards every minute.",
    Callback = function(Value)
        autoDailyRewardEnabled = Value
        config.AutoDailyRewardEnabled = Value
        saveConfig()
        if autoDailyRewardEnabled then
            startAutoDailyReward()
        end
    end
})


MainGroup:AddToggle("AutoCollectTipJarToggle", {
    Text = "Auto Collect Tip Jar",
    Default = config.AutoCollectTipJarEnabled or false,
    Tooltip = "Automatically collects tips from your tip jar every few seconds.",
    Callback = function(Value)
        autoCollectTipJarEnabled = Value
        config.AutoCollectTipJarEnabled = Value
        saveConfig()
        if autoCollectTipJarEnabled then
            startAutoCollectTipJar()
        end
    end
})


local magnetConnection = nil

MainGroup:AddToggle("AutoMagnet", {
    Text = "Auto Collect Vip Cash",
    Default = config.AutoMagnetEnabled or false,
    Tooltip = "Automatically collect nearby drops",
    Callback = function(enabled)
        autoMagnetEnabled = enabled
        config.AutoMagnetEnabled = enabled
        saveConfig()
        if enabled then
            local LocalPlayer = game:GetService("Players").LocalPlayer
            magnetConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local dropFolder = workspace:FindFirstChild("DropFolder")
                if not dropFolder then return end

                for _, drop in ipairs(dropFolder:GetChildren()) do
                    if drop and drop:IsA("BasePart") then
                        drop.Position = hrp.Position
                    end
                end
                task.wait(0.05) -- faster VIP cash collection
            end)
        else
            if magnetConnection then
                magnetConnection:Disconnect()
                magnetConnection = nil
            end
        end
    end
})



ButcherGroup:AddDropdown("IngredientDropdown", {
    Text = "Select Ingredient",
    Values = ingredientNames,
    Default = ingredientNames[1],
    Tooltip = "Choose which ingredient to buy.",
    Callback = function(Value)
        selectedIngredient = Value
    end
})

ButcherGroup:AddButton("Buy Selected Ingredient", function()
    local tycoon = findTycoon()
    if not tycoon then
        warn("Could not find your tycoon!")
        return
    end
    local ingredient = ingredientMap[selectedIngredient]
    local args = {tycoon, ingredient}
    game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
        :WaitForChild("Food", 9e9)
        :WaitForChild("PurchaseIngredientRequested", 9e9)
        :FireServer(unpack(args))
    print("Bought ingredient:", ingredient, "for $" .. ingredientPrices[ingredient])
end)


FarmingGroup:AddDropdown("CropDropdown", {
    Text = "Select Crop",
    Values = cropNames,
    Default = cropNames[1],
    Tooltip = "Choose which crop to plant.",
    Callback = function(Value)
        selectedCrop = Value
    end
})

FarmingGroup:AddToggle("AutoPlantAllTilesToggle", {
    Text = "Auto Plant All Tiles",
    Default = config.AutoPlantEnabled or false,
    Tooltip = "Automatically plants the selected crop on all tiles (Tile1-Tile8) every few seconds.",
    Callback = function(Value)
        autoPlantEnabled = Value
        config.AutoPlantEnabled = Value
        saveConfig()
        if autoPlantEnabled then
            if autoPlantThread == nil then
                autoPlantThread = task.spawn(function()
                    while autoPlantEnabled do
                        local crop = cropMap[selectedCrop]
                        for _, tile in ipairs(tileNames) do
                            local args = {crop, tile}
                            game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
                                :WaitForChild("Farming", 9e9)
                                :WaitForChild("RequestCropPlant", 9e9)
                                :InvokeServer(unpack(args))
                            print("AutoPlant: Planted", crop, "on", tile)
                        end
                        task.wait(5)
                    end
                    autoPlantThread = nil
                end)
            end
        else
            if autoPlantThread then
                autoPlantEnabled = false
            end
        end 
    end
})


FarmingGroup:AddToggle("AutoCollectTilesToggle", {
    Text = "Auto Harvest All Plant",
    Default = config.AutoCollectTilesEnabled or false,
    Tooltip = "Automatically harvests all tiles (Tile1-Tile8) every few seconds.",
    Callback = function(Value)
        autoCollectTilesEnabled = Value
        config.AutoCollectTilesEnabled = Value
        saveConfig()
        if autoCollectTilesEnabled then
            startAutoCollectTiles()
        end
    end
})

-- Upgrade controls
local upgradeOptions = {
    {Name = "Tip Jar", Key = "TipJar", Price = 150},
    {Name = "Waiter Tray", Key = "WaiterTray", Price = 200},
    {Name = "Waiter Cart", Key = "WaiterCart", Price = 900},
    {Name = "Poster Advertising", Key = "PosterAdvertising", Price = 600},
    {Name = "Level 2 Kitchens", Key = "Level2Kitchens", Price = 400},
    {Name = "Left Expansion", Key = "LeftExpansion1", Price = 1200},
    {Name = "Right Expansion", Key = "RightExpansion1", Price = 1200},
    {Name = "Print Advertising", Key = "NewspaperAdvertising", Price = 1300},
    {Name = "Level 3 Kitchens", Key = "Level3Kitchens", Price = 1500},
    {Name = "Card Payments", Key = "CardPayments", Price = 1750},
    {Name = "Back Expansion", Key = "BackExpansion1", Price = 1800},
    {Name = "Billboard Advertising", Key = "BillboardAdvertising", Price = 2750},
    {Name = "Left Expansion 2", Key = "LeftExpansion2", Price = 3400},
    {Name = "Right Expansion 2", Key = "RightExpansion2", Price = 3400},
    {Name = "Back Expansion 2", Key = "BackExpansion2", Price = 4200},
    {Name = "Media Advertising", Key = "TVAdvertising", Price = 5500},
    {Name = "Left Expansion 3", Key = "LeftExpansion3", Price = 6000},
    {Name = "Right Expansion 3", Key = "RightExpansion3", Price = 6000},
    {Name = "Second Floor", Key = "SecondFloor", Price = 12500}
}

table.sort(upgradeOptions, function(a, b)
    return a.Price < b.Price
end)
local upgradeNames = {}
local upgradeMap = {}
for _, v in ipairs(upgradeOptions) do
    local display = v.Name .. " ($" .. v.Price .. ")"
    table.insert(upgradeNames, display)
    upgradeMap[display] = v.Key
end
local selectedUpgrade = upgradeNames[1]

UpgradeGroup:AddDropdown("UpgradeDropdown", {
    Text = "Select Upgrade",
    Values = upgradeNames,
    Default = upgradeNames[1],
    Tooltip = "Choose which upgrade to unlock.",
    Callback = function(Value)
        selectedUpgrade = Value
    end
})

UpgradeGroup:AddButton("Unlock Selected Upgrade", function()
    local tycoon = findTycoon()
    if not tycoon then
        warn("Could not find your tycoon!")
        return
    end
    local upgradeKey = upgradeMap[selectedUpgrade]
    local args = {tycoon, upgradeKey}
    game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
        :WaitForChild("Upgrades", 9e9)
        :WaitForChild("UnlockUpgradeRequested", 9e9)
        :FireServer(unpack(args))
    print("Unlocked upgrade:", selectedUpgrade)
end)


-- Fish Shop ingredient selection and buy
local fishIngredientNames = {"Fish ($55)"}
local fishIngredientMap = { ["Fish ($55)"] = "Fish" }
local selectedFishIngredient = fishIngredientNames[1]

FishGroup:AddDropdown("FishIngredientDropdown", {
    Text = "Select Fish Ingredient",
    Values = fishIngredientNames,
    Default = fishIngredientNames[1],
    Tooltip = "Choose which fish ingredient to buy.",
    Callback = function(Value)
        selectedFishIngredient = Value
    end
})

FishGroup:AddButton("Buy Selected Fish", function()
    local tycoon = findTycoon()
    if not tycoon then
        warn("Could not find your tycoon!")
        return
    end
    local ingredient = fishIngredientMap[selectedFishIngredient]
    local args = {tycoon, ingredient}
    game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
        :WaitForChild("Food", 9e9)
        :WaitForChild("PurchaseIngredientRequested", 9e9)
        :FireServer(unpack(args))
    print("Bought fish ingredient:", ingredient)
end)


-- Supermarket ingredient selection and buy
local supermarketIngredientNames = {"Sugar ($30)", "Berries ($40)", "Apple ($50)", "Pasta ($25)", "Chocolate ($60)", "Cheese ($45)"}
local supermarketIngredientMap = {
    ["Sugar ($30)"] = "Sugar",
    ["Berries ($40)"] = "Berries",
    ["Apple ($50)"] = "Apple",
    ["Pasta ($25)"] = "Pasta",
    ["Chocolate ($60)"] = "Chocolate",
    ["Cheese ($45)"] = "Cheese"
}
local selectedSupermarketIngredient = supermarketIngredientNames[1]

SupermarketGroup:AddDropdown("SupermarketIngredientDropdown", {
    Text = "Select Supermarket Ingredient",
    Values = supermarketIngredientNames,
    Default = supermarketIngredientNames[1],
    Tooltip = "Choose which supermarket ingredient to buy.",
    Callback = function(Value)
        selectedSupermarketIngredient = Value
    end
})

SupermarketGroup:AddButton("Buy Selected Ingredient", function()
    local tycoon = findTycoon()
    if not tycoon then
        warn("Could not find your tycoon!")
        return
    end
    local ingredient = supermarketIngredientMap[selectedSupermarketIngredient]
    local args = {tycoon, ingredient}
    game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
        :WaitForChild("Food", 9e9)
        :WaitForChild("PurchaseIngredientRequested", 9e9)
        :FireServer(unpack(args))
    print("Bought supermarket ingredient:", ingredient)
end)


-- Bakery ingredient selection and buy
local bakeryIngredientNames = {"Egg ($20)", "Flour ($15)", "Bread ($35)"}
local bakeryIngredientMap = {
    ["Egg ($20)"] = "Egg",
    ["Flour ($15)"] = "Flour",
    ["Bread ($35)"] = "Bread"
}
local selectedBakeryIngredient = bakeryIngredientNames[1]

BakeryGroup:AddDropdown("BakeryIngredientDropdown", {
    Text = "Select Bakery Ingredient",
    Values = bakeryIngredientNames,
    Default = bakeryIngredientNames[1],
    Tooltip = "Choose which bakery ingredient to buy.",
    Callback = function(Value)
        selectedBakeryIngredient = Value
    end
})

BakeryGroup:AddButton("Buy Selected Ingredient", function()
    local tycoon = findTycoon()
    if not tycoon then
        warn("Could not find your tycoon!")
        return
    end
    local ingredient = bakeryIngredientMap[selectedBakeryIngredient]
    local args = {tycoon, ingredient}
    game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
        :WaitForChild("Food", 9e9)
        :WaitForChild("PurchaseIngredientRequested", 9e9)
        :FireServer(unpack(args))
    print("Bought bakery ingredient:", ingredient)
end)


-- Farm Shop Ingredients
local farmShopIngredientNames = {"Tomato", "Berries", "Milk", "Apple", "Carrot", "Potato", "Onion", "Lettuce", "Cheese"}
local selectedFarmShopIngredient = config.SelectedFarmShopIngredient or farmShopIngredientNames[1]

FarmGroup:AddDropdown("FarmShopIngredientDropdown", {
    Text = "Select Farm Shop Ingredient",
    Values = farmShopIngredientNames,
    Default = selectedFarmShopIngredient,
    Tooltip = "Choose which farm shop ingredient to buy.",
    Callback = function(Value)
        selectedFarmShopIngredient = Value
        config.SelectedFarmShopIngredient = Value
        saveConfig()
    end
})

FarmGroup:AddButton("Buy Selected Ingredient", function()
    local tycoon = findTycoon()
    if not tycoon then
        warn("Could not find your tycoon!")
        return
    end
    local args = {
        [1] = tycoon,
        [2] = selectedFarmShopIngredient
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9)
        :WaitForChild("Food", 9e9)
        :WaitForChild("PurchaseIngredientRequested", 9e9)
        :FireServer(unpack(args))
    print("Bought farm shop ingredient:", selectedFarmShopIngredient)
end)


-- Custom Cursor Toggle
UISettingsGroup:AddToggle("CustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Tooltip = "Enable/disable the custom cursor design",
    Callback = function(value)
        Library.ShowCustomCursor = value
    end
})

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



local flyEnabled = false
local walkSpeedValue = 16
local flyConnection = nil
local flyDirection = Vector3.new(0, 0, 0)

local UserInputService = game:GetService("UserInputService")

local function setWalkSpeed(speed)
    local character = game:GetService("Players").LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") then
        character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
    end
end

local function startFly()
    if flyConnection then return end
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    flyDirection = Vector3.new(0, 0, 0)

    local function getRelativeDirection()
        local cam = workspace.CurrentCamera
        local forward = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local up = Vector3.new(0, 1, 0)
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + up end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - up end
        return dir
    end

    flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if flyEnabled then
            local dir = getRelativeDirection()
            humanoidRootPart.Velocity = dir.Magnitude > 0 and dir.Unit * 50 or Vector3.new(0, 0, 0)
        end
    end)
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    flyDirection = Vector3.new(0, 0, 0)
end

-- Refresh stats on character spawn
local player = game:GetService("Players").LocalPlayer
player.CharacterAdded:Connect(function()
    task.wait(1)
    setWalkSpeed(walkSpeedValue)
end)

-- UI controls for LocalPlayer
PlayerGroup:AddSlider("WalkSpeedSlider", {
    Text = "WalkSpeed",
    Min = 8,
    Max = 100,
    Default = walkSpeedValue,
    Suffix = "",
    Rounding = 0,
    Tooltip = "Set your character's walkspeed.",
    Callback = function(Value)
        walkSpeedValue = Value
        setWalkSpeed(Value)
    end
})

PlayerGroup:AddToggle("FlyToggle", {
    Text = "Fly",
    Default = flyEnabled,
    Tooltip = "Enable/disable fly mode.",
    Callback = function(Value)
        flyEnabled = Value
        if flyEnabled then
            startFly()
        else
            stopFly()
        end
    end
})


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
    -- Disconnect workspace connection for ball circles
    if workspaceConnection then
        workspaceConnection:Disconnect()
        workspaceConnection = nil
    end
    saveConfig()

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
    -- Stop all automation threads and disable toggles
    sendToTableEnabled = false
    autoAcceptOrderEnabled = false
    autoCookEnabled = false
    autoCollectCashEnabled = false
    autoCollectDishesEnabled = false
    autoServeEnabled = false
    autoDailyRewardEnabled = false
    flyEnabled = false
    autoCollectTilesEnabled = false
    autoPlantEnabled = false
    autoMagnetEnabled = false
    autoCollectTipJarEnabled = false
    setWalkSpeed(16) -- Reset walkspeed to default
    if sendToTableThread then sendToTableThread = nil end
    if autoAcceptOrderThread then autoAcceptOrderThread = nil end
    if autoCookThread then autoCookThread = nil end
    if autoCollectCashThread then autoCollectCashThread = nil end
    if autoCollectDishesThread then autoCollectDishesThread = nil end
    if autoServeThread then autoServeThread = nil end
    if autoDailyRewardThread then autoDailyRewardThread = nil end
    if flyConnection then stopFly() end
    if autoCollectTilesThread then autoCollectTilesThread = nil end
    if autoPlantThread then autoPlantThread = nil end
    if autoCollectTipJarThread then autoCollectTipJarThread = nil end
    if magnetConnection then
        magnetConnection:Disconnect()
        magnetConnection = nil
    end
    selectedFarmShopIngredient = farmShopIngredientNames[1]
    print("✅ Seisen Hub unloaded and cleaned up.")
end)
