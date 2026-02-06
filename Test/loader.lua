-- Load GameList
local success, Games = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/roblox/refs/heads/main/gamelist.lua"))()
end)

if not success or type(Games) ~= "table" then
    warn("Failed to load GameList.")
    return
end

-- Get current game's GameId
local gameId = tostring(game.GameId)

-- Find script URL
local scriptUrl = Games[gameId]

if scriptUrl then
    local ok, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    if not ok then
        warn("Failed to execute script: " .. tostring(err))
    end
else
    warn("No script found for this game: " .. gameId)
end