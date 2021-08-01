-- Welcome to the Tinkr scripting system! We provide many utilties to help
-- you along the way, below you can find a few examples.
-- The Tinkr object is passed to all scripts and can be accessed via the
-- global vararg as shown below.  You don't need to understand this, just
-- know that this is how you get your local copy of the Tinkr library.
local Tinkr = ...

local json
json = Tinkr:require("scripts.json")

local x1, y1, z1 = ObjectPosition('player')

local json_str = ReadFile('route.json')
local waypoint = {
    x = x1,
    y = y1,
    z = z1
}
local json_data

if json_str then
    json_data = json.decode(json_str) -- Returns { 1, 2, 3, { x = 10 } }
    table.insert(json_data.waypoints, waypoint)

else
    json_data = {
        waypoints = { waypoint }
    }
end
json_str = json.encode(json_data)

local success = WriteFile('route.json', json_str, false)
