---------------------------------------------------------------
--- Big Brownie, yummy!
---
--- Move the big-brownie directory to `tinkr/scripts/`.
---------------------------------------------------------------


---------------------------------------------------------------
--- This is the Big Brownie Global holding all the used
--- references.
---------------------------------------------------------------
_G.BB = {
    scripts = {
    }
}

local Tinkr = ...
local Command = Tinkr.Util.Commands:New('bb')
local Common = Tinkr.Common
local Draw = Tinkr.Util.Draw:New()
local Utils = Tinkr:require("scripts.big-brownie.modules.utils")
local Detour = Tinkr.Util.Detour
local Legacy = Tinkr:require("scripts.big-brownie.scripts.legacy")
local CreateRoute = Tinkr:require("scripts.big-brownie.scripts.create_route")
local NavDebug = Tinkr:require("scripts.big-brownie.scripts.nav_debug")
local Navigation = Tinkr:require("scripts.big-brownie.modules.navigation")
local Movement = Tinkr:require("scripts.big-brownie.modules.movement")
local Positioning = Tinkr:require("scripts.big-brownie.modules.positioning")
local Netherwing = Tinkr:require("scripts.big-brownie.scripts.netherwing_eggfarm")
local tinkrFns = Tinkr:require('Routine.Modules.Exports')
local ObjectManager = Tinkr.Util.ObjectManager
local Nav = Tinkr.Util.Nav

Command:Register({ 'legacy' }, function()
    Legacy.showGUI()
end)

Command:Register({ 'create_route' }, function()
    CreateRoute.showGUI()
end)

Command:Register({ 'netherwing' }, function()
    Netherwing.showGUI()
end)

Command:Register({ 'printTinkrObj' }, function()
    Utils.printMemberOf(_G, "scripts/big-brownie/global-object.yml", 1)
end)

Command:Register({ 'nav_debug' }, function()
    Utils.printMemberOf(_G, "scripts/big-brownie/global-object.yml", 1)
end)

Command:Register({ 'b' }, function()
    local tx, ty, tz = -4172.6518554688, 297.49304199219, 124.34543609619
    local px, py, pz = ObjectPosition('player')
    local theta = Positioning.getTargetRadians(px, py, tx, ty)

    local newX, newY, newZ = RotateVector(tx, ty, tz, theta, 0);

    Draw:Sync(function(draw)
        draw:SetColor(draw.colors.green)
        draw:Line(px, py, pz, tx, ty, tz)
        draw:SetColor(draw.colors.red)
        draw:Circle(newX, newY, newZ, 0.5)
    end)
    Draw:Enable()


end)

Command:Register({ 'bb' }, function()
    local tx, ty, tz = -4172.6518554688, 297.49304199219, 126.34543609619
    local px, py, pz = ObjectPosition('player')
    local path = Tinkr.Util.Fly:GetFlightRoute(px, py, pz, tx, ty, tz)

    Draw:Sync(function(draw)
        if path then
            for index, waypoint in ipairs(path) do
                if (index - 1 >= 1) then
                    draw:SetColor(draw.colors.green)
                    draw:Line(waypoint.x, waypoint.y, waypoint.z, path[index - 1].x, path[index - 1].y, path[index - 1].z)
                end
            end
        end
    end)
    Draw:Enable()


end)

Command:Register({ 'nav' }, function()
    Draw:Sync(function(draw)
        local playerX, playerY, playerZ = ObjectPosition('player')

        local nearestObject = nil
        local currentDistance = nil
        for object in ObjectManager:Objects() do
            if ObjectName(object) == 'Netherwing Egg' then
                local x, y, z = ObjectPosition(object)
                local distance = Common.Distance(playerX, playerY, playerZ, x, y, z)

                if not currentDistance or distance < currentDistance then
                    currentDistance = distance
                    nearestObject = object
                end
            end
        end
        if nearestObject then
            local objX, objY, objZ = ObjectPosition(nearestObject)
            if currentDistance > 1 then
                local path = Tinkr.Util.Fly:GetFlightRoute(playerX, playerY, playerZ, objX, objY, objZ)
                if path then
                    for index, waypoint in ipairs(path) do
                        if (index - 1 >= 1) then
                            draw:Line(waypoint.x, waypoint.y, waypoint.z, path[index - 1].x, path[index - 1].y, path[index - 1].z)
                        end
                    end
                end
            end
        end
    end)
    Draw:Enable()
end)

Command:Register({ 'test' }, function()
    local x2, y2, z2 = -4172.6518554688, 297.49304199219, 124.34543609619
    local playerX, playerY, playerZ = ObjectPosition('player')

    Draw:Sync(function(draw)
        runPathObj = Movement.RunPath:New(runPathObj, playerX, playerY, playerZ, x2, y2, z2)
        local type = runPathObj:Start()
        if type == Movement.RunPath.Type.REACHED then
            print("reached")
        end

        Detour:DebugPath(runPathObj.path)
        draw:SetColor(draw.colors.green)
        draw:Circle(runPathObj.path[runPathObj.nextWpIndex].x, runPathObj.path[runPathObj.nextWpIndex].y, runPathObj.path[runPathObj.nextWpIndex].z, 0.5)
        draw:Text(runPathObj.path, "SourceCodePro", runPathObj.path[runPathObj.nextWpIndex].x, runPathObj.path[runPathObj.nextWpIndex].y, runPathObj.path[runPathObj.nextWpIndex].z + 1)
    end)
    Draw:Enable()

    --end
    --local x2, y2, z2 = -4172.6518554688, 297.49304199219, 124.34543609619
    --local playerX, playerY, playerZ = ObjectPosition('player')
    --local path, type = Navigation.GeneratePath(playerX, playerY, playerZ, x2, y2, z2)
    --local debugState = 0
    --Detour:DebugPath(path)
    --print(type)
    --local nextWpIndex = 1
    ----if pathType == Tinkr.Util.Detour.PathType.PATHFIND_NORMAL then
    --if table.getn(path) > 0 then
    --    Draw:Sync(function(draw)
    --        --for index, waypoint in ipairs(path) do
    --        --    draw:SetColor(draw.colors.green)
    --        --    draw:Circle(waypoint.x, waypoint.y, waypoint.z, 0.5)
    --        --    draw:Text(index, "SourceCodePro", waypoint.x, waypoint.y, waypoint.z + 1)
    --        --end
    --        draw:SetColor(draw.colors.green)
    --        draw:Circle(path[nextWpIndex].x, path[nextWpIndex].y, path[nextWpIndex].z, 0.5)
    --        draw:Text(nextWpIndex, "SourceCodePro", path[nextWpIndex].x, path[nextWpIndex].y, path[nextWpIndex].z + 1)
    --        ---
    --        --- COPY PASTE START
    --        ---
    --        local playerX, playerY, playerZ = ObjectPosition('player')
    --        local distance = Common.Distance(playerX, playerY, playerZ, path[nextWpIndex].x, path[nextWpIndex].y, path[nextWpIndex].z)
    --
    --        if distance < 1 then
    --            MoveForwardStop()
    --            nextWpIndex = nextWpIndex + 1
    --
    --            if nextWpIndex > table.getn(path) then
    --                -- Start from first waypoint again.
    --                nextWpIndex = 1
    --            end
    --            MoveTo(path[nextWpIndex].x, path[nextWpIndex].y, path[nextWpIndex].z)
    --            return
    --        end
    --        --if distance < 3 then
    --        --    MoveForwardStart()
    --        --    return
    --        --end
    --
    --        if not tinkrFns.moving() then
    --            utils.runDebounced(function()
    --                MoveTo(path[nextWpIndex].x, path[nextWpIndex].y, path[nextWpIndex].z)
    --            end, 1000)
    --        end
    --        ---
    --        --- COPY PASTE END
    --        ---
    --
    --    end)
    --    Draw:Enable()
    --end
    ----end
end)

Utils.log('Ready.')
Utils.log("Write " .. Utils.yellow("/bb legacy") .. " to open the legacy window.")
