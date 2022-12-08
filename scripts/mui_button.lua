local mui_button = include("mui/widgets/mui_button")

local oldInit = mui_button.init
function mui_button:init( def, ... )
	oldInit( self, def, ... )

	self._ctrlindex = def.ctrlindex
	if def.ctrlindex then
		assert(type(def.ctrlindex) == "table", def.name)
	end
end

function mui_button:setControllerIndex(c, r)
	self._ctrlindex = {c, r}
end

function mui_button:getControllerIndex()
	return self._ctrlindex
end

function mui_button:isDisabled()
	return self._buttonState == mui_button.BUTTON_Disabled
end


local oldOnActivate = mui_button.onActivate
function mui_button:onActivate( screen, ... )
	oldOnActivate(self, screen, ...)
	if self._ctrlindex then
		screen._padctrl:addWidget(self)
	end
end

local oldOnDeactivate = mui_button.onDeactivate
function mui_button:onDeactivate( screen, ... )
	if self._ctrlindex then
		screen._padctrl:removeWidget(self)
	end
	oldOnDeactivate(self, screen, ...)
end
