local Tinkr = ...
local tinkrFns = Tinkr:require('Routine.Modules.Exports')

print(tinkrFns.combat())

--local deb = Tinkr:require('debug')
--print(deb)
--function getArgs(fun)
--    local args = {}
--    local hook = debug.gethook()
--
--    local argHook = function( ... )
--        local info = debug.getinfo(3)
--        if 'pcall' ~= info.name     then return end
--
--        for i = 1, math.huge do
--            local name, value = debug.getlocal(2, i)
--            if '(*temporary)' == name then
--                debug.sethook(hook)
--                error('')
--                return
--            end
--            table.insert(args,name)
--        end
--    end
--
--    debug.sethook(argHook, "c")
--    pcall(fun)
--
--    return args
--end
--
--print(getArgs(Tinkr.require))
--
--print("end")
