--[[

Beerholder's sneaky ladder. WIP name: [MOD] Sneaky [sneaky]

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
minetest.register_node("sneaky:sneaky", {
    drawtype = "airlike",
    selection_box = {
        type = "fixed",
		fixed = {
                    {-0.00001, -0.00001, -0.00001, 0.00001, 0.00001, 0.00001}
			}
		}
})

-- Check for key presses sneak + jump or sneak only and check if there
-- is the pattern of blocks with air in between which is the sneak ladder
minetest.register_globalstep(function(dtime)
    local player = minetest.get_player_by_name("singleplayer")
    if player == nil then
        return
    end

    local pos = { x = player:getpos().x, y = player:getpos().y, z = player:getpos().z }
    local pos0below = { x = pos.x, y = pos.y, z = pos.z }
    local node0below = minetest.get_node(pos0below)
    local pos1below = { x = pos.x, y = pos.y - 1, z = pos.z }
    local node1below = minetest.get_node(pos1below)
    local pos2below = { x = pos.x, y = pos.y - 2, z = pos.z }
    local node2below = minetest.get_node(pos2below)

    if player:get_player_control().sneak and player:get_player_control().jump then

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

        -- Nodes around is
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

        local sneakyclimb = false

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
            player:set_physics_override( { gravity = 0, jump = 0 } )
            player:setpos( { x = player:getpos().x, y = player:getpos().y + 0.2, z = player:getpos().z } )
            if (node1below.name == "air") then
                minetest.place_node(pos1below, { name = "sneaky:sneaky" } )
            end
            if (node2below.name == "sneaky:sneaky") then
                minetest.remove_node(pos2below)
            end
            return
        end
    end

    if player:get_player_control().sneak then

        local pos0front = { x = pos.x, y = pos.y - 1, z = pos.z + 1 }
        local pos0back = { x = pos.x, y = pos.y - 1, z = pos.z + -1 }
        local pos0right = { x = pos.x + 1, y = pos.y - 1, z = pos.z }
        local pos0left = { x = pos.x - 1, y = pos.y - 1, z = pos.z }

        local pos1front = { x = pos.x, y = pos.y, z = pos.z + 1 }
        local pos1back = { x = pos.x, y = pos.y, z = pos.z + -1 }
        local pos1right = { x = pos.x + 1, y = pos.y, z = pos.z }
        local pos1left = { x = pos.x - 1, y = pos.y, z = pos.z }

        local node0front = minetest.get_node(pos0front)
        local node0back = minetest.get_node(pos0back)
        local node0right = minetest.get_node(pos0right)
        local node0left = minetest.get_node(pos0left)

        local node1front = minetest.get_node(pos1front)
        local node1back = minetest.get_node(pos1back)
        local node1right = minetest.get_node(pos1right)
        local node1left = minetest.get_node(pos1left)

        local sneakyhover = false

        -- Check for air something and set sneakyhover if found
        if node0front.name == "air" and node1front.name ~= "air" then
            sneakyhover = true
        elseif node0back.name == "air" and node1back.name ~= "air" then
            sneakyhover = true
        elseif node0right.name == "air" and node1right.name ~= "air" then
            sneakyhover = true
        elseif node0left.name == "air" and node1left.name ~= "air" then
            sneakyhover = true
        end

        if sneakyhover then
            player:set_physics_override( { gravity = 0, jump = 1 } )
            if (node1below.name == "air") then
                minetest.place_node(pos1below, { name = "sneaky:sneaky" } )
            end
            if (node2below.name == "sneaky:sneaky") then
                minetest.remove_node(pos2below)
            end
            return
        end
    end

    -- Reset the original settings. Better implementation is obviously
    -- to backup the original settings and restore them ... Also remove
    -- sneaky nodes so that the player will start falling
    player:set_physics_override( { gravity = 1, jump = 1 } )
    if (node0below.name == "sneaky:sneaky") then
        minetest.remove_node(pos0below)
    end
    if (node1below.name == "sneaky:sneaky") then
        minetest.remove_node(pos1below)
    end
    if (node2below.name == "sneaky:sneaky") then
        minetest.remove_node(pos2below)
    end

end)
