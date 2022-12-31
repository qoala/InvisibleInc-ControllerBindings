local mui_defs = include("mui/mui_defs")
local mui_button = include("mui/widgets/mui_button")
local mui_texture = include("mui/widgets/mui_texture")

local mui_checkbox = include("mui/widgets/mui_checkbox")

local ctrl_widget = include(SCRIPT_PATHS.qedctrl .. "/mui/ctrl_widget")

local oldInit = mui_checkbox.init
function mui_checkbox:init(screen, def, ...)
    oldInit(self, screen, def, ...)
    ctrl_widget.init(self, def)

    local ctrlDef = def.ctrlProperties or {}
    local focusImageDefs
    local focusW, focusH
    if ctrlDef.focusImages then
        -- Focus image surrounding the checkbox.
        focusImageDefs = ctrlDef.focusImages
        local focusSize = (ctrlDef.focusImageSize or
                                  (ctrlDef.focusImagePadding and self._checkSize +
                                          ctrlDef.focusImagePadding) or (self._checkSize * 1.2))
        focusW = ctrlDef.focusImageW or focusSize
        focusH = ctrlDef.focusImageH or focusSize
    else
        -- Default focus image.
        -- Listbox item widgets don't have ctrlProperties, and no native focus behavior,
        -- so always initialize a focus texture.
        focusImageDefs = "qedctrl/select-checkbox.png"
        focusW, focusH = self._checkSize, self._checkSize
    end
    self._qedctrl_focusImage = mui_texture(
            screen, {
                x = 0,
                y = 0,
                w = focusW,
                h = focusH,
                xpx = def.wpx,
                ypx = def.hpx,
                wpx = def.wpx,
                hpx = def.hpx,
                images = focusImageDefs,
            })
    self._qedctrl_focusImage:setVisible(false)
    self._qedctrl_focusImageW = focusW
    self._qedctrl_focusImageH = focusH
    self._cont:addComponent(self._qedctrl_focusImage)
end

do
    local overrides = {}
    function overrides:onActivate()
        self:_updateControllerFocusLayout()
    end

    ctrl_widget.defineCtrlMethods(mui_checkbox, nil, overrides)
end

local oldHandleEvent = mui_checkbox.handleEvent
function mui_checkbox:handleEvent(ev, ...)

    if ev.eventType == mui_defs.EVENT_OnResize then
        self:_updateControllerFocusLayout()

    elseif inputmgr.isMouseEnabled() ~= self._qedctrl_lastMouseEnabled then
        self._qedctrl_lastMouseEnabled = inputmgr.isMouseEnabled()
        self:_updateControllerFocusState()

    elseif ev.widget == self._button then
        self:_updateControllerFocusState()
    end

    return oldHandleEvent(self, ev, ...)
end

function mui_checkbox:_updateControllerFocusLayout()
    local focusImage = self._qedctrl_focusImage
    local focusW, focusH = self._qedctrl_focusImageW, self._qedctrl_focusImageH
    focusImage:setPosition(self._w / 2 - self._checkSize)
    focusImage:setSize(focusW, focusH)
end

function mui_checkbox:_updateControllerFocusState()
    local inFocus = not inputmgr.isMouseEnabled() and
                            (self._button:getState() == mui_button.BUTTON_Hover or
                                    self._button:getState() == mui_button.BUTTON_Active)
    self._qedctrl_focusImage:setVisible(inFocus)
end

-- ===

function mui_checkbox:canControllerFocus()
    return self:isVisible() and self._button:getState() ~= mui_button.BUTTON_Disabled
end

function mui_checkbox:getControllerFocusTarget()
    return self._button
end

function mui_checkbox:onControllerConfirm()
    self._button:dispatchEvent(
            {eventType = mui_defs.EVENT_ButtonClick, widget = self._button, ie = {}})
end
