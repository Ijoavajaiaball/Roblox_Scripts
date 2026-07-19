-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration Variables
local Config = {
    AimbotEnabled = false,
    FovRadius = 50, -- Default FOV (1-100 scale)
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

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- Title Label
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Titanium Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- UI Padding for Content
local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = Frame
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 50)
UIPadding.PaddingLeft = UDim.new(0, 15)
UIPadding.PaddingRight = UDim.new(0, 15)
UIPadding.Parent = Frame

-- Toggle Button Creator Function
local function createToggle(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    button.Text = text .. ": OFF"
    button.TextColor3 = Color3.fromRGB(180, 180, 180)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local state = false
    button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            button.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Text = text .. ": ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            button.TextColor3 = Color3.fromRGB(180, 180, 180)
            button.Text = text .. ": OFF"
        end
        callback(state)
    end)
end

-- Create Menu Options
createToggle("Aimbot Lock", function(state)
    Config.AimbotEnabled = state
    FovCircle.Visible = state
end)

createToggle("Player ESP", function(state)
    Config.EspEnabled = state
end)

-- FOV Slider Elements
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.Text = "FOV Radius: " .. Config.FovRadius
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Font = Enum.Font.SourceSans
SliderLabel.TextSize = 14
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = Frame

local SliderBg = Instance.new("TextButton")
SliderBg.Size = UDim2.new(1, 0, 0, 10)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
SliderBg.Text = ""
SliderBg.BorderSizePixel = 0
SliderBg.Parent = Frame

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(Config.FovRadius / 100, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBg

-- Slider Functionality (1-100 adjustment)
local function updateSlider(input)
    local relativeX = input.Position.X - SliderBg.AbsolutePosition.X
    local percentage = math.clamp(relativeX / SliderBg.AbsoluteSize.X, 0, 1)
    Config.FovRadius = math.round(percentage * 100)
    if Config.FovRadius < 1 then Config.FovRadius = 1 end
    
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderLabel.Text = "FOV Radius: " .. Config.FovRadius
end

local sliding = false
SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)

-- Mobile Open/Close Button
local MenuToggleBtn = Instance.new("TextButton")
MenuToggleBtn.Size = UDim2.new(0, 100, 0, 35)
MenuToggleBtn.Position = UDim2.new(0.5, -50, 0, 10)
MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MenuToggleBtn.Text = "Titanium Hub"
MenuToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggleBtn.Font = Enum.Font.SourceSansBold
MenuToggleBtn.TextSize = 14
MenuToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = MenuToggleBtn

MenuToggleBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

-- ESP Logic (High-Performance Highlights)
local function addEsp(player)
    if player == LocalPlayer then return end
    
    local function applyHighlight(character)
        if character:FindFirstChild("EspHighlight") then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "EspHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.Parent = character
        
        RunService.RenderStepped:Connect(function()
            highlight.Enabled = Config.EspEnabled and character:FindFirstChild("HumanoidRootPart") ~= nil
        end)
    end
    
    if player.Character then applyHighlight(player.Character) end
    player.CharacterAdded:Connect(applyHighlight)
end

for _, player in ipairs(Players:GetPlayers()) do
    addEsp(player)
end
Players.PlayerAdded:Connect(addEsp)

-- Helper function to find the closest target inside the FOV
local function getClosestTarget()
    local maxDistance = Config.FovRadius * 4
    local targetCharacter = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if distanceToCenter < maxDistance then
                    maxDistance = distanceToCenter
                    targetCharacter = player.Character
                end
            end
        end
    end
    return targetCharacter
end

-- Core Render Loop: Stable FOV & INSTANT Camera Lock-on
RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    FovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    FovCircle.Radius = Config.FovRadius * 4 

    if Config.AimbotEnabled then
        local target = getClosestTarget()
        if target and target:FindFirstChild("Head") then
            -- Direct calculation guarantees zero-delay snap lock
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
        end
    end
end)


local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- Title Label
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Titanium Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- UI Padding for Content
local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = Frame
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 50)
UIPadding.PaddingLeft = UDim.new(0, 15)
UIPadding.PaddingRight = UDim.new(0, 15)
UIPadding.Parent = Frame

-- Toggle Button Creator Function
local function createToggle(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    button.Text = text .. ": OFF"
    button.TextColor3 = Color3.fromRGB(180, 180, 180)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local state = false
    button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            button.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Text = text .. ": ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            button.TextColor3 = Color3.fromRGB(180, 180, 180)
            button.Text = text .. ": OFF"
        end
        callback(state)
    end)
end

-- Create Menu Options
createToggle("Aimbot Lock", function(state)
    Config.AimbotEnabled = state
    FovCircle.Visible = state
end)

createToggle("Player ESP", function(state)
    Config.EspEnabled = state
end)

-- FOV Slider Elements
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.Text = "FOV Radius: " .. Config.FovRadius
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Font = Enum.Font.SourceSans
SliderLabel.TextSize = 14
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = Frame

local SliderBg = Instance.new("TextButton")
SliderBg.Size = UDim2.new(1, 0, 0, 10)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
SliderBg.Text = ""
SliderBg.BorderSizePixel = 0
SliderBg.Parent = Frame

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(Config.FovRadius / 100, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBg

-- Slider Functionality (1-100 adjustment)
local function updateSlider(input)
    local relativeX = input.Position.X - SliderBg.AbsolutePosition.X
    local percentage = math.clamp(relativeX / SliderBg.AbsoluteSize.X, 0, 1)
    Config.FovRadius = math.round(percentage * 100)
    if Config.FovRadius < 1 then Config.FovRadius = 1 end
    
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderLabel.Text = "FOV Radius: " .. Config.FovRadius
end

local sliding = false
SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)

-- Mobile Open/Close Button
local MenuToggleBtn = Instance.new("TextButton")
MenuToggleBtn.Size = UDim2.new(0, 100, 0, 35)
MenuToggleBtn.Position = UDim2.new(0.5, -50, 0, 10)
MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MenuToggleBtn.Text = "Titanium Hub"
MenuToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggleBtn.Font = Enum.Font.SourceSansBold
MenuToggleBtn.TextSize = 14
MenuToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = MenuToggleBtn

MenuToggleBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

-- ESP Logic (High-Performance Highlights)
local function addEsp(player)
    if player == LocalPlayer then return end
    
    local function applyHighlight(character)
        if character:FindFirstChild("EspHighlight") then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "EspHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.Parent = character
        
        RunService.RenderStepped:Connect(function()
            highlight.Enabled = Config.EspEnabled and character:FindFirstChild("HumanoidRootPart") ~= nil
        end)
    end
    
    if player.Character then applyHighlight(player.Character) end
    player.CharacterAdded:Connect(applyHighlight)
end

for _, player in ipairs(Players:GetPlayers()) do
    addEsp(player)
end
Players.PlayerAdded:Connect(addEsp)

-- Helper function to find the closest target inside the FOV
local function getClosestTarget()
    local maxDistance = Config.FovRadius * 4
    local targetCharacter = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if distanceToCenter < maxDistance then
                    maxDistance = distanceToCenter
                    targetCharacter = player.Character
                end
            end
        end
    end
    return targetCharacter
end

-- Core Render Loop: Stable FOV & Active Camera Lock-on
RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    FovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    FovCircle.Radius = Config.FovRadius * 4 

    if Config.AimbotEnabled then
        local target = getClosestTarget()
        if target and target:FindFirstChild("Head") then
            -- Smoothing value: lower = slower/smoother lock, higher = snappier instantaneous lock
            local Smoothing = 0.15 
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Smoothing)
        end
    end
end)
