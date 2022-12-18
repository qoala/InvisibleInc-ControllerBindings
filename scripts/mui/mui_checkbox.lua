local mui_defs = include("mui/mui_defs")
local mui_button = include("mui/widgets/mui_button")
local mui_texture = include("mui/widgets/mui_texture")

local mui_checkbox = include("mui/widgets/mui_checkbox")

local ctrl_widget = include(SCRIPT_PATHS.qedctrl.."/mui/ctrl_widget")


local function updateFocusLayout( self )
	local focusImage = self._qedctrl_focusImage
	local focusSize = self._qedctrl_focusSize
	focusImage:setPosition(self._w / 2 - self._checkSize)
	focusImage:setSize(focusSize, focusSize)
end

local oldInit = mui_checkbox.init
function mui_checkbox:init( screen, def, ... )
	oldInit(self, screen, def, ...)
	ctrl_widget.init(self, def)

	-- Prepare focus image regardless of ctrlProperties.
	-- Listbox item widgets don't have ctrlProperties.id.
	local focusImageDefs = def.ctrlProperties and def.ctrlProperties.focusImages
	if not focusImageDefs then
		focusImageDefs =
		{{
			file = "checkbox_no2.png",
			name = "hover",
		}}
	end
	self._qedctrl_focusImage = mui_texture(screen, { x = 0, y = 0, xpx = def.wpx, ypx = def.hpx, w = def.h, h = def.h, wpx = def.wpx, hpx = def.hpx, images = focusImageDefs })
	self._qedctrl_focusImage:setVisible(false)
	self._qedctrl_focusSize = def.ctrlProperties and def.ctrlProperties.focusSize or (self._checkSize * 1.2)
	self._cont:addComponent(self._qedctrl_focusImage)
end

do
	local overrides = {}
	function overrides:onActivate()
		updateFocusLayout(self)
	end

	ctrl_widget.defineCtrlMethods(mui_checkbox, nil, overrides)
end

local oldHandleEvent = mui_checkbox.handleEvent
function mui_checkbox:handleEvent( ev, ... )

	if ev.eventType == mui_defs.EVENT_OnResize then
		updateFocusLayout( self )

	elseif ev.widget == self._button then
		self:_updateControllerFocusState()

	elseif inputmgr.isMouseEnabled() ~= self._qedctrl_lastMouseEnabled then
		self._qedctrl_lastMouseEnabled = inputmgr.isMouseEnabled()
		self:_updateControllerFocusState()
	end

	return oldHandleEvent(self, ev, ...)
end

function mui_checkbox:_updateControllerFocusState()
	local inFocus = not inputmgr.isMouseEnabled() and (
			self._button:getState() == mui_button.BUTTON_Hover
			or self._button:getState() == mui_button.BUTTON_Active)
	self._qedctrl_focusImage:setVisible(inFocus)
end


-- ===

function mui_checkbox:canControllerFocus()
	return self:isVisible() and self._button:getState() ~= mui_button.BUTTON_Disabled
end

function mui_checkbox:getControllerFocusTarget()
	return self._button
end

function mui_checkbox:onControllerConfirm()
	self._button:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self._button, ie = {}})
end
