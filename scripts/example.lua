-- Welcome to the Tinkr scripting system! We provide many utilties to help
-- you along the way, below you can find a few examples.
-- The Tinkr object is passed to all scripts and can be accessed via the
-- global vararg as shown below.  You don't need to understand this, just
-- know that this is how you get your local copy of the Tinkr library.
local Tinkr = ...

 -- A simple script to draw lines and the names of all objects around you.
 local Draw = Tinkr.Util.Draw:New()
 local Common = Tinkr.Common
 local ObjectManager = Tinkr.Util.ObjectManager
local moveTo = MoveTo

local first = true

 Draw:Sync(function(draw)
     local px, py, pz = ObjectPosition('player')

     if first then
         print(tostring(px) .. " | " .. tostring(py) .. " | " .. tostring(pz))
         first = false
     end

     moveTo(-2927.79,-272.45,53.90)

     -- draw the cursor position in world
     local mx, my, mz = Common.ScreenToWorld(GetCursorPosition())
     draw:SetColor(draw.colors.white)
     draw:Circle(mx, my, mz, 0.5)

     local playerHeight = ObjectHeight('player')
     local playerRadius = ObjectBoundingRadius('player')
     local combatReach = ObjectCombatReach('player')
     draw:SetColor(draw.colors.white)
     draw:Circle(px, py, pz, playerRadius)
     draw:Circle(px, py, pz, combatReach)

     local rotation = ObjectRotation('player')
     local rx, ry, rz = RotateVector(px, py, pz, rotation, playerRadius);

     draw:Line(px, py, pz, rx, ry, rz)

     for object in ObjectManager:Objects() do
         local name = ObjectName(object)
         local height = ObjectHeight(object) or 1
         local x, y, z = ObjectPosition(object)
         if x and y and z then
             local distance = Common.Distance(px, py, pz, x, y, z)
             if distance < 100 then
                 draw:SetColorFromObject(object)
                 local hx, hy, hz = TraceLine(px, py, pz + playerHeight, x, y, z + height, Common.HitFlags.All)
                 if hx ~= 0 or hy ~= 0 or hz ~= 0 then
                     draw:SetAlpha(48)
                 else
                     draw:SetAlpha(196)
                 end
                 draw:Line(px, py, pz, x, y, z)
                 draw:Text((name or "Obj") .. " (" .. Common.Round(distance, 1) .. ")", "SourceCodePro", x, y, z + height)
             end
         end
     end

     for m in ObjectManager:Missiles() do
         -- inital -> hit
         draw:SetColor(255, 255, 255, 128)
         draw:Line(m.ix, m.iy, m.iz, m.hx, m.hy, m.hz)

         -- current -> hit
         draw:SetColor(3, 252, 11, 256)
         draw:Line(m.cx, m.cy, m.cz, m.hx, m.hy, m.hz)

         -- model -> hit
         if m.mx and m.my and m.mz then
             draw:SetColor(3, 252, 252, 256)
             draw:Line(m.mx, m.my, m.mz, m.hx, m.hy, m.hz)
         end

         draw:SetColor(255, 255, 255, 255)
         local cdt = Common.Distance(m.cx, m.cy, m.cz, m.hx, m.hy, m.hz)
         local spell = GetSpellInfo(m.spellId)
         draw:Text((spell or m.spellId), "NumberFont_Small", m.cx, m.cy, m.cz + 1.35)
     end
 end)

 Draw:Enable()
--
---- CacheWrite()
--local status
--local value
--
---- status = CacheWrite('test', 'foobar')
--print('write was a', status and 'success' or 'failure')
--value = CacheRead('test')
--print('value is', type(value), value)
--
---- status = CacheWrite('test2', 123.45)
--print('write was a', status and 'success' or 'failure')
--value = CacheRead('test2')
--print('value is', type(value), value)
--
---- status = CacheWrite('test3', false)
--print('write was a', status and 'success' or 'failure')
--value = CacheRead('test3')
--print('value is', type(value), value)
--
--value = CacheRead('test4')
--print('value is', type(value), value)
