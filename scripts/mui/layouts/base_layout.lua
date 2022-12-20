-- Abstract base class of a layout node.

local array = include("modules/array")

local ctrl_defs = include(SCRIPT_PATHS.qedctrl.."/ctrl_defs")
local qutil = include(SCRIPT_PATHS.qedctrl.."/qed_util")


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
function base_layout:getPath()
	return self._navigatePath
end

-- === [abstract]
-- function layout:isEmpty() : bool
-- function layout:canFocus() : bool
-- function layout:onFocus(options, coord, ...) : bool
-- optional function layout:_onInternalNav( navDir ) : bool
-- optional function layout:_onConfirm() : bool
-- optional function layout:_onInternalCommand( command ) : bool  -- Use onConfirm for CONFIRM.

local TO_FIELDS =
{
	[ctrl_defs.UP]      = "upTo",
	[ctrl_defs.DOWN]    = "downTo",
	[ctrl_defs.LEFT]    = "leftTo",
	[ctrl_defs.RIGHT]   = "rightTo",
	[ctrl_defs.CONFIRM] = "confirmTo",
	[ctrl_defs.CANCEL]  = "cancelTo",
	[ctrl_defs.PPREV]   = "pprevTo",
	[ctrl_defs.PNEXT]   = "pnextTo",
}
local LISTENER_MAPPINGS =
{
	["cancelTo"] = ctrl_defs.CANCEL, 
	["pprevTo"] = ctrl_defs.PPREV, 
	["pnextTo"] = ctrl_defs.PNEXT, 
}

function base_layout:onActivate( ctrlScreen )
	-- simlog("LOG_QEDCTRL", "ctrl:activate %s:%s", tostring(self._debugName), tostring(self._SHAPE))
	self._ctrl = ctrlScreen
	self._focusChild = nil
	for k, cmd in pairs(LISTENER_MAPPINGS) do
		if self._def[k] then
			ctrlScreen:incrementListenerCount(self._navigatePath[1], cmd)
		end
	end
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

function base_layout:onNav(navDir, coord, ...)
	if not coord and self._focusChild and self._focusChild:onNav(navDir) then return true end

	if self._onInternalNav and self:_onInternalNav(navDir, coord, ...) then return true end

	local toPath = self._def[TO_FIELDS[navDir]]
	if toPath then
		local options, pathStart = {dir=navDir, continue=true}, 1
		if toPath.options then
			options = qutil.extendData(toPath.options, options){}
		end
		return self._ctrl:navigateTo(options, unpack(toPath, 1, #toPath))
	end
end

function base_layout:onCommand( command, dat )
	if self._focusChild and self._focusChild:onCommand( command, dat ) then return true end
	if dat.interrupted then return end

	if command == ctrl_defs.CONFIRM and self._onConfirm and self:_onConfirm() then
		return true
	elseif self._onInternalCommand and self:_onInternalCommand( command, dat ) then
		return true
	end
	if dat.interrupted then return end

	local toPath = self._def[TO_FIELDS[command]]
	if toPath then
		-- These tend are forced, unlike directional "to" paths.
		return self._ctrl:navigateTo({force=true}, unpack(toPath))
	elseif toPath ~= nil then
		-- simlog("LOG_QEDCTRL", "ctrl:command %s interrupted %s", ctrl_defs.CMD_DBG[command], self._debugName)
		dat.interrupted = true
		return
	end
end

return base_layout
