local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/cat"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variables
local espEnabled = false
local aimbotEnabled = false
local silentAimEnabled = false
local noclipEnabled = false
local fovRadius = 120
local selectedPart = "Head"
local aimAssist = 0.3
local currentTarget = nil

-- ESP System (Universal)
local espObjects = {}
local ESP = {
    Box = true,
    Name = true,
    Health = true,
    Tracer = true,
    BoxColor = Color3.fromRGB(255, 70, 70),
    NameColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(150, 100, 255)
}

-- Function to get character
local function getCharacter(plr)
    return plr.Character
end

-- Create ESP drawing objects
local function createESPObject(plr)
    if espObjects[plr] then return end
    
    local drawings = {
        boxLines = {},
        nameText = Drawing.new("Text"),
        healthText = Drawing.new("Text"),
        tracerLine = Drawing.new("Line")
    }
    
    for i = 1, 4 do
        drawings.boxLines[i] = Drawing.new("Line")
        drawings.boxLines[i].Thickness = 1.5
        drawings.boxLines[i].Color = ESP.BoxColor
        drawings.boxLines[i].Visible = false
    end
    
    drawings.nameText.Size = 12
    drawings.nameText.Center = true
    drawings.nameText.Outline = true
    drawings.nameText.Color = ESP.NameColor
    drawings.nameText.Visible = false
    
    drawings.healthText.Size = 10
    drawings.healthText.Center = true
    drawings.healthText.Outline = true
    drawings.healthText.Color = ESP.HealthColor
    drawings.healthText.Visible = false
    
    drawings.tracerLine.Thickness = 1
    drawings.tracerLine.Color = ESP.TracerColor
    drawings.tracerLine.Visible = false
    
    espObjects[plr] = drawings
end

-- Remove ESP object
local function removeESPObject(plr)
    if espObjects[plr] then
        for _, line in pairs(espObjects[plr].boxLines) do
            line:Remove()
        end
        espObjects[plr].nameText:Remove()
        espObjects[plr].healthText:Remove()
        espObjects[plr].tracerLine:Remove()
        espObjects[plr] = nil
    end
end

-- Update ESP for a player
local function updateESP()
    if not espEnabled then
        for plr, drawings in pairs(espObjects) do
            for _, line in pairs(drawings.boxLines) do
                line.Visible = false
            end
            drawings.nameText.Visible = false
            drawings.healthText.Visible = false
            drawings.tracerLine.Visible = false
        end
        return
    end
    
    local camera = workspace.CurrentCamera
    local viewportX, viewportY = camera.ViewportSize.X, camera.ViewportSize.Y
    
    for plr, drawings in pairs(espObjects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if not hrp or not hum or hum.Health <= 0 then
            for _, line in pairs(drawings.boxLines) do
                line.Visible = false
            end
            drawings.nameText.Visible = false
            drawings.healthText.Visible = false
            drawings.tracerLine.Visible = false
            goto continue
        end
        
        local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        
        if onScreen then
            local headPos = char:FindFirstChild("Head") and char.Head.Position or hrp.Position + Vector3.new(0, 2, 0)
            local headScreen = camera:WorldToViewportPoint(headPos)
            local footScreen = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2, 0))
            
            local height = footScreen.Y - headScreen.Y
            local width = height * 0.5
            local left = pos.X - width / 2
            local top = headScreen.Y
            
            -- Box
            if ESP.Box then
                drawings.boxLines[1].From = Vector2.new(left, top)
                drawings.boxLines[1].To = Vector2.new(left + width, top)
                drawings.boxLines[1].Visible = true
                
                drawings.boxLines[2].From = Vector2.new(left + width, top)
                drawings.boxLines[2].To = Vector2.new(left + width, top + height)
                drawings.boxLines[2].Visible = true
                
                drawings.boxLines[3].From = Vector2.new(left + width, top + height)
                drawings.boxLines[3].To = Vector2.new(left, top + height)
                drawings.boxLines[3].Visible = true
                
                drawings.boxLines[4].From = Vector2.new(left, top + height)
                drawings.boxLines[4].To = Vector2.new(left, top)
                drawings.boxLines[4].Visible = true
            else
                for i = 1, 4 do
                    drawings.boxLines[i].Visible = false
                end
            end
            
            -- Name
            if ESP.Name then
                drawings.nameText.Text = plr.Name
                drawings.nameText.Position = Vector2.new(pos.X, top - 15)
                drawings.nameText.Visible = true
            else
                drawings.nameText.Visible = false
            end
            
            -- Health
            if ESP.Health then
                local healthPercent = hum.Health / hum.MaxHealth
                drawings.healthText.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                drawings.healthText.Position = Vector2.new(pos.X, top + height + 10)
                drawings.healthText.Visible = true
                drawings.healthText.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            else
                drawings.healthText.Visible = false
            end
            
            -- Tracer
            if ESP.Tracer then
                drawings.tracerLine.From = Vector2.new(viewportX / 2, viewportY)
                drawings.tracerLine.To = Vector2.new(pos.X, pos.Y)
                drawings.tracerLine.Visible = true
            else
                drawings.tracerLine.Visible = false
            end
        else
            for _, line in pairs(drawings.boxLines) do
                line.Visible = false
            end
            drawings.nameText.Visible = false
            drawings.healthText.Visible = false
            drawings.tracerLine.Visible = false
        end
        
        ::continue::
    end
end

-- Initialize ESP for all players
local function initESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            createESPObject(plr)
        end
    end
end

-- Player added/removed events
Players.PlayerAdded:Connect(function(plr)
    if plr ~= player then
        createESPObject(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    removeESPObject(plr)
end)

initESP()

-- Update ESP every frame
RunService.RenderStepped:Connect(updateESP)

-- Get closest player for aimbot
local function getClosestPlayer()
    local closest = nil
    local shortestDist = fovRadius
    local center = Vector2.new(mouse.X, mouse.Y)
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild(selectedPart) then
            local part = target.Character[selectedPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = target
                end
            end
        end
    end
    return closest
end

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = fovRadius
fovCircle.Color = Color3.fromRGB(255, 70, 70)
fovCircle.Thickness = 1.5
fovCircle.Filled = false
fovCircle.NumSides = 64

-- Update FOV circle position
local function updateFOVCircle()
    if aimbotEnabled then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
        fovCircle.Radius = fovRadius
    else
        fovCircle.Visible = false
    end
end

RunService.RenderStepped:Connect(updateFOVCircle)

-- Aimbot via mouse movement
local function doAimbot()
    if not aimbotEnabled then return end
    
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild(selectedPart) then
        local targetPart = target.Character[selectedPart]
        local targetPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        
        if onScreen then
            local currentPos = Vector2.new(mouse.X, mouse.Y)
            local targetScreen = Vector2.new(targetPos.X, targetPos.Y)
            local delta = (targetScreen - currentPos) * aimAssist
            
            mousemoverel(delta.X, delta.Y)
        end
    end
end

-- Hook mouse move for aimbot
local originalMouseMove
pcall(function()
    originalMouseMove = mouse.Move
    mouse.Move = function(self, ...)
        doAimbot()
        if originalMouseMove then
            originalMouseMove(self, ...)
        end
    end
end)

-- Silent Aim with CFrame manipulation (safer method)
local function doSilentAim()
    if not silentAimEnabled or not aimbotEnabled then return end
    
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild(selectedPart) then
        currentTarget = target
        local targetPart = target.Character[selectedPart]
        
        -- Save original CFrame
        local originalCF = Camera.CFrame
        
        -- Temporarily look at target
        Camera.CFrame = CFrame.new(originalCF.Position, targetPart.Position)
        
        -- Fire the weapon (simulate click)
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then
            local toolModel = tool
            -- Try to activate the tool
            pcall(function()
                local handle = toolModel:FindFirstChild("Handle")
                if handle then
                    -- Simulate click on handle
                    local args = {handle, mouse.Hit.p}
                    -- This is executor specific, some may work some not
                end
            end)
        end
        
        -- Restore original CFrame
        task.wait(0.01)
        Camera.CFrame = originalCF
    end
end

-- Hook input for silent aim
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Silent aim on mouse click
    if silentAimEnabled and aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        doSilentAim()
    end
end)

-- Noclip (Anti-Freeze)
local noclipConnection = nil
local function enableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if noclipEnabled then
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                -- Anti-freeze: keep humanoid active
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand = true
                    task.wait(0.1)
                    hum.PlatformStand = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Create UI Window
local Window = Library:CreateWindow("181 Store", Vector2.new(400, 550), Enum.KeyCode.RightControl)
Window:SetBackgroundColor(Color3.fromRGB(20, 15, 30))
Window:SetTopbarColor(Color3.fromRGB(40, 30, 55))

-- Logo
local logoUrl = "https://i.imgur.com/DRrDsbP.png"
local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(0, 32, 0, 32)
logoContainer.Position = UDim2.new(0, 8, 0.5, -16)
logoContainer.BackgroundTransparency = 1
logoContainer.Parent = Window.Frame

local logoImage = Instance.new("ImageLabel", logoContainer)
logoImage.Size = UDim2.new(1, 0, 1, 0)
logoImage.BackgroundTransparency = 1
logoImage.Image = logoUrl
logoImage.ScaleType = Enum.ScaleType.Fit

-- Shortcut Bar
local shortcutBar = Instance.new("Frame")
shortcutBar.Size = UDim2.new(0, 320, 0, 42)
shortcutBar.Position = UDim2.new(0.5, -160, 0, 8)
shortcutBar.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
shortcutBar.BackgroundTransparency = 0.15
shortcutBar.ClipsDescendants = true
shortcutBar.ZIndex = 100
Instance.new("UICorner", shortcutBar).CornerRadius = UDim.new(0, 8)

local shortcutStroke = Instance.new("UIStroke", shortcutBar)
shortcutStroke.Color = Color3.fromRGB(100, 80, 180)
shortcutStroke.Thickness = 0.5

local shortcutTitle = Instance.new("TextLabel", shortcutBar)
shortcutTitle.Size = UDim2.new(0, 40, 1, 0)
shortcutTitle.Position = UDim2.new(0, 8, 0, 0)
shortcutTitle.BackgroundTransparency = 1
shortcutTitle.Text = "⌨️"
shortcutTitle.Font = Enum.Font.GothamBold
shortcutTitle.TextSize = 14
shortcutTitle.TextColor3 = Color3.fromRGB(200, 180, 255)

local shortcutText = Instance.new("TextLabel", shortcutBar)
shortcutText.Size = UDim2.new(1, -96, 1, 0)
shortcutText.Position = UDim2.new(0, 48, 0, 0)
shortcutText.BackgroundTransparency = 1
shortcutText.Text = "M=Silent | K=Aimbot | J=ESP"
shortcutText.Font = Enum.Font.Gotham
shortcutText.TextSize = 10
shortcutText.TextColor3 = Color3.fromRGB(180, 170, 210)

local shortcutMinBtn = Instance.new("TextButton", shortcutBar)
shortcutMinBtn.Size = UDim2.new(0, 24, 0, 24)
shortcutMinBtn.Position = UDim2.new(1, -56, 0.5, -12)
shortcutMinBtn.BackgroundColor3 = Color3.fromRGB(60, 45, 90)
shortcutMinBtn.Text = "−"
shortcutMinBtn.Font = Enum.Font.GothamBold
shortcutMinBtn.TextSize = 14
shortcutMinBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
Instance.new("UICorner", shortcutMinBtn).CornerRadius = UDim.new(0, 4)

local shortcutCloseBtn = Instance.new("TextButton", shortcutBar)
shortcutCloseBtn.Size = UDim2.new(0, 24, 0, 24)
shortcutCloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
shortcutCloseBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 50)
shortcutCloseBtn.Text = "✕"
shortcutCloseBtn.Font = Enum.Font.GothamBold
shortcutCloseBtn.TextSize = 12
shortcutCloseBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
Instance.new("UICorner", shortcutCloseBtn).CornerRadius = UDim.new(0, 4)

-- Hide/Show UI
local uiVisible = true
shortcutMinBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    Window.Frame.Visible = uiVisible
    shortcutMinBtn.Text = uiVisible and "−" or "+"
end)

shortcutCloseBtn.MouseButton1Click:Connect(function()
    Window.Frame.Visible = false
    shortcutBar.Visible = false
end)

shortcutBar.Parent = game:GetService("CoreGui")

-- ========== TABS ==========

-- Aimbot Tab
local AimbotTab = Window:CreateTab("🎯 AIMBOT")
local AimSection = AimbotTab:CreateSector("Target Settings", "left")

local aimbotToggle = AimSection:AddToggle("Aimbot Enabled", false, function(state)
    aimbotEnabled = state
end)

local silentToggle = AimSection:AddToggle("Silent Aim", false, function(state)
    silentAimEnabled = state
end)

AimSection:AddDropdown("Target Part", {"Head", "HumanoidRootPart"}, "Head", true, function(part)
    selectedPart = part
end)

local fovSlider = AimSection:AddSlider("FOV Radius", 0, 120, 200, 1, function(value)
    fovRadius = value
end)

local smoothSlider = AimSection:AddSlider("Aim Assist", 0, 0.1, 1, 0.01, function(value)
    aimAssist = value
end)

-- ESP Tab
local EspTab = Window:CreateTab("👁️ ESP")
local EspSection = EspTab:CreateSector("Visual Settings", "left")

local espToggleBtn = EspSection:AddToggle("ESP Enabled", false, function(state)
    espEnabled = state
    if not state then
        for plr, _ in pairs(espObjects) do
            removeESPObject(plr)
            createESPObject(plr)
        end
    end
end)

EspSection:AddToggle("Show Box", true, function(state)
    ESP.Box = state
end)

EspSection:AddToggle("Show Name", true, function(state)
    ESP.Name = state
end)

EspSection:AddToggle("Show Health", true, function(state)
    ESP.Health = state
end)

EspSection:AddToggle("Show Tracer", true, function(state)
    ESP.Tracer = state
end)

-- Movement Tab
local MoveTab = Window:CreateTab("🚀 MOVEMENT")
local MoveSection = MoveTab:CreateSector("Movement Mods", "left")

MoveSection:AddToggle("Noclip (Anti-Freeze)", false, function(state)
    noclipEnabled = state
    if state then
        enableNoclip()
    else
        disableNoclip()
    end
end)

MoveSection:AddButton("Jump Boost", function()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = 100
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.5)
        hum.JumpPower = 50
    end
end)

-- Settings Tab
local SettingsTab = Window:CreateTab("⚙️ SETTINGS")
local SettingsSection = SettingsTab:CreateSector("Keybinds", "left")

SettingsSection:AddLabel("Shortcut Keys:")
SettingsSection:AddLabel("🔘 M - Silent Aim Toggle")
SettingsSection:AddLabel("🔘 K - Aimbot Toggle")
SettingsSection:AddLabel("🔘 J - ESP Toggle")

-- Keybind System
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.M then
        silentAimEnabled = not silentAimEnabled
        silentToggle:SetValue(silentAimEnabled)
        print("[181 Store] Silent Aim:", silentAimEnabled and "ON" or "OFF")
    end
    
    if input.KeyCode == Enum.KeyCode.K then
        aimbotEnabled = not aimbotEnabled
        aimbotToggle:SetValue(aimbotEnabled)
        print("[181 Store] Aimbot:", aimbotEnabled and "ON" or "OFF")
    end
    
    if input.KeyCode == Enum.KeyCode.J then
        espEnabled = not espEnabled
        espToggleBtn:SetValue(espEnabled)
        print("[181 Store] ESP:", espEnabled and "ON" or "OFF")
    end
end)

-- Anti-AFK
player.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- Character respawn handler
player.CharacterAdded:Connect(function()
    if noclipEnabled then
        task.wait(0.5)
        enableNoclip()
    end
end)

print("181 Store | Script Loaded Successfully!")
print("[M] = Silent Aim | [K] = Aimbot | [J] = ESP")
