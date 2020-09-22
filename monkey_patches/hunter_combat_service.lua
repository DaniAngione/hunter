local Point3 = _radiant.csg.Point3
local rng = _radiant.math.get_default_rng()
local log = radiant.log.create_logger('combat')
local CombatService = require 'stonehearth.services.server.combat.combat_service'

-- Compatibility with ACE
local AceCombatService = require 'stonehearth_ace.monkey_patches.ace_combat_service'

HunterCombatService = class()

if AceCombatService then
	HunterCombatService._hunter_old__on_target_killed = AceCombatService._on_target_killed
else
	HunterCombatService._hunter_old__on_target_killed = CombatService._on_target_killed
end
function HunterCombatService:_on_target_killed(attacker, target)
   self:distribute_hunter_exp(attacker, target)
   self:_hunter_old__on_target_killed(attacker, target)
end

function HunterCombatService:distribute_hunter_exp(attacker, target)

   if stonehearth.player:is_npc(attacker) then
      -- no exp for npc players
      return
   end
	
	if attacker:get_component('stonehearth:job'):get_job_uri() ~= 'hunter:jobs:hunter' then
		return
	elseif attacker:get_component('stonehearth:job'):is_max_level() then
		return
	end

   local attacker_player_id = radiant.entities.get_player_id(attacker)
   local target_player_id = radiant.entities.get_player_id(target)

	if target_player_id == 'animals' or target_player_id == 'aggressive_animals' then
		local attributes_component = target:get_component('stonehearth:attributes')
		local max_health = attributes_component:get_attribute('max_health')
		local experience = 0
		
		if max_health then
			experience = math.max(5, math.min(math.floor(max_health / 3), 60))
			attacker:get_component('stonehearth:job'):add_exp(experience)
		end
	else
		return
   end
end

--[[function HunterCombatService:_handle_loot_drop(attacker, target)
   local is_attacker_npc = stonehearth.player:is_npc(attacker)
   local is_target_npc = stonehearth.player:is_npc(target)
   if is_attacker_npc and is_target_npc then
      target:remove_component('stonehearth:loot_drops')
   elseif not is_attacker_npc then
      local loot_drops_component = target:get_component('stonehearth:loot_drops')
      if loot_drops_component then
         local player_id = radiant.entities.get_player_id(attacker)
         loot_drops_component:set_auto_loot_player_id(player_id)
      end
   end
end]]--

-- Modify this function from ACE for compatibility:
function HunterCombatService:_record_kill_stats(attacker, target, units)
   local enemy_player = radiant.entities.get_player_id(target)

   if enemy_player and enemy_player ~= '' then   
      local catalog_data = stonehearth.catalog:get_catalog_data(target:get_uri())
      local enemy_category = catalog_data and catalog_data.category
      local enemy_specifier = radiant.entities.get_property_value(target, 'stats_specifier')

      for _, unit in pairs(units) do
         local stance = self:get_stance(unit)
         if stance == 'defensive' or stance == 'aggressive' or attacker:get_component('stonehearth:job'):get_job_uri() == 'hunter:jobs:hunter' then
            self:_record_kill_stats_for_entity(unit, unit == attacker and 'kills' or 'assists', enemy_player, enemy_category, enemy_specifier, true)
         end
      end
      self:_record_notable_kill_for_entity(attacker, target)

      local equipment = attacker:get_component('stonehearth:equipment')
      if equipment then
         for _, piece in pairs(equipment:get_all_items()) do
            self:_record_kill_stats_for_entity(piece, 'kills', enemy_player, enemy_category, enemy_specifier, true)
            self:_record_notable_kill_for_entity(piece, target)
         end
      end
   end
end

return HunterCombatService
