-- Layouts with all children in a single line.

local ctrl_defs = include(SCRIPT_PATHS.qedctrl.."/ctrl_defs")
local base_layout = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/base_layout")


local list_layout = class(base_layout)
do
	function list_layout:init( def, ... )
		list_layout._base.init(self, def, ...)

		self._children = {}
		assert(type(self._def.children) == "table", "[QEDCTRL] Missing children for list layout "..self._debugName)
		local ctrl_layouts = include(SCRIPT_PATHS.qedctrl.."/mui/ctrl_layouts")
		for i, childDef in ipairs(self._def.children) do
			assert(type(childDef.coord) == "number", "[QEDCTRL] Invalid coord "..tostring(childDef.coord).." for child "..tostring(self._debugName).."/"..(childDef.id or i))

			local child = ctrl_layouts.createLayoutNode(childDef, self._debugName, i, childDef.coord)
			if child then
				child.parentIdx = childDef.coord
				table.insert(self._children, child)
			end
		end
		table.sort(self._children, function(a, b) return a.parentIdx < b.parentIdx end)
	end

	function list_layout:isEmpty()
		return self._children[1] == nil
	end

	function list_layout:onActivate( ... )
		list_layout._base.onActivate(self, ...)
		self._focusIdx = nil
		for i,child in ipairs(self._children) do
			child:onActivate(...)
		end
	end
	function list_layout:onDeactivate( ... )
		for _,child in ipairs(self._children) do
			child:onDeactivate(...)
		end
		self._focusIdx = nil
		list_layout._base.onDeactivate(self, ...)
	end

	function list_layout:_findChild( childID )
		for i, child in ipairs(self._children) do
			if child:getID() == childID then
				return child, i
			end
		end
	end

	function list_layout:canFocus()
		for _,child in ipairs(self._children) do
			if child:canFocus() then return true end
		end
	end

	function list_layout:_doFocus(options, child, idx, ...)
		local ok = child and child:onFocus(options, ...)
		if ok or options.force then
			self._focusChild = ok and child or nil
			self._focusIdx = idx
			return true
		end
	end
	function list_layout:onFocus(options, childID, ...)
		options = options or {}
		if childID then
			local child, idx = self:_findChild(childID)
			local ok = child and self:_doFocus(options, child, idx, ...)
			if not ok and idx and options.dir and options.continue then
				return self:onNav(options.dir, idx)
			end
			return ok
		elseif (options.recall or self._def.alwaysRecall) and self._focusIdx then
			local child = self._children[self._focusIdx]
			if child and self:_doFocus(options, child, self._focusIdx, ...) then
				return true
			end
		end
		if options.dir == self.PREV_DIR then
			return self:_doFocus(options, self:_getOrPrev(#self._children))
		elseif options.dir == self.NEXT_DIR then
			return self:_doFocus(options, self:_getOrNext(1))
		end
		return self:_doFocus(options, self:_defaultChild())
	end
	function list_layout:_defaultChild()
		if self:isEmpty() then return end

		if self._def.default then
			local child, idx = self:_findChild(self._def.default)
			if child and child:canFocus() then
				return child, idx
			end
		end
		if self._def.defaultChain then
			for _,default in ipairs(self._def.defaultChain) do
				local child, idx = self:_findChild(default)
				if child and child:canFocus() then
					return child, idx
				end
			end
		end
		if self._def.defaultReverse then
			return self:_getOrPrev(#self._children)
		else
			return self:_getOrNext(1)
		end
	end

	function list_layout:_getOrPrev( i0 )
		local i = i0
		while i >= 1 do
			local child = self._children[i]
			if child:canFocus() then
				return child, i
			end
			i = i - 1
		end
	end
	function list_layout:_getOrNext( i0 )
		local i = i0
		local size = #self._children
		while i <= size do
			local child = self._children[i]
			if child:canFocus() then
				return child, i
			end
			i = i + 1
		end
	end
	function list_layout:_onInternalNav( navDir, idx )
		idx = idx or self._focusIdx
		local child
		if navDir == self.PREV_DIR and idx and idx > 1 then
			child, idx = self:_getOrPrev(idx - 1)
		elseif navDir == self.NEXT_DIR and idx and idx < #self._children then
			child, idx = self:_getOrNext(idx + 1)
		end
		if child then
			return self:_doFocus({dir=navDir}, child, idx)
		end
	end
end

local vlist_layout = class(list_layout)
vlist_layout._SHAPE = "VLIST"
vlist_layout.PREV_DIR = ctrl_defs.UP
vlist_layout.NEXT_DIR = ctrl_defs.DOWN

local hlist_layout = class(list_layout)
hlist_layout._SHAPE = "HLIST"
hlist_layout.PREV_DIR = ctrl_defs.LEFT
hlist_layout.NEXT_DIR = ctrl_defs.RIGHT

return {
	list_layout = list_layout,
	vlist_layout = vlist_layout,
	hlist_layout = hlist_layout,
}
