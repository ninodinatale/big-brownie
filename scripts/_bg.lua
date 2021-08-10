local Tinkr = ...

local Draw = Tinkr.Util.Draw:New()
local JSON = Tinkr:require("scripts.big-brownie.modules.json")
local movement = Tinkr:require("scripts.big-brownie.modules.movement")
local tinkrFns = Tinkr:require('Routine.Modules.Exports')
local utils = Tinkr:require("scripts.big-brownie.modules.utils")

-- TODO: replace with battleground profiles.
local profile_json_str = ReadFile("scripts/big-brownie/profiles/terokkar.json")

if profile_json_str == false then
    utils.logerror("Could not read profile.")
    return
end

local profile_json_data = JSON.decode(profile_json_str)

if profile_json_str == nil then
    utils.logerror("Could not decode profile content.")
end

local waypoints = profile_json_data.waypoints

if waypoints == nil then
    utils.logerror("Profile seems to be corrupt.")
end

local ENEMY_SEARCH_RANGE = 40

local firstRun = true
local nextWpIndex = 1
Draw:Sync(function(draw)

    if not tinkrFns.enemy('target') or UnitIsDead("target") then
        --- No next target, let's walk the route then.

        setClosestWaypointIndex()

        local startedEating = handleEatingAndDrinking()
        if startedEating then return end

        -- Wait for finished eating or 100% health before walking the route.
        if not tinkrFns.IsEatingOrDrinking() or tinkrFns.health() >= BB.config.eatingAtHp then

            draw:SetColor(draw.colors.white)
            draw:Circle(waypoints[nextWpIndex].x, waypoints[nextWpIndex].y, waypoints[nextWpIndex].z, 0.5)

            local reachedCoords = movement.navigateToXYZ(waypoints[nextWpIndex].x, waypoints[nextWpIndex].y, waypoints[nextWpIndex].z, { threshold = 1, keepMoving = true })

            if reachedCoords == true then
                nextWpIndex = nextWpIndex + 1

                if nextWpIndex > table.getn(waypoints) then
                    -- Start from first waypoint again.
                    nextWpIndex = 1
                end
            end

            local closestUnit = getClosestAliveUnit(ENEMY_SEARCH_RANGE)
            if closestUnit ~= nil then
                TargetUnit(closestUnit)
            end
        end
    else
        -- enter combat, movement is then handled by the routine.
        startCombatIfNotStarted()
    end
    firstRun = false
end)

-- Setting the Draw reference to be able to enable and disable the sync.
BB.scripts.bg.draw = Draw

function getClosestWaypointIndex()
    local playerX, playerY, playerZ = ObjectPosition('player')

    local closesDistance, closestWaypointIndex
    for i, waypoint in ipairs(waypoints) do
        local distance = FastDistance(playerX, playerY, playerZ, waypoint.x, waypoint.y, waypoint.z)
        if closesDistance == nil or distance < closesDistance then
            closesDistance = distance
            closestWaypointIndex = i
        end
    end
    return closestWaypointIndex
end

---
--- Finds and sets the closest waypoint.
---
function setClosestWaypointIndex()
    local combatStopped = stopCombatIfNotStopped()
    if firstRun or combatStopped then
        local closestWaypointIndex = getClosestWaypointIndex()
        if closestWaypointIndex ~= nil then
            nextWpIndex = closestWaypointIndex
        end
    end
end

function startCombatIfNotStarted()
    if not Tinkr.Routine.enabled then
        Tinkr.Routine:Enable()
    end
end

---
--- Returns true if combat has been stopped, false otherwise.
---
function stopCombatIfNotStopped()
    if Tinkr.Routine.enabled then
        if not tinkrFns.combat() then
            Tinkr.Routine:Disable()
            return true
        end
    end
    return false
end

---
--- Returns true player started eating, false otherwise.
---
function handleEatingAndDrinking()
    if tinkrFns.health() < BB.config.eatingAtHp then
        if not tinkrFns.IsEatingOrDrinking() then
            MoveForwardStop()
            TurnLeftStop()
            TurnRightStop()
            Eval('RunMacroText("/use ' .. BB.config.food .. '")', 'r')
            return true
        end
    end
    return false
end

function getClosestAliveUnit(search_range)
    -- ObjectType.Unit (3) -> so units only
    local objects = Objects(3)

    local closestUnit
    local closestDistance = -1
    for i, unit in ipairs(objects) do
        if not UnitIsDeadOrGhost(unit) then
            local distance = ObjectDistance('player', unit)
            if type(distance) == "number" then
                if distance == nil or distance <= search_range then
                    if closestDistance == -1 or distance < closestDistance then
                        if distance ~= 0 then
                            closestDistance = distance
                            closestUnit = unit
                        end
                    end
                end
            end

        end
    end

    return closestUnit
end
