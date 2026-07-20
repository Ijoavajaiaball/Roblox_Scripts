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
    DetectionRadius = 15,    -- Distance in studs to intercept attacks/dashes
    SafetyPadding = 0.15     -- Extra hold window (seconds) to ensure full hitboxes are blocked
}

local isGuarding = false
local lastBlockTime = 0

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
PanelTitle.Text = "TITANIUM HUB — TSB FIXED"
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
-- LOOP-FILTERED COMBAT TRIGGERBOT ENGINE
-- ==========================================================

local function engageGuard()
    if not isGuarding then
        isGuarding = true
        lastBlockTime = os.clock()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    end
end

local function releaseGuard()
    if isGuarding then
        isGuarding = false
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

-- Validate distance, presence, and life states
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

-- Scan currently executing tracks specifically for unlooped combat actions
local function hasActiveThreats()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isTargetValid(player.Character) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    -- CRITICAL FILTER: Attacks/Front-Dashes are NEVER looped.
                    -- Walking, running, and idles are ALWAYS looped (ignores them entirely).
                    if track.Looped == false and track.Priority.Value >= Enum.AnimationPriority.Action.Value then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Direct Event Connection: Fires on the exact frame an animation replicates
local function hookThreatTracking(character)
    if character == LocalPlayer.Character then return end
    
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    
    humanoid.AnimationPlayed:Connect(function(track)
        if not CombatConfig.AutoBlockEnabled or not isTargetValid(character) then return end
        
        -- Instant reaction execution if a non-looped action priority (Attack/Dash) registers
        if track.Looped == false and track.Priority.Value >= Enum.AnimationPriority.Action.Value then
            engageGuard()
            lastBlockTime = os.clock()
        end
    end)
end

-- Precision state resolution and guard-drop mitigation loop
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
        lastBlockTime = os.clock() -- Holds block active continuously while the unlooped action track runs
    else
        -- Safely drop guard only after the non-looped attack completes + tiny padding window clears
        if isGuarding and (os.clock() - lastBlockTime >= CombatConfig.SafetyPadding) then
            releaseGuard()
        end
    end
end)

-- Initialize listeners across player runtime lists
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
