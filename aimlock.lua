-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- UI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobilePcAimSandbox"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 1. Mobile Open/Close Toggle Button
local MenuToggleBtn = Instance.new("TextButton")
MenuToggleBtn.Size = UDim2.new(0, 100, 0, 35)
MenuToggleBtn.Position = UDim2.new(0.5, -50, 0, 10) -- Center top of screen
MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MenuToggleBtn.Text = "Toggle Menu"
MenuToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggleBtn.Font = Enum.Font.SourceSansBold
MenuToggleBtn.TextSize = 14
MenuToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = MenuToggleBtn

-- Main Menu Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 280)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true -- PC drag helper
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- Simple Mobile Drag Handling (Draggable property can be buggy on mobile)
local dragToggle, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)
Frame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and dragToggle then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = false
    end
end)

-- Connect Open/Close functionality
MenuToggleBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = " Aim Lock Test Environment"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Frame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 15)
UIPadding.Parent = Title

-- Helper function to create clean toggle buttons
local function createToggleButton(text, position, defaultState)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 35)
    button.Position = position
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    local state = defaultState
    local function updateVisuals()
        if state then
            button.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            button.Text = text .. ": ON"
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            button.Text = text .. ": OFF"
            button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
    
    updateVisuals()
    
    button.MouseButton1Click:Connect(function()
        state = not state
        updateVisuals()
    end)
    
    return function() return state end
end

-- Feature Toggles
local isAimEnabled = createToggleButton("Master Aim Lock", UDim2.new(0, 10, 0, 50), false)
local isWallCheckEnabled = createToggleButton("Wall Check", UDim2.new(0, 10, 0, 95), true)
local isFovVisible = createToggleButton("Show FOV Circle", UDim2.new(0, 10, 0, 140), true)
local isTargetLockEnabled = createToggleButton("Target Lock", UDim2.new(0, 10, 0, 185), false)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 40)
InfoLabel.Position = UDim2.new(0, 10, 0, 230)
InfoLabel.Text = "PC: [R-Click] Lock | [Q] Swap | [L] UI\nMobile: Screen Center Target Detection"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextSize = 11
InfoLabel.Font = Enum.Font.SourceSansItalic
InfoLabel.BackgroundTransparency = 1
InfoLabel.Parent = Frame

-- 2. Fixed Center Screen FOV Circle
local FOVFrame = Instance.new("Frame")
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Locked perfectly to middle of screen
FOVFrame.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
FOVFrame.BackgroundTransparency = 0.92
FOVFrame.BorderSizePixel = 0
FOVFrame.Visible = false
FOVFrame.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 85, 85)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.4
FOVStroke.Parent = FOVFrame

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

-- Configuration Settings
local PC_AIM_KEY = Enum.UserInputType.MouseButton2
local TOGGLE_UI_KEY = Enum.KeyCode.L
local SWITCH_TARGET_KEY = Enum.KeyCode.Q
local FOV_RADIUS = 130
local SMOOTHNESS = 3 -- Lower numbers make it snap / lock much faster

-- State tracking variables
local isAimingPressed = false
local currentTarget = nil
local blacklistedTargets = {}

-- Check if device is mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Wall check calculations via Raycasting
local function isVisible(targetPart)
    if not isWallCheckEnabled() then return true end
    
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return raycastResult == nil
end

-- Screen coordinates helper
local function getScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- Target checking loop
local function getClosestTarget()
    -- Maintain existing target lock if enabled
    if isTargetLockEnabled() and currentTarget and currentTarget.Parent and currentTarget.Parent:FindFirstChild("Humanoid") and currentTarget.Parent.Humanoid.Health > 0 then
        if isVisible(currentTarget) then
            local screenPos, onScreen = Camera:WorldToViewportPoint(currentTarget.Position)
            if onScreen then
                local center = getScreenCenter()
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if distance <= FOV_RADIUS then
                    return currentTarget
                end
            end
        end
    end

    local closestPart = nil
    local shortestDistance = FOV_RADIUS
    local center = getScreenCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character.HumanoidRootPart
            
            if humanoid and humanoid.Health > 0 and not blacklistedTargets[player] then
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    -- Measure distance from center of the screen
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    
                    if distance < shortestDistance then
                        if isVisible(rootPart) then
                            shortestDistance = distance
                            closestPart = rootPart
                        end
                    end
                end
            end
        end
    end
    
    return closestPart
end

-- PC Keyboard Inputs
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == PC_AIM_KEY then
        isAimingPressed = true
    elseif input.KeyCode == TOGGLE_UI_KEY then
        Frame.Visible = not Frame.Visible
    elseif input.KeyCode == SWITCH_TARGET_KEY and isAimEnabled() then
        if currentTarget and currentTarget.Parent then
            local targetPlayer = Players:GetPlayerFromCharacter(currentTarget.Parent)
            if targetPlayer then
                blacklistedTargets[targetPlayer] = true
                currentTarget = getClosestTarget()
                task.delay(0.2, function() blacklistedTargets[targetPlayer] = nil end)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == PC_AIM_KEY then
        isAimingPressed = false
        if not isTargetLockEnabled() then currentTarget = nil end
    end
end)

-- Main rendering loop
RunService.RenderStepped:Connect(function()
    -- Set size and display of stabilized center FOV Circle
    local diameter = FOV_RADIUS * 2
    FOVFrame.Size = UDim2.new(0, diameter, 0, diameter)
    FOVFrame.Visible = isFovVisible()
    
    -- Mobile treats aim lock as constantly active if Master Switch is ON
    -- PC uses the mouse right-click hold logic
    local shouldLock = false
    if isAimEnabled() then
        if isMobile then
            shouldLock = true
        elseif isAimingPressed then
            shouldLock = true
        end
    end
    
    if shouldLock then
        currentTarget = getClosestTarget()
        
        if currentTarget then
            -- Absolute CFrame Lock: Forces camera direction without input dependency
            local targetLook = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetLook, 1 / SMOOTHNESS)
        end
    else
        if not isAimingPressed then
            currentTarget = nil
        end
    end
end)
