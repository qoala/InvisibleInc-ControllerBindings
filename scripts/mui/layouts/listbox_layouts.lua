-- Layout nodes for wrapping a list box and its items
--
-- listbox_layout: Standard listbox.
-- combobox_layout: Layout for the listbox when a combobox is open.
local util = include("modules/util")
local mui_button = include("mui/widgets/mui_button")
local mui_listbox = include("mui/widgets/mui_listbox")

local ctrl_defs = include(SCRIPT_PATHS.qedctrl .. "/ctrl_defs")
local base_layout = include(SCRIPT_PATHS.qedctrl .. "/mui/layouts/base_layout")

-- ===

local ORIENT_H = 1
local ORIENT_V = 2 -- default

local function isPrevDir(orient, navDir)
    if orient == ORIENT_H then
        return navDir == ctrl_defs.LEFT
    else
        return navDir == ctrl_defs.UP
    end
end
local function isNextDir(orient, navDir)
    if orient == ORIENT_H then
        return navDir == ctrl_defs.RIGHT
    else
        return navDir == ctrl_defs.DOWN
    end
end
local function isOrthogonalDir(orient, navDir)
    if orient == ORIENT_H then
        return navDir == ctrl_defs.UP or navDir == ctrl_defs.DOWN
    else
        return navDir == ctrl_defs.LEFT or navDir == ctrl_defs.RIGHT
    end
end

-- ===

local listbox_layout = class(base_layout)
listbox_layout._SHAPE = "listbox"
listbox_layout.WIDGET_TYPE = "listbox"
function listbox_layout:init(def, ...)
    self._id = def and def.widgetID
    listbox_layout._base.init(self, def, ...)

    self._widgetID = self._def.widgetID
    assert(self._widgetID, "[QEDCTRL] Listbox layout without widgetID " .. self._debugName)

    -- Single child object that is updated to point at a specific index on focus.
    self._child = listbox_layout.item_reference(self._def, self._navigatePath, self._debugName)
end

function listbox_layout:onActivate(ctrlScreen, ...)
    listbox_layout._base.onActivate(self, ctrlScreen, ...)
    self._focusIdx = nil
    self._child:onActivate(self, ctrlScreen, ...)
end
function listbox_layout:onDeactivate(...)
    self._child:onDeactivate(...)
    self._focusIdx = nil
    listbox_layout._base.onDeactivate(self, ...)
end

function listbox_layout:_getListWidget()
    return self._ctrl:getWidget(self._widgetID, "listbox")
end

function listbox_layout:isEmpty()
    local listWidget = self:_getListWidget()
    return not listWidget or listWidget._items[1] == nil
end

function listbox_layout:canFocus()
    local listWidget = self:_getListWidget()
    if listWidget and listWidget:isVisible() and listWidget._items[1] ~= nil then
        for _, item in ipairs(listWidget._items) do
            if self._child:canFocusItem(item) then
                return true
            end
        end
    end
end

function listbox_layout:_getVisibleRange(listWidget)
    local topIndex = listWidget._scrollIndex
    local botIndex = listWidget._scrollIndex + listWidget:getMaxVisibleItems() - 1
    return topIndex, botIndex
end
function listbox_layout:_doFocus(options, listWidget, item, idx, ...)
    if idx then
        local topIndex, botIndex = self:_getVisibleRange(listWidget)
        if topIndex + 1 > idx then
            listWidget:scrollItems(idx - 1)
        elseif idx > botIndex + 1 then
            listWidget:scrollItems(topIndex + (idx - botIndex) - 1)
        end
    end

    if item then
        ok = self._child:onFocus(options, item, idx, ...)
    elseif options.force then
        ok = self._ctrl:setFocus(nil, self._debugName)
    end
    if ok then
        self._focusChild = ok and self._child or nil
        self._focusIdx = idx
        return true
    end
end

local function shouldRecall(options, ctrlDef, listOrientation)
    if options.recall or ctrlDef.recallAlways then
        return true
    end

    -- Implicitly consider entry from orthogonal directions as a recall=true move.
    return ctrlDef.recallOrthogonal ~= false and isOrthogonalDir(listOrientation, options.dir)
end
function listbox_layout:onFocus(options, idx, ...)
    local listWidget = self:_getListWidget()
    if not listWidget then
        return
    end
    local listOrientation = listWidget._orientation
    options = options or {}
    local topIndex, botIndex
    if idx then
        local item = listWidget._items[idx]
        local ok = item and self:_doFocus(options, listWidget, item, idx, ...)
        if not ok and idx and options.dir and options.continue then
            return self:onNav(options.dir, idx)
        end
        return ok
    elseif self._focusIdx and shouldRecall(options, self._def, listOrientation) then
        local focusIdx = self._focusIdx
        topIndex, botIndex = self:_getVisibleRange(listWidget)
        -- Ignore recall if the entry has been scrolled off the screen.
        if focusIdx >= topIndex and focusIdx <= botIndex then
            local item = listWidget._items[focusIdx]
            if item and self:_doFocus(options, listWidget, item, focusIdx, ...) then
                return true
            end
        end
    end
    local items = listWidget._items
    if isPrevDir(listOrientation, options.dir) then
        return self:_doFocus(options, listWidget, self:_getOrPrev(items, #items))
    elseif isNextDir(listOrientation, options.dir) then
        return self:_doFocus(options, listWidget, self:_getOrNext(items, 1))
    end
    -- Focus the first currently visible item, if possible
    if not topIndex then
        topIndex, botIndex = self:_getVisibleRange(listWidget)
    end
    local item, i = self:_getOrNext(items, topIndex)
    if not i or i > botIndex then
        item, i = self:_getOrNext(items, 1)
    end
    return self:_doFocus(options, listWidget, item, i)
end

function listbox_layout:_getOrPrev(items, i0)
    for i = i0, 1, -1 do
        local item = items[i]
        if self._child:canFocusItem(item) then
            return item, i
        end
    end
    if self._def.wrap and i0 < #items then
        for i = #items, i0 + 1, -1 do
            local item = items[i]
            if self._child:canFocusItem(item) then
                return item, i
            end
        end
    end
end
function listbox_layout:_getOrNext(items, i0)
    for i = i0, #items do
        local item = items[i]
        if self._child:canFocusItem(item) then
            return item, i
        end
    end
    if self._def.wrap and i0 > 1 then
        for i = 1, i0 - 1 do
            local item = items[i]
            if self._child:canFocusItem(item) then
                return item, i
            end
        end
    end
end
function listbox_layout:_onInternalNav(navDir, idx)
    local listWidget = self:_getListWidget()
    if not listWidget then
        return
    end
    local listOrientation = listWidget._orientation
    local items = listWidget._items
    idx = idx or self._focusIdx
    if isPrevDir(listOrientation, navDir) and idx and (idx > 1 or self._def.wrap) then
        return self:_doFocus({dir = navDir}, listWidget, self:_getOrPrev(items, idx - 1))
    elseif isNextDir(listOrientation, navDir) and idx and (idx < #items or self._def.wrap) then
        return self:_doFocus({dir = navDir}, listWidget, self:_getOrNext(items, idx + 1))
    end
end

-- ===

local item_reference = class(base_layout)
listbox_layout.item_reference = item_reference
item_reference._SHAPE = "listitem"
item_reference._REGISTER_NODE = false

function item_reference:init(parentDef, parentPath, debugParent, ...)
    self._id = "#"
    item_reference._base.init(self, {}, parentPath, debugParent, ...)
    self._parentDef = parentDef
end

function item_reference:onActivate(parent, ...)
    item_reference._base.onActivate(self, ...)
    self._parent, self._idx = parent, nil
end

function item_reference:onDeactivate(...)
    self._parent, self._idx = nil
    item_reference._base.onDeactivate(self, ...)
end

function item_reference:isEmpty()
    return not self._idx or self._parent:_getListWidget()[self._idx] == nil
end

function item_reference:_getTarget(item)
    local widget = item.widget.getControllerListItem and item.widget:getControllerListItem()
    return widget, item.hitbox
end

function item_reference:canFocusItem(item)
    if not item then
        return false
    end
    local widget, hitbox = self:_getTarget(item)
    if widget then
        return widget.canControllerFocus and widget:canControllerFocus()
    elseif hitbox then
        return hitbox:getState() ~= mui_button.BUTTON_Disabled
    end
end

function item_reference:onFocus(options, item, idx)
    local target
    if item then
        local widget, hitbox = self:_getTarget(item)
        if widget then
            target = widget.getControllerFocusTarget and widget:getControllerFocusTarget()
        elseif hitbox then
            target = hitbox
        end
    end
    if target or (options and options.force) then
        local ok = self._ctrl:setFocus(
                target, self._debugName .. (idx or "?"), {noTooltip = self._parentDef.noTooltip})
        if ok then
            self._idx = idx
            self._navigatePath[#self._navigatePath] = idx
            return true
        end
    end
end

function item_reference:onUpdate()
    local listWidget = self._parent:_getListWidget()
    local item = self._idx and listWidget and listWidget._items[self._idx]
    local target
    if item then
        local widget, hitbox = self:_getTarget(item)
        if widget then
            target = widget.getControllerFocusTarget and widget:getControllerFocusTarget()
        elseif hitbox then
            target = hitbox
        end
    end
    return self._ctrl:setFocus(
            target, self._debugName .. (self._idx or "?") .. "::onUpdate",
            {noTooltip = self._parentDef.noTooltip})
end

function item_reference:_onConfirm()
    local listWidget = self._parent:_getListWidget()
    local item = self._idx and listWidget and listWidget._items[self._idx]
    if not item then
        return
    end

    local handled
    if listWidget.onItemClicked and not self._parentDef.ignoreOnItemClicked then
        simlog("LOG_QEDCTRL", "ctrl:confirmCallback %s%s", self._debugName, self._idx or "?")
        util.callDelegate(listWidget.onItemClicked, self._idx, item.user_data)
        handled = true
    end
    if item.hitbox then
        listWidget:selectIndex(self._idx)
        handled = listWidget.onItemSelected ~= nil
    end
    if handled then
        return true
    end

    local widget = self:_getTarget(item)
    if widget and widget.onControllerConfirm then
        simlog("LOG_QEDCTRL", "ctrl:confirm %s%s", self._debugName, self._idx or "?")
        widget:onControllerConfirm()
        return true
    end
end

-- ===

local combobox_layout = class(listbox_layout)
combobox_layout._SHAPE = "combobox"

function combobox_layout:init(id, debugParent)
    self._id = id
    base_layout.init(self, nil, {}, debugParent) -- Skip listbox_layout:init.

    self._child = listbox_layout.item_reference(self._def, self._navigatePath, self._debugName)
end

function combobox_layout:onDeactivate(...)
    self._listWidget = nil
    combobox_layout._base.onDeactivate(self, ...)
end

function combobox_layout:setListWidget(widget)
    assert(widget == nil or widget:is_a(mui_listbox))
    self._listWidget = widget
end
function combobox_layout:_getListWidget()
    return self._listWidget
end

function combobox_layout:setReturnPath(navigatePath)
    local oldPath = self._returnPath
    self._returnPath = navigatePath
    self._def.cancelTo = navigatePath
    return oldPath
end

function combobox_layout:_onInternalCommand(command)
    if command == ctrl_defs.CANCEL and self._listWidget.onControllerCancel then
        util.callDelegate(self._listWidget.onControllerCancel)
        return true
    end
end

return {listbox_layout = listbox_layout, combobox_layout = combobox_layout}
