local _M = {}

-- Navigation directions.
_M.UP    = 0
_M.DOWN  = 2
_M.LEFT  = 1
_M.RIGHT = 3

_M.DIR_DBG =
{
	[_M.UP]    = "U",
	[_M.DOWN]  = "D",
	[_M.LEFT]  = "L",
	[_M.RIGHT] = "R",
}

-- Non-directional commands.
_M.CONFIRM = 10
_M.CANCEL  = 11
_M.PPREV   = 12 -- Prev page.
_M.PNEXT   = 13 -- Next page.

_M.CMD_DBG =
{
	[_M.CONFIRM] = "CONFRM",
	[_M.CANCEL]  = "CANCEL",
	[_M.PPREV]   = "P-PREV",
	[_M.PNEXT]   = "P-NEXT",
}

function _M.reverseDir( navDir )
	return (navDir + 2) % 4
end

return _M
