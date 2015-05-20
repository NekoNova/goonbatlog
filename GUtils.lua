-- hook goonbatlog so we can load inside our addon
local GoonbatLog = Apollo.GetAddon("GoonbatLog")

-- setup container for functions
local GUtils = {}
GoonbatLog.GUtils = GUtils

-- breaks for cyclic references, so avoid those.
function GUtils.CopyTable(t)
	local o = {}

	for k,v in pairs(t) do
		if type(v) == 'table' then
			o[k] = GUtils.CopyTable(v)
		else
			o[k] = v
		end
	end

	return o
end

-- helper for the slash command
function GUtils.CPrint(string)
	ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Command, string, "")
end
