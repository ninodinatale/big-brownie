local Tinkr = ...

local utils = Tinkr:require("scripts.big-brownie.modules.utils")
local positioning = Tinkr:require("scripts.big-brownie.modules.positioning")

local exports = Tinkr:require('Routine.Modules.Exports')

--utils.printMemberOf(exports, 'routine.txt')
local playerX, playerY, playerZ = ObjectPosition('player')
local toX, toY = ObjectPosition('target')

local targetRadian = positioning.getTargetRadians(playerX, playerY, toX, toY)
local playerRadian = GetPlayerFacing()
local directionRadian = positioning.absoluteRadian(targetRadian - playerRadian)

print(directionRadian)
