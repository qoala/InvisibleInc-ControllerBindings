-- Simplified class structure with fewer closures and better inheritance.
--
-- If the base class is edited, this is immediately visible on already-defined subclasses.
--

local sclass = {}

local sclassM = {}
setmetatable(sclass, sclassM)
function sclassM:__call(base)
	local cls = {
		_base = base,

		is_a = sclass.is_a,
	}
	cls.__index = cls

	local clsM = {
		__call = sclass.newInstance,
		__index = base
	}
	setmetatable(cls, clsM)

	return cls
end

function sclass.newInstance(cls, ...)
	local t = {}
	setmetatable(t, cls)
	t:init(...)
	return t
end
function sclass.is_a(t, cls)
	local m = getmetatable(t)
	while m do
		if m == cls then return true end
		m = m._base
	end
	return false
end

return sclass
