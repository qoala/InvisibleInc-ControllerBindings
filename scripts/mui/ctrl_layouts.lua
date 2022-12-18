-- Hierarchy Nodes for a logical layout of interactive UI elements.

local _M = {}

do -- Re-export layout classes.
	_M.base_layout = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/base_layout")

	local single_layouts = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/single_layouts")
	_M.widget_reference = single_layouts.widget_reference
	_M.solo_layout      = single_layouts.solo_layout

	local listbox_layouts = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/listbox_layouts")
	_M.listbox_layout = listbox_layouts.listbox_layout
	_M.combobox_layout = listbox_layouts.combobox_layout

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
	vlist = _M.vlist_layout,
	hlist = _M.hlist_layout,
	rgrid = _M.rgrid_layout,
	cgrid = _M.cgrid_layout,
}
_M.WIDGET_NODE_FACTORY = {
	default = _M.widget_reference,
	listbox = _M.listbox_layout,
}
function _M.createLayoutNode(def, navigatePath, debugParent, debugIdx, debugCoord)
	if def.widgetID then
		return _M._createWidgetNode(def, navigatePath, debugParent, debugCoord)
	end
	assert(def.id, "Missing ID for non-widget child "..debugIdx.." of "..debugParent)
	local layoutType = _M.LAYOUT_FACTORY[def.shape or "vlist"]
	assert(layoutType, "Unknown layout shape "..tostring(def.shape).." on "..debugParent.."/"..tostring(def.id))
	return layoutType(def, navigatePath, debugParent, debugCoord)
end
function _M._createWidgetNode(def, navigatePath, debugParent, debugCoord)
	local refType = _M.WIDGET_NODE_FACTORY[def.widgetType or "default"]
	assert(refType, "Unknown widget type "..tostring(def.widgetType).." on "..debugParent.."/"..tostring(def.id))
	return refType(def, navigatePath, debugParent, debugCoord)
end

return _M
