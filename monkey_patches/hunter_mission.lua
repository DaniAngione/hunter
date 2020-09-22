local HunterMission = class()

function HunterMission:_listen_for_sighted()
   local ctx = self._sv.ctx
   local info = self._sv.info
   if not ctx.npc_player_id then
      ctx.npc_player_id = info.npc_player_id
   end
   assert(ctx.npc_player_id, 'no npc_player_id specified for %s', tostring(ctx.encounter_name))

   self._sighted_listeners = {}

   local non_npc_players = stonehearth.player:get_non_npc_players()
   for player_id, player_info in pairs(non_npc_players) do
		if not info.irrelevant_amenity then 
			if not stonehearth.player:are_player_ids_hostile(ctx.npc_player_id, player_id) then 
				return -- don't listen for sighted if players are neutral/friendly
			end
		end
			
      local population = stonehearth.population:get_population(player_id)
      if population then
         local event = 'stonehearth:population:new_threat' -- default
         if info.combat_bulletin then
            event = 'stonehearth:population:engaged_in_combat'
         end
			if info.irrelevant_amenity then
				event = 'stonehearth:population:irrelevant_amenity_threat'
			end
         self._sighted_listeners[player_id] = radiant.events.listen(population, event, self, self._on_player_new_threat)
      end
   end
end

-- Called by individual missions when amenity changes
function HunterMission:suppress_enemy_notification()
   local ctx = self._sv.ctx
	local info = self._sv.info
	if not info.irrelevant_amenity  then 
		if not stonehearth.player:are_player_ids_hostile(ctx.npc_player_id, ctx.player_id) then
			-- if players no longer hostile, make sure enemy notification does not appear
			if self._sighted_listeners then
				self:_destroy_sighted_listeners()
			end
			self:_destroy_bulletins()
		end
	else
		-- if they become hostile again, listen for enemy no
		if not self._sighted_listeners then
			self:_listen_for_sighted()
		end
	end
end

return HunterMission

