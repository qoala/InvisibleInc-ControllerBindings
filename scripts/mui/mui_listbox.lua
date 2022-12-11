local util = include("modules/util")
local mui_defs = include("mui/mui_defs")

local mui_listbox = include("mui/widgets/mui_listbox")

local ctrl_defs = include(SCRIPT_PATHS.qedctrl.."/ctrl_defs")
local padctrl_widget = include(SCRIPT_PATHS.qedctrl.."/mui/mui_padctrl").widget

local ITEM_Inactive = 1
local ITEM_Active = 2
local ITEM_Hover = 3

local ORIENT_H = 1
local ORIENT_V = 2


local oldInit = mui_listbox.init
function mui_listbox:init( screen, def, ... )
	oldInit( self, screen, def, ... )

	if padctrl_widget.init(self, def) then
		self._qedctrl_selectsItems = def.ctrlProperties.listBoxSelectsItems
	end
end

padctrl_widget.defineCtrlMethods(mui_listbox, {
	onActivate = function(self, screen)
		self._qedctrl_focusIdx = nil
	end,
	onDeactivate = function(self, screen)
		self._qedctrl_focusIdx = nil
	end,
})

function mui_listbox:canControllerFocus()
	if not self:isVisible() or #self._items < 1 then
		return
	elseif self._no_hitbox then -- TODO: Support listboxes without item-level hitboxes.
		return
	end
	return true
end

-- TODO: Can individual listbox items be unavailable for focus?
function mui_listbox:_setControllerFocus(options, idx, ...)
	if #self._items > 0 then
		idx = math.min(math.max(idx, 1), #self._items)
	end
	local item = self._items[idx]
	if not item then
		if options and options.force then
			self._qedctrl_focusIdx = idx
			return self._qedctrl_ctrl:setFocus(nil)
		end
		return
	end

	if item.hitbox then
		self._qedctrl_focusIdx = idx
		return self._qedctrl_ctrl:setFocus(item.hitbox)
	end
end

function mui_listbox:onControllerFocus(options, idx, ...)
	if idx then
		return self:_setControllerFocus(options, idx, ...)
	end
	if options and options.recall and self._qedctrl_focusIdx then
		return self:_setControllerFocus(self._qedctrl_focusIdx)
	end
	return self:_setControllerFocus(options, 1)
end

function mui_listbox:onControllerUpdate()
	if self._qedctrl_focusIdx and self._items[self._qedctrl_focusIdx] then
		local item = self._items[self._qedctrl_focusIdx]
		if item.hitbox then
			self._qedctrl_ctrl:setFocus(item.hitbox)
		end
	elseif #self._items > 0 then
		self:onControllerFocus()
	end
end

function mui_listbox:onControllerNav( navDir )
	local i = self._qedctrl_focusIdx
	if not i then
		return
	elseif ((self._orientation ~= ORIENT_H and navDir == ctrl_defs.UP)
		or (self._orientation == ORIENT_H and navDir == ctrl_defs.LEFT))
	then
		if i > 1 then
			return self:_setControllerFocus({}, i - 1)
		end
	elseif ((self._orientation ~= ORIENT_H and navDir == ctrl_defs.DOWN)
		or (self._orientation == ORIENT_H and navDir == ctrl_defs.RIGHT))
	then
		if i < #self._items then
			return self:_setControllerFocus({}, i + 1)
		end
	end
end

function mui_listbox:onControllerConfirm()
	if self._qedctrl_selectsItems and self.onItemClicked then
		local i = self._qedctrl_focusIdx
		util.callDelegate( self.onItemClicked, i, self._items[ i ].user_data )
	end
end
