local mui_defs = include("mui/mui_defs")

-- Extract a local variable from the given function's upvalues
local function extractUpvalue(fn, name)
    local i = 1
    while true do
        local n, v = debug.getupvalue(fn, i)
        assert(n, string.format("Could not find upvalue: %s", name))
        if n == name then
            return v, i
        end
        i = i + 1
    end
end

local _M = inputmgr.getInputInternals()
local oldOnMouseMove = _M._onMouseMove or extractUpvalue(inputmgr.init, "onMouseMove")
local oldOnMouseWheel = _M._onMouseWheel or extractUpvalue(inputmgr.init, "onMouseWheel")
local oldOnMouseLeft = _M._onMouseLeft or extractUpvalue(inputmgr.init, "onMouseLeft")
local oldOnMouseMiddle = _M._onMouseMiddle or extractUpvalue(inputmgr.init, "onMouseMiddle")
local oldOnMouseRight = _M._onMouseRight or extractUpvalue(inputmgr.init, "onMouseRight")

do
    local originalFn = extractUpvalue(inputmgr.init, "onMouseMove")
    _M._createInputEvent = _M._createInputEvent or extractUpvalue(originalFn, "createInputEvent")
    _M._notifyListeners = _M._notifyListeners or extractUpvalue(originalFn, "notifyListeners")
end
_M._qedctrl_mouseEnabled = true

-- ===
-- Enable/disable the mouse.
--
-- Using controller bindings will disable the mouse' effect on the UI until the mouse is moved.
--

function inputmgr.isMouseEnabled()
    return _M._qedctrl_mouseEnabled
end

function inputmgr.setMouseEnabled(enabled)
    -- simlog("LOG_QEDCTRL", "inputmgr %s", enabled and "enableMouse" or "disableMouse")
    _M._qedctrl_mouseEnabled = enabled
end
function inputmgr.setControllerXY(x, y)
    _M._mouseX, _M._mouseY = x, y
end
function inputmgr.onControllerError() -- Call if we soft-fail in a method that could be called on update events to pause controller handling.
    inputmgr.setMouseEnabled(true)
end

function _M._onMouseMove(x, y, ...)
    if _M._qedctrl_mouseEnabled then
        _M._qedctrl_trueMouseX, _M._qedctrl_trueMouseY = x, y
        oldOnMouseMove(x, y, ...)
    elseif (math.abs(x - _M._qedctrl_trueMouseX) > 10) or
            (math.abs(y - _M._qedctrl_trueMouseY) > 10) then
        -- simlog("LOG_QEDCTRL", "inputmgr autoEnableMouse")
        _M._qedctrl_mouseEnabled = true
        _M._qedctrl_trueMouseX, _M._qedctrl_trueMouseY = x, y
        oldOnMouseMove(x, y, ...)
    else
        -- The normal UI relies on continuously emitted MouseMove events to keep focus updated.
        -- Emit our own update event instead.
        local ev = _M._createInputEvent("ControllerUpdate")
        _M._notifyListeners(ev)
    end
end

function _M._reenableMouse()
    if not _M._qedctrl_mouseEnabled then
        -- simlog("LOG_QEDCTRL", "inputmgr autoEnableMouse")
        _M._qedctrl_mouseEnabled = true
    end
end

function _M._onMouseWheel(...)
    _M._reenableMouse()
    oldOnMouseWheel(...)
end

function _M._onMouseLeft(...)
    _M._reenableMouse()
    oldOnMouseLeft(...)
end

function _M._onMouseMiddle(...)
    _M._reenableMouse()
    oldOnMouseMiddle(...)
end

function _M._onMouseRight(...)
    _M._reenableMouse()
    oldOnMouseRight(...)
end

local oldInit = inputmgr.init
function inputmgr.init()
    oldInit()

    MOAIInputMgr.device.pointer:setCallback(_M._onMouseMove)
    MOAIInputMgr.device.wheel:setCallback(_M._onMouseWheel)
    MOAIInputMgr.device.mouseLeft:setCallback(_M._onMouseLeft)
    MOAIInputMgr.device.mouseMiddle:setCallback(_M._onMouseMiddle)
    MOAIInputMgr.device.mouseRight:setCallback(_M._onMouseRight)
end

-- ===
-- Suppress isDown checks on arrow keys for the duration of cam handler's updates.

local ARROW_KEYS = {
    [mui_defs.K_UPARROW] = true,
    [mui_defs.K_DOWNARROW] = true,
    [mui_defs.K_LEFTARROW] = true,
    [mui_defs.K_RIGHTARROW] = true,
}

_M._qedctrl_arrowKeysHidden = false
function inputmgr.hideArrowKeys(enabled)
    _M._qedctrl_arrowKeysHidden = enabled
end

local oldKeyIsDown = inputmgr.keyIsDown
function inputmgr.keyIsDown(key, ...)
    if _M._qedctrl_arrowKeysHidden and ARROW_KEYS[key] then
        return
    else
        return oldKeyIsDown(key, ...)
    end
end
