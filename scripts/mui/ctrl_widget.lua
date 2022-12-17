-- Initialization and method helpers for controllable widgets.

local widget = {}

function widget.init(self, def)
	if def.ctrlProperties then
		assert(type(def.ctrlProperties) == "table", def.name)
		assert(def.ctrlProperties.id, def.name)
		self._qedctrl_ctrl = nil -- set on activate.
		self._qedctrl_def = def.ctrlProperties
		self._qedctrl_id = def.ctrlProperties.id
		return true
	end
end

-- function widget:canControllerFocus()
-- optional function widget:onControllerFocus()
-- optional function widget:onControllerUpdate() -- Required if onControllerFocus is defined.
-- optional function widget:onControllerNav( navDir )
-- optional function widget:onControllerConfirm()

function widget.defineCtrlMethods(cls, appends)
	function cls:getControllerID()
		return self._qedctrl_id
	end
	function cls:getControllerDef()
		return self._qedctrl_def
	end

	-- Widgets are added/removed on activate/deactivate,
	-- because some of them are mui_component, and components aren't added directly to the screen.
	local oldOnActivate = cls.onActivate
	function cls:onActivate( screen, ... )
		oldOnActivate(self, screen, ...)
		if self._qedctrl_id then
			self._qedctrl_ctrl = screen:getControllerControl()
			self._qedctrl_ctrl:attachWidget(self)

			if appends and appends.onActivate then
				appends.onActivate(self, screen, ...)
			end
		end
	end

	local oldOnDeactivate = cls.onDeactivate
	function cls:onDeactivate( screen, ... )
		if self._qedctrl_ctrl then
			self._qedctrl_ctrl:detachWidget(self)

			if appends and appends.onDeactivate then
				appends.onDeactivate(self, screen, ...)
			end
		end
		self._qedctrl_ctrl = nil
		oldOnDeactivate(self, screen, ...)
	end
end

return widget