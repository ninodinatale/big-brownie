-- Welcome to the Tinkr scripting system! We provide many utilties to help
-- you along the way, below you can find a few examples.
-- The Tinkr object is passed to all scripts and can be accessed via the
-- global vararg as shown below.  You don't need to understand this, just
-- know that this is how you get your local copy of the Tinkr library.
local Tinkr = ...

-- A simple script to draw lines and the names of all objects around you.
local Draw = Tinkr.Util.Draw:New()
local json = Tinkr:require("scripts.json")
local Util = Tinkr:require("scripts.util")

local first = true
local DRAW_DISTANCE = 30

-- ObjectType.Unit (3) -> so units only
local objects = Objects(3)
local closestUnit
local closestDistance = -1
for i, unit in ipairs(objects) do
    local distance = ObjectDistance('player', unit)
    if type(distance) == "number" then
        if closestDistance == -1 or distance < closestDistance then
            if distance ~= 0 then
                closestDistance = distance
                closestUnit = unit
            end
        end
    end
end

if closestUnit ~= nil then
    MoveTo(ObjectPosition(closestUnit))
end


--Draw:Sync(function(draw)
--    local px, py, pz = ObjectPosition('player')
--    local json_str = ReadFile('route.json')
--    if json_str then
--        json_data = json.decode(json_str) -- Returns { 1, 2, 3, { x = 10 } }
--
--        for index, waypoint in ipairs(json_data.waypoints) do
--            if math.abs(math.abs(waypoint.x) - math.abs(px)) < DRAW_DISTANCE and
--                    math.abs(math.abs(waypoint.y) - math.abs(py)) < DRAW_DISTANCE then
--                draw:SetColor(draw.colors.white)
--                draw:Circle(waypoint.x, waypoint.y, waypoint.z, 0.5)
--                draw:Text(index, "SourceCodePro", waypoint.x, waypoint.y, waypoint.z + 1)
--
--            end
--        end
--
--    end
--
--    first = false
--end)

Draw:Enable()
