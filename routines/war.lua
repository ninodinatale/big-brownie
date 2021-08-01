local Tinkr = ...
local Routine = Tinkr.Routine

Routine:RegisterRoutine(function()
    if IsPlayerAttacking(target) then
        if castable(100, 'target') then
            return cast(100, 'target')
        end
        if castable(722, 'target') and not debuff(772, 'target') then
            return cast(772, 'target')
        end
        if castable(78, 'target') then
            return cast(78, 'target')
        end
    end
end, Routine.Classes.Warrior, 'war')
