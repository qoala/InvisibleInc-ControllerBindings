local mui_defs = include("mui/mui_defs")
local mui_button = include("mui/widgets/mui_button")

local oldInit = mui_button.init
function mui_button:init( def, ... )
	oldInit( self, def, ... )

	if def.ctrlProperties then
		assert(type(def.ctrlProperties) == "table", def.name)
		assert(type(def.ctrlProperties.coord) == "table", def.name)
		self._qedctrl_def = def.ctrlProperties
		self._qedctrl_coord = def.ctrlProperties.coord
		self._qedctrl_group = def.ctrlProperties.group or 1
	end
end

function mui_button:setControllerCoord(pos, group)
	self._qedctrl_coord = pos
	self._qedctrl_group = group or 1
	self._qedctrl_def = self._qedctrl_def or {}
end
function mui_button:getControllerCoord()
	return self._qedctrl_coord
end
function mui_button:getControllerGroup()
	return self._qedctrl_group
end
function mui_button:getControllerDef()
	return self._qedctrl_def
end

function mui_button:handleControllerClick()
	self:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self, ie = {}})
end

function mui_button:isDisabled()
	return self._buttonState == mui_button.BUTTON_Disabled
end


local oldOnActivate = mui_button.onActivate
function mui_button:onActivate( screen, ... )
	oldOnActivate(self, screen, ...)
	if self._qedctrl_coord then
		screen._qedctrl:addWidget(self)
	end
end

local oldOnDeactivate = mui_button.onDeactivate
function mui_button:onDeactivate( screen, ... )
	if self._qedctrl_coord then
		screen._qedctrl:removeWidget(self)
	end
	oldOnDeactivate(self, screen, ...)
end
