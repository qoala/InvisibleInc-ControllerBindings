local camhandler = include( "gameplay/camhandler" )

local oldOnUpdate = camhandler.onUpdate
function camhandler:onUpdate( ... )
	inputmgr.hideArrowKeys(true)
	oldOnUpdate(self, ...)
	inputmgr.hideArrowKeys(false)
end
