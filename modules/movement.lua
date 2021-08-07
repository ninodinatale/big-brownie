---
--- Movement
---
--- Functions for handling the movement of the player.
---

local Movement = { }

local Tinkr = ...
local NAME = ...

local positioning = Tinkr:require("scripts.big-brownie.modules.positioning")
local utils = Tinkr:require("scripts.big-brownie.modules.utils")
local tinkrFns = Tinkr:require('Routine.Modules.Exports')
local Detour = Tinkr.Util.Detour

local RADIAN_THRESHOLD = 0.1

local RADIAN_NORTH = 0
local RADIAN_SOUTH = math.pi
local RADIAN_EAST = math.pi + (math.pi / 2)
local RADIAN_WEST = math.pi / 2

---
--- Navigates the player to the passed coordinates x,y,z WITHOUT click to move. Returns true
--- if the player reached the coordinates in consideration of the provided threshold, false
--- otherwise.
---
--- toX, toY, toZ: The coordinates the player should move to.
---
--- options [table] (optional, and all member optional)
---     threshold [number]: The threshold to reach the coordinates. A threshold needs to be provided since the
---         player cannot reach the exact coordinates and would be stuck in place turning over
---         and over again.
---     moveFrequencyDelayMs [number]: The frequency the player moves in milliseconds. This is
---         useful to make sure the player won't spam "move forward" which would look very non humanly.
---     keepMoving: [boolean]: If true, does not stop moving forward after reaching the target
---         coordinates. This is useful for navigating a route where otherwise the player
---         would stop and then start moving again in the next cycle, which looks very bot like.
---         So use this if navigating a route or similar.
---
function Movement.navigateToXYZ(toX, toY, toZ, options)

    if options == nil then
        options = {}
    end

    if options.threshold == nil then
        options.threshold = 1
    end
    if options.moveFrequencyDelayMs == nil then
        options.moveFrequencyDelayMs = 0
    end
    if options.keepMoving == nil then
        options.keepMoving = false
    end

    local targetReached = false

    local playerX, playerY, playerZ = ObjectPosition('player')

    if positioning.isXYZInRangeOf(playerX, playerY, playerZ, toX, toY, toZ, options.threshold) then
        -- player reached the coordinates
        if not options.keepMoving then
            MoveForwardStop()
        end
        targetReached = true
    end

    local pathFindingWaypoint = getNextPathFindingWaypoint(toX, toY, toZ)

    movePlayer(playerX, playerY, pathFindingWaypoint.x, pathFindingWaypoint.y, targetReached, options.moveFrequencyDelayMs)

    return targetReached
end

---
--- Navigates the player to its target WITHOUT click to move. Returns true
--- if the player reached the target in consideration of the provided distance, false
--- otherwise.
---
--- distance [number] (optional): The distance in yards to stop before reaching the target's
---     location. This is used for ranged attack, but also useful for melee to set some buffer
---     distance. Don't set this to 0 since it can't reach exactly zero and would move
---     around like crazy.
--- moveFrequencyDelayMs [number]: The frequency the player moves in milliseconds. This is
---     useful to make sure the player won't spam "move forward" which would look very non humanly.
function Movement.navigateToTarget(distance, moveFrequencyDelayMs)

    if distance == nil or distance == 0 then
        distance = 2
    end

    local targetReached = false

    local playerX, playerY, playerZ = ObjectPosition('player')
    local targetX, targetY, targetZ = ObjectPosition('target')

    if tinkrFns.distance('player', 'target') <= distance then
        -- player reached the coordinates
        MoveForwardStop()
        targetReached = true
    end

    local pathFindingWaypoint = getNextPathFindingWaypoint(toX, toY, toZ)
    movePlayer(playerX, playerY, pathFindingWaypoint.x, pathFindingWaypoint.y, targetReached, moveFrequencyDelayMs)

    return targetReached
end

---
--- Moves the player accordingly to its target coordinates both positioning and facing.
---
--- playerX, playerY: The player coordinates.
--- targetX, targetY: The target coordinates.
--- targetReached: Boolean if the target has already reached the location and should only
---     turn to face the target.
function movePlayer(playerX, playerY, targetX, targetY, targetReached, moveFrequencyDelayMs)
    local targetRadian = positioning.getTargetRadians(playerX, playerY, targetX, targetY)
    local playerRadian = GetPlayerFacing()
    local directionRadian = positioning.absoluteRadian(targetRadian - playerRadian)

    if not positioning.isRadianInRangeOf(directionRadian, RADIAN_THRESHOLD) then
        if directionRadian < RADIAN_SOUTH then
            -- Turning left is closer to target
            TurnRightStop()
            TurnLeftStart()

            if directionRadian > RADIAN_WEST then
                -- We want to turn in place
                MoveForwardStop()
            end
        else
            -- Turning right is closer to target
            TurnLeftStop()
            TurnRightStart()

            if directionRadian < RADIAN_EAST then
                -- We want to turn in place
                MoveForwardStop()
            end
        end

    else
        TurnLeftStop()
        TurnRightStop()

        if targetReached == false then
            utils.runDelayed(function()
                MoveForwardStart()
            end, moveFrequencyDelayMs)
        end
    end
end

function getNextPathFindingWaypoint(toX, toY, toZ)
    -- TODO: This is not very efficient and performant, since every tick the path is being calculated
    -- and we just grab the first one as the target. Maye use Utils.runDelayed(), or just keep
    -- it like that if it doesn't generate any problems. :)
    local pathFindingWaypoints = Detour:ToPosition(toX, toY, toZ)
    -- Taking the second waypoint since the first is the player position (?).
    local pathFindingWaypoint = pathFindingWaypoints[2]
    return pathFindingWaypoint
end

return Movement
