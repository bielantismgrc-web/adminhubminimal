-- Minimal Admin Hub / servidor
-- Coloque como Script em ServerScriptService.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ADMIN_USER_IDS = {
    123456789, -- TROQUE pelo seu UserId numérico
}

local function isAdmin(player)
    for _, id in ipairs(ADMIN_USER_IDS) do
        if player.UserId == id then
            return true
        end
    end
    return false
end

local remote = ReplicatedStorage:FindFirstChild("MinimalAdminHubEvent")
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "MinimalAdminHubEvent"
    remote.Parent = ReplicatedStorage
end

local function findPlayer(query)
    query = tostring(query or ""):lower()
    if query == "" then return nil end
    if query == "me" then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == query or p.DisplayName:lower() == query then
            return p
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #query) == query
            or p.DisplayName:lower():sub(1, #query) == query then
            return p
        end
    end
    return nil
end

remote.OnServerEvent:Connect(function(player, action, value)
    if not isAdmin(player) then
        warn(("MinimalAdminHub: %s tentou usar comando sem permissão"):format(player.Name))
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if action == "speed" and humanoid then
        local speed = math.clamp(tonumber(value) or 16, 0, 100)
        humanoid.WalkSpeed = speed

    elseif action == "jump" and humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = math.clamp(tonumber(value) or 50, 0, 150)

    elseif action == "teleport" and root then
        local target = findPlayer(value)
        if target and target ~= player then
            local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                root.CFrame = targetRoot.CFrame * CFrame.new(3, 0, 0)
            end
        end

    elseif action == "char" and humanoid then
        local target
        if tostring(value):lower() == "me" then
            target = player
        else
            target = findPlayer(value)
        end
        if not target then return end

        local targetHumanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
        if not targetHumanoid then return end

        local ok, description = pcall(function()
            return targetHumanoid:GetAppliedDescription()
        end)
        if ok and description then
            pcall(function()
                humanoid:ApplyDescription(description)
            end)
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if isAdmin(player) then
            print("Minimal Admin Hub pronto para " .. player.Name)
        end
    end)
end)
