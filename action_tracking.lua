resources = require('resources')
require('packets')

action_tracking = {}


function action_tracking:new(obj) 
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    self.tracked_actions = {}
    self.tracked_enmity = {}
    self.tracked_debuff = {}
    self.framerate = 75
    self.clean_actions_delay = self.framerate
    self.clean_actions_tick = self.clean_actions_delay
    self.wears_off_message_ids = S{204,206}
    self.tracked_message_ids = S{8,4,7,11,3,6,9,5}
    self.starting_message_ids = S{8,7,9}
    self.completed_message_ids = S{4,11,3,5,6}
    self.spell_message_ids = S{8,4}
    self.item_message_ids = S{5,9}
    self.weapon_skill_message_ids = S{3,7,11}
    self.tracked_debuff_ids = S{2,19,7,28}
    self.untracked_debuff_categories = S{87,6,9}
    self.damaging_spell_message_ids = S{2,252}
    self.party_members = {}
    self.non_damaging_spell_message_ids = S{75,236,237,268,270,271}
    return obj
end


function action_tracking:handle_action_packet(id, data)
    if 0x028 == id then
        local ai = windower.packets.parse_action(data)

        if (ai ~= nil) then
            self:track_actions(ai)
        end
        return true
    else
        return false
    end
end

function action_tracking:track_actions(ai)
    local actor_id = ai.actor_id

    -- if the category is not casting magic, jas, items or ws, don't bother.
    if not self.tracked_message_ids:contains(ai.category) then return end

    -- if it's a starting packet, the id is in param2
    local action_id = ai.param
    if self.starting_message_ids:contains(ai.category) then
        action_id = ai.targets[1].actions[1].param
    end
    if action_id == 0 then return end
    -- find the action
    local action_map = nil
	
	
	
    if self.spell_message_ids:contains(ai.category) then
        action_map = resources.spells[action_id]
    elseif self.item_message_ids:contains(ai.category) then
        action_map = resources.items[action_id]
    elseif self:is_npc(actor_id) then
        action_map = resources.monster_abilities[action_id]
		if not action_map then
			if ai.category == 6 then
				action_map = resources.job_abilities[action_id]
			elseif self.weapon_skill_message_ids:contains(ai.category) then
				action_map = resources.weapon_skills[action_id]
			end
		end
    elseif ai.category == 6 then
        action_map = resources.job_abilities[action_id]
    elseif self.weapon_skill_message_ids:contains(ai.category) then
        action_map = resources.weapon_skills[action_id]
    end
    -- couldn't find the action, let's just give some debug output.
    if not action_map then
        action_map = {en='Unknown (id:'..action_id..')'}
    end 

    if ai.targets[1].actions[1].message == 0 and ai.targets[1].id == ai.actor_id then
        -- cast was interrupted
        self.tracked_actions[ai.actor_id] = nil;
    else
        self.tracked_actions[ai.actor_id] = {actor_id=actor_id, target_name="", target_id=ai.targets[1].id, ability=action_map, complete=false, time=os.time(), updated=false}
		if ai.targets[1].id == ai.actor_id then
			self.tracked_actions[ai.actor_id].target_name = "(self)"
		else
			local name = windower.ffxi.get_mob_by_id(ai.targets[1].id).name
			local new_name = name:sub(1,4)
			local final_name = new_name.."."
			self.tracked_actions[ai.actor_id].target_name = final_name
		end

    end
end

function action_tracking:clean_tracked_actions()

    local time = os.time()
    for id,action in pairs(self.tracked_actions) do
        -- for incomplete items, timeout at 30s.
        if (time - action.time > 30) then
            self.tracked_actions[id] = nil
            return true
        else
            return false
        end
    end

end

function action_tracking:get_target_info(mob_id)
	local target = windower.ffxi.get_mob_by_id(mob_id)
	if target ~= nil then
		return target.name
	else
		return nil
	end
end

function action_tracking:is_npc(mob_id)
	local mob = windower.ffxi.get_mob_by_id(mob_id)
    local is_pc = mob_id < 0x01000000
    local is_pet = mob_id > 0x01000000 and mob_id % 0x1000 > 0x700

    -- filter out pcs and known pet IDs
    if is_pc or is_pet then return false end

    -- check if the mob is charmed
    if not mob then return nil end
    return mob.is_npc and not mob.charmed
end

function action_tracking:reset_tracked_actions()
    self.tracked_actions = {}
    self.tracked_enmity = {}
    self.tracked_debuff = {}
end


return action_tracking
