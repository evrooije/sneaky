--[[
Beerholder's sneaky ladder. WIP name: [MOD] Sneaky [sneaky]

Many thanks to PilzAdam for his example on using entities (his boats
mod) to move the player and setting velocities.

To sneak climb we need to consider either something, then air above
it and then something again, or air, something and air above it.
This pattern needs to be anywhere next to the player.
Diagrammatic climb ("x" something " " air "p" player):
 2  x         2
 1     p  OR  1  x
 0  x         0     p
To sneak hover we need to consider air below and then something on top.
Diagrammatic hover (x something a air p player):
 0  x  p
-1
-2  x
We use a transparent (airlike) dummy node to stand/ hover on. We set
the selection box to something ridiculously small so one cannot see it.
It looks something like this ("s" = the sneaky block, sneakily hiding
underneath you):
 0  x  p
-1     s
-2  x
-3
-4  x
-5
]]--

-- Register the sneaky node to place underneath the player
--[[minetest.register_node("sneaky:sneaky", {
    drawtype = "airlike",
    groups = { fall_damage_add_percent = -100 },
    selection_box = {
        type = "fixed",
		fixed = {
            {-0.00001, -0.00001, -0.00001, 0.00001, 0.00001, 0.00001}
        }
    }
})]]--

minetest.register_entity("sneaky:sneaky", {
	physical = false,
	collisionbox = {-0.1,-0.5,-0.1, 0.1,-0.1,0.1},
	is_visible = false,
})

minetest.register_entity("sneaky:sneakyhard", {
	physical = true,
	collisionbox = {-0.1,-0.5,-0.1, 0.1,-0.1,0.1},
	is_visible = false,
})

local sneaky = nil
local sneakyhard = nil

local function get_velocity(v, yaw, y)
	local x = math.cos(yaw) * v
	local z = math.sin(yaw) * v
	return { x = x, y = y, z = z }
end

minetest.register_on_dieplayer(function(player)
    player:set_detach()

    if (sneaky ~= nil) then
        sneaky:remove()
        sneaky = nil
    end

    if (sneakyhard ~= nil) then
        sneakyhard:remove()
        sneakyhard = nil
    end

end)

-- Check for key presses sneak + jump or sneak only and check if there
-- is the pattern of blocks with air in between which is the sneak ladder
minetest.register_globalstep(function(dtime)
    local player = minetest.get_player_by_name("singleplayer")
    if player == nil then
        return
    end

    local sneakyclimb = false
    local sneakyhover = false

    local pos = player:getpos()

    if player:get_player_control().sneak or player:get_player_control().jump then
        -- Table of positions we are interested in around us
        local pos0front = { x = pos.x, y = pos.y, z = pos.z + 1 }
        local pos0back = { x = pos.x, y = pos.y, z = pos.z + -1 }
        local pos0right = { x = pos.x + 1, y = pos.y, z = pos.z }
        local pos0left = { x = pos.x - 1, y = pos.y, z = pos.z }

        local pos1front = { x = pos.x, y = pos.y + 1, z = pos.z + 1 }
        local pos1back = { x = pos.x, y = pos.y + 1, z = pos.z + -1 }
        local pos1right = { x = pos.x + 1, y = pos.y + 1, z = pos.z }
        local pos1left = { x = pos.x - 1, y = pos.y + 1, z = pos.z }

        local pos2front = { x = pos.x, y = pos.y + 2, z = pos.z + 1 }
        local pos2back = { x = pos.x, y = pos.y + 2, z = pos.z + -1 }
        local pos2right = { x = pos.x + 1, y = pos.y + 2, z = pos.z }
        local pos2left = { x = pos.x - 1, y = pos.y + 2, z = pos.z }

        local pos2above = { x = pos.x, y = pos.y + 2, z = pos.z }

        -- Nodes around us
        local node0front = minetest.get_node(pos0front)
        local node0back = minetest.get_node(pos0back)
        local node0right = minetest.get_node(pos0right)
        local node0left = minetest.get_node(pos0left)

        local node1front = minetest.get_node(pos1front)
        local node1back = minetest.get_node(pos1back)
        local node1right = minetest.get_node(pos1right)
        local node1left = minetest.get_node(pos1left)

        local node2front = minetest.get_node(pos2front)
        local node2back = minetest.get_node(pos2back)
        local node2right = minetest.get_node(pos2right)
        local node2left = minetest.get_node(pos2left)

        local node2above = minetest.get_node(pos2above)

        if player:get_player_control().sneak and player:get_player_control().jump then

            -- Check for air something air/ something air something pattern
            -- Set sneakyclimb to true if found
            if node0front.name ~= "air" and node1front.name == "air" and node2front.name ~= "air" then
                sneakyclimb = true
            elseif node0front.name == "air" and node1front.name ~= "air" and node2front.name == "air" then
                sneakyclimb = true
            elseif node0back.name ~= "air" and node1back.name == "air" and node2back.name ~= "air" then
                sneakyclimb = true
            elseif node0back.name == "air" and node1back.name ~= "air" and node2back.name == "air" then
                sneakyclimb = true
            elseif node0right.name ~= "air" and node1right.name == "air" and node2right.name ~= "air" then
                sneakyclimb = true
            elseif node0right.name == "air" and node1right.name ~= "air" and node2right.name == "air" then
                sneakyclimb = true
            elseif node0left.name ~= "air" and node1left.name == "air" and node2left.name ~= "air" then
                sneakyclimb = true
            elseif node0left.name == "air" and node1left.name ~= "air" and node2left.name == "air" then
                sneakyclimb = true
            end

            if sneakyclimb then
                if (sneaky == nil) then
                    player:set_physics_override( { gravity = 0, jump = 0 } )
                    sneaky = minetest.add_entity(player:getpos(), "sneaky:sneaky")
                    sneaky:set_armor_groups( { immortal = 1 } )
                    player:set_attach(sneaky, "", {x=0,y=0.5,z=0}, {x=0,y=0,z=0})
                end
                if node2above.name == "air" then
                    sneaky:setvelocity( { x = 0, y = 5, z = 0 } )
                else
                    sneaky:setvelocity( { x = 0, y = 0, z = 0 } )
                end
            end
        end

        if player:get_player_control().sneak and not player:get_player_control().jump then

            -- Check for air something air/ something air something pattern
            -- Set sneakyclimb to true if found
            if node0front.name ~= "air" and node1front.name == "air" and node2front.name ~= "air" then
                sneakyhover = true
            elseif node0front.name == "air" and node1front.name ~= "air" and node2front.name == "air" then
                sneakyhover = true
            elseif node0back.name ~= "air" and node1back.name == "air" and node2back.name ~= "air" then
                sneakyhover = true
            elseif node0back.name == "air" and node1back.name ~= "air" and node2back.name == "air" then
                sneakyhover = true
            elseif node0right.name ~= "air" and node1right.name == "air" and node2right.name ~= "air" then
                sneakyhover = true
            elseif node0right.name == "air" and node1right.name ~= "air" and node2right.name == "air" then
                sneakyhover = true
            elseif node0left.name ~= "air" and node1left.name == "air" and node2left.name ~= "air" then
                sneakyhover = true
            elseif node0left.name == "air" and node1left.name ~= "air" and node2left.name == "air" then
                sneakyhover = true
            end

            if sneakyhover then
                if (sneaky == nil) then
                    player:set_physics_override( { gravity = 0, jump = 1 } )
                    sneaky = minetest.add_entity(player:getpos(), "sneaky:sneaky")
                    sneaky:set_armor_groups( { immortal = 1 } )
                    player:set_attach(sneaky, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
                end
                sneaky:setvelocity( { x = 0, y = 0, z = 0 } )
            end
        end
    end

    if sneaky ~= nil and (sneakyclimb or sneakyhover) then
        local moving = false
        local direction
		if player:get_player_control().up then
			direction = (math.pi / 2)
			moving = true
		end
		if player:get_player_control().down then
			direction = (math.pi * 1.5)
			moving = true
		end
		if player:get_player_control().left then
			direction = math.pi
			moving = true
		end
		if player:get_player_control().right then
			direction = 0
			moving = true
		end
		if moving then
            if sneakyhard == nil then
                sneakyhard = minetest.add_entity(player:getpos(), "sneaky:sneakyhard")
                sneakyhard:set_armor_groups( { immortal = 1 } )
                player:set_attach(sneakyhard, "", {x=0,y=0.5,z=0}, {x=0,y=0,z=0})
            end
			sneakyhard:setvelocity(get_velocity(1, player:get_look_horizontal() + direction, sneaky:getvelocity().y))
            sneaky:remove()
            sneaky = nil
		else
            if sneaky ~= nil then
                sneaky:setvelocity( { x = 0, y = sneaky:getvelocity().y, z = 0 })
            elseif sneakyhard ~= nil then
                sneakyhard:setvelocity( { x = 0, y = sneakyhard:getvelocity().y, z = 0 })
            end
		end
        return
    end

    if (sneaky ~= nil) then
        player:set_physics_override( { gravity = 1, jump = 1 } )
        player:set_detach()
        sneaky:remove()
        sneaky = nil
    end

    if (sneakyhard ~= nil) then
        player:set_physics_override( { gravity = 1, jump = 1 } )
        player:set_detach()
        sneakyhard:remove()
        sneakyhard = nil
    end

end)
