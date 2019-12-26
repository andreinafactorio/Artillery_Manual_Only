function makeSureRecipesEnabled()
	for _, force in pairs(game.forces) do
		if force.technologies["artillery"].researched then
			for _, effect in pairs(force.technologies["artillery"].effects) do
				if effect.type == "unlock-recipe" then
					force.recipes[effect.recipe].enabled = true
				end
			end
		end
    end
end

script.on_init(makeSureRecipesEnabled)
script.on_configuration_changed(makeSureRecipesEnabled)
