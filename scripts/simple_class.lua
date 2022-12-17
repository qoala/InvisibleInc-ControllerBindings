-- Simplified class structure with fewer closures and better metamethod support.
--
-- The vanilla class framework interferes with __index/__newIndex overrides.
--

local sclass = {}

local sclassM = {}
setmetatable(sclass, sclassM)
function sclassM:__call(base, inheritDynamically)
	local cls = {}
	if inheritDynamically then
		-- Base class is the fallback lookup table for cls.
		-- Non-overridden methods can be added/updated on the base class after subclass creation.
		local clsM = {
			__call = sclass.newInstance,
			__index = base,
		}
		setmetatable(cls, clsM)
	else
		setmetatable(cls, sclass._clsM)

		-- Base class fields/methods are copied shallowly. (vanilla class behavior)
		if base then
			for k,v in pairs(base) do
				cls[k] = v
			end
		end
	end
	cls._base = base
	cls.is_a = sclass.is_a
	cls.__index = cls

	return cls
end

function sclass.newInstance(cls, ...)
	local t = {}
	setmetatable(t, cls)
	t:init(...)
	return t
end
sclass._clsM = { __call = sclass.newInstance }

function sclass.is_a(t, cls)
	local m = getmetatable(t)
	while m do
		if m == cls then return true end
		m = m._base
	end
	return false
end

return sclass
