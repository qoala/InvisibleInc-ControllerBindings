local mui_defs = include("mui/mui_defs")
local mui_button = include("mui/widgets/mui_button")

local oldInit = mui_button.init
function mui_button:init( def, ... )
	oldInit( self, def, ... )

	if def.ctrlCoord then
		assert(type(def.ctrlCoord) == "table", def.name)
	end
	self._ctrlCoord = def.ctrlCoord
	self._ctrlGroup = def.ctrlGroup or 1
end

function mui_button:setControllerCoord(pos, group)
	self._ctrlCoord = pos
	self._ctrlGroup = group
end

function mui_button:getControllerCoord()
	return self._ctrlCoord
end

function mui_button:getControllerGroup()
	return self._ctrlGroup
end

function mui_button:isDisabled()
	return self._buttonState == mui_button.BUTTON_Disabled
end

function mui_button:handleControllerClick()
	self:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self, ie = {}})
end


local oldOnActivate = mui_button.onActivate
function mui_button:onActivate( screen, ... )
	oldOnActivate(self, screen, ...)
	if self._ctrlCoord then
		screen._qedctrl:addWidget(self)
	end
end

local oldOnDeactivate = mui_button.onDeactivate
function mui_button:onDeactivate( screen, ... )
	if self._ctrlCoord then
		screen._qedctrl:removeWidget(self)
	end
	oldOnDeactivate(self, screen, ...)
end
