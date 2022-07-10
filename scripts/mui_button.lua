local mui_button = include("mui/widgets/mui_button")

local oldInit = mui_button.init
function mui_button:init( def, ... )
	oldInit( self, def, ... )

	self._ctrlindex = def.ctrlindex
	if def.ctrlindex then
		assert(type(def.ctrlindex) == "table", def.name)
	end
end

function mui_button:getControllerIndex()
	return self._ctrlindex
end
