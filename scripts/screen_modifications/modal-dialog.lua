local modifications = {
	-- widgets,2 : panel
	{
		"modal-dialog.lua",
		{ "widgets", 2, "children", 5 }, -- okBtn
		{ ctrlindex = {1,1} },
	},
	{
		"modal-dialog.lua",
		{ "widgets", 2, "children", 6 }, -- cancelBtn
		{ ctrlindex = {1,2} },
	},
	{
		"modal-dialog.lua",
		{ "widgets", 2, "children", 8 }, -- auxBtn
		{ ctrlindex = {1,3} },
	},
}

return modifications
