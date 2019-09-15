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
        -- print(id)
        local ai = windower.packets.parse_action(data)

        -- track_enmity(ai)
        if (ai ~= nil) then
            self:track_actions(ai)
        end
        -- track_debuffs(ai)
    -- elseif 0x029 then
    --     local message_id = data:unpack('H',0x19)
    --     if not message_id then return end
    --     message_id = message_id%0x8000
    --     local param_1 = data:unpack('I',0x0D)
    --     local target_id = data:unpack('I',0x09)
    --     if wears_off_message_ids:contains(message_id) then
    --         -- wears off message.
    --         if tracked_debuff[target_id]  then
    --             tracked_debuff[target_id][param_1] = nil
    --         end
    --     end
        return true
    else
        return false
    end
end


-- function action_tracking:parse_party_packets(id, data)
--     if id == 0x0DD then 
--         self:cache_party_members()
--     elseif id == 0x067 then
--         local p =  parse('incoming', data)
--         if p['Owner Index'] > 0 then
--             local owner = windower.ffxi.get_mob_by_index(p['Owner Index'])
--             if owner and is_party_member_or_pet(owner.id) then
--                 self.party_members[p['Pet ID']] = {is_pet = true, owner = owner.id}
--             end
--         end
--     end
-- end

-- function action_tracking:cache_party_members()
--     self.party_members = {}
--     local party = windower.ffxi.get_party()
--     if not party then return end
--     for i=0, (party.party1_count or 0) - 1 do
--         cache_party_member(party['p'..i])            
--     end
--     for i=0, (party.party2_count or 0) - 1 do
--         cache_party_member(party['a1'..i])            
--     end
--     for i=0, (party.party3_count or 0) - 1 do
--         cache_party_member(party['a2'..i])            
--     end
-- end

-- function action_tracking:cache_party_member(p)
--     if p and p.mob then
--         party_members[p.mob.id] = {is_pc = true,}
--         if p.mob.pet_index then
--             local pet = windower.ffxi.get_mob_by_index(p.mob.pet_index)
--             if pet then
--                 self.party_members[pet.id] = {is_pet = true, owner = p.id}
--             end
--         end
--     end
-- end

-- function is_party_member_or_pet(mob_id)
--     if mob_id == player_id then 
--         return true 
--     elseif self:is_npc(mob_id) then 
--         return false 
--     else
--         return mob_id
--     end
-- end

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
        self.tracked_actions[ai.actor_id] = {actor_id=actor_id, target_id=ai.targets[1].id, ability=action_map, complete=false, time=os.time()}
    end
end

function action_tracking:clean_tracked_actions()
    -- print(self.clean_actions_tick)

    local player = windower.ffxi.get_mob_by_target("me")
    local time = os.time()
    for id,action in pairs(self.tracked_actions) do
        -- for incomplete items, timeout at 30s.
        if  (time - action.time > 10) then
            self.tracked_actions[id] = nil
            return true
        -- for complete actions, timeout at 3s.
        else
            return false
        end
    end

    -- for id,enmity in pairs(tracked_enmity) do
    --     if time - enmity.time > 3 then
    --         local mob = windower.ffxi.get_mob_by_id(enmity.mob)
    --         if not mob or mob.hpp == 0 then
    --             tracked_enmity[id] = nil
    --         elseif mob.status == 0 then
    --             tracked_enmity[id] = nil
    --         elseif enmity.pc and not looking_at(mob, windower.ffxi.get_mob_by_id(enmity.pc)) then
    --             tracked_enmity[id].pc = nil
    --         elseif get_distance(player, mob) > 50 then
    --             tracked_enmity[id] = nil
    --         end
    --     end
    -- end

    -- for id,debuffs in pairs(self.tracked_debuff) do
    --     local mob = windower.ffxi.get_mob_by_id(id)
    --     if not mob or mob.hpp == 0 then
    --         self.tracked_debuff[id] = nil
    --     else
    --         for i,debuff in ipairs(debuffs) do
    --             -- if the duration is much longer than +50%, let's assume it wore. 
    --             if time - debuff.time > debuff.duration * 1.5 then 
    --                 self.tracked_debuff[id][debuff.effect] = nil
    --             end
    --         end
    --     end
    -- end

end

function action_tracking:is_npc(mob_id)
    local is_pc = mob_id < 0x01000000
    local is_pet = mob_id > 0x01000000 and mob_id % 0x1000 > 0x700

    -- filter out pcs and known pet IDs
    if is_pc or is_pet then return false end

    -- check if the mob is charmed
    local mob = windower.ffxi.get_mob_by_id(mob_id)
    if not mob then return nil end
    return mob.is_npc and not mob.charmed
end

function action_tracking:reset_tracked_actions()
    self.tracked_actions = {}
    self.tracked_enmity = {}
    self.tracked_debuff = {}
end


return action_tracking