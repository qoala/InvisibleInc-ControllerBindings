local function assignCtrlIndex(widgetIndex, ctrlindex)
	return {
		"main-menu.lua",
		{ "widgets", widgetIndex },
		{ ctrlindex = ctrlindex },
	}
end

local modifications = {
	assignCtrlIndex(9,  {1,1}), -- playBtn
	assignCtrlIndex(13, {1,2}), -- optionsBtn
	assignCtrlIndex(12, {1,3}), -- creditsBtn
	assignCtrlIndex(11, {1,4}), -- exitBtn
	assignCtrlIndex(10, {1,5}), -- signUpBtn
}

return modifications
