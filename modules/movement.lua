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

    local playerX, playerY, playerZ = ObjectPosition('player')

    if positioning.isXYZInRangeOf(playerX, playerY, playerZ, toX, toY, toZ, options.threshold) then
        -- player reached the coordinates
        TurnLeftStop()
        TurnRightStop()
        if not options.keepMoving then
            MoveForwardStop()
        end
        return true
    end

    local targetRadian = positioning.getTargetRadians(playerX, playerY, toX, toY)
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

        utils.runDelayed(function()
            MoveForwardStart()
        end, options.moveFrequencyDelayMs)
    end

    return false
end

return Movement
