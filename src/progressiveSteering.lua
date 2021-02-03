--- ${title}

---@author ${author}
---@version r_version_r
---@date 11/01/2021

InitRoyalMod(Utils.getFilename("rmod/", g_currentModDirectory))
InitRoyalUtility(Utils.getFilename("utility/", g_currentModDirectory))
InitRoyalSettings(Utils.getFilename("rset/", g_currentModDirectory))

---@class PogressiveSteering : RoyalMod
ProgressiveSteering = RoyalMod.new(r_debug_r, false)
ProgressiveSteering.curves = {}
ProgressiveSteering.curveType = 6
ProgressiveSteering.enabled = true

function ProgressiveSteering:initialize()
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

function ProgressiveSteering:onLoad()
    g_royalSettings:registerMod(self.name, self.directory .. "settings_icon.dds", "$l10n_ps_mod_settings_title")
    g_royalSettings:registerSetting(self.name, "enabled", g_royalSettings.TYPES.GLOBAL, g_royalSettings.OWNERS.USER, 2, {false, true}, {"$l10n_ui_off", "$l10n_ui_on"}, "$l10n_ps_setting_enabled", "$l10n_ps_setting_enabled_tooltip"):addCallback(
        self.onEnableDisable,
        self
    )
    g_royalSettings:registerSetting(
        self.name,
        "precision",
        g_royalSettings.TYPES.GLOBAL,
        g_royalSettings.OWNERS.USER,
        6,
        {1, 2, 3, 4, 5, 6},
        {"$l10n_ps_setting_precision_1", "$l10n_ps_setting_precision_2", "$l10n_ps_setting_precision_3", "$l10n_ps_setting_precision_4", "$l10n_ps_setting_precision_5", "$l10n_ps_setting_precision_6"},
        "$l10n_ps_setting_precision",
        "$l10n_ps_setting_precision_tooltip"
    ):addCallback(self.onCurveChange, self)
end

function ProgressiveSteering:onEnableDisable(value)
    self.enabled = value
end

function ProgressiveSteering:onCurveChange(value)
    self.curveType = value
end

function ProgressiveSteering:onDraw()
    if self.enabled and self.debug then
        local scale = 1.5
        Utility.renderAnimCurve(0.5 - ((0.1125 * scale) / 2), 0.5 - ((0.2 * scale) / 2), 0.1125 * scale, 0.2 * scale, self.curves[self.curveType], 50)
    end
end

function Drivable.actionEventSteer(self, _, inputValue, _, isAnalog, _, deviceCategory)
    local spec = self.spec_drivable
    spec.lastInputValues.axisSteer = inputValue
    if inputValue ~= 0 then
        spec.lastInputValues.axisSteerIsAnalog = isAnalog
        spec.lastInputValues.axisSteerDeviceCategory = deviceCategory
        if isAnalog and ProgressiveSteering.enabled then
            spec.lastInputValues.axisSteer = inputValue * ProgressiveSteering.curves[ProgressiveSteering.curveType]:get(math.abs(Utility.clamp(-1, inputValue, 1)))
        end
    end
end
