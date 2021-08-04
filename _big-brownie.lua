---------------------------------------------------------------
--- Big Brownie, yummy!
---
--- Move the big-brownie directory to `tinkr/scripts/`.
---------------------------------------------------------------

local Tinkr = ...
local Command = Tinkr.Util.Commands:New('bb')
local utils = Tinkr:require("scripts.big-brownie.modules.utils")

Command:Register({ 'start' }, function(program, routine)
    if program == nil then
        utils.logerror("No script path provided. Aborted.")
        return
    end
    if routine == nil then
        utils.logerror("No routine name provided. Aborted.")
        return
    end

    local scriptPath = 'big-brownie/scripts/' .. program .. '.lua'

    Tinkr.Routine:LoadRoutine(routine)
    Tinkr.Util.Script:Load(scriptPath)
    utils.log("Starting program " .. program .. " with routine " .. routine .. ".")
end)

utils.log('Ready.')
utils.log("Write " .. utils.yellow("/bb start <program> <routine>") .. " to start your journey!")
