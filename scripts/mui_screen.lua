local mui_screen = include("mui/mui_screen")

local mui_padctrl = include(SCRIPT_PATHS.qedctrl.."/mui_padctrl")

local oldInit = mui_screen.init
function mui_screen:init( ... )
  oldInit( self, ... )
  self._padctrl = mui_padctrl( self )
  simlog("LOG_QEDCTRL", "screen:init %s", self._filename )
end

