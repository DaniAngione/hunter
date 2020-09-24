local game_master_lib = require 'stonehearth.lib.game_master.game_master_lib'
local Point3 = _radiant.csg.Point3

local WildGameSpawn = class()

function WildGameSpawn:initialize()
   self._sv.ctx = nil
   self._sv.info = nil
	self._sv.party = nil
   self._sv.searcher = nil
   self._sv.timer = nil
end

function WildGameSpawn:start(ctx, info)
   assert(info.spawn_range)
   assert(info.spawn_range.min)
   assert(info.spawn_range.max)

   self._sv.ctx = ctx
   self._sv.info = info

   self:_create_searcher()
end

function WildGameSpawn:_create_searcher()
   self:stop()
	
   local info = self._sv.info
   local min = info.spawn_range.min
   local max = info.spawn_range.max

   self._sv.searcher = radiant.create_controller('stonehearth:game_master:util:choose_location_outside_town',
                                                 min, max,
                                                 radiant.bind(self, '_mission'))
end

function WildGameSpawn:stop()
   if self._sv.timer then
      self._sv.timer:destroy()
      self._sv.timer = nil
   end
   if self._sv.searcher then
      self._sv.searcher:destroy()
      self._sv.searcher = nil
   end
end

function WildGameSpawn:destroy()
   self:stop()
end

function WildGameSpawn:get_ctx()
   return self._sv.ctx
end

function WildGameSpawn:_mission(op, location)
   local info = self._sv.info
   if op == 'abort' then
      local on_searcher_failure = info.on_searcher_failure
      if on_searcher_failure and on_searcher_failure.retry then
         self._sv.timer = stonehearth.calendar:set_persistent_timer("Retry WildGameSpawn",
                                                                     stonehearth.constants.encounters.DEFAULT_SEARCHER_DELAY,
                                                                     radiant.bind(self, '_create_searcher'))
      elseif on_searcher_failure and on_searcher_failure.destroy_tree then
         local root_node = on_searcher_failure.destroy_tree.root
         if root_node then
            game_master_lib.destroy_tree(root_node, on_searcher_failure.destroy_tree.destroy_root, self._sv.ctx)
         end
      else
         self:_destroy_node()
      end
   else
      local ctx = self._sv.ctx

      assert(info.mission)

      ctx.enemy_location = location

      self:_spawn_commence(ctx, info.mission)
   end
end

function WildGameSpawn:_destroy_node()
   self:destroy()
   assert(self._sv.ctx, 'No ctx saved in create camp encounter!')
   game_master_lib.destroy_node(self._sv.ctx.encounter, self._sv.ctx.parent_node)
end

function WildGameSpawn:_spawn_commence(ctx, info)
   if info.npc_player_id then
      ctx.npc_player_id = info.npc_player_id
   end

   self._sv.party = self:_create_party(ctx, info)
end

function WildGameSpawn:_create_party(ctx, info)
   assert(ctx)
   radiant.assert(ctx.enemy_location, "no enemy location for mission %s", radiant.util.table_tostring(info))
   radiant.assert(info.offset, "no offset for mission %s", radiant.util.table_tostring(info))
   radiant.assert(info.members, "no members for mission %s", radiant.util.table_tostring(info))

   assert(ctx.npc_player_id)

   local origin = ctx.enemy_location

   local population = stonehearth.population:get_population(ctx.npc_player_id)

   local offset = Point3(info.offset.x, info.offset.y, info.offset.z)

   local party_entity = stonehearth.unit_control:get_controller(ctx.npc_player_id):create_party()
   local party_component = party_entity:get_component('stonehearth:party')

   local raid_timeout_minutes = info.raid_timeout_minutes or 4300
   local raid_timeout_variance_minutes = info.raid_timeout_variance_minutes or 0

	local bulletin_created = nil
	
   local citizens_by_type = {}
   if info.members then
      for type, info in pairs(info.members) do
         local members = game_master_lib.create_citizens(population, info, origin + offset, ctx)
         citizens_by_type[type] = members
         for i, member in ipairs(members) do
            radiant.entities.set_attribute(member, 'raid_timeout_minutes', raid_timeout_minutes)
            radiant.entities.set_attribute(member, 'raid_timeout_variance_minutes', raid_timeout_variance_minutes)
            party_component:add_member(member)
				
				if not bulletin_created then
					stonehearth.bulletin_board:post_bulletin(ctx.player_id)
						:set_data({
						zoom_to_entity = member,
						title = "i18n(hunter:data.gm.campaigns.hunting.wild_game_spawn)"
					})
					bulletin_created = true
				end
         end
      end
      if info.ctx_entity_registration_path then
         game_master_lib.register_entities(ctx, info.ctx_entity_registration_path, citizens_by_type)
      end
   end
	
	self:destroy()
	
   return party_entity
end

return WildGameSpawn
