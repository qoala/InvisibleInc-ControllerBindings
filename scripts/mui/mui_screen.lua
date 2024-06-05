local mui_defs = include("mui/mui_defs")
local util = include("client_util")

local mui_screen = include("mui/mui_screen")

local ctrl_screen = include(SCRIPT_PATHS.qedctrl .. "/mui/ctrl_screen")

local oldInit = mui_screen.init
function mui_screen:init(...)
    oldInit(self, ...)

    self._qedctrl_ctrl = ctrl_screen(self._props.ctrlProperties, self._filename)

    -- Hide the sinksInput flag from the vanilla handleInputEvent.
    self._qedctrl_sinksInput = self._props.sinksInput
    self._props = util.tdupe(self._props)
    self._props.sinksInput = false
end

function mui_screen:getControllerControl()
    return self._qedctrl_ctrl
end

local oldOnActivate = mui_screen.onActivate
function mui_screen:onActivate(...)
    self._qedctrl_ctrl:onActivate(self) -- Prepare to receive widgets.
    oldOnActivate(self, ...)
    self._qedctrl_ctrl:afterActivate() -- Finalize for input.
end

local oldOnDeactivate = mui_screen.onDeactivate
function mui_screen:onDeactivate(...)
    -- Don't leave widgets focused, in case this screen is reused.
    if self._focusWidget then
        self:dispatchEvent(
                {
                    eventType = mui_defs.EVENT_FocusChanged,
                    newFocus = nil,
                    oldFocus = self._focusWidget,
                })
    end

    self._qedctrl_ctrl:onDeactivate()
    oldOnDeactivate(self, ...)
end

local oldHandleInputEvent = mui_screen.handleInputEvent
function mui_screen:handleInputEvent(ev, ...)
    if ev.eventType == 'ControllerUpdate' then
        local result = self._qedctrl_ctrl:onUpdate()

        local x, y = 0, 0
        if self._focusWidget then
            local widget = self._focusWidget
            if widget._cont then
                widget = widget._cont
            end
            if widget._prop then
                x, y = widget._prop:modelToWorld(0, 0)
                local wx, wy = self:uiToWnd(x, y)
                inputmgr.setControllerXY(wx, wy)
            end
        end

        -- Vanilla tooltip handling from handleInputEvent, but with our x,y coordinates.
        local props = self._layer:propListForPoint(x, y, 0, MOAILayer.SORT_PRIORITY_DESCENDING)
        local tooltip = nil
        if props then
            for i, prop in ipairs(props) do
                if prop:shouldDraw() and self._propToWidget[prop] then
                    local tooltipWidget = self._propToWidget[prop]._widget
                    tooltip = tooltipWidget:handleTooltip(x, y)
                    if tooltip ~= nil then
                        if type(tooltip) == "boolean" then
                            tooltip = nil
                        end
                        break
                    end
                end
            end
        end
        if tooltip == nil and self.onTooltip and self:handlesInput() then
            tooltip = util.callDelegate(self.onTooltip, self, x, y)
        end
        self:setTooltip(tooltip)

        return result
    end

    local handled = oldHandleInputEvent(self, ev, ...)

    if (not handled and ev.eventType == mui_defs.EVENT_KeyDown and
            util.isKeyBindingEvent("QEDCTRL_CANCEL", ev)) then
        -- Treat "cancel" as "Esc" in screens that don't have a native cancel binding.
        local fakeEv = util.tdupe(ev)
        fakeEv.key = mui_defs.K_ESCAPE
        handled = oldHandleInputEvent(self, fakeEv, ...)
    end

    return handled or self._qedctrl_sinksInput
end
