local mui_defs = include("mui/mui_defs")
local mui_screen = include("mui/mui_screen")

local mui_padctrl = include(SCRIPT_PATHS.qedctrl.."/mui_padctrl")

local oldInit = mui_screen.init
function mui_screen:init( ... )
	oldInit( self, ... )

	-- simlog("LOG_QEDCTRL", "screen:init %s", self._filename )
	self._padctrl = mui_padctrl()
end

local oldOnActivate = mui_screen.onActivate
function mui_screen:onActivate( ... )
	self._padctrl:onActivate( self )
	oldOnActivate( self, ... )
end

local oldOnDeactivate = mui_screen.onDeactivate
function mui_screen:onDeactivate( ... )
	oldOnDeactivate( self, ... )
	self._padctrl:onDeactivate()
end

local oldRegisterProp = mui_screen.registerProp
function mui_screen:registerProp( prop, widget, ... )
	oldRegisterProp( self, prop, widget, ... )

	if widget.getTabindex and widget:getTabindex() then
		self._padctrl:addWidget( widget )
	end
end

local oldUnregisterProp = mui_screen.unregisterProp
function mui_screen:unregisterProp( prop, ... )
	assert( self._propToWidget[ prop ], prop:getDebugName() )
	local widget = self._propToWidget[ prop ]
	if widget.getTabindex and widget:getTabindex() then
		self._padctrl:removeWidget( widget )
	end

	oldUnregisterProp( self, prop, ... )
end
