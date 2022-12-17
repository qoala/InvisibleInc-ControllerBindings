-- Hierarchy Nodes for a logical layout of interactive UI elements.

local _M = {}

do -- Re-export layout classes.
	local base_layout = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/base_layout")
	_M.base_layout = base_layout

	local single_layouts = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/single_layouts")
	_M.widget_reference = single_layouts.widget_reference
	_M.solo_layout      = single_layouts.solo_layout

	local list_layouts = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/list_layouts")
	_M.list_layout  = list_layouts.list_layout
	_M.hlist_layout = list_layouts.hlist_layout
	_M.vlist_layout = list_layouts.vlist_layout

	local grid_layouts = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/grid_layouts")
	_M.grid_layout  = grid_layouts.grid_layout
	_M.rgrid_layout = grid_layouts.rgrid_layout
	_M.cgrid_layout = grid_layouts.cgrid_layout
end

_M.LAYOUT_FACTORY = {
	VLIST = _M.vlist_layout,
	HLIST = _M.hlist_layout,
	RGRID = _M.rgrid_layout,
	CGRID = _M.cgrid_layout,
}
function _M.createLayout(def, debugParent, debugIdx, debugCoord)
	if def.widgetID then
		return _M.widget_reference(def, debugParent, debugCoord)
	end
	assert(def.id, "Missing ID for non-widget child "..debugIdx.." of "..debugParent)
	local layoutType = _M.LAYOUT_FACTORY[def.shape or "VLIST"]
	assert(layoutType, "Unknown layout shape "..tostring(def.shape).." on "..debugParent.."/"..tostring(def.id))
	return layoutType(def, debugParent)
end

return _M
