local Tinkr = ...
local Routine = Tinkr.Routine

Routine:RegisterRoutine(function()
    print("routine")

    -- don't spam in the GCD
    if gcd() > latency() then return end

    -- don't dismount us
    if mounted() then return end

    -- don't spam on nothing
    if not UnitExists("target") then return end

    -- don't spam on friendly or other
    if not UnitCanAttack("player", "target") then return end

    -- don't start combat
    if not combat() then return end

    print("cast!")
end, Routine.Classes.Druid, 'big-brownie-routine')
print("routine registered")
