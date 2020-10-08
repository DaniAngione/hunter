local BaseJob = require 'stonehearth.jobs.base_job'

local HUNTER_RECIPES = radiant.resources.load_json('hunter:jobs:hunter:recipes')

local HunterClass = class()
radiant.mixin(HunterClass, BaseJob)

function HunterClass:unlock_hunting_camp(args)
   local player_id = radiant.entities.get_player_id(self._sv._entity)

   local recipes = HUNTER_RECIPES[stonehearth.population:get_population(player_id):get_kingdom()] or HUNTER_RECIPES['stonehearth:kingdoms:ascendancy']
   for job, recipe_keys in pairs(recipes) do
      local job_info = stonehearth.job:get_job_info(player_id, job)
      for recipe_key, value in pairs(recipe_keys) do
         if value then
            job_info:manually_unlock_recipe(recipe_key)
         end
      end
   end
end

function HunterClass:should_tame(target)
	return false
end

return HunterClass