--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 12/01/2021

---@class RoyalSettings
RoyalSettings = {}
RoyalSettings.revision = 1
RoyalSettings.loadingModName = g_currentModName
RoyalSettings.userProfileDirectory = getUserProfileAppPath()
RoyalSettings.name = g_currentModName
RoyalSettings.xmlRootNode = "royalSettings"
RoyalSettings.TYPES = {}
RoyalSettings.TYPES.GLOBAL = 1
RoyalSettings.TYPES.SAVEGAME = 2
RoyalSettings.OWNERS = {}
RoyalSettings.OWNERS.ALL = 1
RoyalSettings.OWNERS.USER = 2

function RoyalSettings:initialize()
    g_royalSettings = self
    self.registrationEnabled = true

    self.settingsClass = {}
    self.settingsClass[self.TYPES.GLOBAL] = {}
    self.settingsClass[self.TYPES.GLOBAL][self.OWNERS.ALL] = nil
    self.settingsClass[self.TYPES.GLOBAL][self.OWNERS.USER] = RoyalSettingGlobal

    self.mods = {}

    self.settings = {}

    Utility.prependedFunction(Mission00, "loadMission00Finished", self.onLoadSavegame)
    Utility.appendedFunction(FSBaseMission, "saveSavegame", self.onSaveSavegame)

    g_logManager:devInfo("Initializing r_title_r from " .. self.loadingModName)
end

function RoyalSettings:onLoadSavegame()
    self = g_royalSettings
    self.registrationEnabled = false
    local xmlIds = {}
    ---@type RoyalSetting
    for _, setting in pairs(self.settings) do
        local xmlPath = Utils.getFilename(setting:getSavegameFilePath(), self.userProfileDirectory)
        if fileExists(xmlPath) then
            if xmlIds[xmlPath] == nil then
                xmlIds[xmlPath] = loadXMLFile("royalSettingsSave" .. xmlPath, xmlPath)
            end
            setting:loadFromXMLFile(xmlIds[xmlPath], self.xmlRootNode)
        end
    end
    for _, xml in pairs(xmlIds) do
        delete(xml)
    end
end

function RoyalSettings:onSaveSavegame()
    self = g_royalSettings
    local xmlIds = {}
    ---@type RoyalSetting
    for _, setting in pairs(self.settings) do
        local xmlPath = Utils.getFilename(setting:getSavegameFilePath(), self.userProfileDirectory)
        if xmlIds[xmlPath] == nil then
            xmlIds[xmlPath] = createXMLFile("royalSettingsSave" .. xmlPath, xmlPath, self.xmlRootNode)
            setXMLInt(xmlIds[xmlPath], self.xmlRootNode .. "#revision", self.revision)
        end
        setting:saveToXMLFile(xmlIds[xmlPath], self.xmlRootNode)
    end
    for _, xml in pairs(xmlIds) do
        saveXMLFile(xml)
        delete(xml)
    end
end

function RoyalSettings:registerMod(modName, icon, description)
    if self.registrationEnabled then
        if self.mods[modName] == nil then
            self.mods[modName] = {modName, icon, description}
        else
            g_logManager:devError("[r_title_r] Tab for '%s' is already registered", modName)
        end
    else
        g_logManager:devError("[r_title_r] Mods / tabs registration isn't allowd at this time")
    end
end

function RoyalSettings:registerSetting(modName, settingName, settingType, settingOwner, defaultIndex, values, texts, tooltip)
    if self.registrationEnabled then
        if self.mods[modName] ~= nil then
            local sclass = self.settingsClass[settingType][settingOwner]
            if sclass ~= nil then
                local newSetting = sclass:new()
                local key = string.format("%s.%s", modName, settingName)
                if self.settings[key] == nil then
                    if newSetting:initialize(key, modName, settingName, defaultIndex, values, texts, tooltip) then
                        self.settings[key] = newSetting
                        DebugUtil.printTableRecursively(newSetting.options)
                        return key
                    end
                else
                    g_logManager:devError("[r_title_r] Setting with key '%s' is already registered", key)
                end
            else
                g_logManager:devError("[r_title_r] Can't find a proper setting class for (%d, %d) type / owner combination", settingType, settingOwner)
            end
        else
            g_logManager:devError("[r_title_r] Tab for '%s' isn't still registered", modName)
        end
    else
        g_logManager:devError("[r_title_r] Settings registration isn't allowd at this time")
    end
end

--#region bootstrap
local game = getfenv(0)
if game.g_royalSettings == nil then
    game.g_royalSettings = {}
    game.g_royalSettings.instances = {}
    game.g_royalSettings.bootstrap = function()
        local hRevision = -1
        local object = nil
        for _, rs in ipairs(game.g_royalSettings.instances) do
            if rs ~= nil and rs.obj ~= nil and rs.obj.initialize ~= nil and rs.rev > hRevision then
                hRevision = rs.rev
                object = rs.obj
            end
        end
        game.g_royalSettings = object
        game.g_royalSettings:initialize()
    end
    Utility.prependedFunction(VehicleTypeManager, "validateVehicleTypes", game.g_royalSettings.bootstrap)
end
table.insert(game.g_royalSettings.instances, {obj = RoyalSettings, rev = RoyalSettings.revision})
--#endregion
