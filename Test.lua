-- AIM LOCK v4.0 | BLACK MINIMAL
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer

-- НАСТРОЙКИ
local FOV = 150
local Smoothness = 0.3

-- СОСТОЯНИЕ
local enabled = false
local visible = true
local target = nil

-- СОЗДАЁМ GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AimLock"
gui.ResetOnSpawn = false
gui.Parent = Player.PlayerGui

-- ГЛАВНОЕ МЕНЮ
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 220, 0, 170)
menu.Position = UDim2.new(0, 16, 0, 16)
menu.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
menu.BackgroundTransparency = 0.08
menu.BorderSizePixel = 0
menu.ClipsDescendants = true
menu.Parent = gui

-- СКОРУГЛЕНИЕ УГЛОВ (сделаем через Corner)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = menu

-- ТЕНЬ (лёгкая подсветка)
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 0, 1, 0)
shadow.Position = UDim2.new(0, 0, 0, 0)
shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shadow.BackgroundTransparency = 0.95
shadow.BorderSizePixel = 0
shadow.Parent = menu

-- ЗАГОЛОВОК
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 36)
title.Position = UDim2.new(0, 12, 0, 8)
title.BackgroundTransparency = 1
title.Text = "AIM LOCK"
title.TextColor3 = Color3.fromRGB(220, 220, 225)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamMedium
title.Parent = menu

-- РАЗДЕЛИТЕЛЬНАЯ ЛИНИЯ
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -24, 0, 1)
divider.Position = UDim2.new(0, 12, 0, 48)
divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
divider.BorderSizePixel = 0
divider.Parent = menu

-- СТАТУС
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 22)
status.Position = UDim2.new(0, 12, 0, 56)
status.BackgroundTransparency = 1
status.Text = "DISABLED"
status.TextColor3 = Color3.fromRGB(140, 140, 150)
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Font = Enum.Font.Gotham
status.Parent = menu

-- КНОПКА ВКЛ/ВЫКЛ
local btnToggle = Instance.new("TextButton")
btnToggle.Size = UDim2.new(1, -24, 0, 34)
btnToggle.Position = UDim2.new(0, 12, 0, 84)
btnToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
btnToggle.BorderSizePixel = 0
btnToggle.Text = "ACTIVATE"
btnToggle.TextColor3 = Color3.fromRGB(200, 200, 210)
btnToggle.TextSize = 12
btnToggle.Font = Enum.Font.GothamMedium
btnToggle.Parent = menu

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = btnToggle

-- КНОПКА СКРЫТЬ/ПОКАЗАТЬ
local btnHide = Instance.new("TextButton")
btnHide.Size = UDim2.new(1, -24, 0, 34)
btnHide.Position = UDim2.new(0, 12, 0, 124)
btnHide.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
btnHide.BorderSizePixel = 0
btnHide.Text = "HIDE CROSSHAIR"
btnHide.TextColor3 = Color3.fromRGB(200, 200, 210)
btnHide.TextSize = 12
btnHide.Font = Enum.Font.GothamMedium
btnHide.Parent = menu

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 6)
btnCorner2.Parent = btnHide

-- ПРИЦЕЛ (КРАСНЫЙ КРЕСТ)
local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0, 32, 0, 32)
crosshair.Position = UDim2.new(0.5, -16, 0.5, -16)
crosshair.BackgroundTransparency = 1
crosshair.Parent = gui

local function makeLine(size, posX, posY, w, h)
    local l = Instance.new("Frame")
    l.Size = UDim2.new(0, size, 0, 2)
    l.Position = UDim2.new(0.5, posX, 0.5, posY)
    l.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    l.BorderSizePixel = 0
    l.Parent = crosshair
    return l
end

makeLine(18, -11, -1)
makeLine(18, -7, 1)

local v = Instance.new("Frame")
v.Size = UDim2.new(0, 2, 0, 18)
v.Position = UDim2.new(0.5, -1, 0.5, -11)
v.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
v.BorderSizePixel = 0
v.Parent = crosshair

local v2 = Instance.new("Frame")
v2.Size = UDim2.new(0, 2, 0, 18)
v2.Position = UDim2.new(0.5, 1, 0.5, -7)
v2.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
v2.BorderSizePixel = 0
v2.Parent = crosshair

-- КРУГ FOV
local circle = Instance.new("ImageLabel")
circle.Size = UDim2.new(0, FOV * 2, 0, FOV * 2)
circle.Position = UDim2.new(0.5, -FOV, 0.5, -FOV)
circle.BackgroundTransparency = 1
circle.Image = "rbxassetid://4911621264"
circle.ImageColor3 = Color3.fromRGB(200, 200, 210)
circle.ImageTransparency = 0.85
circle.Visible = false
circle.Parent = gui

-- ПОИСК ЦЕЛИ
local function findTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best = nil
    local bestDist = math.huge
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < FOV and dist < bestDist then
                    best = plr
                    bestDist = dist
                end
            end
        end
    end
    
    return best
end

-- ФИКСАЦИЯ
local function lockCamera()
    if not enabled or not target or not target.Character then
        target = nil
        return
    end
    
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local camPos = Camera.CFrame.Position
    local lookAt = root.Position
    local newCF = CFrame.lookAt(camPos, lookAt)
    
    Camera.CFrame = Camera.CFrame:Lerp(newCF, Smoothness)
end

-- КЛАВИАТУРА
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.One then
        enabled = not enabled
        if enabled then
            target = findTarget()
            if not target then
                enabled = false
                status.Text = "NO TARGET"
                status.TextColor3 = Color3.fromRGB(200, 150, 50)
                btnToggle.Text = "RETRY"
                return
            end
            status.Text = "ACTIVE"
            status.TextColor3 = Color3.fromRGB(120, 220, 150)
            btnToggle.Text = "DEACTIVATE"
            circle.Visible = true
        else
            status.Text = "DISABLED"
            status.TextColor3 = Color3.fromRGB(140, 140, 150)
            btnToggle.Text = "ACTIVATE"
            circle.Visible = false
            target = nil
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Two then
        visible = not visible
        crosshair.Visible = visible
        circle.Visible = visible and enabled
        btnHide.Text = visible and "HIDE CROSSHAIR" or "SHOW CROSSHAIR"
    end
end)

-- КНОПКИ GUI
btnToggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        target = findTarget()
        if not target then
            enabled = false
            status.Text = "NO TARGET"
            status.TextColor3 = Color3.fromRGB(200, 150, 50)
            btnToggle.Text = "RETRY"
            return
        end
        status.Text = "ACTIVE"
        status.TextColor3 = Color3.fromRGB(120, 220, 150)
        btnToggle.Text = "DEACTIVATE"
        circle.Visible = true
    else
        status.Text = "DISABLED"
        status.TextColor3 = Color3.fromRGB(140, 140, 150)
        btnToggle.Text = "ACTIVATE"
        circle.Visible = false
        target = nil
    end
end)

btnHide.MouseButton1Click:Connect(function()
    visible = not visible
    crosshair.Visible = visible
    circle.Visible = visible and enabled
    btnHide.Text = visible and "HIDE CROSSHAIR" or "SHOW CROSSHAIR"
end)

-- ГЛАВНЫЙ ЦИКЛ
RunService.RenderStepped:Connect(function()
    if enabled then
        if not target or not target.Character then
            target = findTarget()
        end
        if target then
            lockCamera()
        end
    end
end)

-- УВЕДОМЛЕНИЕ
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "AIM LOCK",
    Text = "Press 1 to activate",
    Duration = 3
})
