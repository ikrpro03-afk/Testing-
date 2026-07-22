-- AIM LOCK v7.0 | STICK MODE (1st person only)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer

-- НАСТРОЙКИ
local SNAP_SPEED = 0.9  -- скорость доведения до точки (0.8-1.0)

-- СОСТОЯНИЕ
local enabled = false
local visible = true
local target = nil
local isMinimized = false
local isMaximized = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AimLock"
gui.ResetOnSpawn = false
gui.Parent = Player.PlayerGui

-- ОКНО
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 280, 0, 210)
menu.Position = UDim2.new(0, 20, 0, 20)
menu.BackgroundColor3 = Color3.fromRGB(10, 15, 26)
menu.BackgroundTransparency = 0.05
menu.BorderSizePixel = 0
menu.ClipsDescendants = true
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 8)
menuCorner.Parent = menu

-- ЗАГОЛОВОК
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 20, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = menu

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 8)
titleBarCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -100, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "AIM LOCK v7.0"
titleText.TextColor3 = Color3.fromRGB(180, 210, 255)
titleText.TextSize = 13
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamMedium
titleText.Parent = titleBar

-- КНОПКИ ОКНА
local btnMinimize = Instance.new("TextButton")
btnMinimize.Size = UDim2.new(0, 28, 1, 0)
btnMinimize.Position = UDim2.new(1, -84, 0, 0)
btnMinimize.BackgroundTransparency = 1
btnMinimize.Text = "─"
btnMinimize.TextColor3 = Color3.fromRGB(180, 210, 255)
btnMinimize.TextSize = 16
btnMinimize.Font = Enum.Font.Gotham
btnMinimize.Parent = titleBar

local btnMaximize = Instance.new("TextButton")
btnMaximize.Size = UDim2.new(0, 28, 1, 0)
btnMaximize.Position = UDim2.new(1, -56, 0, 0)
btnMaximize.BackgroundTransparency = 1
btnMaximize.Text = "□"
btnMaximize.TextColor3 = Color3.fromRGB(180, 210, 255)
btnMaximize.TextSize = 16
btnMaximize.Font = Enum.Font.Gotham
btnMaximize.Parent = titleBar

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 28, 1, 0)
btnClose.Position = UDim2.new(1, -28, 0, 0)
btnClose.BackgroundTransparency = 1
btnClose.Text = "✕"
btnClose.TextColor3 = Color3.fromRGB(255, 100, 100)
btnClose.TextSize = 16
btnClose.Font = Enum.Font.Gotham
btnClose.Parent = titleBar

-- СТАТУС
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 22)
status.Position = UDim2.new(0, 12, 0, 44)
status.BackgroundTransparency = 1
status.Text = "DISABLED"
status.TextColor3 = Color3.fromRGB(100, 150, 200)
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Font = Enum.Font.Gotham
status.Parent = menu

-- ИНФО О РЕЖИМЕ
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -24, 0, 22)
infoLabel.Position = UDim2.new(0, 12, 0, 66)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "MODE: STICK (1st person only)"
infoLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
infoLabel.TextSize = 11
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Font = Enum.Font.Gotham
infoLabel.Parent = menu

-- КНОПКА ВКЛ/ВЫКЛ
local btnToggle = Instance.new("TextButton")
btnToggle.Size = UDim2.new(1, -24, 0, 34)
btnToggle.Position = UDim2.new(0, 12, 0, 94)
btnToggle.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
btnToggle.BorderSizePixel = 0
btnToggle.Text = "ACTIVATE"
btnToggle.TextColor3 = Color3.fromRGB(180, 210, 255)
btnToggle.TextSize = 12
btnToggle.Font = Enum.Font.GothamMedium
btnToggle.Parent = menu

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = btnToggle

-- КНОПКА СКРЫТЬ ПРИЦЕЛ
local btnHide = Instance.new("TextButton")
btnHide.Size = UDim2.new(1, -24, 0, 34)
btnHide.Position = UDim2.new(0, 12, 0, 136)
btnHide.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
btnHide.BorderSizePixel = 0
btnHide.Text = "HIDE CROSSHAIR"
btnHide.TextColor3 = Color3.fromRGB(180, 210, 255)
btnHide.TextSize = 12
btnHide.Font = Enum.Font.GothamMedium
btnHide.Parent = menu

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 6)
btnCorner2.Parent = btnHide

-- КНОПКА ВЫХОДА
local btnExit = Instance.new("TextButton")
btnExit.Size = UDim2.new(1, -24, 0, 34)
btnExit.Position = UDim2.new(0, 12, 0, 178)
btnExit.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
btnExit.BorderSizePixel = 0
btnExit.Text = "EXIT SCRIPT"
btnExit.TextColor3 = Color3.fromRGB(255, 150, 150)
btnExit.TextSize = 12
btnExit.Font = Enum.Font.GothamMedium
btnExit.Parent = menu

local btnCorner3 = Instance.new("UICorner")
btnCorner3.CornerRadius = UDim.new(0, 6)
btnCorner3.Parent = btnExit

-- ПРИЦЕЛ (ТОЧКА)
local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0, 4, 0, 4)
crosshair.Position = UDim2.new(0.5, -2, 0.5, -2)
crosshair.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
crosshair.BorderSizePixel = 0
crosshair.Parent = gui

local glow = Instance.new("Frame")
glow.Size = UDim2.new(0, 12, 0, 12)
glow.Position = UDim2.new(0.5, -6, 0.5, -6)
glow.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
glow.BackgroundTransparency = 0.8
glow.BorderSizePixel = 0
glow.Parent = crosshair

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(1, 0)
glowCorner.Parent = glow

-- ПРОВЕРКА ОТ 1-ГО ЛИЦА
local function checkFirstPerson()
    if not Player.Character then return false end
    local head = Player.Character:FindFirstChild("Head")
    if not head then return false end
    
    local camPos = Camera.CFrame.Position
    local headPos = head.Position
    local dist = (camPos - headPos).Magnitude
    
    -- Если камера ближе чем 2 студии к голове — считаем 1 лицом
    return dist < 2.5
end

-- ПОИСК ЦЕЛИ (по центру экрана)
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
                if dist < 250 and dist < bestDist then
                    best = plr
                    bestDist = dist
                end
            end
        end
    end
    
    return best
end

-- ОСНОВНАЯ ЛОГИКА (доведение до точки)
local function stickAim()
    if not enabled then return end
    
    -- Проверка на 1 лицо
    if not checkFirstPerson() then
        status.Text = "ERROR: 1ST PERSON ONLY"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    -- Поиск цели
    if not target or not target.Character then
        target = findTarget()
        if not target then
            status.Text = "NO TARGET"
            status.TextColor3 = Color3.fromRGB(255, 200, 100)
            return
        end
    end
    
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Получаем позицию цели на экране
    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then return end
    
    -- Центр экрана
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Вектор отклонения от центра
    local offset = Vector2.new(screenPos.X - center.X, screenPos.Y - center.Y)
    
    -- Если цель уже в центре (с погрешностью 0.5 пикселя) — ничего не делаем
    if offset.Magnitude < 0.5 then
        status.Text = "LOCKED (centered)"
        status.TextColor3 = Color3.fromRGB(100, 255, 200)
        return
    end
    
    -- Вычисляем новое направление камеры
    local camPos = Camera.CFrame.Position
    local lookAt = root.Position
    
    -- Корректируем направление, чтобы цель оказалась строго в центре
    -- Используем Camera:WorldToViewportPoint и обратное преобразование
    local viewport = Camera.ViewportSize
    local aspect = viewport.X / viewport.Y
    
    -- Получаем текущий CFrame камеры
    local currentCF = Camera.CFrame
    
    -- Вычисляем направление на цель
    local direction = (root.Position - camPos).Unit
    
    -- Создаём новый CFrame, смотрящий прямо на цель
    local newCF = CFrame.lookAt(camPos, root.Position)
    
    -- Применяем с максимальной точностью (без Lerp, чтобы точно в центр)
    Camera.CFrame = Camera.CFrame:Lerp(newCF, SNAP_SPEED)
    
    status.Text = "STICKING..."
    status.TextColor3 = Color3.fromRGB(200, 200, 255)
end

-- ВКЛЮЧЕНИЕ
local function activate()
    if not checkFirstPerson() then
        status.Text = "ERROR: 1ST PERSON ONLY"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        btnToggle.Text = "RETRY"
        return
    end
    
    enabled = true
    target = findTarget()
    if not target then
        enabled = false
        status.Text = "NO TARGET"
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
        btnToggle.Text = "RETRY"
        return
    end
    status.Text = "ACTIVE"
    status.TextColor3 = Color3.fromRGB(100, 255, 200)
    btnToggle.Text = "DEACTIVATE"
end

-- ВЫКЛЮЧЕНИЕ
local function deactivate()
    enabled = false
    target = nil
    status.Text = "DISABLED"
    status.TextColor3 = Color3.fromRGB(100, 150, 200)
    btnToggle.Text = "ACTIVATE"
end

-- КНОПКИ
btnToggle.MouseButton1Click:Connect(function()
    if not enabled then
        activate()
    else
        deactivate()
    end
end)

btnHide.MouseButton1Click:Connect(function()
    visible = not visible
    crosshair.Visible = visible
    btnHide.Text = visible and "HIDE CROSSHAIR" or "SHOW CROSSHAIR"
end)

btnMinimize.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        menu:TweenSize(UDim2.new(0, 200, 0, 32), "Out", "Quad", 0.3, true)
        status.Visible = false
        infoLabel.Visible = false
        btnToggle.Visible = false
        btnHide.Visible = false
        btnExit.Visible = false
        btnMinimize.Text = "□"
    else
        menu:TweenSize(UDim2.new(0, 280, 0, 210), "Out", "Quad", 0.3, true)
        status.Visible = true
        infoLabel.Visible = true
        btnToggle.Visible = true
        btnHide.Visible = true
        btnExit.Visible = true
        btnMinimize.Text = "─"
    end
end)

btnMaximize.MouseButton1Click:Connect(function()
    isMaximized = not isMaximized
    if isMaximized then
        menu:TweenSize(UDim2.new(0, 400, 0, 280), "Out", "Quad", 0.3, true)
        menu:TweenPosition(UDim2.new(0.5, -200, 0.5, -140), "Out", "Quad", 0.3, true)
    else
        menu:TweenSize(UDim2.new(0, 280, 0, 210), "Out", "Quad", 0.3, true)
        menu:TweenPosition(UDim2.new(0, 20, 0, 20), "Out", "Quad", 0.3, true)
    end
end)

btnClose.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

btnExit.MouseButton1Click:Connect(function()
    gui:Destroy()
    enabled = false
    target = nil
end)

-- КЛАВИАТУРА
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.One then
        if not enabled then
            activate()
        else
            deactivate()
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Two then
        visible = not visible
        crosshair.Visible = visible
        btnHide.Text = visible and "HIDE CROSSHAIR" or "SHOW CROSSHAIR"
    end
end)

-- ГЛАВНЫЙ ЦИКЛ
RunService.RenderStepped:Connect(function()
    if enabled then
        stickAim()
    end
end)

-- УВЕДОМЛЕНИЕ
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "AIM LOCK v7.0",
    Text = "1 - Stick | 2 - Hide | 1st person only",
    Duration = 4
})

print(" AIM LOCK v7.0 LOADED")
print(" 1 - Stick/Unstick (1st person only)")
print(" 2 - Hide/Show crosshair")
print(" Locks target to center with pixel precision")
