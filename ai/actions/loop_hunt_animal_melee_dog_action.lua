local Entity = _radiant.om.Entity

local HunterLoopHuntAnimalMeleeDog = radiant.class()

HunterLoopHuntAnimalMeleeDog.name = 'keep hunting this animal dog'
HunterLoopHuntAnimalMeleeDog.does = 'hunter:loop_hunt_animal_dog'
HunterLoopHuntAnimalMeleeDog.args = {
   target = Entity,                  -- the animal to hunt
}
HunterLoopHuntAnimalMeleeDog.priority = 0.5

local ai = stonehearth.ai
return ai:create_compound_action(HunterLoopHuntAnimalMeleeDog)
   :execute('stonehearth:combat:get_melee_range', {
      target = ai.ARGS.target,
   })
   :execute('stonehearth:chase_entity', {
      target = ai.ARGS.target,
      stop_distance = ai.PREV.melee_range_ideal,
   })
   :execute('stonehearth:combat:attack_melee_adjacent', {
      target = ai.ARGS.target,
   })
   :execute('stonehearth:combat:set_global_attack_cooldown')
