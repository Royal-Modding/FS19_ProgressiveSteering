--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 12/01/2021

--- Initialize RoyalSettings library
---@param libDirectory string
function InitRoyalSettings(libDirectory)
    source(Utils.getFilename("RoyalSettings.lua", libDirectory))
    source(Utils.getFilename("RoyalSetting.lua", libDirectory))
    source(Utils.getFilename("RoyalSettingGlobal.lua", libDirectory))
    g_logManager:devInfo("r_title_r loaded successfully by " .. g_currentModName)
    return true
end
