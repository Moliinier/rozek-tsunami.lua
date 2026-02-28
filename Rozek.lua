--[[
  ROZEK v2
  - God Mode (bajo el suelo, invulnerable)
  - Instant Pickup: SIEMPRE ACTIVO, sin botón
  - Auto Brain: agarra brainrots automáticamente al estar cerca
  - GUI compacta con 2 botones, arrastrable
  - Título "Rozek" centrado con rainbow
]]

local Players        = game:GetService("Players")
local RS             = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local lp             = Players.LocalPlayer
local cam            = workspace.CurrentCamera
local pg             = lp.PlayerGui

local OFFSET_Y   = -18
local CAM_HEIGHT = 7

local heartbeat
local fakePart
local godData

local godActive        = false
local autoBrainActive  = false
local autoBrainThread  = nil
local BtnGod, BtnAuto

-- ══════════════════════════════════════
--  HELPER: suelo real con Raycast
-- ══════════════════════════════════════
local function getGroundY(pos, character)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    if character then
        rayParams.FilterDescendantsInstances = {character}
    end
    local offsets = {
        Vector3.new(0,0,0), Vector3.new(3,0,0),
        Vector3.new(-3,0,0), Vector3.new(0,0,3), Vector3.new(0,0,-3),
    }
    local bestY = nil
    for _, offset in ipairs(offsets) do
        local origin = Vector3.new(pos.X+offset.X, pos.Y+50, pos.Z+offset.Z)
        local result = workspace:Raycast(origin, Vector3.new(0,-200,0), rayParams)
        if result and (bestY == nil or result.Position.Y > bestY) then
            bestY = result.Position.Y
        end
    end
    return bestY or (godData and godData.surfaceY or pos.Y)
end

-- ══════════════════════════════════════
--  GOD MODE: ACTIVAR
-- ══════════════════════════════════════
local function activate()
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local surfaceY = root.Position.Y
    local targetY  = surfaceY + OFFSET_Y
    godData = {surfaceY = surfaceY, targetY = targetY}

    root.AssemblyLinearVelocity = Vector3.new(0,0,0)
    local yaw = select(2, root.CFrame:ToEulerAnglesYXZ())
    root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z) * CFrame.Angles(0, yaw, 0)

    fakePart              = Instance.new("Part")
    fakePart.Name         = "__GodFakePart__"
    fakePart.Anchored     = true
    fakePart.CanCollide   = false
    fakePart.Transparency = 1
    fakePart.Size         = Vector3.new(1,1,1)
    fakePart.Position     = Vector3.new(root.Position.X, surfaceY+CAM_HEIGHT, root.Position.Z)
    fakePart.Parent       = workspace

    cam.CameraType    = Enum.CameraType.Custom
    cam.CameraSubject = fakePart

    local FLY_SPEED = 800

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity  = Vector3.new(0, 0, 0)
    bv.Parent    = root

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P         = 1e4
    bg.CFrame    = root.CFrame
    bg.Parent    = root

    heartbeat = RS.Heartbeat:Connect(function()
        local c = lp.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end

        local yawNow = select(2, r.CFrame:ToEulerAnglesYXZ())
        r.CFrame = CFrame.new(r.Position.X, targetY, r.Position.Z) * CFrame.Angles(0, yawNow, 0)

        local move = h.MoveDirection

        if move.Magnitude > 0.1 then
            local camLook = cam.CFrame.LookVector
            local forward = Vector3.new(camLook.X, 0, camLook.Z).Unit
            local right   = Vector3.new(camLook.Z, 0, -camLook.X).Unit

            local dot_f = Vector3.new(move.X, 0, move.Z):Dot(forward)
            local dot_r = Vector3.new(move.X, 0, move.Z):Dot(right)
            if forward.Magnitude < 0.01 then dot_f = 0 end
            local dir = (forward * dot_f + right * dot_r)
            if dir.Magnitude > 0 then dir = dir.Unit end

            bv.Velocity = dir * FLY_SPEED
            bg.CFrame   = CFrame.new(r.Position, r.Position + dir)
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end

        fakePart.Position = Vector3.new(r.Position.X, surfaceY+CAM_HEIGHT, r.Position.Z)
    end)

    godData.bv = bv
    godData.bg = bg
end

-- ══════════════════════════════════════
--  GOD MODE: DESACTIVAR
-- ══════════════════════════════════════
local function deactivate()
    if heartbeat then heartbeat:Disconnect(); heartbeat = nil end
    if fakePart  then fakePart:Destroy();    fakePart  = nil  end
    if godData then
        if godData.bv and godData.bv.Parent then godData.bv:Destroy() end
        if godData.bg and godData.bg.Parent then godData.bg:Destroy() end
    end

    cam.CameraType = Enum.CameraType.Custom
    local char = lp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then cam.CameraSubject = hum end

    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local safeY = getGroundY(root.Position, char) + 3
        local yaw   = select(2, root.CFrame:ToEulerAnglesYXZ())
        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        root.CFrame = CFrame.new(root.Position.X, safeY, root.Position.Z) * CFrame.Angles(0, yaw, 0)
    end
    godData = nil
end

local function resetOnDeath()
    if heartbeat then heartbeat:Disconnect(); heartbeat = nil end
    if fakePart  then fakePart:Destroy();    fakePart  = nil  end
    if godData then
        if godData.bv and godData.bv.Parent then godData.bv:Destroy() end
        if godData.bg and godData.bg.Parent then godData.bg:Destroy() end
    end
    godData   = nil
    godActive = false
    cam.CameraType = Enum.CameraType.Custom
    autoBrainActive = false
    if autoBrainThread then
        task.cancel(autoBrainThread)
        autoBrainThread = nil
    end
    if BtnGod then
        BtnGod.Text             = "⚡ God Mode"
        BtnGod.BackgroundColor3 = Color3.fromRGB(20, 50, 20)
    end
    if BtnAuto then
        BtnAuto.Text             = "🧠 Auto Brain"
        BtnAuto.BackgroundColor3 = Color3.fromRGB(30, 20, 55)
    end
end

lp.CharacterAdded:Connect(function(char)
    resetOnDeath()
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        cam.CameraSubject = hum
        hum.Died:Connect(resetOnDeath)
    end
end)

local currentChar = lp.Character
if currentChar then
    local hum = currentChar:FindFirstChildOfClass("Humanoid")
    if hum then hum.Died:Connect(resetOnDeath) end
end

-- ══════════════════════════════════════
--  INSTANT PICKUP — SIEMPRE ACTIVO
-- ══════════════════════════════════════
local originalDurations = {}

local function isPickupPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return false end
    if prompt.HoldDuration <= 0 then return false end

    local ancestor = prompt.Parent
    while ancestor and ancestor ~= workspace do
        if ancestor:IsA("Model") then
            if ancestor:HasTag("Brainrot") or ancestor:HasTag("HoldingLuckyBlock") then
                return true
            end
        end
        ancestor = ancestor.Parent
    end

    local actionLower = prompt.ActionText:lower()
    local keywords = {"pick", "toma", "take", "coger", "collect", "cobrar", "place", "coloca", "poner", "sell", "vend"}
    for _, kw in ipairs(keywords) do
        if actionLower:find(kw) then return true end
    end
    return false
end

local function applyInstant(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if isPickupPrompt(prompt) then
        if not originalDurations[prompt] then
            originalDurations[prompt] = prompt.HoldDuration
        end
        prompt.HoldDuration = 0
    end
end

workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        originalDurations[obj] = nil
    end
end)

for _, obj in ipairs(workspace:GetDescendants()) do
    applyInstant(obj)
end

workspace.DescendantAdded:Connect(function(obj)
    task.defer(function() applyInstant(obj) end)
end)

task.spawn(function()
    while true do
        task.wait(2)
        for _, obj in ipairs(workspace:GetDescendants()) do
            applyInstant(obj)
        end
    end
end)

-- ══════════════════════════════════════
--  AUTO BRAIN
-- ══════════════════════════════════════
local AUTO_RANGE    = 8
local AUTO_INTERVAL = 0.05
local trackedPrompts = {}

local function isBrainrotPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return false end

    local ancestor = prompt.Parent
    while ancestor and ancestor ~= workspace do
        if ancestor:IsA("Model") then
            if ancestor:HasTag("Brainrot") or ancestor:HasTag("HoldingLuckyBlock") then
                return true
            end
        end
        ancestor = ancestor.Parent
    end

    local actionLower = prompt.ActionText:lower()
    local keywords = {"pick", "toma", "take", "coger", "collect", "cobrar", "brainrot"}
    for _, kw in ipairs(keywords) do
        if actionLower:find(kw) then return true end
    end
    return false
end

for _, obj in ipairs(workspace:GetDescendants()) do
    if isBrainrotPrompt(obj) then trackedPrompts[obj] = true end
end

workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if isBrainrotPrompt(obj) then trackedPrompts[obj] = true end
    end)
end)

workspace.DescendantRemoving:Connect(function(obj)
    trackedPrompts[obj] = nil
end)

local function getPromptPosition(prompt)
    local part = prompt.Parent
    if part and part:IsA("BasePart") then return part.Position end
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model then
        local base = model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
        if base then return base.Position end
    end
    return nil
end

local function firePrompt(prompt)
    prompt.HoldDuration = 0
    prompt.Enabled = true
    if fireproximityprompt then pcall(fireproximityprompt, prompt) end
    if triggerproximityprompt then pcall(triggerproximityprompt, prompt) end
    pcall(function() prompt.Triggered:Fire(lp) end)
end

local function startAutoBrain()
    if autoBrainThread then task.cancel(autoBrainThread); autoBrainThread = nil end
    autoBrainThread = task.spawn(function()
        local inRange = {}
        local firedAt = {}
        while autoBrainActive do
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local now = tick()
                for prompt, _ in pairs(trackedPrompts) do
                    if not prompt or not prompt.Parent then
                        trackedPrompts[prompt] = nil
                        inRange[prompt] = nil
                        firedAt[prompt] = nil
                    else
                        local promptPos = getPromptPosition(prompt)
                        if promptPos then
                            local dist = (root.Position - promptPos).Magnitude
                            if dist <= AUTO_RANGE then
                                local last = firedAt[prompt] or 0
                                if not inRange[prompt] or (now - last) >= 0.1 then
                                    firePrompt(prompt)
                                    firedAt[prompt] = now
                                    inRange[prompt] = true
                                end
                            else
                                inRange[prompt] = nil
                                firedAt[prompt] = nil
                            end
                        end
                    end
                end
            end
            task.wait(AUTO_INTERVAL)
        end
    end)
end

local function stopAutoBrain()
    autoBrainActive = false
    if autoBrainThread then task.cancel(autoBrainThread); autoBrainThread = nil end
end

-- ══════════════════════════════════════
--  GUI — Rozek v2
-- ══════════════════════════════════════
repeat task.wait() until lp.PlayerGui

pcall(function()
    if lp.PlayerGui:FindFirstChild("__Rozek__") then
        lp.PlayerGui.__Rozek__:Destroy()
    end
end)

local GUI = Instance.new("ScreenGui")
GUI.Name         = "__Rozek__"
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 10
GUI.Parent       = lp.PlayerGui

-- Frame principal — más ancho para 2 botones bien proporcionados
local Frame = Instance.new("Frame")
Frame.Size             = UDim2.new(0, 200, 0, 70)
Frame.Position         = UDim2.new(0.5, -100, 0, 12)
Frame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Frame.BorderSizePixel  = 0
Frame.Active           = true
Frame.Parent           = GUI
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local outerStroke = Instance.new("UIStroke", Frame)
outerStroke.Color        = Color3.fromRGB(60, 60, 90)
outerStroke.Thickness    = 1
outerStroke.Transparency = 0.4

-- TitleBar (drag zone)
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 22)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = Frame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

-- Parche esquinas inferiores rectas
local TitlePatch = Instance.new("Frame")
TitlePatch.Size             = UDim2.new(1, 0, 0, 10)
TitlePatch.Position         = UDim2.new(0, 0, 1, -10)
TitlePatch.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TitlePatch.BorderSizePixel  = 0
TitlePatch.Parent           = TitleBar

-- Título centrado
local Title = Instance.new("TextLabel")
Title.Size               = UDim2.new(1, 0, 1, 0)
Title.Position           = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3         = Color3.fromRGB(220, 220, 255)
Title.Font               = Enum.Font.GothamBold
Title.TextSize           = 11
Title.TextXAlignment     = Enum.TextXAlignment.Center
Title.Text               = "✦ Rozek"
Title.Parent             = TitleBar

-- Dot de estado
local StatusDot = Instance.new("Frame")
StatusDot.Size             = UDim2.new(0, 6, 0, 6)
StatusDot.Position         = UDim2.new(1, -12, 0.5, -3)
StatusDot.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
StatusDot.BorderSizePixel  = 0
StatusDot.Parent           = TitleBar
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local function updateDot()
    if godActive or autoBrainActive then
        StatusDot.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    else
        StatusDot.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end

-- Contenedor botones
local BtnContainer = Instance.new("Frame")
BtnContainer.Size             = UDim2.new(1, -12, 0, 36)
BtnContainer.Position         = UDim2.new(0, 6, 0, 26)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Parent           = Frame

local BtnLayout = Instance.new("UIListLayout", BtnContainer)
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.SortOrder     = Enum.SortOrder.LayoutOrder
BtnLayout.Padding       = UDim.new(0, 6)

local function makeBtn(text, bgColor, order)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0.5, -3, 1, 0)
    btn.BackgroundColor3 = bgColor
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 10
    btn.Text             = text
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = order
    btn.Parent           = BtnContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return btn
end

BtnGod  = makeBtn("⚡ God Mode",  Color3.fromRGB(18, 40, 18), 1)
BtnAuto = makeBtn("🧠 Auto Brain", Color3.fromRGB(22, 16, 40), 2)

-- Lógica botones — solo Activated para evitar doble toggle en móvil
BtnGod.Activated:Connect(function()
    godActive = not godActive
    if godActive then
        activate()
        BtnGod.Text             = "🛑 God OFF"
        BtnGod.BackgroundColor3 = Color3.fromRGB(55, 10, 10)
    else
        deactivate()
        BtnGod.Text             = "⚡ God Mode"
        BtnGod.BackgroundColor3 = Color3.fromRGB(18, 40, 18)
    end
    updateDot()
end)

BtnAuto.Activated:Connect(function()
    autoBrainActive = not autoBrainActive
    if autoBrainActive then
        BtnAuto.Text             = "🛑 Auto OFF"
        BtnAuto.BackgroundColor3 = Color3.fromRGB(55, 10, 10)
        startAutoBrain()
    else
        stopAutoBrain()
        BtnAuto.Text             = "🧠 Auto Brain"
        BtnAuto.BackgroundColor3 = Color3.fromRGB(22, 16, 40)
    end
    updateDot()
end)

-- DRAG táctil
local dragging   = false
local dragStart  = Vector2.new()
local panelStart = Vector2.new()

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging   = true
        dragStart  = Vector2.new(input.Position.X, input.Position.Y)
        panelStart = Vector2.new(Frame.Position.X.Offset, Frame.Position.Y.Offset)
    end
end)

UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = Vector2.new(input.Position.X - dragStart.X, input.Position.Y - dragStart.Y)
    local vp = cam.ViewportSize
    local nx = math.clamp(panelStart.X + delta.X, 0, vp.X - Frame.AbsoluteSize.X)
    local ny = math.clamp(panelStart.Y + delta.Y, 0, vp.Y - Frame.AbsoluteSize.Y)
    Frame.Position = UDim2.new(0, nx, 0, ny)
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ══════════════════════════════════════
--  RAINBOW — título y botones inactivos
-- ══════════════════════════════════════
local rainbowHue = 0
RS.Heartbeat:Connect(function(dt)
    rainbowHue = (rainbowHue + dt * 0.4) % 1

    local c1 = Color3.fromHSV(rainbowHue % 1,          0.85, 1)
    local c2 = Color3.fromHSV((rainbowHue + 0.5) % 1,  0.85, 1)
    local ct = Color3.fromHSV((rainbowHue + 0.25) % 1, 0.7,  1)

    -- Título siempre rainbow
    Title.TextColor3 = ct

    -- Botones solo si están inactivos
    if BtnGod  and not godActive       then BtnGod.TextColor3  = c1 end
    if BtnAuto and not autoBrainActive then BtnAuto.TextColor3 = c2 end
end)

print("[Rozek v2] Listo — God Mode | Auto Brain | Instant Pickup ON")
-- ══════════════════════════════════════
--  INFINITE JUMP
-- ══════════════════════════════════════
local infiniteJumpActive = false
local infiniteJumpConn   = nil
local BtnJump

local function startInfiniteJump()
    if infiniteJumpConn then infiniteJumpConn:Disconnect(); infiniteJumpConn = nil end
    infiniteJumpConn = UIS.JumpRequest:Connect(function()
        local char = lp.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function stopInfiniteJump()
    if infiniteJumpConn then infiniteJumpConn:Disconnect(); infiniteJumpConn = nil end
end

-- Conectar también al resetOnDeath existente
local _origResetOnDeath = resetOnDeath
resetOnDeath = function()
    _origResetOnDeath()
    infiniteJumpActive = false
    stopInfiniteJump()
    if BtnJump then
        BtnJump.Text             = "🦘 Inf Jump"
        BtnJump.BackgroundColor3 = Color3.fromRGB(20, 30, 55)
    end
end

-- Ampliar frame para el 3er botón
Frame.Size = UDim2.new(0, 290, 0, 70)
Frame.Position = UDim2.new(0.5, -145, 0, 12)

-- Ajustar tamaño de botones existentes para que quepan 3
BtnGod.Size  = UDim2.new(0, 88, 1, 0)
BtnAuto.Size = UDim2.new(0, 88, 1, 0)

-- Crear botón Infinite Jump
BtnJump = Instance.new("TextButton")
BtnJump.Size             = UDim2.new(0, 88, 1, 0)
BtnJump.BackgroundColor3 = Color3.fromRGB(20, 30, 55)
BtnJump.TextColor3       = Color3.fromRGB(255, 255, 255)
BtnJump.Font             = Enum.Font.GothamBold
BtnJump.TextSize         = 10
BtnJump.Text             = "🦘 Inf Jump"
BtnJump.BorderSizePixel  = 0
BtnJump.LayoutOrder      = 3
BtnJump.Parent           = BtnContainer
Instance.new("UICorner", BtnJump).CornerRadius = UDim.new(0, 7)

BtnJump.Activated:Connect(function()
    infiniteJumpActive = not infiniteJumpActive
    if infiniteJumpActive then
        BtnJump.Text             = "🛑 Jump OFF"
        BtnJump.BackgroundColor3 = Color3.fromRGB(55, 10, 10)
        startInfiniteJump()
    else
        stopInfiniteJump()
        BtnJump.Text             = "🦘 Inf Jump"
        BtnJump.BackgroundColor3 = Color3.fromRGB(20, 30, 55)
    end
    updateDot()
end)

-- Rainbow en BtnJump cuando inactivo
local _origHeartbeat = RS.Heartbeat
-- Extender el rainbow existente para incluir BtnJump
local rainbowHue2 = 0.33
RS.Heartbeat:Connect(function(dt)
    rainbowHue2 = (rainbowHue2 + dt * 0.4) % 1
    if BtnJump and not infiniteJumpActive then
        BtnJump.TextColor3 = Color3.fromHSV((rainbowHue2 + 0.15) % 1, 0.85, 1)
    end
end)

print("[Rozek v3] Infinite Jump agregado")
