-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CLEANUP: Clear any older versions before running
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
FovCircle.Color = Color3.fromRGB(255, 0, 0) -- Red accent to match new theme
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Filled = false
FovCircle.Visible = false

-- UI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TitaniumHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Menu Frame (New AJJANS Style Red/Dark)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Border = Instance.new("UIStroke")
Border.Color = Color3.fromRGB(150, 0, 0)
Border.Thickness = 2
Border.Parent = MainFrame

-- Left Sidebar Navigation
local Nav = Instance.new("Frame")
Nav.Size = UDim2.new(0, 100, 1, 0)
Nav.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Nav.BorderSizePixel = 0
Nav.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Titanium"
Title.TextColor3 = Color3.fromRGB(150, 0, 0)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = Nav

-- Right Side Content Window
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -100, 1, 0)
Content.Position = UDim2.new(0, 100, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 12)
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 20)
Padding.PaddingLeft = UDim.new(0, 20)
Padding.PaddingRight = UDim.new(0, 20)
Padding.Parent = Content

-- Helper: Create Menu Toggles
local function createToggle(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    button.Text = text .. ": OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    local state = false
    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(25, 25, 25)
        button.Text = text .. (state and ": ON" or ": OFF")
        callback(state)
    end)
end

-- Create Script Elements
createToggle("Aimbot Lock", function(state) 
    Config.AimbotEnabled = state 
    FovCircle.Visible = state 
end)

createToggle("Player ESP", function(state) 
    Config.EspEnabled = state 
end)

-- FOV Interactive Slider Block
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Text = "FOV Radius: " .. Config.FovRadius
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Font = Enum.Font.SourceSans
SliderLabel.TextSize = 14
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = Content

local SliderBg = Instance.new("TextButton")
SliderBg.Size = UDim2.new(1, 0, 0, 12)
SliderBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SliderBg.Text = ""
SliderBg.BorderSizePixel = 0
SliderBg.Parent = Content

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(Config.FovRadius / 100, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBg

local function updateSlider(input)
    local relX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
    Config.FovRadius = math.round(relX * 100)
    if Config.FovRadius < 1 then Config.FovRadius = 1 end
    
    SliderFill.Size = UDim2.new(relX, 0, 1, 0)
    SliderLabel.Text = "FOV Radius: " .. Config.FovRadius
end

SliderBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then updateSlider(i) end end)
SliderBg.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then updateSlider(i) end end)

-- Mobile Header Open/Close Button
local MenuToggleBtn = Instance.new("TextButton")
MenuToggleBtn.Size = UDim2.new(0, 110, 0, 35)
MenuToggleBtn.Position = UDim2.new(0.5, -55, 0, 10)
MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuToggleBtn.Text = "Titanium Hub"
MenuToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggleBtn.Font = Enum.Font.SourceSansBold
MenuToggleBtn.TextSize = 14
MenuToggleBtn.Parent = ScreenGui

local BtnBorder = Instance.new("UIStroke")
BtnBorder.Color = Color3.fromRGB(150, 0, 0)
BtnBorder.Thickness = 1.5
BtnBorder.Parent = MenuToggleBtn

MenuToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ESP Feature Logic
local function addEsp(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(150, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Parent = char
        RunService.RenderStepped:Connect(function() 
            highlight.Enabled = Config.EspEnabled and char:FindFirstChild("HumanoidRootPart") ~= nil
        end)
    end)
end
for _, p in pairs(Players:GetPlayers()) do addEsp(p) end
Players.PlayerAdded:Connect(addEsp)

-- Exact Wall Check & Tracking Formula
local function isVisible(target)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, target}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, (target.Head.Position - Camera.CFrame.Position), rayParams)
    return result == nil 
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

-- Core Render Thread
RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Radius = Config.FovRadius * 4
    
    if Config.AimbotEnabled then
        local target = getClosestTarget()
        if target then 
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position) 
        end
    end
end)
