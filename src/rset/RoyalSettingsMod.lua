--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 19/01/2021

---@class RoyalSettingsMod
RoyalSettingsMod = {}

---@param name string
---@param icon string
---@param description string
---@return RoyalSettingsMod
function RoyalSettingsMod.new(name, icon, description)
    ---@type RoyalSettingsMod
    local mod = {}
    ---@type string
    mod.name = name
    ---@type string
    mod.icon = icon
    ---@type string
    mod.description = StringUtility.parseI18NText(description)
    ---@type string
    mod.guiPageName = ""
    ---@type RoyalSetting[]
    mod.settings = {}
    ---@type RoyalSetting[]
    mod.orderedSettings = {}

    --- Add a new setting to mod
    ---@param self RoyalSettingsMod
    ---@param setting RoyalSetting
    mod.addSetting = function(self, setting)
        table.insert(self.orderedSettings, setting)
        self.settings[setting.key] = setting
    end
    return mod
end
