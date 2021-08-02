local Tinkr = ...
local Routine = Tinkr.Routine

Routine:RegisterRoutine(function()
    -- don't spam in the GCD
    if gcd() > latency() then return end

    -- don't dismount us
    if mounted() then return end

    -- don't spam on nothing
    if not UnitExists("target") then return end

    -- don't spam on friendly or other
    if not UnitCanAttack("player", "target") then return end

    return cast(Wrath)
end, Routine.Classes.Druid, 'big-brownie-routine')
