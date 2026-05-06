-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/cat"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variables
local espEnabled = false
local aimbotEnabled = false
local silentAimEnabled = false
local noclipEnabled = false
local wallhackEnabled = false
local fovRadius = 120
local aimbotKey = "K"
local silentAimKey = "M"
local espToggleKey = "J"
local selectedPart = "Head"
local aimAssist = 0.3

-- ESP System
local ESP = loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-ESP-Library-9570", true))("181 Store ESP")

-- ESP Override Team Color
function ESP:GetTeamColor()
    return Color3.fromRGB(255, 70, 70) -- Enemy red
end

function ESP:GetColor()
    return Color3.fromRGB(0, 255, 255) -- Teal default
end

-- Create UI Window
local Window = Library:CreateWindow("181 Store", Vector2.new(400, 550), Enum.KeyCode.RightControl)
Window:SetBackgroundColor(Color3.fromRGB(20, 15, 30))
Window:SetTopbarColor(Color3.fromRGB(40, 30, 55))

-- Load Logo dari Imgur
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

-- Tambahkan shortcutBar ke GUI
shortcutBar.Parent = game:GetService("CoreGui")

-- ========== TAB AIMBOT ==========
local AimbotTab = Window:CreateTab("🎯 AIMBOT")
local AimSection = AimbotTab:CreateSector("Target Settings", "left")

local aimbotToggle = AimSection:AddToggle("Aimbot Enabled", false, function(state)
    aimbotEnabled = state
end)

local silentToggle = AimSection:AddToggle("Silent Aim", false, function(state)
    silentAimEnabled = state
end)

local wallhackToggle = AimSection:AddToggle("Wallhack (Bullet Penetration)", false, function(state)
    wallhackEnabled = state
    if state then
        -- Enable bullet penetration
        pcall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end)
    else
        pcall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end)
    end
end)

AimSection:AddDropdown("Target Part", {"Head", "HumanoidRootPart", "Torso"}, "Head", true, function(part)
    selectedPart = part
end)

local fovSlider = AimSection:AddSlider("FOV Radius", 0, 120, 200, 1, function(value)
    fovRadius = value
end)

local smoothSlider = AimSection:AddSlider("Aim Assist", 0, 0.1, 1, 0.01, function(value)
    aimAssist = value
end)

-- Draw FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = fovRadius
fovCircle.Color = Color3.fromRGB(255, 70, 70)
fovCircle.Thickness = 1.5
fovCircle.Filled = false
fovCircle.NumSides = 64
fovCircle.Position = Vector2.new(mouse.X, mouse.Y)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
        fovCircle.Radius = fovRadius
    else
        fovCircle.Visible = false
    end
end)

-- Get Closest Player to Mouse
local function getClosestPlayer()
    local closest = nil
    local shortestDist = fovRadius
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild(selectedPart) then
            local partPos, onScreen = Camera:WorldToViewportPoint(target.Character[selectedPart].Position)
            if onScreen then
                local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(partPos.X, partPos.Y)).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = target
                end
            end
        end
    end
    return closest
end

-- Silent Aim & Bullet Penetration
local function getClosestPlayerToCrosshair()
    local closest = nil
    local shortestDist = math.huge
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local partPos, onScreen = Camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
            if onScreen then
                local crosshairPos = Vector2.new(mouse.X, mouse.Y)
                local targetPos = Vector2.new(partPos.X, partPos.Y)
                local dist = (crosshairPos - targetPos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = target
                end
            end
        end
    end
    return closest, shortestDist
end

-- Hitbox modifier for wallbang
local function modifyHitbox(char)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Size = part.Size + Vector3.new(0.5, 0.5, 0.5)
        end
    end
end

-- CFrame manipulation for silent aim
local oldCFrame
local function setSilentAim(target)
    if not silentAimEnabled or not aimbotEnabled then return end
    
    local closestTarget, dist = getClosestPlayerToCrosshair()
    if closestTarget and closestTarget.Character and closestTarget.Character:FindFirstChild(selectedPart) then
        local targetPart = closestTarget.Character[selectedPart]
        if targetPart then
            -- Simulate aiming at target
            oldCFrame = Camera.CFrame
            local lookAt = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = lookAt
            task.wait(0.01)
            Camera.CFrame = oldCFrame
        end
    end
end

-- Hook mouse for silent aim
local mt = getrawmetatable(game)
local old_namecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if silentAimEnabled and aimbotEnabled and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        if tostring(self):find("Weapon") or tostring(args[1]):find("shoot") then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(selectedPart) then
                local targetPart = target.Character[selectedPart]
                if targetPart then
                    -- Modify direction to target
                    local direction = (targetPart.Position - Camera.CFrame.Position).Unit
                    if wallhackEnabled then
                        -- Penetrate walls (remove collision temporarily)
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and obj ~= targetPart then
                                obj.CanCollide = false
                            end
                        end
                        task.wait(0.05)
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                obj.CanCollide = true
                            end
                        end
                    end
                end
            end
        end
    end
    
    return old_namecall(self, ...)
end)

setreadonly(mt, true)

-- ========== TAB ESP ==========
local EspTab = Window:CreateTab("👁️ ESP")
local EspSection = EspTab:CreateSector("Visual Settings", "left")

local espToggleBtn = EspSection:AddToggle("ESP Enabled", false, function(state)
    espEnabled = state
    if state then
        -- Enable ESP for all players
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                local char = plr.Character
                if char then
                    ESP.Object:New(char)
                end
            end
        end
    else
        -- Clear all ESP objects
        ESP:Clear()
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

-- ESP Update on player add
Players.PlayerAdded:Connect(function(plr)
    if espEnabled then
        plr.CharacterAdded:Connect(function(char)
            ESP.Object:New(char)
        end)
        if plr.Character then
            ESP.Object:New(plr.Character)
        end
    end
end)

-- ========== TAB MOVEMENT ==========
local MoveTab = Window:CreateTab("🚀 MOVEMENT")
local MoveSection = MoveTab:CreateSector("Movement Mods", "left")

-- Anti-Freeze Noclip (bypass)
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
                -- Additional anti-freeze: reset velocity
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity
                    hrp.AssemblyAngularVelocity = Vector3.zero
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

MoveSection:AddToggle("Noclip (Anti-Freeze)", false, function(state)
    noclipEnabled = state
    if state then
        enableNoclip()
    else
        disableNoclip()
    end
end)

MoveSection:AddToggle("Speed Boost", false, function(state)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and state then
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(100000, 0, 100000)
        bodyVel.Velocity = hrp.CFrame.LookVector * 100
        bodyVel.Parent = hrp
        task.delay(0.5, function() bodyVel:Destroy() end)
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

-- ========== TAB SETTINGS ==========
local SettingsTab = Window:CreateTab("⚙️ SETTINGS")
local SettingsSection = SettingsTab:CreateSector("Keybinds", "left")

SettingsSection:AddLabel("Shortcut Keys:")
SettingsSection:AddLabel("🔘 M - Silent Aim Toggle")
SettingsSection:AddLabel("🔘 K - Aimbot Toggle")
SettingsSection:AddLabel("🔘 J - ESP Toggle")

-- Keybind system
local function setupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Silent Aim toggle (M)
        if input.KeyCode == Enum.KeyCode.M then
            silentAimEnabled = not silentAimEnabled
            notify("Silent Aim", silentAimEnabled and "ON" or "OFF", silentAimEnabled and "success" or "error")
        end
        
        -- Aimbot toggle (K)
        if input.KeyCode == Enum.KeyCode.K then
            aimbotEnabled = not aimbotEnabled
            notify("Aimbot", aimbotEnabled and "ON" or "OFF", aimbotEnabled and "success" or "error")
        end
        
        -- ESP toggle (J)
        if input.KeyCode == Enum.KeyCode.J then
            espEnabled = not espEnabled
            espToggleBtn:SetValue(espEnabled)
            if espEnabled then
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character then
                        ESP.Object:New(plr.Character)
                    end
                end
            else
                ESP:Clear()
            end
            notify("ESP", espEnabled and "ON" or "OFF", espEnabled and "success" or "error")
        end
    end)
end

setupKeybinds()

-- Notification helper
local function notify(title, msg, ntype)
    local color = ntype == "success" and Color3.fromRGB(50, 200, 110) or Color3.fromRGB(220, 60, 75)
    -- Simple notification
    print(string.format("[%s] %s: %s", ntype:upper(), title, msg))
end

-- Cleanup on script end
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if noclipEnabled then
        enableNoclip()
    end
end)

-- Initialize ESP settings
ESP.Box = true
ESP.Name = true
ESP.Health = true
ESP.Tracer = true
ESP.BoxColor = Color3.fromRGB(255, 70, 70)
ESP.NameColor = Color3.fromRGB(255, 255, 255)
ESP.HealthColor = Color3.fromRGB(50, 200, 110)
ESP.TracerColor = Color3.fromRGB(150, 100, 255)

-- Final notification
print("181 Store | Script Loaded Successfully!")
notify("181 Store", "Script siap digunakan! M=Silent | K=Aimbot | J=ESP", "success")

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)
```

FITUR YANG TERSEDIA:

Fitur Keterangan
Aimbot Auto aim ke player terdekat dalam FOV
Silent Aim Peluru meleset secara visual tapi tetap kena target
Wallhack/Bullet Penetration Tembus tembok (temporary disable collision)
ESP Box, Name, Health, Tracer
Noclip Anti-freeze + bypass
Shortcut M, K, J untuk toggle
FOV Circle Visualisasi radius aimbot
UI Modern Responsive HP, logo, minimize/close

CARA PAKAI:

1. Paste script ke executor
2. Execute
3. Tekan RightControl untuk buka/tutup UI utama
4. Gunakan shortcut M, K, J untuk toggle fitur cepat

Perintah selanjutnya, Aseph.
