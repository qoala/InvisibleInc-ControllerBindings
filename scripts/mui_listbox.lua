local util = include("modules/util")
local mui_defs = include("mui/mui_defs")
local mui_listbox = include("mui/widgets/mui_listbox")

local padctrl_widget = include(SCRIPT_PATHS.qedctrl.."/mui_padctrl").widget

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
	return (
		self:isVisible() and #self._items > 0
		and not self._no_hitbox -- TODO: Support listboxes without item-level hitboxes.
	)
end

-- TODO: Can individual listbox items be unavailable for focus?
function mui_listbox:setControllerFocus(idx)
	local item = self._items[idx]
	if not item then
		return
	end

	local widget
	if not self._no_hitbox then
		widget = item.hitbox
	end

	if widget then
		self._qedctrl_focusIdx = idx
		return self._qedctrl:setProxyFocus(self, widget, idx)
	end
end

function mui_listbox:onControllerFocus()
	self._qedctrl_focusIdx = self._qedctrl_focusIdx or 1
	return self:setControllerFocus(self._qedctrl_focusIdx)
end

function mui_listbox:onControllerUp()
	if self._orientation == ORIENT_H then return end

	local i = self._qedctrl_focusIdx
	if i > 1 then
		return self:setControllerFocus(i - 1)
	end
end

function mui_listbox:onControllerDown()
	if self._orientation == ORIENT_H then return end

	local i = self._qedctrl_focusIdx
	if i < #self._items then
		return self:setControllerFocus(i + 1)
	end
end

function mui_listbox:onControllerLeft()
	if self._orientation ~= ORIENT_H then return end

	local i = self._qedctrl_focusIdx
	if i > 1 then
		return self:setControllerFocus(i - 1)
	end
end

function mui_listbox:onControllerRight()
	if self._orientation ~= ORIENT_H then return end

	local i = self._qedctrl_focusIdx
	if i < #self._items then
		return self:_setControllerFocus(i + 1)
	end
end

function mui_listbox:onControllerConfirm()
	if self._qedctrl_selectsItems and self.onItemClicked then
		local i = self._qedctrl_focusIdx
		util.callDelegate( self.onItemClicked, i, self._items[ i ].user_data )
	end
end
