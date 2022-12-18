-- Abstract base class of a layout node.

local array = include("modules/array")

local ctrl_defs = include(SCRIPT_PATHS.qedctrl.."/ctrl_defs")


local base_layout = class()
function base_layout:init( def, parentPath, debugParent, debugCoord )
	self._def = def or {}
	self._id = self._id or self._def.id -- Allow subclasses to force ID before we build debugName.
	self._debugName = (debugParent or "?").."/"..tostring(self._id or "[nil]")
	simlog("LOG_QEDCTRL", "ctrl:init %s:%s%s", tostring(self._debugName), tostring(self._SHAPE), debugCoord and " @"..debugCoord or "")
	self._navigatePath = array.copy(parentPath)
	table.insert(self._navigatePath, self._id)
end
function base_layout:getID()
	return self._id
end

-- === [abstract]
-- function layout:isEmpty() : bool
-- function layout:canFocus() : bool
-- function layout:onFocus(options, coord, ...) : bool
-- optional function layout:_onInternalNav( navDir ) : bool

function base_layout:onActivate(screenCtrl)
	-- simlog("LOG_QEDCTRL", "ctrl:activate %s:%s", tostring(self._debugName), tostring(self._SHAPE))
	self._ctrl = screenCtrl
	self._focusChild = nil
end
function base_layout:onDeactivate()
	self._ctrl = nil
	self._focusChild = nil
end

function base_layout:onUpdate()
	if self._focusChild then
		return self._focusChild:onUpdate()
	elseif not self:isEmpty() then
		return self:onFocus({recall=true, onUpdate=true})
	end
end

local NAV_TO_FIELDS = {
	[ctrl_defs.UP] = "upTo",
	[ctrl_defs.DOWN] = "downTo",
	[ctrl_defs.LEFT] = "leftTo",
	[ctrl_defs.RIGHT] = "rightTo",
}
function base_layout:onNav(navDir, coord, ...)
	if not coord and self._focusChild and self._focusChild:onNav(navDir) then return true end

	if self._onInternalNav and self:_onInternalNav(navDir, coord, ...) then return true end

	local toPath = self._def[NAV_TO_FIELDS[navDir]]
	if toPath then
		return self._ctrl:navigateTo({dir=navDir, continue=true}, unpack(toPath))
	end
end

function base_layout:onConfirm()
	return self._focusChild and self._focusChild:onConfirm()
end

return base_layout
