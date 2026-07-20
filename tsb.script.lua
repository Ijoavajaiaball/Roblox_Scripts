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
    DetectionRadius = 13, -- Optimal close-quarters combat distance (in studs)
    BlockHoldDuration = 0.4 -- Seconds to maintain guard per triggered interaction
}

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
PanelTitle.Text = "TITANIUM HUB — TSB TRIGGER"
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

-- Mobile Panel Toggle Button
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

-- Initialize UI Toggle
createToggle("Insta-Trigger Block", false, function(state)
    CombatConfig.AutoBlockEnabled = state
end)

-- ==========================================================
-- INSTANT REACTION TRIGGERBOT ENGINE (CROSS-PLATFORM BIND)
-- ==========================================================

local isGuardActive = false
local blockReleaseThread = nil

-- Forces immediate engine-level action engagement
local function engageGuard()
    if not isGuardActive then
        isGuardActive = true
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    end
    
    -- Auto-refresh safety window thread
    if blockReleaseThread then task.cancel(blockReleaseThread) end
    blockReleaseThread = task.spawn(function()
        task.wait(CombatConfig.BlockHoldDuration)
        if isGuardActive then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            isGuardActive = false
        end
    end)
end

-- Connection routine for monitoring active threats 
local function hookThreatTracking(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    
    -- Event Hook: Fires immediately when an enemy starts any animation action string
    humanoid.AnimationPlayed:Connect(function()
        if not CombatConfig.AutoBlockEnabled then return end
        
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local enemyRoot = character:FindFirstChild("HumanoidRootPart")
        
        if myRoot and enemyRoot then
            -- High-speed proximity evaluation
            local distance = (myRoot.Position - enemyRoot.Position).Magnitude
            if distance <= CombatConfig.DetectionRadius then
                engageGuard()
            end
        end
    end)
end

-- Initialize tracking logic across the current session environment
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
        task.spawn(hookThreatTracking, char)
    end)
end)

-- Backup Engine: Monitors raw property status tags as a secondary fail-safe
RunService.Heartbeat:Connect(function()
    if not CombatConfig.AutoBlockEnabled then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local enemyChar = player.Character
            -- Fast check if the game engine marks them in a combat attack state
            if enemyChar:GetAttribute("Attacking") == true or enemyChar:GetAttribute("InCombo") == true then
                local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart")
                if enemyRoot then
                    local distance = (myRoot.Position - enemyRoot.Position).Magnitude
                    if distance <= CombatConfig.DetectionRadius then
                        engageGuard()
                        break
                    end
                end
            end
        end
    end
end)
