local mui_defs = include("mui/mui_defs")
local cdefs = include( "client_defs" )
local util = include( "client_util" )
local simquery = include( "sim/simquery" )

local selection = include( "hud/selection" )

function selection:selectPreviousUnit()
	if not self.game:getLocalPlayer() then
        return
    end

	local units = self.game:getLocalPlayer():getUnits()
	if #units > 0 then
		local i0 = (util.indexOf(units, self:getSelectedUnit()) or #units + 1) - 1

		for i = i0 - 1, i0 - #units, -1 do
			local unit = units[(i % #units) + 1]
			if unit:getLocation() and simquery.isAgent( unit ) then
				self:selectUnit( unit )
				MOAIFmodDesigner.playSound( cdefs.SOUND_HUD_GAME_SELECT_UNIT )
				self.game:getCamera():fitOnscreen( self.game:cellToWorld( unit:getLocation()) )
				return
			end
		end
	end
end
