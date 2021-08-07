---------------------------------------------------------------
--- Big Brownie, yummy!
---
--- Move the big-brownie directory to `tinkr/scripts/`.
---------------------------------------------------------------


---------------------------------------------------------------
--- This is the Big Brownie reference holding all the used
--- references.
---------------------------------------------------------------
_G.BB = {
    profile = nil,
}

local Tinkr = ...
local Command = Tinkr.Util.Commands:New('bb')
local utils = Tinkr:require("scripts.big-brownie.modules.utils")

Command:Register({ 'bg' }, function(profile, routine)
    if profile == nil or profile == '' then
        utils.logerror("No profile provided. Aborted.")
        return
    elseif profile:sub(-#'.json') ~= '.json' then
         profile = profile .. '.json'
    end
    if routine == nil or routine == '' then
        utils.logerror("No routine provided. Aborted.")
        return
    end

    local routineExists = false
    for key, value in pairs(Tinkr.Routine.routines) do
        if key == routine then
            routineExists = true
            break
        end
    end

    if not routineExists then
        utils.logerror("Provided routine " .. utils.yellow(routine) .. " does not exist.")
    end

    BB.profile = profile
    utils.log("Starting BGing with profile " .. utils.yellow(profile) .. " and routine " .. utils.yellow(routine) .. "...")
    Tinkr.Routine:LoadRoutine(routine)
    Tinkr.Util.Script:Load('big-brownie/scripts/bg.lua')
end)

utils.log('Ready.')
utils.log("Write " .. utils.yellow("/bb bg <profile> <routine>") .. " to start your journey!")
