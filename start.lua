local Tinkr = ...

-- TODO: script should be able to be passed via command.
local scriptPath = 'big-brownie/scripts/walk_route.lua'

-- TODO: routine name should be able to be passed via command.
local routineName = 'big-brownie-routine'
if scriptPath == nil then
    error("No script path provided.")
end
if routineName == nil then
    error("No routine name provided.")
end

Tinkr.Routine:LoadRoutine(routineName)
Tinkr.Util.Script:Load(scriptPath)
