-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CLEANUP: Delete old UI if it exists to prevent duplication
if LocalPlayer.PlayerGui:FindFirstChild("TitaniumHubGui") then
    LocalPlayer.PlayerGui.TitaniumHubGui:Destroy()
end

-- Configuration Variables
local Config = {
    AimbotEnabled = false,
    FovRadius = 50,
    EspEnabled = false
}

-- FOV Circle Visual
local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(0, 255, 137)
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Filled = false
FovCircle.Visible = false

-- UI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TitaniumHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Menu Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 320)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- UI Padding & Layouts
local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = Frame
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 50)
UIPadding.PaddingLeft = UDim.new(0, 15)
UIPadding.PaddingRight = UDim.new(0, 15)
UIPadding.Parent = Frame

-- Helper Functions
local function createToggle(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    button.Text = text .. ": OFF"
    button.TextColor3 = Color3.fromRGB(180, 180, 180)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.Parent = Frame
    
    local state = false
    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(35, 35, 40)
        button.Text = text .. (state and ": ON" or ": OFF")
        callback(state)
    end)
end

-- Create Options
createToggle("Aimbot Lock", function(state) Config.AimbotEnabled = state; FovCircle.Visible = state end)
createToggle("Player ESP", function(state) Config.EspEnabled = state end)

-- FOV Slider
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Text = "FOV Radius: 50"; SliderLabel.Size = UDim2.new(1, 0, 0, 20); SliderLabel.BackgroundTransparency = 1; SliderLabel.Parent = Frame
local SliderBg = Instance.new("TextButton"); SliderBg.Size = UDim2.new(1, 0, 0, 10); SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45); SliderBg.Parent = Frame
local SliderFill = Instance.new("Frame"); SliderFill.Size = UDim2.new(0.5, 0, 1, 0); SliderFill.BackgroundColor3 = Color3.fromRGB(52, 152, 219); SliderFill.Parent = SliderBg

local function updateSlider(input)
    local relX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
    Config.FovRadius = math.round(relX * 100)
    SliderFill.Size = UDim2.new(relX, 0, 1, 0); SliderLabel.Text = "FOV Radius: " .. Config.FovRadius
end
SliderBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then updateSlider(i) end end)
SliderBg.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then updateSlider(i) end end)

-- ESP Logic
local function addEsp(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.Parent = char
        RunService.RenderStepped:Connect(function() highlight.Enabled = Config.EspEnabled end)
    end)
end
for _, p in pairs(Players:GetPlayers()) do addEsp(p) end
Players.PlayerAdded:Connect(addEsp)

-- Wall Check & Aimbot Target
local function isVisible(target)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, target}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, (target.Head.Position - Camera.CFrame.Position), rayParams)
    return result == nil -- Returns true if nothing is in the way
end

local function getClosestTarget()
    local maxDist = Config.FovRadius * 4
    local closest = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen and isVisible(p.Character) then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < maxDist then
                    maxDist = dist
                    closest = p.Character
                end
            end
        end
    end
    return closest
end

-- Core Loop
RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Radius = Config.FovRadius * 4
    if Config.AimbotEnabled then
        local target = getClosestTarget()
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position) end
    end
end)

