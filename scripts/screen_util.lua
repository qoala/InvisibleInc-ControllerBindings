-- Helpers for screen modifications.

local util = include("modules/util")

local _M = {}

-- Modification arg that applies ctrl coordinates to a widget.
function _M.ctrlCoord(coord, otherProperties)
	local ctrlProperties = { coord = coord }
	if otherProperties then
		ctrlProperties = util.extend(otherProperties)(ctrlProperties)
	end
	return { ctrlProperties = ctrlProperties }
end
-- Modification arg that applies ctrl group and coordinates to a widget.
function _M.ctrlGroupCoord(group, coord, otherProperties)
	local ctrlProperties = { coord = coord, group = group }
	if otherProperties then
		ctrlProperties = util.extend(otherProperties)(ctrlProperties)
	end
	return { ctrlProperties = ctrlProperties }
end

-- Modification arg that applies a given modification arg to the [[btn]] widget within a skin.
-- The shared screen_button skin is common, though some use screens have their own skin with the same btn child.
function _M.skinButton(buttonModification)
	return { inheritDef = { ["btn"] = buttonModification } }
end

-- Full modification entry for an arbitrary modification.
function _M.modify(filename, path, modification)
	return { filename, path, modification }
end

-- Full modification entry for assigning screen-wide group defs.
function _M.setLayout(filename, layoutGroups, otherProperties)
	local ctrlProperties = { groups = layoutGroups }
	if otherProperties then
		ctrlProperties = util.extend(otherProperties)(ctrlProperties)
	end
	return { filename, { "properties" }, { ctrlProperties = ctrlProperties } }
end


return util.tmerge(util, _M)
