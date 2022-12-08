local function earlyInit(modApi)
	modApi.requirements =
	{
	}
end

local function initStrings(modApi)
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()

	-- local MOD_STRINGS = include( scriptPath .. "/strings" )
	-- modApi:addStrings( dataPath, "QEDCTRL", MOD_STRINGS)
end

local function init(modApi)
	local scriptPath = modApi:getScriptPath()
	-- Store script path for cross-file includes
	rawset(_G,"SCRIPT_PATHS",rawget(_G,"SCRIPT_PATHS") or {})
	SCRIPT_PATHS.qedctrl = scriptPath

	-- client overrides
	include(scriptPath.."/input-manager")

	include(scriptPath.."/mui_button")
	include(scriptPath.."/mui_padctrl")
	include(scriptPath.."/mui_screen")

	-- sim overrides
end

local function earlyUnload(modApi)
end

local function earlyLoad(modApi, options, params)
	earlyUnload(modApi)
end

local function load(modApi, options, params)
	local scriptPath = modApi:getScriptPath()

	modApi:modifyUIElements(include(scriptPath.."/screen_modifications/main-menu"))
	modApi:modifyUIElements(include(scriptPath.."/screen_modifications/modal-dialog"))
end

return {
	earlyInit = earlyInit,
	earlyLoad = earlyLoad,
	earlyUnload = earlyUnload,
	load = load,
	init = init,
	initStrings = initStrings,
}
