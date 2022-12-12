local _M = {}

_M.DEFAULT_LAYOUT = "root"

-- Navigation directions.
_M.UP = 0
_M.DOWN = 2
_M.LEFT = 1
_M.RIGHT = 3

_M.DIR_DBG = {
	[_M.UP] = "U",
	[_M.DOWN] = "D",
	[_M.LEFT] = "L",
	[_M.RIGHT] = "R",
}

function _M.reverseDir( navDir )
	return (navDir + 2) % 4
end

return _M
