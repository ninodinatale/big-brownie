---
--- Utils
---
--- Utility functions.
---

local Tinkr = ...
local JSON = Tinkr.Util.JSON
local utils = Tinkr:require("scripts.big-brownie.modules.utils")
local NAME = ...

local ConfigHandling = { }

---
--- Loads or creates config for the passed `globalConfigName`.
---
function ConfigHandling.loadConfig(scriptName)
    local CONFIG_FILE_PATH = "scripts/big-brownie/script_configs/" .. scriptName .. ".json"
    local configStr = ReadFile(CONFIG_FILE_PATH)

    local config = false
    if configStr then
        config = JSON:Decode(configStr)
    end

    if config ~= false and type(config) == "table" then
        BB.scripts[scriptName].config = config
    else
        utils.logerror("Could not read config file. Delete the config.json if it's malformed.")
        return
    end
end





---
--- Saves the passed `value` to the `field` in the `config` object and writes it
--- as JSON string to the file.
---
function ConfigHandling.saveConfig(appName, field, value)
    BB.scripts[appName].config[field] = value
    local json_str = JSON:Encode(BB.scripts[appName].config)
    WriteFile("scripts/big-brownie/script_configs/" .. appName .. ".json", json_str, false)
end



return ConfigHandling
