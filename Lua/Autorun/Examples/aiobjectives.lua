--[[
    This example shows how to give AI objectives using code.
--]]

if CLIENT and Game.IsMultiplayer then return end -- lets this run if on the server-side, if it's multiplayer, doesn't let it run on the client, and if it's singleplayer, lets it run on the client.

local function FightMe(target)
    for key, value in pairs(Character.CharacterList) do
        if value.IsBot and value.IsHuman then
            local ai = value.AIController
            ai.AddCombatObjective(AIObjectiveCombat.CombatMode.Offensive, target)
        end
    end
end

local function Come(target)
    for key, value in pairs(Character.CharacterList) do
        if value.IsBot and value.IsHuman then
            local manager = value.AIController.ObjectiveManager

            manager.AddObjective(AIObjectiveGoTo(target, value, manager))
        end
    end
end

local function RandomItem()
    local potential = {}
    for key, value in pairs(Submarine.MainSub.GetItems(true)) do
        if value.ParentInventory == nil and value.PhysicsBodyActive then
            table.insert(potential, value)
        end
    end

    return potential[math.random(1, #potential)]
end

local function GetItem()
    for key, value in pairs(Character.CharacterList) do
        if value.IsBot and value.IsHuman then
            local manager = value.AIController.ObjectiveManager

            local item = RandomItem()

            print("added objective to get item " .. item.Name)
            
            manager.AddObjective(AIObjectiveGoTo(target, value, manager))
            manager.AddObjective(AIObjectiveGetItem(value, item, manager, false, 99))
        end
    end
end

local function PlaceItemCabinet()
    for key, character in pairs(Character.CharacterList) do
        if character.IsBot and character.IsHuman and not character.IsDead then
            local manager = character.AIController.ObjectiveManager

            local item = RandomItem()

            print("added objective to get item " .. item.Name)
            
            local moveObjective = AIObjectiveGoTo(item, character, manager)
            manager.AddObjective(moveObjective)
            moveObjective.Completed.add(function ()
                print(character.Inventory.TryPutItem(item, character))
                local cabinet = Character.Controlled.SelectedItem
                local moveObjective2 = AIObjectiveGoTo(cabinet, character, manager)
                moveObjective2.ForceHighestPriority = true
                manager.AddObjective(moveObjective2)
                moveObjective2.Completed.add(function ()
                    print(cabinet.OwnInventory.TryPutItem(item, character))
                end)
            end)
            break
        end
    end
end

Hook.Add("chatMessage", "examples.aiObjectives", function (message, client)    
    local target = client and client.Character or Character.Controlled
    
    if message == "!fightme" then
        FightMe(target)
    end

    if message == "!come" then
        Come(target)
    end

    if message == "!getitem" then
        GetItem()
    end

    if message == "!placeitem" then
        PlaceItemCabinet()
    end
end)
