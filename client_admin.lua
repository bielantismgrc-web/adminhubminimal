-- Minimal Admin Hub / interface
-- Coloque como LocalScript em StarterPlayer > StarterPlayerScripts.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("MinimalAdminHubEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "MinimalAdminHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(310, 390)
frame.Position = UDim2.new(0, 24, 0.5, -195)
frame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(64, 69, 82)
outline.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 42)
title.Position = UDim2.fromOffset(12, 4)
title.BackgroundTransparency = 1
title.Text = "MINIMAL  /  ADMIN HUB"
title.TextColor3 = Color3.fromRGB(242, 244, 250)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 22)
status.Position = UDim2.fromOffset(12, 43)
status.BackgroundTransparency = 1
status.Text = "Pronto"
status.TextColor3 = Color3.fromRGB(160, 168, 184)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local function button(text, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -24, 0, 32)
    b.Position = UDim2.fromOffset(12, y)
    b.BackgroundColor3 = Color3.fromRGB(41, 44, 54)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(238, 240, 247)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.Activated:Connect(callback)
    return b
end

local function setStatus(text)
    status.Text = text
end

-- Arrastar pelo título
local dragging, dragStart, startPosition
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

button("Velocidade: 32", 72, function()
    remote:FireServer("speed", 32)
    setStatus("Solicitada velocidade 32")
end)

button("Velocidade normal: 16", 110, function()
    remote:FireServer("speed", 16)
    setStatus("Solicitada velocidade normal")
end)

button("Pulo alto: 90", 148, function()
    remote:FireServer("jump", 90)
    setStatus("Solicitado pulo alto")
end)

button("Pulo normal: 50", 186, function()
    remote:FireServer("jump", 50)
    setStatus("Solicitado pulo normal")
end)

local targetBox = Instance.new("TextBox")
targetBox.Size = UDim2.new(1, -24, 0, 32)
targetBox.Position = UDim2.fromOffset(12, 224)
targetBox.BackgroundColor3 = Color3.fromRGB(32, 35, 43)
targetBox.BorderSizePixel = 0
targetBox.PlaceholderText = "Nome do jogador"
targetBox.Text = ""
targetBox.TextColor3 = Color3.fromRGB(240, 242, 248)
targetBox.PlaceholderColor3 = Color3.fromRGB(145, 152, 168)
targetBox.Font = Enum.Font.Gotham
targetBox.TextSize = 12
targetBox.ClearTextOnFocus = false
targetBox.Parent = frame
Instance.new("UICorner", targetBox).CornerRadius = UDim.new(0, 7)

button("Teletransportar até jogador", 262, function()
    if targetBox.Text == "" then return setStatus("Digite um nome primeiro") end
    remote:FireServer("teleport", targetBox.Text)
    setStatus("Solicitado teleporte")
end)

button("Copiar aparência  ;char", 300, function()
    if targetBox.Text == "" then return setStatus("Digite um nome primeiro") end
    remote:FireServer("char", targetBox.Text)
    setStatus("Solicitada cópia de aparência")
end)

button("Fechar painel", 338, function()
    gui:Destroy()
end)

-- Comando de chat: ;char NomeDoJogador
local function handleMessage(message)
    local target = message:match("^;char%s+(.+)$")
    if target then
        remote:FireServer("char", target)
        setStatus("Solicitada aparência de " .. target)
    end
end

player.Chatted:Connect(handleMessage)
