---
--- Utils
---
--- Utility functions.
---

local NAME=...

local Utils = { }

---
--- Runs the passed function only once within the passed delay. This is useful if the function
--- is run in the game loop, but should only run once every 500ms and not getting spammed.
---
local last_tick = GetGameTick()
function Utils.runDelayed(fn, delay_ms)
    if delay_ms == nil then
        delay_ms = 0
    end
    local game_tick = GetGameTick()
    if (game_tick - last_tick) > delay_ms then
        last_tick = game_tick
        fn()
    end
end

function Utils.printMemberOf(obj, filepath)

    function printAndWriteFile(str)
        if filepath ~= nil then
            print(str)
            WriteFile(filepath, str .. "\n", true)
        end
    end

    do

        printAndWriteFile('Members of "' .. tostring(obj) .. '" ' .. "(key, value):")
        print("xx")
        for key, value in pairs(obj) do
            printAndWriteFile(key .. ' (' .. type(value) .. ')')
        end
        --for key, value in pairs(getmetatable(obj)) do
            --printAndWriteFile(key .. ' (' .. type(value) .. ') (meta)')

        --end
        print('Successfully printed members')
    end
end

return Utils
