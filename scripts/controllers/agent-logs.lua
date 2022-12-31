local util = include("client_util")

local dialog = include("fe/agent-logs")

local oldRefresh = dialog.refresh
function dialog:refresh(...)
    oldRefresh(self, ...)

    local ctrl = self.screen:getControllerControl()
    if self._unlockedlogs and #self._unlockedlogs > 0 then
        ctrl:navigateTo({force = true}, "logsList")
    else
        ctrl:navigateTo({force = true}, "closeBtn")
    end
end
