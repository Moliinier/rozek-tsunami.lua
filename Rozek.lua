--[[
  +==========================================+
  |              ROZEK v4                    |
  |  - God Mode                              |
  |  - Auto Brain                            |
  |  - Instant Pickup: SIEMPRE ACTIVO        |
  |  - Infinite Jump: SIEMPRE ACTIVO         |
  |  - Remove Map: oculta mapa base          |
  |    automaticamente al cargar             |
  +==========================================+
]]

local Players   = game:GetService("Players")
local RS        = game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera
local pg  = lp.PlayerGui

local OFFSET_Y   = -18
local CAM_HEIGHT = 7

local heartbeat
local fakePart
local godData

local godActive       = false
local autoBrainActive = false
local autoBrainThread = nil
local removeActive    = false

local BtnGod, BtnAuto, BtnRemove

-- =============================================
--  MAP DATA (rozek_map.json embebido)
-- =============================================
local MAP_DELETED={
    {"Workspace.DefaultMap_SharedInstances.Floors.Common",Vector3.new(242,-3,0)},
    {"Workspace.DefaultMap.Spawners.Common",Vector3.new(242,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.DefaultMap.FirstFloor",Vector3.new(173,-3,0)},
    {"Workspace.DefaultMap.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.DefaultMap.Ground",Vector3.new(73,-3,0)},
    {"Workspace.GameObjects.PlaceSpecific.root.Misc.Roof",Vector3.new(1182.5,68.5,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.DefaultMap.Spawners.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Rare",Vector3.new(470,-3,0)},
    {"Workspace.DefaultMap.Spawners.Rare",Vector3.new(470,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Epic",Vector3.new(649,-3,0)},
    {"Workspace.DefaultMap.Spawners.Epic",Vector3.new(649,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.DefaultMap.Spawners.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.DefaultMap.Spawners.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.DefaultMap.Spawners.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap8.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.GameObjects.PlaceSpecific.root.Misc.Roof",Vector3.new(2570.5,68.5,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Cosmic",Vector3.new(2605,-3,0)},
    {"Workspace.DefaultMap.Spawners.Cosmic",Vector3.new(2605,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap8.Mud",Vector3.new(2957.5,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap8.Mud",Vector3.new(2957.5,-9.025,0)},
    {"Workspace.GameObjects.PlaceSpecific.root.Misc.Roof",Vector3.new(3613.004,70.5,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Secret1",Vector3.new(3135,-3,0)},
    {"Workspace.DefaultMap.Spawners.Secret",Vector3.new(3135,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Secret2",Vector3.new(3490,-3,0)},
    {"Workspace.DefaultMap.Spawners.Secret",Vector3.new(3490,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap8.Mud",Vector3.new(3312.5,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap8.Mud",Vector3.new(3312.5,-9.025,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap9.Mud",Vector3.new(3667.5,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap9.Mud",Vector3.new(3667.5,-9.025,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Secret3",Vector3.new(3853,-3,0)},
    {"Workspace.DefaultMap.Spawners.Secret",Vector3.new(3853,-3,0)},
    {"Workspace.DefaultMap.Spawners.Celestial",Vector3.new(3845,-3,0)},
    {"Workspace.DefaultMap_SharedInstances.Gaps.Gap9.Mud",Vector3.new(4022.5,-9.025,0)},
    {"Workspace.DefaultMap.Gaps.Gap9.Mud",Vector3.new(4022.5,-9.025,0)},
    {"Workspace.DefaultMap_SharedInstances.Floors.Celestial",Vector3.new(4164.5,-3,0)},
    {"Workspace.DefaultMap.Spawners.Divine",Vector3.new(4164.5,-3,0)},
    {"Workspace.DefaultMap.TowerGround",Vector3.new(4314.5,-3,0)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Part",Vector3.new(4313.833,0.799,-2.124)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Part",Vector3.new(4304.291,0.142,-1.098)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Part",Vector3.new(4321.747,1.309,-2.021)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Union",Vector3.new(4317.728,21.425,41.33)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Part",Vector3.new(4317.728,0.16,-1.956)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Union",Vector3.new(4317.728,20.527,-46.674)},
    {"Workspace.GameObjects.PlaceSpecific.root.Misc.Ground",Vector3.new(73,-3,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Ground",Vector3.new(73,-3,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.FirstFloor",Vector3.new(173,-3,0)},
    {"Workspace.GameObjects.PlaceSpecific.root.Misc.Roof",Vector3.new(1182.5,68.5,0)},
    {"Workspace.MoneyMap_SharedInstances.Floors.Common",Vector3.new(242,-3,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Common",Vector3.new(242,-3,0)},
    {"Workspace.MoneyMap_SharedInstances.Floors.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.MoneyMap_SharedInstances.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.MoneyMap_SharedInstances.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.MoneyMap_SharedInstances.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.MoneyMap_SharedInstances.Floors.Epic",Vector3.new(649,-3,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Rare",Vector3.new(470,-3,0)},
    {"Workspace.MoneyMap_SharedInstances.Floors.Rare",Vector3.new(470,-3,0)},
    {"Workspace.MoneyMap_SharedInstances.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Gaps.Gap3.Mud",Vector3.new(398,-9.025,1)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Epic",Vector3.new(649,-3,0)},
    {"Workspace.MoneyMap_SharedInstances.Floors.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.MoneyMap_SharedInstances.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.MoneyMap_SharedInstances.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.MoneyMap_SharedInstances.Floors.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.MoneyMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.MoneyMap_SharedInstances.Floors.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.MoneyMap_SharedInstances.Gaps.Gap8.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Gaps.Gap8.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.MoneyMap_SharedInstances.Floors.Secret",Vector3.new(2430,-3,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Secret",Vector3.new(2430,-3,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Gaps.Gap9.Mud",Vector3.new(2607.5,-9.025,0)},
    {"Workspace.MoneyMap_SharedInstances.Gaps.Gap9.Mud",Vector3.new(2607.5,-9.025,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Celestial",Vector3.new(2785,-3,0)},
    {"Workspace.RadioactiveMap.Ground",Vector3.new(73,-3,0)},
    {"Workspace.RadioactiveMap.OG.FirstFloor",Vector3.new(173,-3,0)},
    {"Workspace.RadioactiveMap.OG.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Floors.Common",Vector3.new(242,-3,0)},
    {"Workspace.RadioactiveMap.OG.Common",Vector3.new(242,-3,0)},
    {"Workspace.RadioactiveMap.OG.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Floors.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.RadioactiveMap.OG.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.RadioactiveMap.OG.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Floors.Rare",Vector3.new(470,-3,0)},
    {"Workspace.RadioactiveMap.OG.Rare",Vector3.new(470,-3,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Floors.Epic",Vector3.new(649,-3,0)},
    {"Workspace.RadioactiveMap.OG.Epic",Vector3.new(649,-3,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.RadioactiveMap.OG.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.RadioactiveMap.OG.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Floors.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.RadioactiveMap.OG.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Floors.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.RadioactiveMap.OG.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.RadioactiveMap.OG.Gap6.Mud",Vector3.new(1074,-9.025,-36)},
    {"Workspace.RadioactiveMap_SharedInstances.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.RadioactiveMap.OG.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Floors.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.RadioactiveMap.OG.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.RadioactiveMap.OG.Gap8.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Floors.Secret",Vector3.new(2430,-3,0)},
    {"Workspace.RadioactiveMap.OG.Secret",Vector3.new(2430,-3,0)},
    {"Workspace.RadioactiveMap.OG.Gap9.Mud",Vector3.new(2607.5,-9.025,0)},
    {"Workspace.RadioactiveMap_SharedInstances.Floors.Celestial",Vector3.new(2749,-3,0)},
    {"Workspace.RadioactiveMap.OG.Celestial",Vector3.new(2785,-3,0)},
    {"Workspace.MarsMap.FirstFloor",Vector3.new(173,-3,0)},
    {"Workspace.MarsMap_SharedInstances.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.MarsMap.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.MarsMap.Ground",Vector3.new(73,-3,0)},
    {"Workspace.MarsMap_SharedInstances.Floors.Common",Vector3.new(242,-3,0)},
    {"Workspace.MarsMap.Spawners.Common",Vector3.new(242,-3,0)},
    {"Workspace.MarsMap_SharedInstances.Floors.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.MarsMap.Spawners.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.MarsMap_SharedInstances.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.MarsMap.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.MarsMap_SharedInstances.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.MarsMap.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.MarsMap.Spawners.Rare",Vector3.new(470,-3,0)},
    {"Workspace.MarsMap_SharedInstances.Floors.Rare",Vector3.new(470,-3,0)},
    {"Workspace.MarsMap.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.MarsMap_SharedInstances.Floors.Epic",Vector3.new(649,-3,0)},
    {"Workspace.MarsMap.Spawners.Epic",Vector3.new(649,-3,0)},
    {"Workspace.MarsMap_SharedInstances.Floors.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.MarsMap.Spawners.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.MarsMap_SharedInstances.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.MarsMap.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.MarsMap_SharedInstances.Floors.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.MarsMap.Spawners.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.MarsMap_SharedInstances.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.MarsMap.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.MarsMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.MarsMap.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.MarsMap_SharedInstances.Floors.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.MarsMap.Spawners.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.MarsMap_SharedInstances.Gaps.Gap8.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.MarsMap.Gaps.Gap7.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.MarsMap_SharedInstances.Floors.Secret",Vector3.new(2430,-3,0)},
    {"Workspace.MarsMap.Spawners.Secret",Vector3.new(2430,-3,0)},
    {"Workspace.MarsMap_SharedInstances.Gaps.Gap9.Mud",Vector3.new(2607.5,-9.025,0)},
    {"Workspace.MarsMap.Gaps.Gap9.Mud",Vector3.new(2607.5,-9.025,0)},
    {"Workspace.MarsMap_SharedInstances.Floors.Celestial",Vector3.new(2749,-3,0)},
    {"Workspace.MarsMap.Spawners.Celestial",Vector3.new(2785,-3,0)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1137.5,-11.815,434)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1137.5,-2,434)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1124.5,7.5,533)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1132.5,14.5,533)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1140.5,7.5,533)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1132.5,-8.5,141)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1132.5,-15,159.5)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1132.5,-15,147.5)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1132.5,-3.5,131)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1132.5,-15,167.5)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1132.5,-15,178.5)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1132.5,-7.5,139)},
    {"Workspace.MoneyMap.DefaultStudioMap.Spawners.Mythical",Vector3.new(1132.5,-4.5,133)},
    {"Workspace.GameObjects.PlaceSpecific.root.Misc.Ground",Vector3.new(73,-3,0)},
    {"Workspace.ArcadeMap.Ground",Vector3.new(73,-3,0)},
    {"Workspace.ArcadeMap.FirstFloor",Vector3.new(173,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.ArcadeMap.Spawners.Common",Vector3.new(242,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Floors.Common",Vector3.new(242,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.ArcadeMap.Spawners.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.ArcadeMap.Spawners.Rare",Vector3.new(470,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Floors.Rare",Vector3.new(470,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.ArcadeMap.Spawners.Epic",Vector3.new(649,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.ArcadeMap_SharedInstances.Floors.Epic",Vector3.new(649,-3,0)},
    {"Workspace.ArcadeMap.Spawners.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.ArcadeMap_SharedInstances.Floors.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.ArcadeMap.Spawners.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.ArcadeMap.Spawners.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Floors.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap8.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.ArcadeMap.Spawners.Cosmic",Vector3.new(2605,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Floors.Cosmic",Vector3.new(2605,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap8.Mud",Vector3.new(2957.5,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap8.Mud",Vector3.new(2957.5,-9.025,0)},
    {"Workspace.ArcadeMap.Spawners.Secret",Vector3.new(3135,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Floors.Secret1",Vector3.new(3135,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap8.Mud",Vector3.new(3312.5,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap8.Mud",Vector3.new(3312.5,-9.025,0)},
    {"Workspace.ArcadeMap.Spawners.Secret",Vector3.new(3490,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap9.Mud",Vector3.new(3667.5,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap9.Mud",Vector3.new(3667.5,-9.025,0)},
    {"Workspace.ArcadeMap.Spawners.Celestial",Vector3.new(3849,-3,0)},
    {"Workspace.ArcadeMap_SharedInstances.Gaps.Gap9.Mud",Vector3.new(4022.5,-9.025,0)},
    {"Workspace.ArcadeMap.Gaps.Gap9.Mud",Vector3.new(4022.5,-9.025,0)},
    {"Workspace.ArcadeMap_SharedInstances.Floors.Celestial",Vector3.new(4164.5,-3,0)},
    {"Workspace.ArcadeMap.Spawners.Divine",Vector3.new(4200,-3,0)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Part",Vector3.new(4313.833,0.799,-2.124)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Part",Vector3.new(4304.291,0.142,-1.098)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Part",Vector3.new(4321.747,1.309,-2.021)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Union",Vector3.new(4317.728,21.425,41.33)},
    {"Workspace.GameObjects.PlaceSpecific.root.Tower.Union",Vector3.new(4317.728,20.527,-46.674)},
    {"Workspace.DoomMap.Ground",Vector3.new(73,-3,0)},
    {"Workspace.DoomMap.FirstFloor",Vector3.new(173,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Common",Vector3.new(242,-3,0)},
    {"Workspace.DoomMap.Spawners.Common",Vector3.new(242,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.DoomMap.Spawners.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Rare",Vector3.new(470,-3,0)},
    {"Workspace.DoomMap.Spawners.Rare",Vector3.new(470,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Epic",Vector3.new(649,-3,0)},
    {"Workspace.DoomMap.Spawners.Epic",Vector3.new(649,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.DoomMap.Spawners.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.GameObjects.PlaceSpecific.root.Misc.Roof",Vector3.new(1182.5,68.5,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.DoomMap.Spawners.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.DoomMap.Spawners.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap8.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Cosmic",Vector3.new(2605,-3,0)},
    {"Workspace.DoomMap.Spawners.Cosmic",Vector3.new(2605,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap8.Mud",Vector3.new(2957.5,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap8.Mud",Vector3.new(2957.5,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Secret1",Vector3.new(3135,-3,0)},
    {"Workspace.DoomMap.Spawners.Secret",Vector3.new(3135,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap8.Mud",Vector3.new(3312.5,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap8.Mud",Vector3.new(3312.5,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Secret2",Vector3.new(3490,-3,0)},
    {"Workspace.DoomMap.Spawners.Secret",Vector3.new(3490,-3,0)},
    {"Workspace.DoomMap.Gaps.Gap9.Mud",Vector3.new(3667.5,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap9.Mud",Vector3.new(3667.5,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Secret3",Vector3.new(3853,-3,0)},
    {"Workspace.DoomMap.Spawners.Secret",Vector3.new(3849,-3,0)},
    {"Workspace.DoomMap_SharedInstances.Gaps.Gap9.Mud",Vector3.new(4022.5,-9.025,0)},
    {"Workspace.DoomMap.Gaps.Gap9.Mud",Vector3.new(4022.5,-9.025,0)},
    {"Workspace.DoomMap_SharedInstances.Floors.Celestial",Vector3.new(4164.5,-3,0)},
    {"Workspace.DoomMap.Spawners.Divine",Vector3.new(4200,-3,0)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(3849,-3,-66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Secret3",Vector3.new(3853,-3,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(3849,-3,66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap9.Mud",Vector3.new(4022.5,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap9.Mud",Vector3.new(4022.5,-9.025,0)},
    {"Workspace.GameObjects.PlaceSpecific.root.Misc.Roof",Vector3.new(3613.004,70.5,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(4164.5,-3,66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Celestial",Vector3.new(4164.5,-3,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(4117,-3,2)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(4164.5,-3,-66.5)},
    {"Workspace.FireAndIceMap.TowerGround",Vector3.new(4314.5,-3,65)},
    {"Workspace.FireAndIceMap.TowerGround",Vector3.new(4314.5,-3,-65)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap9.Mud",Vector3.new(3667.5,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap9.Mud",Vector3.new(3667.5,-9.025,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(3490,-3,66.5)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(3490,-3,-66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Secret2",Vector3.new(3490,-3,0)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap8.Mud",Vector3.new(3312.5,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap8.Mud",Vector3.new(3312.5,-9.025,0)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(3135,-3,-66.5)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(3135,-3,66.5)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(2605,-3,-66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Cosmic",Vector3.new(2605,-3,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(2907.5,-3,2)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(2605,-3,66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap8.Mud",Vector3.new(2957.5,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap8.Mud",Vector3.new(2957.5,-9.025,0)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap8.Mud",Vector3.new(2252.5,-9.025,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(1900,-3,66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Cosmic",Vector3.new(1900,-3,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(2189,-3,2)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(1900,-3,-66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap7.Mud",Vector3.new(1555,-9.025,0)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(1310,-3,-66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Mythical",Vector3.new(1310,-3,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(1310,-3,66.5)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(913,-3,-66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Legendary",Vector3.new(913,-3,0)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap6.Mud",Vector3.new(1074,-9.025,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(913,-3,66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap5.Mud",Vector3.new(756,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap5.Mud",Vector3.new(756,-9.025,-1)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(649,-3,-66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Epic",Vector3.new(649,-3,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(649,-3,66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap4.Mud",Vector3.new(542,-9.025,0)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Rare",Vector3.new(470,-3,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(470,-3,66.5)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(470,-3,-66.5)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(341,-3,-66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Uncommon",Vector3.new(341,-3,0)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap3.Mud",Vector3.new(398,-9.025,0)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(341,-3,66.5)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(242,-3,66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Floors.Common",Vector3.new(242,-3,0)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap2.Mud",Vector3.new(284,-9.025,0)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(242,-3,-66.5)},
    {"Workspace.FireAndIceMap_SharedInstances.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.FireAndIceMap.Gaps.Gap1.Mud",Vector3.new(200,-9.025,0)},
    {"Workspace.FireAndIceMap.FirstFloor",Vector3.new(173,-3,-66.5)},
    {"Workspace.FireAndIceMap.FirstFloor",Vector3.new(173,-3,66)},
    {"Workspace.FireAndIceMap.Ground",Vector3.new(73,-3,0)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(294,-3,-2)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(293.5,-3,0)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(302,-3,-1.5)},
    {"Workspace.FireAndIceMap.LeftSide.LeftSide",Vector3.new(299.5,-3,-2)},
    {"Workspace.FireAndIceMap.RightSide.RightSide",Vector3.new(298.5,-3,0)},
}

local MAP_ADDED = {
    -- 1
    {pos=Vector3.new(60.10002899169922,-0.5999994277954102,9.700004577636719), size=Vector3.new(186,0.5,405), color=Color3.fromRGB(80,180,80), mat=Enum.Material.Pebble},
    -- 2
    {pos=Vector3.new(1144.5,-9.5,10.399993896484375), size=Vector3.new(2048,5.5,295), color=Color3.fromRGB(80,180,80), mat=Enum.Material.Pebble},
    -- 3
    {pos=Vector3.new(150,-5.5,8), size=Vector3.new(8.5,9.5,300.5), color=Color3.fromRGB(80,180,80), mat=Enum.Material.Pebble},
    -- 4
    {pos=Vector3.new(3190,-7.5,-6), size=Vector3.new(2048,1,310), color=Color3.fromRGB(80,180,80), mat=Enum.Material.Pebble},
    -- 5
    {pos=Vector3.new(4225,-16,-13), size=Vector3.new(290,21,330), color=Color3.fromRGB(80,180,80), mat=Enum.Material.Pebble},
    -- 6
    {pos=Vector3.new(4336,-4,-4), size=Vector3.new(63,4,330), color=Color3.fromRGB(15,15,15), mat=Enum.Material.Pebble},
    -- 7
    {pos=Vector3.new(4303,-5,-15), size=Vector3.new(10,3,345), color=Color3.fromRGB(15,15,15), mat=Enum.Material.Pebble},
    -- 8
    {pos=Vector3.new(4155.6005859375,-5.5,-132.5999755859375), size=Vector3.new(435,11,5), color=Color3.fromRGB(15,15,15), mat=Enum.Material.Pebble},
    -- 9
    {pos=Vector3.new(4170,-5.500000476837158,132.5999755859375), size=Vector3.new(460,11,5), color=Color3.fromRGB(15,15,15), mat=Enum.Material.Pebble},
    -- 10
    {pos=Vector3.new(4309.59765625,-2,-94), size=Vector3.new(10,175.5,75), color=Color3.fromRGB(15,15,15), mat=Enum.Material.Pebble},
    -- 11
    {pos=Vector3.new(4309.5966796875,-2,92.60003662109375), size=Vector3.new(10,176,80), color=Color3.fromRGB(15,15,15), mat=Enum.Material.Pebble},
}

local hiddenOriginals  = {}
local addedParts       = {}

-- =============================================
--  HELPER: buscar parte por path + posicion
-- =============================================
local POS_TOLERANCE = 5

local function getByPathAndPos(pathStr, expectedPos)
    local segments = {}
    for seg in pathStr:gmatch("[^%.]+") do
        table.insert(segments, seg)
    end
    local current = game
    for i = 1, #segments - 1 do
        local child = current:FindFirstChild(segments[i])
        if not child then return nil end
        current = child
    end
    local lastName = segments[#segments]
    local candidates = {}
    for _, child in ipairs(current:GetChildren()) do
        if child.Name == lastName then
            table.insert(candidates, child)
        end
    end
    if #candidates == 0 then return nil end
    if #candidates == 1 then return candidates[1] end
    local best, bestDist = nil, math.huge
    for _, child in ipairs(candidates) do
        if child:IsA("BasePart") then
            local dist = (child.Position - expectedPos).Magnitude
            if dist < bestDist then
                bestDist = dist
                best = child
            end
        end
    end
    return best or candidates[1]
end

-- =============================================
--  HELPER: suelo real con Raycast
-- =============================================
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

-- =============================================
--  GOD MODE
-- =============================================
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
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity  = Vector3.new(0,0,0)
    bv.Parent    = root

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
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
            local dot_f = Vector3.new(move.X,0,move.Z):Dot(forward)
            local dot_r = Vector3.new(move.X,0,move.Z):Dot(right)
            if forward.Magnitude < 0.01 then dot_f = 0 end
            local dir = (forward * dot_f + right * dot_r)
            if dir.Magnitude > 0 then dir = dir.Unit end
            bv.Velocity = dir * FLY_SPEED
            bg.CFrame   = CFrame.new(r.Position, r.Position + dir)
        else
            bv.Velocity = Vector3.new(0,0,0)
        end
        fakePart.Position = Vector3.new(r.Position.X, surfaceY+CAM_HEIGHT, r.Position.Z)
    end)

    godData.bv = bv
    godData.bg = bg
end

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
    if autoBrainThread then task.cancel(autoBrainThread); autoBrainThread = nil end
    if BtnGod  then BtnGod.Text  = "God Mode";   BtnGod.BackgroundColor3  = Color3.fromRGB(20,50,20) end
    if BtnAuto then BtnAuto.Text = "Auto Brain"; BtnAuto.BackgroundColor3 = Color3.fromRGB(30,20,55) end
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

-- =============================================
--  INSTANT PICKUP
-- =============================================
local originalDurations = {}

local function isPickupPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return false end
    if prompt.HoldDuration <= 0 then return false end
    local ancestor = prompt.Parent
    while ancestor and ancestor ~= workspace do
        if ancestor:IsA("Model") then
            if ancestor:HasTag("Brainrot") or ancestor:HasTag("HoldingLuckyBlock") then return true end
        end
        ancestor = ancestor.Parent
    end
    local actionLower = prompt.ActionText:lower()
    for _, kw in ipairs({"pick","toma","take","coger","collect","cobrar","place","coloca","poner","sell","vend"}) do
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
    if obj:IsA("ProximityPrompt") then originalDurations[obj] = nil end
end)
for _, obj in ipairs(workspace:GetDescendants()) do applyInstant(obj) end
workspace.DescendantAdded:Connect(function(obj) task.defer(function() applyInstant(obj) end) end)
task.spawn(function()
    while true do
        task.wait(2)
        for _, obj in ipairs(workspace:GetDescendants()) do applyInstant(obj) end
    end
end)

-- =============================================
--  AUTO BRAIN
-- =============================================
local AUTO_RANGE    = 8
local AUTO_INTERVAL = 0.05
local trackedPrompts = {}

local function isBrainrotPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return false end
    local ancestor = prompt.Parent
    while ancestor and ancestor ~= workspace do
        if ancestor:IsA("Model") then
            if ancestor:HasTag("Brainrot") or ancestor:HasTag("HoldingLuckyBlock") then return true end
        end
        ancestor = ancestor.Parent
    end
    local actionLower = prompt.ActionText:lower()
    for _, kw in ipairs({"pick","toma","take","coger","collect","cobrar","brainrot"}) do
        if actionLower:find(kw) then return true end
    end
    return false
end

for _, obj in ipairs(workspace:GetDescendants()) do
    if isBrainrotPrompt(obj) then trackedPrompts[obj] = true end
end
workspace.DescendantAdded:Connect(function(obj)
    task.defer(function() if isBrainrotPrompt(obj) then trackedPrompts[obj] = true end end)
end)
workspace.DescendantRemoving:Connect(function(obj) trackedPrompts[obj] = nil end)

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
    if fireproximityprompt  then pcall(fireproximityprompt, prompt) end
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

-- =============================================
--  AUTO TOWER - deposita brainrots en la Tower
--  Busca cualquier ProximityPrompt en la Tower
--  que no sea Skip Cooldown y lo dispara
--  SIEMPRE ACTIVO
-- =============================================
local TOWER_RANGE    = 35  -- un poco mas que MaxActivationDistance del prompt (30)
local TOWER_INTERVAL = 0.1

local towerModel = nil
local function getTower()
    if towerModel and towerModel.Parent then return towerModel end
    local t = workspace:FindFirstChild("GameObjects")
    if t then t = t:FindFirstChild("PlaceSpecific") end
    if t then t = t:FindFirstChild("root") end
    if t then t = t:FindFirstChild("Tower") end
    towerModel = t
    return towerModel
end

local towerMainPart = nil
local function getTowerMainPart()
    if towerMainPart and towerMainPart.Parent then return towerMainPart end
    local tower = getTower()
    if tower then towerMainPart = tower:FindFirstChild("Main") end
    return towerMainPart
end

-- Ignorar Skip Cooldown (unico prompt permanente)
local function isSubmitPrompt(prompt)
    if not prompt or not prompt.Parent then return false end
    local action = prompt.ActionText:lower()
    if action:find("skip") then return false end
    if action:find("cooldown") then return false end
    if action:find("r%$") then return false end
    return true
end

local lastFired = 0

task.spawn(function()
    while true do
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local main = getTowerMainPart()

        if root and main then
            -- Usar distancia horizontal (X,Z) porque Main esta muy alto
            local rp = root.Position
            local mp = main.Position
            local hdist = Vector2.new(rp.X - mp.X, rp.Z - mp.Z).Magnitude
            if hdist <= TOWER_RANGE then
                local now = tick()
                local tower = getTower()
                if tower then
                    for _, obj in ipairs(tower:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and isSubmitPrompt(obj) then
                            -- Verificar distancia al prompt especificamente
                            local part = obj.Parent
                            local promptPos = (part and part:IsA("BasePart")) and part.Position or mp
                            local pdist = (root.Position - promptPos).Magnitude
                            if pdist <= obj.MaxActivationDistance + 5 then
                                if (now - lastFired) >= 0.15 then
                                    obj.HoldDuration = 0
                                    obj.Enabled = true
                                    if fireproximityprompt then
                                        pcall(fireproximityprompt, obj)
                                    end
                                    if triggerproximityprompt then
                                        pcall(triggerproximityprompt, obj)
                                    end
                                    lastFired = now
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(TOWER_INTERVAL)
    end
end)

-- =============================================
--  REMOVE MAP
-- =============================================
local function activateRemove()
    hiddenOriginals = {}
    addedParts      = {}
    for _, entry in ipairs(MAP_DELETED) do
        local obj = getByPathAndPos(entry[1], entry[2])
        if obj and obj:IsA("BasePart") then
            table.insert(hiddenOriginals, {
                part             = obj,
                origTransparency = obj.Transparency,
                origCanCollide   = obj.CanCollide,
            })
            obj.Transparency = 1
            obj.CanCollide   = false
        end
    end
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
    print("[Rozek v4] Remove Map ON - " .. #hiddenOriginals .. " ocultas, " .. #addedParts .. " agregadas")
end

local function deactivateRemove()
    for _, entry in ipairs(hiddenOriginals) do
        if entry.part and entry.part.Parent then
            entry.part.Transparency = entry.origTransparency
            entry.part.CanCollide   = entry.origCanCollide
        end
    end
    for _, p in ipairs(addedParts) do
        if p and p.Parent then p:Destroy() end
    end
    hiddenOriginals = {}
    addedParts      = {}
    print("[Rozek v4] Remove Map OFF")
end

-- =============================================
--  GUI
-- =============================================
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

local FRAME_W = 180
local FRAME_H = 148  -- title 22 + fila1 28 + fila2 28 + fila3 28 + status 24 + gaps

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

-- TitleBar
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
Title.BackgroundTransparency = 1
Title.TextColor3         = Color3.fromRGB(220, 220, 255)
Title.Font               = Enum.Font.GothamBold
Title.TextSize           = 11
Title.TextXAlignment     = Enum.TextXAlignment.Center
Title.Text               = "Rozek v4"
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

-- Helper boton
local function makeBtn(parent, text, bgColor, w, h, x, y)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, w, 0, h)
    btn.Position         = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = bgColor
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 10
    btn.Text             = text
    btn.BorderSizePixel  = 0
    btn.Parent           = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return btn
end

local BW = 82  -- ancho boton
local BH = 26  -- alto boton
local PX = 8   -- padding x
local PY = 26  -- start y (despues del title)
local GAP = 6  -- gap entre botones

-- Fila 1: God Mode | Auto Brain
BtnGod  = makeBtn(Frame, "God Mode",   Color3.fromRGB(18,40,18),  BW, BH, PX,        PY+4)
BtnAuto = makeBtn(Frame, "Auto Brain", Color3.fromRGB(30,20,55),  BW, BH, PX+BW+GAP, PY+4)

-- Fila 2: Remove Map (ancho completo)
BtnRemove = makeBtn(Frame, "Remove Map", Color3.fromRGB(50,28,10), FRAME_W-PX*2, BH, PX, PY+4+BH+GAP)

-- Ajustar alto total del frame
Frame.Size = UDim2.new(0, FRAME_W, 0, PY+4+BH*2+GAP*2+8)

-- -- Logica botones --------------------------------
BtnGod.Activated:Connect(function()
    godActive = not godActive
    if godActive then
        activate()
        BtnGod.Text             = "God OFF"
        BtnGod.BackgroundColor3 = Color3.fromRGB(55,10,10)
    else
        deactivate()
        BtnGod.Text             = "God Mode"
        BtnGod.BackgroundColor3 = Color3.fromRGB(18,40,18)
    end
    updateDot()
end)

BtnAuto.Activated:Connect(function()
    autoBrainActive = not autoBrainActive
    if autoBrainActive then
        BtnAuto.Text             = "Auto OFF"
        BtnAuto.BackgroundColor3 = Color3.fromRGB(55,10,10)
        startAutoBrain()
    else
        stopAutoBrain()
        BtnAuto.Text             = "Auto Brain"
        BtnAuto.BackgroundColor3 = Color3.fromRGB(30,20,55)
    end
    updateDot()
end)

BtnRemove.Activated:Connect(function()
    removeActive = not removeActive
    if removeActive then
        activateRemove()
        BtnRemove.Text             = "Remove OFF"
        BtnRemove.BackgroundColor3 = Color3.fromRGB(55,10,10)
    else
        deactivateRemove()
        BtnRemove.Text             = "Remove Map"
        BtnRemove.BackgroundColor3 = Color3.fromRGB(50,28,10)
    end
    updateDot()
end)

-- =============================================
--  DRAG
-- =============================================
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

-- =============================================
--  RAINBOW
-- =============================================
local rainbowHue = 0
RS.Heartbeat:Connect(function(dt)
    rainbowHue = (rainbowHue + dt * 0.4) % 1
    local c1 = Color3.fromHSV(rainbowHue % 1,          0.85, 1)
    local c2 = Color3.fromHSV((rainbowHue + 0.5)  % 1, 0.85, 1)
    local c3 = Color3.fromHSV((rainbowHue + 0.33) % 1, 0.85, 1)
    local ct = Color3.fromHSV((rainbowHue + 0.25) % 1, 0.7,  1)
    Title.TextColor3 = ct
    if BtnGod    and not godActive       then BtnGod.TextColor3    = c1 end
    if BtnAuto   and not autoBrainActive then BtnAuto.TextColor3   = c2 end
    if BtnRemove and not removeActive    then BtnRemove.TextColor3 = c3 end
end)

-- =============================================
--  INFINITE JUMP
-- =============================================
UIS.JumpRequest:Connect(function()
    local char = lp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

print("[Rozek v4] Cargado - God | Auto Brain | Instant Pickup | Remove Map | Infinite Jump")
