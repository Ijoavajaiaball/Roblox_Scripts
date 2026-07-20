-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- CLEANUP: Clear any older versions before running
if LocalPlayer.PlayerGui:FindFirstChild("TitaniumHubGui") then
    LocalPlayer.PlayerGui.TitaniumHubGui:Destroy()
end

-- Configuration Variables
local Config = {
    AimbotEnabled = false,
    AutoShootEnabled = false,
    FovRadius = 50,
    EspEnabled = false
}

-- FOV Circle Visual
local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(200, 0, 0)
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Filled = false
FovCircle.Visible = false

-- UI Root Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TitaniumHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Menu Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 360)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 4, 4)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Color3.fromRGB(120, 10, 10)
MainBorder.Thickness = 1.5
MainBorder.Parent = MainFrame

-- Top Status Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(8, 2, 2)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopTitle = Instance.new("TextLabel")
TopTitle.Text = "A  TITANIUM"
TopTitle.Size = UDim2.new(0, 120, 1, 0)
TopTitle.Position = UDim2.new(0, 10, 0, 0)
TopTitle.TextColor3 = Color3.fromRGB(200, 20, 20)
TopTitle.TextSize = 14
TopTitle.Font = Enum.Font.SourceSansBold
TopTitle.TextXAlignment = Enum.TextXAlignment.Left
TopTitle.BackgroundTransparency = 1
TopTitle.Parent = TopBar

local TopStats = Instance.new("TextLabel")
TopStats.Text = "FPS: 60  |  PING: 45ms  |  VER: v2.4b"
TopStats.Size = UDim2.new(0, 200, 1, 0)
TopStats.Position = UDim2.new(1, -210, 0, 0)
TopStats.TextColor3 = Color3.fromRGB(120, 30, 30)
TopStats.TextSize = 12
TopStats.Font = Enum.Font.SourceSans
TopStats.TextXAlignment = Enum.TextXAlignment.Right
TopStats.BackgroundTransparency = 1
TopStats.Parent = TopBar

-- Left Sidebar Navigation
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -30)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 3, 3)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local MainTab = Instance.new("TextLabel")
MainTab.Text = "♥  Main"
MainTab.Size = UDim2.new(1, -10, 0, 35)
MainTab.Position = UDim2.new(0, 10, 0, 10)
MainTab.TextColor3 = Color3.fromRGB(245, 245, 245)
MainTab.TextSize = 14
MainTab.Font = Enum.Font.SourceSansBold
MainTab.TextXAlignment = Enum.TextXAlignment.Left
MainTab.BackgroundTransparency = 1
MainTab.Parent = Sidebar

local SettingsTab = Instance.new("TextLabel")
SettingsTab.Text = "⚙  Settings"
SettingsTab.Size = UDim2.new(1, -10, 0, 35)
SettingsTab.Position = UDim2.new(0, 10, 0, 45)
SettingsTab.TextColor3 = Color3.fromRGB(130, 130, 130)
SettingsTab.TextSize = 14
SettingsTab.Font = Enum.Font.SourceSans
SettingsTab.TextXAlignment = Enum.TextXAlignment.Left
SettingsTab.BackgroundTransparency = 1
SettingsTab.Parent = Sidebar

-- Columns Container
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -120, 1, -40)
Container.Position = UDim2.new(0, 115, 0, 35)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local LeftColumn = Instance.new("Frame")
LeftColumn.Size = UDim2.new(0.5, -5, 1, 0)
LeftColumn.Position = UDim2.new(0, 0, 0, 0)
LeftColumn.BackgroundTransparency = 1
LeftColumn.Parent = Container

local RightColumn = Instance.new("Frame")
RightColumn.Size = UDim2.new(0.5, -5, 1, 0)
RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
RightColumn.BackgroundTransparency = 1
RightColumn.Parent = Container

-- Functional Component Creators
local function createSection(name, parentFrame)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 1, 0)
    section.BackgroundTransparency = 1
    section.Parent = parentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = section

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 0
    header.Parent = section
    
    local title = Instance.new("TextLabel")
    title.Text = "⚙  " .. name
    title.Size = UDim2.new(0.8, 0, 1, 0)
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = header
    
    local arrow = Instance.new("TextLabel")
    arrow.Text = "∨"
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.TextColor3 = Color3.fromRGB(150, 20, 20)
    arrow.Font = Enum.Font.SourceSansBold
    arrow.TextSize = 12
    arrow.BackgroundTransparency = 1
    arrow.Parent = header
    
    return section
end

local function createInlineToggle(section, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.75, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = row
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 30, 0, 16)
    switch.Position = UDim2.new(1, -30, 0, 4)
    switch.BackgroundColor3 = default and Color3.fromRGB(200, 20, 20) or Color3.fromRGB(40, 40, 40)
    switch.Text = ""
    switch.BorderSizePixel = 0
    switch.Parent = row
    
    local round = Instance.new("UICorner")
    round.CornerRadius = UDim.new(1, 0)
    round.Parent = switch
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = default and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = switch
    
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(1, 0)
    sc.Parent = dot

    local state = default
    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.BackgroundColor3 = state and Color3.fromRGB(200, 20, 20) or Color3.fromRGB(40, 40, 40)
        dot.Position = state and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2)
        callback(state)
    end)
end

local function createRowSlider(section, labelText, min, max, default, callback)
    local sliderBg = Instance.new("TextButton")
    sliderBg.Size = UDim2.new(1, 0, 0, 24)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 10, 10)
    sliderBg.Text = ""
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = section
    
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(140, 15, 15)
    border.Thickness = 1
    border.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(180, 15, 15)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local displayLabel = Instance.new("TextLabel")
    displayLabel.Text = labelText .. ": " .. default
    displayLabel.Size = UDim2.new(1, 0, 1, 0)
    displayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    displayLabel.Font = Enum.Font.SourceSans
    displayLabel.TextSize = 13
    displayLabel.BackgroundTransparency = 1
    displayLabel.ZIndex = 2
    displayLabel.Parent = sliderBg

    local function update(input)
        local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.round(min + (relX * (max - min)))
        sliderFill.Size = UDim2.new(relX, 0, 1, 0)
        displayLabel.Text = labelText .. ": " .. val
        callback(val)
    end

    sliderBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then update(i) end end)
    sliderBg.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
end

-- Generate Layout Columns
local CombatSection = createSection("Auto Settings", LeftColumn)
local VisualsSection = createSection("Visuals", RightColumn)

-- Populate UI Elements
createInlineToggle(CombatSection, "Enable Aimbot Lock", false, function(s) 
    Config.AimbotEnabled = s 
    FovCircle.Visible = s 
end)

createInlineToggle(CombatSection, "Auto Shoot (TB)", false, function(s)
    Config.AutoShootEnabled = s
end)

createRowSlider(CombatSection, "Aimbot FOV Radius", 1, 100, 50, function(v) 
    Config.FovRadius = v 
end)

createInlineToggle(VisualsSection, "Esp Player Show", false, function(s) 
    Config.EspEnabled = s 
end)

-- Mobile Expand/Collapse Header Button
local MenuToggleBtn = Instance.new("TextButton")
MenuToggleBtn.Size = UDim2.new(0, 120, 0, 26)
MenuToggleBtn.Position = UDim2.new(0.5, -60, 0, 2)
MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 5, 5)
MenuToggleBtn.Text = "Titanium Hub"
MenuToggleBtn.TextColor3 = Color3.fromRGB(230, 20, 20)
MenuToggleBtn.Font = Enum.Font.SourceSansBold
MenuToggleBtn.TextSize = 13
MenuToggleBtn.Parent = ScreenGui

local BtnBorder = Instance.new("UIStroke")
BtnBorder.Color = Color3.fromRGB(150, 10, 10)
BtnBorder.Thickness = 1.2
BtnBorder.Parent = MenuToggleBtn

MenuToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

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

-- ESP Registration Thread
local function addEsp(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(180, 0, 0)
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

-- Debounce flag to protect firing rates on mobile hardware loops
local isFiring = false

-- Core Render Update Loop
RunService.RenderStepped:Connect(function()
    local centerScreen = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Position = centerScreen
    FovCircle.Radius = Config.FovRadius * 4
    
    -- Handle Aimbot Look Tracking
    if Config.AimbotEnabled then
        local target = getClosestTarget()
        if target then 
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position) 
        end
    end
    
    -- Handle Auto Shoot Mobile Native Injection
    if Config.AutoShootEnabled and not isFiring and Mouse.Target then
        local hitObject = Mouse.Target
        local character = hitObject:FindFirstAncestorOfClass("Model")
        
        if character and character:FindFirstChild("Humanoid") and character ~= LocalPlayer.Character then
            local targetPlayer = Players:GetPlayerFromCharacter(character)
            if targetPlayer and character:FindFirstChild("Head") and isVisible(character) then
                isFiring = true
                
                -- Construct Touch Tap Input Object
                local touchObj = Instance.new("InputObject")
                touchObj.UserInputType = Enum.UserInputType.Touch
                touchObj.UserInputState = Enum.UserInputState.Begin
                touchObj.Position = Vector3.new(centerScreen.X, centerScreen.Y, 0)
                
                -- Fire Mobile Tap State Channels
                UserInputService:InputBegan:Fire(touchObj, false)
                task.wait(0.03) -- Clean hardware release frame
                touchObj.UserInputState = Enum.UserInputState.End
                UserInputService:InputEnded:Fire(touchObj, false)
                
                task.wait(0.1) -- Cooldown to match game cycle speeds
                isFiring = false
            end
        end
    end
end)
