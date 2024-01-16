local NAME = ...
local Netherwing = { }

local Tinkr = ...
local Draw = Tinkr.Util.Draw:New()
local Utils = Tinkr:require("scripts.big-brownie.modules.utils")
local JSON = Tinkr.Util.JSON
local Detour = Tinkr.Util.Detour
local AceGUI = Tinkr.Util.AceGUI
local ConfigHandling = Tinkr:require("scripts.big-brownie.modules.config_handling")
local Movement = Tinkr:require("scripts.big-brownie.modules.movement")
local Navigation = Tinkr:require("scripts.big-brownie.modules.navigation")
local tinkrFns = Tinkr:require('Routine.Modules.Exports')
local Positioning = Tinkr:require("scripts.big-brownie.modules.positioning")
local ObjectManager = Tinkr.Util.ObjectManager
local Common = Tinkr.Common
------------------------------------------------------------------------------------------
--- Store
------------------------------------------------------------------------------------------
local SCRIPT_NAME = "netherwing_eggfarm"
BB.scripts[SCRIPT_NAME] = {
    config = {
    },
    waypoints = {
    },
    drawDistance = 50,
    selectedRoute = nil,
    firstRun = true,
    nextWpIndex = 1,
    antiStuckData = {
        lastPosGameTick = 0,
        lastPos = {
            x = 0,
            y = 0,
            z = 0
        }
    }

}
local STORE = BB.scripts[SCRIPT_NAME]
ConfigHandling.loadConfig(SCRIPT_NAME)

------------------------------------------------------------------------------------------
--- Private functions
------------------------------------------------------------------------------------------

function toggleStartStop(startStopButton)
    if Draw.enabled then
        startStopButton:SetText('Start')
        stopBot()
        Utils.log('Stopped')
    else
        startStopButton:SetText('Stop')

        local waypoints = JSON:Decode(ReadFile('scripts/big-brownie/routes/' .. STORE.selectedRoute))
        STORE.waypoints = waypoints
        startBot()
        Utils.log('Started')
    end
end

------------------------------------------------------------------------------------------
--- Finds the closest waypoint.
------------------------------------------------------------------------------------------
function getClosestWaypointIndex()
    local playerX, playerY, playerZ = ObjectPosition('player')

    local closesDistance, closestWaypointIndex
    for i, waypoint in ipairs(STORE.waypoints) do
        local distance = FastDistance(playerX, playerY, playerZ, waypoint.x, waypoint.y, waypoint.z)
        if closesDistance == nil or distance < closesDistance then
            closesDistance = distance
            closestWaypointIndex = i
        end
    end
    return closestWaypointIndex
end

------------------------------------------------------------------------------------------
--- Finds and sets the closest waypoint.
------------------------------------------------------------------------------------------
function setClosestWaypointIndex()
    local closestWaypointIndex = getClosestWaypointIndex()
    if closestWaypointIndex ~= nil then
        STORE.nextWpIndex = closestWaypointIndex
    end
end

---
--- Resets values to start the bot.
---
function startBot()
    STORE.firstRun = true
    Draw:Enable()
end

---
--- Stops the bot.
---
function stopBot()
    Draw:Disable()
end

-- -- TODO Remove, this is for manual mfarm :()
Draw:Sync(function(draw)
    local px, py, pz = ObjectPosition("player")

    -- draw the cursor position in world
    local mx, my, mz = Common.ScreenToWorld(GetCursorPosition())
    draw:SetColor(draw.colors.white)
    draw:Circle(mx, my, mz, 0.5)

    local playerHeight = ObjectHeight("player")
    local playerRadius = ObjectBoundingRadius("player")
    local combatReach = ObjectCombatReach("player")

    draw:SetColor(draw.colors.white)
    draw:Circle(px, py, pz, playerRadius)
    draw:Circle(px, py, pz, combatReach)

    local rotation = ObjectRotation("player")
    local rx, ry, rz = RotateVector(px, py, pz, rotation, playerRadius)
    draw:Line(px, py, pz, rx, ry, rz)

    for object in ObjectManager:Objects() do
        if ObjectName(object) == 'Netherwing Egg' then
            -- local name = ObjectType(object) == 7 and GetSpellInfo(ObjectId(object)) or ObjectName(object)
            -- local name = ObjectAddress(object)
            local name = ObjectType(object)
            -- local name = ObjectSkinnable(object) and "skin me" or "Nope"
            local height = ObjectHeight(object) or 1
            local x, y, z = ObjectPosition(object)
            if x and y and z then
                local distance = Common.Distance(px, py, pz, x, y, z)
                if distance < 100 then
                    draw:SetColorFromObject(object)
                    local angleBetween = Common.GetAnglesBetweenPositions(px, py, pz, x, y, z)
                    local sx, sy, sz = Common.GetPositionFromPosition(px, py, pz, playerRadius, angleBetween, 0)
                    draw:Line(sx, sy, sz, x, y, z)
                    draw:Text((name or "Obj") .. " (" .. Common.Round(distance, 1) .. ")", "SourceCodePro", x, y, z + height)
                end
            end
        end
    end
end)
Draw:Enable()

---
--- Bot loop logic.
---
--local antiStuck = Movement.AntiStuck:New()
--local logState = Utils.LogState:New()
--Draw:Sync(function(draw)
--    local playerX, playerY, playerZ = ObjectPosition('player')
--    draw:Circle(playerX, playerY, playerZ, 0.5)
--
--    for index, waypoint in ipairs(STORE.waypoints) do
--        if math.abs(math.abs(waypoint.x) - math.abs(playerX)) < STORE.drawDistance and
--                math.abs(math.abs(waypoint.y) - math.abs(playerY)) < STORE.drawDistance and
--                math.abs(math.abs(waypoint.z) - math.abs(playerZ)) < STORE.drawDistance then
--            draw:SetColor(draw.colors.green)
--            draw:Circle(waypoint.x, waypoint.y, waypoint.z, 0.5)
--            draw:Text(index, "SourceCodePro", waypoint.x, waypoint.y, waypoint.z + 1)
--
--            if (index - 1 >= 1) then
--                draw:Line(waypoint.x, waypoint.y, waypoint.z, STORE.waypoints[index - 1].x, STORE.waypoints[index - 1].y, STORE.waypoints[index - 1].z)
--            end
--        end
--    end
--
--    if tinkrFns.casting() then
--        return
--    end
--
--    for index, waypoint in ipairs(STORE.waypoints) do
--        if math.abs(math.abs(waypoint.x) - math.abs(playerX)) < STORE.drawDistance and
--                math.abs(math.abs(waypoint.y) - math.abs(playerY)) < STORE.drawDistance and
--                math.abs(math.abs(waypoint.z) - math.abs(playerZ)) < STORE.drawDistance then
--            draw:SetColor(draw.colors.green)
--            draw:Circle(waypoint.x, waypoint.y, waypoint.z, 0.5)
--
--            if (index - 1 >= 1) then
--                draw:Line(waypoint.x, waypoint.y, waypoint.z, STORE.waypoints[index - 1].x, STORE.waypoints[index - 1].y, STORE.waypoints[index - 1].z)
--            end
--        end
--    end
--
--    local currentDistance = nil
--    local nearestObject = nil
--    for object in ObjectManager:Objects() do
--        if ObjectName(object) == 'Netherwing Egg' then
--            local x, y, z = ObjectPosition(object)
--            local distance = Common.Distance(playerX, playerY, playerZ, x, y, z)
--
--            if not currentDistance or distance < currentDistance then
--                currentDistance = distance
--                nearestObject = object
--            end
--        end
--    end
--    if nearestObject then
--        logState:Log('obj_finding', 0, 'Object found')
--        local objX, objY, objZ = ObjectPosition(nearestObject)
--        draw:SetColor(draw.colors.blue)
--        draw:Line(playerX, playerY, playerZ, objX, objY, objZ)
--        if currentDistance > 1 then
--            logState:Log('obj_finding', 1, 'Trying to moving to object')
--            runPathObj = Movement.RunPath:New(runPathObj, playerX, playerY, playerZ, objX, objY, objZ)
--            runPathObj:Start()
--
--            if runPathObj.type ~= Movement.RunPath.Type.NO_PATH then
--                logState:Log('obj_finding', 2, 'Moving to object')
--                for index, waypoint in ipairs(runPathObj.path) do
--                    if (index - 1 >= 1) then
--                        draw:Line(waypoint.x, waypoint.y, waypoint.z, runPathObj.path[index - 1].x, runPathObj.path[index - 1].y, runPathObj.path[index - 1].z)
--                    end
--                end
--                return
--            else
--                logState:Log('obj_finding', 3, 'Path cannot be found')
--                -- Do not return, let the route continue until path can be found.
--            end
--        else
--            logState:Log('obj_finding', 4, 'Interacting with object')
--            MoveForwardStop()
--            ObjectInteract(nearestObject)
--            return
--        end
--    end
--
--    logState:Log('going_route', 0, 'Running the route...')
--
--    if not IsMounted() and Utils.canMount() then
--        MoveForwardStop()
--
--        -- TODO: Make a config var
--        return tinkrFns:cast('Azure Cloud Serpent')
--    end
--
--    if STORE.firstRun then
--        setClosestWaypointIndex()
--        MoveTo(STORE.waypoints[STORE.nextWpIndex].x, STORE.waypoints[STORE.nextWpIndex].y, STORE.waypoints[STORE.nextWpIndex].z)
--    end
--
--    local reached = antiStuckMoveTo(playerX, playerY, playerZ, STORE.waypoints[STORE.nextWpIndex].x, STORE.waypoints[STORE.nextWpIndex].y, STORE.waypoints[STORE.nextWpIndex].z)
--    if reached == true then
--        MoveForwardStop()
--        STORE.nextWpIndex = STORE.nextWpIndex + 1
--
--        if STORE.nextWpIndex > table.getn(STORE.waypoints) then
--            -- Start from first waypoint again.
--            STORE.nextWpIndex = 1
--        end
--        MoveTo(STORE.waypoints[STORE.nextWpIndex].x, STORE.waypoints[STORE.nextWpIndex].y, STORE.waypoints[STORE.nextWpIndex].z)
--        --elseif distance < 3 then
--        --    MoveForwardStart()
--        --    return
--    end
--
--    --local distance = Common.Distance(playerX, playerY, playerZ, STORE.waypoints[STORE.nextWpIndex].x, STORE.waypoints[STORE.nextWpIndex].y, STORE.waypoints[STORE.nextWpIndex].z)
--    --if distance < 2 then
--    --    MoveForwardStop()
--    --    STORE.nextWpIndex = STORE.nextWpIndex + 1
--    --
--    --    if STORE.nextWpIndex > table.getn(STORE.waypoints) then
--    --        -- Start from first waypoint again.
--    --        STORE.nextWpIndex = 1
--    --    end
--    --    MoveTo(STORE.waypoints[STORE.nextWpIndex].x, STORE.waypoints[STORE.nextWpIndex].y, STORE.waypoints[STORE.nextWpIndex].z)
--    --    --elseif distance < 3 then
--    --    --    MoveForwardStart()
--    --    --    return
--    --end
--
--    --if not tinkrFns.moving() then
--    --    Utils.runDebounced(function()
--    --        MoveTo(STORE.waypoints[STORE.nextWpIndex].x, STORE.waypoints[STORE.nextWpIndex].y, STORE.waypoints[STORE.nextWpIndex].z)
--    --    end, 1000)
--    --end
--
--    ---- Anti Stuck
--    --if GetGameTick() - STORE.antiStuckData.lastPosGameTick > 1000 then
--    --    local pX, pY, pZ = ObjectPosition('player')
--    --    if antiStuck.IsWaitForFinished() == false and Common.Distance(pX, pY, pZ, STORE.antiStuckData.lastPos.x, STORE.antiStuckData.lastPos.y, STORE.antiStuckData.lastPos.z) < 1 then
--    --        antiStuck = Movement.AntiStuck:New()
--    --        antiStuck:Perform(pX, pY, pZ, STORE.antiStuckData.lastPos.x, STORE.antiStuckData.lastPos.y, STORE.antiStuckData.lastPos.z)
--    --    else
--    --        antiStuck:Stop()
--    --    end
--    --    STORE.antiStuckData.lastPos.x, STORE.antiStuckData.lastPos.y, STORE.antiStuckData.lastPos.z = ObjectPosition('player')
--    --    STORE.antiStuckData.lastPosGameTick = GetGameTick()
--    --end
--
--    STORE.firstRun = false
--end)
--

---
---
--- Returns true if position has been reached, nil otherwise.
local antiStuckMoveToRunDebounced = Utils.Debounced:New()
function antiStuckMoveTo(pX, pY, pZ, toX, toY, toZ)
    local distance = Common.Distance(pX, pY, pZ, toX, toY, toZ)
    if distance < 2 then
        return true
    end

    if not tinkrFns.moving() then
        antiStuckMoveToRunDebounced:Run(function()
            MoveTo(toX, toY, toZ)
        end, 1000)
    end

    -- Anti Stuck
    if GetGameTick() - STORE.antiStuckData.lastPosGameTick > 1000 then
        if antiStuck:IsWaitForFinished() == false and Common.Distance(pX, pY, pZ, STORE.antiStuckData.lastPos.x, STORE.antiStuckData.lastPos.y, STORE.antiStuckData.lastPos.z) < 1 then
            antiStuck:Perform(pX, pY, pZ, STORE.antiStuckData.lastPos.x, STORE.antiStuckData.lastPos.y, STORE.antiStuckData.lastPos.z)
        else
            antiStuck:Stop()
        end
        STORE.antiStuckData.lastPos.x, STORE.antiStuckData.lastPos.y, STORE.antiStuckData.lastPos.z = ObjectPosition('player')
        STORE.antiStuckData.lastPosGameTick = GetGameTick()
    end
end

------------------------------------------------------------------------------------------
--- Public functions
------------------------------------------------------------------------------------------

---
--- Show GUI
---
function Netherwing.showGUI()

    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Netherwing egg farm")
    frame:EnableResize(false)
    frame:SetWidth(300)
    frame:SetHeight(300)
    frame:SetLayout("List")
    frame:SetCallback("OnClose", function(widget)
    end)

    -- Load route
    local files = ListFiles('scripts/big-brownie/routes')
    local fileNames = {}
    for _, file in ipairs(files) do
        table.insert(fileNames, file)
    end
    local routesDropdown = AceGUI:Create("Dropdown")
    routesDropdown:SetFullWidth(true)
    routesDropdown:SetLabel("Load route")
    routesDropdown:SetList(fileNames)
    routesDropdown:SetCallback("OnValueChanged", function(_, _, selectedIndex)
        STORE.selectedRoute = fileNames[selectedIndex]
    end)

    -- Start/Stop button
    local startStopButton = AceGUI:Create("Button")
    startStopButton:SetText('Start')
    startStopButton:SetFullWidth(true)
    startStopButton:SetCallback("OnClick", function(widget, event, text)
        toggleStartStop(startStopButton)
    end)

    ---
    --- Compose groups
    ---
    frame:AddChild(routesDropdown)
    frame:AddChild(startStopButton)
end

return Netherwing