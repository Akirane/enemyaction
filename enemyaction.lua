_addon.name = 'EnemyAction'
_addon.author = 'Akirane'
_addon.version = '0.1'
_addon.language = 'English'
_addon.commands = {'enemyaction','ea'}


local player_id = nil
require('action_message')

action_message = require('action_message')

local action_msg_obj = nil
local ready = false

function initialize()
    action_msg_obj = action_message:new(nil)
	action_msg_obj:update_player_id()
    ready = true
end

windower.register_event('prerender', function()
    if action_msg_obj ~= nil then
        action_msg_obj:clean()
        action_msg_obj:prerender_update()
    end
end)

windower.register_event('incoming chunk', function(id, data)
    if action_msg_obj ~= nil then
        action_msg_obj:update(id, data, player_id)
    end
end)

windower.register_event('zone change', function()
    if action_msg_obj ~= nil then
		action_msg_obj:update_player_id()
        action_msg_obj:reset_tracked_actions()
    end
end)

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        initialize()
    end
end)
