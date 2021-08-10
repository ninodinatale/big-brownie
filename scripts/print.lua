local Tinkr = ...

local utils = Tinkr:require("scripts.big-brownie.modules.utils")
local Exports = Tinkr:require('Routine.Modules.Exports')

print("test1")
--print(Exports:eatordrink())
--print(Exports:eatingordrinking())
--print(Exports.iseatingordrinking('player'))
--print(Tinkr.Automator.Runners.Rest:Initialize(1,2,3,4,5,6,7,8,9,10  ))
utils.printMemberOf(Tinkr.Util.Draw:New(), 'draw:new.yml', 5)

