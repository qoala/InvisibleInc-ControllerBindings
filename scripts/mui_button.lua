local mui_button = include("mui/widgets/mui_button")

local oldInit = mui_button.init
function mui_button:init( def, ... )
  oldInit( self, def, ... )
  self._tabindex = def.tabindex
  if def.tabindex then
	  simlog("LOG_QEDCTRL", "button:init %s %s %s", def.name, tostring(def.tabindex[1]), tostring(def.tabindex[2]) )
  end
end


