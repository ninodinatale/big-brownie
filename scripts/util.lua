-- simple modules

-- capture the name searched for by require
local Tinkr = ...
local NAME=...

-- table for our functions
local M = { }

-- Shorthand form is less typing and doesn't use a local variable
function M.printMemberOf(obj)
    do
        Tinkr:log('Printing members of "' .. tostring(obj) .. '" ' .. "(key, value):")
        for key, value in pairs(obj) do
            Tinkr:log(key .. ' (' .. type(value) .. ')');
        end
        for key, value in pairs(getmetatable(obj)) do
            Tinkr:log(key .. ' (meta)');
            --Tinkr:log(key .. ' (' .. type(value) .. ') (meta)');
        end
        Tinkr:log('End of printing members')
    end
end

return M
