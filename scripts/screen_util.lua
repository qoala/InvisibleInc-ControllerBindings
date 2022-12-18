-- Helpers for screen modifications.

local qutil = include(SCRIPT_PATHS.qedctrl.."/qed_util")

local _M = {}

-- Re-exports
_M.extendData = qutil.extendData

-- Shallowly concatenates any number of arrays into the first array
function _M.concat(ary1, ...)
	local n = #ary1 + 1
	for _, other in ipairs({...}) do
		for _, v in ipairs(other) do
			ary1[n] = v
			n = n + 1
		end
	end
	return ary1
end


-- ===
-- Modification args.
-- Helpers that return a value for the 3rd argument of a modifyUIElement line.

-- Images for a basic border with corner highlights.
_M.SELECT_BORDER_16 = "qedctrl/select16.png"
_M.SELECT_BORDER_64 = "qedctrl/select64.png"
_M.SELECT_BORDER_512 = "qedctrl/select512.png"


-- Full modification entry for an arbitrary modification.
--
-- Usage:
--     sutil.modify("file.lua", "widgets", ...)
--     {
--     },
function _M.modify(filename, ...)
	local path = { ... }
	return function(modification)
		return { filename, path, modification }
	end
end
_M.insert = _M.modify


-- Modification arg that applies arbitrary ctrlProperties
function _M.ctrl(properties, otherProperties)
	local modification = { ctrlProperties = properties }
	if otherProperties then
		modification = qutil.extendData(otherProperties)(modification)
	end
	return modification
end

-- Modification arg that applies a ctrl ID to a widget.
function _M.ctrlID(id, otherProperties)
	assert(type(id) == "string" or type(id) == "number", "[QEDCTRL] Illegal ID "..tostring(id))
	local ctrlProperties = { id = id }
	if otherProperties then
		ctrlProperties = qutil.extendData(otherProperties)(ctrlProperties)
	end
	return { ctrlProperties = ctrlProperties }
end

-- Modification arg that applies a given modification arg to the [[btn]] widget within a skin.
-- The shared screen_button skin is common, though some use screens have their own skin with the same btn child.
function _M.skinButton(buttonModification)
	return { inheritDef = { ["btn"] = buttonModification } }
end


-- ===
-- Layout helpers.

-- Helper for widget references in layout children.
function _M.widget(widgetID, coord, otherProperties)
	local t = { widgetID = widgetID, coord = coord }
	if otherProperties then
		return qutil.extendData(otherProperties)(t)
	end
	return t
end

-- Helper for the common case where all of a list or grid's children are widget references.
function _M.widgetList(...)
	local t = {}
	for i, widgetID in ipairs({...}) do
		t[i] = _M.widget(widgetID, i)
	end
	return t
end
function _M.widgetRow(y, ...)
	local t = {}
	for x, widgetID in ipairs({...}) do
		t[x] = _M.widget(widgetID, {x,y})
	end
	return t
end
function _M.widgetCol(x, ...)
	local t = {}
	for y, widgetID in ipairs({...}) do
		t[y] = _M.widget(widgetID, {x,y})
	end
	return t
end

-- Full modification entry for assigning screen-wide layouts.
function _M.setLayouts(filename, layouts, otherProperties)
	local ctrlProperties = { layouts = layouts }
	if otherProperties then
		ctrlProperties = qutil.extendData(otherProperties)(ctrlProperties)
	end
	return { filename, { "properties" }, { ctrlProperties = ctrlProperties } }
end

-- Full modification entry for assigning a single screen-wide layout.
function _M.setSingleLayout(filename, children, layoutProperties, otherProperties)
	local layoutDef = { id = "root", children = children }
	if layoutProperties then
		layoutDef = qutil.extendData(layoutProperties)(layoutDef)
	end
	local ctrlProperties = { layouts = {layoutDef} }
	if otherProperties then
		ctrlProperties = qutil.extendData(otherProperties)(ctrlProperties)
	end
	return { filename, { "properties" }, { ctrlProperties = ctrlProperties } }
end


return _M
