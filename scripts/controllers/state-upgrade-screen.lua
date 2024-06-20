local mui_defs = include("mui/mui_defs")
local util = include("client_util")
local upgradeScreen = include("states/state-upgrade-screen")

function upgradeScreen:selectSlot(index)
    if index == 0 then
        self:selectIncognita()
    else
        self:selectAgent(self._agency.unitDefs[index], index)
    end
end

function upgradeScreen:onInputEvent(ev)
    if ev.eventType == mui_defs.EVENT_KeyDown then
        if util.isKeyBindingEvent("QEDCTRL_SELECTNEXT", ev) or
                util.isKeyBindingEvent("cycleSelection", ev) then
            local index = (self._selectedIndex + 1) % (#self._agency.unitDefs + 1)
            self:selectSlot(index)
            return true
        elseif util.isKeyBindingEvent("QEDCTRL_SELECTPREV", ev) then
            local index = (self._selectedIndex - 1) % (#self._agency.unitDefs + 1)
            self:selectSlot(index)
            return true
        end
    end
end

local oldSelectIncognita = upgradeScreen.selectIncognita
function upgradeScreen:selectIncognita(...)
    oldSelectIncognita(self, ...)
    self._selectedIndex = 0
end

local oldOnLoad = upgradeScreen.onLoad
function upgradeScreen:onLoad(...)
    oldOnLoad(self, ...)
    inputmgr.addListener(self, 1)
end
local oldOnUnload = upgradeScreen.onUnload
function upgradeScreen:onUnload(...)
    inputmgr.removeListener(self)
    oldOnUnload(self, ...)
end
