local modifications = {
	-- widgets,2 : panel
	{
		"modal-dialog-large.lua",
		{ "widgets", 2, "children", 3 }, -- okBtn
		{ ctrlindex = {1,1} },
	},
	{
		"modal-dialog-large.lua",
		{ "widgets", 2, "children", 4 }, -- cancelBtn
		{ ctrlindex = {1,2} },
	},
	{
		"modal-dialog-large.lua",
		{ "widgets", 2, "children", 6 }, -- auxBtn
		{ ctrlindex = {1,3} },
	},
}

return modifications
