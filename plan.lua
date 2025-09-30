local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local isRunning = true
local joinedServers = {}
local failedGames = {}
local currentTargetPlayer = nil
local usersProcessed = 0
local maxUsersPerGame = 3
local followConnection = nil
local pingOptimized = false
local messageVariations = {}
local autoStartEnabled = true

local function generateMessageVariations(baseMessage)
    local variations = {}
    local substitutions = {,
        ["e"] = {"3", "€", "ε"},
        ["i"] = {"1", "!", "ι"},
        ["o"] = {"0", "ø", "ο"},
        ["u"] = {"μ", "υ"},
        ["l"] = {"1", "|", "ι"},
        ["t"] = {"7", "†"},
        [" "] = {".", "_", "-"}
    }
    
    for i = 1, 5 do
        local variation = baseMessage:lower()
        for char, subs in pairs(substitutions) do
            if math.random() > 0.7 then
                local replacement = subs[math.random(#subs)]
                variation = variation:gsub(char, replacement, 1)
            end
        end
        
        if math.random() > 0.5 then
            variation = variation .. string.rep(".", math.random(1, 3))
        end
        
        table.insert(variations, variation)
    end
    
    return variations
end

local function initializeMessageVariations()
    local baseMessages = {
        "ageplayer heaven in /weep",
        "cnc and ageplay in vcs /weep",
        "get active /weep",
        "join the new /weep",
        "camgir1s in /weep jvc",
        "shame18 blue for promotion just like this",
        "BRO WHAT IS SHE DOING ON CAM /weep",
        "add shame18 if you want $$"
    }
    
    for _, msg in ipairs(baseMessages) do
        local variations = generateMessageVariations(msg)
        for _, variation in ipairs(variations) do
            table.insert(messageVariations, variation)
        end
    end
end

local function applyNetworkOptimizations()
    local flags = {
        DFIntTaskSchedulerTargetFps = 15,
        FFlagDebugDisableInGameMenuV2 = true,
        FFlagDisableInGameMenuV2 = true,
        DFIntTextureQualityOverride = 1,
        FFlagRenderNoLights = true,
        FFlagRenderNoShadows = true,
        DFIntDebugFRMQualityLevelOverride = 1,
        DFFlagTextureQualityOverrideEnabled = true,
        FFlagHandleAltEnterFullscreenManually = false,
        DFIntConnectionMTUSize = 1500,
        DFIntMaxMissedWorldStepsRemembered = 1,
        DFIntDefaultTimeoutTimeMs = 2000,
        FFlagDebugSimIntegrationStabilityTesting = false,
        DFFlagDebugRenderForceTechnologyVoxel = true,
        FFlagUserHandleCameraToggle = false
    }
    
    for flag, value in pairs(flags) do
        pcall(function()
            game:SetFastFlag(flag, value)
        end)
    end
end

local function optimizeClientPerformance()
    pcall(function()
        settings().Network.IncomingReplicationLag = 0
        settings().Network.RenderStreamedRegions = false
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.MaterialQualityLevel = Enum.MaterialQualityLevel.Level01
        settings().Physics.AllowSleep = true
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnvironmentalPhysicsThrottle.DefaultAuto
    end)
end

local function forceDisableUI()
    spawn(function()
        while wait(0.5) do
            pcall(function()
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
                StarterGui:SetCore("TopbarEnabled", false)
            end)
            
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in pairs(playerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Name ~= "Chat" then
                            gui.Enabled = false
                        end
                    end
                end
            end)
            
            pcall(function()
                if workspace.CurrentCamera then
                    workspace.CurrentCamera.FieldOfView = 20
                end
            end)
        end
    end)
end

local function forceChatFeatures()
    spawn(function()
        while wait(0.2) do
            pcall(function()
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
            end)
            
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    local chatGui = playerGui:FindFirstChild("Chat")
                    if chatGui then
                        chatGui.Enabled = true
                    end
                end
            end)
            
            pcall(function()
                if TextChatService.ChatInputBarConfiguration then
                    TextChatService.ChatInputBarConfiguration.Enabled = true
                end
            end)
            
            if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
                break
            end
        end
    end)
end

local function optimizeRendering()
    spawn(function()
        local heartbeatCount = 0
        RunService.Heartbeat:Connect(function()
            heartbeatCount = heartbeatCount + 1
            if heartbeatCount % 20 == 0 then
                pcall(function()
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Decal") or obj:IsA("Texture") then
                            obj.Transparency = 1
                        elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
                            obj.Enabled = false
                        elseif obj:IsA("Sound") then
                            obj.Volume = 0
                        end
                    end
                end)
            end
        end)
    end)
end

local queueteleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

local function queueScript()
    if queueteleport and type(queueteleport) == "function" then
        queueteleport([[
wait(0.5)
print("Restarting script from queue...")
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sulwtf/spam/main/plan.lua"))()
end)
]])
        print("Script queued for restart")
    else
        print("Queue teleport not available - script will not auto-restart")
    end
end

local function saveScriptData()
    local data = {
        joinedServers = joinedServers,
        shouldAutoStart = autoStartEnabled,
        failedGames = failedGames,
        usersProcessed = usersProcessed,
        timestamp = tick()
    }
    pcall(function()
        if writefile then
            writefile("spammer_data.json", HttpService:JSONEncode(data))
            print("Script data saved - Auto-start: " .. tostring(autoStartEnabled))
        end
    end)
end

local function loadScriptData()
    print("Loading script data...")
    local success, content = pcall(function()
        if isfile and readfile and isfile("spammer_data.json") then
            return readfile("spammer_data.json")
        end
        return nil
    end)
    
    if success and content then
        local success2, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        
        if success2 and data then
            joinedServers = data.joinedServers or {}
            failedGames = data.failedGames or {}
            usersProcessed = data.usersProcessed or 0
            
            if data.shouldAutoStart ~= nil then
                autoStartEnabled = data.shouldAutoStart
                print("Loaded auto-start setting: " .. tostring(autoStartEnabled))
                return autoStartEnabled
            end
        end
    end
    
    print("No save data found, defaulting to auto-start enabled")
    autoStartEnabled = true
    return true
end

local function waitForStableConnection()
    local connectionAttempts = 0
    while connectionAttempts < 10 do
        pcall(function()
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            local pingValue = tonumber(ping:match("(%d+)"))
            
            if pingValue and pingValue < 250 then
                return true
            end
        end)
        
        wait(0.2)
        connectionAttempts = connectionAttempts + 1
    end
end

local function waitForGameLoad()
    print("Starting game load sequence...")
    
    local attempts = 0
    while (not player.Character or not player.Character:FindFirstChild("Humanoid")) and attempts < 30 do
        wait(0.1)
        attempts = attempts + 1
    end
    
    if not player.Character then
        print("Failed to load character - restarting")
        wait(1)
        teleportToNewServer()
        return
    end
    
    print("Character loaded, applying optimizations...")
    applyNetworkOptimizations()
    optimizeClientPerformance()
    waitForStableConnection()
    
    print("Disabling UI and enabling chat...")
    forceDisableUI()
    forceChatFeatures()
    optimizeRendering()
    
    wait(2)
    
    local chatAttempts = 0
    while chatAttempts < 20 do
        local chatReady = false
        pcall(function()
            if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
                chatReady = true
            end
        end)
        
        if chatReady then
            print("Chat system ready!")
            break
        end
        
        wait(0.3)
        chatAttempts = chatAttempts + 1
    end
    
    print("Game load sequence complete!")
    wait(1)
end

local function cleanupOldServers()
    local currentTime = tick()
    for serverId, joinTime in pairs(joinedServers) do
        if currentTime - joinTime >= 45 then
            joinedServers[serverId] = nil
        end
    end
    
    for gameId, failTime in pairs(failedGames) do
        if currentTime - failTime >= 90 then
            failedGames[gameId] = nil
        end
    end
end

local function sendMessage(message)
    local success = false
    local attempts = 0
    
    while not success and attempts < 3 do
        success = pcall(function()
            if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
                TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(message)
                return true
            end
        end)
        
        if not success then
            attempts = attempts + 1
            wait(0.1)
        end
    end
    
    return success
end

local function getRandomMessages()
    local selectedMessages = {}
    
    for i = 1, 3 do
        if #messageVariations > 0 then
            local randomIndex = math.random(1, #messageVariations)
            table.insert(selectedMessages, messageVariations[randomIndex])
        end
    end
    
    return selectedMessages
end

local function stopFollowing()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

local function instantTeleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    pcall(function()
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
        local newPosition = targetPosition + Vector3.new(math.random(-2, 2), 8, math.random(-2, 2))
        character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
    end)
    
    return true
end

local function getTopThreePlayers()
    local players = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, p)
        end
    end
    
    local selectedPlayers = {}
    for i = 1, math.min(3, #players) do
        if #players > 0 then
            local randomIndex = math.random(1, #players)
            table.insert(selectedPlayers, players[randomIndex])
            table.remove(players, randomIndex)
        end
    end
    
    return selectedPlayers
end

local function processMultipleUsers()
    local targetPlayers = getTopThreePlayers()
    if #targetPlayers == 0 then
        wait(0.5)
        return false
    end
    
    print("Processing " .. #targetPlayers .. " users simultaneously")
    
    for _, targetPlayer in ipairs(targetPlayers) do
        spawn(function()
            if instantTeleportToPlayer(targetPlayer) then
                wait(0.1)
                
                local selectedMessages = getRandomMessages()
                for i, message in ipairs(selectedMessages) do
                    if not isRunning then break end
                    local sent = sendMessage(message)
                    if sent then
                        print("Sent to " .. targetPlayer.Name .. ": " .. message)
                    end
                    wait(math.random(0.3, 0.6))
                end
            end
        end)
        wait(0.05)
    end
    
    wait(2)
    return true
end

local function getAvailableServers(gameId)
    local availableServers = {}
    local httpAttempts = 0
    
    while httpAttempts < 2 do
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100", true)
        end)
        
        if success then
            local parseSuccess, data = pcall(function()
                return HttpService:JSONDecode(result)
            end)
            
            if parseSuccess and data and data.data and type(data.data) == "table" then
                for _, server in ipairs(data.data) do
                    if server and 
                       server.id and 
                       server.playing and 
                       server.maxPlayers and
                       server.ping and
                       server.playing >= 3 and
                       server.playing < server.maxPlayers * 0.9 and
                       server.ping < 180 and
                       server.id ~= game.JobId and 
                       not joinedServers[server.id] then
                        table.insert(availableServers, {
                            id = server.id,
                            playing = server.playing,
                            maxPlayers = server.maxPlayers,
                            ping = server.ping,
                            priority = server.playing - (server.ping / 8)
                        })
                    end
                end
                
                table.sort(availableServers, function(a, b)
                    return a.priority > b.priority
                end)
                break
            end
        end
        
        httpAttempts = httpAttempts + 1
        if httpAttempts < 2 then
            wait(1)
        end
    end
    
    return availableServers
end

local function selectBestServer(availableServers)
    if #availableServers == 0 then
        return nil
    end
    
    local optimalServers = {}
    
    for _, server in ipairs(availableServers) do
        local populationRatio = server.playing / server.maxPlayers
        if server.ping < 120 and server.playing >= 4 and populationRatio >= 0.2 and populationRatio <= 0.8 then
            table.insert(optimalServers, server)
        end
    end
    
    if #optimalServers > 0 then
        return optimalServers[math.random(1, math.min(2, #optimalServers))]
    else
        return availableServers[math.random(1, math.min(2, #availableServers))]
    end
end

local function tryTeleportWithRetry(gameId, serverId)
    local maxRetries = 2
    
    for attempt = 1, maxRetries do
        local success, errorMsg = pcall(function()
            wait(0.2)
            
            if serverId then
                TeleportService:TeleportToPlaceInstance(tonumber(gameId), serverId, player)
            else
                TeleportService:Teleport(tonumber(gameId), player)
            end
        end)
        
        if success then
            return true
        else
            print("Teleport attempt " .. attempt .. " failed: " .. tostring(errorMsg))
            
            if string.find(tostring(errorMsg), "773") or string.find(tostring(errorMsg), "restricted") then
                print("Place is restricted or session conflict - trying different approach")
                wait(1)
                
                local logoutSuccess = pcall(function()
                    game:GetService("GuiService"):Logout()
                end)
                
                if logoutSuccess then
                    wait(2)
                end
            end
            
            if attempt < maxRetries then
                wait(math.random(1, 2))
            else
                failedGames[gameId] = tick()
                return false
            end
        end
    end
    
    return false
end

local function teleportToNewServer()
    cleanupOldServers()
    saveScriptData()
    queueScript()
    
    wait(0.5)
    
    local currentGameId = tostring(game.PlaceId)
    local attempts = 0
    local maxAttempts = 5
    
    while attempts < maxAttempts and isRunning do
        print("Server search attempt " .. (attempts + 1) .. " for current game: " .. currentGameId)
        
        local availableServers = getAvailableServers(currentGameId)
        
        if #availableServers > 0 then
            local selectedServer = selectBestServer(availableServers)
            
            if selectedServer then
                joinedServers[selectedServer.id] = tick()
                saveScriptData()
                
                print("Attempting to join new server: " .. selectedServer.id)
                if tryTeleportWithRetry(currentGameId, selectedServer.id) then
                    return
                end
            end
        end
        
        print("No suitable servers found, trying random server hop...")
        if tryTeleportWithRetry(currentGameId, nil) then
            return
        end
        
        attempts = attempts + 1
        wait(math.random(2, 4))
    end
    
    print("All server hop attempts failed, retrying in 8 seconds...")
    wait(8)
    if isRunning then
        teleportToNewServer()
    end
end

local function startSpamming()
    print("Starting spam process - isRunning: " .. tostring(isRunning))
    spawn(function()
        waitForGameLoad()
        
        if not isRunning then 
            print("Script stopped during game load")
            return 
        end
        
        print("Spam process active!")
        local processedInThisGame = 0
        
        while processedInThisGame < maxUsersPerGame and isRunning do
            if processMultipleUsers() then
                processedInThisGame = processedInThisGame + 1
                usersProcessed = usersProcessed + 1
                saveScriptData()
                print("Processed batch " .. processedInThisGame .. "/" .. maxUsersPerGame)
                wait(math.random(0.5, 1))
            else
                wait(0.5)
            end
        end
        
        if isRunning then
            print("Max users reached, hopping to new server...")
            usersProcessed = 0
            saveScriptData()
            wait(0.5)
            teleportToNewServer()
        end
    end)
end

local function stopSpamming()
    isRunning = false
    autoStartEnabled = false
    stopFollowing()
    saveScriptData()
    print("Script stopped - Auto-start disabled")
end

local function onKeyPress(key)
    if key.KeyCode == Enum.KeyCode.Q then
        stopSpamming()
    elseif key.KeyCode == Enum.KeyCode.R then
        if not isRunning then
            isRunning = true
            autoStartEnabled = true
            print("Manually starting script...")
            startSpamming()
        else
            teleportToNewServer()
        end
    end
end

local function initialize()
    print("=== ENHANCED SPAMMER SCRIPT INITIALIZING ===")
    print("Game: " .. game.Name .. " | Place ID: " .. game.PlaceId)
    print("Player: " .. player.Name .. " | User ID: " .. player.UserId)
    
    initializeMessageVariations()
    print("Message variations initialized: " .. #messageVariations .. " variations")
    
    local shouldAutoStart = loadScriptData()
    
    UserInputService.InputBegan:Connect(onKeyPress)
    print("Key bindings connected (Q = Stop, R = Start/Restart)")
    
    if game.JobId and game.JobId ~= "" then
        joinedServers[game.JobId] = tick()
        print("Current server registered: " .. game.JobId)
    end
    
    if shouldAutoStart then
        print("AUTO-STARTING SPAM PROCESS...")
        isRunning = true
        autoStartEnabled = true
        startSpamming()
    else
        print("Script loaded but auto-start disabled. Press R to manually start.")
        isRunning = false
        autoStartEnabled = false
    end
    
    print("=== INITIALIZATION COMPLETE ===")
end

initialize()
