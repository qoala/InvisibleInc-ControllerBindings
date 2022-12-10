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

	include(scriptPath.."/input-manager")

	include(scriptPath.."/mui/mui_button")
	include(scriptPath.."/mui/mui_group")
	include(scriptPath.."/mui/mui_listbox")
	include(scriptPath.."/mui/mui_screen")

	include(scriptPath.."/controllers/hud")
	include(scriptPath.."/controllers/saveslots-dialog")
end

local function earlyUnload(modApi)
end

local function earlyLoad(modApi, options, params)
	earlyUnload(modApi)
end

local function unload( modApi )
	local scriptPath = modApi:getScriptPath()

	modApi:addNewUIScreen("qedctrl-end-turn-dialog.lua", scriptPath.."/screens/qedctrl-end-turn-dialog")
	modApi:insertUIElements(include(scriptPath.."/screen_inserts/hud"))

	modApi:modifyUIElements(include(scriptPath.."/screen_modifications/main-menu"))
	modApi:modifyUIElements(include(scriptPath.."/screen_modifications/modal-monst3r"))
	modApi:modifyUIElements(include(scriptPath.."/screen_modifications/modal-saveslots"))
	modApi:modifyUIElements(include(scriptPath.."/screen_modifications/modals"))
	modApi:modifyUIElements(include(scriptPath.."/screen_modifications/pause-dialog"))
	-- TODO: modal-logs: listbox, nonlinear button arrangement.
	-- TODO: modal-tutorials: buttons for internal pages all start visible, but all but the first are occluded.
end

local function load(modApi, options, params)
	unload( modApi )
end

return {
	earlyInit = earlyInit,
	earlyLoad = earlyLoad,
	earlyUnload = earlyUnload,
	load = load,
	unload = unload,
	init = init,
	initStrings = initStrings,
}
