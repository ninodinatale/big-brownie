---
--- Utils
---
--- Utility functions.
---

local NAME = ...

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

function Utils.printMemberOf(obj, filepath, maxDepth)

    if maxDepth == nil then
        maxDepth = 10
    end
    if not type(obj) == "table" then
        error("Can only print member tables.")
    end

    -- Emptying file first.
    WriteFile(filepath, '', true)

    local success = printMemberOf(obj, filepath, 0, maxDepth)

    if success == false then
        print('There was an error printing members')
    end

end

function printMemberOf(obj, filepath, depth, maxDepth)

    if depth >= maxDepth then
        return true
    end

    local indent = ''
    local i = 0
    while i < depth do
        indent = indent .. '\t'
        i = i + 1
    end
    for key, value in pairs(obj) do
        if printAndWriteFile(indent .. tostring(key) .. ': ' .. type(value), filepath) == false then
            return false
        end
        if type(value) == "table" then
            local success = printMemberOf(value, filepath, depth + 1, maxDepth)
            if success == false then
                return false
            end
        end
    end
    local mt = getmetatable(obj)

    if mt ~= nil then
        for key, value in pairs(getmetatable(obj)) do
            if printAndWriteFile(indent .. tostring(key) .. ': ' .. type(value), filepath) == false then
                return false
            end
            if type(value) == "table" then
                local success = printMemberOf(value, filepath, depth + 1, maxDepth)
                if success == false then
                    return false
                end
            end
        end
    end

    return true
end

function printAndWriteFile(str, filepath)
    if filepath ~= nil then
        return WriteFile(filepath, str .. "\n", true)
    end
    return true
end

function Utils.brown(str)
    return "|cffCD661D" .. str .. "|r"
end

function Utils.red(str)
    return "|cffff0000" .. str .. "|r"
end

function Utils.yellow(str)
    return "|cffffff00" .. str .. "|r"
end

local prefix = Utils.brown("[Big-Brownie]")
local errorPrefix = Utils.red("[Error]")

function Utils.log(text)
    print(prefix .. " " .. text)
end

function Utils.logerror(text)
    Utils.log(errorPrefix .. " " .. text)
end

return Utils
