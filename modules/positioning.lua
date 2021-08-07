---
--- Positioning
---
--- Functions for retrieving positions, coordinates, radians etc.
---

local NAME=...

local Positioning = { }

---
--- Returns the absolute radian of the passed radian by turning it 2π (180 degrees) if the
--- passed radian is negative.
---
function Positioning.absoluteRadian(radian)
    -- if rad is negative we need to "turn it 180 degree" by a full circle, so 2pi.
    if radian < 0 then
        radian = radian + (math.pi * 2)
    end
    return radian
end

---
--- Calculates and returns the (absolute) radian of the passed coordinates where the returned
--- radian is the direction from x1,y1 to x2,y2.
---
function Positioning.getTargetRadians(x1, y1, x2, y2)
    local deltaX = x2 - x1;
    local deltaY = y2 - y1;
    local rad = math.atan2(deltaY, deltaX);

    -- if rad is negative we need to "turn it 180 degree" by a full circle, so 2pi.
    return Positioning.absoluteRadian(rad)
end

---
--- Calculates and returns the coordinates from the passed coordinates x,y, the distance and
--- the radian.
---
--- Note: distance is just the radius of the circle drawn at x,y.
---
function Positioning.getXYByRadian(x, y, distance, radian)
    local newX = distance *  math.cos(radian)
    local newY = distance *  math.sin(radian)
    return x + newX, y + newY
end

---
--- Returns true if the passed radian is facing "forward" with the passed  and therefore allowed
--- threshold.
---
function Positioning.isRadianInRangeOf(radian, allowedThreshold)
    if radian < allowedThreshold then
        return true
    end
    if math.abs(radian - (2 * math.pi)) < allowedThreshold then
        return true
    end
    return false
end

---
--- Returns true if the coordinates x1,y1,z1 are at x2,y2,z2 with the passed and therefore allowed
--- threshold.
---
function Positioning.isXYZInRangeOf(x1, y1, z1, x2, y2, z2, allowedThreshold)
    return math.abs(math.abs(x1) - math.abs(x2)) < allowedThreshold and
            math.abs(math.abs(y1) - math.abs(y2)) < allowedThreshold and
            math.abs(math.abs(z1) - math.abs(z2)) < allowedThreshold
end


return Positioning
