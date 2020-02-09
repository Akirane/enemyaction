_addon.name = 'EnemyAction'
_addon.author = 'Akirane'
_addon.version = '0.3'
_addon.language = 'English'
_addon.commands = {'enemyaction','ea'}

local player_id = nil
require('action_message')

action_message = require('action_message')

action_tracking = require('action_tracking')
local action_msg_obj = nil
local ready = false

function initialize()
    action_msg_obj = action_message:new(nil)
	action_msg_obj:update_player_id()
    ready = true
end

windower.register_event('prerender', function()
	if ready == true then
		if action_msg_obj ~= nil then
			action_msg_obj:clean()
			action_msg_obj:prerender_update()
		end
	end
end)

--windower.register_event('action', function(raw_action)
--	if ready == true then
--		action_msg_obj:update_casting(raw_action)
--	end
--end)

windower.register_event('incoming chunk', function(id, data)
	if ready == true then
		if action_msg_obj ~= nil then
			action_msg_obj:update(id, data)
		end
	end
end)

windower.register_event('zone change', function()
	if ready == true then
		if action_msg_obj ~= nil then
			action_msg_obj:update_player_id()
			action_msg_obj:reset_tracked_actions()
		end
	end
end)

windower.register_event('load', 'login', function()
	if windower.ffxi.get_player() ~= nil then
        initialize()
    end
end)
