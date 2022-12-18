local mui_defs = include("mui/mui_defs")
local mui_button = include("mui/widgets/mui_button")

local mui_checkbox = include("mui/widgets/mui_checkbox")

local ctrl_widget = include(SCRIPT_PATHS.qedctrl.."/mui/ctrl_widget")


local oldInit = mui_checkbox.init
function mui_checkbox:init( screen, def, ... )
	oldInit(self, screen, def, ...)
	ctrl_widget.init(self, def)
end

ctrl_widget.defineCtrlMethods(mui_checkbox)

function mui_checkbox:canControllerFocus()
	return self:isVisible() and self._button:getState() ~= mui_button.BUTTON_Disabled
end

-- TODO: Highlight the checkbox image on focus.
function mui_checkbox:getControllerFocusTarget()
	return self._button
end

function mui_checkbox:onControllerConfirm()
	self._button:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self._button, ie = {}})
end
