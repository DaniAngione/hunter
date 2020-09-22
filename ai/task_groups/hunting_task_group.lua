local HunterHuntingTaskGroup = class()
HunterHuntingTaskGroup.name = 'hunting'
HunterHuntingTaskGroup.does = 'stonehearth:work'
HunterHuntingTaskGroup.priority = 0.82

return stonehearth.ai:create_task_group(HunterHuntingTaskGroup)
         :work_order_tag("job")
         :declare_permanent_task('hunter:hunt_animal', {category = 'hunt'}, 1.0)