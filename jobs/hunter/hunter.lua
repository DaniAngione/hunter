local BaseJob = require 'stonehearth.jobs.base_job'

local HunterClass = class()
radiant.mixin(HunterClass, BaseJob)

function HunterClass:should_tame(target)
	return false
end

return HunterClass