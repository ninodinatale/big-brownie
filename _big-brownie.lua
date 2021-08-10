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

    -- Default config
    config = {
      food = "",
      routine = "",
      eatingAtHp = 60
    },

    -- available modes ("scripts")
    scripts = {
        bg = {
            draw = nil
        }
    }
}

local Tinkr = ...
local Command = Tinkr.Util.Commands:New('bb')
local utils = Tinkr:require("scripts.big-brownie.modules.utils")
local AceGUI = Tinkr.Util.AceGUI
local JSON = Tinkr.Util.JSON

local configStr = ReadFile("scripts/big-brownie/config.json")

if configStr == false then
    WriteFile("scripts/big-brownie/config.json", JSON:Encode(BB.config), false)
end

local config = JSON:Decode(configStr)

print(config)

if config ~= false and type(config) == "table" then
    BB.config = config
else
    utils.logerror("Could not read config file. Delete the config.json if it's malformed.")
    return
end

Command:Register({ 'gui' }, function()
    showGUI()
end)

function saveConfig(field, value)
    print(field)
    print(value)
    BB.config[field] = value
    local json_str = JSON:Encode(BB.config)
    WriteFile("scripts/big-brownie/config.json", json_str, false)
end

function showGUI()

    local frame = AceGUI:Create("Window")
    frame:SetTitle("Big-Brownie")
    frame:EnableResize(false)
    frame:SetWidth(300)
    frame:SetHeight(300)
    frame:SetLayout("List")
    frame:SetCallback("OnClose", function(widget)
    end)


    ---
    --- Routine name
    ---
    -- Edit box
    local routineName = AceGUI:Create("EditBox")
    routineName:SetLabel("Routine name")
    routineName:SetText(BB.config.routine)
    routineName:SetFullWidth(true)
    routineName:SetCallback("OnEnterPressed", function(widget, event, text)
        saveConfig("routine", text)
    end)

    ---
    --- Food name
    ---
    local foodName = AceGUI:Create("EditBox")
    foodName:SetLabel("Food name")
    foodName:SetText(BB.config.food)
    foodName:SetFullWidth(true)
    foodName:SetCallback("OnEnterPressed", function(widget, event, text)
        saveConfig("food", text)
    end)

    ---
    --- Eating at % HP
    ---
    local eatingAtHpSlider = AceGUI:Create("Slider")
    eatingAtHpSlider:SetLabel("Eating at % HP")
    eatingAtHpSlider:SetValue(BB.config.eatingAtHp)
    eatingAtHpSlider:SetSliderValues(1, 100, 1)
    eatingAtHpSlider:SetFullWidth(true)
    eatingAtHpSlider:SetCallback("OnMouseUp", function(widget, event, value)
        saveConfig("eatingAtHp", value)
    end)

    ---
    --- Start/Stop buttons
    ---
    local startButton = AceGUI:Create("Button")
    local stopButton = AceGUI:Create("Button")

    --- start
    startButton:SetText('Start')
    startButton:SetDisabled(BB.scripts.bg.draw.enabled)
    startButton:SetFullWidth(true)
    startButton:SetCallback("OnClick", function(widget, event, text)
        local routineExists = false
        for key, value in pairs(Tinkr.Routine.routines) do
            if key == BB.config.routine then
                routineExists = true
                break
            end
        end

        if not routineExists then
            utils.logerror("Provided routine " .. utils.yellow(BB.config.routine) .. " does not exist.")
            return
        end



        Tinkr.Routine:LoadRoutine(BB.config.routine)
        if not BB.scripts.bg.draw.enabled then
            BB.scripts.bg.draw:Enable()
            startButton:SetDisabled(true)
            stopButton:SetDisabled(false)
            utils.log("Started.")
        end
    end)

    --- stop
    stopButton:SetText('Stop')
    stopButton:SetDisabled(not BB.scripts.bg.draw.enabled)
    stopButton:SetFullWidth(true)
    stopButton:SetCallback("OnClick", function(widget, event, text)
        Tinkr.Routine:Disable()
        MoveForwardStop()
        TurnLeftStop()
        TurnRightStop()
        if BB.scripts.bg.draw.enabled then
            BB.scripts.bg.draw:Disable()
            startButton:SetDisabled(false)
            stopButton:SetDisabled(true)
            utils.log("Stopped.")
        end
    end)

    ---
    --- Compose groups
    ---
    frame:AddChild(routineName)
    frame:AddChild(foodName)
    frame:AddChild(eatingAtHpSlider)
    frame:AddChild(startButton)
    frame:AddChild(stopButton)
end

utils.log('Ready.')
utils.log("Write " .. utils.yellow("/bb gui") .. " to open the config window.")
