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
            event = 'stonehearth:population:irrelevant_amenity'
         end
         self._sighted_listeners[player_id] = radiant.events.listen(population, event, self, self._on_player_new_threat)
      end
   end
end

return HunterMission

