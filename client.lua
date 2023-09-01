_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Prop menu", "~b~Spawn props")
_menuPool:Add(mainMenu)
_menuPool:MouseEdgeEnabled(false)

function createObject(id)
    return CreateObject(id, 0,0,0, true, false, false)
end

function reduceOpacity(entity)
    SetEntityAlpha(entity, 102, false)
end

function fullOpacity(entity)
    SetEntityAlpha(entity, 255, false)
end

function disableCollisions(entity)
    SetEntityCollision(entity, false, false)
end

function enableCollisions(entity)
    SetEntityCollision(entity, true, true)
end

function bringObject(entity)
    SetEntityCoords(entity, GetEntityCoords(PlayerPedId()), false, false, false, false)
end

function spawnObject(id)
    local object = createObject(id)
    reduceOpacity(object)
    disableCollisions(object)
    bringObject(object)
    return object
end

function setObject(entity, hasPhysics)
    fullOpacity(entity)
    enableCollisions(entity)
    SetEntityAsMissionEntity(entity, true, true)
    if not hasPhysics then
        FreezeEntityPosition(entity, true)
    end
end

function rotateObject(entity)
    local heading = GetEntityHeading(entity)
    SetEntityHeading(entity, heading + 10)
end

function deleteObject(entity)
    DeleteEntity(entity)
end

function moveUp(entity)
    local coords = GetEntityCoords(entity)
    SetEntityCoords(entity, coords.x, coords.y, coords.z + 0.1, false, false, false, false)
end

function moveDown(entity)
    local coords = GetEntityCoords(entity)
    SetEntityCoords(entity, coords.x, coords.y, coords.z - 0.1, false, false, false, false)
end


-- Add props here
-- ["key"] = {"name", "model", hasPhysics}
-- You can put anything in key
-- Physics if you want to enable the props physics
-- Some props will fall through the ground if you enable physics
local items = {
    ["cone"] = {"Traffic cone", "prop_mp_cone_02", true},
}


function addSubmenu(menu, object)
    local submenu = _menuPool:AddSubMenu(menu, items[object][1])
    _menuPool:MouseEdgeEnabled(false)
    local spawn = NativeUI.CreateItem("Spawn", "Spawn the prop")
    local rotate = NativeUI.CreateItem("Rotate", "Rotate the prop")
    local moveup = NativeUI.CreateItem("Move up", "Move the prop up")
    local movedown = NativeUI.CreateItem("Move down", "Move the prop down")
    local finish = NativeUI.CreateItem("Finish", "Complete the spawn")
    local objectcreated = nil
    local spawned = false
    submenu:AddItem(spawn)
    submenu:AddItem(rotate)
    submenu:AddItem(moveup)
    submenu:AddItem(movedown)
    submenu:AddItem(finish)
    submenu.OnItemSelect = function(sender, item, index)
        if item == spawn and objectcreated == nil then
            objectcreated = spawnObject(items[object][2])
        elseif item == rotate and objectcreated ~= nil then
            rotateObject(objectcreated)
        elseif item == moveup and objectcreated ~= nil then
            moveUp(objectcreated)
        elseif item == movedown and objectcreated ~= nil then
            moveDown(objectcreated)
        elseif item == finish and objectcreated ~= nil then
            setObject(objectcreated, items[object][3])
            spawned = true
            submenu:GoBack()
        end
    end
    submenu.OnMenuChanged = function(menu, newmenu, forward)
        if not spawned then
            deleteObject(objectcreated)
        else
            spawned = false
            
        end
        objectcreated = nil
    end
end

for key, value in pairs(items) do
    addSubmenu(mainMenu, key)
end

_menuPool:RefreshIndex()

RegisterCommand("propmenu", function(source, args, rawCommand)
    mainMenu:Visible(not mainMenu:Visible())
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
    end
end)