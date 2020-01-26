function getIcons(proto)
	if proto.icons then
		return util.table.deepcopy(proto.icons)
	elseif proto.icon then
		return {
			{
				icon = proto.icon,
				icon_size = proto.icon_size
			}
		}
	else
		return {}
	end
end

local newProtos = {};
local newRecipeUnlocks = {};

for _, entityType in pairs({ "artillery-wagon", "artillery-turret" }) do
	for _, entityBase in pairs(data.raw[entityType]) do

		local baseLocalisedName = entityBase.localised_name or { "entity-name."..entityBase.name }

		local entityManual = util.table.deepcopy(entityBase)
		entityManual.name = entityBase.name.."-manual"
		entityManual.localised_name = { "entity-name."..entityType.."-manual", baseLocalisedName }
		entityManual.localised_description = { "entity-description."..entityType.."-manual", baseLocalisedName }
		entityManual.disable_automatic_firing = true
		entityManual.minable.result = entityManual.name

		table.insert(newProtos, entityManual)

		for _, itemType in pairs({ "item", "item-with-entity-data" }) do
			for _, item in pairs(data.raw[itemType]) do
				if item.place_result == entityBase.name then
					local manualItem = util.table.deepcopy(item)
					manualItem.name = manualItem.name.."-manual"
					manualItem.localised_name = { "item-name."..entityType.."-manual", baseLocalisedName }
					manualItem.localised_description = { "item-description."..entityType.."-manual", baseLocalisedName }
					manualItem.place_result = entityManual.name

					manualItem.icons = getIcons(manualItem)
					table.insert(manualItem.icons, {
						icon = "__base__/graphics/icons/artillery-targeting-remote.png",
						icon_size = 64,
						icon_mipmaps = 4,
						shift = { -8, 8 },
						scale = 0.5 * 0.65,
					})

					table.insert(newProtos, manualItem)
				end
			end
		end

		local toManualRecipe = {
		    type = "recipe",
		    name = entityManual.name,
		    localised_name = { "recipe-name."..entityType.."-manual", baseLocalisedName },
		    localised_description = { "recipe-description."..entityType.."-manual", baseLocalisedName },
		    allow_as_intermediate = false,
			allow_intermediates = false,
			allow_decomposition = false,
			hide_from_stats = true,
		    energy_required = 1,
		    enabled = false,
		    ingredients =
		    {
				{entityBase.name, 1}
		    },
		    result = entityManual.name
		}

		toManualRecipe.icons = getIcons(entityManual)
		table.insert(toManualRecipe.icons, {
			icon = "__base__/graphics/icons/artillery-targeting-remote.png",
			icon_size = 64,
			icon_mipmaps = 4,
			shift = { -8, 8 },
			scale = 0.5 * 0.65,
		})

		local toAutoRecipe = {
		    type = "recipe",
		    name = entityManual.name.."-to-auto",
		    localised_name = { "recipe-name."..entityType.."-manual-to-auto", baseLocalisedName },
		    localised_description = { "recipe-description."..entityType.."-manual-to-auto", baseLocalisedName },
		    allow_as_intermediate = false,
			allow_intermediates = false,
			allow_decomposition = false,
			hide_from_stats = true,
		    energy_required = 1,
		    enabled = false,
		    ingredients =
		    {
				{entityManual.name, 1}
		    },
		    result = entityBase.name
		}

		toAutoRecipe.icons = getIcons(entityManual)
		table.insert(toAutoRecipe.icons, {
			icon = "__core__/graphics/icons/mip/reset-white.png",
			icon_size = 32,
			shift = { 0.5, 0.5 },
			scale = 0.75,
		})

		table.insert(newProtos, toManualRecipe)
		table.insert(newProtos, toAutoRecipe)

		table.insert(
			newRecipeUnlocks,
			toManualRecipe.name
		)

		table.insert(
			newRecipeUnlocks,
			toAutoRecipe.name
		)
	end
end

data:extend(newProtos)

for _, recipe in pairs(newRecipeUnlocks) do
	table.insert(
		data.raw["technology"]["artillery"].effects,
		{ type = "unlock-recipe", recipe = recipe}
	)
end
