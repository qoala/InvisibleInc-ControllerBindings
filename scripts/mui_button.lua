local mui_button = include("mui/widgets/mui_button")

local oldInit = mui_button.init
function mui_button:init( def, ... )
	oldInit( self, def, ... )

	self._tabindex = def.tabindex
	if def.tabindex then
		assert(type(def.tabindex) == "table", def.name)
	end
end

function mui_button:getTabindex()
	return self._tabindex
end
