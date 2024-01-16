local NAME = ...
local CreateRoute = { }

local Tinkr = ...
local JSON = Tinkr.Util.JSON
local Draw = Tinkr.Util.Draw:New()
local json = Tinkr:require("scripts.big-brownie.modules.json")
local Utils = Tinkr:require("scripts.big-brownie.modules.utils")
local AceGUI = Tinkr.Util.AceGUI
local ConfigHandling = Tinkr:require("scripts.big-brownie.modules.config_handling")

------------------------------------------------------------------------------------------
--- GUI References
------------------------------------------------------------------------------------------
local routineNameEditBox
local replaceIndexEditBox
local frame

------------------------------------------------------------------------------------------
--- Store
------------------------------------------------------------------------------------------
local SCRIPT_NAME = "create_route"
BB.scripts[SCRIPT_NAME] = {
    config = {
        lastUsedRoute = ""
    },
    routineName = "",
    waypoints = {
    },
    drawDistance = 200
}
local STORE = BB.scripts[SCRIPT_NAME]
ConfigHandling.loadConfig(SCRIPT_NAME)

------------------------------------------------------------------------------------------
--- Private functions
------------------------------------------------------------------------------------------

---
--- Loads the route to store and showing its waypoints.
---
function loadRoute(fileName)
    local CONFIG_FILE_PATH = "scripts/big-brownie/routes/" .. fileName
    local waypointsJsonStr = ReadFile(CONFIG_FILE_PATH)

    local waypoints = false
    if waypointsJsonStr then
        waypoints = JSON:Decode(waypointsJsonStr)
    end

    if waypoints ~= false and type(waypoints) == "table" then
        STORE.waypoints = waypoints

        local routineName = fileName:match("(.+)%..+$")
        if routineName == nil then
            routineName = fileName
        end
        STORE.routineName = routineName
        routineNameEditBox:SetText(STORE.routineName)
        Draw:Enable()
    else
        utils.logerror("Could not read waypoints file.")
        return
    end

end

---
--- Adds a waypoint of the current player position to the store.
---
function addWaypoint()
    local x1, y1, z1 = ObjectPosition('player')
    local waypoint = {
        x = x1,
        y = y1,
        z = z1
    }

    table.insert(STORE.waypoints, waypoint)

end

---
--- Replaces the waypoint with the passed index with the current player position.
---
function replaceWaypointWithCurrentPosition(index)
    local x1, y1, z1 = ObjectPosition('player')
    local waypoint = {
        x = x1,
        y = y1,
        z = z1
    }

    STORE.waypoints[index] = waypoint
end

---
--- Removes the last waypoint from the store.
---
function removeLastWaypoint()
    local length = 0
    for _, _ in ipairs(STORE.waypoints) do
        length = length + 1
    end

    table.remove(STORE.waypoints, length)

end

---
--- Handles the save interaction of the user.
---
function onSave()
    if FileExists('scripts/big-brownie/routes/' .. routineNameEditBox:GetText() .. '.json') then
        frame:Hide()

        local confirmDialog = AceGUI:Create("Window")
        confirmDialog:SetTitle("Create Route")
        confirmDialog:EnableResize(false)
        confirmDialog:SetWidth(300)
        confirmDialog:SetHeight(300)
        confirmDialog:SetLayout("List")

        local text = AceGUI:Create("Label")
        text:SetText('There already exists a route with that name. Do you want to overwrite it?')

        local overwriteButton = AceGUI:Create("Button")
        overwriteButton:SetText('Overwrite')
        overwriteButton:SetCallback("OnClick", function(widget, event, text)
            saveRoute()
            AceGUI:Release(confirmDialog)
            frame:Show()
        end)

        local cancelButton = AceGUI:Create("Button")
        cancelButton:SetText('Cancel')
        cancelButton:SetCallback("OnClick", function(widget, event, text)
            AceGUI:Release(confirmDialog)
            frame:Show()
        end)
        confirmDialog:AddChild(text)
        confirmDialog:AddChild(overwriteButton)
        confirmDialog:AddChild(cancelButton)
        AceGUI:SetFocus(confirmDialog)
    else
        saveRoute()
    end
end

---
--- Saves the route in the store to a file.
---
function saveRoute()
    local json_str = json.encode(STORE.waypoints)
    local success = WriteFile('scripts/big-brownie/routes/' .. routineNameEditBox:GetText() .. '.json', json_str, false)
    if (success == true) then
        Utils.log("Waypoints successfully saved.")
    else
        Utils.logerror("Waypoints could not be saved.")
    end
end

---
--- Draws the waypoints currently in the store to the world.
---
Draw:Sync(function(draw)
    local playerX, playerY, playerZ = ObjectPosition('player')
    draw:Circle(playerX, playerY, playerZ, 0.5)

    for index, waypoint in ipairs(STORE.waypoints) do
        if math.abs(math.abs(waypoint.x) - math.abs(playerX)) < STORE.drawDistance and
                math.abs(math.abs(waypoint.y) - math.abs(playerY)) < STORE.drawDistance and
                math.abs(math.abs(waypoint.z) - math.abs(playerZ)) < STORE.drawDistance then
            draw:SetColor(draw.colors.green)
            draw:Circle(waypoint.x, waypoint.y, waypoint.z, 0.5)
            draw:Text(index, "SourceCodePro", waypoint.x, waypoint.y, waypoint.z + 1)

            if (index - 1 >= 1) then
                draw:Line(waypoint.x, waypoint.y, waypoint.z, STORE.waypoints[index - 1].x, STORE.waypoints[index - 1].y, STORE.waypoints[index - 1].z)
            end
        end
    end
end)

------------------------------------------------------------------------------------------
--- Public functions
------------------------------------------------------------------------------------------

---
--- Show GUI
---
function CreateRoute.showGUI()

    frame = AceGUI:Create("Frame")
    frame:SetTitle("Create Route")
    frame:EnableResize(false)
    frame:SetWidth(300)
    frame:SetHeight(300)
    frame:SetLayout("List")
    frame:SetCallback("OnClose", function(widget)
        Draw:Disable()
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
        loadRoute(fileNames[selectedIndex])
    end)

    -- Add/Remove buttons
    local addButton = AceGUI:Create("Button")
    local removeButton = AceGUI:Create("Button")
    local saveButton = AceGUI:Create("Button")

    -- Add
    addButton:SetText('Add waypoint')
    addButton:SetFullWidth(true)
    addButton:SetCallback("OnClick", function(widget, event, text)
        addWaypoint()
    end)

    -- Remove
    removeButton:SetText('Remove last waypoint')
    removeButton:SetFullWidth(true)
    removeButton:SetCallback("OnClick", function(widget, event, text)
        removeLastWaypoint()
    end)

    ---
    --- Replace with index
    ---
    replaceIndexEditBox = AceGUI:Create("EditBox")
    replaceIndexEditBox:SetLabel("Replace with index")
    replaceIndexEditBox:SetFullWidth(true)
    replaceIndexEditBox:SetCallback("OnEnterPressed", function(widget, event, text)
        local index = tonumber(text)
        if index ~= nil then
            if index > table.getn(STORE.waypoints) then
                Utils.logerror('There is no waypoint with index "' .. text .. '". Waypoints for this route only go from "1" to "' .. table.getn(STORE.waypoints) .. '".')
                return
            end
            replaceWaypointWithCurrentPosition(index)
            replaceIndexEditBox:SetText("")
        else
            Utils.logerror('"' .. text .. '" is not a number. Replacing failed.')
        end
    end)

    ---
    --- Routine name
    ---
    routineNameEditBox = AceGUI:Create("EditBox")
    routineNameEditBox:SetLabel("Routine name")
    routineNameEditBox:SetText(STORE.routineName)
    routineNameEditBox:SetFullWidth(true)
    routineNameEditBox:SetCallback("OnEnterPressed", function(widget, event, text)
        ConfigHandling.saveConfig(SCRIPT_NAME, "routine", text)
    end)

    --- Save
    saveButton:SetText('Save')
    saveButton:SetFullWidth(true)
    saveButton:SetCallback("OnClick", function(widget, event, text)
        onSave()
    end)

    ---
    --- Compose groups
    ---
    frame:AddChild(routesDropdown)
    frame:AddChild(addButton)
    frame:AddChild(removeButton)
    frame:AddChild(replaceIndexEditBox)
    frame:AddChild(routineNameEditBox)
    frame:AddChild(saveButton)
end

return CreateRoute