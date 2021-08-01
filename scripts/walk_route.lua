-- Welcome to the Tinkr scripting system! We provide many utilties to help
-- you along the way, below you can find a few examples.
-- The Tinkr object is passed to all scripts and can be accessed via the
-- global vararg as shown below.  You don't need to understand this, just
-- know that this is how you get your local copy of the Tinkr library.
local Tinkr = ...

Tinkr.Routine:LoadRoutine('big-brownie-routine')




local Draw = Tinkr.Util.Draw:New()
local JSON = Tinkr:require("scripts.json")
local movement = Tinkr:require("scripts.big-brownie.modules.movement")

local tinkrFns = Tinkr:require('Routine.Modules.Exports')

local json_str = ReadFile('route.json')

if json_str == false then
    print("Could not read route file.")
end

local json_data = JSON.decode(json_str)

if json_str == nil then
    print("Could not decode route file content.")
end

local waypoints = json_data.waypoints

if waypoints == nil then
    print("Route file has no 'waypoints' node.")
end

local inCombat = false

local next_wp_index = 1
local next_wp = waypoints[next_wp_index]

Draw:Sync(function(draw)

    if not tinkrFns.enemy('target') or UnitIsDead("target") then
        inCombat = false
        --- No next target, let's walk the route then.
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

        -- try to get the next target
        local closestUnit = getClosestAliveUnit(20)
        -- ObjectFlags(closestUnit) == 0 is alive? 2048 is dead?
        if closestUnit ~= nil then
            TargetUnit(closestUnit)
        else
            -- TODO: this spams ClearTarget(). Should add check if we have a target first.
            --ClearTarget()
        end

    else
        --- combat/interactions/etc, everything not walking the route
        --- enter combat
        local targetX, targetY, targetZ = ObjectPosition('target')
        movement.navigateToXYZ(targetX, targetY, targetZ, { threshold = 2, moveFrequencyDelayMs = 350 })

        if inCombat == false then
            -- TODO: routine
            AttackTarget()
            inCombat = true
        end
    end

end)

Draw:Enable()

function getClosestAliveUnit(search_distance)
    -- ObjectType.Unit (3) -> so units only
    local objects = Objects(3)

    local closestUnit
    local closestDistance = -1
    for i, unit in ipairs(objects) do
        if not UnitIsDeadOrGhost(unit) then
            local distance = ObjectDistance('player', unit)
            if type(distance) == "number" then
                if distance == nil or distance <= search_distance then
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
