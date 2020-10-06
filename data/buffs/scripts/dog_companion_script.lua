local DogCompanionScript = class()

function DogCompanionScript:on_buff_added(entity, buff)
	entity:add_component('hunter:dog_companion')
end

function DogCompanionScript:on_buff_removed(entity, buff)
   entity:remove_component('hunter:dog_companion')
end

return DogCompanionScript
