
-- Extract a local variable from the given function's upvalues
local function extractUpvalue(fn, name)
	local i = 1
	while true do
		local n, v = debug.getupvalue(fn, i)
		assert(n, string.format("Could not find upvalue: %s", name ))
		if n == name then
			return v, i
		end
		i = i + 1
	end
end

local _M = inputmgr.getInputInternals()
local oldOnMouseMove = extractUpvalue(inputmgr.init, "onMouseMove")
local oldOnMouseWheel = extractUpvalue(inputmgr.init, "onMouseWheel")
local oldOnMouseLeft = extractUpvalue(inputmgr.init, "onMouseLeft")
local oldOnMouseMiddle = extractUpvalue(inputmgr.init, "onMouseMiddle")
local oldOnMouseRight = extractUpvalue(inputmgr.init, "onMouseRight")

_M._mouseEnabled = true

function inputmgr.isMouseEnabled()
	return _M._mouseEnabled
end

function inputmgr.setMouseEnabled(enabled)
	simlog("LOG_QEDCTRL", "inputmgr %s", enabled and "enableMouse" or "disableMouse")
	_M._mouseEnabled = enabled
end

function _M._onMouseMove(x, y, ...)
	if _M._mouseEnabled then
		oldOnMouseMove(x, y, ...)
	elseif (math.abs(x - _M._mouseX) > 10) or (math.abs(y - _M._mouseY) > 10) then
		simlog("LOG_QEDCTRL", "inputmgr autoEnableMouse")
		_M._mouseEnabled = true
		oldOnMouseMove(x, y, ...)
	end
end

local function reenableMouse()
	if not _M._mouseEnabled then
		simlog("LOG_QEDCTRL", "inputmgr autoEnableMouse")
		_M._mouseEnabled = true
	end
end

function _M._onMouseWheel(...)
	reenableMouse()
	oldOnMouseWheel(...)
end

function _M._onMouseLeft(...)
	reenableMouse()
	oldOnMouseLeft(...)
end

function _M._onMouseMiddle(...)
	reenableMouse()
	oldOnMouseMiddle(...)
end

function _M._onMouseRight(...)
	reenableMouse()
	oldOnMouseRight(...)
end


local oldInit = inputmgr.init
function inputmgr.init()
	oldInit()

	MOAIInputMgr.device.pointer:setCallback( _M._onMouseMove )
	MOAIInputMgr.device.wheel:setCallback( _M._onMouseWheel )
	MOAIInputMgr.device.mouseLeft:setCallback( _M._onMouseLeft )
	MOAIInputMgr.device.mouseMiddle:setCallback( _M._onMouseMiddle )
	MOAIInputMgr.device.mouseRight:setCallback( _M._onMouseRight )
end
