-- This is extracted from the Node.lua override used in ACE;
-- Special thanks to the ACE Team/Paulthegreat

local Node = class()

-- deep copy the cached json so that things like random i18n string selections from tables don't override the cache
function Node:load_json()
   if self._sv.json_path then
      -- true for cache, false for don't report error if json doesn't exist.
      -- If the json file doesn't exist, the NodeList's post activate will reap us
      self._sv._info = radiant.deep_copy(radiant.resources.load_json(self._sv.json_path, true, false))
   end
end

return Node
