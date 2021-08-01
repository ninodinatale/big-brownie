local Tinkr = ...
local Routine = Tinkr.Routine

Routine:RegisterRoutine(function()
    if castable(Fireball) and IsPlayerAttacking("target") then
        return cast(Fireball)
    end
end, Routine.Classes.Mage, 'magelvl')
