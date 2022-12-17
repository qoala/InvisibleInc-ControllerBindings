-- Single widgets as layout nodes.
--
-- * widget_reference: A singular interactive widget as a leaf node in the hierarchy.
-- * solo_layout: Special root layout with at most one widget in the hierarchy.

local base_layout = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/base_layout")


local widget_reference = class(base_layout)
do
	widget_reference._SHAPE = "widget"
	function widget_reference:init( def, ... )
		self._id = def and def.widgetID
		widget_reference._base.init(self, def, ...)

		self._widgetID = self._def.widgetID
	end

	function widget_reference:_getWidget()
		return self._widgetID and self._ctrl:getWidget(self._widgetID)
	end

	function widget_reference:isEmpty()
		return not self:_getWidget()
	end

	function widget_reference:canFocus()
		local widget = self:_getWidget()
		return widget and widget:canControllerFocus()
	end

	function widget_reference:onFocus( options, ... )
		local widget = self:_getWidget()
		if widget and widget.onControllerFocus then
			widget._qedctrl_debugName = self._debugName
			return widget:onControllerFocus(options, ...)
		elseif widget or (options and options.force) then
			local target = widget and widget:getControllerFocusTarget()
			return self._ctrl:setFocus(target, self._debugName)
		end
	end

	function widget_reference:onUpdate()
		local widget = self:_getWidget()
		if widget and widget.onControllerUpdate then
			return widget:onControllerUpdate()
		end
		local target = widget and widget:getControllerFocusTarget()
		return self._ctrl:setFocus(target, self._debugName.."::onUpdate")
	end

	function widget_reference:_onInternalNav( navDir )
		local widget = self:_getWidget()
		if widget and widget.onControllerNav then
			return widget:onControllerNav(navDir)
		end
	end

	function widget_reference:onConfirm()
		local widget = self:_getWidget()
		if widget and widget.onControllerConfirm then
			simlog("LOG_QEDCTRL", "ctrl:confirm %s", self._debugName)
			widget:onControllerConfirm()
			return true
		end
	end
end

-- A solo top-level widget.
-- Only constructed in the absence of a layout.
local solo_layout = class(widget_reference)
do
	solo_layout._SHAPE = "-"
	function solo_layout:init( debugParent )
		self._id = "solo"
		base_layout.init(self, nil, debugParent) -- Skip widget_reference:init
	end

	function solo_layout:getWidgetID()
		return self._widgetID
	end

	function solo_layout:hasAutoConfirm()
		return self._autoConfirm
	end

	function solo_layout:setWidget( widget )
		self._widgetID = widget and widget:getControllerID()
		self._autoConfirm = widget and widget:getControllerDef().autoConfirm
	end
end

return {
	widget_reference = widget_reference,
	solo_layout = solo_layout,
}
