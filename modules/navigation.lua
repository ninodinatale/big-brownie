---
--- Navigation
---
--- Functions for handling the Navigation of the player.
---

local Navigation = { }

local Tinkr = ...
local NAME = ...
local Common = Tinkr.Common
local Nav = Tinkr.Util.Nav
local OM = Tinkr.Util.ObjectManager

---
--- Generates a path with object avoidance.
--- fromX, fromY, fromZ: Starting coordinates.
--- toX, toY, toZ: Destination coordinates.
--- Returns: The generated path and the type of the generated path (Tinkr.Util.Nav.PathType), which can be:
---         1: Normal           normal path
---			2: NoPath           no valid path at all or error in generating one
---			3: NotUsingPath     used when we are either flying/swiming or on map w/o mmaps
---			4: Short            path is longer or equal to its limited path length
---			5: Blank            path not built yet
---			6: Shortcut         travel through obstacles, terrain, air, etc (old behavior)
---			7: Incomplete       we have partial path to follow - getting closer to target
---
function Navigation.GeneratePath(fromX, fromY, fromZ, toX, toY, toZ)
    local path, type = Nav:Path(fromX, fromY, fromZ, toX, toY, toZ, GetMapId())

    -- a set of know object sizes
    local knows_sizes = {
        [177025] = 4,
        [177019] = 6,
        [183347] = 4,
        [184640] = 4
    }

    if #path > 2 then
        -- loop over all objects and collect ones we want to avoid, here we just collect all
        local objects = { }
        for object in OM:Objects(OM.Types.GameObject) do
            local ox, oy, oz = object:position()
            if ox and oy and oz then
                local id = object:id()
                local orad = (knows_sizes[id] or (object:boundingRadius() or 1.5))
                table.insert(objects, { ox, oy, oz, orad })
            end
        end

        -- adjust points based on proximity to objects
        local extra_buffer = 1.5
        for i, point in ipairs(path) do
            for oi, object in ipairs(objects) do
                local dist = FastDistance(point.x, point.y, point.z, object[1], object[2], object[3])
                if dist < (object[4] * extra_buffer) then
                    local ab = Common.GetAnglesBetweenPositions(object[1], object[2], 0, point.x, point.y, 0)
                    local sx, sy, sz = Common.GetPositionFromPosition(point.x, point.y, point.z, (object[4] * extra_buffer) - dist, ab, 0)
                    point.x, point.y, point.z = sx, sy, sz
                end
            end
        end
    end
    return path, type
end

return Navigation
