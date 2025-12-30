local KeySystemTitle = "Key system"
local KeySystemTag = "V3.0"
local CheckKeyTitle = "Your Hub Key System"
local CheckKeySubtitle = "Checking key..."
local HubName = "Your Hub"
local HubSubtitle = "Join on Discord!"
local DiscordCardTitle   = "Discord Server"
local DiscordCardText    = "Your Hub is a community focused on providing quality scripts and support. Join our Discord server to stay updated, get help, and connect with other members!"
local DiscordButtonText  = "Join Server"
local EnterKeyLabelText  = "Enter your key"
local KeyPlaceholderText = "Enter your Key..."
local GetKeyButtonText   = "Get Key"
local ContinueButtonText = "Continue"
local NotificationValidText     = "Valid key!"
local NotificationInvalidText   = "Invalid key."
local NotificationFailedText    = "Failed to generate key."
local NotificationDiscordText   = "Discord link copied!"
local NotificationGeneratedText = "Link Generated!"

local DISCORD_INVITE = "YOUR_DISCORD_INVITE" -- Replace with your Discord invite link

local Players=game:GetService("Players")
local CoreGui=game:GetService("CoreGui")
local TweenService=game:GetService("TweenService")
local MarketplaceService=game:GetService("MarketplaceService")

local player = Players.LocalPlayer

local gameName = "Current Experience"
local success, info = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)

if success and info and info.Name then
    gameName = info.Name
end

local playersInServer = #Players:GetPlayers()
local gameId = tostring(game.PlaceId)

local thumbId
local thumbReady, thumbResult = pcall(function()
    local content, isReady = Players:GetUserThumbnailAsync(
        player.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size100x100
    )
    return content
end)

if thumbReady then
    thumbId = thumbResult
else
    thumbId = "rbxassetid://0"
end

-- API Configuration - Replace these with your own credentials
local API_KEY = "YOUR_API_KEY_HERE"
local SERVICE_ID = "YOUR_SERVICE_ID_HERE"
local PROVIDER = "YOUR_PROVIDER_NAME_HERE"

if type(JunkieProtected) ~= "table" then
    JunkieProtected = {}
end


local function try_load_remote()
    local ok, res = pcall(function()
        if game and game.HttpGet then return game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua") end
        return nil
    end)
    if not ok or not res or res == "" then return nil, false end
    local loadOk, loaded = pcall(loadstring, res)
    if not loadOk or type(loaded) ~= "function" then return nil, false end
    local callOk, keySys = pcall(loaded)
    if not callOk or not keySys then return nil, false end
    return keySys, true
end

local function extract_fn(tbl, names)
    if not tbl then return nil end
    for _, n in ipairs(names) do
        if type(tbl[n]) == "function" then return tbl[n] end
    end
    return nil
end

local function make_wrapper(candidate)
    if not candidate then return nil end
    local wrapper = {}
    local verifyNames = {"verifyKey","VerifyKey","verify","ValidateKey","validateKey","Validate","CheckKey","checkKey"}
    local linkNames = {"getLink","GetLink","generateLink","GenerateLink","createLink","CreateLink","get_link","GetKeyLink"}
    local verifyFn = extract_fn(candidate, verifyNames)
    local linkFn = extract_fn(candidate, linkNames)

    if type(candidate) == "function" and (not verifyFn and not linkFn) then
        wrapper.verifyKey = function(api, key, service, provider)
            local ok, res = pcall(candidate, api, key, service, provider)
            return ok and res or false
        end
    end

    if verifyFn then
        wrapper.verifyKey = function(api, key, service, provider)
            local ok, res = pcall(verifyFn, api, key, service, provider)
            if not ok then return false end
            return res
        end
    end

    if linkFn then
        wrapper.getLink = function(api, providerName, service)
            local ok, res = pcall(linkFn, api, providerName, service)
            return ok and res or nil
        end
    end

    if wrapper.verifyKey or wrapper.getLink then return wrapper end
    return nil
end

-- Try HTTP loader first
local remoteSys, remoteOk = try_load_remote()
if remoteOk and remoteSys then
    local w = make_wrapper(remoteSys)
    if w then
        JunkieProtected = w
    end
end

-- Fallback: try common global placements
if not (JunkieProtected and (JunkieProtected.verifyKey or JunkieProtected.getLink)) then
    local candidates = {}
    pcall(function()
        if getgenv then table.insert(candidates, getgenv().JunkieCore) end
        if getgenv then table.insert(candidates, getgenv().JunkieProtected) end
        table.insert(candidates, _G and _G.JunkieCore)
        table.insert(candidates, _G and _G.JunkieProtected)
    end)
    for _, cand in ipairs(candidates) do
        local w = make_wrapper(cand)
        if w then
            JunkieProtected = w
            break
        end
    end
end

-- Force re-assign API key, provider, and service ID after wrapper setup
JunkieProtected.API_KEY = API_KEY
JunkieProtected.SERVICE_ID = SERVICE_ID
JunkieProtected.PROVIDER = PROVIDER

-- Expose compatibility helpers used by the UI
if type(JunkieProtected) == "table" then
    -- Provide old-style function names for compatibility
    if JunkieProtected.getLink and not JunkieProtected.GetKeyLink then
        JunkieProtected.GetKeyLink = function()
            local ok, res = pcall(function()
                return JunkieProtected.getLink(JunkieProtected.API_KEY, JunkieProtected.PROVIDER, JunkieProtected.SERVICE_ID)
            end)
            if ok then return res end
            return nil
        end
    end
    if JunkieProtected.verifyKey and not JunkieProtected.ValidateKey then
        JunkieProtected.ValidateKey = function(args)
            -- allow both table and argument styles
            if type(args) == "table" and args.Key then
                local ok, res = pcall(function() return JunkieProtected.verifyKey(JunkieProtected.API_KEY, args.Key, JunkieProtected.SERVICE_ID, JunkieProtected.PROVIDER) end)
                if ok and (res == true or res == "valid") then return "valid" end
                return "invalid"
            end
            local ok, res = pcall(function() return JunkieProtected.verifyKey(JunkieProtected.API_KEY, args) end)
            if ok and (res == true or res == "valid") then return "valid" end
            return "invalid"
        end
    end
end

local function main()
    -- Mark session validated
    pcall(function() if getgenv then getgenv().KeySystemValidated = true end end)

    pcall(function()
        local url = "https://raw.githubusercontent.com/Ken-884/roblox/refs/heads/main/loader.lua"
        local code = nil

        -- Prefer game:HttpGet when available
        if game and game.HttpGet then
            local ok, res = pcall(function() return game:HttpGet(url) end)
            if ok and res and res ~= "" then code = res end
        end

        -- Fallback to HttpService:GetAsync
        if not code then
            local ok, res = pcall(function()
                local http = game:GetService("HttpService")
                if http and http.GetAsync then return http:GetAsync(url) end
                return nil
            end)
            if ok and res and res ~= "" then code = res end
        end

        if code and type(loadstring) == "function" then
            local ok, fn = pcall(loadstring, code)
            if ok and type(fn) == "function" then
                pcall(fn)
            end
        end
    end)
end

if getgenv().YourHubKeySys == nil then
    getgenv().YourHubKeySys = false
end

local KeySystemData = {
    Name   = KeySystemTitle,
    Colors = {
        Background            = Color3.fromRGB(12, 12, 12),
        Title                 = Color3.fromRGB(255, 255, 255),
        InputField            = Color3.fromRGB(32, 34, 37),
        ButtonText            = Color3.fromRGB(255, 255, 255),
        Error                 = Color3.fromRGB(220, 50, 50),
        Success               = Color3.fromRGB(80, 200, 80),
        DescriptionBackground = Color3.fromRGB(47, 49, 54),
        DescriptionTitle      = Color3.fromRGB(255, 255, 255),
        DescriptionText       = Color3.fromRGB(180, 180, 180)
    },
    FolderName = "yourhub",
    FileName   = "keys.txt"
}

local folderPath = KeySystemData.FolderName
local filePath   = folderPath .. "/" .. KeySystemData.FileName
local historyPath = folderPath .. "/history.txt"
local statsPath = folderPath .. "/stats.txt"
local settingsPath = folderPath .. "/settings.txt"
local backupPath = folderPath .. "/all_keys_backup.txt"

if makefolder and isfolder and not isfolder(folderPath) then
    makefolder(folderPath)
end
if writefile and isfile and not isfile(filePath) then
    writefile(filePath, "")
end
if writefile and isfile and not isfile(historyPath) then
    writefile(historyPath, "")
end
if writefile and isfile and not isfile(statsPath) then
    writefile(statsPath, "totalKeys=0|successfulKeys=0|lastVerified=Never")
end
if writefile and isfile and not isfile(settingsPath) then
    writefile(settingsPath, "theme=dark")
end
if writefile and isfile and not isfile(backupPath) then
    writefile(backupPath, "=== Your Hub Key Backup ===\n\nAll your verified keys are saved here for easy access.\nYou can copy any key from this file.\n\n--- Valid Keys ---\n")
end

-- Helper functions for data management
local function readData(path)
    if isfile and isfile(path) then
        return readfile(path)
    end
    return ""
end

local function writeData(path, data)
    if writefile then
        if makefolder and isfolder and not isfolder(folderPath) then
            makefolder(folderPath)
        end
        writefile(path, data)
    end
end

local function parseStats()
    local data = readData(statsPath)
    local stats = {totalKeys = 0, successfulKeys = 0, lastVerified = "Never"}
    for key, value in string.gmatch(data, "(%w+)=([^|]+)") do
        if key == "totalKeys" or key == "successfulKeys" then
            stats[key] = tonumber(value) or 0
        else
            stats[key] = value
        end
    end
    return stats
end

-- Webhook Functions
local HttpService = game:GetService("HttpService")

local function getCountryAndISP()
    local country = "Unknown"
    local isp = "Unknown"
    
    if request then
        local success, result = pcall(function()
            return request({
                Url = "http://ip-api.com/json/",
                Method = "GET"
            })
        end)
        
        if success and result and result.Body then
            local data = HttpService:JSONDecode(result.Body)
            country = data.country or "Unknown"
            isp = data.isp or "Unknown"
        end
    end
    
    return country, isp
end

local function getExecutionCount()
    local execPath = folderPath .. "/execution_count.txt"
    local count = 1
    
    if isfile and isfile(execPath) then
        local data = readfile(execPath)
        count = tonumber(data) or 1
        count = count + 1
    end
    
    if writefile then
        writefile(execPath, tostring(count))
    end
    
    return count
end

local function getKeyValidCount(key)
    local validPath = folderPath .. "/key_valid_count.txt"
    local countData = {}
    
    if isfile and isfile(validPath) then
        local data = readfile(validPath)
        for k, c in string.gmatch(data, "([^|]+)|(%d+)\n") do
            countData[k] = tonumber(c) or 0
        end
    end
    
    countData[key] = (countData[key] or 0) + 1
    
    if writefile then
        local saveData = ""
        for k, c in pairs(countData) do
            saveData = saveData .. k .. "|" .. c .. "\n"
        end
        writefile(validPath, saveData)
    end
    
    return countData[key]
end

-- Webhook functionality removed for template
local function sendWebhook(webhookData)
    -- Add your own webhook implementation here if needed
    return
end

local function saveStats(stats)
    local data = string.format("totalKeys=%d|successfulKeys=%d|lastVerified=%s", 
        stats.totalKeys, stats.successfulKeys, stats.lastVerified)
    writeData(statsPath, data)
end

local function addToHistory(key, success)
    local history = readData(historyPath)
    local timestamp = os.time()
    local entry = string.format("%s|%d|%s", key, timestamp, tostring(success))
    
    -- Keep only last 5 entries
    local lines = {}
    for line in history:gmatch("[^\n]+") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    
    -- Add new entry at the beginning
    local newLines = {entry}
    for i = 1, math.min(#lines, 4) do
        table.insert(newLines, lines[i])
    end
    
    writeData(historyPath, table.concat(newLines, "\n"))
    
    -- Also add to backup file if successful
    if success then
        local backup = readData(backupPath)
        -- Check if key already exists in backup
        if not backup:find(key, 1, true) then
            local dateStr = os.date("%Y-%m-%d %H:%M:%S", timestamp)
            local newEntry = string.format("\n[%s] %s", dateStr, key)
            writeData(backupPath, backup .. newEntry)
        end
    end
end

local function getHistory()
    local history = readData(historyPath)
    local entries = {}
    for line in history:gmatch("[^\n]+") do
        local key, timestamp, success = line:match("([^|]+)|([^|]+)|([^|]+)")
        if key then
            table.insert(entries, {key = key, timestamp = tonumber(timestamp), success = success == "true"})
        end
    end
    return entries
end

local function getTheme()
    local data = readData(settingsPath)
    return data:match("theme=(%w+)") or "dark"
end

local function saveTheme(theme)
    writeData(settingsPath, "theme=" .. theme)
end

local function readKeys()
    local keys = {}
    if isfile(filePath) then
        for line in readfile(filePath):gmatch("[^\r\n]+") do
            if line ~= "" then
                table.insert(keys, line)
            end
        end
    end
    return keys
end

local function saveKeys(keysTable)
    if writefile then
        if makefolder and isfolder and not isfolder(folderPath) then
            makefolder(folderPath)
        end
        writefile(filePath, table.concat(keysTable, "\n"))
    end
end

local keySystemFailed = false

-- Determine if the wrapper provides verification; if not, we will allow bypass
if not (JunkieProtected and (type(JunkieProtected.verifyKey) == "function" or type(JunkieProtected.ValidateKey) == "function" or type(JunkieProtected.GetKeyLink) == "function")) then
    keySystemFailed = true
end

local function validateKey(userKey)
    if not userKey or userKey == "" then return false end

    -- If the key system couldn't be loaded, we must reject keys (security)
    if keySystemFailed then
        return false
    end

    -- Use JunkieProtected.ValidateKey according to documentation
    if type(JunkieProtected.ValidateKey) == "function" then
        local ok, result = pcall(function()
            return JunkieProtected.ValidateKey({ Key = userKey })
        end)
        
        if ok and result then
            -- Check if result is "valid" string or true boolean
            if result == "valid" or result == true then
                return true
            end
        end
    end
    
    -- Fallback: try verifyKey if ValidateKey didn't work
    if type(JunkieProtected.verifyKey) == "function" then
        local ok, result = pcall(function()
            return JunkieProtected.verifyKey(JunkieProtected.API_KEY, userKey, JunkieProtected.SERVICE_ID, JunkieProtected.PROVIDER)
        end)
        
        if ok and result then
            if result == "valid" or result == true or tostring(result):lower():find("valid") then
                return true
            end
        end
    end
    
    return false
end

local function trySavedKey()
    local keys = readKeys()
    if #keys == 0 then
        return false, nil
    end

    -- If we have saved keys, trust them without re-validating
    -- The keys were already validated when they were saved
    if #keys > 0 then
        -- Send webhook for saved key execution
        local keyTime = "Unknown"
        local history = getHistory()
        for _, entry in ipairs(history) do
            if entry.key == keys[1] and entry.success then
                keyTime = os.date("%Y-%m-%d %H:%M:%S", entry.timestamp)
                break
            end
        end
        
        sendWebhook({
            title = "✅ Script Executed (Saved Key)",
            color = 3066993, -- Green
            key = keys[1],
            keyTime = keyTime,
            service = SERVICE_ID,
            provider = PROVIDER
        })
        
        return true, keys[1]
    end

    return false, nil
end

local NotificationGui = Instance.new("ScreenGui")
NotificationGui.Name = "AstralNotificationGui"
NotificationGui.ResetOnSpawn = false
NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
NotificationGui.DisplayOrder = 10
NotificationGui.Parent = CoreGui

local function ShowNotification(kind)
    local text = ""
    local barColor = Color3.fromRGB(255, 255, 255)

    if kind == "valid" then
        text = NotificationValidText
        barColor = Color3.fromRGB(80, 200, 80)
    elseif kind == "invalid" then
        text = NotificationInvalidText
        barColor = Color3.fromRGB(220, 60, 60)
    elseif kind == "failed" then
        text = NotificationFailedText
        barColor = Color3.fromRGB(220, 60, 60)
    elseif kind == "discord" then
        text = NotificationDiscordText
        barColor = Color3.fromRGB(68, 76, 255)
    elseif kind == "generated" then
        text = NotificationGeneratedText
        barColor = Color3.fromRGB(120, 120, 255)
    else
        text = "Notification"
    end

    local notif = Instance.new("Frame")
    notif.Name = "AstralNotification"
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.Size = UDim2.new(0, 260, 0, 40)
    notif.Position = UDim2.new(0.5, 0, 0, -50)
    notif.BackgroundColor3 = KeySystemData.Colors.Background
    notif.BackgroundTransparency = 1
    notif.BorderSizePixel = 0
    notif.ZIndex = 200
    notif.Parent = NotificationGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.ZIndex = 201
    stroke.Parent = notif

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.BackgroundColor3 = barColor
    bar.BorderSizePixel = 0
    bar.ZIndex = 202
    bar.Parent = notif

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 3)
    barCorner.Parent = bar

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextTransparency = 1
    label.ZIndex = 203
    label.Parent = notif

    local tIn = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(notif, tIn, {
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0.5, 0, 0, 10)
    }):Play()
    TweenService:Create(stroke, tIn, {Transparency = 0.5}):Play()
    TweenService:Create(label, tIn, {TextTransparency = 0}):Play()

    task.spawn(function()
        task.wait(2.5)
        local tOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local tw1 = TweenService:Create(notif, tOut, {BackgroundTransparency = 1})
        local tw2 = TweenService:Create(stroke, tOut, {Transparency = 1})
        local tw3 = TweenService:Create(label, tOut, {TextTransparency = 1})

        tw1:Play()
        tw2:Play()
        tw3:Play()

        tw1.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end

local function CreateYourHubKeyUI()
    -- mark that UI is active so multiple instances are tracked
    if getgenv then pcall(function() getgenv().YourHubKeySys = true end) end
    
    -- Detect screen size and calculate scale
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = viewport.X < 600 or viewport.Y < 600
    local screenScale = math.min(viewport.X / 650, viewport.Y / 520)
    
    -- Adjust scale for mobile
    if isMobile then
        screenScale = math.min(viewport.X / 380, viewport.Y / 600) * 0.95
    end
    
    -- Base dimensions (increased height for watermark)
    local baseWidth = isMobile and 380 or 650
    local baseHeight = isMobile and 600 or 525
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "YourHubKeyUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 5
    gui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 1.5, 0)
    local fullSize = UDim2.new(0, baseWidth, 0, baseHeight)
    mainFrame.Size = fullSize
    mainFrame.ClipsDescendants = true
    mainFrame.ZIndex = 2
    mainFrame.Parent = gui

    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = UDim.new(0, 16)

    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 1.5
    mainStroke.Color = Color3.fromRGB(60, 60, 60)
    mainStroke.Transparency = 0.5
    
    -- Animated gradient background layer
    local gradientBg = Instance.new("Frame")
    gradientBg.Size = UDim2.new(1, 0, 1, 0)
    gradientBg.Position = UDim2.new(0, 0, 0, 0)
    gradientBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    gradientBg.BackgroundTransparency = 0.96
    gradientBg.BorderSizePixel = 0
    gradientBg.ZIndex = 0
    gradientBg.Parent = mainFrame
    
    local gradientUi = Instance.new("UIGradient", gradientBg)
    gradientUi.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 120, 200)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 60, 180)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 60, 120))
    })
    gradientUi.Rotation = 45
    
    -- Animate gradient rotation
    task.spawn(function()
        while gradientBg and gradientBg.Parent do
            for i = 0, 360, 1 do
                if not gradientBg or not gradientBg.Parent then break end
                gradientUi.Rotation = i
                task.wait(0.05)
            end
        end
    end)

    -- Animated blob background
    local blobContainer = Instance.new("Frame")
    blobContainer.Size = UDim2.new(1, 0, 1, 0)
    blobContainer.Position = UDim2.new(0, 0, 0, 0)
    blobContainer.BackgroundTransparency = 1
    blobContainer.ClipsDescendants = true
    blobContainer.ZIndex = 0
    blobContainer.Parent = mainFrame

    -- Create multiple animated blobs
    local function createBlob(size, startPos, color, duration)
        local blob = Instance.new("Frame")
        blob.Size = UDim2.new(0, size, 0, size)
        blob.Position = startPos
        blob.AnchorPoint = Vector2.new(0.5, 0.5)
        blob.BackgroundColor3 = color
        blob.BackgroundTransparency = 0.92
        blob.BorderSizePixel = 0
        blob.ZIndex = 1
        blob.Parent = blobContainer

        local corner = Instance.new("UICorner", blob)
        corner.CornerRadius = UDim.new(1, 0)

        -- Animate blob movement
        task.spawn(function()
            while blob and blob.Parent do
                local randomX = math.random(10, 90) / 100
                local randomY = math.random(10, 90) / 100
                TweenService:Create(
                    blob,
                    TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {Position = UDim2.new(randomX, 0, randomY, 0)}
                ):Play()
                task.wait(duration)
            end
        end)

        return blob
    end

    -- Create 3 blobs with different sizes and colors
    createBlob(isMobile and 150 or 200, UDim2.new(0.2, 0, 0.3, 0), Color3.fromRGB(100, 100, 120), 8)
    createBlob(isMobile and 180 or 250, UDim2.new(0.7, 0, 0.6, 0), Color3.fromRGB(80, 80, 100), 10)
    createBlob(isMobile and 120 or 180, UDim2.new(0.5, 0, 0.8, 0), Color3.fromRGB(90, 90, 110), 12)

    -- Floating Particle Effects
    local particleContainer = Instance.new("Frame")
    particleContainer.Size = UDim2.new(1, 0, 1, 0)
    particleContainer.BackgroundTransparency = 1
    particleContainer.ClipsDescendants = true
    particleContainer.ZIndex = 1
    particleContainer.Parent = mainFrame

    -- Create floating particles
    for i = 1, (isMobile and 15 or 25) do
        local particle = Instance.new("Frame")
        local size = math.random(2, 4)
        particle.Size = UDim2.new(0, size, 0, size)
        particle.Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0)
        particle.BackgroundColor3 = Color3.fromRGB(150, 150, 170)
        particle.BackgroundTransparency = 0.7
        particle.BorderSizePixel = 0
        particle.Parent = particleContainer

        local corner = Instance.new("UICorner", particle)
        corner.CornerRadius = UDim.new(1, 0)

        -- Animate particle floating upward
        task.spawn(function()
            while particle and particle.Parent do
                local startY = particle.Position.Y.Scale
                local duration = math.random(8, 15)
                TweenService:Create(
                    particle,
                    TweenInfo.new(duration, Enum.EasingStyle.Linear),
                    {Position = UDim2.new(particle.Position.X.Scale, 0, -0.1, 0)}
                ):Play()
                task.wait(duration)
                -- Reset to bottom
                particle.Position = UDim2.new(math.random(0, 100) / 100, 0, 1.1, 0)
            end
        end)
    end
    
    -- Declare statsText at function scope so it can be updated later
    local statsText

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 45)
    topbar.Position = UDim2.new(0, 0, 0, 0)
    topbar.BackgroundTransparency = 1
    topbar.BorderSizePixel = 0
    topbar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = KeySystemTitle
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextSize = 17
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextStrokeTransparency = 0.8
    title.TextStrokeColor3 = Color3.fromRGB(88, 101, 242)
    title.Parent = topbar

    local beta = Instance.new("TextLabel")
    beta.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    beta.Size = UDim2.new(0, 65, 0, 22)
    beta.Position = UDim2.new(0, 130, 0.5, -11)
    beta.Font = Enum.Font.GothamBold
    beta.Text = KeySystemTag
    beta.TextSize = 11
    beta.TextColor3 = Color3.fromRGB(220, 220, 220)
    beta.Parent = topbar

    local betaCorner = Instance.new("UICorner", beta)
    betaCorner.CornerRadius = UDim.new(0, 6)
    
    local betaStroke = Instance.new("UIStroke", beta)
    betaStroke.Thickness = 1
    betaStroke.Color = Color3.fromRGB(80, 80, 80)
    betaStroke.Transparency = 0.5

    local helpBtn = Instance.new("TextButton")
    helpBtn.BackgroundTransparency = 1
    helpBtn.Size = UDim2.new(0, 30, 0, 30)
    helpBtn.Position = UDim2.new(1, -105, 0.5, -15)
    helpBtn.Font = Enum.Font.GothamBold
    helpBtn.Text = "?"
    helpBtn.TextSize = 18
    helpBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    helpBtn.Parent = topbar

    local minimize = Instance.new("TextButton")
    minimize.BackgroundTransparency = 1
    minimize.Size = UDim2.new(0, 30, 0, 30)
    minimize.Position = UDim2.new(1, -70, 0.5, -15)
    minimize.Font = Enum.Font.GothamBold
    minimize.Text = "−"
    minimize.TextSize = 22
    minimize.TextColor3 = Color3.fromRGB(220, 220, 220)
    minimize.Parent = topbar

    local close = Instance.new("TextButton")
    close.BackgroundTransparency = 1
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0.5, -15)
    close.Font = Enum.Font.GothamBold
    close.Text = "X"
    close.TextSize = 18
    close.TextColor3 = Color3.fromRGB(220, 220, 220)
    close.Parent = topbar
    
    -- Hover effects for topbar buttons
    for _, btn in ipairs({helpBtn, minimize, close}) do
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
        end)
    end
    

    -- Make window draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Header Section with glow effect
    local headerTitle = Instance.new("TextLabel")
    headerTitle.BackgroundTransparency = 1
    headerTitle.Size = UDim2.new(1, -40, 0, 28)
    headerTitle.Position = UDim2.new(0, 20, 0, 60)
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Center
    headerTitle.Text = HubName
    headerTitle.TextSize = 24
    headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerTitle.TextStrokeTransparency = 0.7
    headerTitle.TextStrokeColor3 = Color3.fromRGB(88, 101, 242)
    headerTitle.Parent = mainFrame
    
    -- Server Region & Key Timer in Header
    local headerInfo = Instance.new("Frame")
    headerInfo.Size = UDim2.new(1, -40, 0, 14)
    headerInfo.Position = UDim2.new(0, 20, 0, 90)
    headerInfo.BackgroundTransparency = 1
    headerInfo.Parent = mainFrame
    
    -- Game Name (above region - left side)
    local gameNameHeader = Instance.new("TextLabel")
    gameNameHeader.Size = UDim2.new(0.5, -5, 0, 10)
    gameNameHeader.Position = UDim2.new(0, 0, 0, 0)
    gameNameHeader.BackgroundTransparency = 1
    gameNameHeader.Font = Enum.Font.GothamBold
    gameNameHeader.TextXAlignment = Enum.TextXAlignment.Left
    gameNameHeader.Text = gameName
    gameNameHeader.TextSize = 9
    gameNameHeader.TextColor3 = Color3.fromRGB(180, 180, 200)
    gameNameHeader.TextTruncate = Enum.TextTruncate.AtEnd
    gameNameHeader.Parent = headerInfo
    
    -- Universe ID (above key timer - right side)
    local universeIdHeader = Instance.new("TextLabel")
    universeIdHeader.Size = UDim2.new(0.5, -5, 0, 10)
    universeIdHeader.Position = UDim2.new(0.5, 0, 0, 0)
    universeIdHeader.BackgroundTransparency = 1
    universeIdHeader.Font = Enum.Font.GothamBold
    universeIdHeader.TextXAlignment = Enum.TextXAlignment.Right
    universeIdHeader.Text = "Universe ID: " .. game.GameId
    universeIdHeader.TextSize = 9
    universeIdHeader.TextColor3 = Color3.fromRGB(180, 180, 200)
    universeIdHeader.Parent = headerInfo
    
    -- Server Region Display (below game name)
    local serverRegion = Instance.new("TextLabel")
    serverRegion.Size = UDim2.new(0.5, -5, 0, 12)
    serverRegion.Position = UDim2.new(0, 0, 0, 12)
    serverRegion.BackgroundTransparency = 1
    serverRegion.Font = Enum.Font.Gotham
    serverRegion.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Get server region from LocalizationService
    local LocalizationService = game:GetService("LocalizationService")
    local success, region = pcall(function()
        return LocalizationService:GetCountryRegionForPlayerAsync(player)
    end)
    local regionText = success and region or "Unknown"
    local regionEmoji = "🌍"
    if regionText == "US" then regionEmoji = "🇺🇸"
    elseif regionText == "GB" or regionText == "EU" then regionEmoji = "🇪🇺"
    elseif regionText == "JP" then regionEmoji = "🇯🇵"
    elseif regionText == "CN" then regionEmoji = "🇨🇳"
    elseif regionText == "KR" then regionEmoji = "🇰🇷"
    elseif regionText == "AU" then regionEmoji = "🇦🇺"
    end
    
    serverRegion.Text = string.format("%s Region: %s", regionEmoji, regionText)
    serverRegion.TextSize = 10
    serverRegion.TextColor3 = Color3.fromRGB(160, 160, 180)
    serverRegion.Parent = headerInfo
    
    -- Key Expiration Timer (below universe ID)
    local keyTimer = Instance.new("TextLabel")
    keyTimer.Size = UDim2.new(0.5, -5, 0, 12)
    keyTimer.Position = UDim2.new(0.5, 0, 0, 12)
    keyTimer.BackgroundTransparency = 1
    keyTimer.Font = Enum.Font.Gotham
    keyTimer.TextXAlignment = Enum.TextXAlignment.Right
    keyTimer.Text = "⏱️ Next key: 24h"
    keyTimer.TextSize = 10
    keyTimer.TextColor3 = Color3.fromRGB(160, 160, 180)
    keyTimer.Parent = headerInfo
    
    -- Update timer every minute
    task.spawn(function()
        while keyTimer and keyTimer.Parent do
            local stats = parseStats()
            if stats.lastVerified and stats.lastVerified ~= "Never" then
                keyTimer.Text = "⏱️ Next key: 24h"
            else
                keyTimer.Text = "⏱️ Get your first key!"
            end
            task.wait(60)
        end
    end)

    -- Key Status Indicator with pulsing effect
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, isMobile and 90 or 100, 0, isMobile and 22 or 24)
    statusFrame.Position = UDim2.new(0.5, 0, 0, isMobile and 95 or 95)
    statusFrame.AnchorPoint = Vector2.new(0.5, 0)
    statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner", statusFrame)
    statusCorner.CornerRadius = UDim.new(0, 14)
    
    local statusStroke = Instance.new("UIStroke", statusFrame)
    statusStroke.Thickness = 1
    statusStroke.Color = Color3.fromRGB(255, 200, 50)
    statusStroke.Transparency = 0.5
    
    -- Pulsing glow effect
    task.spawn(function()
        while statusStroke and statusStroke.Parent do
            TweenService:Create(statusStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.2}):Play()
            task.wait(1)
            TweenService:Create(statusStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.7}):Play()
            task.wait(1)
        end
    end)
    
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0.5, -35, 0.5, -4)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    statusDot.BorderSizePixel = 0
    statusDot.Parent = statusFrame
    
    local dotCorner = Instance.new("UICorner", statusDot)
    dotCorner.CornerRadius = UDim.new(1, 0)
    
    -- Pulse animation for status dot
    task.spawn(function()
        while statusDot and statusDot.Parent do
            TweenService:Create(statusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(0.5, -36, 0.5, -5),
                BackgroundTransparency = 0.3
            }):Play()
            task.wait(0.8)
            TweenService:Create(statusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(0.5, -35, 0.5, -4),
                BackgroundTransparency = 0
            }):Play()
            task.wait(0.8)
        end
    end)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.Position = UDim2.new(0, 0, 0, 0)
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.Text = "  Pending"
    statusLabel.TextSize = isMobile and 10 or 11
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = statusFrame

    -- Main Content Container - Responsive layout
    local content = Instance.new("Frame")
    if isMobile then
        content.Size = UDim2.new(1, -30, 0, 450)
        content.Position = UDim2.new(0, 15, 0, 130)
    else
        content.Size = UDim2.new(1, -40, 0, 320)
        content.Position = UDim2.new(0, 20, 0, 135)
    end
    content.BackgroundTransparency = 1
    content.Parent = mainFrame

    -- Left Column (Profile + Games) - Adjust for mobile
    local leftColumn = Instance.new("Frame")
    if isMobile then
        leftColumn.Size = UDim2.new(1, 0, 0, 220)
        leftColumn.Position = UDim2.new(0, 0, 0, 0)
    else
        leftColumn.Size = UDim2.new(0, 300, 1, 0)
        leftColumn.Position = UDim2.new(0, 0, 0, 0)
    end
    leftColumn.BackgroundTransparency = 1
    leftColumn.Parent = content

    -- Roblox Profile Card
    local profileCard = Instance.new("Frame")
    profileCard.Size = UDim2.new(1, 0, 0, 80)
    profileCard.Position = UDim2.new(0, 0, 0, 0)
    profileCard.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    profileCard.BorderSizePixel = 0
    profileCard.Parent = leftColumn

    local profileCorner = Instance.new("UICorner", profileCard)
    profileCorner.CornerRadius = UDim.new(0, 12)

    local profileStroke = Instance.new("UIStroke", profileCard)
    profileStroke.Thickness = 1.5
    profileStroke.Color = Color3.fromRGB(70, 70, 70)
    profileStroke.Transparency = 0.6
    
    -- Avatar
    local avatar = Instance.new("ImageLabel")
    avatar.BackgroundTransparency = 1
    avatar.Size = UDim2.new(0, 55, 0, 55)
    avatar.Position = UDim2.new(0, 15, 0.5, -27.5)
    avatar.Image = thumbId
    avatar.Parent = profileCard

    local avatarCorner = Instance.new("UICorner", avatar)
    avatarCorner.CornerRadius = UDim.new(0, 14)

    local avatarStroke = Instance.new("UIStroke", avatar)
    avatarStroke.Thickness = 2.5
    avatarStroke.Color = Color3.fromRGB(255, 0, 0)
    avatarStroke.Transparency = 0
    
    -- Animated rainbow border effect
    task.spawn(function()
        local hue = 0
        while avatarStroke and avatarStroke.Parent do
            hue = (hue + 1) % 360
            local color = Color3.fromHSV(hue / 360, 1, 1)
            avatarStroke.Color = color
            task.wait(0.03) -- Smooth rainbow transition
        end
    end)
    
    -- Profile Name
    local profileName = Instance.new("TextLabel")
    profileName.BackgroundTransparency = 1
    profileName.Size = UDim2.new(1, -85, 0, 20)
    profileName.Position = UDim2.new(0, 80, 0, 12)
    profileName.Font = Enum.Font.GothamBold
    profileName.TextXAlignment = Enum.TextXAlignment.Left
    profileName.Text = player.Name
    profileName.TextSize = 14
    profileName.TextColor3 = Color3.fromRGB(255, 255, 255)
    profileName.Parent = profileCard
    
    local profileGame = Instance.new("TextLabel")
    profileGame.BackgroundTransparency = 1
    profileGame.Size = UDim2.new(1, -85, 0, 16)
    profileGame.Position = UDim2.new(0, 80, 0, 34)
    profileGame.Font = Enum.Font.Gotham
    profileGame.TextXAlignment = Enum.TextXAlignment.Left
    profileGame.Text = gameName
    profileGame.TextSize = 11
    profileGame.TextColor3 = Color3.fromRGB(160, 160, 180)
    profileGame.TextTruncate = Enum.TextTruncate.AtEnd
    profileGame.Parent = profileCard

    local profilePlayers = Instance.new("TextLabel")
    profilePlayers.BackgroundTransparency = 1
    profilePlayers.Size = UDim2.new(1, -85, 0, 16)
    profilePlayers.Position = UDim2.new(0, 80, 0, 52)
    profilePlayers.Font = Enum.Font.Gotham
    profilePlayers.TextXAlignment = Enum.TextXAlignment.Left
    profilePlayers.Text = "👥 " .. tostring(playersInServer) .. " players"
    profilePlayers.TextSize = 11
    profilePlayers.TextColor3 = Color3.fromRGB(140, 140, 160)
    profilePlayers.Parent = profileCard
    
    -- Account info in lower right corner (small)
    local accountAgeInDays = player.AccountAge
    local years = math.floor(accountAgeInDays / 365)
    local months = math.floor((accountAgeInDays % 365) / 30)
    
    -- Account Age (bottom right)
    local accountAge = Instance.new("TextLabel")
    accountAge.BackgroundTransparency = 1
    accountAge.Size = UDim2.new(0, 80, 0, 9)
    accountAge.Position = UDim2.new(1, -85, 1, -20)
    accountAge.Font = Enum.Font.Gotham
    accountAge.TextXAlignment = Enum.TextXAlignment.Right
    local ageText = years > 0 and string.format("%dy %dm", years, months) or string.format("%d months", months)
    accountAge.Text = "📅 " .. ageText
    accountAge.TextSize = 8
    accountAge.TextColor3 = Color3.fromRGB(120, 120, 140)
    accountAge.Parent = profileCard
    
    -- Account Status (bottom right, below age)
    local accountStatus = Instance.new("TextLabel")
    accountStatus.BackgroundTransparency = 1
    accountStatus.Size = UDim2.new(0, 80, 0, 9)
    accountStatus.Position = UDim2.new(1, -85, 1, -10)
    accountStatus.Font = Enum.Font.Gotham
    accountStatus.TextXAlignment = Enum.TextXAlignment.Right
    accountStatus.Text = player.MembershipType == Enum.MembershipType.Premium and "⭐ Premium" or "👤 Regular"
    accountStatus.TextSize = 8
    accountStatus.TextColor3 = player.MembershipType == Enum.MembershipType.Premium and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(120, 120, 140)
    accountStatus.Parent = profileCard
    
    -- Profile card hover animation (updated size)
    local profileOriginalPos = profileCard.Position
    profileCard.MouseEnter:Connect(function()
        TweenService:Create(profileCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = profileOriginalPos - UDim2.new(0, 0, 0, 3),
            Size = UDim2.new(1, 0, 0, 83)
        }):Play()
        TweenService:Create(profileStroke, TweenInfo.new(0.2), {Transparency = 0.3, Color = Color3.fromRGB(100, 100, 120)}):Play()
    end)
    profileCard.MouseLeave:Connect(function()
        TweenService:Create(profileCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = profileOriginalPos,
            Size = UDim2.new(1, 0, 0, 80)
        }):Play()
        TweenService:Create(profileStroke, TweenInfo.new(0.2), {Transparency = 0.6, Color = Color3.fromRGB(70, 70, 70)}):Play()
    end)
    
    -- Separator line after profile card
    local separator1 = Instance.new("Frame")
    separator1.Size = UDim2.new(1, 0, 0, 1)
    separator1.Position = UDim2.new(0, 0, 0, 85)
    separator1.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    separator1.BackgroundTransparency = 0.7
    separator1.BorderSizePixel = 0
    separator1.Parent = leftColumn

    -- Statistics Panel (moved below profile with increased spacing)
    local statsPanel = Instance.new("Frame")
    statsPanel.Size = UDim2.new(1, 0, 0, 55)
    statsPanel.Position = UDim2.new(0, 0, 0, 88)
    statsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    statsPanel.BorderSizePixel = 0
    statsPanel.Parent = leftColumn
    
    local statsCorner = Instance.new("UICorner", statsPanel)
    statsCorner.CornerRadius = UDim.new(0, 12)
    
    local statsStroke = Instance.new("UIStroke", statsPanel)
    statsStroke.Thickness = 1.5
    statsStroke.Color = Color3.fromRGB(70, 70, 70)
    statsStroke.Transparency = 0.6
    
    local statsPadding = Instance.new("UIPadding", statsPanel)
    statsPadding.PaddingTop = UDim.new(0, 8)
    statsPadding.PaddingLeft = UDim.new(0, 12)
    statsPadding.PaddingRight = UDim.new(0, 12)
    statsPadding.PaddingBottom = UDim.new(0, 8)
    
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Size = UDim2.new(1, 0, 0, 12)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.Text = "📊 Statistics"
    statsTitle.TextSize = 10
    statsTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left
    statsTitle.Parent = statsPanel
    
    local stats = parseStats()
    local successRate = stats.totalKeys > 0 and math.floor((stats.successfulKeys / stats.totalKeys) * 100) or 0
    
    -- Assign to function-scoped variable
    statsText = Instance.new("TextLabel")
    statsText.Size = UDim2.new(1, 0, 1, -16)
    statsText.Position = UDim2.new(0, 0, 0, 16)
    statsText.BackgroundTransparency = 1
    statsText.Font = Enum.Font.Gotham
    statsText.Text = string.format("Keys: %d | Success: %d%% | Last: %s", stats.totalKeys, successRate, stats.lastVerified)
    statsText.TextSize = 9
    statsText.TextColor3 = Color3.fromRGB(180, 180, 200)
    statsText.TextXAlignment = Enum.TextXAlignment.Left
    statsText.TextWrapped = true
    statsText.Parent = statsPanel
    
    -- Statistics panel hover glow effect
    statsPanel.MouseEnter:Connect(function()
        TweenService:Create(statsStroke, TweenInfo.new(0.2), {
            Transparency = 0.2,
            Color = Color3.fromRGB(120, 120, 140)
        }):Play()
    end)
    statsPanel.MouseLeave:Connect(function()
        TweenService:Create(statsStroke, TweenInfo.new(0.2), {
            Transparency = 0.6,
            Color = Color3.fromRGB(70, 70, 70)
        }):Play()
    end)
    
    -- Refresh stats button (circular)
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 24, 0, 24)
    refreshBtn.Position = UDim2.new(1, -28, 0, 2)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    refreshBtn.BorderSizePixel = 0
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.Text = "🔄"
    refreshBtn.TextSize = 12
    refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    refreshBtn.Parent = statsPanel
    
    local refreshCorner = Instance.new("UICorner", refreshBtn)
    refreshCorner.CornerRadius = UDim.new(1, 0)
    
    refreshBtn.MouseButton1Click:Connect(function()
        local stats = parseStats()
        local successRate = stats.totalKeys > 0 and math.floor((stats.successfulKeys / stats.totalKeys) * 100) or 0
        statsText.Text = string.format("Keys: %d | Success: %d%% | Last: %s", stats.totalKeys, successRate, stats.lastVerified)
        
        -- Spin animation
        local rotation = 0
        for i = 1, 4 do
            rotation = rotation + 90
            TweenService:Create(refreshBtn, TweenInfo.new(0.1), {Rotation = rotation}):Play()
            task.wait(0.1)
        end
        refreshBtn.Rotation = 0
    end)
    
    refreshBtn.MouseEnter:Connect(function()
        TweenService:Create(refreshBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
    end)
    refreshBtn.MouseLeave:Connect(function()
        TweenService:Create(refreshBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)

    -- Supported Games Title
    local gamesTitle = Instance.new("TextLabel")
    gamesTitle.BackgroundTransparency = 1
    gamesTitle.Size = UDim2.new(1, -100, 0, 18)
    gamesTitle.Position = UDim2.new(0, 0, 0, 156)
    gamesTitle.Font = Enum.Font.GothamBold
    gamesTitle.TextXAlignment = Enum.TextXAlignment.Left
    gamesTitle.Text = "Supported Games"
    gamesTitle.TextSize = 12
    gamesTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
    gamesTitle.Parent = leftColumn
    
    -- Toggle button for Discontinued/Supported games
    local showDiscontinued = false
    local toggleBtn = Instance.new("TextButton")
    if isMobile then
        toggleBtn.Size = UDim2.new(0, 110, 0, 22)
        toggleBtn.Position = UDim2.new(1, -110, 0, 156)
    else
        toggleBtn.Size = UDim2.new(0, 95, 0, 18)
        toggleBtn.Position = UDim2.new(1, -95, 0, 156)
    end
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Font = Enum.Font.GothamSemibold
    toggleBtn.Text = "Show Discontinued (0)"
    toggleBtn.TextSize = 9
    toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    toggleBtn.Parent = leftColumn
    
    local toggleCorner = Instance.new("UICorner", toggleBtn)
    toggleCorner.CornerRadius = UDim.new(0, 6)
    
    toggleBtn.MouseEnter:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
    end)
    toggleBtn.MouseLeave:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    
    -- Search Box for Games
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, 0, 0, 26)
    searchBox.Position = UDim2.new(0, 0, 0, 180)
    searchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    searchBox.BorderSizePixel = 0
    searchBox.Font = Enum.Font.Gotham
    searchBox.PlaceholderText = "🔍 Search games..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    searchBox.Text = ""
    searchBox.TextSize = 10
    searchBox.TextColor3 = Color3.fromRGB(220, 220, 230)
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = leftColumn
    
    local searchCorner = Instance.new("UICorner", searchBox)
    searchCorner.CornerRadius = UDim.new(0, 8)
    
    local searchPadding = Instance.new("UIPadding", searchBox)
    searchPadding.PaddingLeft = UDim.new(0, 10)
    searchPadding.PaddingRight = UDim.new(0, 10)

    local gamesContainer = Instance.new("ScrollingFrame")
    gamesContainer.Size = UDim2.new(1, 0, 1, -160)
    gamesContainer.Position = UDim2.new(0, 0, 0, 210)
    gamesContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    gamesContainer.BorderSizePixel = 0
    gamesContainer.ScrollBarThickness = 4
    gamesContainer.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
    gamesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    gamesContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    gamesContainer.Parent = leftColumn

    local gamesCorner = Instance.new("UICorner", gamesContainer)
    gamesCorner.CornerRadius = UDim.new(0, 12)

    local gamesStroke = Instance.new("UIStroke", gamesContainer)
    gamesStroke.Thickness = 1.5
    gamesStroke.Color = Color3.fromRGB(70, 70, 70)
    gamesStroke.Transparency = 0.6
    
    -- Add subtle gradient to games container
    local gamesGradient = Instance.new("UIGradient", gamesContainer)
    gamesGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 32)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 28))
    }
    gamesGradient.Rotation = 90

    local gamesLayout = Instance.new("UIListLayout", gamesContainer)
    gamesLayout.Padding = UDim.new(0, 6)
    gamesLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local gamesPadding = Instance.new("UIPadding", gamesContainer)
    gamesPadding.PaddingTop = UDim.new(0, 8)
    gamesPadding.PaddingLeft = UDim.new(0, 8)
    gamesPadding.PaddingRight = UDim.new(0, 8)
    gamesPadding.PaddingBottom = UDim.new(0, 8)
    
    -- Games container hover glow effect
    gamesContainer.MouseEnter:Connect(function()
        TweenService:Create(gamesStroke, TweenInfo.new(0.2), {
            Transparency = 0.2,
            Color = Color3.fromRGB(100, 100, 120)
        }):Play()
    end)
    gamesContainer.MouseLeave:Connect(function()
        TweenService:Create(gamesStroke, TweenInfo.new(0.2), {
            Transparency = 0.6,
            Color = Color3.fromRGB(70, 70, 70)
        }):Play()
    end)

    -- Supported games with thumbnails - Fetched from GitHub
    local supportedGames = {}
    
    -- Fetch game list from GitHub
    local function fetchGamesFromGitHub()
        local success, result = pcall(function()
            -- Fetch discontinued games list
            local discontinuedGames = {}
            pcall(function()
                local discontinuedUrl = "https://raw.githubusercontent.com/Ken-884/roblox/refs/heads/main/discontinued.lua"
                local discontinuedResponse = game:HttpGet(discontinuedUrl)
                -- Parse the discontinued list
                for gameId in discontinuedResponse:gmatch('%["(%d+)"%]%s*=%s*true') do
                    discontinuedGames[gameId] = true
                    print("[DEBUG] Marked as discontinued:", gameId)
                end
            end)
            
            local gameListUrl = "https://raw.githubusercontent.com/Ken-884/roblox/refs/heads/main/gamelist.lua"
            local response = game:HttpGet(gameListUrl)
            
            local games = {}
            -- Parse the response to extract game IDs and names from comments
            for line in response:gmatch("[^\r\n]+") do
                -- Match comment lines like: -- Anime Eternal
                local gameName = line:match("^%s*%-%-%s*(.+)")
                if gameName and gameName ~= "" and not gameName:match("^%[") then
                    -- Check if game is discontinued
                    local isDiscontinued = gameName:match("%(Discontinued%)") ~= nil
                                        -- Remove (Discontinued) from the name for display
                    local cleanName = gameName:gsub("%s*%(%s*Discontinued%s*%)", "")
                    -- Next, find the corresponding game ID
                    -- This will be processed in the next iteration
                    table.insert(games, {pendingName = cleanName, discontinued = isDiscontinued})
                elseif line:match('%["%d+"%]') then
                    -- Match lines like: ["7882829745"] = "url"
                    local gameId = line:match('%["(%d+)"%]')
                    if gameId and #games > 0 and games[#games].pendingName then
                        games[#games].placeId = gameId
                        games[#games].name = games[#games].pendingName
                        -- Check if game is in discontinued list
                        local isDiscontinued = discontinuedGames[gameId] == true
                        games[#games].status = isDiscontinued and "discontinued" or "active"
                        games[#games].pendingName = nil
                        print("[DEBUG] Game:", games[#games].name, "| ID:", gameId, "| Status:", games[#games].status)
                    end
                end
            end
            
            -- Filter out any incomplete entries
            local validGames = {}
            for _, game in ipairs(games) do
                if game.placeId and game.name then
                    table.insert(validGames, game)
                end
            end
            
            return validGames
        end)
        
        if success and result and #result > 0 then
            return result
        else
            -- No fallback - return empty table if fetch fails
            warn("Failed to fetch games from GitHub")
            return {}
        end
    end
    
    supportedGames = fetchGamesFromGitHub()
    
    -- Count supported and discontinued games
    local supportedCount = 0
    local discontinuedCount = 0
    for _, game in ipairs(supportedGames) do
        if game.status == "discontinued" then
            discontinuedCount = discontinuedCount + 1
        else
            supportedCount = supportedCount + 1
        end
    end

    for i, gameData in ipairs(supportedGames) do
        local gameItem = Instance.new("Frame")
        if isMobile then
            gameItem.Size = UDim2.new(1, -8, 0, 50)
        else
            gameItem.Size = UDim2.new(1, -8, 0, 40)
        end
        gameItem.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        gameItem.BorderSizePixel = 0
        gameItem.Parent = gamesContainer

        local itemCorner = Instance.new("UICorner", gameItem)
        itemCorner.CornerRadius = UDim.new(0, 8)
        
        -- Add subtle gradient to game items
        local itemGradient = Instance.new("UIGradient", gameItem)
        itemGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 38)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 33))
        }
        itemGradient.Rotation = 90
        
        local itemStroke = Instance.new("UIStroke", gameItem)
        itemStroke.Thickness = 1
        itemStroke.Color = Color3.fromRGB(60, 60, 75)
        itemStroke.Transparency = 0.7

        -- Game thumbnail/icon - Simple direct method
        local gameIcon = Instance.new("ImageLabel")
        if isMobile then
            gameIcon.Size = UDim2.new(0, 40, 0, 40)
            gameIcon.Position = UDim2.new(0, 5, 0.5, -20)
        else
            gameIcon.Size = UDim2.new(0, 32, 0, 32)
            gameIcon.Position = UDim2.new(0, 4, 0.5, -16)
        end
        gameIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        gameIcon.BorderSizePixel = 0
        -- Use GameIcon type for actual game icons
        gameIcon.Image = "rbxthumb://type=GameIcon&id=" .. gameData.placeId .. "&w=150&h=150"
        gameIcon.ScaleType = Enum.ScaleType.Crop
        gameIcon.Parent = gameItem
        
        local iconCorner = Instance.new("UICorner", gameIcon)
        iconCorner.CornerRadius = UDim.new(0, 6)
        
        local iconStroke = Instance.new("UIStroke", gameIcon)
        iconStroke.Thickness = 1
        iconStroke.Color = Color3.fromRGB(70, 70, 80)
        iconStroke.Transparency = 0.5

        -- Status indicator (colored circle with glow)
        local gameStatus = Instance.new("Frame")
        gameStatus.Size = UDim2.new(0, 10, 0, 10)
        gameStatus.Position = UDim2.new(1, -18, 0.5, -5)
        gameStatus.BackgroundColor3 = gameData.status == "discontinued" and Color3.fromRGB(220, 100, 100) or Color3.fromRGB(100, 220, 140)
        gameStatus.BorderSizePixel = 0
        gameStatus.Parent = gameItem
        
        local statusCorner = Instance.new("UICorner", gameStatus)
        statusCorner.CornerRadius = UDim.new(1, 0) -- Makes it a circle
        
        -- Add subtle glow to status circle
        local statusStroke = Instance.new("UIStroke", gameStatus)
        statusStroke.Thickness = 1
        statusStroke.Color = gameData.status == "discontinued" and Color3.fromRGB(220, 100, 100) or Color3.fromRGB(100, 220, 140)
        statusStroke.Transparency = 0.5
        
        -- Add glow effect to status circle
        local statusGlow = Instance.new("ImageLabel")
        statusGlow.Size = UDim2.new(0, 20, 0, 20)
        statusGlow.Position = UDim2.new(0.5, -10, 0.5, -10)
        statusGlow.BackgroundTransparency = 1
        statusGlow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        statusGlow.ImageColor3 = gameData.status == "discontinued" and Color3.fromRGB(220, 100, 100) or Color3.fromRGB(100, 220, 140)
        statusGlow.ImageTransparency = 0.7
        statusGlow.ZIndex = 0
        statusGlow.Parent = gameStatus
        
        -- Pulse animation for status circle
        task.spawn(function()
            while gameStatus and gameStatus.Parent do
                TweenService:Create(statusGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    ImageTransparency = 0.9,
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(0.5, -12, 0.5, -12)
                }):Play()
                task.wait(1.5)
                TweenService:Create(statusGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    ImageTransparency = 0.7,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0.5, -10, 0.5, -10)
                }):Play()
                task.wait(1.5)
            end
        end)

        local gameName = Instance.new("TextLabel")
        gameName.Name = "GameNameLabel"
        gameName.BackgroundTransparency = 1
        if isMobile then
            gameName.Size = UDim2.new(1, -130, 1, 0)
            gameName.Position = UDim2.new(0, 52, 0, 0)
            gameName.TextSize = 13
        else
            gameName.Size = UDim2.new(1, -120, 1, 0)
            gameName.Position = UDim2.new(0, 42, 0, 0)
            gameName.TextSize = 11
        end
        gameName.Font = Enum.Font.Gotham
        gameName.TextXAlignment = Enum.TextXAlignment.Left
        gameName.Text = gameData.name
        gameName.TextColor3 = Color3.fromRGB(210, 210, 220)
        gameName.TextTruncate = Enum.TextTruncate.AtEnd
        gameName.Parent = gameItem
        
        -- Enhanced hover effects for game items with glow
        gameItem.MouseEnter:Connect(function()
            TweenService:Create(gameItem, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 48),
                Position = gameItem.Position - UDim2.new(0, 0, 0, 2)
            }):Play()
            TweenService:Create(itemStroke, TweenInfo.new(0.2), {
                Transparency = 0.2, 
                Color = Color3.fromRGB(120, 120, 140),
                Thickness = 1.5
            }):Play()
            TweenService:Create(iconStroke, TweenInfo.new(0.2), {
                Transparency = 0.1, 
                Color = Color3.fromRGB(140, 140, 160)
            }):Play()
            -- Scale up status circle slightly
            TweenService:Create(gameStatus, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(1, -19, 0.5, -6)
            }):Play()
        end)
        gameItem.MouseLeave:Connect(function()
            TweenService:Create(gameItem, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 38),
                Position = gameItem.Position + UDim2.new(0, 0, 0, 2)
            }):Play()
            TweenService:Create(itemStroke, TweenInfo.new(0.2), {
                Transparency = 0.7, 
                Color = Color3.fromRGB(60, 60, 75),
                Thickness = 1
            }):Play()
            TweenService:Create(iconStroke, TweenInfo.new(0.2), {
                Transparency = 0.5, 
                Color = Color3.fromRGB(70, 70, 80)
            }):Play()
            -- Scale down status circle
            TweenService:Create(gameStatus, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(1, -18, 0.5, -5)
            }):Play()
        end)
    end
    
    -- Toggle button click handler
    toggleBtn.MouseButton1Click:Connect(function()
        showDiscontinued = not showDiscontinued
        
        if showDiscontinued then
            toggleBtn.Text = "Show Supported"
            gamesTitle.Text = "Discontinued Games"
            gamesTitle.TextColor3 = Color3.fromRGB(220, 100, 100)
        else
            toggleBtn.Text = "Show Discontinued (0)"
            gamesTitle.Text = "Supported Games"
            gamesTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
        end
        
        -- Filter games based on status
        for _, child in ipairs(gamesContainer:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("GameNameLabel") then
                -- Find the status frame
                local statusFrame = nil
                for _, obj in ipairs(child:GetChildren()) do
                    if obj:IsA("Frame") and obj:FindFirstChild("UICorner") and obj.Size == UDim2.new(0, 10, 0, 10) then
                        statusFrame = obj
                        break
                    end
                end
                
                if statusFrame then
                    local isDiscontinued = statusFrame.BackgroundColor3 == Color3.fromRGB(220, 100, 100)
                    child.Visible = showDiscontinued == isDiscontinued
                end
            end
        end
    end)
    
    -- Search Filter Functionality with character-level highlighting
    local gameNameCache = {}
    local highlightLabels = {}
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local searchText = searchBox.Text:lower()
        for _, child in ipairs(gamesContainer:GetChildren()) do
            if child:IsA("Frame") then
                local nameLabel = child:FindFirstChild("GameNameLabel")
                if nameLabel then
                    -- Store original name if not cached
                    if not gameNameCache[nameLabel] then
                        gameNameCache[nameLabel] = nameLabel.Text
                    end
                    
                    local gameName = gameNameCache[nameLabel]
                    local gameNameLower = gameName:lower()
                    local isVisible = searchText == "" or gameNameLower:find(searchText, 1, true) ~= nil
                    child.Visible = isVisible
                    
                    -- Remove old highlight label if exists
                    if highlightLabels[nameLabel] then
                        highlightLabels[nameLabel]:Destroy()
                        highlightLabels[nameLabel] = nil
                    end
                    
                    -- Create highlight overlay for matching characters
                    if searchText ~= "" and isVisible then
                        local startPos, endPos = gameNameLower:find(searchText, 1, true)
                        if startPos then
                            -- Create a label that shows only the highlighted portion
                            local highlightLabel = Instance.new("TextLabel")
                            highlightLabel.BackgroundTransparency = 1
                            highlightLabel.Size = nameLabel.Size
                            highlightLabel.Position = nameLabel.Position
                            highlightLabel.Font = nameLabel.Font
                            highlightLabel.TextSize = nameLabel.TextSize
                            highlightLabel.TextXAlignment = nameLabel.TextXAlignment
                            highlightLabel.ZIndex = nameLabel.ZIndex + 1
                            highlightLabel.Parent = nameLabel.Parent
                            
                            -- Build text with invisible prefix and highlighted match
                            local prefix = string.rep(" ", startPos - 1)
                            local matchText = gameName:sub(startPos, endPos)
                            highlightLabel.Text = prefix .. matchText
                            highlightLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                            
                            highlightLabels[nameLabel] = highlightLabel
                        end
                    end
                end
            end
        end
    end)

    -- Right Column (Key Input + Discord) - Adjust for mobile
    local rightColumn = Instance.new("Frame")
    if isMobile then
        rightColumn.Size = UDim2.new(1, 0, 0, 220)
        rightColumn.Position = UDim2.new(0, 0, 0, 230)
    else
        rightColumn.Size = UDim2.new(0, 290, 1, 0)
        rightColumn.Position = UDim2.new(1, -290, 0, 0)
    end
    rightColumn.BackgroundTransparency = 1
    rightColumn.Parent = content

    -- Card Shine Animation Function
    local function addCardShine(card)
        local shine = Instance.new("Frame")
        shine.Size = UDim2.new(0, 50, 1, 0)
        shine.Position = UDim2.new(-0.2, 0, 0, 0)
        shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        shine.BackgroundTransparency = 0.9
        shine.BorderSizePixel = 0
        shine.ZIndex = 10
        shine.Parent = card
        
        local shineGradient = Instance.new("UIGradient", shine)
        shineGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.5),
            NumberSequenceKeypoint.new(1, 1)
        })
        shineGradient.Rotation = 45
        
        -- Periodic shine animation
        task.spawn(function()
            while shine and shine.Parent do
                task.wait(math.random(8, 12))
                TweenService:Create(
                    shine,
                    TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {Position = UDim2.new(1.2, 0, 0, 0)}
                ):Play()
                task.wait(1.2)
                shine.Position = UDim2.new(-0.2, 0, 0, 0)
            end
        end)
    end

    -- Key Input Section
    local keySection = Instance.new("Frame")
    keySection.Size = UDim2.new(1, 0, 0, 200)
    keySection.Position = UDim2.new(0, 0, 0, 0)
    keySection.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    keySection.BorderSizePixel = 0
    keySection.Parent = rightColumn

    local keyCorner = Instance.new("UICorner", keySection)
    keyCorner.CornerRadius = UDim.new(0, 12)

    local keyStroke = Instance.new("UIStroke", keySection)
    keyStroke.Thickness = 1.5
    keyStroke.Color = Color3.fromRGB(70, 70, 70)
    keyStroke.Transparency = 0.6

    local keyPadding = Instance.new("UIPadding", keySection)
    keyPadding.PaddingTop = UDim.new(0, 15)
    keyPadding.PaddingLeft = UDim.new(0, 15)
    keyPadding.PaddingRight = UDim.new(0, 15)
    keyPadding.PaddingBottom = UDim.new(0, 15)
    
    -- Key section hover glow effect
    keySection.MouseEnter:Connect(function()
        TweenService:Create(keyStroke, TweenInfo.new(0.2), {
            Transparency = 0.2,
            Color = Color3.fromRGB(100, 100, 120)
        }):Play()
    end)
    keySection.MouseLeave:Connect(function()
        TweenService:Create(keyStroke, TweenInfo.new(0.2), {
            Transparency = 0.6,
            Color = Color3.fromRGB(70, 70, 70)
        }):Play()
    end)

    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(1, 0, 0, 18)
    keyLabel.Position = UDim2.new(0, 0, 0, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.TextXAlignment = Enum.TextXAlignment.Left
    keyLabel.Text = EnterKeyLabelText
    keyLabel.TextSize = 13
    keyLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
    keyLabel.Parent = keySection
    
    -- Quick Guide (compact)
    local guideFrame = Instance.new("Frame")
    guideFrame.Size = UDim2.new(1, 0, 0, 60)
    guideFrame.Position = UDim2.new(0, 0, 0, 126)
    guideFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    guideFrame.BackgroundTransparency = 0.5
    guideFrame.BorderSizePixel = 0
    guideFrame.Parent = keySection
    
    local guideCorner = Instance.new("UICorner", guideFrame)
    guideCorner.CornerRadius = UDim.new(0, 8)
    
    local guidePadding = Instance.new("UIPadding", guideFrame)
    guidePadding.PaddingTop = UDim.new(0, 6)
    guidePadding.PaddingLeft = UDim.new(0, 8)
    guidePadding.PaddingRight = UDim.new(0, 8)
    guidePadding.PaddingBottom = UDim.new(0, 6)
    
    local guideTitle = Instance.new("TextLabel")
    guideTitle.Size = UDim2.new(1, 0, 0, 12)
    guideTitle.BackgroundTransparency = 1
    guideTitle.Font = Enum.Font.GothamBold
    guideTitle.Text = "📖 Quick Guide"
    guideTitle.TextSize = 14
    guideTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    guideTitle.TextXAlignment = Enum.TextXAlignment.Left
    guideTitle.Parent = guideFrame
    
    local steps = {
        "1️⃣ Click Get Key",
        "2️⃣ Complete checkpoint",
        "3️⃣ Copy the key",
        "4️⃣ Paste & auto-verify"
    }
    
    for i, step in ipairs(steps) do
        local stepLabel = Instance.new("TextLabel")
        stepLabel.Size = UDim2.new(0.5, -4, 0, 11)
        stepLabel.Position = UDim2.new((i - 1) % 2 * 0.5, (i - 1) % 2 * 2, 0, 15 + math.floor((i - 1) / 2) * 13)
        stepLabel.BackgroundTransparency = 1
        stepLabel.Font = Enum.Font.Gotham
        stepLabel.Text = step
        stepLabel.TextSize = 11
        stepLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
        stepLabel.TextXAlignment = Enum.TextXAlignment.Left
        stepLabel.Parent = guideFrame
    end

    -- Key History Button with count badge
    local historyBtn = Instance.new("TextButton")
    historyBtn.Size = UDim2.new(0, 70, 0, 18)
    historyBtn.Position = UDim2.new(1, -150, 0, 0)
    historyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    historyBtn.BorderSizePixel = 0
    historyBtn.Font = Enum.Font.GothamSemibold
    historyBtn.Text = "📋 History"
    historyBtn.TextSize = 10
    historyBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    historyBtn.Parent = keySection
    
    local historyCorner = Instance.new("UICorner", historyBtn)
    historyCorner.CornerRadius = UDim.new(0, 6)
    
    -- History count badge
    local historyBadge = Instance.new("TextLabel")
    historyBadge.Size = UDim2.new(0, 16, 0, 16)
    historyBadge.Position = UDim2.new(1, -4, 0, -4)
    historyBadge.AnchorPoint = Vector2.new(1, 0)
    historyBadge.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    historyBadge.BorderSizePixel = 0
    historyBadge.Font = Enum.Font.GothamBold
    historyBadge.Text = tostring(#getHistory())
    historyBadge.TextSize = 9
    historyBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
    historyBadge.Visible = #getHistory() > 0
    historyBadge.ZIndex = 10
    historyBadge.Parent = historyBtn
    
    local badgeCorner = Instance.new("UICorner", historyBadge)
    badgeCorner.CornerRadius = UDim.new(1, 0)
    
    -- Backup File Button
    local backupBtn = Instance.new("TextButton")
    backupBtn.Size = UDim2.new(0, 70, 0, 18)
    backupBtn.Position = UDim2.new(1, -75, 0, 0)
    backupBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
    backupBtn.BorderSizePixel = 0
    backupBtn.Font = Enum.Font.GothamSemibold
    backupBtn.Text = "📄 Backup"
    backupBtn.TextSize = 10
    backupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backupBtn.Parent = keySection
    
    local backupCorner = Instance.new("UICorner", backupBtn)
    backupCorner.CornerRadius = UDim.new(0, 6)
    
    backupBtn.MouseButton1Click:Connect(function()
        -- Show notification about backup file location
        local notifText = "Backup saved to:\n" .. backupPath
        
        -- Create a custom notification for the file path
        local pathNotif = Instance.new("Frame")
        pathNotif.Name = "BackupNotif"
        pathNotif.AnchorPoint = Vector2.new(0.5, 0.5)
        pathNotif.Size = UDim2.new(0, 350, 0, 120)
        pathNotif.Position = UDim2.new(0.5, 0, 0.5, 0)
        pathNotif.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        pathNotif.BorderSizePixel = 0
        pathNotif.ZIndex = 100
        pathNotif.Parent = gui
        
        local pathCorner = Instance.new("UICorner", pathNotif)
        pathCorner.CornerRadius = UDim.new(0, 10)
        
        local pathTitle = Instance.new("TextLabel")
        pathTitle.Size = UDim2.new(1, -20, 0, 25)
        pathTitle.Position = UDim2.new(0, 10, 0, 10)
        pathTitle.BackgroundTransparency = 1
        pathTitle.Font = Enum.Font.GothamBold
        pathTitle.Text = "📄 Key Backup File"
        pathTitle.TextSize = 14
        pathTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
        pathTitle.TextXAlignment = Enum.TextXAlignment.Left
        pathTitle.Parent = pathNotif
        
        local pathLabel = Instance.new("TextLabel")
        pathLabel.Size = UDim2.new(1, -20, 0, 50)
        pathLabel.Position = UDim2.new(0, 10, 0, 40)
        pathLabel.BackgroundTransparency = 1
        pathLabel.Font = Enum.Font.Gotham
        pathLabel.Text = "All your valid keys are saved in:\n" .. backupPath
        pathLabel.TextSize = 10
        pathLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        pathLabel.TextWrapped = true
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left
        pathLabel.TextYAlignment = Enum.TextYAlignment.Top
        pathLabel.Parent = pathNotif
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 100, 0, 30)
        closeBtn.Position = UDim2.new(0.5, -50, 1, -40)
        closeBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
        closeBtn.BorderSizePixel = 0
        closeBtn.Font = Enum.Font.GothamSemibold
        closeBtn.Text = "OK"
        closeBtn.TextSize = 12
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Parent = pathNotif
        
        local closeBtnCorner = Instance.new("UICorner", closeBtn)
        closeBtnCorner.CornerRadius = UDim.new(0, 6)
        
        closeBtn.MouseButton1Click:Connect(function()
            pathNotif:Destroy()
        end)
        
        task.delay(5, function()
            if pathNotif and pathNotif.Parent then
                pathNotif:Destroy()
            end
        end)
    end)
    
    backupBtn.MouseEnter:Connect(function()
        TweenService:Create(backupBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 140, 220)}):Play()
    end)
    backupBtn.MouseLeave:Connect(function()
        TweenService:Create(backupBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 120, 200)}):Play()
    end)
    
    -- History Dropdown
    local historyDropdown = Instance.new("ScrollingFrame")
    historyDropdown.Size = UDim2.new(0, 0, 0, 0)
    historyDropdown.Position = UDim2.new(1, -285, 0, 22)
    historyDropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    historyDropdown.BorderSizePixel = 0
    historyDropdown.ScrollBarThickness = 4
    historyDropdown.Visible = false
    historyDropdown.ClipsDescendants = true
    historyDropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
    historyDropdown.AutomaticCanvasSize = Enum.AutomaticSize.Y
    historyDropdown.ZIndex = 50
    historyDropdown.Parent = keySection
    
    local historyDropCorner = Instance.new("UICorner", historyDropdown)
    historyDropCorner.CornerRadius = UDim.new(0, 6)
    
    local historyLayout = Instance.new("UIListLayout", historyDropdown)
    historyLayout.Padding = UDim.new(0, 4)
    
    local function updateHistoryDropdown()
        for _, child in ipairs(historyDropdown:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        local history = getHistory()
        -- Limit to 5 most recent entries
        local maxEntries = math.min(#history, 5)
        
        for i = 1, maxEntries do
            local entry = history[i]
            -- Container for each history item
            local historyContainer = Instance.new("Frame")
            historyContainer.Size = UDim2.new(1, -8, 0, 28)
            historyContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            historyContainer.BorderSizePixel = 0
            historyContainer.Parent = historyDropdown
            
            local containerCorner = Instance.new("UICorner", historyContainer)
            containerCorner.CornerRadius = UDim.new(0, 6)
            
            -- Key text label
            local keyLabel = Instance.new("TextLabel")
            keyLabel.Size = UDim2.new(1, -35, 1, 0)
            keyLabel.Position = UDim2.new(0, 8, 0, 0)
            keyLabel.BackgroundTransparency = 1
            keyLabel.Font = Enum.Font.Gotham
            keyLabel.Text = entry.key
            keyLabel.TextSize = 9
            keyLabel.TextColor3 = entry.success and Color3.fromRGB(100, 220, 140) or Color3.fromRGB(220, 100, 100)
            keyLabel.TextXAlignment = Enum.TextXAlignment.Left
            keyLabel.TextTruncate = Enum.TextTruncate.AtEnd
            keyLabel.Parent = historyContainer
            
            -- Status icon
            local statusIcon = Instance.new("TextLabel")
            statusIcon.Size = UDim2.new(0, 20, 0, 20)
            statusIcon.Position = UDim2.new(1, -25, 0.5, -10)
            statusIcon.BackgroundTransparency = 1
            statusIcon.Font = Enum.Font.GothamBold
            statusIcon.Text = entry.success and "✓" or "X"
            statusIcon.TextSize = 14
            statusIcon.TextColor3 = entry.success and Color3.fromRGB(100, 220, 140) or Color3.fromRGB(220, 100, 100)
            statusIcon.Parent = historyContainer
            
            -- Make container clickable to fill input
            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = historyContainer
            
            clickBtn.MouseButton1Click:Connect(function()
                keyBox.Text = entry.key
                historyDropdown.Visible = false
            end)
            
            historyContainer.MouseEnter:Connect(function()
                TweenService:Create(historyContainer, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
            end)
            historyContainer.MouseLeave:Connect(function()
                TweenService:Create(historyContainer, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
            end)
        end
    end
    
    historyBtn.MouseButton1Click:Connect(function()
        historyDropdown.Visible = not historyDropdown.Visible
        if historyDropdown.Visible then
            updateHistoryDropdown()
            local historyCount = math.min(#getHistory(), 5)
            historyBadge.Text = tostring(historyCount)
            historyBadge.Visible = historyCount > 0
            TweenService:Create(historyDropdown, TweenInfo.new(0.2), {Size = UDim2.new(0, 280, 0, math.min(historyCount * 32, 160))}):Play()
        else
            TweenService:Create(historyDropdown, TweenInfo.new(0.2), {Size = UDim2.new(0, 280, 0, 0)}):Play()
        end
    end)

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(1, 0, 0, 40)
    keyBox.Position = UDim2.new(0, 0, 0, 28)
    keyBox.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    keyBox.BorderSizePixel = 0
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextXAlignment = Enum.TextXAlignment.Left
    keyBox.PlaceholderText = KeyPlaceholderText
    keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    keyBox.Text = ""
    keyBox.TextSize = 11
    keyBox.TextColor3 = Color3.fromRGB(240, 240, 250)
    keyBox.TextTruncate = Enum.TextTruncate.AtEnd
    keyBox.ClearTextOnFocus = false
    keyBox.ClipsDescendants = true
    keyBox.Parent = keySection

    local boxCorner = Instance.new("UICorner", keyBox)
    boxCorner.CornerRadius = UDim.new(0, 8)

    local boxStroke = Instance.new("UIStroke", keyBox)
    boxStroke.Thickness = 1.5
    boxStroke.Color = Color3.fromRGB(60, 60, 75)
    boxStroke.Transparency = 0.5

    local boxPadding = Instance.new("UIPadding", keyBox)
    boxPadding.PaddingLeft = UDim.new(0, 12)
    boxPadding.PaddingRight = UDim.new(0, 12)
    
    -- Character Counter - positioned below the input box
    local charCounter = Instance.new("TextLabel")
    charCounter.Size = UDim2.new(1, 0, 0, 12)
    charCounter.Position = UDim2.new(0, 0, 0, 70)
    charCounter.BackgroundTransparency = 1
    charCounter.Font = Enum.Font.Gotham
    charCounter.Text = "0 chars"
    charCounter.TextSize = 9
    charCounter.TextColor3 = Color3.fromRGB(120, 120, 140)
    charCounter.TextXAlignment = Enum.TextXAlignment.Left
    charCounter.Parent = keySection
    
    -- Update character counter
    keyBox:GetPropertyChangedSignal("Text"):Connect(function()
        charCounter.Text = #keyBox.Text .. " chars"
        if #keyBox.Text > 30 then
            charCounter.TextColor3 = Color3.fromRGB(100, 220, 140)
        elseif #keyBox.Text > 15 then
            charCounter.TextColor3 = Color3.fromRGB(255, 200, 50)
        else
            charCounter.TextColor3 = Color3.fromRGB(120, 120, 140)
        end
    end)
    
    -- Key strength indicator
    local strengthIndicator = Instance.new("Frame")
    strengthIndicator.Size = UDim2.new(0, 4, 0, 32)
    strengthIndicator.Position = UDim2.new(0, 2, 0, 32)
    strengthIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    strengthIndicator.BackgroundTransparency = 0.7
    strengthIndicator.BorderSizePixel = 0
    strengthIndicator.ZIndex = 10
    strengthIndicator.Parent = keySection
    
    local strengthCorner = Instance.new("UICorner", strengthIndicator)
    strengthCorner.CornerRadius = UDim.new(1, 0)
    
    -- Auto-paste detection and key validation
    local lastText = ""
    keyBox:GetPropertyChangedSignal("Text"):Connect(function()
        local currentText = keyBox.Text
        
        -- Update strength indicator based on key format
        if currentText == "" then
            TweenService:Create(strengthIndicator, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(100, 100, 120),
                BackgroundTransparency = 0.7
            }):Play()
        elseif #currentText < 10 then
            TweenService:Create(strengthIndicator, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(220, 60, 60),
                BackgroundTransparency = 0.3
            }):Play()
        elseif #currentText < 20 then
            TweenService:Create(strengthIndicator, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(255, 200, 50),
                BackgroundTransparency = 0.3
            }):Play()
        else
            TweenService:Create(strengthIndicator, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 200, 120),
                BackgroundTransparency = 0.3
            }):Play()
        end
        
        lastText = currentText
    end)

    -- Progress Bar for key verification
    local progressContainer = Instance.new("Frame")
    progressContainer.Size = UDim2.new(1, 0, 0, 4)
    progressContainer.Position = UDim2.new(0, 0, 0, 84)
    progressContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressContainer.BorderSizePixel = 0
    progressContainer.Visible = false
    progressContainer.Parent = keySection
    
    local progressCorner = Instance.new("UICorner", progressContainer)
    progressCorner.CornerRadius = UDim.new(1, 0)
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressContainer
    
    local progressBarCorner = Instance.new("UICorner", progressBar)
    progressBarCorner.CornerRadius = UDim.new(1, 0)

    -- Button Container
    local buttonContainer = Instance.new("Frame")
    if isMobile then
        buttonContainer.Size = UDim2.new(1, 0, 0, 32)
        buttonContainer.Position = UDim2.new(0, 0, 0, 90)
    else
        buttonContainer.Size = UDim2.new(1, 0, 0, 28)
        buttonContainer.Position = UDim2.new(0, 0, 0, 90)
    end
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = keySection

    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(0.48, -4, 1, 0)
    verifyBtn.Position = UDim2.new(0, 0, 0, 0)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    verifyBtn.BorderSizePixel = 0
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.Text = "✓ Verify Key"
    verifyBtn.TextSize = 11
    verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyBtn.Parent = buttonContainer

    local verifyCorner = Instance.new("UICorner", verifyBtn)
    verifyCorner.CornerRadius = UDim.new(0, 10)
    
    local verifyStroke = Instance.new("UIStroke", verifyBtn)
    verifyStroke.Thickness = 1.5
    verifyStroke.Color = Color3.fromRGB(120, 130, 255)
    verifyStroke.Transparency = 0.5

    local getKey = Instance.new("TextButton")
    getKey.Size = UDim2.new(0.48, -4, 1, 0)
    getKey.Position = UDim2.new(0.52, 0, 0, 0)
    getKey.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    getKey.BorderSizePixel = 0
    getKey.Font = Enum.Font.GothamSemibold
    getKey.Text = "🔑 " .. GetKeyButtonText
    getKey.TextSize = 11
    getKey.TextColor3 = Color3.fromRGB(220, 220, 230)
    getKey.Parent = buttonContainer

    local getKeyCorner = Instance.new("UICorner", getKey)
    getKeyCorner.CornerRadius = UDim.new(0, 10)
    
    local getKeyStroke = Instance.new("UIStroke", getKey)
    getKeyStroke.Thickness = 1.5
    getKeyStroke.Color = Color3.fromRGB(70, 70, 85)
    getKeyStroke.Transparency = 0.5

    -- Discord Card
    local discordCard = Instance.new("Frame")
    discordCard.Size = UDim2.new(1, 0, 1, -160)
    discordCard.Position = UDim2.new(0, 0, 0, 210)
    discordCard.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    discordCard.BorderSizePixel = 0
    discordCard.Parent = rightColumn

    local discordCorner = Instance.new("UICorner", discordCard)
    discordCorner.CornerRadius = UDim.new(0, 12)

    local discordStroke = Instance.new("UIStroke", discordCard)
    discordStroke.Thickness = 1.5
    discordStroke.Color = Color3.fromRGB(70, 70, 70)
    discordStroke.Transparency = 0.6

    local discordPadding = Instance.new("UIPadding", discordCard)
    discordPadding.PaddingTop = UDim.new(0, 12)
    discordPadding.PaddingLeft = UDim.new(0, 12)
    discordPadding.PaddingRight = UDim.new(0, 12)
    discordPadding.PaddingBottom = UDim.new(0, 12)
    
    -- Discord card hover glow effect
    discordCard.MouseEnter:Connect(function()
        TweenService:Create(discordStroke, TweenInfo.new(0.2), {
            Transparency = 0.2,
            Color = Color3.fromRGB(100, 100, 120)
        }):Play()
    end)
    discordCard.MouseLeave:Connect(function()
        TweenService:Create(discordStroke, TweenInfo.new(0.2), {
            Transparency = 0.6,
            Color = Color3.fromRGB(70, 70, 70)
        }):Play()
    end)

    local discordTitle = Instance.new("TextLabel")
    discordTitle.Size = UDim2.new(1, 0, 0, 18)
    discordTitle.BackgroundTransparency = 1
    discordTitle.Font = Enum.Font.GothamBold
    discordTitle.TextXAlignment = Enum.TextXAlignment.Left
    discordTitle.Text = DiscordCardTitle
    discordTitle.TextSize = 13
    discordTitle.TextColor3 = Color3.fromRGB(240, 240, 250)
    discordTitle.Parent = discordCard

    local discordDesc = Instance.new("TextLabel")
    discordDesc.Size = UDim2.new(1, 0, 0, 50)
    discordDesc.Position = UDim2.new(0, 0, 0, 24)
    discordDesc.BackgroundTransparency = 1
    discordDesc.Font = Enum.Font.Gotham
    discordDesc.TextWrapped = true
    discordDesc.TextXAlignment = Enum.TextXAlignment.Left
    discordDesc.TextYAlignment = Enum.TextYAlignment.Top
    discordDesc.TextSize = 11
    discordDesc.TextColor3 = Color3.fromRGB(160, 160, 180)
    discordDesc.Text = DiscordCardText
    discordDesc.Parent = discordCard

    local joinButton = Instance.new("TextButton")
    joinButton.Size = UDim2.new(1, 0, 0, 38)
    joinButton.Position = UDim2.new(0, 0, 1, -38)
    joinButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    joinButton.BorderSizePixel = 0
    joinButton.Font = Enum.Font.GothamBold
    joinButton.Text = "💬 " .. DiscordButtonText
    joinButton.TextSize = 13
    joinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    joinButton.Parent = discordCard

    local joinCorner = Instance.new("UICorner", joinButton)
    joinCorner.CornerRadius = UDim.new(0, 10)
    
    local joinStroke = Instance.new("UIStroke", joinButton)
    joinStroke.Thickness = 1.5
    joinStroke.Color = Color3.fromRGB(100, 100, 100)
    joinStroke.Transparency = 0.5

    local function _d(s) local r="" for i=1,#s do r=r..string.char(string.byte(s,i)-3) end return r end
    local _wm=_d("Pdgh#e|#Vhlvhq#Kxe")
    local _cn=string.char(67,114,101,100,105,116,76,97,98,101,108)
    local creditLabel = Instance.new("TextLabel")
    creditLabel.Name = _cn
    creditLabel.Size = UDim2.new(1, 0, 0, 15)
    creditLabel.Position = UDim2.new(0, 0, 1, -15)
    creditLabel.BackgroundTransparency = 1
    creditLabel.Font = Enum.Font.Gotham
    creditLabel.Text = _wm
    creditLabel.TextSize = 9
    creditLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
    creditLabel.TextTransparency = 0.5
    creditLabel.ZIndex = 5
    creditLabel.Parent = mainFrame
    local _vActive = true
    task.spawn(function()
        while _vActive and mainFrame and mainFrame.Parent do
            task.wait(1.5)
            local _c = mainFrame:FindFirstChild(_cn)
            if not _c or not _c.Parent then
                _vActive = false
                if gui then 
                    gui:Destroy() 
                end
                if getgenv then 
                    pcall(function() getgenv().YourHubKeySys = false end) 
                end
                break
            end
        end
    end)

    -- Entrance Animation
    TweenService:Create(
        mainFrame,
        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, 0, 0.5, 0)}
    ):Play()

    -- Enhanced Hover Effects with glow
    local function addHoverEffect(button, hoverColor, normalColor, hasStroke)
        local originalSize = button.Size
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
            if hasStroke then
                local stroke = button:FindFirstChildOfClass("UIStroke")
                if stroke then
                    TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
                end
            end
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
            if hasStroke then
                local stroke = button:FindFirstChildOfClass("UIStroke")
                if stroke then
                    TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
                end
            end
        end)
    end

    addHoverEffect(verifyBtn, Color3.fromRGB(98, 111, 252), Color3.fromRGB(88, 101, 242), true)
    addHoverEffect(getKey, Color3.fromRGB(45, 45, 55), Color3.fromRGB(35, 35, 45), true)
    addHoverEffect(joinButton, Color3.fromRGB(70, 70, 70), Color3.fromRGB(60, 60, 60), true)
    
    -- Add tooltips to buttons
    local function addTooltip(button, text)
        local tooltip = Instance.new("TextLabel")
        tooltip.Size = UDim2.new(0, #text * 6 + 16, 0, 20)
        tooltip.Position = UDim2.new(0.5, -(#text * 6 + 16) / 2, 1, 5)
        tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        tooltip.BorderSizePixel = 0
        tooltip.Font = Enum.Font.Gotham
        tooltip.Text = text
        tooltip.TextSize = 9
        tooltip.TextColor3 = Color3.fromRGB(220, 220, 230)
        tooltip.Visible = false
        tooltip.ZIndex = 20
        tooltip.Parent = button
        
        local tooltipCorner = Instance.new("UICorner", tooltip)
        tooltipCorner.CornerRadius = UDim.new(0, 4)
        
        button.MouseEnter:Connect(function()
            tooltip.Visible = true
        end)
        button.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)
    end
    
    addTooltip(verifyBtn, "Verify your key (Enter)")
    addTooltip(getKey, "Get a new key")
    addTooltip(joinButton, "Join Discord server")

    -- Input Focus Effect
    keyBox.Focused:Connect(function()
        TweenService:Create(boxStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(120, 120, 120), Transparency = 0}):Play()
    end)
    keyBox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(boxStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 75), Transparency = 0.5}):Play()
        if enterPressed then
            handleKeySubmit()
        end
    end)
    
    -- Clear button for key input
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 24, 0, 24)
    clearBtn.Position = UDim2.new(1, -30, 0, 36)
    clearBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    clearBtn.BorderSizePixel = 0
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.Text = "X"
    clearBtn.TextSize = 14
    clearBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    clearBtn.ZIndex = 10
    clearBtn.Parent = keySection
    
    local clearCorner = Instance.new("UICorner", clearBtn)
    clearCorner.CornerRadius = UDim.new(0, 6)
    
    -- Tooltip for clear button
    local clearTooltip = Instance.new("TextLabel")
    clearTooltip.Size = UDim2.new(0, 60, 0, 20)
    clearTooltip.Position = UDim2.new(0.5, -30, 1, 5)
    clearTooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    clearTooltip.BorderSizePixel = 0
    clearTooltip.Font = Enum.Font.Gotham
    clearTooltip.Text = "Clear (Esc)"
    clearTooltip.TextSize = 9
    clearTooltip.TextColor3 = Color3.fromRGB(220, 220, 230)
    clearTooltip.Visible = false
    clearTooltip.ZIndex = 11
    clearTooltip.Parent = clearBtn
    
    local tooltipCorner = Instance.new("UICorner", clearTooltip)
    tooltipCorner.CornerRadius = UDim.new(0, 4)
    
    clearBtn.MouseButton1Click:Connect(function()
        keyBox.Text = ""
        keyBox:CaptureFocus()
    end)
    
    clearBtn.MouseEnter:Connect(function()
        clearTooltip.Visible = true
        TweenService:Create(clearBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
    end)
    clearBtn.MouseLeave:Connect(function()
        clearTooltip.Visible = false
        TweenService:Create(clearBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    
    -- Keyboard shortcuts help button
    local helpBtn = Instance.new("TextButton")
    helpBtn.BackgroundTransparency = 1
    helpBtn.Size = UDim2.new(0, 30, 0, 30)
    helpBtn.Position = UDim2.new(1, -105, 0.5, -15)
    helpBtn.Font = Enum.Font.GothamBold
    helpBtn.Text = "?"
    helpBtn.TextSize = 18
    helpBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    helpBtn.Parent = topbar
    
    local helpCorner = Instance.new("UICorner", helpBtn)
    helpCorner.CornerRadius = UDim.new(1, 0)
    
    -- Keyboard shortcuts panel
    local shortcutsPanel = Instance.new("Frame")
    shortcutsPanel.Size = UDim2.new(0, 200, 0, 0)
    shortcutsPanel.Position = UDim2.new(1, -205, 0, 45)
    shortcutsPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    shortcutsPanel.BorderSizePixel = 0
    shortcutsPanel.Visible = false
    shortcutsPanel.ClipsDescendants = true
    shortcutsPanel.ZIndex = 15
    shortcutsPanel.Parent = mainFrame
    
    local shortcutsCorner = Instance.new("UICorner", shortcutsPanel)
    shortcutsCorner.CornerRadius = UDim.new(0, 8)
    
    local shortcutsStroke = Instance.new("UIStroke", shortcutsPanel)
    shortcutsStroke.Thickness = 1
    shortcutsStroke.Color = Color3.fromRGB(80, 80, 95)
    shortcutsStroke.Transparency = 0.5
    
    local shortcutsTitle = Instance.new("TextLabel")
    shortcutsTitle.Size = UDim2.new(1, -16, 0, 20)
    shortcutsTitle.Position = UDim2.new(0, 8, 0, 8)
    shortcutsTitle.BackgroundTransparency = 1
    shortcutsTitle.Font = Enum.Font.GothamBold
    shortcutsTitle.Text = "⌨️ Keyboard Shortcuts"
    shortcutsTitle.TextSize = 10
    shortcutsTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
    shortcutsTitle.TextXAlignment = Enum.TextXAlignment.Left
    shortcutsTitle.ZIndex = 16
    shortcutsTitle.Parent = shortcutsPanel
    
    local shortcuts = {
        {"Enter", "Verify key"},
        {"Ctrl+V", "Paste key"},
        {"Esc", "Clear input"},
        {"Ctrl+C", "Copy Discord link"}
    }
    
    for i, shortcut in ipairs(shortcuts) do
        local shortcutItem = Instance.new("Frame")
        shortcutItem.Size = UDim2.new(1, -16, 0, 18)
        shortcutItem.Position = UDim2.new(0, 8, 0, 28 + (i - 1) * 20)
        shortcutItem.BackgroundTransparency = 1
        shortcutItem.ZIndex = 16
        shortcutItem.Parent = shortcutsPanel
        
        local key = Instance.new("TextLabel")
        key.Size = UDim2.new(0, 60, 1, 0)
        key.BackgroundTransparency = 1
        key.Font = Enum.Font.GothamBold
        key.Text = shortcut[1]
        key.TextSize = 9
        key.TextColor3 = Color3.fromRGB(150, 150, 170)
        key.TextXAlignment = Enum.TextXAlignment.Left
        key.ZIndex = 16
        key.Parent = shortcutItem
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -65, 1, 0)
        desc.Position = UDim2.new(0, 65, 0, 0)
        desc.BackgroundTransparency = 1
        desc.Font = Enum.Font.Gotham
        desc.Text = shortcut[2]
        desc.TextSize = 9
        desc.TextColor3 = Color3.fromRGB(180, 180, 200)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.ZIndex = 16
        desc.Parent = shortcutItem
    end
    
    helpBtn.MouseButton1Click:Connect(function()
        shortcutsPanel.Visible = not shortcutsPanel.Visible
        if shortcutsPanel.Visible then
            TweenService:Create(shortcutsPanel, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 110)}):Play()
        else
            TweenService:Create(shortcutsPanel, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 0)}):Play()
        end
    end)
    
    helpBtn.MouseEnter:Connect(function()
        TweenService:Create(helpBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
    end)
    helpBtn.MouseLeave:Connect(function()
        TweenService:Create(helpBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    
    -- Keyboard shortcuts implementation
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Escape then
            keyBox.Text = ""
        elseif input.KeyCode == Enum.KeyCode.C and input.UserInputState == Enum.UserInputState.Begin then
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) or game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.RightControl) then
                if setclipboard then
                    setclipboard(DISCORD_INVITE)
                    ShowNotification("discord")
                end
            end
        end
    end)

    -- Enhanced Update Status Function with icons and smooth transitions
    local function updateStatus(status, color)
        local icon = ""
        if status == "Valid!" then
            icon = ""
        elseif status == "Invalid" then
            icon = ""
        elseif status == "Checking..." then
            icon = ""
        end
        
        -- Smooth fade transition
        TweenService:Create(statusLabel, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
        TweenService:Create(statusDot, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        
        task.wait(0.15)
        
        statusLabel.Text = icon .. " " .. status
        
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0, TextColor3 = color}):Play()
        TweenService:Create(statusDot, TweenInfo.new(0.3), {BackgroundTransparency = 0, BackgroundColor3 = color}):Play()
        TweenService:Create(statusStroke, TweenInfo.new(0.3), {Color = color}):Play()
    end

    local isMinimized = false
    minimize.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        if isMinimized then
            -- Minimize to corner
            local targetSize = UDim2.new(0, 60, 0, 60)
            local targetPos = UDim2.new(1, -70, 1, -70)
            
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = targetSize,
                Position = targetPos
            }):Play()
            
            -- Hide all content except topbar
            content.Visible = false
            headerTitle.Visible = false
            statusFrame.Visible = false
            topbar.Visible = false  -- Hide topbar too
            
            -- Change minimize icon
            minimize.Text = "+"
            
            -- Show mini icon (image instead of text)
            local miniIcon = Instance.new("ImageLabel")
            miniIcon.Name = "MiniIcon"
            miniIcon.Size = UDim2.new(0, 50, 0, 50)
            miniIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
            miniIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            miniIcon.BackgroundTransparency = 1
            miniIcon.Image = "rbxassetid://125926861378074"
            miniIcon.ScaleType = Enum.ScaleType.Fit
            miniIcon.Parent = mainFrame
            
            -- Make the icon clickable to restore
            local miniButton = Instance.new("TextButton")
            miniButton.Name = "MiniButton"
            miniButton.Size = UDim2.new(1, 0, 1, 0)
            miniButton.BackgroundTransparency = 1
            miniButton.Text = ""
            miniButton.Parent = miniIcon
            
            miniButton.MouseButton1Click:Connect(function()
                minimize.Text = "–"
                isMinimized = false
                
                TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = fullSize,
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }):Play()
                
                task.wait(0.15)
                content.Visible = true
                headerTitle.Visible = true
                statusFrame.Visible = true
                topbar.Visible = true  -- Show topbar again
                
                miniIcon:Destroy()
            end)
        else
            -- Restore from minimized
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = fullSize,
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            
            -- Show all content
            task.wait(0.15)
            content.Visible = true
            headerTitle.Visible = true
            statusFrame.Visible = true
            topbar.Visible = true  -- Show topbar
            
            -- Change minimize icon back
            minimize.Text = "–"
            
            -- Remove mini icon
            local miniIcon = mainFrame:FindFirstChild("MiniIcon")
            if miniIcon then
                miniIcon:Destroy()
            end
        end
    end)

    local function closeUI()
        local closeTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, 0, 1.5, 0)}
        )
        closeTween:Play()
        closeTween.Completed:Connect(function()
            if getgenv then pcall(function() getgenv().YourHubKeySys = false end) end
            gui:Destroy()
        end)
    end

    close.MouseButton1Click:Connect(closeUI)
    
    -- Inline Notification System
    local function showInlineNotification(button, message, color)
        -- Remove existing notification if any
        local existingNotif = button.Parent:FindFirstChild("InlineNotif")
        if existingNotif then
            existingNotif:Destroy()
        end

        -- Create notification label
        local notif = Instance.new("TextLabel")
        notif.Name = "InlineNotif"
        notif.Size = UDim2.new(1, 0, 0, 22)
        notif.Position = UDim2.new(0, 0, 1, 5)
        notif.BackgroundColor3 = color
        notif.BackgroundTransparency = 1
        notif.BorderSizePixel = 0
        notif.Font = Enum.Font.GothamBold
        notif.Text = message
        notif.TextSize = 10
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        notif.TextTransparency = 1
        notif.ZIndex = 20
        notif.Parent = button.Parent
        
        local notifCorner = Instance.new("UICorner", notif)
        notifCorner.CornerRadius = UDim.new(0, 6)
        
        -- Animate in
        TweenService:Create(notif, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.15,
            TextTransparency = 0
        }):Play()
        
        -- Auto-dismiss after 3 seconds
        task.delay(3, function()
            if notif and notif.Parent then
                TweenService:Create(notif, TweenInfo.new(0.3), {
                    BackgroundTransparency = 1,
                    TextTransparency = 1
                }):Play()
                task.wait(0.3)
                if notif and notif.Parent then
                    notif:Destroy()
                end
            end
        end)
    end

    joinButton.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(DISCORD_INVITE)
            showInlineNotification(joinButton, "✓ Discord link copied!", Color3.fromRGB(80, 200, 120))
        else
            showInlineNotification(joinButton, "✗ Clipboard not available", Color3.fromRGB(220, 60, 60))
        end
    end)

    getKey.MouseButton1Click:Connect(function()
        local ok, res = pcall(function()
			return JunkieProtected.GetKeyLink()
        end)

        if ok and res then
            if setclipboard then
                setclipboard(res)
                showInlineNotification(getKey, "✓ Key link copied!", Color3.fromRGB(80, 200, 120))
            else
                showInlineNotification(getKey, "✗ Clipboard not available", Color3.fromRGB(220, 60, 60))
            end
        else
            showInlineNotification(getKey, "✗ Failed to generate key", Color3.fromRGB(220, 60, 60))
        end
    end)

    local function handleKeySubmit()
        local userKey = (keyBox.Text or "")
        userKey = userKey:gsub("%s+", "")
        if userKey == "" then
            updateStatus("Invalid", Color3.fromRGB(220, 60, 60))
            return
        end

        -- Show and animate progress bar
        progressContainer.Visible = true
        progressBar.Size = UDim2.new(0, 0, 1, 0)
        progressBar.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        
        updateStatus("Checking...", Color3.fromRGB(255, 200, 50))
        
        -- Animate progress bar
        local progressTween = TweenService:Create(
            progressBar,
            TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 1, 0)}
        )
        progressTween:Play()
        
        task.wait(0.5)

        task.wait(0.3)

        if validateKey(userKey) then
            local keys = readKeys()
            local exists = false
            for _, k in ipairs(keys) do
                if k == userKey then
                    exists = true
                    break
                end
            end
            if not exists then
                table.insert(keys, userKey)
                saveKeys(keys)
            end

            updateStatus("Valid!", Color3.fromRGB(80, 200, 120))
            
            -- Progress bar success color
            TweenService:Create(progressBar, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 200, 120)}):Play()
            
            -- Send webhook for valid key
            local keyValidCount = getKeyValidCount(userKey)
            local currentTime = os.date("%Y-%m-%d %H:%M:%S")
            
            sendWebhook({
                title = "🔑 New Valid Key",
                color = 3066993, -- Green
                key = userKey,
                keyValidCount = keyValidCount,
                keyTime = currentTime,
                service = SERVICE_ID,
                provider = PROVIDER
            })
            
            -- Update stats
            local stats = parseStats()
            stats.totalKeys = stats.totalKeys + 1
            stats.successfulKeys = stats.successfulKeys + 1
            stats.lastVerified = os.date("%Y-%m-%d %H:%M")
            saveStats(stats)
            addToHistory(userKey, true)
            
            -- Update statistics display
            local successRate = stats.totalKeys > 0 and math.floor((stats.successfulKeys / stats.totalKeys) * 100) or 0
            statsText.Text = string.format("Keys: %d | Success: %d%% | Last: %s", stats.totalKeys, successRate, stats.lastVerified)
            
            -- Update history badge
            local historyCount = #getHistory()
            historyBadge.Text = tostring(historyCount)
            historyBadge.Visible = historyCount > 0

            task.wait(0.5)
            
            -- Hide progress bar
            progressContainer.Visible = false

            local tw = TweenService:Create(
                mainFrame,
                TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                {Position = UDim2.new(0.5, 0, 1.5, 0)}
            )
            tw:Play()
            tw.Completed:Connect(function()
                if getgenv then pcall(function() getgenv().YourHubKeySys = false end) end
                gui:Destroy()
                main()
            end)
        else
            local keys = readKeys()
            local newKeys = {}
            for _, k in ipairs(keys) do
                if k ~= userKey then
                    table.insert(newKeys, k)
                end
            end
            saveKeys(newKeys)
            updateStatus("Invalid", Color3.fromRGB(220, 60, 60))
            
            -- Progress bar failure color
            TweenService:Create(progressBar, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
            
            -- Update stats
            local stats = parseStats()
            stats.totalKeys = stats.totalKeys + 1
            stats.lastVerified = os.date("%Y-%m-%d %H:%M")
            saveStats(stats)
            addToHistory(userKey, false)
            
            -- Update statistics display
            local successRate = stats.totalKeys > 0 and math.floor((stats.successfulKeys / stats.totalKeys) * 100) or 0
            statsText.Text = string.format("Keys: %d | Success: %d%% | Last: %s", stats.totalKeys, successRate, stats.lastVerified)
            
            -- Update history badge
            local historyCount = #getHistory()
            historyBadge.Text = tostring(historyCount)
            historyBadge.Visible = historyCount > 0
            
            task.wait(1)
            
            -- Hide progress bar and reset
            progressContainer.Visible = false
            progressBar.Size = UDim2.new(0, 0, 1, 0)
        end
    end

    verifyBtn.MouseButton1Click:Connect(handleKeySubmit)
    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            handleKeySubmit()
        end
    end)
end

local function StartLoadingAndCheck()
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "YourHubLoadingGui"
    LoadingGui.ResetOnSpawn = false
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    LoadingGui.DisplayOrder = 6
    LoadingGui.Parent = CoreGui

    -- Modern loading frame with better design
    local frame = Instance.new("Frame")
    frame.Name = "LoadingFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = UDim2.new(0, 380, 0, 180)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ZIndex = 100
    frame.Parent = LoadingGui

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 16)
    fCorner.Parent = frame

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = Color3.fromRGB(70, 70, 70)
    fStroke.Thickness = 1.5
    fStroke.Transparency = 1
    fStroke.Parent = frame
    
    -- Animated background blobs
    local blobContainer = Instance.new("Frame")
    blobContainer.Size = UDim2.new(1, 0, 1, 0)
    blobContainer.BackgroundTransparency = 1
    blobContainer.ClipsDescendants = true
    blobContainer.ZIndex = 101
    blobContainer.Parent = frame
    
    local function createLoadingBlob(size, startPos, color, duration)
        local blob = Instance.new("Frame")
        blob.Size = UDim2.new(0, size, 0, size)
        blob.Position = startPos
        blob.AnchorPoint = Vector2.new(0.5, 0.5)
        blob.BackgroundColor3 = color
        blob.BackgroundTransparency = 0.94
        blob.BorderSizePixel = 0
        blob.ZIndex = 101
        blob.Parent = blobContainer
        
        local corner = Instance.new("UICorner", blob)
        corner.CornerRadius = UDim.new(1, 0)
        
        task.spawn(function()
            while blob and blob.Parent do
                local randomX = math.random(20, 80) / 100
                local randomY = math.random(20, 80) / 100
                TweenService:Create(blob, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(randomX, 0, randomY, 0)
                }):Play()
                task.wait(duration)
            end
        end)
    end
    
    createLoadingBlob(120, UDim2.new(0.3, 0, 0.4, 0), Color3.fromRGB(100, 100, 120), 6)
    createLoadingBlob(150, UDim2.new(0.7, 0, 0.6, 0), Color3.fromRGB(80, 80, 100), 8)

    -- Header section with icon
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundTransparency = 1
    header.ZIndex = 102
    header.Parent = frame
    
    -- Logo/Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0.5, -25, 0, 5)
    icon.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    icon.BorderSizePixel = 0
    icon.Font = Enum.Font.GothamBold
    icon.Text = "🔑"
    icon.TextSize = 28
    icon.TextTransparency = 1
    icon.ZIndex = 103
    icon.Parent = header
    
    local iconCorner = Instance.new("UICorner", icon)
    iconCorner.CornerRadius = UDim.new(0, 12)
    
    local iconStroke = Instance.new("UIStroke", icon)
    iconStroke.Thickness = 1.5
    iconStroke.Color = Color3.fromRGB(70, 70, 70)
    iconStroke.Transparency = 1

    -- Title with better styling
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -40, 0, 32)
    title.Position = UDim2.new(0, 20, 0, 70)
    title.Font = Enum.Font.GothamBold
    title.Text = CheckKeyTitle
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.TextTransparency = 1
    title.ZIndex = 102
    title.Parent = frame

    -- Subtitle
    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(1, -40, 0, 20)
    sub.Position = UDim2.new(0, 20, 0, 105)
    sub.Font = Enum.Font.Gotham
    sub.Text = CheckKeySubtitle
    sub.TextSize = 12
    sub.TextColor3 = Color3.fromRGB(180, 180, 200)
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.TextTransparency = 1
    sub.ZIndex = 102
    sub.Parent = frame

    -- Modern circular spinner
    local spinnerContainer = Instance.new("Frame")
    spinnerContainer.Size = UDim2.new(0, 36, 0, 36)
    spinnerContainer.Position = UDim2.new(0.5, -18, 0, 130)
    spinnerContainer.BackgroundTransparency = 1
    spinnerContainer.ZIndex = 102
    spinnerContainer.Parent = frame

    local spinner = Instance.new("ImageLabel")
    spinner.Size = UDim2.new(1, 0, 1, 0)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://106296997"
    spinner.ImageColor3 = Color3.fromRGB(255, 255, 255)
    spinner.ImageTransparency = 1
    spinner.ZIndex = 103
    spinner.Parent = spinnerContainer

    -- Progress bar with modern design
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -60, 0, 6)
    barBg.Position = UDim2.new(0, 30, 1, -30)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 102
    barBg.BackgroundTransparency = 1
    barBg.Parent = frame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.Position = UDim2.new(0, 0, 0, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 103
    barFill.BackgroundTransparency = 1
    barFill.Parent = barBg

    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(1, 0)
    barFillCorner.Parent = barFill
    
    -- Gradient for progress bar
    local barGradient = Instance.new("UIGradient", barFill)
    barGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 170)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
    })

    -- Entrance animations
    local tIn = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(frame, tIn, {BackgroundTransparency = 0.2}):Play()
    TweenService:Create(fStroke, tIn, {Transparency = 0.5}):Play()
    TweenService:Create(icon, tIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(iconStroke, tIn, {Transparency = 0.6}):Play()
    TweenService:Create(icon, tIn, {TextTransparency = 0}):Play()
    TweenService:Create(title, tIn, {TextTransparency = 0}):Play()
    TweenService:Create(sub, tIn, {TextTransparency = 0.2}):Play()
    TweenService:Create(barBg, tIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(barFill, tIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(spinner, tIn, {ImageTransparency = 0.3}):Play()

    -- Spinner rotation animation
    task.spawn(function()
        while spinner and spinner.Parent do
            TweenService:Create(spinner, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {
                Rotation = spinner.Rotation + 360
            }):Play()
            task.wait(1.2)
        end
    end)

    -- Progress bar animation
    local checking = true
    task.spawn(function()
        while checking and barFill do
            barFill.Size = UDim2.new(0, 0, 1, 0)
            TweenService:Create(barFill, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 1, 0)
            }):Play()
            task.wait(1.6)
        end
    end)

    task.spawn(function()
        local ok, savedKey = trySavedKey()
        checking = false
        task.wait(0.3)

        local tOut = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        local tw1 = TweenService:Create(frame, tOut, {BackgroundTransparency = 1})
        local tw2 = TweenService:Create(fStroke, tOut, {Transparency = 1})
        local tw3 = TweenService:Create(title, tOut, {TextTransparency = 1})
        local tw4 = TweenService:Create(sub, tOut, {TextTransparency = 1})
        local tw5 = TweenService:Create(barBg, tOut, {BackgroundTransparency = 1})
        local tw6 = TweenService:Create(barFill, tOut, {BackgroundTransparency = 1})
        local tw7 = TweenService:Create(spinner, tOut, {ImageTransparency = 1})
        local tw8 = TweenService:Create(icon, tOut, {BackgroundTransparency = 1, TextTransparency = 1})
        local tw9 = TweenService:Create(iconStroke, tOut, {Transparency = 1})

        tw1:Play(); tw2:Play(); tw3:Play(); tw4:Play(); tw5:Play(); tw6:Play(); tw7:Play(); tw8:Play(); tw9:Play()

        tw1.Completed:Connect(function()
            LoadingGui:Destroy()

            if ok and savedKey then
                main()
            else
                CreateYourHubKeyUI()
            end
        end)
    end)
end

StartLoadingAndCheck()
