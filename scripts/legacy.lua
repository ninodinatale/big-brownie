local Legacy = { }
local Tinkr = ...
local NAME = ...

local utils = Tinkr:require("scripts.big-brownie.modules.utils")
local AceGUI = Tinkr.Util.AceGUI
local ConfigHandling = Tinkr:require("scripts.big-brownie.modules.config_handling")

local SCRIPT_NAME = "legacy"
BB.scripts[SCRIPT_NAME] = {

    -- Default config
    config = {
      food = "",
      routine = "",
      eatingAtHp = 60
    },

    -- available modes ("scripts")
    --scripts = {
    --    bg = {
    --        draw = nil
    --    }
    --}
}


ConfigHandling.loadConfig(SCRIPT_NAME)
--[[

------------------------------------------------------------------------------------------
--- Shows the config GUI and handles the configuration file according to the inputs.
------------------------------------------------------------------------------------------
function Legacy.showGUI()

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
    utils.printMemberOf(BB.scripts[SCRIPT_NAME], "scripts/big-brownie/temp.json")
    routineName:SetText(BB.scripts[SCRIPT_NAME].config.routine)
    routineName:SetFullWidth(true)
    routineName:SetCallback("OnEnterPressed", function(widget, event, text)
        ConfigHandling.saveConfig(SCRIPT_NAME, "routine", text)
    end)

    ---
    --- Food name
    ---
    local foodName = AceGUI:Create("EditBox")
    foodName:SetLabel("Food name")
    foodName:SetText(BB.scripts[SCRIPT_NAME].config.food)
    foodName:SetFullWidth(true)
    foodName:SetCallback("OnEnterPressed", function(widget, event, text)
        ConfigHandling.saveConfig(SCRIPT_NAME, "food", text)
    end)

    ---
    --- Eating at % HP
    ---
    local eatingAtHpSlider = AceGUI:Create("Slider")
    eatingAtHpSlider:SetLabel("Eating at % HP")
    eatingAtHpSlider:SetValue(BB.scripts[SCRIPT_NAME].config.eatingAtHp)
    eatingAtHpSlider:SetSliderValues(1, 100, 1)
    eatingAtHpSlider:SetFullWidth(true)
    eatingAtHpSlider:SetCallback("OnMouseUp", function(widget, event, value)
        ConfigHandling.saveConfig(SCRIPT_NAME, "eatingAtHp", value)
    end)

]]
--[[
    ---
    --- Start/Stop buttons
    ---
    local startButton = AceGUI:Create("Button")
    local stopButton = AceGUI:Create("Button")

    --- start
    startButton:SetText('Start')
    startButton:SetDisabled(BB.scripts[SCRIPT_NAME].scripts.bg.draw.enabled)
    startButton:SetFullWidth(true)
    startButton:SetCallback("OnClick", function(widget, event, text)
        local routineExists = false
        for key, value in pairs(Tinkr.Routine.routines) do
            if key == BB.scripts[SCRIPT_NAME].config.routine then
                routineExists = true
                break
            end
        end

        if not routineExists then
            utils.logerror("Provided routine " .. utils.yellow(BB.scripts[SCRIPT_NAME].config.routine) .. " does not exist.")
            return
        end



        Tinkr.Routine:LoadRoutine(BB.config.routine)
        if not BB.scripts[SCRIPT_NAME].scripts.bg.draw.enabled then
            BB.scripts[SCRIPT_NAME].scripts.bg.draw:Enable()
            startButton:SetDisabled(true)
            stopButton:SetDisabled(false)
            utils.log("Started.")
        end
    end)

    --- stop
    stopButton:SetText('Stop')
    stopButton:SetDisabled(not BB.scripts[SCRIPT_NAME].scripts.bg.draw.enabled)
    stopButton:SetFullWidth(true)
    stopButton:SetCallback("OnClick", function(widget, event, text)
        Tinkr.Routine:Disable()
        MoveForwardStop()
        TurnLeftStop()
        TurnRightStop()
        if BB.scripts[SCRIPT_NAME].scripts.bg.draw.enabled then
            BB.scripts[SCRIPT_NAME].scripts.bg.draw:Disable()
            startButton:SetDisabled(false)
            stopButton:SetDisabled(true)
            utils.log("Stopped.")
        end
    end)
]]--[[


    ---
    --- Compose groups
    ---
    frame:AddChild(routineName)
    frame:AddChild(foodName)
    frame:AddChild(eatingAtHpSlider)
--    frame:AddChild(startButton)
--    frame:AddChild(stopButton)
end
]]

return Legacy