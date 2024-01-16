---
--- Movement
---
--- Functions for handling the movement of the player.
---

local Movement = { }

local Tinkr = ...
local NAME = ...

local Positioning = Tinkr:require("scripts.big-brownie.modules.positioning")
local Navigation = Tinkr:require("scripts.big-brownie.modules.navigation")
local utils = Tinkr:require("scripts.big-brownie.modules.utils")
local tinkrFns = Tinkr:require('Routine.Modules.Exports')
local Detour = Tinkr.Util.Detour
local Utils = Tinkr:require("scripts.big-brownie.modules.utils")

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

    if Positioning.isXYZInRangeOf(playerX, playerY, playerZ, toX, toY, toZ, options.threshold) then
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

    local pathFindingWaypoint = getNextPathFindingWaypoint(targetX, targetY, targetZ)
    movePlayer(playerX, playerY, pathFindingWaypoint.x, pathFindingWaypoint.y, targetReached, moveFrequencyDelayMs)

    return targetReached
end

---
--- Moves the player with `Click to move` to the end position `toX, toY, toZ` with
--- pathfinding to that end position.
---
local lastWaypoint
function Movement.moveToWithClick(toX, toY, toZ)
    local pathFindingWaypoint = getNextPathFindingWaypoint(toX, toY, toZ)

    if lastWaypoint == nil or lastWaypoint.x ~= pathFindingWaypoint.x or lastWaypoint.y ~= pathFindingWaypoint.y or lastWaypoint.z ~= pathFindingWaypoint.z then
        print('mocing!')
        MoveTo(pathFindingWaypoint.x, pathFindingWaypoint.y, pathFindingWaypoint.z)
        lastWaypoint = pathFindingWaypoint
    end
end

---
--- Moves the player accordingly to its target coordinates both positioning and facing.
---
--- playerX, playerY: The player coordinates.
--- targetX, targetY: The target coordinates.
--- targetReached: Boolean if the target has already reached the location and should only
---     turn to face the target.
local movePlayerRunDebounced = Utils.Debounced:New()
function movePlayer(playerX, playerY, targetX, targetY, targetReached, moveFrequencyDelayMs)
    local targetRadian = Positioning.getTargetRadians(playerX, playerY, targetX, targetY)
    local playerRadian = GetPlayerFacing()
    local directionRadian = Positioning.absoluteRadian(targetRadian - playerRadian)

    if not Positioning.isRadianInRangeOf(directionRadian, RADIAN_THRESHOLD) then
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
            movePlayerRunDebounced:Run(function()
                MoveForwardStart()
            end, moveFrequencyDelayMs)
        end
    end
end

function getNextPathFindingWaypoint(toX, toY, toZ)
    -- TODO: This is not very efficient and performant, since every tick the path is being calculated
    -- and we just grab the first one as the target. Maye use Utils.runDebounced(), or just keep
    -- it like that if it doesn't generate any problems. :)
    local pathFindingWaypoints = Detour:ToPosition(toX, toY, toZ)
    -- Taking the second waypoint since the first is the player position (?).
    local pathFindingWaypoint = pathFindingWaypoints[2]
    return pathFindingWaypoint
end

local moveToDebounced1 = Utils.Debounced:New()
function Movement.MoveTo(toX, toY, toZ, debounced)
    local debounceMs = 0
    if debounced == true then
        debounceMs = 200
    end

    moveToDebounced1:Run(function()
        MoveTo(toX, toY, toZ)
    end, debounceMs)
end

--local moveToRunDebounced = Utils.Debounced:New()
--function Movement.MoveTo(fromX, fromY, fromZ, toX, toY, toZ, reachedCallback)
--    local distance = Tinkr.Common.Distance(fromX, fromY, fromZ, toX, toY, toZ)
--    if distance < 2 then
--        MoveForwardStop()
--        return true
--    else
--        if not tinkrFns.moving() then
--            moveToRunDebounced:Run(function()
--                MoveTo(toX, toY, toZ)
--            end, 1000)
--        end
--    end
--    return false
--end
--
Movement.RunPath = { }
function Movement.RunPath:New(o, fromX, fromY, fromZ, toX, toY, toZ)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.nextWpIndex = o.nextWpIndex or 1
    self.type = o.type or Movement.RunPath.Type.NOT_STARTED
    self.fromX = o.fromX or fromX
    self.fromY = o.fromY or fromY
    self.fromZ = o.fromZ or fromZ
    self.toX = o.toX or toX
    self.toY = o.toY or toY
    self.toZ = o.toZ or toZ
    self.path = o.path or nil
    self.pathType = o.pathType or nil
    self.runDebounced1 = o.runDebounced1 or Utils.Debounced:New()
    self.runDebounced2 = o.runDebounced2 or Utils.Debounced:New()

    return o
end

---
---
---
function Movement.RunPath:Start()
    if self.type == Movement.RunPath.Type.REACHED then
        return Movement.RunPath.Type.REACHED
    end
    if not self.path then
        self.path, self.pathType = Navigation.GeneratePath(self.fromX, self.fromY, self.fromZ, self.toX, self.toY, self.toZ)
    end
    if self.pathType == Tinkr.Util.Nav.PathType.Normal or self.pathType == Tinkr.Util.Nav.PathType.Incomplete then
        --self.runDebounced1:Run(function()
        --    self.path, self.pathType = Navigation.GeneratePath(self.fromX, self.fromY, self.fromZ, self.toX, self.toY, self.toZ)
        --end, 1000)

        local playerX, playerY, playerZ = ObjectPosition('player')
        local distance = Tinkr.Common.Distance(
                playerX,
                playerY,
                playerZ,
                self.path[self.nextWpIndex].x,
                self.path[self.nextWpIndex].y,
                self.path[self.nextWpIndex].z)

        if distance < 1 then
            --MoveForwardStop()
            self.nextWpIndex = self.nextWpIndex + 1

            if self.nextWpIndex > #self.path then
                -- Target has been reached
                self.type = Movement.RunPath.Type.REACHED
                return self.type
            end
            Movement.MoveTo(self.path[self.nextWpIndex].x, self.path[self.nextWpIndex].y, self.path[self.nextWpIndex].z)
            return Movement.RunPath.Type.MOVING
        elseif distance < 2 then
            if IsFlying() then
                MoveForwardStart()
                --moveToDebounced2:Run(function()
                --end, 500, true)
            end
        end
        if not tinkrFns.moving() then
            Movement.MoveTo(self.path[self.nextWpIndex].x, self.path[self.nextWpIndex].y, self.path[self.nextWpIndex].z, true)
        end


    else
        self.type = Movement.RunPath.Type.NO_PATH
        return self.type
    end

    self.type = Movement.RunPath.Type.MOVING
    return self.type
end
Movement.RunPath.Type = {
    NOT_STARTED = -1, -- if it has not been started yet
    NO_PATH = 0, -- if there is no path available
    MOVING = 1, -- if moving but not reached target yet
    REACHED = 2 -- if target has been reached
}

---
--- States:
---     -1 = not started yet
---     0 = try path finding
---     1 = try jumping
---     2 = try strafing left
---     3 = try strafing right
---     4 = try backing up
---
Movement.AntiStuck = { state = 0, waitForFinished = false }

function Movement.AntiStuck:New()
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.state = 0
    self.waitForFinished = false
    return o
end
function Movement.AntiStuck:Perform(fromX, fromY, fromZ, toX, toY, toZ)
    MoveForwardStop()
    AscendStop()
    StrafeLeftStop()
    StrafeRightStop()
    MoveBackwardStop()
    if self.state == 0 then
        local path, pathType = Tinkr.Util.Nav:Path(fromX, fromY, fromZ, toX, toY, toZ, GetMapId())
        if pathType ~= Tinkr.Util.Nav.PathType.NoPath and path[1] then
            local reached = Movement.MoveTo(fromX, fromY, fromZ, path[1].x, path[1].y, path[1].z)
            if reached == true then
                Movement.MoveTo(fromX, fromY, fromZ, path[2].x, path[2].y, path[2].z)
            end
        else
            self.state = 1
        end
    elseif self.state == 1 then
        MoveForwardStart()
        JumpOrAscendStart()
        self.state = 2
    elseif self.state == 2 then
        StrafeLeftStart()
        self.state = 3
        self.waitForFinished = false
    elseif self.state == 3 then
        StrafeRightStart()
        self.state = 4
    elseif self.state == 4 then
        self.waitForFinished = true
        MoveBackwardStart()
        self.state = 2
    end
end

function Movement.AntiStuck:Stop()
    if self.state > 0 then
        MoveForwardStop()
        AscendStop()
        self.state = 0
    end
end

function Movement.AntiStuck:IsWaitForFinished()
    return self.waitForFinished
end


--function Movement:AntiStuck(fromX, fromY, fromZ, toX, toY, toZ)
--    o = {
--        perform = function()
--            if self.state == 0 then
--                local path, pathType = Navigation.GeneratePath(fromX, fromY, fromZ, toX, toY, toZ)
--                if pathType ~= Tinkr.Util.Nav.PathType.NoPath then
--                    Movement.MoveTo(fromX, fromY, fromZ, path.x, path.y, path.z)
--                    self.state = 1
--                else
--                    self.state = 1
--                end
--            end
--            print(self.state)
--        end,
--        state = 0
--    }   -- create object if user does not provide one
--    setmetatable(o, self)
--    self.__index = self
--    return o
--end
--
return Movement
