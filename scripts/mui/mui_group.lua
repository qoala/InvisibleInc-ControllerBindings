
local mui_group = include("mui/widgets/mui_group")

local oldInit = mui_group.init
function mui_group:init( screen, def, ... )
	oldInit(self, screen, def, ...)

	if def.ctrlProperties and def.ctrlProperties.bindListItemTo then
		local path = def.ctrlProperties.bindListItemTo
		self._qedctrl_listItem = self:findWidget(path)
	end
end

function mui_group:getControllerListItem()
	return self._qedctrl_listItem
end
