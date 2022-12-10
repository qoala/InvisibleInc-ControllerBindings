local mui_defs = include("mui/mui_defs")
local mui_button = include("mui/widgets/mui_button")

local padctrl_widget = include(SCRIPT_PATHS.qedctrl.."/mui_padctrl").widget


local oldInit = mui_button.init
function mui_button:init( def, ... )
	oldInit(self, def, ...)
	padctrl_widget.init(self, def)
end

padctrl_widget.defineCtrlMethods(mui_button)

function mui_button:canControllerFocus()
	return self:isVisible() and self._buttonState ~= mui_button.BUTTON_Disabled
end

function mui_button:onControllerConfirm()
	self:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self, ie = {}})
end
