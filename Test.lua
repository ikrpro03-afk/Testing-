-- AIM LOCK v8.0 | FULL CONTROL
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer

-- ========== НАСТРОЙКИ ==========
local SNAP_SPEED = 0.92          -- скорость доведения (0.8-1.0)
local AIM_PART = "Head"          -- HumanoidRootPart / Head

-- ========== РЕЖИМЫ ==========
local MODE = {
    OBJECTS = "OBJECTS",
    PLAYERS = "PLAYERS"
}

local AIM_TARGET = {
    HEAD = "Head",
    BODY = "HumanoidRootPart"
}

-- ========== СОСТОЯНИЕ ==========
local currentMode = MODE.OBJECTS
local aimPart = AIM_TARGET.HEAD
local enabled = false
local visible = true
local target = nil
local frozenPoint = nil          -- точка фиксации для OBJECTS
local isMinimized = false
local isMaximized = false

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "AimLock"
gui.ResetOnSpawn = false
gui.Parent = Player.PlayerGui

-- ОКНО
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 300, 0, 280)
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
titleText.Text = "AIM LOCK v8.0"
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
btnMinimize.TextSize = 20
btnMinimize.Font = Enum.Font.Gotham
btnMinimize.Parent = titleBar

local btnMaximize = Instance.new("TextButton")
btnMaximize.Size = UDim2.new(0, 28, 1, 0)
btnMaximize.Position = UDim2.new(1, -56, 0, 0)
btnMaximize.BackgroundTransparency = 1
btnMaximize.Text = "□"
btnMaximize.TextColor3 = Color3.fromRGB(180, 210, 255)
btnMaximize.TextSize = 18
btnMaximize.Font = Enum.Font.Gotham
btnMaximize.Parent = titleBar

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 28, 1, 0)
btnClose.Position = UDim2.new(1, -28, 0, 0)
btnClose.BackgroundTransparency = 1
btnClose.Text = "✕"
btnClose.TextColor3 = Color3.fromRGB(255, 60, 60)
btnClose.TextSize = 18
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

-- РЕЖИМ
local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(1, -24, 0, 22)
modeLabel.Position = UDim2.new(0, 12, 0, 66)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "MODE: OBJECTS"
modeLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
modeLabel.TextSize = 11
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.Font = Enum.Font.Gotham
modeLabel.Parent = menu

-- ЦЕЛЬ ДЛЯ ИГРОКОВ
local aimLabel = Instance.new("TextLabel")
aimLabel.Size = UDim2.new(1, -24, 0, 22)
aimLabel.Position = UDim2.new(0, 12, 0, 88)
aimLabel.BackgroundTransparency = 1
aimLabel.Text = "AIM: HEAD"
aimLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
aimLabel.TextSize = 11
aimLabel.TextXAlignment = Enum.TextXAlignment.Left
aimLabel.Font = Enum.Font.Gotham
aimLabel.Parent = menu

-- КНОПКА ВКЛ/ВЫКЛ
local btnToggle = Instance.new("TextButton")
btnToggle.Size = UDim2.new(1, -24, 0, 34)
btnToggle.Position = UDim2.new(0, 12, 0, 116)
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

-- КНОПКА СМЕНЫ РЕЖИМА
local btnMode = Instance.new("TextButton")
btnMode.Size = UDim2.new(0, 140, 0, 30)
btnMode.Position = UDim2.new(0, 12, 0, 156)
btnMode.BackgroundColor3 = Color3.fromRGB(0, 30, 60)
btnMode.BorderSizePixel = 0
btnMode.Text = "SWITCH MODE"
btnMode.TextColor3 = Color3.fromRGB(180, 210, 255)
btnMode.TextSize = 11
btnMode.Font = Enum.Font.GothamMedium
btnMode.Parent = menu

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 6)
btnCorner2.Parent = btnMode

-- КНОПКА СМЕНЫ ЦЕЛИ (HEAD/BODY)
local btnAimPart = Instance.new("TextButton")
btnAimPart.Size = UDim2.new(0, 130, 0, 30)
btnAimPart.Position = UDim2.new(1, -142, 0, 156)
btnAimPart.BackgroundColor3 = Color3.fromRGB(0, 30, 60)
btnAimPart.BorderSizePixel = 0
btnAimPart.Text = "SWITCH TO BODY"
btnAimPart.TextColor3 = Color3.fromRGB(180, 210, 255)
btnAimPart.TextSize = 11
btnAimPart.Font = Enum.Font.GothamMedium
btnAimPart.Parent = menu

local btnCorner3 = Instance.new("UICorner")
btnCorner3.CornerRadius = UDim.new(0, 6)
btnCorner3.Parent = btnAimPart

-- КНОПКА СКРЫТЬ ПРИЦЕЛ
local btnHide = Instance.new("TextButton")
btnHide.Size = UDim2.new(1, -24, 0, 34)
btnHide.Position = UDim2.new(0, 12, 0, 194)
btnHide.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
btnHide.BorderSizePixel = 0
btnHide.Text = "HIDE CROSSHAIR"
btnHide.TextColor3 = Color3.fromRGB(180, 210, 255)
btnHide.TextSize = 12
btnHide.Font = Enum.Font.GothamMedium
btnHide.Parent = menu

local btnCorner4 = Instance.new("UICorner")
btnCorner4.CornerRadius = UDim.new(0, 6)
btnCorner4.Parent = btnHide

-- КНОПКА ВЫХОДА
local btnExit = Instance.new("TextButton")
btnExit.Size = UDim.new(1, -24, 0, 34)
btnExit.Position = UDim2.new(0, 12, 0, 234)
btnExit.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
btnExit.BorderSizePixel = 0
btnExit.Text = "EXIT SCRIPT"
btnExit.TextColor3 = Color3.fromRGB(255, 150, 150)
btnExit.TextSize = 12
btnExit.Font = Enum.Font.GothamMedium
btnExit.Parent = menu

local btnCorner5 = Instance.new("UICorner")
btnCorner5.CornerRadius = UDim.new(0, 6)
btnCorner5.Parent = btnExit

-- ========== ПРИЦЕЛ (ТОЧКА) ==========
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

-- ========== ЛОГИКА ==========

-- ПОИСК ОБЪЕКТА (всё, что можно зафиксировать)
local function findObject()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best = nil
    local bestDist = math.huge
    
    -- Ищем части объектов (не игроков)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Parent ~= Player.Character then
            -- Проверяем, что это не игрок
            local isPlayerPart = false
            local parent = v.Parent
            while parent do
                if parent:IsA("Model") and Players:GetPlayerFromCharacter(parent) then
                    isPlayerPart = true
                    break
                end
                parent = parent.Parent
            end
            
            if not isPlayerPart then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < 200 and dist < bestDist then
                        best = v
                        bestDist = dist
                    end
                end
            end
        end
    end
    
    return best
end

-- ПОИСК ИГРОКА
local function findPlayer()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best = nil
    local bestDist = math.huge
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild(aimPart) then
            local part = plr.Character[aimPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
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

-- ФИКСАЦИЯ НА ОБЪЕКТЕ
local function stickToObject(obj)
    if not obj or not obj.Parent then
        target = nil
        return false
    end
    
    local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
    if not onScreen then return false end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local offset = Vector2.new(pos.X - center.X, pos.Y - center.Y)
    
    if offset.Magnitude < 0.5 then
        return true
    end
    
    -- Доводим до центра
    local camPos = Camera.CFrame.Position
    local newCF = CFrame.lookAt(camPos, obj.Position)
    Camera.CFrame = Camera.CFrame:Lerp(newCF, SNAP_SPEED)
    
    return true
end

-- ФИКСАЦИЯ НА ИГРОКЕ
local function stickToPlayer(plr)
    if not plr or not plr.Character or not plr.Character:FindFirstChild(aimPart) then
        target = nil
        return false
    end
    
    local part = plr.Character[aimPart]
    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return false end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local offset = Vector2.new(pos.X - center.X, pos.Y - center.Y)
    
    if offset.Magnitude < 0.5 then
        return true
    end
    
    local camPos = Camera.CFrame.Position
    local newCF = CFrame.lookAt(camPos, part.Position)
    Camera.CFrame = Camera.CFrame:Lerp(newCF, SNAP_SPEED)
    
    return true
end

-- ГЛАВНАЯ ФУНКЦИЯ
local function stickAim()
    if not enabled then return end
    
    if currentMode == MODE.OBJECTS then
        if not target or not target.Parent then
            target = findObject()
            if not target then
                status.Text = "NO OBJECT"
                status.TextColor3 = Color3.fromRGB(255, 200, 100)
                return
            end
            status.Text = "OBJECT LOCKED"
            status.TextColor3 = Color3.fromRGB(100, 255, 200)
        end
        
        if not stickToObject(target) then
            target = nil
        end
        
    elseif currentMode == MODE.PLAYERS then
        if not target or not target.Character or not target.Character:FindFirstChild(aimPart) then
            target = findPlayer()
            if not target then
                status.Text = "NO PLAYER"
                status.TextColor3 = Color3.fromRGB(255, 200, 100)
                return
            end
            status.Text = "PLAYER LOCKED"
            status.TextColor3 = Color3.fromRGB(100, 255, 200)
        end
        
        if not stickToPlayer(target) then
            target = nil
        end
    end
end

-- ========== УПРАВЛЕНИЕ ==========

-- ВКЛЮЧЕНИЕ
local function activate()
    enabled = true
    if currentMode == MODE.OBJECTS then
        target = findObject()
        if not target then
            enabled = false
            status.Text = "NO OBJECT"
            status.TextColor3 = Color3.fromRGB(255, 200, 100)
            btnToggle.Text = "RETRY"
            return
        end
        status.Text = "OBJECT LOCKED"
        status.TextColor3 = Color3.fromRGB(100, 255, 200)
    else
        target = findPlayer()
        if not target then
            enabled = false
            status.Text = "NO PLAYER"
            status.TextColor3 = Color3.fromRGB(255, 200, 100)
            btnToggle.Text = "RETRY"
            return
        end
        status.Text = "PLAYER LOCKED"
        status.TextColor3 = Color3.fromRGB(100, 255, 200)
    end
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

-- СМЕНА РЕЖИМА
local function switchMode()
    if currentMode == MODE.OBJECTS then
        currentMode = MODE.PLAYERS
        modeLabel.Text = "MODE: PLAYERS"
        btnMode.Text = "SWITCH MODE"
        aimLabel.Visible = true
        btnAimPart.Visible = true
    else
        currentMode = MODE.OBJECTS
        modeLabel.Text = "MODE: OBJECTS"
        btnMode.Text = "SWITCH MODE"
        aimLabel.Visible = false
        btnAimPart.Visible = false
    end
    
    if enabled then
        deactivate()
        activate()
    end
end

-- СМЕНА ЦЕЛИ (HEAD/BODY)
local function switchAimPart()
    if aimPart == AIM_TARGET.HEAD then
        aimPart = AIM_TARGET.BODY
        aimLabel.Text = "AIM: BODY"
        btnAimPart.Text = "SWITCH TO HEAD"
    else
        aimPart = AIM_TARGET.HEAD
        aimLabel.Text = "AIM: HEAD"
        btnAimPart.Text = "SWITCH TO BODY"
    end
    
    if enabled and currentMode == MODE.PLAYERS then
        deactivate()
        activate()
    end
end

-- КНОПКИ
btnToggle.MouseButton1Click:Connect(function()
    if not enabled then activate() else deactivate() end
end)

btnMode.MouseButton1Click:Connect(switchMode)

btnAimPart.MouseButton1Click:Connect(switchAimPart)

btnHide.MouseButton1Click:Connect(function()
    visible = not visible
    crosshair.Visible = visible
    btnHide.Text = visible and "HIDE CROSSHAIR" or "SHOW CROSSHAIR"
end)

-- КНОПКИ ОКНА
btnMinimize.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        menu:TweenSize(UDim2.new(0, 200, 0, 32), "Out", "Quad", 0.3, true)
        status.Visible = false
        modeLabel.Visible = false
        aimLabel.Visible = false
        btnToggle.Visible = false
        btnMode.Visible = false
        btnAimPart.Visible = false
        btnHide.Visible = false
        btnExit.Visible = false
        btnMinimize.Text = "□"
    else
        menu:TweenSize(UDim2.new(0, 300, 0, 280), "Out", "Quad", 0.3, true)
        status.Visible = true
        modeLabel.Visible = true
        if currentMode == MODE.PLAYERS then aimLabel.Visible = true end
        btnToggle.Visible = true
        btnMode.Visible = true
        if currentMode == MODE.PLAYERS then btnAimPart.Visible = true end
        btnHide.Visible = true
        btnExit.Visible = true
        btnMinimize.Text = "─"
    end
end)

btnMaximize.MouseButton1Click:Connect(function()
    isMaximized = not isMaximized
    if isMaximized then
        menu:TweenSize(UDim2.new(0, 420, 0, 340), "Out", "Quad", 0.3, true)
        menu:TweenPosition(UDim2.new(0.5, -210, 0.5, -170), "Out", "Quad", 0.3, true)
    else
        menu:TweenSize(UDim2.new(0, 300, 0, 280), "Out", "Quad", 0.3, true)
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
        if not enabled then activate() else deactivate() end
    end
    
    if input.KeyCode == Enum.KeyCode.Two then
        visible = not visible
        crosshair.Visible = visible
        btnHide.Text = visible and "HIDE CROSSHAIR" or "SHOW CROSSHAIR"
    end
    
    if input.KeyCode == Enum.KeyCode.Three then
        switchMode()
    end
    
    if input.KeyCode == Enum.KeyCode.Four then
        if currentMode == MODE.PLAYERS then
            switchAimPart()
        end
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
    Title = "AIM LOCK v8.0",
    Text = "1 - Toggle | 3 - Mode | 4 - Head/Body",
    Duration = 4
})

print("✅ AIM LOCK v8.0 LOADED")
print("📌 1 - Toggle ON/OFF")
print("📌 2 - Hide/Show crosshair")
print("📌 3 - Switch mode (OBJECTS ↔ PLAYERS)")
print("📌 4 - Switch aim (HEAD ↔ BODY) [PLAYERS mode]")
