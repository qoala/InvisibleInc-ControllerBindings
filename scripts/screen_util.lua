-- Helpers for screen modifications.

local util = include("modules/util")

local _M = {}

-- Full modification entry for an arbitrary modification.
function _M.modify(filename, path, modification)
	return { filename, path, modification }
end

-- ===
-- Modification args.
-- Helpers that return a value for the 3rd argument of a modifyUIElement line.

_M.modificationDef = {}

-- Modification arg that applies a ctrl ID to a widget.
function _M.modificationDef.ctrlID(id, otherProperties)
	local ctrlProperties = { id = id }
	if otherProperties then
		ctrlProperties = util.extend(otherProperties)(ctrlProperties)
	end
	return { ctrlProperties = ctrlProperties }
end

-- Modification arg that applies a given modification arg to the [[btn]] widget within a skin.
-- The shared screen_button skin is common, though some use screens have their own skin with the same btn child.
function _M.modificationDef.skinButton(buttonModification)
	return { inheritDef = { ["btn"] = buttonModification } }
end

-- ===
-- Layout helpers.

_M.layoutDef = {}

-- Helper for widget references in layout children.
function _M.layoutDef.widget(widgetID, coord, otherProperties)
	local t = { widgetID = widgetID, coord = coord }
	if otherProperties then
		return util.extend(otherProperties)(t)
	end
	return t
end

-- Helper for the common case where all of a list layout's children are widget references.
function _M.layoutDef.widgetList(...)
	local t = {}
	for i, widgetID in ipairs({...}) do
		t[i] = _M.layoutDef.widget(widgetID, i)
	end
	return t
end

-- Full modification entry for assigning screen-wide layouts.
function _M.setLayouts(filename, layouts, otherProperties)
	local ctrlProperties = { layouts = layouts }
	if otherProperties then
		ctrlProperties = util.extend(otherProperties)(ctrlProperties)
	end
	return { filename, { "properties" }, { ctrlProperties = ctrlProperties } }
end

-- Full modification entry for assigning a single screen-wide layout.
function _M.setSingleLayout(filename, children, layoutProperties, otherProperties)
	local layoutDef = { id = 1, children = children }
	if layoutProperties then
		layoutDef = util.extend(layoutProperties)(layoutDef)
	end
	local ctrlProperties = { layouts = {layoutDef} }
	if otherProperties then
		ctrlProperties = util.extend(otherProperties)(ctrlProperties)
	end
	return { filename, { "properties" }, { ctrlProperties = ctrlProperties } }
end


return util.tmerge(util, _M)
