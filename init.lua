if minetest.get_current_modname() ~= "legendary_items" then
   error("mod directory must be named 'legendary_items'");
end

dofile(minetest.get_modpath("legendary_items") .. "/itemsound.lua")

minetest.register_tool("legendary_items:sword_scorn", {
	description = "Scorn of the Hell God Cron",
	inventory_image = "scorn_of_the_hell_god.png",
	tool_capabilities = {
		full_punch_interval = 0.6,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.0, [2]=1.00, [3]=0.35}, uses=4, maxlevel=3},
		},
		damage_groups = {fleshy=18},
	},
	sounds = {
	node = "blade_strike_surface",
	player = "blade_strike_flesh",
   },
})
--[[
minetest.register_tool("legendary_items:sword_scorn", {
	description = "Scorn of the Hell God Cron",
	inventory_image = "scorn_of_the_hell_god.png",
	tool_capabilities = {
		full_punch_interval = 0.6,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.0, [2]=1.00, [3]=0.35}, uses=4, maxlevel=3},
		},
		damage_groups = {fleshy=10},
	},
	on_use = function(itemstack, user, pointed_thing)
	if pointed_thing.type == "object" then
		minetest.sound_play("blade_strike_flesh", { pos = minetest.get_pointed_thing_position(pointed_thing, above), max_hear_distance = 10 })
	elseif pointed_thing.type == "node" then
		minetest.sound_play("blade_strike_surface", { pos = minetest.get_pointed_thing_position(pointed_thing, above), max_hear_distance = 10 })
	elseif pointed_thing.type == "nothing" then
		minetest.sound_play("blade_strike", { pos = user:getpos(), max_hear_distance = 10 })
	else
		minetest.debug("Player struck something that is somehow not an object, node, nor air.")
	end
end
})
]]
minetest.register_tool("legendary_items:pick_enduro", {
	description = "Enduro Pickaxe",
	inventory_image = "enduro_pick.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=1000, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
})

minetest.register_tool("legendary_items:shovel_enduro", {
	description = "Enduro Shovel",
	inventory_image = "enduro_shovel.png",
	wield_image = "enduro_shovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=1000, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	},
})

minetest.register_tool("legendary_items:axe_enduro", {
	description = "Enduro Axe",
	inventory_image = "enduro_axe.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=1000, maxlevel=2},
		},
		damage_groups = {fleshy=7},
	},
})



minetest.register_tool("legendary_items:sword_enduro", {
	description = "Enduro Sword",
	inventory_image = "enduro_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 1,
		groupcaps = {
			snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=1000, maxlevel=3},
		},
		damage_groups = {fleshy=8},
	}
})

-- Hoe API section from default "farming" mod.

hoe_on_use = function(itemstack, user, pointed_thing, uses)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end
	
	local under = minetest.get_node(pt.under)
	local p = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
	local above = minetest.get_node(p)
	
	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end
	
	-- check if the node above the pointed thing is air
	if above.name ~= "air" then
		return
	end
	
	-- check if pointing at soil
	if minetest.get_item_group(under.name, "soil") ~= 1 then
		return
	end
	
	-- check if (wet) soil defined
	local regN = minetest.registered_nodes
	if regN[under.name].soil == nil or regN[under.name].soil.wet == nil or regN[under.name].soil.dry == nil then
		return
	end
	
	if minetest.is_protected(pt.under, user:get_player_name()) then
		minetest.record_protection_violation(pt.under, user:get_player_name())
		return
	end
	if minetest.is_protected(pt.above, user:get_player_name()) then
		minetest.record_protection_violation(pt.above, user:get_player_name())
		return
	end

	
	-- turn the node into soil, wear out item and play sound
	minetest.set_node(pt.under, {name = regN[under.name].soil.dry})
	minetest.sound_play("default_dig_crumbly", {
		pos = pt.under,
		gain = 0.5,
	})
	
	if not minetest.setting_getbool("creative_mode") then
		itemstack:add_wear(65535/(uses-1))
	end
	return itemstack
end

register_hoe = function(name, def)
	-- Check for : prefix (register new hoes in your mod's namespace)
	if name:sub(1,1) ~= ":" then
		name = ":" .. name
	end
	-- Check def table
	if def.description == nil then
		def.description = "Hoe"
	end
	if def.inventory_image == nil then
		def.inventory_image = "unknown_item.png"
	end
	if def.recipe == nil then
		def.recipe = {
			{"air","air",""},
			{"","group:stick",""},
			{"","group:stick",""}
		}
	end
	if def.max_uses == nil then
		def.max_uses = 30
	end
	minetest.register_tool(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		on_use = function(itemstack, user, pointed_thing)
			return farming.hoe_on_use(itemstack, user, pointed_thing, def.max_uses)
		end
	})
end

-- End hoe API.

register_hoe("legendary_items:hoe_enduro", {
	description = "Enduro Hoe",
	inventory_image = "enduro_hoe.png",
	max_uses = 1000,
	--material = "default:diamond"
	on_use = function(itemstack, user, pointed_thing)
			return farming.hoe_on_use(itemstack, user, pointed_thing, def.max_uses)
		end
})

minetest.register_tool("legendary_items:pimp_cane", {
	description = "Pimp Cane",
	inventory_image = "pimp_cane.png",
})

local SERPENT_TIPS = {"Act on that impulse before time grows weary.",
"Just do it, do not concern yourself with those who condemn your actions.",
"Work with me and we can accomplish feats of great recognition.",
"Disappointment is inevitable. But to become discouraged, that is a choice you make.",
"Never can true reconcilement grow where wounds of deadly hate have pierced so deep.",
"Your successes are the greatest when you appear with my mark on your soul.",
"Nothing in life has any permanence. Only by letting go can you have what is truly real.",
"In everyone's heart there is a devil, but we do not know the vile until the devil is roused.",
"If you scratch some saints, you will find true malice.",
"You may not wield much power... except when in darkness.",
"The world is all the richer for having us in it, so long as we keep our feet upon its neck.",
"The only certainty in this universe is death.",
"Do not be afraid to take seat in another man's throne.",
"Do not shut out the thoughts that make your soul tremble, embracing them gives us power."}

minetest.register_tool("legendary_items:serpent_eye", {
	description = "The Serpent's Eye",
	inventory_image = "serpent_eye.png",
	wield_scale = {x=0.6,y=0.6,z=0.5},
	on_use = function(itemstack, user, pointed_thing)
	minetest.sound_play("mysterious_snake", { to_player = user:get_player_name(), gain = 0.5 })
	minetest.after(1, function()
		minetest.chat_send_player(user:get_player_name(), "Serpent: ".. SERPENT_TIPS[math.random(1, #SERPENT_TIPS)])
	end)
	end
})

local lpp = 14 -- Lines per book's page
local function book_on_use(itemstack, user)
	local player_name = user:get_player_name()
	local data = minetest.deserialize(itemstack:get_metadata())
	local formspec, title, text, owner = "", "", "", player_name
	local page, page_max, lines, string = 1, 1, {}, "Page text."

	if data then
		title = data.title
		text = data.text
		owner = data.owner

		for str in (text .. "\n"):gmatch("([^\n]*)[\n]") do
			lines[#lines+1] = str
		end

		if data.page then
			page = data.page
			page_max = data.page_max

			for i = ((lpp * page) - lpp) + 1, lpp * page do
				if not lines[i] then break end
				string = string .. lines[i] .. "\n"
			end
		end
	end
--[[
	if owner == player_name then
		formspec = "size[8,8]" .. default.gui_bg ..
			default.gui_bg_img ..
			"field[0.5,1;7.5,0;title;Title:;" ..
				minetest.formspec_escape(title) .. "]" ..
			"textarea[0.5,1.5;7.5,7;text;Contents:;" ..
				minetest.formspec_escape(text) .. "]" ..
			"button_exit[2.5,7.5;3,1;save;Save]"
	else]]
		formspec = "size[8,8]" .. default.gui_bg ..
			default.gui_bg_img ..
			"label[0.5,0.5;The Book of the Dead]" ..
			"tablecolumns[color;text]" ..
			"tableoptions[background=#00000000;highlight=#00000000;border=false]" ..
			"table[0.4,0;7,0.5;title;#FFFF00," .. minetest.formspec_escape(title) .. "]" ..
			"textarea[0.5,1.5;7.5,7;;" ..
				minetest.formspec_escape(string ~= "" and string or text) .. ";]" ..
			"button[2.4,7.6;0.8,0.8;book_prev;<]" ..
			"label[3.2,7.7;Page " .. page .. " of " .. page_max .. "]" ..
			"button[4.9,7.6;0.8,0.8;book_next;>]"
	--end

	minetest.show_formspec(player_name, "legendary_items:book_of_the_dead", formspec)
end

minetest.register_craftitem("legendary_items:book_of_the_dead", {
	description = "The Book of the Dead",
	inventory_image = "default_book_written.png",
	groups = {book = 1,},
	stack_max = 1,
	on_use = book_on_use,
})
