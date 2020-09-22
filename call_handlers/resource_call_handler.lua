local Point3 = _radiant.csg.Point3
local Cube3 = _radiant.csg.Cube3
local Color4 = _radiant.csg.Color4
local entity_forms_lib = require 'stonehearth.lib.entity_forms.entity_forms_lib'
local validator = radiant.validator

local ResourceCallHandler = class()

local boxed_entities = {}

function ResourceCallHandler:box_hunt(session, response)
   stonehearth.selection:select_xz_region(stonehearth.constants.xz_region_reasons.BOX_HARVEST_RESOURCES)
      :set_max_size(50)
      :require_supported(true)
      :use_outline_marquee(Color4(0, 255, 0, 32), Color4(0, 255, 0, 255))
      :set_cursor('stonehearth:cursors:harvest')
      -- Allow selection on buildings/other items that aren't selectable
      :allow_unselectable_support_entities(true)
      :set_find_support_filter(function(result)
            if self:_is_ground(result.entity) then
               return true
            end
            return stonehearth.selection.FILTER_IGNORE
         end)
      :done(function(selector, box)
            _radiant.call('hunter:server_box_hunt', box)
            response:resolve(true)
         end)
      :fail(function(selector)
            response:reject('no region')
         end)
      :go()
end

function ResourceCallHandler:server_box_hunt(session, response, box)
   validator.expect_argument_types({'Cube3'}, box)

   local cube = Cube3(Point3(box.min.x, box.min.y, box.min.z),
                      Point3(box.max.x, box.max.y, box.max.z))

   local entities = radiant.terrain.get_entities_in_cube(cube)

   for _, entity in pairs(entities) do
      self:hunt_entity(session, response, entity, true) -- true for from harvest tool
   end
end

local HUNT_ACTION = 'hunter:hunt_animal'
function ResourceCallHandler:hunt_entity(session, response, entity, from_harvest_tool)
   validator.expect_argument_types({'Entity', validator.optional('boolean')}, entity, from_harvest_tool)   

   local town = stonehearth.town:get_town(session.player_id)

   local is_animal = radiant.entities.get_player_id(entity) == 'animals'
   if not is_animal then
      return false
   end

   local task_tracker_component = entity:add_component('stonehearth:task_tracker')
   if task_tracker_component:is_activity_requested(HUNT_ACTION) then
      return false -- If someone has requested to hunt already
   end

   local success = task_tracker_component:request_task(session.player_id, 'hunt', HUNT_ACTION, 'stonehearth:effects:attack_indicator_effect')
   return success
end

-- returns true if the entity should be considered a target when box selecting items
function ResourceCallHandler:_is_ground(entity)
   if entity:get_component('terrain') then
      return true
   end
   
   if (entity:get_component('stonehearth:construction_data') or
       entity:get_component('stonehearth:build2:structure')) then
      return true
   end

   return false
end

return ResourceCallHandler
