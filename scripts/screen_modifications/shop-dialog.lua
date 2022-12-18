local sutil = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local ctrlID = sutil.ctrlID

local function skinAgentItem(modification)
	return { inheritDef = { ["item"] = sutil.skinButton(modification), }, }
end
local function skinShopItem(modification)
	return { inheritDef = { ["icon"] = sutil.skinButton(modification), }, }
end

local function skinInventoryRow(baseID)
	return {
		inheritDef =
		{
			["item1"] = skinAgentItem(ctrlID(baseID..".item1")),
			["item2"] = skinAgentItem(ctrlID(baseID..".item2")),
			["item3"] = skinAgentItem(ctrlID(baseID..".item3")),
			["item4"] = skinAgentItem(ctrlID(baseID..".item4")),
			["item5"] = skinAgentItem(ctrlID(baseID..".item5")),
			["item6"] = skinAgentItem(ctrlID(baseID..".item6")),
			["item7"] = skinAgentItem(ctrlID(baseID..".item7")),
			["item8"] = skinAgentItem(ctrlID(baseID..".item8")),
		},
	}
end

local function modifyWidget(widgetIndex, modification)
	assert(type(modification) == "table", type(modification))
	return {
		"shop-dialog.lua",
		{ "widgets", widgetIndex },
		modification,
	}
end
local function modifySubWidget(widgetIndex, childIndex, modification)
	assert(type(modification) == "table", type(modification))
	return {
		"shop-dialog.lua",
		{ "widgets", widgetIndex, "children", childIndex },
		modification,
	}
end
local function modifySubSubWidget(widgetIndex, cid1, cid2, modification)
	assert(type(modification) == "table", type(modification))
	return {
		"shop-dialog.lua",
		{ "widgets", widgetIndex, "children", cid1, "children", cid2 },
		modification,
	}
end

local modifications = {
	-- Inventory rows.
	modifyWidget(9, skinInventoryRow("upperInv")), -- "sell"
	modifyWidget(10, skinInventoryRow("lowerInv")), -- "inventory"

	-- Shop items. (nanofab only)
	modifySubSubWidget(11, 3, 1, skinShopItem(ctrlID("shop.aug1"))),
	modifySubSubWidget(11, 3, 2, skinShopItem(ctrlID("shop.aug2"))),
	modifySubSubWidget(11, 3, 3, skinShopItem(ctrlID("shop.aug3"))),
	modifySubSubWidget(11, 3, 4, skinShopItem(ctrlID("shop.aug4"))),
	modifySubSubWidget(11, 4, 1, skinShopItem(ctrlID("shop.weap1"))),
	modifySubSubWidget(11, 4, 2, skinShopItem(ctrlID("shop.weap2"))),
	modifySubSubWidget(11, 4, 3, skinShopItem(ctrlID("shop.weap3"))),
	modifySubSubWidget(11, 4, 4, skinShopItem(ctrlID("shop.weap4"))),
	modifySubSubWidget(11, 5, 1, skinShopItem(ctrlID("shop.item1"))),
	modifySubSubWidget(11, 5, 2, skinShopItem(ctrlID("shop.item2"))),
	modifySubSubWidget(11, 5, 3, skinShopItem(ctrlID("shop.item3"))),
	modifySubSubWidget(11, 5, 4, skinShopItem(ctrlID("shop.item4"))),
	modifySubSubWidget(11, 5, 5, skinShopItem(ctrlID("shop.item5"))),
	modifySubSubWidget(11, 5, 6, skinShopItem(ctrlID("shop.item6"))),
	modifySubSubWidget(11, 5, 7, skinShopItem(ctrlID("shop.item7"))),
	modifySubSubWidget(11, 5, 8, skinShopItem(ctrlID("shop.item8"))),

	-- Inventory background.
	-- (non-nanofabs: loot/transfer, server terminals, research consoles, etc)
	modifySubWidget(5, 1, ctrlID("inventory.closeBtn")),
	-- Shop background.
	-- (nanofabs)
	modifySubWidget(6, 2, ctrlID("shop.buybackBtn")),
	modifySubWidget(6, 1, ctrlID("shop.closeBtn")),

	sutil.setSingleLayout("shop-dialog.lua",
		{
			{
				id = "inventory", coord = 1,
				shape = [[rgrid]], w = 8, h = 2,
				children = sutil.concat(
					sutil.widgetRow(1, "upperInv.item1", "upperInv.item2", "upperInv.item3", "upperInv.item4",
							"upperInv.item5", "upperInv.item6", "upperInv.item7", "upperInv.item8"),
					sutil.widgetRow(2, "lowerInv.item1", "lowerInv.item2", "lowerInv.item3", "lowerInv.item4",
							"lowerInv.item5", "lowerInv.item6", "lowerInv.item7", "lowerInv.item8"),
				nil),
				recallOrthogonalX = true,
			},
			{
				id = "shopgrid", coord = 2,
				shape = [[cgrid]], w = 4, h = 4,
				children = sutil.concat(
					sutil.widgetCol(1, "shop.aug1", "shop.aug2", "shop.aug3", "shop.aug4"),
					sutil.widgetCol(2, "shop.weap1", "shop.weap2", "shop.weap3", "shop.weap4"),
					sutil.widgetCol(3, "shop.item1", "shop.item2", "shop.item3", "shop.item4"),
					sutil.widgetCol(4, "shop.item5", "shop.item6", "shop.item7", "shop.item8"),
				nil),
				recallOrthogonalX = true,
			},
			{
				id = "bottom", coord = 3,
				shape = [[hlist]],
				children = sutil.widgetList(
						"shop.buyBackBtn", "shop.closeBtn", "inventory.closeBtn"),
				defaultReverse = true,
			},
		},
	nil),
}

return modifications

