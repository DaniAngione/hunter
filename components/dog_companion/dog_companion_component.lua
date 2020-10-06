local Point3 = _radiant.csg.Point3
local COMPANION_OFFSET = Point3(2, 0, 2)

local DogCompanionComponent = class()

function DogCompanionComponent:initialize()
	self._sv.player_id = radiant.entities.get_player_id(self._entity)
	self._sv._companion = nil
end

function DogCompanionComponent:activate()
	if self._sv._companion then
		return
	end
		
	self:_create_companion(self._sv.player_id)
end

function DogCompanionComponent:_create_companion(player_id)
   self._sv._companion = radiant.entities.create_entity('hunter:dog_companion', { owner = player_id })
	self.__saved_variables:mark_changed()

   self:_make_pet(player_id)
end

function DogCompanionComponent:get_companion()
   return self._sv._companion
end

function DogCompanionComponent:_make_pet(player_id)
	assert(player_id, 'convert_to_pet missing player_id arg')
   local dog_collar = radiant.entities.create_entity('hunter:dog_collar')
   local equipment = self._sv._companion:add_component('stonehearth:equipment')
   equipment:equip_item(dog_collar)
	
   self._sv._companion:add_component('stonehearth:conversation')
   stonehearth.town:get_town(player_id):add_pet(self._sv._companion)

   local pet_component = self._sv._companion:add_component('stonehearth:pet')
   pet_component:set_owner(self._entity)
	
	self:_place_companion_near_owner()
end

function DogCompanionComponent:_place_companion_near_owner()
   local loc = radiant.entities.get_world_location(self._entity)
   local companion_loc = radiant.terrain.get_point_on_terrain(loc - COMPANION_OFFSET)
   radiant.terrain.place_entity_at_exact_location(self._sv._companion, companion_loc)
end

function DogCompanionComponent:destroy()
   if self._sv._companion then 
		local pet_component = self._sv._companion:add_component('stonehearth:pet')
		pet_component:release_pet()
	end
end

return DogCompanionComponent
