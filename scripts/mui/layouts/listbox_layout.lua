-- Layout node for wrapping a list box and its items

local util = include("modules/util")
local mui_button = include("mui/widgets/mui_button")

local ctrl_defs = include(SCRIPT_PATHS.qedctrl.."/ctrl_defs")
local base_layout = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/base_layout")


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
function listbox_layout:init( def, ... )
	self._id = def and def.widgetID
	listbox_layout._base.init(self, def, ...)

	self._widgetID = self._def.widgetID
	assert(self._widgetID, "[QEDCTRL] Listbox layout without widgetID "..self._debugName)

	-- Single child object that is updated to point at a specific index on focus.
	self._child = listbox_layout.item_reference(self._debugName)
end

function listbox_layout:onActivate( ... )
	listbox_layout._base.onActivate(self, ...)
	self._focusIdx = nil
	self._child:onActivate(self, ...)
end
function listbox_layout:onDeactivate( ... )
	self._child:onDeactivate(...)
	self._focusIdx = nil
	listbox_layout._base.onDeactivate(self, ...)
end

function listbox_layout:_getListWidget()
	return self._ctrl:getTypedWidget("listbox", self._widgetID)
end

function listbox_layout:isEmpty()
	local listWidget = self:_getListWidget()
	return not listWidget or listWidget._items[1] == nil
end

function listbox_layout:canFocus()
	local listWidget = self:_getListWidget()
	-- TODO: Can individual listbox items be unavailable for focus?
	return (listWidget and listWidget:isVisible() and listWidget._items[1] ~= nil
			and not listWidget._no_hitbox) -- TODO: Support listboxes without item-level hitboxes.
end

function listbox_layout:_doFocus( options, listWidget, item, idx, ... )
	-- TODO: Scrolling?
	local ok = item and self._child:onFocus(options, item, idx, ...)
	if ok or options.force then
		self._focusChild = ok and self._child or nil
		self._focusIdx = idx
		return true
	end
end

function listbox_layout:onFocus( options, idx, ... )
	local listWidget = self:_getListWidget()
	if not listWidget then return end
	local listOrientation = listWidget._orientation
	options = options or {}
	if idx then
		local item = listWidget._items[idx]
		local ok = item and self:_doFocus(options, listWidget, item, idx, ...)
		if not ok and idx and options.dir and options.continue then
			return self:onNav(options.dir, idx)
		end
		return ok
	elseif self._focusIdx and (options.recall or isOrthogonalDir(listOrientation, options.dir)) then
		-- Consider entry from orthogonal directions as a recall=true move.
		-- TODO: Maybe fall through if the recalled item is outside the current scroll range?
		local item = listWidget._items[self._focusIdx]
		if item and self:_doFocus(options, listWidget, item, self._focusIdx, ...) then
			return true
		end
	end
	local items = listWidget._items
	if isPrevDir(listOrientation, options.dir) then
		return self:_doFocus(options, listWidget, self:_getOrPrev(items, #items))
	elseif isNextDir(listOrientation, options.dir) then
		return self:_doFocus(options, listWidget, self:_getOrNext(items, 1))
	end
	-- TODO: Focus the first currently visible item if there's a scrollbar and no specific target.
	--   Also bounce back, if the only targetable items are earlier in the scroll.
	return self:_doFocus(options, listWidget, self:_getOrNext(items, 1))
end

function listbox_layout:_getOrPrev( items, i0 )
	local i = i0
	while i >= 1 do
		local item = items[i]
		if self._child:canFocusItem(item) then
			return item, i
		end
		i = i - 1
	end
end
function listbox_layout:_getOrNext( items, i0 )
	local i = i0
	local itemCount = #items
	while i <= itemCount do
		local item = items[i]
		if self._child:canFocusItem(item) then
			return item, i
		end
		i = i + 1
	end
end
function listbox_layout:_onInternalNav( navDir, idx )
	local listWidget = self:_getListWidget()
	if not listWidget then return end
	local listOrientation = listWidget._orientation
	local items = listWidget._items
	idx = idx or self._focusIdx
	if isPrevDir(listOrientation, navDir) and idx and idx > 1 then
		return self:_doFocus({dir=navDir}, listWidget, self:_getOrPrev(items, idx - 1))
	elseif isNextDir(listOrientation, navDir) and idx and idx < #items then
		return self:_doFocus({dir=navDir}, listWidget, self:_getOrNext(items, idx + 1))
	end
end

-- ===

local item_reference = class(base_layout)
listbox_layout.item_reference = item_reference
item_reference._SHAPE = "listitem"

function item_reference:init( debugParent, ... )
	self._id = ""
	item_reference._base.init(self, {}, debugParent, ...)
end

function item_reference:onActivate( parent, ... )
	item_reference._base.onActivate(self, ...)
	self._parent, self._idx = parent, nil
end

function item_reference:onDeactivate( ... )
	self._parent, self._idx = nil
	item_reference._base.onDeactivate(self, ...)
end

function item_reference:isEmpty()
	return not self._idx or self._parent:_getListWidget()[self._idx] == nil
end

function item_reference:canFocusItem( item )
	if not item then return false end
	if item.hitbox then
		return item.hitbox:getState() ~= mui_button.BUTTON_Disabled
	end
	local target = item.hitbox
	return target and target.canControllerFocus and target:canControllerFocus()
end

function item_reference:onFocus( options, item, idx )
	local ok = false
	if item then
		local target = item.hitbox
		ok = target and self._ctrl:setFocus(target, self._debugName..(idx or "?"))
	end
	if ok or options.force then
		self._idx = idx
		return true
	end
end

function item_reference:onUpdate()
	local listWidget = self._parent:_getListWidget()
	local item = self._idx and listWidget and listWidget._items[self._idx]
	local target = item and item.hitbox
	return self._ctrl:setFocus(target, self._debugName..(self._idx or "?").."::onUpdate")
end

function item_reference:onConfirm()
	local listWidget = self._parent:_getListWidget()
	local item = self._idx and listWidget and listWidget._items[self._idx]
	if not item then return end

	if listWidget.onItemClicked then
		util.callDelegate( listWidget.onItemClicked, self._idx, item.user_data )
		return true
	end

	local target
	if target and target.onControllerConfirm then
		simlog("LOG_QEDCTRL", "ctrl:confirm %s%s", self._debugName, self._idx or "?")
		target:onControllerConfirm()
		return true
	end
end

return listbox_layout
