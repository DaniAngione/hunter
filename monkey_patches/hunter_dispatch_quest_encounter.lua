local game_master_lib = require 'stonehearth.lib.game_master.game_master_lib'
local Entity = _radiant.om.Entity

local HunterDispatchQuest = class()

function HunterDispatchQuest:restore()
   if self._sv.dispatched_citizen then
      self._sv.dispatched_citizens = { self._sv.dispatched_citizen }
   end

   for _, citizen in pairs(self._sv.dispatched_citizens) do
      local town = stonehearth.town:get_town(self._sv.ctx.player_id)
		local pets = {}
		if citizen:get_component('stonehearth:pet_owner') then 
			pets = citizen:get_component('stonehearth:pet_owner'):get_pets()
		end
      local location = radiant.terrain.find_placement_point(town:get_landing_location(), 0, 20)
      radiant.terrain.place_entity(citizen, location)
      town:dispatch_citizen(citizen)
		
		if pets ~= {} then 
			for _, pet in ipairs(pets) do
				radiant.terrain.place_entity(pet, location)
			end
			town:_suspend_animals(pets)
		end
   end
   
   if self._sv.bulletin then
      self._sv.bulletin_data = self._sv._info
      self._sv.bulletin_data.on_try_dispatch = '_on_try_dispatch'
      self._sv.bulletin_data.on_abandon = '_on_abandon'
      self._sv.bulletin:set_data(self._sv.bulletin_data)
   end
end

function HunterDispatchQuest:_on_try_dispatch(session, request, citizens)
   if #citizens ~= #self._sv._info.requirements then
      return
   end
 
	local pets = {} 
   local remaining_requirements = radiant.shallow_copy(self._sv._info.requirements)
   for i, citizen in ipairs(citizens) do
      local matched = false
      for j, req in ipairs(remaining_requirements) do
         if self:_check_requirements(citizen, req) then
            table.remove(remaining_requirements, j)
            matched = true
				if citizen:get_component('stonehearth:pet_owner') then
					pets = citizen:get_component('stonehearth:pet_owner'):get_pets()
				end
            break
         end
      end
      if not matched then
         return
      end
   end
	
	local town = stonehearth.town:get_town(self._sv.ctx.player_id)
	
   self:_dispatch_citizens(citizens)
	if pets ~= {} then 
		town:_suspend_animals(pets)
	end
   self:_destroy_bulletin()

   self.__saved_variables:mark_changed()
end

function HunterDispatchQuest:_return_citizens()
   local town = stonehearth.town:get_town(self._sv.ctx.player_id)
   for _, citizen in pairs(self._sv.dispatched_citizens) do
      town:return_citizen(citizen)
      self:_play_poof_for(citizen)
		
		local pets = {}
		if citizen:get_component('stonehearth:pet_owner') then
			pets = citizen:get_component('stonehearth:pet_owner'):get_pets()
		end
		
		if pets ~= {} then 
			town:_continue_animals(pets)
		end

      if self._sv._info.buff_on_return then
         radiant.entities.add_buff(citizen, self._sv._info.buff_on_return)
      end

      if self._sv._info.thought_on_return then
          radiant.entities.add_thought(citizen, self._sv._info.thought_on_return)
       end

      if self._sv._info.xp_gained then
         local job = citizen:get_component('stonehearth:job')
         if job then
            job:add_exp(self._sv._info.xp_gained, false)
         end
      end
     
   end

   -- Clean up
   self._sv.dispatched_citizens = {}
   if self._sv._return_timer then
      self._sv._return_timer:destroy()
      self._sv._return_timer = nil
   end
end

return HunterDispatchQuest