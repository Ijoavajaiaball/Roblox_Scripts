-- [[ TITANIUM HUB: MULTI-FUNCTION CHEAT SUITE ]]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global Feature States (Kept exact original settings)
local Config = {
    Aimbot = false,
    AutoShoot = false, -- Connected directly to the Toggle below
    TargetPart = "HumanoidRootPart",
    MaxDistance = 500,
    Smoothness = 1
}

----------------------------------------------------------------
-- 1. MOBILE-OPTIMIZED UI INTERFACE (UNCHANGED)
----------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TitaniumHub_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 200)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Header = Instance.new("TextLabel")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Header.Text = "  TITANIUM HUB v2.0"
Header.TextColor3 = Color3.fromRGB(0, 210, 255)
Header.TextSize = 14
Header.Font = Enum.Font.SourceSansBold
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local function CreateToggle(name, text, positionY, callback)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = name
    ToggleButton.Size = UDim2.new(0, 200, 0, 35)
    ToggleButton.Position = UDim2.new(0.5, -100, 0, positionY)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    ToggleButton.Text = text .. " [OFF]"
    ToggleButton.TextColor3 = Color3.fromRGB(200, 50, 50)
    ToggleButton.TextSize = 14
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ToggleButton

    local active = false
    ToggleButton.MouseButton1Click:Connect(function()
        active = not active
        if active then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 65, 45)
            ToggleButton.Text = text .. " [ON]"
            ToggleButton.TextColor3 = Color3.fromRGB(50, 220, 50)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            ToggleButton.Text = text .. " [OFF]"
            ToggleButton.TextColor3 = Color3.fromRGB(200, 50, 50)
        end
        callback(active)
    end)
end

-- Kept your precise button configurations and layout
CreateToggle("AimbotToggle", "Aimbot Lock", 50, function(state) Config.Aimbot = state end)
CreateToggle("TriggerbotToggle", "Auto-Shoot", 95, function(state) Config.AutoShoot = state end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "Minimize"
MinimizeButton.Size = UDim2.new(0, 30, 0, 25)
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14
MinimizeButton.Parent = MainFrame

local ContentVisible = true
MinimizeButton.MouseButton1Click:Connect(function()
    ContentVisible = not ContentVisible
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child ~= Header and child ~= MinimizeButton and not child:IsA("UICorner") then
            child.Visible = ContentVisible
        end
    end
    MainFrame.Size = ContentVisible and UDim2.new(0, 240, 0, 200) or UDim2.new(0, 240, 0, 35)
    MinimizeButton.Text = ContentVisible and "-" or "+"
end)

----------------------------------------------------------------
-- 2. COMBINED AIMING AND AUTO-SHOOT LOGIC
----------------------------------------------------------------

local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            local target = char and char:FindFirstChild(Config.TargetPart)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if target and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                
                if onScreen then
                    local mousePos = Camera.ViewportSize / 2
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance and distance <= Config.MaxDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Main loop combining tracking and auto-firing safely
RunService.RenderStepped:Connect(function()
    local targetEnemy = getClosestEnemy()
    
    if not targetEnemy or not targetEnemy.Character then return end
    local targetPartInstance = targetEnemy.Character:FindFirstChild(Config.TargetPart)
    if not targetPartInstance then return end

    -- Aimbot visual lock functionality
    if Config.Aimbot then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPartInstance.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / Config.Smoothness)
    end

    -- Newly integrated Auto-Shoot check inside the core execution block
    if Config.AutoShoot then
        local centerRay = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local raycastResult = Workspace:Raycast(centerRay.Origin, centerRay.Direction * Config.MaxDistance, raycastParams)
        
        -- Confirms the crosshair ray intersects the enemy target model before triggering input
        if raycastResult and raycastResult.Instance:IsDescendantOf(targetEnemy.Character) then
            VirtualInputManager:Button1Down(Vector3.new(0, 0, 0))
            task.wait(0.02)
            VirtualInputManager:Button1Up(Vector3.new(0, 0, 0))
        end
    end
end)
