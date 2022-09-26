## How to use this resource

This is purely released as a dev helper and is not going to work without edits. No guarantees of functionality is given for your specific use case.

To use it: change all the exports used into qbr-core specific ones, and edit any of the specific triggers / functions included to work with your setup.

This resource does currently not utilize any spawn select system. And should just spawn your character upon creation

### `qbr-core/client/events.lua`

This is just a example of how to use this resource with QBR-core.

```lua
AddEventHandler("playerSpawned", function()
	TriggerEvent("QBCore:Client:InitialLoad")
end)

RegisterNetEvent("QBCore:Client:InitialLoad", function()
	DoScreenFadeOut(500)
	NetworkSetEntityInvisibleToNetwork(PlayerPedId(), true)
	SetEntityVisible(PlayerPedId(), false)
	GetInteriorAtCoords(-558.9098, -3775.616, 238.59, 137.98)
	SetEntityCoords(PlayerPedId(), -561.8157, -3780.966, 239.0805)
	TriggerEvent("d-character:client:initCharSelect")
end)

```
