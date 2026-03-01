--[[
  ╔══════════════════════════════════════╗
  ║           ROZEK v3                   ║
  ║  - God Mode (bajo el suelo)          ║
  ║  - Instant Pickup: SIEMPRE ACTIVO    ║
  ║  - Auto Brain: agarra brainrots      ║
  ║  - Remove Map: carga/revierte mapa   ║
  ║  - Infinite Jump: SIEMPRE ACTIVO     ║
  ║  - GUI compacta 3 filas, arrastrable ║
  ╚══════════════════════════════════════╝
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
local removeActive     = false
local BtnGod, BtnAuto, BtnRemove

-- ══════════════════════════════════════
--  MAP DATA (rozek_map.json embebido)
-- ══════════════════════════════════════

-- Partes del mapa original a eliminar (restaurar al desactivar Remove)
local MAP_DELETED = {
    -- 1
    {path="Workspace.DefaultMap_SharedInstances.Floors.Common",        color=Color3.fromHex("60973C"), mat=Enum.Material.Plastic, name="Common",      pos=Vector3.new(242,             -2.999981,  -5.6016e-05),   size=Vector3.new(70,            6,          260)},
    -- 2
    {path="Workspace.DefaultMap.Spawners.Common",                      color=Color3.fromHex("60973C"), mat=Enum.Material.Plastic, name="Common",      pos=Vector3.new(242,             -2.999981,  -5.6016e-05),   size=Vector3.new(70,            6,          260)},
    -- 3
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap1.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(200,             -9.024967,  -5.0486e-05),   size=Vector3.new(6.05,          260,        14)},
    -- 4
    {path="Workspace.DefaultMap.FirstFloor",                           color=Color3.fromHex("60973C"), mat=Enum.Material.Plastic, name="FirstFloor",  pos=Vector3.new(173,             -2.999981,  -5.9032e-05),   size=Vector3.new(40,            6,          260)},
    -- 5
    {path="Workspace.DefaultMap.Gaps.Gap1.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(200,             -9.024967,  -5.8115e-05),   size=Vector3.new(6.05,          260,        14)},
    -- 6
    {path="Workspace.DefaultMap.Ground",                               color=Color3.fromHex("2F9724"), mat=Enum.Material.Plastic, name="Ground",      pos=Vector3.new(72.99999,        -2.999981,  -6.3403e-05),   size=Vector3.new(160,           6,          376)},
    -- 7
    {path="Workspace.GameObjects.PlaceSpecific.root.Misc.Roof",        color=Color3.fromHex("A3A2A5"), mat=Enum.Material.Plastic, name="Roof",        pos=Vector3.new(1182.5,           68.499992,  7.6294e-06),   size=Vector3.new(2047,          1,          260)},
    -- 8
    {path="Workspace.DefaultMap_SharedInstances.Floors.Uncommon",      color=Color3.fromHex("73973C"), mat=Enum.Material.Plastic, name="Uncommon",    pos=Vector3.new(341,             -2.999981,  -5.1689e-05),   size=Vector3.new(100,           6,          260)},
    -- 9
    {path="Workspace.DefaultMap.Spawners.Uncommon",                    color=Color3.fromHex("73973C"), mat=Enum.Material.Plastic, name="Uncommon",    pos=Vector3.new(341,             -2.999981,  -5.1689e-05),   size=Vector3.new(100,           6,          260)},
    -- 10
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap2.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(284,             -9.024967,  -4.6814e-05),   size=Vector3.new(6.05,          260,        14)},
    -- 11
    {path="Workspace.DefaultMap.Gaps.Gap2.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(284,             -9.024967,  -5.4444e-05),   size=Vector3.new(6.05,          260,        14)},
    -- 12
    {path="Workspace.DefaultMap_SharedInstances.Floors.Rare",          color=Color3.fromHex("82973C"), mat=Enum.Material.Plastic, name="Rare",        pos=Vector3.new(470,             -2.999981,  -4.6050e-05),   size=Vector3.new(130,           6,          260)},
    -- 13
    {path="Workspace.DefaultMap.Spawners.Rare",                        color=Color3.fromHex("82973C"), mat=Enum.Material.Plastic, name="Rare",        pos=Vector3.new(470,             -2.999981,  -4.6050e-05),   size=Vector3.new(130,           6,          260)},
    -- 14
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap3.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(398,             -9.024967,  -4.1831e-05),   size=Vector3.new(6.05,          260,        14)},
    -- 15
    {path="Workspace.DefaultMap.Gaps.Gap3.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(398,             -9.024967,  -4.9461e-05),   size=Vector3.new(6.05,          260,        14)},
    -- 16
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap4.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(542.0001,        -9.024967,  -3.5537e-05),   size=Vector3.new(6.05,          260,        14)},
    -- 17
    {path="Workspace.DefaultMap.Gaps.Gap4.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(542,             -9.024967,  -4.3166e-05),   size=Vector3.new(6.05,          260,        14)},
    -- 18
    {path="Workspace.DefaultMap_SharedInstances.Floors.Epic",          color=Color3.fromHex("8E973C"), mat=Enum.Material.Plastic, name="Epic",        pos=Vector3.new(649,             -2.999981,  -3.8226e-05),   size=Vector3.new(200,           6,          260)},
    -- 19
    {path="Workspace.DefaultMap.Spawners.Epic",                        color=Color3.fromHex("8E973C"), mat=Enum.Material.Plastic, name="Epic",        pos=Vector3.new(649,             -2.999981,  -3.8226e-05),   size=Vector3.new(200,           6,          260)},
    -- 20
    {path="Workspace.DefaultMap_SharedInstances.Floors.Legendary",     color=Color3.fromHex("97973D"), mat=Enum.Material.Plastic, name="Legendary",   pos=Vector3.new(913,             -2.999981,  -2.6686e-05),   size=Vector3.new(300,           6,          260)},
    -- 21
    {path="Workspace.DefaultMap.Spawners.Legendary",                   color=Color3.fromHex("97973D"), mat=Enum.Material.Plastic, name="Legendary",   pos=Vector3.new(913,             -2.999981,  -2.6686e-05),   size=Vector3.new(300,           6,          260)},
    -- 22
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap5.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(756.0001,        -9.024967,  -2.6182e-05),   size=Vector3.new(6.05,          260,        14)},
    -- 23
    {path="Workspace.DefaultMap.Gaps.Gap5.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(756,             -9.024967,  -3.3812e-05),   size=Vector3.new(6.05,          260,        14)},
    -- 24
    {path="Workspace.DefaultMap.Spawners.Mythical",                    color=Color3.fromHex("97932A"), mat=Enum.Material.Plastic, name="Mythical",    pos=Vector3.new(1310,            -2.999981,  -9.3324e-06),   size=Vector3.new(450,           6,          260)},
    -- 25
    {path="Workspace.DefaultMap_SharedInstances.Floors.Mythical",      color=Color3.fromHex("97932A"), mat=Enum.Material.Plastic, name="Mythical",    pos=Vector3.new(1310,            -2.999981,  -9.3324e-06),   size=Vector3.new(450,           6,          260)},
    -- 26
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap6.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(1074,            -9.024967,  -1.2107e-05),   size=Vector3.new(6.05,          260,        22)},
    -- 27
    {path="Workspace.DefaultMap.Gaps.Gap6.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(1074,            -9.024967,  -1.9912e-05),   size=Vector3.new(6.05,          260,        22)},
    -- 28
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap7.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(1555,            -9.024967,   9.3112e-06),   size=Vector3.new(6.05,          260,        40)},
    -- 29
    {path="Workspace.DefaultMap.Gaps.Gap7.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(1555,            -9.024967,   1.1135e-06),   size=Vector3.new(6.05,          260,        40)},
    -- 30
    {path="Workspace.DefaultMap_SharedInstances.Floors.Cosmic",        color=Color3.fromHex("ABA500"), mat=Enum.Material.Plastic, name="Cosmic",      pos=Vector3.new(1900,            -2.999981,   1.6457e-05),   size=Vector3.new(650,           6,          260)},
    -- 31
    {path="Workspace.DefaultMap.Spawners.Cosmic",                      color=Color3.fromHex("ABA500"), mat=Enum.Material.Plastic, name="Cosmic",      pos=Vector3.new(1900,            -2.999981,   1.6457e-05),   size=Vector3.new(650,           6,          260)},
    -- 32
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap7.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(2252.5,          -9.024967,   3.9800e-05),   size=Vector3.new(6.05,          260,        55)},
    -- 33
    {path="Workspace.DefaultMap.Gaps.Gap8.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(2252.5,          -9.024967,   3.1602e-05),   size=Vector3.new(6.05,          260,        55)},
    -- 34
    {path="Workspace.DefaultMap_SharedInstances.AllowedSpaces.Waves2", color=Color3.fromHex("A3A2A5"), mat=Enum.Material.Plastic, name="Waves2",      pos=Vector3.new(3031.5498,        28.950020,  -1.999929),    size=Vector3.new(2048,          82.0999985, 276)},
    -- 35
    {path="Workspace.GameObjects.PlaceSpecific.root.Misc.Roof",        color=Color3.fromHex("A3A2A5"), mat=Enum.Material.Plastic, name="Roof",        pos=Vector3.new(2570.5,           68.499992,   0),           size=Vector3.new(729,           1,          260)},
    -- 36
    {path="Workspace.DefaultMap_SharedInstances.Floors.Cosmic",        color=Color3.fromHex("ABA500"), mat=Enum.Material.Plastic, name="Cosmic",      pos=Vector3.new(2605,            -2.999981,   4.7274e-05),   size=Vector3.new(650,           6,          260)},
    -- 37
    {path="Workspace.DefaultMap.Spawners.Cosmic",                      color=Color3.fromHex("ABA500"), mat=Enum.Material.Plastic, name="Cosmic",      pos=Vector3.new(2605,            -2.999981,   4.7274e-05),   size=Vector3.new(650,           6,          260)},
    -- 38
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap8.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(2957.5,          -9.024967,   7.0944e-05),   size=Vector3.new(6.05,          260,        55)},
    -- 39
    {path="Workspace.DefaultMap.Gaps.Gap8.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(2957.5,          -9.024967,   6.2419e-05),   size=Vector3.new(6.05,          260,        55)},
    -- 40
    {path="Workspace.GameObjects.PlaceSpecific.root.Misc.Roof",        color=Color3.fromHex("A3A2A5"), mat=Enum.Material.Plastic, name="Roof",        pos=Vector3.new(3613.004395,      70.500031,   0),           size=Vector3.new(1475.5003662,  1,          260)},
    -- 41
    {path="Workspace.DefaultMap_SharedInstances.Floors.Secret1",       color=Color3.fromHex("CBC100"), mat=Enum.Material.Plastic, name="Secret1",     pos=Vector3.new(3135,            -2.999981,   7.0441e-05),   size=Vector3.new(299.9999695,   6,          260)},
    -- 42
    {path="Workspace.DefaultMap.Spawners.Secret",                      color=Color3.fromHex("CBC100"), mat=Enum.Material.Plastic, name="Secret",      pos=Vector3.new(3135,            -2.999981,   7.0441e-05),   size=Vector3.new(299.9999695,   6,          260)},
    -- 43
    {path="Workspace.DefaultMap_SharedInstances.Floors.Secret2",       color=Color3.fromHex("CBC100"), mat=Enum.Material.Plastic, name="Secret2",     pos=Vector3.new(3490,            -2.999981,   8.5958e-05),   size=Vector3.new(299.9999695,   6,          260)},
    -- 44
    {path="Workspace.DefaultMap.Spawners.Secret",                      color=Color3.fromHex("CBC100"), mat=Enum.Material.Plastic, name="Secret",      pos=Vector3.new(3490,            -2.999981,   8.5958e-05),   size=Vector3.new(299.9999695,   6,          260)},
    -- 45
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap8.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(3312.5,          -9.024967,   8.6462e-05),   size=Vector3.new(6.05,          260,        55)},
    -- 46
    {path="Workspace.DefaultMap.Gaps.Gap8.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(3312.5,          -9.024967,   7.7936e-05),   size=Vector3.new(6.05,          260,        55)},
    -- 47
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap9.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(3667.5,          -9.024967,   1.0198e-04),   size=Vector3.new(6.05,          260,        55)},
    -- 48
    {path="Workspace.DefaultMap.Gaps.Gap9.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(3667.5,          -9.024967,   9.3454e-05),   size=Vector3.new(6.05,          260,        55)},
    -- 49
    {path="Workspace.DefaultMap_SharedInstances.Floors.Secret3",       color=Color3.fromHex("CBC100"), mat=Enum.Material.Plastic, name="Secret3",     pos=Vector3.new(3853,            -2.999981,   1.0183e-04),   size=Vector3.new(299.9999695,   6,          260)},
    -- 50
    {path="Workspace.DefaultMap.Spawners.Secret",                      color=Color3.fromHex("CBC100"), mat=Enum.Material.Plastic, name="Secret",      pos=Vector3.new(3853,            -2.999981,   1.0183e-04),   size=Vector3.new(299.9999695,   6,          260)},
    -- 51
    {path="Workspace.DefaultMap.Spawners.Celestial",                   color=Color3.fromHex("CBC100"), mat=Enum.Material.Plastic, name="Celestial",   pos=Vector3.new(3845,            -2.999981,   1.0148e-04),   size=Vector3.new(299.9999695,   6,          260)},
    -- 52
    {path="Workspace.WackyWave_Visual.Hitbox3",                        color=Color3.fromHex("A3A2A5"), mat=Enum.Material.Plastic, name="Hitbox3",     pos=Vector3.new(3986.665039,      16.374998,  86.666794),    size=Vector3.new(25.516001,     28.75,      86.666664)},
    -- 53
    {path="Workspace.DefaultMap_SharedInstances.Gaps.Gap9.Mud",        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(4022.5,          -9.024967,   1.1750e-04),   size=Vector3.new(6.05,          260,        55)},
    -- 54
    {path="Workspace.DefaultMap.Gaps.Gap9.Mud",                        color=Color3.fromHex("D5733D"), mat=Enum.Material.Plastic, name="Mud",         pos=Vector3.new(4022.5,          -9.024967,   1.0897e-04),   size=Vector3.new(6.05,          260,        55)},
    -- 55
    {path="Workspace.DefaultMap_SharedInstances.AllowedSpaces.Waves3", color=Color3.fromHex("A3A2A5"), mat=Enum.Material.Plastic, name="Waves3",      pos=Vector3.new(4205.774902,      28.950020,  -1.999878),    size=Vector3.new(300.450378,    82.0999985, 276)},
    -- 56
    {path="Workspace.DefaultMap_SharedInstances.Floors.Celestial",     color=Color3.fromHex("CBC100"), mat=Enum.Material.Plastic, name="Celestial",   pos=Vector3.new(4164.5,          -3,          0),           size=Vector3.new(229,           6,          260)},
    -- 57
    {path="Workspace.DefaultMap.Spawners.Divine",                      color=Color3.fromHex("CBC100"), mat=Enum.Material.Plastic, name="Divine",      pos=Vector3.new(4164.5,          -3,          0),           size=Vector3.new(229,           6,          260)},
    -- 58
    {path="Workspace.DefaultMap.TowerGround",                          color=Color3.fromHex("CBC100"), mat=Enum.Material.Plastic, name="TowerGround", pos=Vector3.new(4314.5,          -2.999981,   1.2200e-04),   size=Vector3.new(70.999954,     6,          260)},
    -- 59 (Torre Part 1)
    {path="Workspace.GameObjects.PlaceSpecific.root.Tower.Part",       color=Color3.fromHex("5B5D69"), mat=Enum.Material.Plastic, name="Part",        pos=Vector3.new(4313.832520,       0.799339,  -2.124415),    size=Vector3.new(57.658379,     2.351409,   110.238846)},
    -- 60 (Torre Part 2)
    {path="Workspace.GameObjects.PlaceSpecific.root.Tower.Part",       color=Color3.fromHex("5B5D69"), mat=Enum.Material.Plastic, name="Part",        pos=Vector3.new(4304.290527,       0.141930,  -1.097811),    size=Vector3.new(47.632408,     1.671976,    76.730042)},
    -- 61 (Torre Part 3)
    {path="Workspace.GameObjects.PlaceSpecific.root.Tower.Part",       color=Color3.fromHex("5B5D69"), mat=Enum.Material.Plastic, name="Part",        pos=Vector3.new(4321.747070,       1.309166,  -2.021373),    size=Vector3.new(41.828934,     3.371163,   209.273361)},
    -- 62 (Torre Union 1)
    {path="Workspace.GameObjects.PlaceSpecific.root.Tower.Union",      color=Color3.fromHex("5B5D69"), mat=Enum.Material.Plastic, name="Union",       pos=Vector3.new(4317.728027,      21.425194,  41.329739),    size=Vector3.new(10.984474,    20.510284,    48.470699)},
    -- 63 (Torre Part 4)
    {path="Workspace.GameObjects.PlaceSpecific.root.Tower.Part",       color=Color3.fromHex("5B5D69"), mat=Enum.Material.Plastic, name="Part",        pos=Vector3.new(4317.727539,       0.160423,  -1.956494),    size=Vector3.new(10.984708,   103.945686,    7.073647)},
    -- 64 (Torre Union 2)
    {path="Workspace.GameObjects.PlaceSpecific.root.Tower.Union",      color=Color3.fromHex("5B5D69"), mat=Enum.Material.Plastic, name="Union",       pos=Vector3.new(4317.727539,      20.527273, -46.674198),    size=Vector3.new(10.984474,    20.510277,   46.674847)},
}

-- Partes nuevas a agregar (se destruyen al desactivar Remove)
local MAP_ADDED = {
    {pos=Vector3.new(60.1,    -0.6,   9.7),   size=Vector3.new(186,   0.5, 405), color=Color3.fromHex("50B450"), mat=Enum.Material.Pebble},
    {pos=Vector3.new(1144.5,  -9.5,   10.4),  size=Vector3.new(2048,  5.5, 295), color=Color3.fromHex("50B450"), mat=Enum.Material.Pebble},
    {pos=Vector3.new(150,     -5.5,   8),     size=Vector3.new(8.5,   9.5, 300.5),color=Color3.fromHex("50B450"), mat=Enum.Material.Pebble},
    {pos=Vector3.new(3190,    -7.5,  -6),     size=Vector3.new(2048,  1,   310), color=Color3.fromHex("50B450"), mat=Enum.Material.Pebble},
    {pos=Vector3.new(4225,   -16,   -13),     size=Vector3.new(290,  21,   330), color=Color3.fromHex("50B450"), mat=Enum.Material.Pebble},
}

-- Tabla para guardar referencias: partes originales ocultas y partes nuevas creadas
local hiddenOriginals = {} -- {part, originalTransparency, originalCanCollide}
local addedParts      = {} -- instancias Part creadas por Remove

-- ══════════════════════════════════════
--  HELPER: buscar parte por path + posición
--  Necesario porque hay múltiples objetos
--  con el mismo path exacto:
--    - Roof               x3
--    - Gap7.Mud           x2
--    - Floors.Cosmic      x2
--    - Spawners.Cosmic    x2
--    - Gap8.Mud           x2/x3
--    - Spawners.Secret    x3
--    - Gap9.Mud           x2
--    - Tower.Part         x4
--    - Tower.Union        x2
--  FindFirstChild solo devuelve el primero,
--  así que buscamos TODOS y elegimos el
--  más cercano a la posición del JSON.
-- ══════════════════════════════════════
local POS_TOLERANCE = 5 -- studs de margen

local function getByPathAndPos(pathStr, expectedPos)
    local segments = {}
    for seg in pathStr:gmatch("[^%.]+") do
        table.insert(segments, seg)
    end

    -- Navegar hasta el contenedor padre
    local current = game
    for i = 1, #segments - 1 do
        local child = current:FindFirstChild(segments[i])
        if not child then return nil end
        current = child
    end

    local lastName = segments[#segments]

    -- Recoger TODOS los hijos con ese nombre
    local candidates = {}
    for _, child in ipairs(current:GetChildren()) do
        if child.Name == lastName then
            table.insert(candidates, child)
        end
    end

    if #candidates == 0 then return nil end
    if #candidates == 1 then return candidates[1] end

    -- Hay varios: elegir el BasePart más cercano a expectedPos
    local best     = nil
    local bestDist = math.huge
    for _, child in ipairs(candidates) do
        if child:IsA("BasePart") then
            local dist = (child.Position - expectedPos).Magnitude
            if dist < bestDist then
                bestDist = dist
                best     = child
            end
        end
    end
    return best or candidates[1]
end

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
    local keywords = {"pick","toma","take","coger","collect","cobrar","place","coloca","poner","sell","vend"}
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
    local keywords = {"pick","toma","take","coger","collect","cobrar","brainrot"}
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
--  REMOVE MAP: ACTIVAR
--  1. Oculta + desactiva colisión de las
--     partes del mapa original (deleted)
--  2. Crea e inserta las partes nuevas
--     (added) en el workspace
-- ══════════════════════════════════════
local function activateRemove()
    hiddenOriginals = {}
    addedParts      = {}

    -- Paso 1: ocultar originales buscando por path + posición
    -- (usa posición para distinguir duplicados con el mismo path)
    for _, entry in ipairs(MAP_DELETED) do
        local obj = getByPathAndPos(entry.path, entry.pos)
        if obj and obj:IsA("BasePart") then
            table.insert(hiddenOriginals, {
                part              = obj,
                origTransparency  = obj.Transparency,
                origCanCollide    = obj.CanCollide,
            })
            obj.Transparency = 1
            obj.CanCollide   = false
        end
    end

    -- Paso 2: crear partes nuevas
    for i, entry in ipairs(MAP_ADDED) do
        local p = Instance.new("Part")
        p.Name         = "__RozekAdded_" .. i .. "__"
        p.Anchored     = true
        p.CanCollide   = true
        p.Transparency = 0
        p.Color        = entry.color
        p.Material     = entry.mat
        p.Size         = entry.size
        p.CFrame       = CFrame.new(entry.pos)
        p.Parent       = workspace
        table.insert(addedParts, p)
    end

    print("[Rozek v3] Remove Map ON — " .. #hiddenOriginals .. " partes ocultas, " .. #addedParts .. " partes añadidas")
end

-- ══════════════════════════════════════
--  REMOVE MAP: DESACTIVAR
--  1. Restaura visibilidad y colisión
--     de las partes originales
--  2. Destruye las partes añadidas
-- ══════════════════════════════════════
local function deactivateRemove()
    -- Restaurar originales
    for _, entry in ipairs(hiddenOriginals) do
        if entry.part and entry.part.Parent then
            entry.part.Transparency = entry.origTransparency
            entry.part.CanCollide   = entry.origCanCollide
        end
    end

    -- Destruir partes añadidas
    for _, p in ipairs(addedParts) do
        if p and p.Parent then
            p:Destroy()
        end
    end

    hiddenOriginals = {}
    addedParts      = {}

    print("[Rozek v3] Remove Map OFF — mapa restaurado")
end

-- ══════════════════════════════════════
--  GUI — Rozek v3
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

-- Frame principal — más alto para 3 filas (TitleBar 22 + Fila1 28 + Fila2 28 + padding)
local FRAME_W = 170
local FRAME_H = 92  -- 22 title + 28 fila1 + 28 fila2 + 14 gaps/padding

local Frame = Instance.new("Frame")
Frame.Size             = UDim2.new(0, FRAME_W, 0, FRAME_H)
Frame.Position         = UDim2.new(0.5, -FRAME_W/2, 0, 12)
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

local TitlePatch = Instance.new("Frame")
TitlePatch.Size             = UDim2.new(1, 0, 0, 10)
TitlePatch.Position         = UDim2.new(0, 0, 1, -10)
TitlePatch.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TitlePatch.BorderSizePixel  = 0
TitlePatch.Parent           = TitleBar

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

local StatusDot = Instance.new("Frame")
StatusDot.Size             = UDim2.new(0, 6, 0, 6)
StatusDot.Position         = UDim2.new(1, -12, 0.5, -3)
StatusDot.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
StatusDot.BorderSizePixel  = 0
StatusDot.Parent           = TitleBar
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local function updateDot()
    if godActive or autoBrainActive or removeActive then
        StatusDot.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    else
        StatusDot.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end

-- ── FILA 1: God Mode + Auto Brain ─────────────────────
local Row1 = Instance.new("Frame")
Row1.Size             = UDim2.new(1, -10, 0, 28)
Row1.Position         = UDim2.new(0, 5, 0, 26)
Row1.BackgroundTransparency = 1
Row1.Parent           = Frame

local RowLayout1 = Instance.new("UIListLayout", Row1)
RowLayout1.FillDirection = Enum.FillDirection.Horizontal
RowLayout1.SortOrder     = Enum.SortOrder.LayoutOrder
RowLayout1.Padding       = UDim.new(0, 6)

-- ── FILA 2: Remove Map (centrado) ─────────────────────
local Row2 = Instance.new("Frame")
Row2.Size             = UDim2.new(1, -10, 0, 28)
Row2.Position         = UDim2.new(0, 5, 0, 58)
Row2.BackgroundTransparency = 1
Row2.Parent           = Frame

local RowLayout2 = Instance.new("UIListLayout", Row2)
RowLayout2.FillDirection      = Enum.FillDirection.Horizontal
RowLayout2.SortOrder          = Enum.SortOrder.LayoutOrder
RowLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ── Helper para crear botones ─────────────────────────
local function makeBtn(parent, text, bgColor, order, fullWidth)
    local btn = Instance.new("TextButton")
    if fullWidth then
        btn.Size = UDim2.new(1, 0, 1, 0)
    else
        btn.Size = UDim2.new(0.5, -3, 1, 0)
    end
    btn.BackgroundColor3 = bgColor
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 10
    btn.Text             = text
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = order
    btn.Parent           = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return btn
end

-- Botones fila 1
BtnGod  = makeBtn(Row1, "⚡ God Mode",   Color3.fromRGB(18, 40, 18), 1, false)
BtnAuto = makeBtn(Row1, "🧠 Auto Brain", Color3.fromRGB(22, 16, 40), 2, false)

-- Botón fila 2 (ancho completo)
BtnRemove = makeBtn(Row2, "🗺️ Remove Map", Color3.fromRGB(50, 28, 10), 1, true)

-- ── Lógica botón God Mode ─────────────────────────────
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

-- ── Lógica botón Auto Brain ───────────────────────────
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

-- ── Lógica botón Remove Map ───────────────────────────
BtnRemove.Activated:Connect(function()
    removeActive = not removeActive
    if removeActive then
        activateRemove()
        BtnRemove.Text             = "🛑 Remove OFF"
        BtnRemove.BackgroundColor3 = Color3.fromRGB(55, 10, 10)
    else
        deactivateRemove()
        BtnRemove.Text             = "🗺️ Remove Map"
        BtnRemove.BackgroundColor3 = Color3.fromRGB(50, 28, 10)
    end
    updateDot()
end)

-- ══════════════════════════════════════
--  DRAG — táctil y mouse
-- ══════════════════════════════════════
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
    local c2 = Color3.fromHSV((rainbowHue + 0.5)  % 1, 0.85, 1)
    local c3 = Color3.fromHSV((rainbowHue + 0.33) % 1, 0.85, 1)
    local ct = Color3.fromHSV((rainbowHue + 0.25) % 1, 0.7,  1)

    -- Título siempre rainbow
    Title.TextColor3 = ct

    -- Botones solo si están inactivos
    if BtnGod    and not godActive       then BtnGod.TextColor3    = c1 end
    if BtnAuto   and not autoBrainActive then BtnAuto.TextColor3   = c2 end
    if BtnRemove and not removeActive    then BtnRemove.TextColor3 = c3 end
end)

-- ══════════════════════════════════════
--  INFINITE JUMP — SIEMPRE ACTIVO
-- ══════════════════════════════════════
UIS.JumpRequest:Connect(function()
    local char = lp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

print("[Rozek v3] Cargado — God Mode | Auto Brain | Instant Pickup | Remove Map | Infinite Jump")
