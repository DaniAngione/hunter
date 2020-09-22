local HunterPopulationFaction = class()

function HunterPopulationFaction:_get_threat_level(visitor, visitor_id)
   local is_hostile 
	local is_friendly
	local visitor_player_id = radiant.entities.get_player_id(visitor)	

   if self._entity_hostility and self._entity_hostility[visitor_id] ~= nil then
      is_hostile = self._entity_hostility[visitor_id]
   else
      is_hostile = stonehearth.player:are_player_ids_hostile(self._sv.player_id, visitor_player_id)
      self._entity_hostility[visitor_id] = is_hostile
	end
	if stonehearth.player:are_player_ids_friendly(self._sv.player_id, visitor_player_id) then
		is_friendly = true
	end
   if is_hostile then
      return radiant.entities.get_attribute(visitor, 'menace', 0.1)  -- Even if non-menacing, worth notifying
   elseif is_friendly then
		return -0.1
	end
   return 0
end

function HunterPopulationFaction:_on_seen_by(spotter_id, visitor_id, visitor)
   if not visitor or not visitor:is_valid() then
      -- visitor is already destroyed
      return
   end
	
   local threat_level = self:_get_threat_level(visitor, visitor_id)
   if threat_level < 0 then
       -- not interesting.  move along!
      return
	elseif threat_level == 0 then
			radiant.events.trigger_async(self, 'stonehearth:population:irrelevant_amenity_threat', {
					entity_id = visitor_id,
					entity = visitor,
				});
   end

   local entry = self._global_vision[visitor_id]
   if not entry then
      entry = {
         seen_by = { [spotter_id] = true },
         threat_level = threat_level,
         entity = visitor,
      }
      self._global_vision[visitor_id] = entry

      self:_update_threat_level()

      radiant.events.trigger_async(self, 'stonehearth:population:new_threat', {
            entity_id = visitor_id,
            entity = visitor,
         });
   end
   entry.seen_by[spotter_id] = true
end

return HunterPopulationFaction
