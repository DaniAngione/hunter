local LootTable = require 'stonehearth.lib.loot_table.loot_table'
local LootDropsComponent = require 'stonehearth.components.loot_drops.loot_drops_component'

-- ACE Compatibility
local AceLootDropsComponent = require 'stonehearth_ace.monkey_patches.ace_loot_drops_component'
-- ACE Unstable Compatibility
local AceUnstable = require 'stonehearth_ace.monkey_patches.ace_charging_pedestal_component'
local AceUtil = require 'stonehearth_ace.lib.util'

local HunterLootDropsComponent = class()

function HunterLootDropsComponent:activate()
	if AceUnstable then
		self._kill_listener = radiant.events.listen(self._entity, 'stonehearth:kill_event', self, self._on_kill_event_ace_unstable)
	elseif AceLootDropsComponent then
		self._kill_listener = radiant.events.listen(self._entity, 'stonehearth:kill_event', self, self._on_kill_event_ace)
	else
		self._kill_listener = radiant.events.listen(self._entity, 'stonehearth:kill_event', self, self._on_kill_event)
	end
end

function HunterLootDropsComponent:set_hunting_camp_loot(player_id)
	self:set_auto_loot_player_id(player_id)
   self._sv._hunting_camp_loot = nil
	local hunting_camps = {}
	local inventory = stonehearth.inventory:get_inventory(player_id)
	
	if inventory then
		local matching = inventory and inventory:get_items_of_type('hunter:containers:hunting_camp')
		for _, camp in pairs(matching and matching.items or {}) do
			if radiant.entities.exists_in_world(camp) then
				table.insert(hunting_camps, camp)
			end
		end
		
		local hunting_camp_storage = nil
		if hunting_camps ~= {} then
			for _, hunting_camp in ipairs(hunting_camps) do
				hunting_camp_storage = hunting_camp:get_component('stonehearth:storage'):is_full()
				if not hunting_camp_storage then 
					self._sv._hunting_camp_loot = hunting_camp
					self.__saved_variables:mark_changed()
					return
				end				
			end
		end
	end	
end

function HunterLootDropsComponent:_on_kill_event(kill_data)
	local loot_table = self._sv.loot_table or radiant.entities.get_json(self)
   if loot_table then
      local location = radiant.entities.get_world_grid_location(self._entity)
      if location then
         local auto_loot = radiant.util.get_config('auto_loot', false)
         local town = stonehearth.town:get_town(self._sv.auto_loot_player_id)

         local items = LootTable(loot_table)
                           :roll_loot()
         local spawned_entities = radiant.entities.spawn_items(items, location, 1, 3, { owner = self._entity })

         --Add a loot command to each of the spawned items, or claim them automatically
         for id, entity in pairs(spawned_entities) do
            local target = entity
            local entity_forms = entity:get_component('stonehearth:entity_forms')
            if entity_forms then
               target = entity_forms:get_iconic_entity()
            end
            if self._sv.auto_loot_player_id and (loot_table.force_auto_loot or self._entity:get_player_id() == self._sv.auto_loot_player_id) then
               entity:set_player_id(self._sv.auto_loot_player_id)
               target:set_player_id(self._sv.auto_loot_player_id)
               stonehearth.inventory:get_inventory(self._sv.auto_loot_player_id)
                                       :add_item_if_not_full(entity)
            else
               local command_component = target:add_component('stonehearth:commands')
               command_component:add_command('stonehearth:commands:loot_item')
               if auto_loot and town then
                  town:loot_item(target)
               end
            end
         end
			
			if self._sv._hunting_camp_loot then 
				local destination = self._sv._hunting_camp_loot:get_component('stonehearth:storage')
				for id, entity in pairs(spawned_entities) do
					radiant.terrain.remove_entity(entity)
					destination:add_item(entity, true, self._sv.auto_loot_player_id)
				end
			end
      end
   end
end

-- ACE Compatibility
function HunterLootDropsComponent:_on_kill_event_ace(kill_data)
   local loot_table = self._sv.loot_table or radiant.entities.get_json(self)
   if loot_table then
      local location = radiant.entities.get_world_grid_location(self._entity)
      if location then
         local auto_loot, force_auto_loot
         if self._sv.auto_loot_player_id then
            auto_loot = stonehearth.client_state:get_client_gameplay_setting(self._sv.auto_loot_player_id, 'stonehearth', 'auto_loot', false)
				force_auto_loot = loot_table.force_auto_loot or self._entity:get_player_id() == self._sv.auto_loot_player_id
         end
         local town = stonehearth.town:get_town(self._sv.auto_loot_player_id)

         local items = LootTable(loot_table)
                           :roll_loot()
         local spawned_entities = radiant.entities.spawn_items(items, location, 1, 3, { owner = force_auto_loot and self._sv.auto_loot_player_id or self._entity })

         --Add a loot command to each of the spawned items, or claim them automatically
         for id, entity in pairs(spawned_entities) do
            local target = entity
            local entity_forms = entity:get_component('stonehearth:entity_forms')
            if entity_forms then
               target = entity_forms:get_iconic_entity()
            end
            if force_auto_loot then
               stonehearth.inventory:get_inventory(self._sv.auto_loot_player_id)
                                       :add_item_if_not_full(entity)
            else
               local command_component = target:add_component('stonehearth:commands')
               command_component:add_command('stonehearth:commands:loot_item')
               if auto_loot and town then
                  town:loot_item(target)
               end
            end
         end
			
			if self._sv._hunting_camp_loot then 
				local destination = self._sv._hunting_camp_loot:get_component('stonehearth:storage')
				for id, entity in pairs(spawned_entities) do
					radiant.terrain.remove_entity(entity)
					destination:add_item(entity, true, self._sv.auto_loot_player_id)
				end
			end
      end
   end
end

-- ACE Unstable Compatibility
function HunterLootDropsComponent:_on_kill_event_ace_unstable(e)
   local loot_table, filter_script, filter_args = self._sv.loot_table, self._sv._filter_script, self._sv._filter_args
   if not loot_table then
      loot_table = radiant.entities.get_json(self)
      if loot_table then
         filter_script = loot_table.filter_script
         filter_args = loot_table.filter_args
      end
   end

   if loot_table then
      local location = radiant.entities.get_world_grid_location(self._entity)
      if location then
         local player_id = radiant.entities.get_player_id(self._entity)
         local kill_data = e.kill_data or {}
         local loot_player_id = kill_data.source or self._sv.auto_loot_player_id
         if radiant.entities.is_entity(loot_player_id) then
            loot_player_id = radiant.entities.get_player_id(loot_player_id)
         end
         local auto_loot, force_auto_loot
         if self._sv.auto_loot_player_id then
            auto_loot = stonehearth.client_state:get_client_gameplay_setting(self._sv.auto_loot_player_id, 'stonehearth', 'auto_loot', false)
            force_auto_loot = loot_table.force_auto_loot or player_id == self._sv.auto_loot_player_id
         elseif loot_player_id == player_id then
            force_auto_loot = true
         end
         local town = stonehearth.town:get_town(self._sv.auto_loot_player_id)

         local quality
         if loot_table.apply_entity_quality then
            quality = radiant.entities.get_item_quality(self._entity)
         end

         if filter_script and not filter_args then
            filter_args = util.get_current_conditions_loot_table_filter_args()
         end
         local items = LootTable(loot_table, quality, filter_script, filter_args)
                           :roll_loot()
         local options = {
            owner = force_auto_loot and loot_player_id or player_id,
            add_spilled_to_inventory = force_auto_loot,
            inputs = kill_data.source,
            output = self._entity,
            spill_fail_items = true,
         }
         local spawned_entities = radiant.entities.output_items(items, location, 1, 3, options).spilled

         --Add a loot command to each of the spawned items, or claim them automatically
         for id, entity in pairs(spawned_entities) do
            local target = entity
            local entity_forms = entity:get_component('stonehearth:entity_forms')
            if entity_forms then
               target = entity_forms:get_iconic_entity()
            end
            if not force_auto_loot then
               local command_component = target:add_component('stonehearth:commands')
               command_component:add_command('stonehearth:commands:loot_item')
               if auto_loot and town then
                  town:loot_item(target)
               end
            end
         end
			
			if self._sv._hunting_camp_loot then 
				local destination = self._sv._hunting_camp_loot:get_component('stonehearth:storage')
				for id, entity in pairs(spawned_entities) do
					radiant.terrain.remove_entity(entity)
					destination:add_item(entity, true, self._sv.auto_loot_player_id)
				end
			end
      end
   end
end

return HunterLootDropsComponent
