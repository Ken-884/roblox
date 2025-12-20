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
local ALLOWED_GAME_IDS = {7671049560} -- TODO: replace with your game's GameId(s) (universe id)

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
    Footer = "Anime Eternal",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Center = true,
    Icon = 125926861378074,
    AutoShow = true,
    ShowCustomCursor = true -- Enable custom cursor
})

config = {}
local FPSBoostToggle = config.FPSBoostToggle or false


local MainTab = Window:AddTab("Main", "atom", "Main Features")
local LeftGroupbox = MainTab:AddLeftGroupbox("Auto Mine", "stone")
local RightGroupbox = MainTab:AddRightGroupbox("Auto Farm", "bug")
local BuySell = MainTab:AddRightGroupbox("Auto Buy/Sell", "shopping-cart")
local AutoForge = MainTab:AddLeftGroupbox("Auto Forge", "anvil")
local GoToArea = MainTab:AddLeftGroupbox("Go To Area", "location")

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

---=======================================Main FeatureS=======================================---
--================================================= Auto Mine Feature =================================================--

-- Auto Mine variables
local autoMineEnabled = false
local miningConnection = nil
local selectedAreaName = nil
local selectedRockName = nil
local areaDropdown = nil
local rockDropdown = nil
local minePositionChoice = "Above"
local mineDistance = 8

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Ensure a safe cancel helper exists (other code calls this)
if not cancelCurrentTween then
    function cancelCurrentTween()
        pcall(function()
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
        end)
    end
end

-- Get list of areas under workspace.Rocks
local function getRockAreas()
    local areas = {}
    local rocksRoot = workspace:FindFirstChild("Rocks")
    if not rocksRoot then return areas end
    for _, a in ipairs(rocksRoot:GetChildren()) do
        table.insert(areas, a.Name)
    end
    table.sort(areas)
    return areas
end

-- Helper: find rock parts/models inside an area, prefer those inside a Spawn/SpawnLocation descendant
local function getRocksInArea(areaName)
    local rocks = {}
    local seen = {}
    local rocksRoot = workspace:FindFirstChild("Rocks")
    if not rocksRoot then return rocks end
    local area = rocksRoot:FindFirstChild(areaName)
    if not area then return rocks end

    -- Only include actual rock models or parts, not folders like SpawnLocation
    for _, folder in ipairs(area:GetChildren()) do
        for _, rock in ipairs(folder:GetChildren()) do
            if (rock:IsA("Model") or rock:IsA("BasePart")) and not seen[rock.Name] then
                seen[rock.Name] = true
                table.insert(rocks, rock.Name)
            end
        end
    end
    table.sort(rocks)
    return rocks
end

-- Find a physical part to tween to for given area and rock name. Returns BasePart or nil
local function findRockParts(areaName, rockName)
    -- Returns a list of all available BaseParts for the given rockName in the area, searching all folders
    local rocksRoot = workspace:FindFirstChild("Rocks")
    if not rocksRoot then return {} end
    local area = rocksRoot:FindFirstChild(areaName)
    if not area then return {} end

    local candidates = {}
    for _, folder in ipairs(area:GetChildren()) do
        for _, d in ipairs(folder:GetChildren()) do
            if d.Name == rockName then
                if d:IsA("BasePart") then
                    table.insert(candidates, d)
                elseif d:IsA("Model") then
                    -- Only add the PrimaryPart or first BasePart descendant, not the folder itself
                    if d.PrimaryPart and d.PrimaryPart:IsA("BasePart") then
                        table.insert(candidates, d.PrimaryPart)
                    else
                        for _, c in ipairs(d:GetDescendants()) do
                            if c:IsA("BasePart") then table.insert(candidates, c) break end
                        end
                    end
                end
            end
        end
    end
    return candidates
end

-- Helper: find all available BaseParts for a given rock name in all areas
local function findRockPartsAllAreas(rockName)
    local rocksRoot = workspace:FindFirstChild("Rocks")
    if not rocksRoot then return {} end
    local candidates = {}
    for _, area in ipairs(rocksRoot:GetChildren()) do
        for _, folder in ipairs(area:GetChildren()) do
            for _, d in ipairs(folder:GetChildren()) do
                if d.Name == rockName then
                    if d:IsA("BasePart") then
                        table.insert(candidates, d)
                    elseif d:IsA("Model") then
                        if d.PrimaryPart and d.PrimaryPart:IsA("BasePart") then
                            table.insert(candidates, d.PrimaryPart)
                        else
                            for _, c in ipairs(d:GetDescendants()) do
                                if c:IsA("BasePart") then table.insert(candidates, c) break end
                            end
                        end
                    end
                end
            end
        end
    end
    return candidates
end

-- Helper: get rock health from a part or its ancestor model (reads the "Health" attribute)
local function getRockHealth(part)
    if not part then return nil end
    local function tryGet(obj)
        if not obj then return nil end
        local ok, val = pcall(function() return obj:GetAttribute("Health") end)
        if ok and val ~= nil then
            return tonumber(val) or val
        end
        return nil
    end
    -- Check the part itself first
    local health = tryGet(part)
    if health then return health end
    -- Walk up ancestors to find the model that holds the attribute
    local parent = part.Parent
    local depth = 0
    while parent and depth < 10 do
        health = tryGet(parent)
        if health then return health end
        parent = parent.Parent
        depth = depth + 1
    end
    return nil
end

-- Tween to rock with sleeping pose and chosen above/below offset
local function tweenToRock(part)
    if not part then return false end
    local player = Players.LocalPlayer
    if not player or not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end

    -- Compute vertical offset
    local yOffset = tonumber(mineDistance) or 0
    if minePositionChoice == "Below" then yOffset = -math.abs(yOffset) else yOffset = math.abs(yOffset) end
    local targetPosition = part.Position + Vector3.new(0, yOffset, 0)

    -- Prepare physics/sleep pose
    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    humanoid.AutoRotate = false
    hrp.CanCollide = true
    hrp.Anchored = false

    local targetCFrame = CFrame.new(targetPosition, part.Position)

    local fixedSpeed = 40
    local distance = (hrp.Position - targetPosition).Magnitude
    local duration = math.max(0.08, distance / fixedSpeed)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    currentTween = tween
    tween:Play()
    tween.Completed:Wait()
    currentTween = nil

    -- Anchor at destination and disable collisions for stability
    hrp.Anchored = true
    hrp.CanCollide = false
    return true
end


-- Toggle for prioritizing nearby enemies
local prioritizeEnemies = false
LeftGroupbox:AddToggle("PrioritizeEnemiesToggle", {
    Text = "Prioritize Nearby Enemies",
    Default = false,
    Tooltip = "If enabled, farm enemies near you before mining rocks.",
    Callback = function(value)
        prioritizeEnemies = value
    end
})

-- (legacy) enemy priority distance is hardcoded below as 15

-- Helper: get closest enemy (not localplayer) within a certain distance
local function getClosestEnemy(maxDist)
    maxDist = maxDist or 30 -- default to 30 if not provided
    local living = workspace:FindFirstChild("Living")
    local player = Players.LocalPlayer
    local myChar = player and player.Character
    local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not living or not hrp then return nil end
    local closest, minDist = nil, maxDist
    local myPos = hrp.Position
    for _, model in ipairs(living:GetChildren()) do
        if model:IsA("Model") and model ~= myChar then
            -- prefer Humanoid.Health, but also support other health sources (e.g. model.Game.Health or NumberValue)
            local function getModelHealth(m)
                if not m then return nil end
                -- 1) Humanoid Health
                local ok, humanoid = pcall(function() return m:FindFirstChildOfClass("Humanoid") end)
                if ok and humanoid and humanoid.Health ~= nil then
                    return tonumber(humanoid.Health)
                end
                -- 2) child named "Game" that might have a Health property or be a NumberValue container
                local g = m:FindFirstChild("Game")
                if g then
                    -- If `Game` is a NumberValue or contains a `Health` NumberValue
                    if g:IsA("NumberValue") then
                        return tonumber(g.Value)
                    end
                    local hv = g:FindFirstChild("Health")
                    if hv and hv:IsA("NumberValue") then
                        return tonumber(hv.Value)
                    end
                    -- try direct property access (some instances expose a Health field)
                    local ok2, v = pcall(function() return g.Health end)
                    if ok2 and v ~= nil then return tonumber(v) end
                end
                -- 3) model attribute "Health"
                local ok3, attr = pcall(function() return m:GetAttribute("Health") end)
                if ok3 and attr ~= nil then return tonumber(attr) end
                return nil
            end

            local enemyHealth = getModelHealth(model)
            local enemyRoot = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
            if enemyHealth and enemyRoot and enemyHealth > 0 then
                local enemyPos = enemyRoot.Position
                -- Only consider horizontal (XZ) distance
                local dist = ((Vector3.new(enemyPos.X, 0, enemyPos.Z)) - (Vector3.new(myPos.X, 0, myPos.Z))).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = model
                end
            end
        end
    end
    return closest
end

local function tweenToEnemy(enemy)
    local player = Players.LocalPlayer
    if not player or not player.Character then return false end
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoidRootPart or not humanoid then return false end
    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return false end
    -- Use same sleeping pose and distance as mining
    local yOffset = tonumber(mineDistance) or 0
    if minePositionChoice == "Below" then yOffset = -math.abs(yOffset) else yOffset = math.abs(yOffset) end
    local targetPosition = enemyRoot.Position + Vector3.new(0, yOffset, 0)
    humanoidRootPart.CanCollide = true
    humanoidRootPart.Anchored = false
    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    humanoid.AutoRotate = false
    local targetCFrame = CFrame.new(targetPosition, enemyRoot.Position)
    local tweenService = game:GetService("TweenService")
    local fixedSpeed = 60
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    local duration = math.max(0.1, distance / fixedSpeed)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    currentTween = tween
    tween:Play()
    tween.Completed:Wait()
    currentTween = nil
    humanoidRootPart.Anchored = true
    humanoidRootPart.CanCollide = false
    return true
end

local function attackEnemy()
    pcall(function()
        local args = {
            [1] = "Weapon"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Packages", 9e9):WaitForChild("Knit", 9e9):WaitForChild("Services", 9e9):WaitForChild("ToolService", 9e9):WaitForChild("RF", 9e9):WaitForChild("ToolActivated", 9e9):InvokeServer(unpack(args))
    end)
end

local lastRock = nil -- file scope so it can be reset from dropdown
local function startAutoMining()
    if miningConnection then miningConnection:Disconnect() miningConnection = nil end
    miningConnection = RunService.Heartbeat:Connect(function()
        if not autoMineEnabled then return end
        pcall(function()
            local prioritized = false
            if prioritizeEnemies then
                local enemy = getClosestEnemy(15)
                if enemy then
                    prioritized = true
                    local attempts = 0
                    local maxAttempts = 6
                    while attempts < maxAttempts do
                        if not enemy or not enemy.Parent then break end
                        local ehum = enemy:FindFirstChildOfClass("Humanoid")
                        if not ehum or ehum.Health <= 0 then
                            enemy = getClosestEnemy(15)
                            if not enemy then break end
                            attempts = attempts + 1
                            -- try next enemy
                        else
                            -- Try to tween to current enemy (retry twice)
                            local tweened = false
                            for i = 1, 2 do
                                local ok = pcall(function() tweenToEnemy(enemy) end)
                                if ok then tweened = true break end
                                task.wait(0.05)
                            end
                            if not tweened then break end

                            attackEnemy()
                            task.wait(0.25)

                            -- Re-evaluate enemy health after attack
                            ehum = enemy:FindFirstChildOfClass("Humanoid")
                            if not ehum or ehum.Health <= 0 then
                                -- Try to find another nearby alive enemy immediately
                                local nextEnemy = getClosestEnemy(15)
                                if nextEnemy and nextEnemy ~= enemy then
                                    enemy = nextEnemy
                                    attempts = attempts + 1
                                    -- continue to next loop iteration to attack it
                                else
                                    -- No other enemy found; break to resume mining
                                    break
                                end
                            else
                                -- If another closer enemy appeared, transfer to it
                                local closer = getClosestEnemy(15)
                                if closer and closer ~= enemy then
                                    enemy = closer
                                    attempts = attempts + 1
                                    -- continue to next loop iteration to handle new target
                                else
                                    -- Keep current pose and stop prioritizing for this heartbeat
                                    break
                                end
                            end
                        end
                    end
                    -- Restore player pose after enemy loop
                    pcall(function()
                        local pl = Players.LocalPlayer
                        if pl and pl.Character then
                            local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                            local humanoid = pl.Character:FindFirstChildOfClass("Humanoid")
                            if hrp then hrp.Anchored = false hrp.CanCollide = true end
                            if humanoid then
                                humanoid.PlatformStand = false
                                humanoid.AutoRotate = true
                                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                            end
                        end
                    end)
                    return
                end
            end
            if not selectedAreaName or not selectedRockName then return end
            local parts = findRockParts(selectedAreaName, selectedRockName)
            local validParts = {}
            for _, p in ipairs(parts) do
                if p and p.Parent then
                    local ok, health = pcall(function() return getRockHealth(p) end)
                    if ok then
                        if not health or (tonumber(health) and tonumber(health) > 0) then
                            table.insert(validParts, p)
                        end
                    else
                        table.insert(validParts, p)
                    end
                end
            end
            -- If no valid rocks in selected area, search all areas for the same rock name
            local usingFallback = false
            if #validParts == 0 then
                local allParts = findRockPartsAllAreas(selectedRockName)
                for _, p in ipairs(allParts) do
                    if p and p.Parent then
                        local ok, health = pcall(function() return getRockHealth(p) end)
                        if ok then
                            if not health or (tonumber(health) and tonumber(health) > 0) then
                                table.insert(validParts, p)
                            end
                        else
                            table.insert(validParts, p)
                        end
                    end
                end
                usingFallback = true
            end
            -- Only pick a new rock if lastRock is nil or invalid
            if not lastRock or not lastRock.Parent then
                lastRock = nil
                -- Pick the closest valid part as the new target
                local player = Players.LocalPlayer
                local hrp = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local minDist = math.huge
                local closest = nil
                for _, p in ipairs(validParts) do
                    if hrp then
                        local dist = (p.Position - hrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = p
                        end
                    else
                        closest = p
                        break
                    end
                end
                lastRock = closest
            end
            -- If using fallback, check if selected area has the rock again and switch back if so
            if usingFallback then
                local selectedAreaParts = findRockParts(selectedAreaName, selectedRockName)
                local found = false
                for _, p in ipairs(selectedAreaParts) do
                    if p and p.Parent then
                        local ok, health = pcall(function() return getRockHealth(p) end)
                        if ok then
                            if not health or (tonumber(health) and tonumber(health) > 0) then
                                found = true
                                break
                            end
                        else
                            found = true
                            break
                        end
                    end
                end
                if found then
                    -- force re-pick from selected area
                    lastRock = nil
                end
            end

            -- If there is a valid lastRock, try mining it. If it depletes, immediately transfer to another rock up to 3 times in the same heartbeat.
            if lastRock and lastRock.Parent then
                for attempt = 1, 3 do
                    if not lastRock or not lastRock.Parent then break end
                    -- Double-check the health before attempting
                    local rockHealth = nil
                    pcall(function() rockHealth = getRockHealth(lastRock) end)
                    if rockHealth and tonumber(rockHealth) and tonumber(rockHealth) <= 0 then
                        lastRock = nil
                        break
                    end

                    local ok = pcall(function() tweenToRock(lastRock) end)
                    if not ok then break end

                    pcall(function()
                        local args = {
                            [1] = "Pickaxe";
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Packages", 9e9):WaitForChild("Knit", 9e9):WaitForChild("Services", 9e9):WaitForChild("ToolService", 9e9):WaitForChild("RF", 9e9):WaitForChild("ToolActivated", 9e9):InvokeServer(unpack(args))
                    end)

                    task.wait(0.2) -- small delay to allow server to apply damage and update attribute

                    -- After hitting, check health; if depleted, immediately pick next closest and continue loop
                    local h = nil
                    pcall(function() h = getRockHealth(lastRock) end)
                    if h and tonumber(h) and tonumber(h) <= 0 then
                        -- refresh validParts to exclude depleted
                        local parts2 = findRockParts(selectedAreaName, selectedRockName)
                        local nextClosest = nil
                        local minDist2 = math.huge
                        local pl = Players.LocalPlayer
                        local hrp2 = pl and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                        for _, p in ipairs(parts2) do
                            if p and p.Parent then
                                local ok2, hp2 = pcall(function() return getRockHealth(p) end)
                                if ok2 and (not hp2 or tonumber(hp2) and tonumber(hp2) > 0) then
                                    if hrp2 then
                                        local d = (p.Position - hrp2.Position).Magnitude
                                        if d < minDist2 then minDist2 = d nextClosest = p end
                                    else
                                        nextClosest = p
                                        break
                                    end
                                end
                            end
                        end
                        lastRock = nextClosest
                        -- continue to next attempt which will mine the new lastRock
                    else
                        -- Not depleted yet; finish this heartbeat after resetting pose
                        pcall(function()
                            local pl = Players.LocalPlayer
                            if pl and pl.Character then
                                local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                                local humanoid = pl.Character:FindFirstChildOfClass("Humanoid")
                                if hrp then hrp.Anchored = false hrp.CanCollide = true end
                                if humanoid then
                                    humanoid.PlatformStand = false
                                    humanoid.AutoRotate = true
                                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                                end
                            end
                        end)
                        break
                    end
                end
            else
                -- No valid rocks, clear lastRock and refresh dropdown
                lastRock = nil
                pcall(function()
                    if rockDropdown then rockDropdown:SetValues(getRocksInArea(selectedAreaName)) end
                end)
                task.wait(0.5)
            end
        end)
    end)
end

local function stopAutoMining()
    if miningConnection then miningConnection:Disconnect() miningConnection = nil end
    pcall(cancelCurrentTween)
    pcall(function()
        local pl = Players.LocalPlayer
        if pl and pl.Character then
            local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = pl.Character:FindFirstChildOfClass("Humanoid")
            if hrp then hrp.Anchored = false hrp.CanCollide = true end
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.AutoRotate = true
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)
end

-- UI: Area dropdown
areaDropdown = LeftGroupbox:AddDropdown("MineAreaSelect", {
    Text = "Select Mine Area",
    Values = getRockAreas(),
    Default = 1,
    Multi = false,
    Tooltip = "Choose which area (folder inside workspace.Rocks) to mine",
    Callback = function(value)
        selectedAreaName = value
        -- refresh rock list when area changes
        pcall(function()
            if rockDropdown then rockDropdown:SetValues(getRocksInArea(selectedAreaName)) end
        end)
    end
})

-- UI: Rock dropdown
rockDropdown = LeftGroupbox:AddDropdown("MineRockSelect", {
    Text = "Select Rock",
    Values = {},
    Default = 1,
    Multi = false,
    Tooltip = "Choose the rock type inside the selected area to tween to",
    Callback = function(value)
        selectedRockName = value
        -- If Auto Mine is enabled, immediately update mining target and reset lastRock
        if autoMineEnabled then
            lastRock = nil
        end
    end
})

-- Real-time rock dropdown updater
local lastRockList = nil
task.spawn(function()
    while true do
        task.wait(1.0) -- Check every second
        if selectedAreaName and rockDropdown then
            local currentRocks = getRocksInArea(selectedAreaName)
            -- Always show the last selected rock name, even if not available
            if selectedRockName and selectedRockName ~= "" and not table.find(currentRocks, selectedRockName) then
                table.insert(currentRocks, selectedRockName)
            end
            -- Only update if the list has changed
            local changed = false
            if not lastRockList or #lastRockList ~= #currentRocks then
                changed = true
            else
                for i, v in ipairs(currentRocks) do
                    if lastRockList[i] ~= v then changed = true break end
                end
            end
            if changed then
                rockDropdown:SetValues(currentRocks)
                lastRockList = currentRocks
                -- If the currently selected rock is gone, select the first available
                if selectedRockName == nil or not table.find(currentRocks, selectedRockName) then
                    selectedRockName = currentRocks[1]
                    if selectedRockName then
                        rockDropdown:SetValue(selectedRockName)
                    end
                end
            end
        end
    end
end)

-- UI: Position dropdown (Above/Below)
LeftGroupbox:AddDropdown("MinePositionDropdown", {
    Text = "Mine Position",
    Values = {"Above", "Below"},
    Default = 1,
    Multi = false,
    Tooltip = "Choose whether to tween above or below the rock (sleep pose)",
    Callback = function(value)
        minePositionChoice = value
    end
})

-- UI: Distance slider
LeftGroupbox:AddSlider("MineDistance", {
    Text = "Distance From Rock",
    Default = mineDistance,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Tooltip = "Vertical distance (studs) between you and the rock when positioned",
    Callback = function(value)
        mineDistance = value
    end
})

-- Toggle to start/stop auto mine
LeftGroupbox:AddToggle("AutoMineToggle", {
    Text = "Auto Mine",
    Default = false,
    Tooltip = "Automatically tween to the selected rock inside the selected area",
    Callback = function(value)
        autoMineEnabled = value
        if value then
            if not selectedAreaName then
                -- set default area if possible
                local areas = getRockAreas()
                if #areas > 0 then
                    selectedAreaName = areas[1]
                    pcall(function() areaDropdown:SetValue(selectedAreaName) end)
                end
            end
            -- populate rocks dropdown
            pcall(function()
                if selectedAreaName then rockDropdown:SetValues(getRocksInArea(selectedAreaName)) end
                if not selectedRockName then
                    local rvals = getRocksInArea(selectedAreaName)
                    if rvals and #rvals > 0 then
                        selectedRockName = rvals[1]
                        rockDropdown:SetValue(selectedRockName)
                    end
                end
            end)

            startAutoMining()
        else
            stopAutoMining()
        end
    end
})

-- Initialize area dropdown default
do
    local init = getRockAreas()
    if init and #init > 0 then
        selectedAreaName = init[1]
        pcall(function() if areaDropdown and areaDropdown.SetValue then areaDropdown:SetValue(selectedAreaName) end end)
        pcall(function() if rockDropdown and rockDropdown.SetValues then rockDropdown:SetValues(getRocksInArea(selectedAreaName)) end end)
        local r = getRocksInArea(selectedAreaName)
        if r and #r > 0 then
            selectedRockName = r[1]
            pcall(function() if rockDropdown and rockDropdown.SetValue then rockDropdown:SetValue(selectedRockName) end end)
        end
    end
end










--================================================= Auto Farm Enemy Feature =================================================--
local autoFarmEnemy = false
local enemyConnection = nil
local selectedEnemyName = nil
local enemyDropdown = nil
local enemyYOffset = 7 -- default Y offset below enemy
-- Separate sleep position choice for enemies (so enemies have their own Above/Below)
local enemySleepPositionChoice = "Above"

local function getEnemies()
    local enemies = {}
    local living = workspace:FindFirstChild("Living")
    if not living then return enemies end
    
    for _, child in ipairs(living:GetChildren()) do
        if child:IsA("Model") and child ~= Players.LocalPlayer.Character then
            -- Only consider models that do NOT contain a 'Health' child (these are not targetable enemies)
            if not child:FindFirstChild("Health") then
                -- Check if it has a Humanoid and HumanoidRootPart
                if child:FindFirstChild("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
                    -- Optional: Check if alive
                    if child.Humanoid.Health > 0 then
                        table.insert(enemies, child)
                    end
                end
            end
        end
    end
    return enemies
end

local function tweenToEnemy(enemy)
    local player = Players.LocalPlayer
    if not player or not player.Character then return false end
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoidRootPart or not humanoid then return false end
    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return false end
    
    -- Target position based on `enemySleepPositionChoice`: above or below enemy
    local enemyVerticalOffset = (enemySleepPositionChoice == "Below") and -math.abs(enemyYOffset) or math.abs(enemyYOffset)
    local targetPosition = enemyRoot.Position + Vector3.new(0, enemyVerticalOffset, 0)
    
    -- Enable collisions for travel
    humanoidRootPart.CanCollide = true
    humanoidRootPart.Anchored = false
    
    -- Force sleep/ragdoll state
    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    humanoid.AutoRotate = false
    
    -- Build target CFrame so the character faces the enemy.
    -- Placing the HRP at `targetPosition` and orienting towards the enemy ensures
    -- "Above" (HRP above enemy) will make the lookVector point down (face down),
    -- and "Below" will make the lookVector point up (face up).
    local targetCFrame = CFrame.new(targetPosition, enemyRoot.Position)
    
    -- Tween to position
    local tweenService = game:GetService("TweenService")
    local fixedSpeed = 60 -- Faster speed for enemies
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    local duration = math.max(0.1, distance / fixedSpeed)
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, {
        CFrame = targetCFrame
    })
    currentTween = tween
    tween:Play()
    local _, playbackState = tween.Completed:Wait()
    currentTween = nil
    if playbackState == Enum.PlaybackState.Cancelled then
        return false
    end

    -- Anchor and disable collision for farming
    humanoidRootPart.Anchored = true
    humanoidRootPart.CanCollide = false
    return true
end

-- Soft-reset the player's character to recover from stuck states.
local function softResetCharacter(character)
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    pcall(function()
        hrp.Anchored = false
        hrp.CanCollide = true
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)
    task.wait(0.1)
    pcall(function()
        humanoid.PlatformStand = true
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        humanoid.AutoRotate = false
    end)
end

local function attackEnemy()
    pcall(function()
        local args = {
            [1] = "Weapon"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Packages", 9e9):WaitForChild("Knit", 9e9):WaitForChild("Services", 9e9):WaitForChild("ToolService", 9e9):WaitForChild("RF", 9e9):WaitForChild("ToolActivated", 9e9):InvokeServer(unpack(args))
    end)
end

local function startAutoFarming()
    if enemyConnection then
        enemyConnection:Disconnect()
        enemyConnection = nil
    end
    
    -- Keep track of last successful damage time so we can reset if attacks stop working
    local lastSuccessfulHit = tick()

    enemyConnection = RunService.Heartbeat:Connect(function()
        if not autoFarmEnemy then return end
        
        pcall(function()
            local player = Players.LocalPlayer
            local character = player and player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            if not character or not humanoid then return end
            
            -- Ensure sleep state
            if not humanoid.PlatformStand then
                humanoid.PlatformStand = true
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            end
            
            -- Target logic: prefer the selected enemy type; if none present, farm the nearest enemy.
            local enemies = getEnemies()
            local myPos = character.HumanoidRootPart.Position

            local selName = nil
            if type(selectedEnemyName) == "string" then
                selName = selectedEnemyName
            elseif type(selectedEnemyName) == "table" and #selectedEnemyName > 0 then
                selName = selectedEnemyName[1]
            end

            local function findNearestInList(list)
                local nearest, minDist = nil, math.huge
                for _, enemy in ipairs(list) do
                    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                    if enemyRoot and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        local targetPos = enemyRoot.Position - Vector3.new(0, enemyYOffset, 0)
                        local dist = (targetPos - myPos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = enemy
                        end
                    end
                end
                return nearest
            end

            local targetEnemy = nil
            if selName then
                local selList = {}
                for _, e in ipairs(enemies) do
                    local baseName = string.match(e.Name, "^(.-)%d*$") or e.Name
                    if baseName == selName then table.insert(selList, e) end
                end
                targetEnemy = findNearestInList(selList)
            end

            if not targetEnemy then
                targetEnemy = findNearestInList(enemies)
            end

            if targetEnemy then
                -- Record previous health to detect damage
                local prevHealth = nil
                if targetEnemy and targetEnemy:FindFirstChild("Humanoid") then
                    prevHealth = targetEnemy.Humanoid.Health
                end

                local ok = pcall(function() tweenToEnemy(targetEnemy) end)
                if ok then
                    attackEnemy()
                    -- Wait a short moment for server to apply damage
                    task.wait(0.7)
                    -- Check if damage occurred
                    if targetEnemy and targetEnemy:FindFirstChild("Humanoid") then
                        local cur = targetEnemy.Humanoid.Health
                        if prevHealth and cur < prevHealth then
                            lastSuccessfulHit = tick()
                        end
                    end
                    -- If we've not seen damage for a while, soft-reset the character and retry
                    if tick() - lastSuccessfulHit > 8 then
                        -- Try soft-reset sequence first
                        softResetCharacter(character)
                        -- retry movement once
                        pcall(function() tweenToEnemy(targetEnemy) end)
                        attackEnemy()
                        lastSuccessfulHit = tick()
                    end

                    -- If still no hits after a longer timeout, perform an automatic full restart
                    if tick() - lastSuccessfulHit > 16 then
                        -- Forceful reset sequence for long-running desyncs
                        pcall(function() cancelCurrentTween() end)
                        -- Disconnect the heartbeat connection if still present
                        pcall(function()
                            if enemyConnection then
                                enemyConnection:Disconnect()
                                enemyConnection = nil
                            end
                        end)

                        -- Restore humanoid/HRP state to give server a clean starting point
                        pcall(function()
                            local pl = Players.LocalPlayer
                            if pl and pl.Character then
                                local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                                local humanoid = pl.Character:FindFirstChildOfClass("Humanoid")
                                if hrp then
                                    hrp.Anchored = false
                                    hrp.CanCollide = true
                                    hrp.CFrame = CFrame.new(hrp.Position)
                                end
                                if humanoid then
                                    humanoid.PlatformStand = false
                                    humanoid.AutoRotate = true
                                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                                end
                                -- small pause to let server/character sync
                                task.wait(0.2)
                                if humanoid then
                                    humanoid.PlatformStand = true
                                    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                                    humanoid.AutoRotate = false
                                end
                            end
                        end)

                        -- small delay to allow cleanup and server-side sync
                        task.wait(0.6)

                        -- restart only if user still wants auto farm enabled
                        if autoFarmEnemy then
                            pcall(function()
                                startAutoFarming()
                            end)
                        end

                        -- reset the timestamp to avoid immediate repeat
                        lastSuccessfulHit = tick()
                    end
                end
            else
                task.wait(0.5)
            end
        end)
    end)
end

local function stopAutoFarming()
    if enemyConnection then
        enemyConnection:Disconnect()
        enemyConnection = nil
    end
    -- Cancel any active movement tween immediately so player regains control
    pcall(cancelCurrentTween)

    -- Restore humanoid state and force upright, above ground
    pcall(function()
        local player = Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                -- Anchor, move up, set upright, then unanchor
                humanoidRootPart.Anchored = true
                local pos = humanoidRootPart.Position
                humanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y + 8, pos.Z)
                task.wait(0.1)
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)
                humanoidRootPart.Anchored = false
                humanoidRootPart.CanCollide = true
            end
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.AutoRotate = true
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)
    -- Extra safety: re-apply restore a few times to ensure other code doesn't re-freeze player
    pcall(function()
        task.spawn(function()
            local player = Players.LocalPlayer
            for i = 1, 4 do
                if not player or not player.Character then break end
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                pcall(function()
                    if hrp then hrp.Anchored = false hrp.CanCollide = true end
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid.AutoRotate = true
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end)
                task.wait(0.12)
            end
        end)
    end)
end

-- Fire the EquipAchievement remote for weapon forging (safe pcall wrapper)
-- Fire the EquipAchievement remote for weapon forging (disabled)
-- Fire the EquipAchievement remote for weapon forging (safe pcall wrapper)
local function fireEquipAchievement(name)
    -- name: string name of the achievement to trigger. Defaults to weapon_forging
    name = name or "weapon_forging"
    pcall(function()
        local args = {[1] = name}
        local rep = game:GetService("ReplicatedStorage")
        local rf = rep:WaitForChild("Shared", 9e9)
            :WaitForChild("Packages", 9e9)
            :WaitForChild("Knit", 9e9)
            :WaitForChild("Services", 9e9)
            :WaitForChild("AchievementService", 9e9)
            :WaitForChild("RE", 9e9)
            :WaitForChild("EquipAchievement", 9e9)
        rf:FireServer(unpack(args))
    end)
end

-- Helper: read the weapon_forging EquipBoost Title text safely
local function getWeaponForgingTitleText()
    local ok, txt = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if not player then return nil end
        local gui = player:FindFirstChild("PlayerGui")
        if not gui then return nil end
        local menu = gui:FindFirstChild("Menu")
        if not menu then return nil end
        local frame = menu:FindFirstChild("Frame")
        if not frame then return nil end
        local inner = frame:FindFirstChild("Frame")
        if not inner then return nil end
        local menus = inner:FindFirstChild("Menus")
        if not menus then return nil end
        local achievements = menus:FindFirstChild("Achievements")
        if not achievements then return nil end
        local achChildren = achievements:FindFirstChild("Achievements") or achievements
        local wf = achChildren:FindFirstChild("weapon_forging")
        if not wf then return nil end
        local equipBoost = wf:FindFirstChild("EquipBoost")
        if not equipBoost then return nil end
        local eqFrame = equipBoost:FindFirstChild("Frame")
        if not eqFrame then return nil end
        local title = eqFrame:FindFirstChild("Title")
        if not title then return nil end
        return title.Text
    end)
    if ok then return txt end
    return nil
end

RightGroupbox:AddToggle("AutoFarmEnemyToggle", {
    Text = "Auto Farm Enemies",
    Default = false,
    Tooltip = "Automatically move to targeted enemies and attempt attacks",
    Callback = function(value)
        autoFarmEnemy = value
        
        if value then
            -- Only fire EquipAchievement when enabling if UI shows "Equip Skill"
            pcall(function()
                local title = getWeaponForgingTitleText()
                if title == "Equip Skill" then
                    local args = {
                        [1] = "weapon_forging";
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Packages", 9e9):WaitForChild("Knit", 9e9):WaitForChild("Services", 9e9):WaitForChild("AchievementService", 9e9):WaitForChild("RE", 9e9):WaitForChild("EquipAchievement", 9e9):FireServer(unpack(args))
                end
            end)
            startAutoFarming()
        else
            -- Only fire EquipAchievement when disabling if UI shows "Unequip Skill"
            pcall(function()
                local title = getWeaponForgingTitleText()
                if title == "Unequip Skill" then
                    local args = {
                        [1] = "weapon_forging";
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Packages", 9e9):WaitForChild("Knit", 9e9):WaitForChild("Services", 9e9):WaitForChild("AchievementService", 9e9):WaitForChild("RE", 9e9):WaitForChild("EquipAchievement", 9e9):FireServer(unpack(args))
                end
            end)
            stopAutoFarming()
        end
    end
})

-- Enemy-specific sleep position dropdown (Above = face down, Below = face up)
RightGroupbox:AddDropdown("EnemyPositionDropdown", {
    Text = "Enemy Position",
    Values = {"Above", "Below"},
    Default = 1,
    Multi = false,
    Tooltip = "Choose how your character will be positioned when idle near the enemy (Above = face down, Below = face up)",
    Callback = function(value)
        enemySleepPositionChoice = value
        -- If auto-farming is active, immediately retween to apply new choice
        pcall(function()
            if autoFarmEnemy then
                local pl = game:GetService("Players").LocalPlayer
                if not pl or not pl.Character then return end
                local enemies = getEnemies()
                local nearest, minDist = nil, math.huge
                local myPos = pl.Character:FindFirstChild("HumanoidRootPart") and pl.Character.HumanoidRootPart.Position
                if not myPos then return end
                for _, e in ipairs(enemies) do
                    local er = e:FindFirstChild("HumanoidRootPart")
                    if er and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
                        local dist = (er.Position - myPos).Magnitude
                        if dist < minDist then minDist = dist nearest = e end
                    end
                end
                if nearest then
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = pl.Character:FindFirstChildOfClass("Humanoid")
                    if hrp then hrp.Anchored = false hrp.CanCollide = true end
                    if humanoid then humanoid.PlatformStand = false humanoid.AutoRotate = true end
                    pcall(function() tweenToEnemy(nearest) end)
                end
            end
        end)
    end
})


    -- Helper to build enemy name list and dropdown UI
    local function refreshEnemyDropdown()
        if not enemyDropdown then return end
        local names = {}
        local seen = {}
        local found = 0
        for _, e in ipairs(getEnemies()) do
            if e and e.Name then
                local baseName = string.match(e.Name, "^(.-)%d*$") or e.Name
                local healthObj = e:FindFirstChild("Health")
                if not healthObj and not seen[baseName] then
                    seen[baseName] = true
                    table.insert(names, baseName)
                    found = found + 1
                end
            end
        end
        print("[DEBUG] Enemy dropdown found " .. found .. " unique enemy types.")
        enemyDropdown:SetValues(names)
        pcall(function()
            local current = selectedEnemyName
            if not current and #names > 0 then current = names[1] end
            if current then enemyDropdown:SetValue(current) end
        end)
    end


    -- Enemy selection dropdown (positioned below the Auto Farm toggle)
    enemyDropdown = RightGroupbox:AddDropdown("EnemySelect", {
        Text = "Target Enemy",
        Values = {},
        Default = 1,
        Multi = false,
        Tooltip = "Select which enemy type the auto-farm should target",
        Callback = function(value)
            selectedEnemyName = value
        end
    })

    -- Slider to adjust enemy Y offset
    RightGroupbox:AddSlider("EnemyYOffset", {
        Text = "Auto Farm Distance",
        Default = enemyYOffset,
        Min = 0,
        Max = 20,
        Rounding = 0,
        Tooltip = "Distance (in studs) to position below the enemy while farming",
        Callback = function(value)
            enemyYOffset = value
        end
    })


    -- Populate dropdown initially and provide a small refresh
    task.spawn(function()
        pcall(refreshEnemyDropdown)
    end)


--================================================= Auto Buy Pickaxe =================================================--
-- Dropdown for Pickaxes in workspace.Proximity
local function getPickaxesInProximity()
    local pickaxes = {}
    local prox = workspace:FindFirstChild("Proximity")
    if prox then
        for _, obj in ipairs(prox:GetChildren()) do
            if obj.Name:lower():find("pickaxe") then
                table.insert(pickaxes, obj.Name)
            end
        end
    end
    table.sort(pickaxes)
    return pickaxes
end

local selectedPickaxe = nil
local pickaxeDropdown = BuySell:AddDropdown("PickaxeSelect", {
    Text = "Select Pickaxe",
    Values = getPickaxesInProximity(),
    Default = 1,
    Multi = false,
    Tooltip = "Choose a pickaxe to purchase or pick up from nearby vendors",
    Callback = function(value)
        selectedPickaxe = value
        print("Selected Pickaxe:", value)
    end
})

-- Initialize selectedPickaxe to the first available value so the dropdown default is honored
do
    local initial = getPickaxesInProximity()
    if initial and #initial > 0 then
        selectedPickaxe = initial[1]
        pcall(function()
            if pickaxeDropdown and pickaxeDropdown.SetValue then
                pickaxeDropdown:SetValue(selectedPickaxe)
            end
        end)
    end
end

    local buyPickaxeEnabled = false
    local buyPickaxeConnection = nil

    local function getPickaxeTargetByName(name)
        local prox = workspace:FindFirstChild("Proximity")
        if not prox then return nil end
        local obj = prox:FindFirstChild(name)
        if not obj then return nil end
        -- Prefer a child named "Handle"
        local h = obj:FindFirstChild("Handle")
        if h and h:IsA("BasePart") then return h end
        -- Otherwise try the 4th child if it exists and is a part
        local children = obj:GetChildren()
        if #children >= 4 and children[4] and children[4]:IsA("BasePart") then
            return children[4]
        end
        -- Fallback: first BasePart descendant
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("BasePart") then return d end
        end
        return nil
    end

    local function tweenToPickaxePart(part)
        if not part then return false end
        local player = Players.LocalPlayer
        if not player or not player.Character then return false end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return false end

        -- Noclip-style travel (disable collisions during tween) but do NOT change
        -- humanoid.PlatformStand or apply a sleeping rotation.
        local tweenService = TweenService
        local fixedSpeed = 50
        local targetPos = part.Position + Vector3.new(0, 2, 0)
        local distance = (hrp.Position - targetPos).Magnitude
        local duration = math.max(0.05, distance / fixedSpeed)
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

        -- Disable collisions so the player won't get stuck while moving (noclip-like)
        local ok, previousCanCollide = pcall(function() return hrp.CanCollide end)
        hrp.CanCollide = false
        hrp.Anchored = false

        -- Preserve current facing direction by using the current lookVector
        local lookVec = hrp.CFrame.LookVector
        local targetCFrame = CFrame.new(targetPos, targetPos + lookVec)

        local tween = tweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()

        -- Anchor at destination to keep stable for purchase, but keep collisions disabled
        hrp.Anchored = true
        hrp.CanCollide = false
        return true
    end

    local function purchasePickaxeByName(pickaxeName)
        local ok, err = pcall(function()
            local args = {
                [1] = pickaxeName,
                [2] = 1,
            }
            local rf = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9)
                :WaitForChild("Packages", 9e9)
                :WaitForChild("Knit", 9e9)
                :WaitForChild("Services", 9e9)
                :WaitForChild("ProximityService", 9e9)
                :WaitForChild("RF", 9e9)
                :WaitForChild("Purchase", 9e9)
            rf:InvokeServer(unpack(args))
        end)
        return ok
    end

    local function startBuyPickaxe()
        if buyPickaxeConnection then buyPickaxeConnection:Disconnect() buyPickaxeConnection = nil end
        buyPickaxeConnection = RunService.Heartbeat:Connect(function()
            if not buyPickaxeEnabled then return end
            pcall(function()
                if not selectedPickaxe then
                    buyPickaxeEnabled = false
                    return
                end
                local targetPart = getPickaxeTargetByName(selectedPickaxe)
                if targetPart then
                    local player = Players.LocalPlayer
                    local hrp = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - targetPart.Position).Magnitude
                        if dist > 3 then
                            tweenToPickaxePart(targetPart)
                        end
                        -- Recompute distance after tween
                        dist = (hrp.Position - targetPart.Position).Magnitude
                        if dist <= 3 then
                            -- Attempt purchase (no UI notification)
                            pcall(function()
                                purchasePickaxeByName(selectedPickaxe)
                            end)
                            buyPickaxeEnabled = false
                            stopBuyPickaxe()
                            return
                        end
                    end
                else
                    -- target not found, stop the buy process
                    buyPickaxeEnabled = false
                    stopBuyPickaxe()
                end
                task.wait(1)
            end)
        end)
    end

    local function stopBuyPickaxe()
        if buyPickaxeConnection then
            buyPickaxeConnection:Disconnect()
            buyPickaxeConnection = nil
        end
        -- Restore player state
        pcall(function()
            local player = Players.LocalPlayer
            if player and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.Anchored = false
                    humanoidRootPart.CanCollide = true
                    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)
                end
                if humanoid then
                    humanoid.PlatformStand = false
                    humanoid.AutoRotate = true
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end)
    end

    -- Toggle in UI
    BuySell:AddToggle("AutoBuyPickaxeToggle", {
        Text = "Auto Buy Pickaxe",
        Default = false,
        Tooltip = "Move to the selected pickaxe so you can obtain it",
        Callback = function(value)
            buyPickaxeEnabled = value
            if value then
                if not selectedPickaxe then
                    buyPickaxeEnabled = false
                    return
                end
                startBuyPickaxe()
            else
                stopBuyPickaxe()
            end
        end
    })

BuySell:AddDivider()

--================================================= Auto Sell Ore/Rock =================================================--
local sellOreEnabled = false
local sellOreConnection = nil
local selectedSellOre = nil
local sellOreDropdown = nil

local function getOreNames()
    local names = {}
    local set = {}
    local rep = game:GetService("ReplicatedStorage")
    local ok, shared = pcall(function() return rep:WaitForChild("Shared", 2) end)
    if not ok or not shared then return names end
    local data = shared:FindFirstChild("Data")
    if not data then return names end
    local ore = data:FindFirstChild("Ore")
    if not ore then return names end

    -- Traverse top level children and one level deeper to collect ore names
    for _, child in ipairs(ore:GetChildren()) do
        -- If child has children (like categories), add their names
        local grandchildren = child:GetChildren()
        if #grandchildren > 0 then
            for _, g in ipairs(grandchildren) do
                if g.Name and not set[g.Name] then
                    table.insert(names, g.Name)
                    set[g.Name] = true
                end
            end
        else
            if child.Name and not set[child.Name] then
                table.insert(names, child.Name)
                set[child.Name] = true
            end
        end
    end

    table.sort(names)
    return names
end

local function sellOreByName(oreName)
    if not oreName then return false end
    local args = {
        [1] = "SellConfirm",
        [2] = {
            ["Basket"] = {
                [oreName] = 1,
            },
        },
    }
    local ok, err = pcall(function()
        local rf = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9)
            :WaitForChild("Packages", 9e9)
            :WaitForChild("Knit", 9e9)
            :WaitForChild("Services", 9e9)
            :WaitForChild("DialogueService", 9e9)
            :WaitForChild("RF", 9e9)
            :WaitForChild("RunCommand", 9e9)
        rf:InvokeServer(unpack(args))
    end)
    return ok
end

-- Find a BasePart inside workspace.Proximity by name (e.g., the seller NPC)
local function getProximityTargetByName(name)
    local prox = workspace:FindFirstChild("Proximity")
    if not prox then return nil end
    local obj = prox:FindFirstChild(name)
    if not obj then return nil end
    -- prefer a child named "Handle" or HumanoidRootPart, otherwise first BasePart descendant
    local h = obj:FindFirstChild("Handle") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart")
    if h and h:IsA("BasePart") then return h end
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function startAutoSell()
    if sellOreConnection then sellOreConnection:Disconnect() sellOreConnection = nil end
    local lastSell = 0
    sellOreConnection = RunService.Heartbeat:Connect(function()
        if not sellOreEnabled then return end
        pcall(function()
            if not selectedSellOre then
                sellOreEnabled = false
                return
            end

            -- Ensure we're near the seller NPC before selling
            local player = Players.LocalPlayer
            local hrp = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local sellerPart = getProximityTargetByName("Greedy Cey")
            if hrp and sellerPart then
                local dist = (hrp.Position - sellerPart.Position).Magnitude
                if dist > 5 then
                    -- use the existing noclip-style tween function to move near the seller
                    pcall(function()
                        tweenToPickaxePart(sellerPart)
                    end)
                end
            end

            -- simple cooldown to avoid spamming: perform sells once per second
            if tick() - lastSell < 1 then return end

            -- Support single string or table of selected ores
            if type(selectedSellOre) == "table" then
                for _, oreName in ipairs(selectedSellOre) do
                    if type(oreName) == "string" and oreName ~= "" then
                        sellOreByName(oreName)
                        task.wait(0.05)
                    end
                end
            else
                sellOreByName(selectedSellOre)
            end

            lastSell = tick()
        end)
    end)
end

local function stopAutoSell()
    if sellOreConnection then
        sellOreConnection:Disconnect()
        sellOreConnection = nil
    end
    -- Restore player state (unanchor, enable collisions)
    pcall(function()
        local player = Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.Anchored = false
                humanoidRootPart.CanCollide = true
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)
            end
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.AutoRotate = true
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)
end

-- Dropdown + Toggle UI
sellOreDropdown = BuySell:AddDropdown("SellOreSelect", {
    Text = "Select Ore To Sell",
    Values = getOreNames(),
    Default = 1,
    Multi = false,
    Tooltip = "Choose which ore type to automatically sell",
    Callback = function(value)
        selectedSellOre = value
    end
})

-- Initialize selectedSellOre so the default is effective
do
    local initial = getOreNames()
    if initial and #initial > 0 then
        selectedSellOre = initial[1]
        pcall(function()
            if sellOreDropdown and sellOreDropdown.SetValue then sellOreDropdown:SetValue(selectedSellOre) end
        end)
    end
end

BuySell:AddToggle("AutoSellOreToggle", {
    Text = "Auto Sell Selected Ore",
    Default = false,
    Tooltip = "Automatically sell the chosen ore to the vendor when available",
    Callback = function(value)
        sellOreEnabled = value
        if value then
            if not selectedSellOre then
                sellOreEnabled = false
                return
            end
            startAutoSell()
        else
            stopAutoSell()
        end
    end
})
BuySell:AddDivider()
--================================================= Auto Buy Potion =================================================--
-- Auto Buy Potion
local function getPotionsInProximity()
    local potions = {}
    local prox = workspace:FindFirstChild("Proximity")
    if prox then
        for _, obj in ipairs(prox:GetChildren()) do
            if obj.Name:lower():find("potion") then
                table.insert(potions, obj.Name)
            end
        end
    end
    table.sort(potions)
    return potions
end

local selectedPotion = nil
local potionDropdown = BuySell:AddDropdown("PotionSelect", {
    Text = "Select Potion",
    Values = getPotionsInProximity(),
    Default = 1,
    Multi = false,
    Tooltip = "Choose a potion to buy from nearby vendors",
    Callback = function(value)
        selectedPotion = value
        print("Selected Potion:", value)
    end
})

-- Initialize selectedPotion to the first available value so default is honored
do
    local initial = getPotionsInProximity()
    if initial and #initial > 0 then
        selectedPotion = initial[1]
        pcall(function()
            if potionDropdown and potionDropdown.SetValue then
                potionDropdown:SetValue(selectedPotion)
            end
        end)
    end
end

local buyPotionEnabled = false
local buyPotionConnection = nil

local function getPotionTargetByName(name)
    local prox = workspace:FindFirstChild("Proximity")
    if not prox then return nil end
    local obj = prox:FindFirstChild(name)
    if not obj then return nil end
    -- Prefer a child named "Handle"
    local h = obj:FindFirstChild("Handle")
    if h and h:IsA("BasePart") then return h end
    -- Fallback: first BasePart descendant
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function tweenToPotionPart(part)
    -- reuse the same noclip-style movement used for pickaxes
    return tweenToPickaxePart(part)
end

local function purchasePotionByName(potionName)
    local ok = false
    pcall(function()
        local args = {
            [1] = potionName,
            [2] = 1,
        }
        local rf = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9)
            :WaitForChild("Packages", 9e9)
            :WaitForChild("Knit", 9e9)
            :WaitForChild("Services", 9e9)
            :WaitForChild("ProximityService", 9e9)
            :WaitForChild("RF", 9e9)
            :WaitForChild("Purchase", 9e9)
        rf:InvokeServer(unpack(args))
        ok = true
    end)
    return ok
end

local function startBuyPotion()
    if buyPotionConnection then buyPotionConnection:Disconnect() buyPotionConnection = nil end
    buyPotionConnection = RunService.Heartbeat:Connect(function()
        if not buyPotionEnabled then return end
        pcall(function()
            if not selectedPotion then
                buyPotionEnabled = false
                return
            end
            local targetPart = getPotionTargetByName(selectedPotion)
            if targetPart then
                local player = Players.LocalPlayer
                local hrp = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - targetPart.Position).Magnitude
                    if dist > 3 then
                        tweenToPotionPart(targetPart)
                    end
                    dist = (hrp.Position - targetPart.Position).Magnitude
                    if dist <= 3 then
                        pcall(function()
                            purchasePotionByName(selectedPotion)
                        end)
                        buyPotionEnabled = false
                        stopBuyPotion()
                        return
                    end
                end
            else
                buyPotionEnabled = false
                stopBuyPotion()
            end
            task.wait(1)
        end)
    end)
end

local function stopBuyPotion()
    if buyPotionConnection then
        buyPotionConnection:Disconnect()
        buyPotionConnection = nil
    end
    pcall(function()
        local player = Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.Anchored = false
                humanoidRootPart.CanCollide = true
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)
            end
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.AutoRotate = true
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)
end

BuySell:AddToggle("AutoBuyPotionToggle", {
    Text = "Auto Buy Potion",
    Default = false,
    Tooltip = "Move to the selected potion and purchase it automatically",
    Callback = function(value)
        buyPotionEnabled = value
        if value then
            if not selectedPotion then
                buyPotionEnabled = false
                return
            end
            startBuyPotion()
        else
            stopBuyPotion()
        end
    end
})

--================================================= Proximity Targets (generic) =================================================--
-- Dropdown showing children of workspace.Proximity excluding pickaxes and potions
local function getProximityItems()
    local items = {}
    local prox = workspace:FindFirstChild("Proximity")
    if not prox then return items end
    for _, obj in ipairs(prox:GetChildren()) do
        local name = obj.Name or ""
        local lname = name:lower()
        -- Exclude pickaxes and potions from this generic list
        if not (lname:find("pickaxe") or lname:find("potion")) then
            table.insert(items, name)
        end
    end
    table.sort(items)
    return items
end

local selectedProximityTarget = nil
local proximityDropdown = GoToArea:AddDropdown("ProximitySelect", {
    Text = "Select NPC's",
    Values = getProximityItems(),
    Default = 1,
    Multi = false,
    Tooltip = "Choose an object inside workspace.Proximity to move to (excludes pickaxes/potions)",
    Callback = function(value)
        selectedProximityTarget = value
    end
})

do
    local initial = getProximityItems()
    if initial and #initial > 0 then
        selectedProximityTarget = initial[1]
        pcall(function()
            if proximityDropdown and proximityDropdown.SetValue then proximityDropdown:SetValue(selectedProximityTarget) end
        end)
    end
end

local moveToProxEnabled = false
local moveToProxConnection = nil
local proximityFixedSpeed = 40 -- studs per second (fixed speed)

local function tweenToProximityPart(part)
    if not part then return false end
    local player = Players.LocalPlayer
    if not player or not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    -- Build target position slightly above the part for stability
    local targetPos = part.Position + Vector3.new(0, 2, 0)
    local distance = (hrp.Position - targetPos).Magnitude
    local duration = math.max(0.05, distance / proximityFixedSpeed)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    -- Disable collisions while moving to avoid getting stuck
    pcall(function() hrp.CanCollide = false hrp.Anchored = false end)

    local lookVec = hrp.CFrame.LookVector
    local targetCFrame = CFrame.new(targetPos, targetPos + lookVec)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    currentTween = tween
    tween:Play()
    tween.Completed:Wait()
    currentTween = nil

    -- Anchor at destination and keep collisions disabled for stability
    pcall(function() hrp.Anchored = true hrp.CanCollide = false end)
    return true
end

local function startMoveToProximity()
    if moveToProxConnection then moveToProxConnection:Disconnect() moveToProxConnection = nil end
    moveToProxConnection = RunService.Heartbeat:Connect(function()
        if not moveToProxEnabled then return end
        pcall(function()
            if not selectedProximityTarget then
                moveToProxEnabled = false
                return
            end
            local targetPart = getProximityTargetByName(selectedProximityTarget)
            if targetPart then
                local player = Players.LocalPlayer
                local hrp = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - targetPart.Position).Magnitude
                    if dist > 3 then
                        tweenToProximityPart(targetPart)
                    end
                    -- after arriving, disable the toggle so it doesn't keep moving
                    moveToProxEnabled = false
                    stopMoveToProximity()
                    return
                end
            else
                -- if target cannot be found, stop
                moveToProxEnabled = false
                stopMoveToProximity()
                return
            end
        end)
    end)
end

local function stopMoveToProximity()
    if moveToProxConnection then
        moveToProxConnection:Disconnect()
        moveToProxConnection = nil
    end
    pcall(cancelCurrentTween)
    -- restore collisions/unanchor
    pcall(function()
        local player = Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                -- Anchor, move up, set upright, then unanchor
                humanoidRootPart.Anchored = true
                local pos = humanoidRootPart.Position
                humanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y + 8, pos.Z)
                task.wait(0.1)
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)
                humanoidRootPart.Anchored = false
                humanoidRootPart.CanCollide = true
            end
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.AutoRotate = true
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)
    -- Extra safety: re-apply restore a few times to ensure other code doesn't re-freeze player
    pcall(function()
        task.spawn(function()
            local player = Players.LocalPlayer
            for i = 1, 4 do
                if not player or not player.Character then break end
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                pcall(function()
                    if hrp then hrp.Anchored = false hrp.CanCollide = true end
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid.AutoRotate = true
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end)
                task.wait(0.12)
            end
        end)
    end)
end

-- UI Toggle
GoToArea:AddToggle("MoveToProximityToggle", {
    Text = "Move To NPC",
    Default = false,
    Tooltip = "Tween to the selected object inside workspace.Proximity (fixed speed)",
    Callback = function(value)
        moveToProxEnabled = value
        if value then
            if not selectedProximityTarget then
                moveToProxEnabled = false
                return
            end
            startMoveToProximity()
        else
            stopMoveToProximity()
        end
    end
})

--================================================= Perfect Forge Automation =================================================--
local perfectForgeEnabled = false
local perfectForgeConnection = nil
local forgeRF = nil

-- Try to locate the Forge ChangeSequence RF safely
pcall(function()
    local rep = game:GetService("ReplicatedStorage")
    local shared = rep:WaitForChild("Shared", 2)
    if shared then
        local packages = shared:FindFirstChild("Packages")
        if packages then
            local knit = packages:FindFirstChild("Knit")
            if knit then
                local ok, requireKnit = pcall(function() return require(packages.Knit) end)
            end
        end
        local services = shared:FindFirstChild("Packages") -- not used, but keep safety
    end
    local rfCandidate = rep:FindFirstChild("Shared") and rep.Shared:FindFirstChild("Packages") and rep.Shared.Packages:FindFirstChild("Knit") and nil
    -- direct path used in game code
    local ok, svc = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Shared", 2)
            :WaitForChild("Packages", 2)
            :WaitForChild("Knit", 2)
    end)
    -- Instead of requiring Knit, look for the RF directly under expected path
    local ok2, rfTry = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Shared", 2)
            :WaitForChild("Packages", 2)
            :WaitForChild("Knit", 2)
    end)
    -- Best-effort: try known full path to ForgeService RF
    local ok3, rfFound = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Shared", 2)
            :WaitForChild("Packages", 2)
            :WaitForChild("Knit", 2)
    end)
    -- Try the Service RF directly (common layout)
    pcall(function()
        local shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 2)
        local packages = shared and shared:FindFirstChild("Packages")
        if packages then
            local knitpkg = packages:FindFirstChild("Knit")
        end
        local rf = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 2)
            :WaitForChild("Packages", 2)
            :WaitForChild("Knit", 2)
    end)
    -- Finally, attempt to get the RF via the more direct known path used earlier
    pcall(function()
        local rfPath = game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
        if rfPath then
            local services = rfPath:FindFirstChild("Packages")
            -- fallback: scan ReplicatedStorage for ForgeService RF if present anywhere
            local candidate = nil
            for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if obj.Name == "ChangeSequence" and obj:IsA("RemoteFunction") then
                    candidate = obj
                    break
                end
            end
            if candidate then
                forgeRF = candidate
            end
        end
    end)
end)

local function tryInvokeForgeRF(action, args)
    if not forgeRF then
        -- attempt to find it dynamically each time as a fallback
        for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if obj.Name == "ChangeSequence" and obj:IsA("RemoteFunction") then
                forgeRF = obj
                break
            end
        end
    end
    if not forgeRF then return false end
    local ok, res = pcall(function()
        return forgeRF:InvokeServer(action, args)
    end)
    return ok, res
end

local function driveMeltGUI(g)
    -- best-effort: fill the bar and trigger completion visuals
    pcall(function()
        if g and g.Bar and g.Bar.Area then
            g.Bar.Area.Size = UDim2.fromScale(1, 1)
        end
        if g and g.Heater and g.Heater.Top then
            g.Heater.Top.Position = UDim2.fromScale(0.5, 0.5)
        end
        g.Visible = false
    end)
end

local function drivePourGUI(g)
    pcall(function()
        if g and g.Frame and g.Frame.Area then
            g.Frame.Area.Position = UDim2.fromScale(0, 0)
        end
        if g and g.Timer and g.Timer.Bar then
            g.Timer.Bar.Size = UDim2.fromScale(1, 0.65)
        end
        g.Visible = false
    end)
end

local function driveHammerGUI(g)
    pcall(function()
        if g and g.Frame and g.Frame.Timer and g.Frame.Timer.Bar then
            g.Frame.Timer.Bar.Size = UDim2.fromScale(1, 0.65)
        end
        -- simulate clicking required notes by firing the RemoteFunction if present
        for _, rf in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if rf:IsA("RemoteFunction") and rf.Name:match("Hammer") then
                pcall(function() rf:InvokeServer({}) end)
            end
        end
        g.Visible = false
    end)
end

local function startPerfectForge()
    if perfectForgeConnection then perfectForgeConnection:Disconnect() perfectForgeConnection = nil end
    perfectForgeConnection = RunService.Heartbeat:Connect(function()
        if not perfectForgeEnabled then return end
        pcall(function()
            local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
            if not playerGui then return end

            local forgeGui = playerGui:FindFirstChild("Forge")
            if not forgeGui then return end

            -- Melt
            local melt = forgeGui:FindFirstChild("MeltMinigame")
            if melt and melt.Visible then
                -- try server RF first with a reasonable ClientTime
                local ok = false
                ok = tryInvokeForgeRF("Melt", { ClientTime = workspace:GetServerTimeNow() })
                if not ok then
                    driveMeltGUI(melt)
                end
                return
            end

            -- Pour
            local pour = forgeGui:FindFirstChild("PourMinigame")
            if pour and pour.Visible then
                local ok = false
                ok = tryInvokeForgeRF("Pour", { ClientTime = workspace:GetServerTimeNow() })
                if not ok then
                    drivePourGUI(pour)
                end
                return
            end

            -- Hammer
            local hammer = forgeGui:FindFirstChild("HammerMinigame")
            if hammer and hammer.Visible then
                local ok = false
                ok = tryInvokeForgeRF("Hammer", { ClientTime = workspace:GetServerTimeNow() })
                if not ok then
                    driveHammerGUI(hammer)
                end
                return
            end
        end)
    end)
end

local function stopPerfectForge()
    if perfectForgeConnection then
        perfectForgeConnection:Disconnect()
        perfectForgeConnection = nil
    end
end

AutoForge:AddToggle("PerfectForgeToggle", {
    Text = "Perfect Forge",
    Default = false,
    Tooltip = "Automatically complete Forge minigames when they appear on screen",
    Callback = function(value)
        perfectForgeEnabled = value
        if value then
            startPerfectForge()
        else
            stopPerfectForge()
        end
    end
})

    ---=======================================Settings Features=======================================---
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
local TweenService = game:GetService("TweenService")
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
    Tooltip = "Set your character's walk speed (affects movement)",
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
    Tooltip = "Movement speed applied while flying",
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
    Tooltip = "Toggle a simple fly mode (use WASD to move, Space/Ctrl to go up/down)",
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

Settings:AddToggle("AutoHideUI", {
    Text = "Auto Hide UI",
    Default = config.AutoHideUIEnabled or false,
    Tooltip = "Automatically hide the script UI when the script loads",
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
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Decal") or obj:IsA("Texture") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Type = "Decal", Transparency = obj.Transparency}
                        end
                        obj.Transparency = 1
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Type = "Emitter", Enabled = obj.Enabled}
                        end
                        if pcall(function() obj.Enabled = false end) then end
                    elseif obj:IsA("Humanoid") then
                        -- stop currently playing animation tracks and remember them
                        if originalFPSValues[obj] == nil then
                            local playing = {}
                            for _, track in ipairs(obj:GetPlayingAnimationTracks()) do
                                table.insert(playing, track)
                                pcall(function() track:Stop() end)
                            end
                            originalFPSValues[obj] = {Type = "Humanoid", Tracks = playing}
                        end
                    elseif obj:IsA("MeshPart") then
                        local rfKey = tostring(obj).."_RenderFidelity"
                        if originalFPSValues[rfKey] == nil then
                            originalFPSValues[rfKey] = {Type = "RenderFidelity", RenderFidelity = obj.RenderFidelity}
                        end
                        pcall(function()
                            if obj.RenderFidelity ~= nil and obj:IsDescendantOf(workspace)
                                and (not obj:IsA("SolidModel")) and (not obj:IsA("UnionOperation")) then
                                obj.RenderFidelity = Enum.RenderFidelity.Performance
                            end
                        end)
                    elseif obj:IsA("Sound") then
                        if originalFPSValues[obj] == nil then
                            originalFPSValues[obj] = {Type = "Sound", Volume = obj.Volume}
                        end
                        obj.Volume = 0
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
                        local rfKey = tostring(obj).."_RenderFidelity"
                        if originalFPSValues[rfKey] == nil then
                            originalFPSValues[rfKey] = {Type = "RenderFidelity", RenderFidelity = obj.RenderFidelity}
                        end
                        pcall(function()
                            if obj.RenderFidelity ~= nil and obj:IsDescendantOf(workspace)
                                and (not obj:IsA("SolidModel")) and (not obj:IsA("UnionOperation")) then
                                obj.RenderFidelity = Enum.RenderFidelity.Performance
                            end
                        end)
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
                            pcall(function()
                                if typeof(obj) == "userdata" and obj and obj:IsA("BasePart")
                                    and (not obj:IsA("SolidModel")) and (not obj:IsA("UnionOperation")) then
                                    obj.RenderFidelity = props.RenderFidelity
                                end
                            end)
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

-- Anti-AFK Toggle (prevents idle kick by simulating controller input)
Settings:AddToggle("AntiAFKToggle", {
    Text = "Anti AFK",
    Default = config.AntiAFKToggle or false,
    Tooltip = "Prevent being kicked for idling by simulating input",
    Callback = function(value)
        config.AntiAFKToggle = value
        local Players = game:GetService("Players")
        local vu = game:GetService("VirtualUser")
        -- Always ensure previous connection is cleared
        pcall(function()
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
        end)

        if value then
            -- Connect to Idled and simulate a simple click to prevent AFK kick
            pcall(function()
                antiAFKConnection = Players.LocalPlayer.Idled:Connect(function()
                    pcall(function()
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new(0, 0))
                    end)
                end)
            end)
        end
    end
})


-- White/Black Screen FPS Toggle
local fpsScreenOverlay = nil
Settings:AddToggle("FPSScreenOverlay", {
    Text = "White/Black Screen (Max FPS)",
    Default = false,
    Tooltip = "Cover the screen with a solid color to improve FPS (reduces rendering)",
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
                        pcall(function()
                            if typeof(obj) == "userdata" and obj and obj:IsA("BasePart")
                                and (not obj:IsA("SolidModel")) and (not obj:IsA("UnionOperation")) then
                                obj.RenderFidelity = props.RenderFidelity
                            end
                        end)
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
    -- Disconnect Anti-AFK connection if present
    pcall(function()
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
            print("🔒 Anti-AFK disconnected")
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
    -- Additional cleanup: stop feature loops, disconnect and nil connections, restore player state, disable overrides
    pcall(function()
        -- Stop auto-buy/auto-sell/mining/enhance/forge loops and their connections
        pcall(function()
            buyPickaxeEnabled = false
            if buyPickaxeConnection then buyPickaxeConnection:Disconnect() buyPickaxeConnection = nil end
            if stopBuyPickaxe then pcall(stopBuyPickaxe) end
        end)
        pcall(function()
            buyPotionEnabled = false
            if buyPotionConnection then buyPotionConnection:Disconnect() buyPotionConnection = nil end
            if stopBuyPotion then pcall(stopBuyPotion) end
        end)
        pcall(function()
            if sellOreConnection then sellOreConnection:Disconnect() sellOreConnection = nil end
            if stopAutoSell then pcall(stopAutoSell) end
        end)
        pcall(function()
            if miningConnection then miningConnection:Disconnect() miningConnection = nil end
            if stopAutoMining then pcall(stopAutoMining) end
        end)
        pcall(function()
            if enemyConnection then enemyConnection:Disconnect() enemyConnection = nil end
            if stopAutoFarming then pcall(stopAutoFarming) end
        end)
        pcall(function()
            if perfectForgeConnection then perfectForgeConnection:Disconnect() perfectForgeConnection = nil end
            if stopPerfectForge then pcall(stopPerfectForge) end
        end)
        -- Disable Auto Enhance override if applied
        pcall(function()
            if disableAutoEnhance then pcall(disableAutoEnhance) end
            autoEnhanceEnabled = false
        end)

        -- Ensure fly is disabled and its resources cleaned
        pcall(function()
            if disableFly then pcall(disableFly) end
            flyEnabled = false
        end)

        -- Restore local player's humanoid state and unanchor root
        pcall(function()
            local pl = game:GetService("Players").LocalPlayer
            if pl and pl.Character then
                local humanoid = pl.Character:FindFirstChildOfClass("Humanoid")
                local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Anchored = false
                    hrp.CanCollide = true
                    hrp.CFrame = CFrame.new(hrp.Position)
                end
                if humanoid then
                    humanoid.PlatformStand = false
                    humanoid.AutoRotate = true
                    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                end
            end
        end)

        -- Clear global UI flags
        pcall(function() _G.FPSScreenOverlayColor = nil _G.FPSScreenOverlayActive = nil end)
    end)
    
    print("✅ Seisen Hub completely unloaded and cleaned up!")
end)

-- Load the autoload config after all UI elements are setup
SaveManager:LoadAutoloadConfig()
