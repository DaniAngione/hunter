local HunterHuntAnimalDogAction = radiant.class()

HunterHuntAnimalDogAction.name = 'hunt animal dog'
HunterHuntAnimalDogAction.does = 'hunter:hunt_animal'
HunterHuntAnimalDogAction.args = {
   category = 'string',  -- The category for hunting
}
HunterHuntAnimalDogAction.priority = {0.0, 1.0}

local function _hunt_dog_filter_fn(player_id, category, entity)
   if not entity or not entity:is_valid() then
      return false
   end

   if radiant.entities.get_player_id(entity) ~= 'animals' and radiant.entities.get_player_id(entity) ~= 'aggressive_animals' then
      return false
   end
   
   local marked = radiant.entities.has_buff(entity, 'hunter:buffs:hunter_mark')
   if marked ~= true then
      return false
   end

   local task_tracker_component = entity:get_component('stonehearth:task_tracker')
   if not task_tracker_component then
      return false
   end

   return task_tracker_component:is_task_requested(player_id, category, HunterHuntAnimalDogAction.does)
end

function HunterHuntAnimalDogAction:start_thinking(ai, entity, args)
   local work_player_id = radiant.entities.get_work_player_id(entity)
   local category = args.category

   local filter_fn = stonehearth.ai:filter_from_key('hunter:hunt_animal_dog', work_player_id .. ':' .. category, function(item)
         return _hunt_dog_filter_fn(work_player_id, category, item)
      end)
      
   ai:set_think_output({
      hunt_dog_filter_fn = filter_fn,
      owner_player_id = work_player_id,
   })
end

function HunterHuntAnimalDogAction:compose_utility(entity, self_utility, child_utilities, current_activity)
   return self_utility * 0.9 + child_utilities:get('hunter:loop_hunt_animal_dog') * 0.1
end

local ai = stonehearth.ai
return ai:create_compound_action(HunterHuntAnimalDogAction)
         :execute('stonehearth:abort_on_event_triggered', {
            source = ai.ENTITY,
            event_name = 'stonehearth:work_order:job:work_player_id_changed',
         })
         :execute('stonehearth:find_best_reachable_entity_by_type', {
            filter_fn = ai.BACK(2).hunt_dog_filter_fn,
            description = 'finding huntable animal',
            owner_player_id = ai.BACK(2).owner_player_id,
         })
         :execute('stonehearth:abort_on_reconsider_rejected', {
            filter_fn = ai.BACK(3).hunt_dog_filter_fn,
            item = ai.BACK(1).item,
         })
         :execute('stonehearth:set_posture', { posture = 'stonehearth:combat' })
         :execute('hunter:loop_hunt_animal_dog', {
            target = ai.BACK(3).item,
         })
