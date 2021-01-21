--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 11/01/2021

InitRoyalMod(Utils.getFilename("rmod/", g_currentModDirectory))
InitRoyalUtility(Utils.getFilename("utility/", g_currentModDirectory))
InitRoyalSettings(Utils.getFilename("rset/", g_currentModDirectory))

---@class PogressiveSteering : RoyalMod
ProgressiveSteering = RoyalMod.new(r_debug_r, false)
ProgressiveSteering.curves = {}
ProgressiveSteering.curveType = 6
ProgressiveSteering.enabled = true

function ProgressiveSteering:initialize()
    addConsoleCommand("psSetCurve", "", "setCurveType", self)

    ProgressiveSteering.curves[1] = AnimCurve:new(linearInterpolator1)
    ProgressiveSteering.curves[2] = AnimCurve:new(linearInterpolator1)
    ProgressiveSteering.curves[3] = AnimCurve:new(linearInterpolator1)
    ProgressiveSteering.curves[4] = AnimCurve:new(linearInterpolator1)
    ProgressiveSteering.curves[5] = AnimCurve:new(InterpolatorUtility.exponential11Interpolator1)
    ProgressiveSteering.curves[6] = AnimCurve:new(InterpolatorUtility.catmullRomInterpolator1, 3)

    self.curves[1]:addKeyframe({0, time = 0})
    self.curves[1]:addKeyframe({0.1, time = 0.3})
    self.curves[1]:addKeyframe({0.9, time = 0.70})
    self.curves[1]:addKeyframe({1, time = 1})

    self.curves[2]:addKeyframe({0, time = 0})
    self.curves[2]:addKeyframe({0.125, time = 0.3})
    self.curves[2]:addKeyframe({0.875, time = 0.70})
    self.curves[2]:addKeyframe({1, time = 1})

    self.curves[3]:addKeyframe({0, time = 0})
    self.curves[3]:addKeyframe({0.15, time = 0.3})
    self.curves[3]:addKeyframe({0.85, time = 0.70})
    self.curves[3]:addKeyframe({1, time = 1})

    self.curves[4]:addKeyframe({0, time = 0})
    self.curves[4]:addKeyframe({0.15, time = 0.35})
    self.curves[4]:addKeyframe({0.85, time = 0.65})
    self.curves[4]:addKeyframe({1, time = 1})

    self.curves[5]:addKeyframe({0, time = 0})
    self.curves[5]:addKeyframe({1, time = 1})

    self.curves[6]:addKeyframe({0, time = 0})
    self.curves[6]:addKeyframe({0.2, time = 0.30})
    self.curves[6]:addKeyframe({0.8, time = 0.70})
    self.curves[6]:addKeyframe({1, time = 1})
end

function ProgressiveSteering:onValidateVehicleTypes(vehicleTypeManager, addSpecialization, addSpecializationBySpecialization, addSpecializationByVehicleType, addSpecializationByFunction)
end

function ProgressiveSteering:onMissionInitialize(baseDirectory, missionCollaborators)
end

function ProgressiveSteering:onSetMissionInfo(missionInfo, missionDynamicInfo)
end

function ProgressiveSteering:onLoad()
    g_royalSettings:registerMod(self.name, self.directory .. "settings_icon.dds", "$l10n_ps_test_text")
    g_royalSettings:registerSetting(self.name, "precision", g_royalSettings.TYPES.GLOBAL, g_royalSettings.OWNERS.USER, 6, {1, 2, 3, 4, 5, 6}, {"2", "3", "4", "5", "6", "7"}, "Precision", "tooltip 1"):addCallback(self.onCurveChange, self)
    g_royalSettings:registerSetting(self.name, "enabled", g_royalSettings.TYPES.GLOBAL, g_royalSettings.OWNERS.USER, 2, {false, true}, {"$l10n_ui_off", "$l10n_ui_on"}, "Enabled", "tooltip 2"):addCallback(self.onEnableDisable, self)
end

function ProgressiveSteering:onEnableDisable(value)
    self.enabled = value
end

function ProgressiveSteering:onCurveChange(value)
    self.curveType = value
end

function ProgressiveSteering:onPreLoadMap(mapFile)
end

function ProgressiveSteering:onCreateStartPoint(startPointNode)
end

function ProgressiveSteering:onLoadMap(mapNode, mapFile)
end

function ProgressiveSteering:onPostLoadMap(mapNode, mapFile)
end

function ProgressiveSteering:onLoadSavegame(savegameDirectory, savegameIndex)
end

function ProgressiveSteering:onPreLoadVehicles(xmlFile, resetVehicles)
end

function ProgressiveSteering:onPreLoadItems(xmlFile)
end

function ProgressiveSteering:onPreLoadOnCreateLoadedObjects(xmlFile)
end

function ProgressiveSteering:onLoadFinished()
end

function ProgressiveSteering:onStartMission()
end

function ProgressiveSteering:onMissionStarted()
end

function ProgressiveSteering:onWriteStream(streamId)
end

function ProgressiveSteering:onReadStream(streamId)
end

function ProgressiveSteering:onUpdate(dt)
end

function ProgressiveSteering:onUpdateTick(dt)
end

function ProgressiveSteering:onWriteUpdateStream(streamId, connection, dirtyMask)
end

function ProgressiveSteering:onReadUpdateStream(streamId, timestamp, connection)
end

function ProgressiveSteering:onMouseEvent(posX, posY, isDown, isUp, button)
end

function ProgressiveSteering:onKeyEvent(unicode, sym, modifier, isDown)
end

function ProgressiveSteering:onDraw()
    if self.enabled and self.debug then
        local scale = 1.5
        Utility.renderAnimCurve(0.5 - ((0.1125 * scale) / 2), 0.5 - ((0.2 * scale) / 2), 0.1125 * scale, 0.2 * scale, self.curves[self.curveType], 50)
    end
end

function ProgressiveSteering:onPreSaveSavegame(savegameDirectory, savegameIndex)
end

function ProgressiveSteering:onPostSaveSavegame(savegameDirectory, savegameIndex)
end

function ProgressiveSteering:onPreDeleteMap()
end

function ProgressiveSteering:onDeleteMap()
end

function ProgressiveSteering:setCurveType(type)
    --self.curveType = tonumber(type)
    --g_royalSettings:openGui()
end

function Drivable.actionEventSteer(self, actionName, inputValue, callbackState, isAnalog, isMouse, deviceCategory)
    local spec = self.spec_drivable

    spec.lastInputValues.axisSteer = inputValue
    if inputValue ~= 0 then
        spec.lastInputValues.axisSteerIsAnalog = isAnalog
        spec.lastInputValues.axisSteerDeviceCategory = deviceCategory
        if isAnalog then
            spec.lastInputValues.axisSteer = inputValue * ProgressiveSteering.curves[ProgressiveSteering.curveType]:get(math.abs(Utility.clamp(-1, inputValue, 1)))
        end
    end
end
