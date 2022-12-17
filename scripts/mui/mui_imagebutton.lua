local mui_defs = include("mui/mui_defs")
local mui_button = include("mui/widgets/mui_button")

local mui_imagebutton = include("mui/widgets/mui_imagebutton")

local padctrl_widget = include(SCRIPT_PATHS.qedctrl.."/mui/mui_padctrl").widget


local oldInit = mui_imagebutton.init
function mui_imagebutton:init( screen, def, ... )
	oldInit(self, screen, def, ...)
	padctrl_widget.init(self, def)
end

padctrl_widget.defineCtrlMethods(mui_imagebutton)

function mui_imagebutton:canControllerFocus()
	return self:isVisible() and self._button:getState() ~= mui_button.BUTTON_Disabled
end

function mui_imagebutton:getControllerFocusTarget()
	return self._button
end

function mui_imagebutton:onControllerConfirm()
	self._button:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self._button, ie = {}})
end
