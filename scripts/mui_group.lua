--
-- 'group' elements at the top of a skin can have an inheritDefs property to override properties on their children.
-- Notably, this allows specifying properties on a skin reference that will apply to the inner elements after the skin is resolved.
--
-- inheritDefs is a table with (key = child name) and (value = override table). Overrides are applied as a shallow replacement.
--

local util = require( "modules/util" )
local mui_binder = require("mui/mui_binder")
local mui_defs = require( "mui/mui_defs" )
local mui_container = require( "mui/widgets/mui_container" )
local mui_group = require( "mui/widgets/mui_group" )
local mui_widget = require( "mui/widgets/mui_widget" )


-- Overwrite mui_group:init
-- Add inheritDef handling when creating child widgets.
function mui_group:init( screen, def )
	mui_widget.init( self, def )

	self._cont = mui_container( def )
	self._children = {}
	
	for i,childdef in ipairs(def.children) do
		if def.inheritDef and def.inheritDef[childdef.name] then
			childdef = util.inherit(childdef)(def.inheritDef[childdef.name])
		end

		local child = screen:createWidget( childdef )
		self:addChild( child )
	end

	self.binder = mui_binder.create( self )
end
