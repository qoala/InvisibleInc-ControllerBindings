-- Initialization and method helpers for controllable widgets.

local widget = {}

function widget.init(self, def)
	if def.ctrlProperties then
		assert(type(def.ctrlProperties) == "table", def.name)
		self._qedctrl_ctrl = nil -- set on activate.
		self._qedctrl_def = def.ctrlProperties
		self._qedctrl_id = def.ctrlProperties.id
		return def.ctrlProperties
	end
end

-- function widget:canControllerFocus()
-- optional function widget:onControllerFocus()
-- optional function widget:onControllerUpdate() -- Required if onControllerFocus is defined.
-- optional function widget:onControllerNav( navDir )
-- optional function widget:onControllerConfirm()

function widget.defineCtrlMethods(cls, ctrlAppends, alwaysAppends)
	function cls:getControllerID()
		return self._qedctrl_id
	end
	function cls:getControllerDef()
		return self._qedctrl_def
	end
	function cls:setControllerPath( navigatePath )
		self._qedctrl_path = navigatePath
	end

	-- If the top-level of a listbox item skin is a supported interactive element, target it.
	function cls:getControllerListItem()
		return self
	end

	-- Widgets are added/removed on activate/deactivate,
	-- because some of them are mui_component, and components aren't added directly to the screen.
	local oldOnActivate = cls.onActivate
	function cls:onActivate( screen, ... )
		oldOnActivate(self, screen, ...)
		if self._qedctrl_id then
			self._qedctrl_ctrl = screen:getControllerControl()
			self._qedctrl_ctrl:attachWidget(self)

			if ctrlAppends and ctrlAppends.onActivate then
				ctrlAppends.onActivate(self, screen, ...)
			end
		end
		if alwaysAppends and alwaysAppends.onActivate then
			alwaysAppends.onActivate(self, screen, ...)
		end
	end

	local oldOnDeactivate = cls.onDeactivate
	function cls:onDeactivate( screen, ... )
		if self._qedctrl_ctrl and self._qedctrl_id then
			self._qedctrl_ctrl:detachWidget(self)

			if ctrlAppends and ctrlAppends.onDeactivate then
				ctrlAppends.onDeactivate(self, screen, ...)
			end
		end
		if alwaysAppends and alwaysAppends.onDeactivate then
			alwaysAppends.onDeactivate(self, screen, ...)
		end
		self._qedctrl_ctrl = nil
		oldOnDeactivate(self, screen, ...)
	end
end

return widget
