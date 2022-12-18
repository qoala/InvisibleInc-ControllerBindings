local mui_defs = include("mui/mui_defs")
local mui_button = include("mui/widgets/mui_button")

local mui_combobox = include("mui/widgets/mui_combobox")

local ctrl_widget = include(SCRIPT_PATHS.qedctrl.."/mui/ctrl_widget")


local oldInit = mui_combobox.init
function mui_combobox:init( screen, def, ... )
	oldInit(self, screen, def, ...)
	ctrl_widget.init(self, def)
end

ctrl_widget.defineCtrlMethods(mui_combobox)

function mui_combobox:canControllerFocus()
	return self:isVisible() and self._btn:getState() ~= mui_button.BUTTON_Disabled
end

function mui_combobox:getControllerFocusTarget()
	return self._btn
end

-- TODO: Capture controls into the dropdown.
function mui_combobox:onControllerConfirm()
	self._btn:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self._btn, ie = {}})
end
