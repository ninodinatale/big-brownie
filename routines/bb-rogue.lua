local Tinkr = ...
local Routine = Tinkr.Routine
local movement = Tinkr:require("scripts.big-brownie.modules.movement")

-- An example solo/farming Rogue routine for TBC.
-- Once automatically loaded, enable in-game with
-- /routine load rogue

-- REF: https://www.icy-veins.com/tbc-classic/rogue-dps-pve-rotation-cooldowns-abilities

Routine:RegisterRoutine(function()

    if UnitExists('target') and not UnitIsDeadOrGhost('target') and enemy('target') then
        movement.navigateToTarget(3, 0)

        if gcd() > latency() then
            return
        end

        if not latencyCheck() then
            return
        end

        if mounted() then
            return
        end

        if not IsPlayerAttacking('target') then
            Eval('StartAttack()', 't')
        end

        if castable(Eviscerate, 'target') and combo() >= 4 then
            return cast(Eviscerate, 'target')
        end
        if castable(SliceAndDice, 'target') and combo() >= 2 and not buff(SliceAndDice, 'player') then
            return cast(SliceAndDice, 'target')
        end
        if castable(SinisterStrike, 'target') then
            return cast(SinisterStrike, 'target')
        end



        --if castable(Shiv, 'target') and debuffduration(DeadlyPoison, 'target') < 1 then
        --    return cast(Shiv, 'target')
        --end
        --if castable(SinisterStrike, 'target') and
        --        (combo() < 2 or (buffduration(SliceAndDice, 'player') > 3 and combo() < 5)) then
        --    return cast(SinisterStrike, 'target')
        --end
        --if castable(SliceAndDice, 'target') and combo() >= 2 and not buff(SliceAndDice, 'player') then
        --    return cast(SliceAndDice, 'target')
        --end
        --if ttd() < 8675309 and ttd() > 50 then
        --    if castable(BladeFlurry, 'target') then
        --        return cast(BladeFlurry, 'target')
        --    end
        --    if castable(AdrenalineRush, 'target') then
        --        return cast(AdrenalineRush, 'target')
        --    end
        --end
        --if castable(ExposeArmor, 'target') and combo() == 5 and
        --        (not debuff(ExposeArmor, 'target') or debuffduration(ExposeArmor, 'target') < 2) then
        --    return cast(ExposeArmor, 'target')
        --end
        --if castable(SliceAndDice, 'target') and combo() >= 2 and buffduration(SliceAndDice, 'player') < 2 then
        --    return cast(SliceAndDice, 'target')
        --end
        --if castable(Eviscerate, 'target') and combo() >= 3 and buffduration(Rapture, 'player') > 4 and
        --        not debuff(Eviscerate, 'target') then
        --    return cast(Eviscerate, 'target')
        --end
        --if castable(Rapture, 'target') and combo() >= 2 and between(2, buffduration(Rapture, 'player'), 4) then
        --    return cast(Rapture, 'target')
        --end
    end

end, Routine.Classes.Rogue, 'bb-rogue')
