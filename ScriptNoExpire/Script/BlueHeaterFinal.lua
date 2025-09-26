game.StarterGui:SetCore("SendNotification", {
    Title = "Seisen Hub";
    Text = "Blue Heater Script Loaded";
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

--// CONFIG SAVE/LOAD SYSTEM
local HttpService = game:GetService("HttpService")
local configFolder = "SeisenHub"
local configFile = configFolder .. "/seisen_hub_sb3.txt"

if not isfolder(configFolder) then
    makefolder(configFolder)
end

-- Default config
local config = {
    auraEnabled = false,
    auraRange = 15,
    auraDelay = 0.1,
    autoFarmEnabled = false,
    autoSkillEnabled = false,
    selectedEntityName = nil,
    customCursorEnabled = true,
    uiScale = "100%",
    watermarkPosition = {XScale = 0, XOffset = 10, YScale = 0, YOffset = 100},
    autoCollectMaterialEnabled = false,
    selectedMaterialType = nil,
    fastStaminaRegenEnabled = false,
    walkSpeed = 16,
    highlightEnabled = true,
    autoStartDungeon = false,
    autoEquipWeaponEnabled = false
    ,autoSkeletonKingEnabled = false
    ,autoSkeletonKingDistance = 5
}


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


-- Save helper
local function saveConfig()
    writefile(configFile, HttpService:JSONEncode(config))
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
local Window = Library:CreateWindow({
    Title = "Seisen Hub",
    Footer = "Blue Heater",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Center = true,
    Icon = 125926861378074,
    AutoShow = true,
    ShowCustomCursor = config.customCursorEnabled
})
local MainTab = Window:AddTab("Main", "home")
local Misc = Window:AddTab("Miscellaneous", "cog")
local SettingsTab = Window:AddTab("Settings", "settings")
local UISettingsGroup = SettingsTab:AddLeftGroupbox("UI Customization", "paintbrush")
local InfoGroup = SettingsTab:AddRightGroupbox("Script Information", "info")


ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenHub")
ThemeManager:ApplyToTab(SettingsTab)

-- Restore information display
InfoGroup:AddLabel("Script by: Seisen")
InfoGroup:AddLabel("Version: 2.5.0")
InfoGroup:AddLabel("Game: Blue Heater")

InfoGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/F4sAf6z8Ph")
    print("Copied Discord Invite!")
end)
local CombatGroup = MainTab:AddLeftGroupbox("Combat", "sword")
local SubCombat = MainTab:AddLeftGroupbox("Sub-Combat", "swords")
local Dungeon = MainTab:AddRightGroupbox("Dungeon", "heart-minus")
local DungeonTeleportGroup = MainTab:AddRightGroupbox("Dungeon UI", "map")
local MaterialGroup = MainTab:AddRightGroupbox("Auto Collect Material", "database-backup")
local TeleportGroup = Misc:AddLeftGroupbox("Teleport", "aperture")



DungeonTeleportGroup:AddButton("Enter Dungeon (Pad): Cellar", function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local DungeonPadTouched = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("DungeonPadTouched")
    DungeonPadTouched:Fire("Cellar")
end)

DungeonTeleportGroup:AddButton("Enter Dungeon (Pad): Mines", function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local DungeonPadTouched = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("DungeonPadTouched")
    DungeonPadTouched:Fire("Mines")
end)

DungeonTeleportGroup:AddButton("Enter Dungeon (Pad): Temple Ruins", function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local DungeonPadTouched = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("DungeonPadTouched")
    DungeonPadTouched:Fire("Temple Ruins")
end)
TeleportGroup:AddButton("Teleport to Tower", function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(947.1397094726562, -251.82017517089844, -1257.157958984375)
end)
TeleportGroup:AddButton("Tower Nun", function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-2978.750244140625, -24.449262619018555, 843.4796142578125)
end)
TeleportGroup:AddButton("Teleport to Skeleton King", function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-2663.287109375, -34.61481857299805, -50.10152053833008)
end)
TeleportGroup:AddButton("Teleport Yamu", function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-868.4031982421875, -295.54888916015625, -2514.129638671875)
end)
TeleportGroup:AddButton("Teleport Bell Tower", function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-3117.162353515625, -131.33082580566406, 2859.88671875)
end)
local StaminaGroup = Misc:AddRightGroupbox("Misc", "bolt")
-- Auto Skeleton King distance slider
local autoSkeletonKingDistance = config.autoSkeletonKingDistance or 5
local AutoSkeletonKingDistanceSlider = SubCombat:AddSlider("AutoSkeletonKingDistanceSlider", {
    Text = "Skeleton King TP Distance",
    Min = 5,
    Max = 50,
    Default = config.autoSkeletonKingDistance or 5,
    Suffix = " studs",
    Callback = function(value)
        autoSkeletonKingDistance = value
        config.autoSkeletonKingDistance = value
        saveConfig()
    end
})
AutoSkeletonKingDistanceSlider:SetValue(config.autoSkeletonKingDistance or 5)
-- Auto Skeleton King toggle
local autoSkeletonKingEnabled = config.autoSkeletonKingEnabled or false
local autoSkeletonKingPositions = {
    Vector3.new(1, 0, 0),   -- right
    Vector3.new(-1, 0, 0),  -- left
    Vector3.new(0, 0, 1),   -- front
    Vector3.new(0, 0, -1),  -- behind
}
local autoSkeletonKingIndex = 1
SubCombat:AddToggle("AutoSkeletonKingToggle", {
    Text = "Auto Skeleton King",
    Default = config.autoSkeletonKingEnabled or false,
    Callback = function(enabled)
        autoSkeletonKingEnabled = enabled
        config.autoSkeletonKingEnabled = enabled
        saveConfig()
    end
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if autoSkeletonKingEnabled then
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:FindFirstChild("HumanoidRootPart")
            -- Noclip while enabled
            if character then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            -- Find Skeleton King in workspace.SpawnedEntities
            local skeletonKingHRP = nil
            if workspace:FindFirstChild("SpawnedEntities") then
                local skEntity = workspace.SpawnedEntities:FindFirstChild("Skeleton King")
                if skEntity and skEntity:FindFirstChild("HumanoidRootPartCollision") then
                    skeletonKingHRP = skEntity.HumanoidRootPartCollision
                end
            end
            if skeletonKingHRP and hrp then
                -- Use BodyPosition for persistent magnet effect (like autofarm)
                if not hrp:FindFirstChild("AutoSK_BodyPosition") then
                    local bp = Instance.new("BodyPosition")
                    bp.Name = "AutoSK_BodyPosition"
                    bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bp.D = 1000
                    bp.P = 10000
                    bp.Parent = hrp
                end
                local bp = hrp:FindFirstChild("AutoSK_BodyPosition")
                local offsetDir = autoSkeletonKingPositions[autoSkeletonKingIndex]
                local offset = offsetDir * autoSkeletonKingDistance
                local targetPos = skeletonKingHRP.Position + offset
                bp.Position = targetPos
                autoSkeletonKingIndex = autoSkeletonKingIndex % #autoSkeletonKingPositions + 1
                task.wait(1)
            else
                -- Remove BodyPosition if not following
                if hrp and hrp:FindFirstChild("AutoSK_BodyPosition") then
                    hrp.AutoSK_BodyPosition:Destroy()
                end
            end
        end
    end
end)


-- Ensure UI toggle matches config on load
task.defer(function()
    if config.AutoHideUIEnabled and Library and Library.Toggle then
        if UISettingsGroup and UISettingsGroup.SetValue then
            UISettingsGroup:SetValue("AutoHideUIToggle", true)
        end
        Library:Toggle()
        Library.ShowCustomCursor = false
    end
end)

-- Fly script variables
local flyEnabled = false
local flyConnection = nil
local flyBodyVelocity = nil

local autoCollectOrbEnabled = config.autoCollectOrbEnabled or false

local infiniteStaminaEnabled = config.infiniteStaminaEnabled or false
local auraEnabled = config.auraEnabled
local auraRange = config.auraRange
local auraDelay = config.auraDelay
local selectedEntityName = config.selectedEntityName
local autoFarmEnabled = config.autoFarmEnabled
local autoFarmDistance = config.autoFarmDistance or 10
local autoFarmPositionType = config.autoFarmPositionType or "Above"
local autoSkillEnabled = config.autoSkillEnabled
local selectedStat = config.selectedStat
local lastEntity, bodyVelocity = nil, nil
local autoCollectMaterialEnabled = config.autoCollectMaterialEnabled
local selectedMaterialType = config.selectedMaterialType
local autoHideUIEnabled = config.autoHideUIEnabled or false
local autoStartDungeonEnabled = config.autoStartDungeon or false
-- Load fast stamina regen state
fastStaminaRegenEnabled = config.fastStaminaRegenEnabled or false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local spawnedEntitiesFolder = workspace:WaitForChild("SpawnedEntities", 9e9)
local multiEntityHitRemote = ReplicatedStorage:WaitForChild("PlayerEvents", 9e9):WaitForChild("MultiEntityHit", 9e9)
local replicaRemote = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 9e9):WaitForChild("Replica_ReplicaSignal", 9e9)
-- Helper to get entity names for dropdown
local function getEntityNames()
    local names = {}
    if workspace:FindFirstChild("SpawnedEntities") then
        for _, entity in ipairs(workspace.SpawnedEntities:GetChildren()) do
            if entity.Name and not table.find(names, entity.Name) then
                table.insert(names, entity.Name)
            end
        end
    end
    return names
end
local function getMaterialTypes()
    local types = {}
    if workspace:FindFirstChild("Materials") then
        for _, material in pairs(workspace.Materials:GetChildren()) do
            if material.Name and not table.find(types, material.Name) then
                table.insert(types, material.Name)
            end
        end
    end
    return types
end
local AutoFarmToggle = CombatGroup:AddToggle("AutoFarmToggle", {
    Text = "Auto Farm",
    Default = config.autoFarmEnabled,
    Callback = function(value)
        autoFarmEnabled = value
        config.autoFarmEnabled = value
        saveConfig()
    end
})

local entityHighlights = {}
local entityLabels = {}
local highlightEnabled = true
highlightEnabled = config.highlightEnabled
local HighlightToggle = CombatGroup:AddToggle("HighlightToggle", {
    Text = "Highlight Selected Entity",
    Default = config.highlightEnabled,
    Callback = function(value)
        highlightEnabled = value
        config.highlightEnabled = value
        saveConfig()
    end
})

-- Auto Equip Weapon Toggle
local autoEquipEnabled = config.autoEquipWeaponEnabled or false
SubCombat:AddToggle("AutoEquipWeaponToggle", {
    Text = "Auto Equip Weapon",
    Default = config.autoEquipWeaponEnabled or false,
    Callback = function(enabled)
        autoEquipEnabled = enabled
        config.autoEquipWeaponEnabled = enabled
        saveConfig()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local ManageWeapon = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("ManageWeapon")
        -- true = equip, false = unequip
        ManageWeapon:InvokeServer(enabled)
    end
})

-- Auto start auto equip weapon on load
task.defer(function()
    if config.autoEquipWeaponEnabled ~= nil then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local ManageWeapon = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("ManageWeapon")
        ManageWeapon:InvokeServer(config.autoEquipWeaponEnabled)
    end
end)

local AutoSkillToggle = SubCombat:AddToggle("AutoSkillToggle", {
    Text = "Auto Skill",
    Default = config.autoSkillEnabled,
    Callback = function(value)
        autoSkillEnabled = value
        config.autoSkillEnabled = value
        saveConfig()
    end
})
local KillAuraToggle = SubCombat:AddToggle("KillAuraToggle", {
    Text = "Melee Kill Aura",
    Default = config.auraEnabled,
    Callback = function(value)
        auraEnabled = value
        config.auraEnabled = value
        saveConfig()
    end
})
-- Add Auto Collect Chest toggle below Kill Aura
local autoCollectChestEnabled = config.autoCollectChestEnabled or false

-- Move Auto Collect Chest toggle to Misc groupbox (StaminaGroup), above Infinite Stamina
local AutoCollectChestToggle = StaminaGroup:AddToggle("AutoCollectChestToggle", {
    Text = "Auto Collect Chest",
    Default = autoCollectChestEnabled,
    Callback = function(value)
        autoCollectChestEnabled = value
        config.autoCollectChestEnabled = value
        saveConfig()
    end
})
-- Dropdown for Auto Farm Position
CombatGroup:AddDropdown("AutoFarmPositionDropdown", {
    Text = "Auto Farm Position",
    Values = {"Behind", "Above", "Below"},
    Default = ({Behind=1, Above=2, Below=3})[autoFarmPositionType] or 2,
    Callback = function(value)
        autoFarmPositionType = value
        config.autoFarmPositionType = value
        saveConfig()
    end
})

local AutoFarmDistanceSlider = CombatGroup:AddSlider("AutoFarmDistanceSlider", {
    Text = "Auto Farm Distance",
    Min = 2,
    Max = 100,
    Default = config.autoFarmDistance or 10,
    Suffix = " studs",
    Callback = function(value)
        autoFarmDistance = value
        config.autoFarmDistance = value
        saveConfig()
    end
})

-- Set slider value from config on load (after creation)
AutoFarmDistanceSlider:SetValue(config.autoFarmDistance or 10)

local KillAuraRangeSlider = SubCombat:AddSlider("KillAuraRangeSlider", {
    Text = "Kill Aura Range",
    Min = 20,
    Max = 100,
    Default = config.auraRange or 15,
    Suffix = " studs",
    Callback = function(value)
        auraRange = value
        config.auraRange = value
        saveConfig()
    end
})

KillAuraRangeSlider:SetValue(config.auraRange or 15)
local EntityDropdown = CombatGroup:AddDropdown("EntityDropdown", {
    Text = "Select Entity",
    Values = getEntityNames(),
    Default = selectedEntityName and table.find(getEntityNames(), selectedEntityName) or 1,
    Callback = function(value)
        selectedEntityName = value
        config.selectedEntityName = value
        saveConfig()
    end
})


local function updateSelectedEntityHighlights()
    -- Remove highlights/labels from entities that no longer exist or no longer match
    for entity, highlight in pairs(entityHighlights) do
        local shouldRemove = not entity or not entity.Parent or not workspace.SpawnedEntities:FindFirstChild(entity.Name) or entity.Name ~= selectedEntityName or not highlightEnabled
        if shouldRemove then
            if highlight then highlight:Destroy() end
            entityHighlights[entity] = nil
            -- Remove fake HRP if it was created by us (named FakeHRP)
            local fakehrp = entity:FindFirstChild("FakeHRP")
            if fakehrp and fakehrp.Transparency == 1 and fakehrp.Anchored and fakehrp.CanCollide == false and fakehrp.Size == Vector3.new(2,2,1) then
                fakehrp:Destroy()
            end
        end
    end
    for entity, label in pairs(entityLabels) do
        local shouldRemove = not entity or not entity.Parent or not workspace.SpawnedEntities:FindFirstChild(entity.Name) or entity.Name ~= selectedEntityName or not highlightEnabled
        if shouldRemove then
            if label then label:Destroy() end
            entityLabels[entity] = nil
        end
    end
    -- Add highlight/label and ensure fake HRP for all entities matching selectedEntityName
    if highlightEnabled and selectedEntityName and workspace:FindFirstChild("SpawnedEntities") then
        for _, entity in ipairs(workspace.SpawnedEntities:GetChildren()) do
            if entity:IsA("Model") and entity.Name == selectedEntityName then
                -- Ensure HumanoidRootPart exists
                local hrp = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("FakeHRP")
                if not hrp then
                    -- Create a fake HRP at the model's pivot or first BasePart
                    local fallbackPart = nil
                    for _, part in ipairs(entity:GetChildren()) do
                        if part:IsA("BasePart") then fallbackPart = part; break end
                    end
                    hrp = Instance.new("Part")
                    hrp.Name = "FakeHRP"
                    hrp.Size = Vector3.new(2,2,1)
                    hrp.Anchored = true
                    hrp.CanCollide = false
                    hrp.Transparency = 1
                    hrp.CFrame = fallbackPart and fallbackPart.CFrame or entity:GetPivot()
                    hrp.Parent = entity
                end
                -- Highlight
                if not entityHighlights[entity] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "SeisenHubEntityHighlight"
                    highlight.FillColor = Color3.fromRGB(125, 85, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Adornee = entity
                    highlight.Parent = entity
                    entityHighlights[entity] = highlight
                end
                -- Floating name label
                if hrp and not entityLabels[entity] then
                    local label = Instance.new("BillboardGui")
                    label.Name = "SeisenHubEntityLabel"
                    label.Adornee = hrp
                    label.Size = UDim2.new(0, 120, 0, 24)
                    label.AlwaysOnTop = true
                    label.Parent = hrp
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = entity.Name
                    nameLabel.TextColor3 = Color3.fromRGB(125, 85, 255)
                    nameLabel.TextStrokeTransparency = 0.5
                    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.TextScaled = true
                    nameLabel.Parent = label
                    entityLabels[entity] = label
                end
            end
        end
    end
end

-- Update highlight/label in real time
task.spawn(function()
    local lastSelected = nil
    while true do
        task.wait(0.5)
        if selectedEntityName ~= lastSelected then
            -- Remove all highlights/labels if selection changed
            for entity, highlight in pairs(entityHighlights) do if highlight then highlight:Destroy() end end
            for entity, label in pairs(entityLabels) do if label then label:Destroy() end end
            entityHighlights = {}
            entityLabels = {}
            lastSelected = selectedEntityName
        end
        updateSelectedEntityHighlights()
    end
end)

-- Real-time update for EntityDropdown values
task.spawn(function()
    local lastEntities = {}
    while true do
        task.wait(1)
        local currentEntities = getEntityNames()
        -- Only update if the list changed
        local changed = false
        if #currentEntities ~= #lastEntities then
            changed = true
        else
            for i, v in ipairs(currentEntities) do
                if v ~= lastEntities[i] then
                    changed = true
                    break
                end
            end
        end
        if changed then
            EntityDropdown:SetValues(currentEntities)
            lastEntities = currentEntities
        end
    end
end)


-- Mage Kill Aura
local mageAuraEnabled = false
local RANGE = 60         -- max distance to target
local HITS_PER_SEC = 2   -- how many attacks per second
local MIN_TRAVEL = 12    -- minimum projectile travel distance
local STEP = 1 / HITS_PER_SEC

local MageKillAuraToggle = SubCombat:AddToggle("MageKillAuraToggle", {
    Text = "Mage Kill Aura",
    Default = false,
    Callback = function(val)
        mageAuraEnabled = val
    end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StaffAttack = ReplicatedStorage:WaitForChild("PlayerEvents", 9e9)
    :WaitForChild("WeaponClassEvents", 9e9)
    :WaitForChild("StaffAttack", 9e9)
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local function isAliveModel(model)
    local hum = model and model:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

task.spawn(function()
    while true do
        task.wait(STEP)
        if not mageAuraEnabled then continue end
        local char = lp.Character
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        if not myHRP then continue end
        local best, bestHRP
        local bestDist = math.huge
        local container = workspace:FindFirstChild("SpawnedEntities")
        if not container then continue end
        for _, m in ipairs(container:GetChildren()) do
            local ehrp = m:FindFirstChild("HumanoidRootPart")
            if ehrp and isAliveModel(m) then
                local d = (ehrp.Position - myHRP.Position).Magnitude
                if d < RANGE and d < bestDist then
                    best, bestHRP, bestDist = m, ehrp, d
                end
            end
        end
        if bestHRP then
            local startCFrame = myHRP.CFrame
            local dir = (bestHRP.Position - startCFrame.Position)
            local distance = dir.Magnitude
            if distance < MIN_TRAVEL then
                dir = dir.Magnitude > 0 and dir.Unit * MIN_TRAVEL or myHRP.CFrame.LookVector * MIN_TRAVEL
            end
            local hitPos = startCFrame.Position + dir
            StaffAttack:FireServer(startCFrame, hitPos)
        end
    end
end)


local AutoCollectMaterialToggle = MaterialGroup:AddToggle("AutoCollectMaterialToggle", {
    Text = "Auto Collect Material",
    Default = config.autoCollectMaterialEnabled,
    Callback = function(value)
        autoCollectMaterialEnabled = value
        config.autoCollectMaterialEnabled = value
        saveConfig()
    end
})
local MaterialTypeDropdown = MaterialGroup:AddDropdown("MaterialTypeDropdown", {
    Text = "Select Material Type",
    Values = getMaterialTypes(),
    Default = selectedMaterialType and table.find(getMaterialTypes(), selectedMaterialType) or 1,
    Callback = function(value)
        selectedMaterialType = value
        config.selectedMaterialType = value
        saveConfig()
    end
})


local function setInfiniteStamina(value)
    -- Set stamina for all objects in workspace that have a Stamina value
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:FindFirstChild("Values") and obj.Values:FindFirstChild("Stamina") then
            obj.Values.Stamina.Value = value
        end
    end
end


-- Optional: Keep stamina infinite while enabled
task.spawn(function()
    while true do
        task.wait(1)
        if infiniteStaminaEnabled then
            setInfiniteStamina(1000000)
        end
    end
end)

-- Fast Stamina Regeneration Logic
task.spawn(function()
    while true do
        task.wait(0.02) -- faster tick
        if fastStaminaRegenEnabled then
            for _, staminaObj in ipairs(workspace:GetChildren()) do
                if staminaObj:FindFirstChild("Values") and staminaObj.Values:FindFirstChild("Stamina") then
                    local stamina = staminaObj.Values.Stamina
                    local maxStamina = stamina:GetAttribute("Max") or 100
                    local regenRate = ((staminaObj:GetAttribute("StaminaRegeneration") or 50) / 100) * 20 -- super fast multiplier
                    if stamina.Value < maxStamina then
                        local increment = 0.02 * regenRate * maxStamina
                        stamina.Value = math.min(stamina.Value + increment, maxStamina)
                    end
                end
            end
        end
    end
end)

-- Helper to get names for dropdowns (sorted alphabetically)
local function getRespawnPointNames()
    local names = {}
    for _, obj in pairs(workspace.RespawnPoints:GetChildren()) do
        if obj.Name and not table.find(names, obj.Name) then
            table.insert(names, obj.Name)
        end
    end
    table.sort(names) -- sort alphabetically
    return names
end

local function getRegionNames()
    local names = {}
    for _, obj in pairs(workspace.Regions:GetChildren()) do
        if obj.Name and not table.find(names, obj.Name) then
            table.insert(names, obj.Name)
        end
    end
    table.sort(names)
    return names
end

local function getNPCNames()
    local names = {}
    if workspace:FindFirstChild("NPCs") then
        for _, obj in pairs(workspace.NPCs:GetChildren()) do
            if obj.Name and not table.find(names, obj.Name) then
                table.insert(names, obj.Name)
            end
        end
    end
    table.sort(names)
    return names
end


-- Teleport to RespawnPoint
TeleportGroup:AddDropdown("RespawnPointDropdown", {
    Text = "Teleport to RespawnPoint",
    Values = workspace:FindFirstChild("RespawnPoints") and getRespawnPointNames() or {},
    Callback = function(value)
        if not workspace:FindFirstChild("RespawnPoints") then
            Library:Notify({
                Title = "Teleport Error",
                Text = "RespawnPoints folder not found in workspace. You may be in a different map.",
                Duration = 3,
                Type = "error"
            })
            return
        end
        local rp = workspace.RespawnPoints:FindFirstChild(value)
        if rp and rp:GetChildren()[7] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = rp:GetChildren()[7].CFrame
        end
    end
})

-- Teleport to Region
TeleportGroup:AddDropdown("RegionDropdown", {
    Text = "Teleport to Region",
    Values = getRegionNames(),
    Callback = function(value)
        local region = workspace.Regions:FindFirstChild(value)
        if region and region:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = region.CFrame
        end
    end
})

-- Teleport to NPC
TeleportGroup:AddDropdown("NPCDropdown", {
    Text = "Teleport to NPC",
    Values = workspace:FindFirstChild("NPCs") and getNPCNames() or {},
    Callback = function(value)
        if not workspace:FindFirstChild("NPCs") then
            Library:Notify({
                Title = "Teleport Error",
                Text = "NPCs folder not found in workspace. You may be in a different map.",
                Duration = 3,
                Type = "error"
            })
            return
        end
        local npc = workspace.NPCs:FindFirstChild(value)
        if npc and npc:IsA("Model") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if not hrp then
                -- Create a fake HumanoidRootPart for any NPC missing one
                hrp = Instance.new("Part")
                hrp.Name = "HumanoidRootPart"
                hrp.Size = Vector3.new(2,2,1)
                hrp.Anchored = true
                hrp.CanCollide = false
                hrp.Transparency = 1
                -- Position at the first BasePart or at the model's pivot
                local foundPart = nil
                for _, part in ipairs(npc:GetChildren()) do
                    if part:IsA("BasePart") then
                        foundPart = part
                        break
                    end
                end
                if foundPart then
                    hrp.CFrame = foundPart.CFrame
                else
                    hrp.CFrame = npc:GetPivot()
                end
                hrp.Parent = npc
            end
            -- Teleport to the HumanoidRootPart (real or fake)
            LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame
        end
    end
})

local AutoCollectOrbToggle = StaminaGroup:AddToggle("AutoCollectOrbToggle", {
    Text = "Auto Collect Orbs",
    Default = config.autoCollectOrbEnabled or false,
    Callback = function(value)
        autoCollectOrbEnabled = value
        config.autoCollectOrbEnabled = value
        saveConfig()
    end
})

local CustomCursor = UISettingsGroup:AddToggle("CustomCursor", {
    Text = "Custom Cursor",
    Default = config.customCursorEnabled, -- load saved state
    Callback = function(value)
        config.customCursorEnabled = value
        Library.ShowCustomCursor = value -- apply immediately
        saveConfig() -- save for next run
    end
})

UISettingsGroup:AddToggle("AutoHideUIToggle", {
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


local UIScale = UISettingsGroup:AddDropdown("UIScale", {
    Text = "UI Scale",
    Values = {"75%", "100%", "125%", "150%"},
    Default = table.find({"75%", "100%", "125%", "150%"}, config.uiScale) or 2,
    Callback = function(value)
        config.uiScale = value
        local scaleMap = {["75%"] = 75, ["100%"] = 100, ["125%"] = 125, ["150%"] = 150}
        Library:SetDPIScale(scaleMap[value])
        saveConfig()
    end
})
StaminaGroup:AddToggle("InfiniteStaminaToggle", {
    Text = "Enable Infinite Stamina",
    Default = config.infiniteStaminaEnabled or false,
    Callback = function(enabled)
        infiniteStaminaEnabled = enabled
        config.infiniteStaminaEnabled = enabled
        saveConfig()
        if enabled then
            setInfiniteStamina(1000000)
        else
            setInfiniteStamina(100) -- Restore stamina to normal
        end
    end
})
StaminaGroup:AddToggle("FastStaminaRegenToggle", {
    Text = "Fast Stamina Regeneration",
        Default = config.fastStaminaRegenEnabled or false,
        Callback = function(enabled)
            fastStaminaRegenEnabled = enabled
            config.fastStaminaRegenEnabled = enabled
            saveConfig()
        end
})

-- Quest Object ESP Toggle
local questObjectEspEnabled = config.questObjectEspEnabled or false
StaminaGroup:AddToggle("QuestObjectEspToggle", {
    Text = "Quest Object ESP",
    Default = questObjectEspEnabled,
    Callback = function(enabled)
        questObjectEspEnabled = enabled
        config.questObjectEspEnabled = enabled
        saveConfig()
    end
})



-- No Fall Damage Toggle
local noFallDamageEnabled = config.noFallDamageEnabled or false
StaminaGroup:AddToggle("NoFallDamageToggle", {
    Text = "No Fall Damage",
    Default = noFallDamageEnabled,
    Callback = function(enabled)
        noFallDamageEnabled = enabled
        config.noFallDamageEnabled = enabled
        saveConfig()
    end
})


-- Save WalkSpeed to config when changed
local walkSpeed = config.walkSpeed or 16
local WalkSpeedSlider = StaminaGroup:AddSlider("WalkSpeedSlider", {
    Text = "WalkSpeed",
    Min = 8,
    Max = 100,
    Default = walkSpeed,
    Suffix = "",
    Callback = function(value)
        walkSpeed = value
        config.walkSpeed = value
        saveConfig()
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
})
WalkSpeedSlider:SetValue(walkSpeed)

-- Persistent WalkSpeed logic: always set WalkSpeed if changed
local walkSpeedLoopEnabled = true
local walkSpeedConnection = nil
if walkSpeedConnection then walkSpeedConnection:Disconnect() end
walkSpeedConnection = game:GetService("RunService").Heartbeat:Connect(function()
    if walkSpeedLoopEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum.WalkSpeed ~= walkSpeed then
            hum.WalkSpeed = walkSpeed
        end
    end
end)

-- Add button below WalkSpeed slider to reset to normal speed
StaminaGroup:AddButton("Reset WalkSpeed", function()
    walkSpeed = 16
    config.walkSpeed = 16
    saveConfig()
    WalkSpeedSlider:SetValue(16)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end)

-- Add Fly toggle to Misc group
StaminaGroup:AddToggle("FlyToggle", {
    Text = "Enable Fly",
    Default = false,
    Callback = function(enabled)
        flyEnabled = enabled
        if not enabled then
            -- Remove BodyVelocity and disconnect
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            -- Restore gravity
            workspace.Gravity = 196.2
        else
            -- Enable fly
            local player = game:GetService("Players").LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            workspace.Gravity = 0
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBodyVelocity.Velocity = Vector3.new(0,0,0)
            flyBodyVelocity.Parent = hrp
            -- WASD and space/shift controls
            if flyConnection then flyConnection:Disconnect() end
            flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not flyEnabled or not hrp or not flyBodyVelocity then return end
                local move = Vector3.new(0,0,0)
                local uis = game:GetService("UserInputService")
                if uis:IsKeyDown(Enum.KeyCode.W) then move = move + hrp.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then move = move - hrp.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then move = move - hrp.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then move = move + hrp.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                if move.Magnitude > 0 then
                    move = move.Unit * 50 -- fly speed
                end
                flyBodyVelocity.Velocity = move
            end)
        end
    end
})

local allEntitiesLogicEnabled = config.allEntitiesLogicEnabled or false
local AllEntitiesLogicToggle = Dungeon:AddToggle("AllEntitiesLogicToggle", {
    Text = "Auto Farm Dungeon",
    Default = config.allEntitiesLogicEnabled or false,
    Callback = function(value)
        allEntitiesLogicEnabled = value
        config.allEntitiesLogicEnabled = value
        saveConfig()
        print("All Entities Logic toggled:", value)
    end
})




Dungeon:AddToggle("AutoStartDungeonToggle", {
    Text = "Auto Start Dungeon",
    Default = autoStartDungeonEnabled,
    Callback = function(value)
        autoStartDungeonEnabled = value
        config.autoStartDungeon = value
        saveConfig()
        if value then
            startAutoStartDungeonLoop()
        end
    end
})


-- Auto start dungeon loop
local autoStartDungeonLoopRunning = false
function startAutoStartDungeonLoop()
    if autoStartDungeonLoopRunning then return end
    autoStartDungeonLoopRunning = true
    task.spawn(function()
        while autoStartDungeonEnabled do
            local frame
            pcall(function()
                frame = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("MainGui")
                    and game:GetService("Players").LocalPlayer.PlayerGui.MainGui:FindFirstChild("InstanceCompleteFrame")
            end)
            if frame and frame.Visible then
                local replicaRemote = game:GetService("ReplicatedStorage")
                    :WaitForChild("ReplicaRemoteEvents", 9e9)
                    :WaitForChild("Replica_ReplicaSignal", 9e9)

                -- First PlayAgain (38)
                replicaRemote:FireServer(38, "PlayAgain")
                task.wait(0.1) -- small delay to prevent flood

                -- Second PlayAgain (43)
                replicaRemote:FireServer(43, "PlayAgain")
                task.wait(0.1) -- small delay to prevent flood

                -- Third PlayAgain (50)
                replicaRemote:FireServer(50, "PlayAgain")
                task.wait(0.1)

                -- Tower Playagain
                replicaRemote:FireServer(9, "PlayAgain")
                task.wait(0.1)

                -- Skeleton King
                replicaRemote:FireServer(9, "PlayAgain")
            end
            task.wait(2)
        end
        autoStartDungeonLoopRunning = false
    end)
end


-- Start loop on script execution if enabled
task.defer(function()
    if autoStartDungeonEnabled then
        startAutoStartDungeonLoop()
    end
end)

-- Settings for new logic
local autoFarmEnabled_all = false           -- toggle autofarm
local autoSkillEnabled_all = false          -- toggle auto skill
local auraEnabled_all = false               -- toggle kill aura

local autoFarmPositionType_all = "Above"  -- "Above", "Below", or "Behind"
-- Use the same autoFarmDistance for dungeon autofarm
local autoFarmDistance_all = nil

local auraRange_all = 100                   -- range for kill aura
local auraDelay_all = 0.01                  -- delay between kill aura hits (seconds)

local noclipConnection_all = nil
local bodyPosition_all = nil
local lastFarmedEntity_all = nil

-- Autofarm loop (target ALL entities with HealthOverhead)
task.spawn(function()
    while task.wait(0.1) do
        autoFarmEnabled_all = allEntitiesLogicEnabled
        if autoFarmEnabled_all and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            autoFarmDistance_all = autoFarmDistance
            -- Enable noclip
            if not noclipConnection_all then
                noclipConnection_all = game:GetService("RunService").Stepped:Connect(function()
                    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            end

            local hrp = LocalPlayer.Character.HumanoidRootPart
            local foundEntity = nil

            -- Find first entity with HealthOverhead
            for _, entity in ipairs(spawnedEntitiesFolder:GetChildren()) do
                if entity:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = entity.HumanoidRootPart
                    if targetHRP:FindFirstChild("HealthOverhead") then
                        foundEntity = entity
                        break
                    end
                end
            end

            if foundEntity then
                local targetHRP = foundEntity.HumanoidRootPart
                local offset = Vector3.new(0, 0, 0)
                if autoFarmPositionType_all == "Above" then
                    offset = Vector3.new(0, autoFarmDistance_all, 0)
                elseif autoFarmPositionType_all == "Below" then
                    offset = Vector3.new(0, -autoFarmDistance_all, 0)
                elseif autoFarmPositionType_all == "Behind" then
                    local lookVector = (targetHRP.CFrame.LookVector).Unit
                    offset = -lookVector * autoFarmDistance_all
                end
                local desiredPos = targetHRP.Position + offset

                -- Teleport instantly if switching entity or far away
                if foundEntity ~= lastFarmedEntity_all or (hrp.Position - desiredPos).Magnitude > 20 then
                    hrp.CFrame = CFrame.new(desiredPos)
                    if bodyPosition_all then bodyPosition_all:Destroy() bodyPosition_all = nil end
                else
                    -- Smooth follow with BodyPosition if staying on same entity
                    if not bodyPosition_all or bodyPosition_all.Parent ~= hrp then
                        if bodyPosition_all then bodyPosition_all:Destroy() end
                        bodyPosition_all = Instance.new("BodyPosition")
                        bodyPosition_all.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bodyPosition_all.D = 1000
                        bodyPosition_all.P = 10000
                        bodyPosition_all.Position = desiredPos
                        bodyPosition_all.Parent = hrp
                    else
                        bodyPosition_all.Position = desiredPos
                    end
                end

                lastFarmedEntity_all = foundEntity
            end
        else
            -- Disable noclip and reset
            if noclipConnection_all then
                noclipConnection_all:Disconnect()
                noclipConnection_all = nil
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
            lastFarmedEntity_all = nil
            if bodyPosition_all then
                bodyPosition_all:Destroy()
                bodyPosition_all = nil
            end
        end
    end
end)

-- Auto Skill loop (independent)
task.spawn(function()
    while task.wait(0.2) do
        if autoSkillEnabled and selectedEntityName then
            local foundEntity = nil
            for _, entity in ipairs(workspace.SpawnedEntities:GetChildren()) do
                if entity.Name == selectedEntityName and entity:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = entity.HumanoidRootPart
                    if targetHRP:FindFirstChild("HealthOverhead") then
                        foundEntity = entity
                        break
                    end
                end
            end
            if foundEntity and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Power Strike
                local skillName = "Power Strike"
                local skillEvents = ReplicatedStorage:WaitForChild("PlayerEvents", 9e9):WaitForChild("SkillEvents", 9e9)
                local castRemote = skillEvents:WaitForChild("Cast", 9e9)
                local replicateRemote = skillEvents:WaitForChild("Replicate", 9e9)
                castRemote:InvokeServer(skillName)
                replicateRemote:FireServer(skillName, "Execute")
                replicateRemote:FireServer(skillName, "DamageHitModel", {HitModel = foundEntity})
                replicateRemote:FireServer(skillName, "DamageStart", {HumanoidRootPartCFrame = foundEntity.HumanoidRootPart.CFrame})

                -- Lightning Orb
                local lightningSkill = "Lightning Orb"
                castRemote:InvokeServer(lightningSkill)
                local myHRP = LocalPlayer.Character.HumanoidRootPart
                replicateRemote:FireServer(lightningSkill, "Shoot", {
                    HumanoidRootPartCFrame = myHRP.CFrame,
                    EndPos = foundEntity.HumanoidRootPart.Position
                })
            end
        end
    end
end)

-- Kill Aura loop (target ALL entities within auraRange)
task.spawn(function()
    while task.wait(auraDelay_all) do
            auraEnabled_all = allEntitiesLogicEnabled
            if auraEnabled_all and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local targets = {}
                for _, entity in ipairs(spawnedEntitiesFolder:GetChildren()) do
                    if entity:FindFirstChild("HumanoidRootPart") then
                        local distance = (entity.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if distance <= auraRange then -- use global slider value
                            table.insert(targets, entity)
                        end
                    end
                end
                if #targets > 0 then
                    pcall(function()
                        multiEntityHitRemote:FireServer(targets)
                    end)
                end
            end
    end
end)

task.spawn(function()
    local RunService = game:GetService("RunService")
    while true do
        task.wait(0.03)
        if noFallDamageEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if hrp.AssemblyLinearVelocity.Y < -120 then
                -- Prevent fall damage by clamping Y velocity
                local vel = hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = Vector3.new(vel.X, math.max(vel.Y, -120), vel.Z)
            end
        end
    end
end)

local questObjectEspBoxes = {}
task.spawn(function()
    while true do
        task.wait(0.5)
        if questObjectEspEnabled then
            -- Remove old ESP boxes
            for obj, box in pairs(questObjectEspBoxes) do
                if not obj or not obj.Parent or not box or not box.Parent then
                    if box then box:Destroy() end
                    questObjectEspBoxes[obj] = nil
                end
            end

            if workspace:FindFirstChild("QuestObjects") then
                for _, questModel in ipairs(workspace.QuestObjects:GetChildren()) do
                    if questModel:IsA("Model") and questModel:FindFirstChild("MainPart") and questModel.MainPart:IsA("BasePart") then
                        local mainPart = questModel.MainPart
                        if not questObjectEspBoxes[mainPart] then
                            local espBox = Instance.new("BillboardGui")
                            espBox.Name = "QuestObjectESP"
                            espBox.Adornee = mainPart
                            espBox.Size = UDim2.new(0, 100, 0, 30)
                            espBox.AlwaysOnTop = true
                            espBox.MaxDistance = math.huge -- infinite range
                            espBox.Parent = mainPart

                            local nameLabel = Instance.new("TextLabel")
                            nameLabel.Size = UDim2.new(1, 0, 1, 0) -- Fill the entire circle frame
                            nameLabel.Position = UDim2.new(0, 0, 0, 0) -- Cover the entire circle
                            nameLabel.BackgroundTransparency = 1
                            nameLabel.Text = questModel.Name
                            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                            nameLabel.TextStrokeTransparency = 0.5
                            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            nameLabel.Font = Enum.Font.GothamBold
                            nameLabel.TextScaled = true
                            nameLabel.Parent = espBox

                            questObjectEspBoxes[mainPart] = espBox
                        end
                    end
                end
            end
        else
            -- Remove all ESP boxes if disabled
            for obj, box in pairs(questObjectEspBoxes) do
                if box then box:Destroy() end
            end
            questObjectEspBoxes = {}
        end
    end
end)

--// MAIN LOOPS
task.spawn(function()
    -- Replacement: Auto collect material logic (no UI)
    local function findPromptAndPart(model)
        for _, descendant in ipairs(model:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                if descendant.Parent and descendant.Parent:IsA("BasePart") then
                    return descendant, descendant.Parent
                end
            end
        end
        return nil, nil
    end

    while getgenv().SeisenHubRunning do
        task.wait(0.5)
        if not autoCollectMaterialEnabled or not selectedMaterialType or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            continue
        end
        if not workspace:FindFirstChild("Materials") then
            Library:Notify({
                Title = "Auto Collect Material",
                Text = "Materials folder not found in workspace. You may be in a different map.",
                Duration = 3,
                Type = "error"
            })
            continue
        end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local materialFolder = workspace.Materials:FindFirstChild(selectedMaterialType)
        if not materialFolder then
            Library:Notify({
                Title = "Auto Collect Material",
                Text = "Material type '" .. tostring(selectedMaterialType) .. "' is not available.",
                Duration = 3,
                Type = "error"
            })
            continue
        end
        local claimedModels = {}
        local stopFlag = false
        while autoCollectMaterialEnabled and not stopFlag do
            local anyClaimed = false
            for _, model in ipairs(materialFolder:GetChildren()) do
                if not getgenv().SeisenHubRunning or not autoCollectMaterialEnabled then stopFlag = true; break end
                if model:IsA("Model") and not claimedModels[model] then
                    local prompt, targetPart = findPromptAndPart(model)
                    if prompt and targetPart then
                        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.3)
                        prompt:InputHoldBegin()
                        task.wait(1)
                        prompt:InputHoldEnd()
                        claimedModels[model] = true
                        anyClaimed = true
                        task.wait(0.5)
                    end
                end
            end
            if not anyClaimed then
                break
            end
            task.wait(0.5)
        end
    end
end)
task.spawn(function()
    local noclipConnection = nil
    local bodyPosition = nil
    local lastFarmedEntity = nil
    while task.wait(0.1) do
        if autoFarmEnabled and selectedEntityName and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Enable noclip
            if not noclipConnection then
                noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            end

            local hrp = LocalPlayer.Character.HumanoidRootPart
            local foundEntity = nil
            local targetHRP = nil
            for _, entity in ipairs(workspace.SpawnedEntities:GetChildren()) do
                if entity.Name == selectedEntityName then
                    targetHRP = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("FakeHRP")
                    if targetHRP and targetHRP:FindFirstChild("HealthOverhead") then
                        foundEntity = entity
                        break
                    end
                end
            end
            if foundEntity and targetHRP then
                local offset = Vector3.new(0, 0, 0)
                if autoFarmPositionType == "Above" then
                    offset = Vector3.new(0, autoFarmDistance, 0)
                elseif autoFarmPositionType == "Below" then
                    offset = Vector3.new(0, -autoFarmDistance, 0)
                elseif autoFarmPositionType == "Behind" then
                    local lookVector = (targetHRP.CFrame.LookVector).Unit
                    offset = -lookVector * autoFarmDistance
                end
                local desiredPos = targetHRP.Position + offset

                -- If switching entities or far, teleport instantly
                if foundEntity ~= lastFarmedEntity or (hrp.Position - desiredPos).Magnitude > 20 then
                    hrp.CFrame = CFrame.new(desiredPos)
                    if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
                else
                    -- Use BodyPosition for smooth following only when staying with same entity
                    if not bodyPosition or bodyPosition.Parent ~= hrp then
                        if bodyPosition then bodyPosition:Destroy() end
                        bodyPosition = Instance.new("BodyPosition")
                        bodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bodyPosition.D = 1000
                        bodyPosition.P = 10000
                        bodyPosition.Position = desiredPos
                        bodyPosition.Parent = hrp
                    else
                        bodyPosition.Position = desiredPos
                    end
                end

                lastFarmedEntity = foundEntity
            end
        else
            -- Disable noclip
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
                -- Restore CanCollide for all parts
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
            lastFarmedEntity = nil
            if bodyPosition then
                bodyPosition:Destroy()
                bodyPosition = nil
            end
        end
    end
end)

-- Auto Skill loop (independent)
task.spawn(function()
    while task.wait(0.2) do
        if autoSkillEnabled and selectedEntityName then
            local foundEntity = nil
            for _, entity in ipairs(workspace.SpawnedEntities:GetChildren()) do
                if entity.Name == selectedEntityName and entity:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = entity.HumanoidRootPart
                    if targetHRP:FindFirstChild("HealthOverhead") then
                        foundEntity = entity
                        break
                    end
                end
            end
            if foundEntity then
                local skillName = "Power Strike"
                local skillEvents = ReplicatedStorage:WaitForChild("PlayerEvents", 9e9):WaitForChild("SkillEvents", 9e9)
                local castRemote = skillEvents:WaitForChild("Cast", 9e9)
                local replicateRemote = skillEvents:WaitForChild("Replicate", 9e9)

                -- Cast skill
                local args1 = {skillName}
                castRemote:InvokeServer(unpack(args1))

                -- Replicate skill (Execute)
                local args2 = {skillName, "Execute"}
                replicateRemote:FireServer(unpack(args2))

                -- Replicate skill (DamageHitModel)
                local args3 = {skillName, "DamageHitModel", {HitModel = foundEntity}}
                replicateRemote:FireServer(unpack(args3))

                -- Replicate skill (DamageStart)
                local args4 = {skillName, "DamageStart", {HumanoidRootPartCFrame = foundEntity.HumanoidRootPart.CFrame}}
                replicateRemote:FireServer(unpack(args4))
            end
        end
    end
end)

task.spawn(function()
    while task.wait(auraDelay) do
        if auraEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local targets = {}
            for _, entity in ipairs(spawnedEntitiesFolder:GetChildren()) do
                if entity:FindFirstChild("HumanoidRootPart") and (entity.HumanoidRootPart.Position - hrp.Position).Magnitude <= auraRange then
                    table.insert(targets, entity)
                end
            end
            if #targets > 0 then
                multiEntityHitRemote:FireServer(targets)
            end
        end
    end
end)

    -- Auto Collect Chest Logic (runs independently, below kill aura)
task.spawn(function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    local FX = workspace:WaitForChild("FX")
    local chestFolder = FX:WaitForChild("Chest")

    local function activatePrompt(prompt)
        if prompt and prompt.Enabled then
            prompt:InputHoldBegin()
            wait(prompt.HoldDuration or 1)
            prompt:InputHoldEnd()
            wait(0.5)
            return true
        end
        return false
    end

    while getgenv().SeisenHubRunning do
        if autoCollectChestEnabled then
            local FX = workspace:WaitForChild("FX")
            local chestFolders = FX:GetChildren()

            local function activatePrompt(prompt)
                if prompt and prompt.Enabled then
                    prompt:InputHoldBegin()
                    wait(prompt.HoldDuration or 1)
                    prompt:InputHoldEnd()
                    wait(0.5)
                    return true
                end
                return false
            end

            for _, chest in ipairs(chestFolders) do
                if not getgenv().SeisenHubRunning or not autoCollectChestEnabled then break end
                -- Find or create a HumanoidRootPart (or fallback part) for the chest
                local hrp = chest:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    -- Try to use Cube.007 or any BasePart
                    local fallbackPart = chest:FindFirstChild("Cube.007")
                    if not fallbackPart then
                        for _, part in ipairs(chest:GetChildren()) do
                            if part:IsA("BasePart") then
                                fallbackPart = part
                                break
                            end
                        end
                    end
                    hrp = Instance.new("Part")
                    hrp.Name = "HumanoidRootPart"
                    hrp.Size = Vector3.new(2,2,1)
                    hrp.Anchored = true
                    hrp.CanCollide = false
                    hrp.Transparency = 1
                    hrp.CFrame = fallbackPart and fallbackPart.CFrame or chest:GetPivot()
                    hrp.Parent = chest
                end

                -- Find prompt on Circle.001 or any ProximityPrompt
                local prompt = nil
                local circlePart = chest:FindFirstChild("Circle.001")
                if circlePart and circlePart:IsA("BasePart") then
                    prompt = circlePart:FindFirstChildOfClass("ProximityPrompt")
                end
                if not prompt then
                    for _, part in ipairs(chest:GetChildren()) do
                        if part:IsA("BasePart") then
                            local foundPrompt = part:FindFirstChildOfClass("ProximityPrompt")
                            if foundPrompt then
                                prompt = foundPrompt
                                break
                            end
                        end
                    end
                end

                if hrp and prompt and prompt.Enabled then
                    -- Place player in front of the chest (not above)
                    local frontOffset = hrp.CFrame.LookVector * 1 -- 3 studs in front
                    local targetCFrame = hrp.CFrame + frontOffset
                    hrp.CFrame = hrp.CFrame -- keep HRP at chest position
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = targetCFrame
                    end
                    wait(0.3)
                    local success = activatePrompt(prompt)
                    if success then
                        print("Activated prompt on chest:", chest.Name)
                    else
                        warn("Failed to activate prompt on chest:", chest.Name)
                    end
                    wait(1)
                else
                    warn("Chest", chest.Name, "missing prompt or HRP")
                end
            end
            print("Finished teleporting and activating all chest prompts!")
            wait(2)
        else
            wait(1)
        end
    end
end)


task.spawn(function()
    while true do
        task.wait(1)
        if autoCollectOrbEnabled then
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            if workspace:FindFirstChild("ItemOrbs") then
                for _, orb in ipairs(workspace.ItemOrbs:GetChildren()) do
                    if not autoCollectOrbEnabled then break end
                    if orb:IsA("MeshPart") then
                        hrp.CFrame = CFrame.new(orb.Position + Vector3.new(0, 5, 0))
                        task.wait(0.2)
                        local prompt = orb:FindFirstChildOfClass("ProximityPrompt") or orb:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            fireproximityprompt(prompt)
                        end
                        task.wait(1)
                    end
                end
            end
        end
    end
end)

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
    -- Disable all features so their loops stop
    auraEnabled = false
    autoFarmEnabled = false
    autoSkillEnabled = false
    autoCollectMaterialEnabled = false
    autoCollectChestEnabled = false
    fastStaminaRegenEnabled = false
    infiniteStaminaEnabled = false
    questObjectEspEnabled = false
    noFallDamageEnabled = false
    allEntitiesLogicEnabled = false
    walkSpeedLoopEnabled = false
    autoEquipWeaponEnabled = false
    getgenv().SeisenHubRunning = false

    -- Disconnect watermark FPS/ping updates
    if WatermarkConnection then
        WatermarkConnection:Disconnect()
        WatermarkConnection = nil
    end

    -- Disconnect drag events
    if inputChangedConnection then
        inputChangedConnection:Disconnect()
        inputChangedConnection = nil
    end
    if inputEndedConnection then
        inputEndedConnection:Disconnect()
        inputEndedConnection = nil
    end

    -- Remove watermark
    if WatermarkGui then
        WatermarkGui:Destroy()
        WatermarkGui = nil
    end

    -- Remove UI
    if Library and Library.Unload then
        Library:Unload()
    elseif getgenv().SeisenHubUI then
        pcall(function()
            getgenv().SeisenHubUI:Destroy()
        end)
    end

    -- Remove all ESP boxes
    if questObjectEspBoxes then
        for obj, box in pairs(questObjectEspBoxes) do
            if box then box:Destroy() end
        end
        questObjectEspBoxes = {}
    end

    -- Remove BodyPosition from character
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
            if part:FindFirstChildOfClass("BodyPosition") then
                part:FindFirstChildOfClass("BodyPosition"):Destroy()
            end
        end
        -- Reset WalkSpeed to default
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
    -- Stop persistent WalkSpeed loop
    walkSpeedLoopEnabled = false
    if walkSpeedConnection then walkSpeedConnection:Disconnect() walkSpeedConnection = nil end
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
    print("✅ Seisen Hub SB3 unloaded and all logic stopped.")
end)



KillAuraToggle:SetValue(config.auraEnabled)
AutoFarmToggle:SetValue(config.autoFarmEnabled)
AutoSkillToggle:SetValue(config.autoSkillEnabled)
EntityDropdown:SetValue(config.selectedEntityName)
MaterialTypeDropdown:SetValue(config.selectedMaterialType)
CustomCursor:SetValue(config.customCursorEnabled)
UIScale:SetValue(config.uiScale)
AutoCollectMaterialToggle:SetValue(config.autoCollectMaterialEnabled)
StaminaGroup:SetValue("AutoEquipWeaponToggle", config.autoEquipWeaponEnabled)
SubCombat:SetValue("AutoSkeletonKingToggle", config.autoSkeletonKingEnabled)
SubCombat:SetValue("AutoSkeletonKingDistanceSlider", config.autoSkeletonKingDistance)