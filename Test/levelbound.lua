-- Load Seisen UI Library
getgenv().SeisenHubRunning = true

game.StarterGui:SetCore("SendNotification", {
    Title = "Seisen Hub";
    Text = "Script Loaded Successfully!";
    Duration = 5;
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

local ALLOWED_GAME_IDS = {} -- TODO: replace with your game's GameId(s) (universe id)

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

local Repo = "https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/"
local Library = loadstring(game:HttpGet(Repo .. "SeisenUI.lua?v=" .. tostring(os.time()) .. "_" .. math.random(1000,9999)))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua?v=" .. tostring(os.time()) .. "_" .. math.random(1000,9999)))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua?v=" .. tostring(os.time()) .. "_" .. math.random(1000,9999)))()

-- Create Window
local Window = Library:CreateWindow({
    Name = "Seisen Hub",
    Icon = "rbxassetid://125926861378074", 
    ConfigSettings = true,
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    SubTitle = "Levelbound",
    Version = "v1.0"
})
-- Create Tab
local MainTab = Window:AddTab("Main", "star")

-- Create Section
local MainSection = MainTab:AddLeftSection("Main Features", "zap")




MainSection:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarmToggle",
    Callback = function(value)
        getgenv().AutoFarm = value
        if value then
            task.spawn(function()
                local RunService = game:GetService("RunService")
                local Player = game:GetService("Players").LocalPlayer
                local CurrentTarget = nil
                local TargetStartTime = 0
                local TargetTimeout = 10 -- seconds before switching targets
                
                while getgenv().AutoFarm do
                    pcall(function()
                        local Character = Player.Character
                        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

                        -- Validate Current Target (with timeout check)
                        if CurrentTarget then
                            local targetStuckTime = tick() - TargetStartTime
                            if not CurrentTarget.Parent or not CurrentTarget:FindFirstChild("Humanoid") or CurrentTarget.Humanoid.Health <= 0 or not CurrentTarget:FindFirstChild("HumanoidRootPart") or targetStuckTime > TargetTimeout then
                                CurrentTarget = nil
                            end
                        end

                        -- Find New Target if None
                        if not CurrentTarget then
                            local closestEnemy = nil
                            local closestEnemyDist = math.huge
                            local closestPortal = nil
                            local closestPortalDist = math.huge

                            -- 1. Search for Enemies (MOBS ONLY - No Real Players, No NPCs)
                            for _, v in ipairs(workspace.Characters:GetChildren()) do
                                if v ~= Character and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                    -- Auto Farm targets ONLY enemy mobs - exclude ALL real players AND NPCs
                                    local isRealPlayer = game:GetService("Players"):GetPlayerFromCharacter(v) ~= nil
                                    local isTrainingDummy = v.Name == "TrainingPole" or string.find(v.Name:lower(), "training") or string.find(v.Name:lower(), "dummy")
                                    local isNPCWithParentheses = string.find(v.Name, "%(NPC%)") -- NPCs with (NPC) in name
                                    
                                    -- Target only enemy mobs (exclude real players, training dummies, AND NPCs)
                                    if not isRealPlayer and not isTrainingDummy and not isNPCWithParentheses then
                                        local dist = (Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                                        if dist < closestEnemyDist then
                                            closestEnemyDist = dist
                                            closestEnemy = v
                                        end
                                    end
                                end
                            end
                            
                            -- 2. Search for Portals
                            if workspace:FindFirstChild("Tower") then
                                for _, room in ipairs(workspace.Tower:GetChildren()) do
                                    local portal = room:FindFirstChild("Out") and room.Out:FindFirstChild("Portal")
                                    if portal then
                                        local dist = (Character.HumanoidRootPart.Position - portal.Position).Magnitude
                                        if dist < closestPortalDist then
                                            closestPortalDist = dist
                                            closestPortal = portal
                                        end
                                    end
                                end
                            end
                            
                            -- Check Special Teleport
                            local specialTeleport = workspace:FindFirstChild("TELEPORT")
                            if specialTeleport then
                                local dist = (Character.HumanoidRootPart.Position - specialTeleport.Position).Magnitude
                                if dist < closestPortalDist then
                                    closestPortalDist = dist
                                    closestPortal = specialTeleport
                                end
                            end

                            -- 3. Determine Priority
                            if closestEnemy and closestEnemyDist <= 100 then
                                -- Priority 1: Enemy within combat range
                                if CurrentTarget ~= closestEnemy then
                                    CurrentTarget = closestEnemy
                                    TargetStartTime = tick()
                                end
                            elseif closestPortal then
                                -- Priority 2: Portal (Navigation)
                                if CurrentTarget ~= closestPortal then
                                    CurrentTarget = closestPortal
                                    TargetStartTime = tick()
                                end
                            else
                                -- Priority 3: Fallback to Enemy (Approach)
                                if CurrentTarget ~= closestEnemy then
                                    CurrentTarget = closestEnemy
                                    TargetStartTime = tick()
                                end
                            end
                        end

                        -- Attack Logic (BYPASS SKILL STATES)
                        if CurrentTarget then
                            local targetPart = CurrentTarget:IsA("Model") and CurrentTarget:FindFirstChild("HumanoidRootPart") or CurrentTarget
                            if targetPart then
                                local isEnemy = CurrentTarget:FindFirstChild("Humanoid") ~= nil
                                
                                -- Attack (Only if Enemy AND < 100 studs) - IGNORE SKILL STATES
                                if isEnemy then
                                    local distToEnemy = (Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
                                    if distToEnemy <= 100 then
                                        local ID = CurrentTarget:GetAttribute("ID")
                                        local target = ID and {ID} or CurrentTarget
                                        
                                        -- FORCE ATTACK REGARDLESS OF SKILL STATE WITH MULTIPLE ATTEMPTS
                                        pcall(function()
                                            local Event = game:GetService("ReplicatedStorage").Events.AttackV2
                                            local isRanged = Character:GetAttribute("IsRanged")

                                            -- Fire multiple attacks to force claim target
                                            for i = 1, 2 do
                                                if isRanged then
                                                    local function CompressVector3(v)
                                                        return string.format("%.2f:%.2f:%.2f", v.X, v.Y, v.Z)
                                                    end
                                                    
                                                    local direction = (targetPart.Position - Character.HumanoidRootPart.Position).Unit
                                                    local targetTable = (type(target) == "table") and target or {ID or target} 
                                                    
                                                    Event:FireServer(1, 1)
                                                    Event:FireServer(4, 1, nil, CompressVector3(direction))
                                                    Event:FireServer(5, 1, targetTable)
                                                    Event:FireServer(3, 1)
                                                else
                                                    Event:FireServer(1, 1)
                                                    Event:FireServer(2, 1, target)
                                                    Event:FireServer(3, 1)
                                                end
                                            end
                                        end)
                                    end
                                else
                                    -- Portal Interaction checking
                                    local distToPortal = (Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
                                    if distToPortal <= 10 then
                                        -- Try to find Prompt
                                        local prompt = targetPart:FindFirstChildWhichIsA("ProximityPrompt") or targetPart.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                                        if prompt then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.05) -- Faster kill aura - works even during skills
                end
            end)
        end
    end
})

MainSection:AddToggle({
    Name = "Auto Claim Daily Quest",
    Default = false,
    Flag = "AutoClaimToggle", 
    Callback = function(value)
        getgenv().AutoClaim = value
        if value then
            task.spawn(function()
                while getgenv().AutoClaim do
                    pcall(function()
                        local Event = game:GetService("ReplicatedStorage").Events.ClaimQuest
                        Event:FireServer("CompleteDungeons")
                    end)
                    task.wait(30) -- Check every 30 seconds
                end
            end)
        end
    end
})

MainSection:AddToggle({
    Name = "Kill Aura (NPCs + Players)",
    Default = false,
    Flag = "KillAuraToggle",
    Callback = function(value)
        getgenv().KillAura = value
        if value then
            task.spawn(function()
                local Player = game:GetService("Players").LocalPlayer
                
                while getgenv().KillAura do
                    pcall(function()
                        local Character = Player.Character
                        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

                        -- Find closest target and AGGRESSIVELY CLAIM IT
                        local closestTarget = nil
                        local closestDistance = math.huge
                        
                        for _, v in ipairs(workspace.Characters:GetChildren()) do
                            if v ~= Character and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                local distance = (Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                                
                                -- Kill Aura targets: NPCs with (NPC) in name AND real players
                                local isNPCWithParentheses = string.find(v.Name, "%(NPC%)")
                                local isRealPlayer = game:GetService("Players"):GetPlayerFromCharacter(v) ~= nil
                                
                                if (isNPCWithParentheses or isRealPlayer) and distance <= 100 and distance < closestDistance then
                                    closestDistance = distance
                                    closestTarget = v
                                end
                            end
                        end
                        
                        -- FORCE CLAIM TARGET FROM NPCs WITH RAPID ATTACKS
                        if closestTarget then
                            local targetPart = closestTarget.HumanoidRootPart
                            local ID = closestTarget:GetAttribute("ID")
                            local target = ID and {ID} or closestTarget
                            
                            -- RAPID FIRE ATTACKS to steal target from NPCs
                            pcall(function()
                                local Event = game:GetService("ReplicatedStorage").Events.AttackV2
                                local isRanged = Character:GetAttribute("IsRanged")

                                -- Fire 3 rapid attacks to claim target from NPCs
                                for i = 1, 3 do
                                    if isRanged then
                                        local function CompressVector3(v)
                                            return string.format("%.2f:%.2f:%.2f", v.X, v.Y, v.Z)
                                        end
                                        
                                        local direction = (targetPart.Position - Character.HumanoidRootPart.Position).Unit
                                        local targetTable = (type(target) == "table") and target or {ID or target} 
                                        
                                        Event:FireServer(1, 1)
                                        Event:FireServer(4, 1, nil, CompressVector3(direction))
                                        Event:FireServer(5, 1, targetTable)
                                        Event:FireServer(3, 1)
                                    else
                                        Event:FireServer(1, 1)
                                        Event:FireServer(2, 1, target)
                                        Event:FireServer(3, 1)
                                    end
                                end
                            end)
                        end
                    end)
                    task.wait(0.02) -- Super aggressive timing to steal targets from NPCs
                end
            end)
        end
    end
})

MainSection:AddToggle({
    Name = "Auto Skill",
    Default = false,
    Flag = "AutoSkillToggle",
    Callback = function(value)
        getgenv().AutoSkill = value
        if value then
            task.spawn(function()
                local Player = game:GetService("Players").LocalPlayer
                local RunSkillEvent = game:GetService("ReplicatedStorage").Events.RunSkill
                
                local lastSkillUse = 0
                local skillCooldown = 1.5
                local skillIndex = 1
                
                -- All available skills by weapon type
                local weaponSkills = {
                    ["Sword"] = {"ShieldStrike", "SwordSmash", "ShieldDash", "Chain", "WeakeningDome"},
                    ["Greatsword"] = {"GreatswordSmash", "BattleVortex", "DevilCut", "GroundRift", "BattleDash"},
                    ["Daggers"] = {"FlurryOfBlows", "BloodyCut", "ShadowStep", "ShadowDash", "Elimination"},
                    ["Bow"] = {"HailOfArrows", "ExplosiveArrow", "GodShot", "JumpBack", "RainOfArrows"},
                    ["Staff"] = {"Fireball", "RingOfFire", "IceSpike", "ChainLightning", "RayOfDestruction"},
                    ["Wand"] = {"CurseBall", "HealingWave", "HealingTotem", "RayOfHeal"}
                }
                
                -- Skills that need special targeting (projectiles/ranged)
                local projectileSkills = {
                    "Fireball", "CurseBall", "ExplosiveArrow", "HailOfArrows", "GodShot", 
                    "ShadowStep", "Chain", "RainOfArrows", "JumpBack"
                }
                
                -- AoE skills that work around player
                local aoeSkills = {
                    "GreatswordSmash", "BattleVortex", "GroundRift", "RingOfFire", 
                    "WeakeningDome", "FlurryOfBlows", "ShadowDash", "Elimination"
                }
                
                while getgenv().AutoSkill do
                    pcall(function()
                        local Character = Player.Character
                        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
                        
                        -- Check character state
                        if Character:GetAttribute("IsDied") then return end
                        if not Character:GetAttribute("IsEquipped") then return end
                        
                        local isStunned = Character:GetAttribute("Stunned")
                        local isBlocking = Character:GetAttribute("IsBlocking")
                        local isDashing = Character:GetAttribute("IsDashing")
                        local isEquipping = Character:GetAttribute("IsEquipping")
                        local isCrawling = Character:GetAttribute("IsCrawling")
                        -- REMOVED IsSkillUsing check to allow concurrent operation
                        
                        if isStunned or isBlocking or isDashing or isEquipping or isCrawling then
                            return
                        end
                        
                        -- Check cooldown
                        local currentTime = tick()
                        if currentTime - lastSkillUse < skillCooldown then return end
                        
                        -- Find nearest enemy
                        local nearestEnemy = nil
                        local nearestDistance = math.huge
                        
                        for _, v in ipairs(workspace.Characters:GetChildren()) do
                            if v ~= Character and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                local isRealPlayer = game:GetService("Players"):GetPlayerFromCharacter(v) ~= nil
                                local isTrainingDummy = v.Name == "TrainingPole" or string.find(v.Name:lower(), "training") or string.find(v.Name:lower(), "dummy")
                                local isNPCWithParentheses = string.find(v.Name, "%(NPC%)") -- NPCs with (NPC) in name
                                
                                -- Auto Skill targets same as Auto Farm - mobs only, exclude real players AND NPCs
                                if not isRealPlayer and not isTrainingDummy and not isNPCWithParentheses then
                                    local distance = (Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                                    if distance <= 20 and distance < nearestDistance then
                                        nearestDistance = distance
                                        nearestEnemy = v
                                    end
                                end
                            end
                        end
                        
                        -- Use skill if enemy is nearby
                        if nearestEnemy then
                            -- Get current weapon and available skills
                            local currentWeapon = Character:GetAttribute("CurrentWeapon") or "Greatsword"
                            local availableSkills = weaponSkills[currentWeapon] or weaponSkills["Greatsword"]
                            
                            -- Cycle through skills
                            local skillToUse = availableSkills[skillIndex]
                            skillIndex = skillIndex + 1
                            if skillIndex > #availableSkills then
                                skillIndex = 1
                            end
                            
                            -- Calculate positions
                            local enemyPosition = nearestEnemy.HumanoidRootPart.Position
                            local myPosition = Character.HumanoidRootPart.Position
                            local directionToEnemy = (enemyPosition - myPosition).Unit
                            
                            -- Make character face enemy for better accuracy
                            local newCFrame = CFrame.lookAt(myPosition, Vector3.new(enemyPosition.X, myPosition.Y, enemyPosition.Z))
                            Character.HumanoidRootPart.CFrame = newCFrame
                            task.wait(0.03)
                            
                            -- Determine target position based on skill type
                            local targetPosition
                            if table.find(projectileSkills, skillToUse) then
                                -- For projectile skills, target the enemy directly
                                targetPosition = enemyPosition
                            elseif table.find(aoeSkills, skillToUse) then
                                -- For AoE skills, target slightly in front of player
                                targetPosition = myPosition + directionToEnemy * 2
                            else
                                -- Default targeting
                                targetPosition = enemyPosition
                            end
                            
                            -- Use Forward direction since we face the enemy
                            local direction = "Forward"
                            
                            -- Use the skill
                            local success, result = pcall(function()
                                return RunSkillEvent:InvokeServer({
                                    Skill = skillToUse,
                                    Function = "Activate"
                                }, targetPosition, true, direction)
                            end)
                            
                            if success then
                                lastSkillUse = currentTime
                                print("Auto Skill used:", skillToUse, "with", currentWeapon, "at", math.floor(nearestDistance), "studs")
                            else
                                print("Auto Skill failed:", skillToUse, "-", tostring(result))
                            end
                        end
                    end)
                    
                    task.wait(0.1) -- Faster skill checks for better integration
                end
            end)
        end
    end
})

-- Create Teleport Section
local TeleportSection = MainTab:AddRightSection("Teleport", "compass")

-- Teleport Settings
local TeleportSettings = {
    Location = "Orc Lands",
    Difficult = "Easy",
    LuckyDungeon = false,
    Invasions = false,
    Ghostified = false,
    IsPrivateGroup = false,
    SoloMode = false
}

-- Function to get dungeon levels and sort them
local function getDungeonOptions()
    local dungeons = {}
    local Player = game:GetService("Players").LocalPlayer
    
    -- Try to get dungeon info from GUI
    pcall(function()
        local dungeonItems = Player.PlayerGui.InteractionZones.DungeonMasterCreate.Dungeons.Items
        
        -- Dynamically get all dungeon children (exclude UI elements)
        for _, child in ipairs(dungeonItems:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("Level") and child:FindFirstChild("Title") then
                local name = child.Name
                local levelText = child.Level.Text or ""
                local level = tonumber(levelText:match("%d+")) or 0
                table.insert(dungeons, {name = name, level = level, display = name .. " (" .. levelText .. ")"})
            end
        end
        
        -- If no dungeons found via GUI, use fallback
        if #dungeons == 0 then
            local fallbackDungeons = {
                {name = "Orc Lands", level = 1, display = "Orc Lands (1-10)"},
                {name = "The Crypt", level = 10, display = "TheCrypt (10-20)"},
                {name = "Frosty Hills", level = 20, display = "FrostyHills (20-30)"},
                {name = "The Swamps", level = 30, display = "TheSwamps (30-40)"},
                {name = "Volcanic Abyss", level = 40, display = "VolcanicAbyss (40-50)"},
                {name = "Heroic", level = 50, display = "Heroic (50+)"},
                {name = "Rune Forest", level = 50, display = "RuneForest (50-70)"}
            }
            dungeons = fallbackDungeons
        end
    end)
    
    -- Sort by level
    table.sort(dungeons, function(a, b) return a.level < b.level end)
    
    -- Return display names and actual names
    local options = {}
    local nameMapping = {}
    for _, dungeon in ipairs(dungeons) do
        table.insert(options, dungeon.display)
        nameMapping[dungeon.display] = dungeon.name
    end
    
    return options, nameMapping
end

-- Get initial dungeon options
local dungeonOptions, dungeonMapping = getDungeonOptions()

TeleportSection:AddDropdown({
    Name = "Dungeon Location",
    Options = dungeonOptions,
    Default = dungeonOptions[1] or "Orc Lands",
    Flag = "DungeonLocation",
    Callback = function(value)
        -- Map display name back to actual dungeon name
        local actualName = dungeonMapping[value] or value
        TeleportSettings.Location = actualName
    end
})

TeleportSection:AddDropdown({
    Name = "Difficulty",
    Options = {"Easy", "Medium", "Hard"},
    Default = "Easy", 
    Flag = "Difficulty",
    Callback = function(value)
        TeleportSettings.Difficult = value
    end
})

TeleportSection:AddToggle({
    Name = "Lucky Dungeon",
    Default = false,
    Flag = "LuckyDungeon",
    Callback = function(value)
        TeleportSettings.LuckyDungeon = value
    end
})

TeleportSection:AddToggle({
    Name = "Invasions",
    Default = false,
    Flag = "Invasions", 
    Callback = function(value)
        TeleportSettings.Invasions = value
    end
})

TeleportSection:AddToggle({
    Name = "Ghostified",
    Default = false,
    Flag = "Ghostified",
    Callback = function(value)
        TeleportSettings.Ghostified = value
    end
})

TeleportSection:AddToggle({
    Name = "Private Group",
    Default = false,
    Flag = "PrivateGroup",
    Callback = function(value)
        TeleportSettings.IsPrivateGroup = value
    end
})

TeleportSection:AddToggle({
    Name = "Solo Mode", 
    Default = false,
    Flag = "SoloMode",
    Callback = function(value)
        TeleportSettings.SoloMode = value
    end
})

TeleportSection:AddButton({
    Name = "Create Dungeon Group",
    Callback = function()
        task.spawn(function()
            pcall(function()
                -- Update dungeon options in case new dungeons were added
                local _, currentMapping = getDungeonOptions()
                
                -- Make sure we're using the actual dungeon name, not the display name
                local actualLocation = TeleportSettings.Location
                for displayName, actualName in pairs(currentMapping) do
                    if TeleportSettings.Location == displayName then
                        actualLocation = actualName
                        break
                    end
                end
                
                -- Create the dungeon group first
                local args = {
                    [1] = {
                        ["LuckyDungeon"] = TeleportSettings.LuckyDungeon;
                        ["Invasions"] = TeleportSettings.Invasions;
                        ["Ghostified"] = TeleportSettings.Ghostified;
                        ["Location"] = actualLocation;
                        ["IsPrivateGroup"] = TeleportSettings.IsPrivateGroup;
                        ["Difficult"] = TeleportSettings.Difficult;
                        ["SoloMode"] = TeleportSettings.SoloMode;
                    };
                    [2] = {};
                }
                
                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("CreateDungeonGroup", 9e9):FireServer(unpack(args))
                
                -- Wait a little bit
                task.wait(2)
                
                -- Start the dungeon group
                local startArgs = {}
                game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("StartDungeonGroup", 9e9):FireServer(unpack(startArgs))
            end)
        end)
    end
})

-- Create Invasion Section
local InvasionSection = MainTab:AddRightSection("Invasion", "shield")

InvasionSection:AddButton({
    Name = "Join Dungeon as PK",
    Callback = function()
        local args = {
            [2] = true;
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("JoinDungeonAsPK", 9e9):FireServer(unpack(args))
    end
})

-- Create UI Settings tab
local UISettingsTab = Window:AddTab("UI Settings", "palette")

-- Configure SaveManager
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("MyScript")
SaveManager:BuildConfigSection(UISettingsTab)

-- Configure ThemeManager
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("MyScript")
ThemeManager:BuildThemeSection(UISettingsTab)

-- Load autoload config
SaveManager:LoadAutoloadConfig()
