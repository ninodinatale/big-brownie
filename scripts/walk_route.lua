local Tinkr = ...

local Draw = Tinkr.Util.Draw:New()
local JSON = Tinkr:require("scripts.big-brownie.modules.json")
local movement = Tinkr:require("scripts.big-brownie.modules.movement")

local tinkrFns = Tinkr:require('Routine.Modules.Exports')

local json_str = ReadFile('route.json')

if json_str == false then
    error("Could not read route file.")
end

local json_data = JSON.decode(json_str)

if json_str == nil then
    error("Could not decode route file content.")
end

local waypoints = json_data.waypoints

if waypoints == nil then
    error("Route file has no 'waypoints' node.")
end

local inCombat = false

local next_wp_index = 1
local next_wp = waypoints[next_wp_index]

Draw:Sync(function(draw)

    if not tinkrFns.enemy('target') or UnitIsDead("target") then
        --- No next target, let's walk the route then.
        stopCombatIfNotStopped()

        draw:SetColor(draw.colors.white)
        draw:Circle(next_wp.x, next_wp.y, next_wp.z, 0.5)

        local reachedCoords = movement.navigateToXYZ(next_wp.x, next_wp.y, next_wp.z, { threshold = 1, keepMoving = true })

        if reachedCoords == true then
            next_wp_index = next_wp_index + 1

            if next_wp_index > table.getn(waypoints) then
                -- Start from first waypoint again.
                next_wp_index = 1
            end
            next_wp = waypoints[next_wp_index]
        end

        local closestUnit = getClosestAliveUnit(50)
        if closestUnit ~= nil then
            TargetUnit(closestUnit)
        end

    else
        --- combat/interactions/etc, everything not walking the route
        --- enter combat
        if tinkrFns.casting() == false then
            movement.navigateToTarget(30, 300)
        end
        startCombatIfNotStarted()
    end

end)

Draw:Enable()

function startCombatIfNotStarted()
    if not Tinkr.Routine.enabled then
        print("enable routine!")
        Tinkr.Routine:Enable()
    end
end

function stopCombatIfNotStopped()
    if Tinkr.Routine.enabled then
        print("disable routine!")
        Tinkr.Routine:Disable()
    end
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
