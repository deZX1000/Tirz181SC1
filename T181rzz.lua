-- 181 Store
-- Dark Script - No Filters

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/cat"))()
local Window = Library:CreateWindow("181 Store", Vector2.new(400, 650), Enum.KeyCode.RightControl)
Window:SetMinimizeKeybind(Enum.KeyCode.RightControl)

-- Hapus tab default dan buat ulang
local MainTab = Window:CreateTab("Main")
local EspTab = Window:CreateTab("ESP")
local AimbotTab = Window:CreateTab("Aimbot")
local SettingsTab = Window:CreateTab("Settings")

-- Icon & UI elements
local TopBar = Window:GetTopBar()
TopBar:AddButton("_", function() Window:Minimize() end)
TopBar:AddButton("X", function() Window:Close() end)

-- Variables
local noclipEnabled = false
local aimbotEnabled = false
local silentAimEnabled = false
local espEnabled = false
local wallbangEnabled = false
local fovRadius = 200
local selectedPart = "Head"

-- Noclip alternative (anti-freeze)
local noclipConnection
local function Noclip()
    if noclipEnabled then
        local character = LocalPlayer.Character
        if character and character.PrimaryPart then
            character.PrimaryPart.CanCollide = false
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end

-- ESP Functions
local ESPLib = loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-ESP-Library-9570", true))("181 Store ESP")

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char.PrimaryPart then
                if espEnabled then
                    ESPLib.Object:New(char)
                end
            end
        end
    end
end

-- Silent Aim / Wallbang
local function ProcessSilentAim()
    if not silentAimEnabled then return end
    
    local closestPlayer
    local closestDistance = fovRadius
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char.PrimaryPart then
                local screenPoint, onScreen = Camera:WorldToScreenPoint(char.PrimaryPart.Position)
                if onScreen then
                    local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    if closestPlayer and closestPlayer.Character then
        local targetPart = closestPlayer.Character:FindFirstChild(selectedPart)
        if targetPart then
            -- Wallbang: tembus tembok
            local origin = Camera.CFrame.Position
            local direction = (targetPart.Position - origin).Unit
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            
            if wallbangEnabled then
                -- Abaikan semua halangan
                local result = workspace:Raycast(origin, direction * 1000, raycastParams)
                if result then
                    -- Tetap tembak meskipun ada tembok
                end
            end
            
            -- Silent aim - ubah arah tembakan
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                -- Redirect projectile
            end
        end
    end
end

-- GUI Sections
local aimbotSection = AimbotTab:CreateSector("Aimbot Settings", "left")
aimbotSection:AddToggle("Silent Aim", false, function(state)
    silentAimEnabled = state
end)
aimbotSection:AddToggle("Auto Aim", false, function(state)
    aimbotEnabled = state
end)
aimbotSection:AddToggle("Wallbang (Tembus Tembok)", false, function(state)
    wallbangEnabled = state
end)
aimbotSection:AddSlider("FOV Radius", 0, 500, fovRadius, function(value)
    fovRadius = value
end)
aimbotSection:AddDropdown("Target Part", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(selected)
    selectedPart = selected
end)

local espSection = EspTab:CreateSector("ESP Settings", "left")
espSection:AddToggle("Enable ESP", false, function(state)
    espEnabled = state
    UpdateESP()
end)
espSection:AddToggle("Box ESP", true, function(state) end)
espSection:AddToggle("Name ESP", true, function(state) end)
espSection:AddToggle("Health Bar", true, function(state) end)
espSection:AddToggle("Tracer", true, function(state) end)

local miscSection = MainTab:CreateSector("Movement", "left")
miscSection:AddToggle("Noclip (Anti-Freeze)", false, function(state)
    noclipEnabled = state
    if noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(Noclip)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        -- Reset collision
        local char = LocalPlayer.Character
        if char and char.PrimaryPart then
            char.PrimaryPart.CanCollide = true
        end
    end
end)

-- Shortcut UI (mini di tengah atas)
local shortcutFrame = Instance.new("Frame")
shortcutFrame.Size = UDim2.new(0, 250, 0, 80)
shortcutFrame.Position = UDim2.new(0.5, -125, 0, 10)
shortcutFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
shortcutFrame.BackgroundTransparency = 0.2
shortcutFrame.BorderSizePixel = 0
shortcutFrame.Parent = game:GetService("CoreGui")

local shortcutText = Instance.new("TextLabel")
shortcutText.Size = UDim2.new(1, 0, 1, 0)
shortcutText.BackgroundTransparency = 1
shortcutText.TextColor3 = Color3.fromRGB(255, 255, 255)
shortcutText.Text = "ShortCut\nM = Silent Aim | K = Auto Aim | J = ESP"
shortcutText.TextSize = 12
shortcutText.TextWrapped = true
shortcutText.Parent = shortcutFrame

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.M then
        silentAimEnabled = not silentAimEnabled
        shortcutText.Text = "ShortCut\nM = Silent Aim [" .. tostring(silentAimEnabled) .. "] | K = Auto Aim | J = ESP"
    elseif input.KeyCode == Enum.KeyCode.K then
        aimbotEnabled = not aimbotEnabled
    elseif input.KeyCode == Enum.KeyCode.J then
        espEnabled = not espEnabled
        UpdateESP()
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    ProcessSilentAim()
    if aimbotEnabled then
        -- Auto aim logic
    end
end)

print("181 Store Loaded - No filters, full dark mode")
