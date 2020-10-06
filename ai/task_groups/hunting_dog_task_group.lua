local HunterHuntingDogTaskGroup = class()
HunterHuntingDogTaskGroup.name = 'hunting_dog'
HunterHuntingDogTaskGroup.does = 'stonehearth:top'
HunterHuntingDogTaskGroup.priority = 0.85

return stonehearth.ai:create_task_group(HunterHuntingDogTaskGroup)
         :declare_permanent_task('hunter:hunt_animal', {category = 'hunt'}, 1.0)