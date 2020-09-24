hunter = {}

local service_creation_order = {
}

local monkey_patches = {
	hunter_combat_service = 'stonehearth.services.server.combat.combat_service'
}

local function monkey_patching()
   for from, into in pairs(monkey_patches) do
      local monkey_see = require('monkey_patches.' .. from)
      local monkey_do = radiant.mods.require(into)
      radiant.log.write_('hunter', 0, 'Hunter Mod server monkey-patching sources \'' .. from .. '\' => \'' .. into .. '\'')
      radiant.mixin(monkey_do, monkey_see)
   end
end

local function create_service(name)
   local path = string.format('services.server.%s.%s_service', name, name)
   local service = require(path)()
	
   local saved_variables = hunter._sv[name]
   if not saved_variables then
      saved_variables = radiant.create_datastore()
      hunter._sv[name] = saved_variables
   end

   service.__saved_variables = saved_variables
   service._sv = saved_variables:get_data()
   saved_variables:set_controller(service)
   saved_variables:set_controller_name('hunter:' .. name)
   service:initialize()
   hunter[name] = service
end

function hunter:_on_init()
   hunter._sv = hunter.__saved_variables:get_data()

   for _, name in ipairs(service_creation_order) do
      create_service(name)
   end

   radiant.events.trigger_async(radiant, 'hunter:server:init')
   radiant.log.write_('hunter', 0, 'Hunter Mod server initialized')
end

function hunter:_on_required_loaded()
	monkey_patching()
   
   radiant.events.trigger_async(radiant, 'hunter:server:required_loaded')
end

radiant.events.listen(hunter, 'radiant:init', hunter, hunter._on_init)

local mods = radiant.resources.get_mod_list()
local ace = false
for i, mod in ipairs(mods) do
	if mod == "stonehearth_ace" then
		ace = true
		break
	end
end
if ace then
	radiant.events.listen(radiant, 'stonehearth_ace:server:required_loaded', hunter, hunter._on_required_loaded)
else
	radiant.events.listen(radiant, 'radiant:required_loaded', hunter, hunter._on_required_loaded)
end

return hunter
