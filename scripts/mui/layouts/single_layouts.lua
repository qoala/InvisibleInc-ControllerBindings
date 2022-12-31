-- Single widgets as layout nodes.
--
-- * widget_reference: A singular interactive widget as a leaf node in the hierarchy.
-- * solo_layout: Special root layout with at most one widget in the hierarchy.
local base_layout = include(SCRIPT_PATHS.qedctrl .. "/mui/layouts/base_layout")

local base_widget_reference = class(base_layout)
function base_widget_reference:_getWidget()
    return self._widgetID and self._ctrl:getWidget(self._widgetID)
end

function base_widget_reference:isEmpty()
    return not self:_getWidget()
end

function base_widget_reference:canFocus()
    local widget = self:_getWidget()
    return widget and widget:canControllerFocus()
end

function base_widget_reference:onFocus(options, ...)
    local widget = self:_getWidget()
    if widget and widget.onControllerFocus then
        widget._qedctrl_debugName = self._debugName
        return widget:onControllerFocus(options, ...)
    elseif widget or (options and options.force) then
        local target = widget and widget:getControllerFocusTarget()
        return self._ctrl:setFocus(target, self._debugName)
    end
end

function base_widget_reference:onUpdate()
    local widget = self:_getWidget()
    if widget and widget.onControllerUpdate then
        return widget:onControllerUpdate()
    end
    local target = widget and widget:getControllerFocusTarget()
    return self._ctrl:setFocus(target, self._debugName .. "::onUpdate")
end

function base_widget_reference:_onInternalNav(navDir)
    local widget = self:_getWidget()
    if widget and widget.onControllerNav then
        return widget:onControllerNav(navDir)
    end
end

function base_widget_reference:_onConfirm()
    local widget = self:_getWidget()
    if widget and widget.onControllerConfirm then
        simlog("LOG_QEDCTRL", "ctrl:confirm %s", self._debugName)
        widget:onControllerConfirm()
        return true
    end
end

-- ===

local widget_reference = class(base_widget_reference)
widget_reference._SHAPE = "widget"
widget_reference.WIDGET_TYPE = 0 -- Untyped widgets.
function widget_reference:init(def, ...)
    self._id = def and def.widgetID
    base_layout.init(self, def, ...)

    self._widgetID = self._def.widgetID
    assert(self._widgetID, "[QEDCTRL] Widget reference without widgetID " .. self._debugName)
end

-- ===

-- A solo top-level widget.
-- Only constructed in the absence of a layout.
local solo_layout = class(base_widget_reference)
solo_layout._SHAPE = "-"
solo_layout._REGISTER_NODE = false
function solo_layout:init(debugParent)
    self._id = "solo"
    base_layout.init(self, nil, {}, debugParent)
    self._navigatePath[1] = 1 -- Installed at [1] in the screen.
end

function solo_layout:getWidgetID()
    return self._widgetID
end

function solo_layout:hasAutoConfirm()
    return self._autoConfirm
end

function solo_layout:setWidget(widget)
    self._widgetID = widget and widget:getControllerID()
    self._autoConfirm = widget and widget:getControllerDef().autoConfirm
end

return {
    base_widget_reference = base_widget_reference,
    widget_reference = widget_reference,
    solo_layout = solo_layout,
}
