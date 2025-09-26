-- Luarmor Runtime Key Expiry Checker
-- Author: Seisen Hub

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- How often to check (in seconds)
local CHECK_INTERVAL = 10 

task.spawn(function()
    while task.wait(CHECK_INTERVAL) do
        local success, check = pcall(function()
            return loadstring(game:HttpGet(
                "https://api.luarmor.net/files/v3/loaders/c66685a510b26b7b1c3230ac5ee50e58.lua"
            ))()
        end)

        if not success or not check or check.status ~= "success" then
            -- Optional cleanup before kicking (disconnect loops, UI, etc.)
            LocalPlayer:Kick("Your Luarmor key has expired. Please get a new one.")
            break
        end
    end
end)
