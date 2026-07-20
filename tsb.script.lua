-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- CLEANUP: Prevent UI duplication
if LocalPlayer.PlayerGui:FindFirstChild("TitaniumTSBGui") then
    LocalPlayer.PlayerGui.TitaniumTSBGui:Destroy()
end

-- State Configuration
local CombatConfig = {
    AutoBlockEnabled = false,
    DetectionRadius = 32,        -- Expanded radius to catch fast front dashes before they hit
    MeleeRadius = 16,            -- Tight radius for standard M1s and close-quarters combat skills
    DashVelocityThreshold = 36,  -- Speed trigger to isolate front dashes
    SafetyPadding = 0.22,         -- Hold window to ensure full skill frames are blocked
    InputRateLimit = 0.08        -- Optimized gate time to prevent mobile input queue lag
}

local isGuarding = false
local lastBlockTime = 0
local lastInputToggleTime = 0

-- UI Root Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TitaniumTSBGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Standalone Combat Panel Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 140)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 4, 4) -- Dark red theme
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Color3.fromRGB(150, 15, 15)
MainBorder.Thickness = 1.5
MainBorder.Parent = MainFrame

-- Panel Title
local PanelTitle = Instance.new("TextLabel")
PanelTitle.Text = "TITANIUM HUB — TSB PARRY"
PanelTitle.Size = UDim2.new(1, 0, 0, 30)
PanelTitle.BackgroundColor3 = Color3.fromRGB(8, 2, 2)
PanelTitle.TextColor3 = Color3.fromRGB(220, 20, 20)
PanelTitle.Font = Enum.Font.SourceSansBold
PanelTitle.TextSize = 13
PanelTitle.BorderSizePixel = 0
PanelTitle.Parent = MainFrame

-- Container for Toggles
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -40)
ContentFrame.Position = UDim2.new(0, 10, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = ContentFrame

-- Toggle Helper Function
local function createToggle(text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.Parent = ContentFrame
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(200, 20, 20)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = row
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 45, 0, 20)
    switch.Position = UDim2.new(1, -45, 0, 5)
    switch.BackgroundColor3 = default and Color3.fromRGB(220, 20, 20) or Color3.fromRGB(40, 40, 40)
    switch.Text = ""
    switch.BorderSizePixel = 0
    switch.Parent = row
    
    local round = Instance.new("UICorner")
    round.CornerRadius = UDim.new(1, 0)
    round.Parent = switch
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = default and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = switch
    
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(1, 0)
    sc.Parent = dot

    local state = default
    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.BackgroundColor3 = state and Color3.fromRGB(220, 20, 20) or Color3.fromRGB(40, 40, 40)
        dot.Position = state and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
        callback(state)
    end)
end

-- Mobile Panel Collapse Button
local MenuToggleBtn = Instance.new("TextButton")
MenuToggleBtn.Size = UDim2.new(0, 130, 0, 26)
MenuToggleBtn.Position = UDim2.new(0.5, -65, 0, 5)
MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 5, 5)
MenuToggleBtn.Text = "TSB Panel"
MenuToggleBtn.TextColor3 = Color3.fromRGB(255, 20, 20)
MenuToggleBtn.Font = Enum.Font.SourceSansBold
MenuToggleBtn.TextSize = 13
MenuToggleBtn.Parent = ScreenGui

local BtnBorder = Instance.new("UIStroke")
BtnBorder.Color = Color3.fromRGB(180, 10, 10)
BtnBorder.Thickness = 1.2
BtnBorder.Parent = MenuToggleBtn

MenuToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Initialize Toggle UI Control
createToggle("Insta-Trigger Block", false, function(state)
    CombatConfig.AutoBlockEnabled = state
end)

-- ==========================================================
-- LOOK-ALIGNED FRONT DASH TRIGGERBOT ENGINE
-- ==========================================================

local function engageGuard()
    local now = os.clock()
    if not isGuarding and (now - lastInputToggleTime >= CombatConfig.InputRateLimit) then
        isGuarding = true
        lastBlockTime = now
        lastInputToggleTime = now
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    end
end

local function releaseGuard()
    local now = os.clock()
    if isGuarding and (now - lastInputToggleTime >= CombatConfig.InputRateLimit) then
        isGuarding = false
        lastInputToggleTime = now
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

local function isTargetValid(character)
    if not character or character == LocalPlayer.Character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local targetRoot = character:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if humanoid and humanoid.Health > 0 and targetRoot and myRoot then
        local distance = (targetRoot.Position - myRoot.Position).Magnitude
        return distance <= CombatConfig.DetectionRadius
    end
    return false
end

local function hasActiveThreats()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isTargetValid(player.Character) then
            local enemyChar = player.Character
            local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart")
            local humanoid = enemyChar:FindFirstChildOfClass("Humanoid")
            
            if enemyRoot and humanoid then
                local distance = (myRoot.Position - enemyRoot.Position).Magnitude
                local enemyVelocity = enemyRoot.AssemblyLinearVelocity
                local velocityHorizontal = Vector3.new(enemyVelocity.X, 0, enemyVelocity.Z)
                local absoluteEnemySpeed = velocityHorizontal.Magnitude
                
                -- 1. ADVANCED FRONT-DASH FILTER ENGINE
                if absoluteEnemySpeed >= CombatConfig.DashVelocityThreshold and absoluteEnemySpeed < 140 then
                    local enemyLookHorizontal = Vector3.new(enemyRoot.CFrame.LookVector.X, 0, enemyRoot.CFrame.LookVector.Z).Unit
                    local movementAlignment = velocityHorizontal.Unit:Dot(enemyLookHorizontal)
                    
                    local toMeHorizontal = Vector3.new(myRoot.Position.X - enemyRoot.Position.X, 0, myRoot.Position.Z - enemyRoot.Position.Z).Unit
                    local headingTowardsMe = velocityHorizontal.Unit:Dot(toMeHorizontal)
                    
                    -- Alignment checks:
                    -- movementAlignment > 0.75 targets movements in their facing direction (Front Dash)
                    -- headingTowardsMe > 0.6 ensures that front dash is aimed directly at your torso
                    if movementAlignment > 0.75 and headingTowardsMe > 0.6 then
                        return true
                    end
                end
                
                -- 2. CLOSE-QUARTERS ATTACK TRACKING (M1 Strings & Skills)
                if distance <= CombatConfig.MeleeRadius then
                    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                        if track.Looped == false and track.Priority.Value >= Enum.AnimationPriority.Action.Value then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Frame-1 Execution pipeline on raw M1 combo registration
local function hookThreatTracking(character)
    if character == LocalPlayer.Character then return end
    
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    
    humanoid.AnimationPlayed:Connect(function(track)
        if not CombatConfig.AutoBlockEnabled or not isTargetValid(character) then return end
        
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local enemyRoot = character:FindFirstChild("HumanoidRootPart")
        
        if myRoot and enemyRoot then
            local distance = (myRoot.Position - enemyRoot.Position).Magnitude
            -- Only auto-blocks unlooped physical animations within true strike distance
            if distance <= CombatConfig.MeleeRadius and track.Looped == false and track.Priority.Value >= Enum.AnimationPriority.Action.Value then
                engageGuard()
                lastBlockTime = os.clock()
            end
        end
    end)
end

-- Main Heartbeat Synchronization Thread
RunService.Heartbeat:Connect(function()
    if not CombatConfig.AutoBlockEnabled then
        if isGuarding then releaseGuard() end
        return
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
        if isGuarding then releaseGuard() end
        return
    end
    
    if hasActiveThreats() then
        engageGuard()
        lastBlockTime = os.clock()
    else
        -- Drops guard after threats drop and the cushion padding expires
        if isGuarding and (os.clock() - lastBlockTime >= CombatConfig.SafetyPadding) then
            releaseGuard()
        end
    end
end)

-- Initialization structures across live instance profiles
local function initialize()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            task.spawn(hookThreatTracking, player.Character)
        end
        player.CharacterAdded:Connect(function(char)
            if player ~= LocalPlayer then
                task.spawn(hookThreatTracking, char)
            end
        end)
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            if player ~= LocalPlayer then
                task.spawn(hookThreatTracking, char)
            end
        end)
    end)
end

initialize()
