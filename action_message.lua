-- Meta class
texts = require('texts')
-- table = require('table')

action_tracking = require('action_tracking')

local left_of_target_box = -180
local init_count = 1


local message_box_setup = {
	flags = {bold=true,draggable=false,right=true, bottom=true},
	pos = { x = left_of_target_box, y = -51 - (20*init_count) },
	bg = {visible=false},
	font='Arial',
	font_size=12,
	show=true,
	text={
		color = {alpha=255, red=255, green=255, blue=255},
		stroke={width=2,alpha=255,red=0,green=0,blue=0}
	}
}

action_message = {}

function action_message:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	self.tracker = action_tracking:new(nil)
	self.party_count = 1
	self.message_box = texts.new('Hello!', message_box_setup)
	return obj
end

function action_message:modify_y_pos(party_count)
	self.message_box:pos_y(-46 - (20*party_count))
end
function action_message:update(id, data)
	if self.tracker:handle_action_packet(id, data) == true then
        target = windower.ffxi.get_mob_by_target('t')
        if target ~= nil then
			local action = self.tracker.tracked_actions[target.id]
			if action ~= nil then 
				if (action.updated == false) then
					self.message_box:color(255, 255, 255, 255)
				end
				self.message_box:show()
			else
				self.message_box:hide()
			end
		else
			self.message_box:hide()
		end
	end
end

function action_message:prerender_update()

	local new_count = windower.ffxi.get_party_info().party1_count
	if (self.party_count ~= new_count) then
		self.party_count  = new_count
		self:modify_y_pos(self.party_count)
	end

    target = windower.ffxi.get_mob_by_target('t')
    if target ~= nil then
		local action = self.tracker.tracked_actions[target.id]
		if action ~= nil and target.id == action.actor_id then 
			if (os.time() - action.time > 5) and (action.updated == false) then
				self.message_box:color(100, 100, 255)
				action.updated = true
			end
			self.message_box:text(action.ability.name)
			self.message_box:show()
		else
			-- self.message_box:text(' ')
			self.message_box:hide()
		end
	else
		self.message_box:hide()
	end
end

function action_message:clean()

	if self.tracker:clean_tracked_actions() == true then
		self.message_box:hide()
	end
end

function action_message:reset_tracked_actions()
	self.tracker:reset_tracked_actions()
end

return action_message