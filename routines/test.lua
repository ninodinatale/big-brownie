local Tinkr = ...
local Routine = Tinkr.Routine

Routine:RegisterRoutine(function()
    print('lol')
    local x, y, z = ObjectPosition('player')
    MoveTo(x+10,y+10,z)
end, Routine.Classes.Druid, 'test')
