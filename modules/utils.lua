---
--- Utils
---
--- Utility functions.
---

local NAME = ...

local Utils = { }

---
--- Runs the passed function only once within the passed delay. This is useful if the function
--- is run in the game loop, but should only run once every e.g. 500ms and not getting spammed.
---
Utils.Debounced = {}
function Utils.Debounced:New(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.fn = o.fn or fn
    self.debounceMs = o.debounceMs or 0
    self.lastGameTick = o.lastGameTick or GetGameTick()
    self.isFirst = o.isFirst or true
    return o
end
function Utils.Debounced:Run(fn, debounceMs, skipFirst)
    local gameTick = GetGameTick()

    -- Should first run being skipped?
    if skipFirst == true and self.isFirst == true then
        self.lastGameTick = gameTick
    end
    if (gameTick - self.lastGameTick) > debounceMs then
        self.lastGameTick = gameTick
        fn()
    end
    self.isFirst = false
    return o
end

--Utils.Delayed = {}
--function Utils.Delayed:New(o)
--    o = o or {}
--    setmetatable(o, self)
--    self.__index = self
--    self.fn = o.fn or fn
--    self.delayMs = o.delayMs or 0
--    self.firstGameTick = nil
--    self.hasBeenRan = o.hasBeenRan or false
--    return o
--end
--
--function Utils.Delayed:Run(fn, delayMs)
--    if self.hasBeenRan ~= true then
--        if not self.firstGameTick then
--            self.firstGameTick = GetGameTick()
--        end
--        if (GetGameTick() - self.firstGameTick) > delayMs then
--            fn()
--            self.hasBeenRan = true
--        end
--    end
--    return self.hasBeenRan
--end

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
        if type(mt) == "table" then
            for key, value in pairs(mt) do
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
    end
    return true
end

function printAndWriteFile(str, filepath)
    if filepath ~= nil then
        return WriteFile(filepath, str .. "\n", true)
    end
    return true
end

function Utils.canMount()
    -- IsIndoors() returns true if inside, false if outside. nil will be returned if "inside" but still able to mount
    return IsIndoors() ~= true
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

Utils.LogState = {}
function Utils.LogState:New(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.lastLoggedGroupId = o.lastLoggedGroupId
    self.lastLoggedDepth = o.lastLoggedDepth
    return o
end
function Utils.LogState:Log(groupId, depth, value)
    local shouldLog = false
    if self.lastLoggedGroupId ~= groupId then
        self.lastLoggedDepth = depth
        shouldLog = true
    else
        if depth > self.lastLoggedDepth then
            self.lastLoggedDepth = depth
            shouldLog = true
        end
    end
    if shouldLog then
        Utils.log(value)
    end
end

return Utils
