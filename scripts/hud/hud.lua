local mui_defs = include("mui/mui_defs")
local util = include("client_util")

local hud = include("hud/hud")

local end_turn_dialog = include(SCRIPT_PATHS.qedctrl .. "/controllers/end_turn_dialog")

--

function onClickEndTurnMenu(self)
    if self._state ~= self.STATE_NULL then
        self:transitionNull()
    else
        local result = self._qedctrl_endTurnDialog:show()
        if result == end_turn_dialog.END_TURN then
            local button = self._endTurnButton._button
            button:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget = button, ie = {}})
        elseif result == end_turn_dialog.REWIND then
            local button = self._screen.binder.rewindBtn._button
            button:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget = button, ie = {}})
        end
    end
end

function onInputEvent(self, ev)
    if self.hide_interface then
        return
    end

    if self._state == self.STATE_NULL then
        local sim = self._game.simCore
        if ev.eventType == mui_defs.EVENT_KeyDown then
            if util.isKeyBindingEvent("QEDCTRL_SELECTNEXT", ev) then
                self._selection:selectNextUnit()
                return true
            elseif util.isKeyBindingEvent("QEDCTRL_SELECTPREV", ev) then
                self._selection:selectPreviousUnit()
                return true
            end
        end
    end
end

--

local oldCreateHud = hud.createHud
hud.createHud = function(...)
    local hudObject = oldCreateHud(...)

    do
        local btnEndTurnMenu = hudObject._screen.binder.qedctrlEndTurnMenu
        if btnEndTurnMenu and not btnEndTurnMenu.isnull then
            hudObject._qedctrl_endTurnDialog = end_turn_dialog(hudObject._game)

            btnEndTurnMenu.onClick = util.makeDelegate(nil, onClickEndTurnMenu, hudObject)
        end
    end

    local oldDestroyHud = hudObject.destroyHud
    function hudObject:destroyHud()
        if self._qedctrl_endTurnDialog then
            self._qedctrl_endTurnDialog:hide()
            self._qedctrl_endTurnDialog = nil
        end

        oldDestroyHud(self)
    end

    local oldOnInputEvent = hudObject.onInputEvent
    function hudObject:onInputEvent(event, ...)
        if onInputEvent(self, event) then
            return true
        end

        return oldOnInputEvent(self, event, ...)
    end

    return hudObject
end
