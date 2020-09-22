local Entity = _radiant.om.Entity

local HunterLoopHuntAnimalMelee = radiant.class()

HunterLoopHuntAnimalMelee.name = 'keep hunting this animal'
HunterLoopHuntAnimalMelee.does = 'hunter:loop_hunt_animal'
HunterLoopHuntAnimalMelee.args = {
   target = Entity,                  -- the animal to hunt
}
HunterLoopHuntAnimalMelee.priority = 0.5

local ai = stonehearth.ai
return ai:create_compound_action(HunterLoopHuntAnimalMelee)
      :execute('stonehearth:combat:get_melee_range', {
         target = ai.ARGS.target,
      })
      :loop({
         name = 'hunt animal',
         break_timeout = 2000,
         break_condition = function(ai, entity, args)
            return not radiant.entities.exists(args.target)
         end
      })
         :execute('stonehearth:chase_entity', {
            target = ai.UP.ARGS.target,
            stop_distance = ai.UP.BACK(1).melee_range_ideal,
         })
         :execute('stonehearth:combat:attack_melee_adjacent', { target = ai.UP.ARGS.target })
         :execute('stonehearth:combat:set_global_attack_cooldown')
      :end_loop()
