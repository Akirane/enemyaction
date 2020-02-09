[Back to top](`ReadMe.md`)
# Documentation
## Action Message


#### action_message:new(`obj`)
----
##### Parameters:
`obj`:\
#### action_message:update_player_id()
----
##### Parameters:
`N/A`
#### action_message:modify_y_pos(`party_count`)
----
##### Parameters:
`party_count`:\
#### action_message:update(`id, data`)
----
##### Parameters:
`id`:\
`data`:\
#### action_message:prerender_update()
----
##### Parameters:
`N/A`
#### action_message:clean()
----
##### Parameters:
`N/A`
#### action_message:reset_tracked_actions()
----
##### Parameters:
`N/A`

## Action Tracking


#### action_tracking:new(`obj`) 
----
##### Parameters:
`obj`:\
#### action_tracking:handle_action_packet(`id, data`)
----
##### Parameters:
`id`:\
`data`:\
#### action_tracking:track_actions(`ai`)
----
##### Parameters:
`ai`:\
#### action_tracking:clean_tracked_actions()
----
##### Parameters:
`N/A`
#### action_tracking:get_target_info(`mob_id`)
----
##### Parameters:
`mob_id`:\
#### action_tracking:is_npc(`mob_id`)
----
Checks what type of target the ID belongs to.
|mob_id<0x1000000|Player|
|mob_id>0x1000000 and mob_id% 0x1000 > 0x700|Pet|
##### Parameters:
`mob_id`:\
#### action_tracking:reset_tracked_actions()
----
##### Parameters:
`N/A`
#### action_tracking:new(`obj`) 
----
##### Parameters:
`obj`:\
#### action_tracking:handle_action_packet(`id, data`)
----
##### Parameters:
`id`:\
`data`:\
#### action_tracking:track_actions(`ai`)
----
##### Parameters:
`ai`:\
#### action_tracking:clean_tracked_actions()
----
##### Parameters:
`N/A`
#### action_tracking:get_target_info(`mob_id`)
----
##### Parameters:
`mob_id`:\
#### action_tracking:is_npc(`mob_id`)
----
##### Parameters:
`mob_id`:\
#### action_tracking:reset_tracked_actions()
----
##### Parameters:
`N/A`
