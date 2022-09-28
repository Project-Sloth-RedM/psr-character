local PSRCore = exports["psr-core"]:GetCoreObject()

local promptGroup = nil
local inSelector, inCustomization = false, false
local lightsEnabled = {
	selector = false,
	customization = false,
}

local currentMenu = nil
local uiSkin = {}
local uiClothing = {}
local uiFeatures = {}

local numberTable = {}
for tempNum = 0, 200, 1 do
	numberTable[#numberTable + 1] = tempNum
end

local campSpawned = false
local extraProps = {}
local characterSpawns = {
	{
		ped = nil,
		cid = nil,
		previewing = false,
		animation = "sit",
		coords = vector4(3778.8779296875, -872.29132080078, 42.764137268066, 303.02612304688),
	}, -- sitting on chair
	{
		ped = nil,
		cid = nil,
		previewing = false,
		animation = "stand",
		coords = vector4(3778.5952148438, -871.21923828125, 41.266132354736, 279.46871948242),
	}, -- standing
	{
		ped = nil,
		cid = nil,
		previewing = false,
		animation = "sit",
		coords = vector4(3778.66796875, -869.89758300781, 42.758773803711, 240.38568115234),
	}, -- sitting on chair
	{
		ped = nil,
		cid = nil,
		previewing = false,
		animation = "sit",
		coords = vector4(3780.5869140625, -868.87677001953, 42.760597229004, 170.3920135498),
	}, -- sitting on chair
}
local createNextPed = nil
local temporaryPed = nil
local currentPed = nil

local currentCamera = nil
local groundCamera, fixedCamera, spawnCam = nil, nil, nil
local tempCamera, tempCamera2 = nil, nil
local interP, interP2 = false, false
local interPSettings = {
	cam1 = vec3(-0.5, 0.0, -0.7),
	cam2 = vec3(-0.5, 0.0, 0.6),
	cam3 = vec3(-1.5, 0.0, 0.0),
}

local Skin = {}
local Clothing = {}
local CharacterData = {}
local TempCharacterData = {}
local DefaultCharacterSkin = {}

Skin["Male"] = {}
Skin["Female"] = {}
Clothing["Male"] = {}
Clothing["Female"] = {}
CharacterData["Sex"] = nil
CharacterData["Skin"] = {}
CharacterData["Features"] = {}
CharacterData["Clothing"] = {}
TempCharacterData["Sex"] = nil
TempCharacterData["Skin"] = {}
TempCharacterData["Features"] = {}
TempCharacterData["Clothing"] = {}
TempCharacterData["Info"] = {
	["Firstname"] = nil,
	["Lastname"] = nil,
	["Age"] = nil,
	["Nationality"] = nil,
}

local ShowBusyspinnerWithText = function(text)
	N_0x7f78cd75cc4539e4(CreateVarString(10, "LITERAL_STRING", text))
end

local SendReactMessage = function(action, data)
	SendNUIMessage({
		action = action,
		data = data,
	})
end

local GetDonationTierFromLicense = function(license)
	PSRCore.Functions.TriggerCallback("d-character:server:GetDonationTierFromLicense", function(tier)
		return tier
	end, license)
end

local createLights = function(area)
	CreateThread(function()
		while inSelector do
			Wait(0)
			if lightsEnabled["selector"] then
				DrawLightWithRange(-559.59, -3780.75, 238.59, 255, 255, 255, 50.0, 50.0)
			end

			if lightsEnabled["customization"] then
				local coords = GetEntityCoords(createNextPed)
				DrawLightWithRange(coords.x - 10.0, coords.y, coords.z, 255, 255, 255, 25.0, 25.0)
			end
		end
	end)
end

local createCamera = function()
	DoScreenFadeOut(500)
	Wait(500)

	groundCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA")
	SetCamCoord(groundCamera, 3792.8193359375, -874.7607421875, 42.797107696533)
	SetCamRot(groundCamera, -20.0, 0.0, 45.0)
	SetCamActive(groundCamera, true)
	RenderScriptCams(true, false, 1, true, true)

	Wait(250)
	DoScreenFadeIn(500)

	fixedCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA")
	SetCamCoord(fixedCamera, 3783.4423828125, -873.37963867188, 42.522724151611)
	SetCamRot(fixedCamera, -5.0, 0.0, 42.0)
	SetCamActive(fixedCamera, true)
	SetCamActiveWithInterp(fixedCamera, groundCamera, 3900, true, true)
	Wait(4000)

	DestroyCam(groundCamera)
	interP = true
end

local interpCamera = function(entity)
	SetCamActiveWithInterp(fixedCamera, tempCamera, 1200, true, true)
	tempCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA")
	AttachCamToEntity(tempCamera, entity, interPSettings["cam3"].x, interPSettings["cam3"].y, interPSettings["cam3"].z)
	SetCamActive(tempCamera, true)
	SetCamRot(tempCamera, -4.0, 0, 270.0)
	if interP then
		SetCamActiveWithInterp(tempCamera, fixedCamera, 1200, true, true)
		interP = false
	end
end

local interpCamera2 = function(camera, entity)
	SetCamActiveWithInterp(fixedCamera, tempCamera, 1200, true, true)
	tempCamera2 = CreateCam("DEFAULT_SCRIPTED_CAMERA")
	AttachCamToEntity(tempCamera2, entity, interPSettings[camera].x, interPSettings[camera].y, interPSettings[camera].z)
	SetCamActive(tempCamera2, true)
	SetCamRot(tempCamera2, 0.0, 0, 270.0)
	if interP2 then
		SetCamActiveWithInterp(tempCamera2, tempCamera, 1200, true, true)
		interP2 = false
	end
end

local switchCamera = function()
	if currentCamera == "cam1" then
		currentCamera = "cam2"
		interpCamera2("cam2", currentPed)
	elseif currentCamera == "cam2" then
		currentCamera = "cam3"
		interpCamera2("cam3", currentPed)
	elseif currentCamera == "cam3" then
		currentCamera = "cam1"
		interpCamera2("cam1", currentPed)
	end
end

local updateCharacterValue = function(ped, sex, name, value)
	TempCharacterData.Skin[name] = value or 0
	name = tostring(name) or nil
	value = tonumber(value) or 0

	if name == "BODIES_UPPER" then
		Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, true, true)
		Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, true, true)
		Citizen.InvokeNative(0x704C908E9C405136, ped)

		Wait(10)
		Citizen.InvokeNative(0x704C908E9C405136, ped)
		Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)
	elseif name == "heads" then
		Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, true, true)
	elseif name == "hair" then
		if value == 0 then
			Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0x864B03AE, 0)
			Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)
		else
			Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, true, true)
		end
	elseif name == "teeth" then
		RequestAnimDict("FACE_HUMAN@GEN_MALE@BASE")
		while not HasAnimDictLoaded("FACE_HUMAN@GEN_MALE@BASE") do
			Citizen.Wait(100)
		end
		TaskPlayAnim(ped, "FACE_HUMAN@GEN_MALE@BASE", "Face_Dentistry_Loop", 1090519040, -4, -1, 17, 0, 0, 0, 0, 0, 0)
		Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, true, true)
	elseif name == "eyes" then
		Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, true, true)
	elseif name == "beards_complete" then
		if value == 0 then
			Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0x864B03AE, 0)
			Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)
		else
			if sex == "Male" then
				Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, true, true)
			end
		end
	end
end

local updateCharacterClothing = function(ped, sex, name, value)
	TempCharacterData.Clothing[name] = value or nil
	name = tostring(name) or nil
	value = tonumber(value) or nil

	Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey(name), 0)
	if name == "shirts_full" then
		Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, true, true)
	elseif name == "boots" or name == "pants" then
		Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, true, true)
	end

	Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, true, true)

	Citizen.InvokeNative(0x704C908E9C405136, ped)
	Citizen.InvokeNative(0xAAB86462966168CE, ped, 1)
	Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)
end

local updateCharacterFace = function(index, value)
	local index = tonumber(index)
	local value = tonumber(value)

	TempCharacterData.Features[index] = value or 0.0

	Citizen.InvokeNative(0x5653AB26C82938CF, currentPed, index, value)
	Citizen.InvokeNative(0xCC8CA3E88256E58F, currentPed, 0, 1, 1, 1, 0)
end

local fixCharacterValues = function(ped, sex)
	Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, 0, 0)
	while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped) do
		Wait(0)
	end

	Citizen.InvokeNative(0x0BFA1BD465CDFEFD, ped)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, Skin[sex]["BODIES_UPPER"][1], false, true, true)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, Skin[sex]["BODIES_LOWER"][1], false, true, true)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, Skin[sex]["heads"][1], false, true, true)
	Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0x1D4C528A, 0)
	Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0x3F1F01E5, 0)
	Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0xDA0E2C55, 0)
	Citizen.InvokeNative(0x704C908E9C405136, ped)
	Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)
end

local GeneratePlayerModel = function(ped, sex, skin, clothing)
	local skin = skin or CharacterData["Skin"]
	local clothing = clothing or CharacterData["Clothing"]
	local ped = ped or PlayerPedId()

	fixCharacterValues(ped, sex)

	if skin and clothing then
		for k, v in pairs(skin) do
			updateCharacterValue(ped, sex, k, v, false)
		end

		for k, v in pairs(clothing) do
			updateCharacterClothing(ped, sex, k, v, false)
		end

		Wait(250)
		Citizen.InvokeNative(0x704C908E9C405136, ped)
		Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)

		return true
	else
		print("Failed to generate player model!", "No data available")
		return false
	end
end

local createTemporaryPed = function(new, sex, skin, clothing)
	local sex = sex or "Male"
	local model = sex == "Male" and GetHashKey("mp_male") or GetHashKey("mp_female")

	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end

	if temporaryPed then
		DeletePed(temporaryPed)
		Wait(500)
	end

	temporaryPed = CreatePed(model, -558.9098, -3775.616, 238.59 - 0.5, 137.98, false, 0)
	currentPed = temporaryPed

	NetworkSetEntityInvisibleToNetwork(currentPed, true)

	if new then
		fixCharacterValues(currentPed, sex)
	else
		local bool = GeneratePlayerModel(currentPed, sex, skin, clothing)
	end
end

local fetchTrueValue = function(type, hash)
	for i = 1, #Skin[TempCharacterData["Sex"]][type], 1 do
		if Skin[TempCharacterData["Sex"]][type][i] == hash then
			return i
		end
	end
end

local fetchTrueClothingValue = function(type, hash)
	for i = 1, #Clothing[TempCharacterData["Sex"]][type], 1 do
		if Clothing[TempCharacterData["Sex"]][type][i] == hash then
			return i
		end
	end
end

local fetchFaceValues = function()
	local rTable = {}

	for k, v in pairs(Config.FaceFeatures) do
		rTable[k] = { hash = v, name = k, values = numberTable }
	end

	return rTable
end

local fetchSkinValues = function()
	local rTable = {}

	for k, v in pairs(Skin[TempCharacterData["Sex"]]) do
		rTable[k] = {}
		TempCharacterData.Skin[k] = v[1]

		for i = 1, #v, 1 do
			rTable[k][#rTable[k] + 1] = v[i]
		end
	end

	return rTable
end

local fetchClothingValues = function()
	local rTable = {}

	for k, v in pairs(Clothing[TempCharacterData["Sex"]]) do
		rTable[k] = {}
		rTable[k][1] = "None"
		for i = 1, #v, 1 do
			rTable[k][#rTable[k] + 1] = v[i]
		end
	end

	return rTable
end

-- local registerFaceFeaturesMenu = function()
-- 	if not TempCharacterData["Sex"] then
-- 		local sex = IsPedMale(PlayerPedId()) and "Male" or "Female"
-- 		TempCharacterData["Sex"] = sex
-- 	end

-- 	local optionValues = fetchFaceValues()
-- 	local options = {}

-- 	for k, v in pairs(optionValues) do
-- 		options[#options + 1] = {
-- 			label = PSRCore.Functions.SplitStr(k, "_"),
-- 			values = v.numbers,
-- 			defaultIndex = CharacterData.Features[k] or 1,
-- 			args = { type = k },
-- 		}
-- 	end

-- 	lib.registerMenu({
-- 		id = "character_facefeatures_menu",
-- 		title = "Face Features",
-- 		position = "top-right",
-- 		onSideScroll = function(selected, scrollIndex, args)
-- 			updateCharacterFace(optionValues[args["type"]]["hash"], ((scrollIndex - 101) / 100))
-- 			Wait(250)
-- 			Citizen.InvokeNative(0x704C908E9C405136, ped)
-- 			Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)
-- 		end,
-- 		onSelected = function(selected, scrollIndex, args)
-- 			print(selected, scrollIndex, json.encode(args))
-- 		end,
-- 		onClose = function()
-- 			print("Menu Closed")
-- 			lib.showMenu("character_creator_menu")
-- 		end,
-- 		options = options,
-- 	}, function(selected, scrollIndex, args)
-- 		lib.showMenu("character_creator_menu")
-- 	end)
-- end

local openFaceFeaturesMenu = function()
	if not TempCharacterData["Sex"] then
		local sex = IsPedMale(PlayerPedId()) and "Male" or "Female"
		TempCharacterData["Sex"] = sex
	end

	local optionValues = fetchFaceValues()
	local options = {}

	for k, v in pairs(optionValues) do
		uiFeatures[#uiFeatures + 1] = {
			id = (#uiFeatures + 1),
			type = k,
			label = PSRCore.Shared.SplitStr(k, "_"),
			values = v.values,
			value = CharacterData.Features[k] or 100,
		}
	end

	currentMenu = "faceMenu"

	SetNuiFocus(true, true)
	SendReactMessage("setInitialData", {
		cloth = uiFeatures,
		title = "Face Features Menu",
	})

	SendReactMessage("setMenu", "scrollMenu")
	SendReactMessage("setVisible", true)
end

local openClothingMenu = function()
	if not TempCharacterData["Sex"] then
		local sex = IsPedMale(PlayerPedId()) and "Male" or "Female"
		TempCharacterData["Sex"] = sex
	end

	local clothingValues = fetchClothingValues()

	for k, v in pairs(clothingValues) do
		uiClothing[#uiClothing + 1] = {
			id = (#uiClothing + 1),
			type = k,
			label = PSRCore.Shared.SplitStr(k, "_"),
			values = v,
			value = CharacterData.Clothing[k] or 1,
		}
	end

	currentMenu = "clothingMenu"

	SetNuiFocus(true, true)
	SendReactMessage("setInitialData", {
		cloth = uiClothing,
		title = "Clothing Menu",
	})

	SendReactMessage("setMenu", "scrollMenu")
	SendReactMessage("setVisible", true)
end

local openCreatorMenu = function()
	if not TempCharacterData["Sex"] then
		local sex = IsPedMale(PlayerPedId()) and "Male" or "Female"
		TempCharacterData["Sex"] = sex
	end

	local optionValues = fetchSkinValues()

	uiSkin = {
		{
			id = 1,
			label = "Body",
			type = "BODIES_UPPER",
			values = optionValues["BODIES_UPPER"],
			value = CharacterData.Skin["body"] or 0,
		},
		{
			id = 2,
			label = "Heads",
			type = "heads",
			values = optionValues["heads"],
			value = CharacterData.Skin["heads"] or 0,
		},
		{
			id = 3,
			label = "Hair",
			type = "hair",
			values = optionValues["hair"],
			value = CharacterData.Skin["hair"] or 0,
		},
		{
			id = 4,
			label = "Teeth",
			type = "teeth",
			values = optionValues["teeth"],
			value = CharacterData.Skin["teeth"] or 0,
		},
		{
			id = 5,
			label = "Eyes",
			type = "eyes",
			values = optionValues["eyes"],
			value = CharacterData.Skin["eyes"] or 0,
		},
	}

	if TempCharacterData["Sex"] == "Male" then
		uiSkin[#uiSkin + 1] = {
			id = 6,
			label = "Beards",
			type = "beards_complete",
			values = optionValues["beards_complete"],
			value = CharacterData.Skin["beards_complete"] or 0,
		}
	end

	currentMenu = "skinMenu"

	SetNuiFocus(true, true)
	SendReactMessage("setInitialData", {
		cloth = uiSkin,
		title = "Skin Menu",
	})

	SendReactMessage("setMenu", "scrollMenu")
	SendReactMessage("setVisible", true)
end

local openSpawnMenu = function()
	local entityCoords = GetEntityCoords(PlayerPedId())
	SetEntityVisible(PlayerPedId(), false)
	DoScreenFadeOut(250)
	Wait(1000)
	DoScreenFadeIn(250)

	spawnCam = CreateCamWithParams(
		"DEFAULT_SCRIPTED_CAMERA",
		entityCoords.x,
		entityCoords.y,
		entityCoords.z + 1500,
		-85.00,
		0.00,
		0.00,
		100.00,
		false,
		0
	)
	SetCamActive(spawnCam, true)
	RenderScriptCams(true, false, 1, true, true)

	Wait(500)

	currentMenu = "spawnMenu"

	SetNuiFocus(true, true)

	local options = {}
	for k, v in pairs(Config.SpawnLocations) do
		options[#options + 1] = {
			label = k,
			coords = v,
		}
	end

	SendReactMessage("setSpawnData", {
		locations = options,
		title = "Select Spawn",
	})

	SendReactMessage("setMenu", "spawnMenu")
	SendReactMessage("setVisible", true)
end

local spawnCamp = function()
	-- GENERIC_SIT_GROUND_SCENARIO
	-- WORLD_CAMP_FIRE_SIT_GROUND

	-- WORLD_CAMP_FIRE_STANDING

	-- WORLD_CAMP_JACK_SIT_GROUND

	-- WORLD_HUMAN_FIRE_SIT

	-- WORLD_HUMAN_FIRE_GEN_SIT

	-- WORLD_HUMAN_FIRE_GEN_SIT_COLD

	-- WORLD_HUMAN_SIT_BACK

	-- WORLD_HUMAN_SIT_GROUND

	-- WORLD_HUMAN_SIT_SMOKE

	-- WORLD_PLAYER_CAMP_FIRE_SIT
	-- WORLD_PLAYER_CAMP_FIRE_SIT_TENT

	-- GENERIC_SEAT_CHAIR_SCENARIO
	-- GFH_PROP_HUMAN_SEAT_CHAIR_KNIFE_BADASS

	-- MP_LOBBY_PROP_HUMAN_SEAT_CHAIR
	-- MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_KNIFE_BADASS
	-- MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_WHITTLE

	-- PROP_CAMP_FIRE_SEAT_CHAIR
	-- PROP_CAMP_HOSEA_SEAT_CHAIR_CARVE_FLOAT

	-- PROP_CAMP_MICAH_SEAT_CHAIR_CLEAN_GUN

	-- PROP_CAMP_SEAT_CHAIR_STEW

	-- PROP_HUMAN_SEAT_CHAIR
	-- PROP_HUMAN_SEAT_CHAIR_CIGAR

	if campSpawned then
		Citizen.InvokeNative(0x58AC173A55D9D7B4, campSpawned)
		Wait(250)
	else
		-- local propsetName = "pg_mp007_naturalist_camp01x"
		-- local propsetName = "pg_re_lemoyneraiders01x"
		-- local propsetName = "pg_re_moonshinecampgroup02x"
		-- local propsetName = "pg_re_odoriscollboysgang02x"
		-- local propsetName = "pg_re_possebreakout01x"
		-- local propsetName = "PG_MP_POSSECAMP_CAMPFIRE_LARGE002X"
		-- local propsetName = "pg_mp_possecamp_campfire_large001x"
		local propsetName = "pg_mp_campfire03x"
		local propsetHash = GetHashKey(propsetName)
		local spawnCoords = vector4(3780.18359375, -870.88873291016, 42.306533813477, 82.850036621094)

		Citizen.InvokeNative(0xF3DE57A46D5585E9, propsetHash)
		while not Citizen.InvokeNative(0x48A88FC684C55FDC, propsetHash) do
			Wait(50)
		end

		-- p_lantern05x
		-- p_lanternstick09x
		-- 3778.8779296875, -872.29132080078, 42.764137268066

		if Citizen.InvokeNative(0x48A88FC684C55FDC, propsetHash) then
			campSpawned = Citizen.InvokeNative(
				0x899C97A1CCE7D483,
				propsetHash,
				spawnCoords.x,
				spawnCoords.y,
				spawnCoords.z,
				0,
				240.0,
				1200.0,
				false,
				true
			)

			extraProps = CreateObject(
				GetHashKey(p_lantern05x),
				3776.8779296875,
				-870.29132080078,
				42.764137268066,
				false,
				false,
				true
			)
			PlaceObjectOnGroundProperly(extraProps)

			-- PlayAnimation
			-- PROP_CAMP_FIRE_SEAT_CHAIR

			-- CreateThread(function()
			-- 	while true do
			-- 		if campSpawned then
			-- 			for i = 1, #characterSpawns, 1 do
			-- 				Citizen.InvokeNative(
			-- 					0x524B54361229154F,
			-- 					characterSpawns[i].ped,
			-- 					GetHashKey("WORLD_HUMAN_FIRE_SIT"),
			-- 					0,
			-- 					1,
			-- 					false,
			-- 					-1.0,
			-- 					0
			-- 				)
			-- 			end

			-- 			Wait(0)
			-- 		else
			-- 			Wait(1000)
			-- 		end
			-- 	end
			-- end)
		end

		Citizen.InvokeNative(0xB1964A83B345B4AB, propsetHash)
	end
end

RegisterCommand("debug2", function(source, args, rawCommand)
	spawnCamp()
end, false)

RegisterNUICallback("updateMenuVariable", function(res)
	local type = res.type
	local id = res.id

	if currentMenu == "skinMenu" then
		local skinHash = nil
		local skinType = nil

		for i = 1, #uiSkin, 1 do
			if uiSkin[i].id == id then
				uiSkin[i].value = type == "decrease" and uiSkin[i].value - 1 or uiSkin[i].value + 1
				skinHash = uiSkin[i].values[uiSkin[i].value]
				skinType = uiSkin[i].type
			end
		end

		updateCharacterValue(currentPed, TempCharacterData["Sex"], skinType, skinHash)
		Citizen.InvokeNative(0x704C908E9C405136, currentPed)
		Citizen.InvokeNative(0xCC8CA3E88256E58F, currentPed, 0, 1, 1, 1, 0)
	elseif currentMenu == "clothingMenu" then
		local skinHash = nil
		local skinType = nil

		for i = 1, #uiClothing, 1 do
			if uiClothing[i].id == id then
				uiClothing[i].value = type == "decrease" and uiClothing[i].value - 1 or uiClothing[i].value + 1
				skinHash = uiClothing[i].values[uiClothing[i].value]
				skinType = uiClothing[i].type
			end
		end

		updateCharacterClothing(currentPed, TempCharacterData["Sex"], skinType, skinHash)
		Citizen.InvokeNative(0x704C908E9C405136, currentPed)
		Citizen.InvokeNative(0xCC8CA3E88256E58F, currentPed, 0, 1, 1, 1, 0)
	elseif currentMenu == "faceMenu" then
		local faceHash = nil
		-- local faceType = nil
		local faceValue = nil

		for i = 1, #uiFeatures, 1 do
			if uiFeatures[i].id == id then
				if type == "decrease" then
					if uiFeatures[i].value > 0 then
						uiFeatures[i].value = uiFeatures[i].value - 1
					end
				elseif type == "increase" then
					if uiFeatures[i].value < 200 then
						uiFeatures[i].value = uiFeatures[i].value + 1
					end
				end

				faceValue = (uiFeatures[i].value - 100) / 100
				faceHash = Config.FaceFeatures[uiFeatures[i].type]

				-- if uiFeatures[i].value > -100 and uiFeatures[i].value < 100 then

				-- 	uiFeatures[i].value = type == "decrease" and uiFeatures[i].value - 1 or uiFeatures[i].value + 1
				-- 	faceValue = (uiFeatures[i].value - 100) / 100
				-- 	faceHash = Config.FaceFeatures[uiFeatures[i].type]
				-- end
			end
		end

		updateCharacterFace(faceHash, faceValue)
	end
end)

RegisterNUICallback("selectSpawn", function(res)
	if temporaryPed then
		DeletePed(temporaryPed)
	end

	if campSpawned then
		Citizen.InvokeNative(0x58AC173A55D9D7B4, campSpawned)
	end

	if extraProps then
		SetEntityAsMissionEntity(extraProps)
		DeleteObject(extraProps)
	end

	for i = 1, #characterSpawns, 1 do
		if characterSpawns[i].ped then
			DeletePed(characterSpawns[i].ped)
		end
	end

	DoScreenFadeOut(200)
	Wait(500)

	DoScreenFadeIn(200)

	if DoesCamExist(spawnCam) then
		DestroyCam(spawnCam, true)
	end

	SendReactMessage("setVisible", false)
	SendReactMessage("resetModals")
	SetNuiFocus(false, false)

	SetEntityCoords(PlayerPedId(), res.x, res.y, res.z)
	SetEntityHeading(PlayerPedId(), res.h)
	FreezeEntityPosition(PlayerPedId(), false)
	TriggerServerEvent("PSRCore:Server:OnPlayerLoaded")
	TriggerEvent("PSRCore:Client:OnPlayerLoaded")

	RenderScriptCams(false, true, 500, true, true)
	SetCamActive(groundCamera, false)
	DestroyCam(groundCamera, true)
	SetCamActive(fixedCamera, false)
	DestroyCam(fixedCamera, true)

	SetEntityVisible(PlayerPedId(), true)
	NetworkSetEntityInvisibleToNetwork(PlayerPedId(), false)
	Wait(500)
	DoScreenFadeIn(250)
end)

RegisterNUICallback("cameraClicked", function(res)
	local camera = res
	if camera == "head" then
		interpCamera2("cam2", currentPed)
	elseif camera == "body" then
		interpCamera2("cam3", currentPed)
	elseif camera == "feet" then
		interpCamera2("cam1", currentPed)
	end
end)

RegisterNUICallback("continueClicked", function()
	if currentMenu == "skinMenu" then
		openFaceFeaturesMenu()
	elseif currentMenu == "faceMenu" then
		openClothingMenu()
	elseif currentMenu == "clothingMenu" then
		SetNuiFocus(false, false)
		SendReactMessage("setVisible", false)
		Wait(100)

		TriggerServerEvent("d-character:server:saveNewCharacter", TempCharacterData)
	end
end)

RegisterNUICallback("deleteCharacter", function(res)
	TriggerServerEvent("d-character:server:deleteCharacter", res.cid)
end)

RegisterNUICallback("previewCharacter", function(res)
	for i = 1, #characterSpawns, 1 do
		if characterSpawns[i].previewing then
			SetEntityAlpha(characterSpawns[i].ped, 200, false)
			characterSpawns[i].previewing = false
		end

		if characterSpawns[i].cid == res.cid then
			SetEntityAlpha(characterSpawns[i].ped, 255, false)
			characterSpawns[i].previewing = true
		end
	end
	-- createTemporaryPed(false, res.data.sex, res.data.skin, res.data.outfit)
end)

RegisterNUICallback("stopPreviewingCharacter", function(res)
	for i = 1, #characterSpawns, 1 do
		if characterSpawns[i].cid == res.cid then
			SetEntityAlpha(characterSpawns[i].ped, 200, false)
			characterSpawns[i].previewing = false
		end
	end
	-- createTemporaryPed(false, res.data.sex, res.data.skin, res.data.outfit)
end)

RegisterNUICallback("selectCharacter", function(res)
	SendReactMessage("setVisible", false)
	SetNuiFocus(false, false)

	TriggerServerEvent(
		"d-character:server:spawnPlayer",
		res.data.citizenid,
		res.data.skin,
		res.data.outfit,
		res.data.sex,
		false
	)
end)

RegisterNUICallback("createNewCharacter", function(res)
	SendReactMessage("setVisible", false)
	SendReactMessage("resetModals")
	SetNuiFocus(false, false)

	DoScreenFadeOut(1500)

	TempCharacterData["Info"]["Firstname"] = res.inputFirstname or "John"
	TempCharacterData["Info"]["Lastname"] = res.inputLastname or "Doe"
	TempCharacterData["Info"]["Age"] = res.inputDOB or "1890-01-01"
	TempCharacterData["Sex"] = res.inputGender or "Male"

	-- createTemporaryPed(true, TempCharacterData["Sex"])

	if IsPedMale(createNextPed) == 1 and TempCharacterData["Sex"] == "Female" then
		RequestModel(GetHashKey("mp_female"))
		while not HasModelLoaded(GetHashKey("mp_female")) do
			Wait(0)
		end

		local index = nil
		for i = 1, #characterSpawns, 1 do
			if characterSpawns[i].ped == createNextPed then
				characterSpawns[i].ped = CreatePed(
					GetHashKey("mp_female"),
					characterSpawns[i].coords.x,
					characterSpawns[i].coords.y,
					characterSpawns[i].coords.z - 0.5,
					characterSpawns[i].coords.w,
					false,
					0
				)

				SetEntityAsMissionEntity(createNextPed)
				DeletePed(createNextPed)
				Wait(250)

				createNextPed = characterSpawns[i].ped

				NetworkSetEntityInvisibleToNetwork(characterSpawns[i].ped, true)
				fixCharacterValues(characterSpawns[i].ped, "Female")
				SetEntityAlpha(characterSpawns[i].ped, 200, false)
				Wait(250)
			end
		end
	end

	currentPed = createNextPed

	interP = true
	interpCamera(currentPed)
	SetEntityAlpha(currentPed, 255, false)
	-- DoScreenFadeOut(1500)
	Wait(3000)

	for i = 1, #characterSpawns, 1 do
		if characterSpawns[i].ped ~= currentPed then
			DeletePed(characterSpawns[i].ped)
		end
	end

	ClearPedTasksImmediately(currentPed)
	SetEntityHeading(currentPed, 87.21)
	PlaySoundFrontend("gender_left", "RDRO_Character_Creator_Sounds", true, 0)
	-- Wait(2000)
	if currentPed then
		-- Wait(2000)
		interpCamera2("cam3", currentPed)
		currentCamera = "cam3"
		interP2 = true
		-- SetEntityCoords(createNextPed, -558.56, -3781.16, 237.59)
		-- SetEntityHeading(currentPed, 87.21)
		lightsEnabled["selector"] = false
		lightsEnabled["customization"] = true
		createLights("customization")
		inCustomization = true
		DoScreenFadeIn(1500)
		openCreatorMenu()
	end
end)

RegisterNetEvent("d-character:client:reloadSelect", function()
	SendReactMessage("resetModals")

	ShowBusyspinnerWithText("Loading your characters")

	Wait(1500)

	BusyspinnerOff()
	PSRCore.Functions.TriggerCallback("d-character:server:fetchCharacters", function(characters, licence)
		local PlayerTier = GetDonationTierFromLicense(license) or 0
		local options = {}
		if characters and #characters > 0 then
			for i = 1, #characters, 1 do
				options[#options + 1] = {
					name = characters[i].charinfo.firstname .. " " .. characters[i].charinfo.lastname,
					cid = characters[i].citizenid,
					data = {
						citizenid = characters[i].citizenid,
						sex = characters[i].charinfo.gender == 0 and "Male" or "Female",
						skin = characters[i].skin,
						outfit = characters[i].outfit,
					},
				}
			end

			currentMenu = nil

			SetNuiFocus(true, true)
			SendReactMessage("setCharacters", {
				characters = options,
				canCreate = (#characters < Config.MaxCharacters[PlayerTier]) and true or false,
			})

			SendReactMessage("setMenu", "charMenu")
			SendReactMessage("setVisible", true)
		else
			currentMenu = nil

			SetNuiFocus(true, true)
			SendReactMessage("setCharacters", {
				characters = {},
				canCreate = true,
			})

			SendReactMessage("setMenu", "charMenu")
			SendReactMessage("setVisible", true)
		end
	end)
end)

local spawnCampPlayers = function(characters)
	if characters then
		local PlayerTier = GetDonationTierFromLicense(license) or 0
		local canCreate = (#characters < Config.MaxCharacters[PlayerTier]) and true or false
		for i = 1, #characters, 1 do
			local sex = characters[i].charinfo.gender == 0 and "Male" or "Female"
			local model = sex == "Male" and "mp_male" or "mp_female"
			local skin = characters[i].skin
			local outfit = characters[i].outfit

			RequestModel(GetHashKey(model))
			while not HasModelLoaded(GetHashKey(model)) do
				Wait(0)
			end

			if characterSpawns[i].ped == nil then
				characterSpawns[i].ped = CreatePed(
					GetHashKey(model),
					characterSpawns[i].coords.x,
					characterSpawns[i].coords.y,
					characterSpawns[i].coords.z - 0.5,
					characterSpawns[i].coords.w,
					false,
					0
				)
				characterSpawns[i].cid = characters[i].citizenid
				NetworkSetEntityInvisibleToNetwork(characterSpawns[i].ped, true)

				if sex == "Female" then
					SetPedOutfitPreset(characterSpawns[i].ped, 17)
					Citizen.InvokeNative(0xD710A5007C2AC539, characterSpawns[i].ped, 0x9925C067, 0)
					Citizen.InvokeNative(0xCC8CA3E88256E58F, characterSpawns[i].ped, 0, 1, 1, 1, 0)
				else
					SetPedOutfitPreset(characterSpawns[i].ped, 43)
				end

				Citizen.InvokeNative(0x77FF8D35EEC6BBC4, characterSpawns[i].ped, 0, 0)
				Citizen.InvokeNative(0x0BFA1BD465CDFEFD, characterSpawns[i].ped)
				Citizen.InvokeNative(0xD710A5007C2AC539, characterSpawns[i].ped, 0x1D4C528A, 0)
				Citizen.InvokeNative(0xD710A5007C2AC539, characterSpawns[i].ped, 0x3F1F01E5, 0)
				Citizen.InvokeNative(0xD710A5007C2AC539, characterSpawns[i].ped, 0xDA0E2C55, 0)
				Citizen.InvokeNative(0x704C908E9C405136, characterSpawns[i].ped)
				Citizen.InvokeNative(0xCC8CA3E88256E58F, characterSpawns[i].ped, 0, 1, 1, 1, 0)

				local bool = GeneratePlayerModel(characterSpawns[i].ped, sex, skin, outfit)
				Wait(250)
				SetEntityAlpha(characterSpawns[i].ped, 200, false)
				Wait(250)

				if characterSpawns[i].animation == "sit" then
					TaskStartScenarioAtPosition(
						characterSpawns[i].ped,
						GetHashKey("PROP_HUMAN_SEAT_CHAIR"),
						characterSpawns[i].coords.x,
						characterSpawns[i].coords.y,
						characterSpawns[i].coords.z - 1.0,
						characterSpawns[i].coords.w,
						-1,
						false,
						true
					)
				else
					TaskStartScenarioAtPosition(
						characterSpawns[i].ped,
						GetHashKey("WORLD_CAMP_FIRE_STANDING"),
						characterSpawns[i].coords.x,
						characterSpawns[i].coords.y,
						characterSpawns[i].coords.z - 0.5,
						characterSpawns[i].coords.w,
						-1,
						false,
						true
					)
				end
			end
		end

		if canCreate then
			RequestModel(GetHashKey("mp_male"))
			while not HasModelLoaded(GetHashKey("mp_male")) do
				Wait(0)
			end

			for i = 1, #characterSpawns, 1 do
				if characterSpawns[i].ped == nil then
					characterSpawns[i].ped = CreatePed(
						GetHashKey("mp_male"),
						characterSpawns[i].coords.x,
						characterSpawns[i].coords.y,
						characterSpawns[i].coords.z - 0.5,
						characterSpawns[i].coords.w,
						false,
						0
					)

					if createNextPed == nil then
						createNextPed = characterSpawns[i].ped
					end

					NetworkSetEntityInvisibleToNetwork(characterSpawns[i].ped, true)
					fixCharacterValues(characterSpawns[i].ped, "Male")
					SetEntityAlpha(characterSpawns[i].ped, 200, false)
					Wait(250)

					if characterSpawns[i].animation == "sit" then
						TaskStartScenarioAtPosition(
							characterSpawns[i].ped,
							GetHashKey("PROP_HUMAN_SEAT_CHAIR"),
							characterSpawns[i].coords.x,
							characterSpawns[i].coords.y,
							characterSpawns[i].coords.z - 1.0,
							characterSpawns[i].coords.w,
							-1,
							false,
							true
						)
					else
						TaskStartScenarioAtPosition(
							characterSpawns[i].ped,
							GetHashKey("WORLD_CAMP_FIRE_STANDING"),
							characterSpawns[i].coords.x,
							characterSpawns[i].coords.y,
							characterSpawns[i].coords.z - 0.5,
							characterSpawns[i].coords.w,
							-1,
							false,
							true
						)
					end
				end
			end
		end
	else
		RequestModel(GetHashKey("mp_male"))
		while not HasModelLoaded(GetHashKey("mp_male")) do
			Wait(0)
		end

		for i = 1, #characterSpawns, 1 do
			if characterSpawns[i].ped == nil then
				characterSpawns[i].ped = CreatePed(
					GetHashKey("mp_male"),
					characterSpawns[i].coords.x,
					characterSpawns[i].coords.y,
					characterSpawns[i].coords.z - 0.5,
					characterSpawns[i].coords.w,
					false,
					0
				)
				NetworkSetEntityInvisibleToNetwork(characterSpawns[i].ped, true)
				fixCharacterValues(characterSpawns[i].ped, "Male")
				SetEntityAlpha(characterSpawns[i].ped, 200, false)
				Wait(250)

				if characterSpawns[i].animation == "sit" then
					TaskStartScenarioAtPosition(
						characterSpawns[i].ped,
						GetHashKey("PROP_HUMAN_SEAT_CHAIR"),
						characterSpawns[i].coords.x,
						characterSpawns[i].coords.y,
						characterSpawns[i].coords.z - 1.0,
						characterSpawns[i].coords.w,
						-1,
						false,
						true
					)
				else
					TaskStartScenarioAtPosition(
						characterSpawns[i].ped,
						GetHashKey("WORLD_CAMP_FIRE_STANDING"),
						characterSpawns[i].coords.x,
						characterSpawns[i].coords.y,
						characterSpawns[i].coords.z - 0.5,
						characterSpawns[i].coords.w,
						-1,
						false,
						true
					)
				end
			end
		end
	end
end

RegisterNetEvent("d-character:client:initCharSelect", function()
	-- local newCamera = vector4(3783.4423828125, -873.37963867188, 42.522724151611, 42.613109588623)
	-- DoScreenFadeOut(500)
	NetworkSetEntityInvisibleToNetwork(PlayerPedId(), true)
	SetEntityVisible(PlayerPedId(), false)

	ShowBusyspinnerWithText("Loading your characters")

	spawnCamp()

	ShutdownLoadingScreen()
	ShutdownLoadingScreenNui()

	SetEntityCoords(PlayerPedId(), 3783.4423828125, -873.37963867188, 42.522724151611)

	inSelector = true
	-- lightsEnabled["selector"] = true
	-- createLights("selector")
	-- Wait(500)
	DestroyAllCams(true)

	-- DoScreenFadeOut(500)
	-- DoScreenFadeIn(500)

	if not groundCamera then
		createCamera()
	end

	BusyspinnerOff()
	Wait(250)

	PSRCore.Functions.TriggerCallback("d-character:server:fetchCharacters", function(characters, licence)
		local PlayerTier = GetDonationTierFromLicense(license) or 0
		local options = {}
		if characters and #characters > 0 then
			for i = 1, #characters, 1 do
				options[#options + 1] = {
					name = characters[i].charinfo.firstname .. " " .. characters[i].charinfo.lastname,
					cid = characters[i].citizenid,
					data = {
						citizenid = characters[i].citizenid,
						sex = characters[i].charinfo.gender == 0 and "Male" or "Female",
						skin = characters[i].skin,
						outfit = characters[i].outfit,
					},
				}
			end

			spawnCampPlayers(characters)

			currentMenu = nil

			SetNuiFocus(true, true)
			SendReactMessage("setCharacters", {
				characters = options,
				canCreate = (#characters < Config.MaxCharacters[PlayerTier]) and true or false,
			})

			SendReactMessage("setMenu", "charMenu")
			SendReactMessage("setVisible", true)
		else
			spawnCampPlayers(false)

			currentMenu = nil

			SetNuiFocus(true, true)
			SendReactMessage("setCharacters", {
				characters = {},
				canCreate = true,
			})

			SendReactMessage("setMenu", "charMenu")
			SendReactMessage("setVisible", true)
		end
	end)
end)

AddEventHandler("onResourceStop", function()
	if temporaryPed then
		DeletePed(temporaryPed)
	end

	if campSpawned then
		Citizen.InvokeNative(0x58AC173A55D9D7B4, campSpawned)
	end

	-- if extraProps then
	-- 	SetEntityAsMissionEntity(extraProps)
	-- 	DeleteObject(extraProps)
	-- end

	for i = 1, #characterSpawns, 1 do
		if characterSpawns[i].ped then
			DeletePed(characterSpawns[i].ped)
		end
	end

	DestroyAllCams()
end)

RegisterNetEvent("d-character:client:loadCharacter", function(player, outfits)
	local skin = player.skin
	local outfit = {}
	local sex = json.decode(player.charinfo).gender

	if type(skin) ~= "table" then
		skin = json.decode(skin)
	end

	for i = 1, #outfits, 1 do
		if outfits[i].id == player.outfit then
			outfit = outfits[i].clothing
			break
		end
	end

	if type(outfit) ~= "table" then
		outfit = json.decode(outfit)
	end

	CharacterData["Sex"] = sex == 0 and "Male" or "Female"
	CharacterData["Skin"] = skin
	CharacterData["Clothing"] = outfit

	if CharacterData["Sex"] == "Female" then
		SetPedOutfitPreset(PlayerPedId(), 17)
		Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0x9925C067, 0)
		Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)
	else
		SetPedOutfitPreset(PlayerPedId(), 43)
	end

	Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 0, 0)
	Citizen.InvokeNative(0x0BFA1BD465CDFEFD, PlayerPedId())
	Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0x1D4C528A, 0)
	Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0x3F1F01E5, 0)
	Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0xDA0E2C55, 0)
	Citizen.InvokeNative(0x704C908E9C405136, PlayerPedId())
	Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)

	local bool = GeneratePlayerModel(PlayerPedId(), CharacterData["Sex"], skin, outfit)
end)

RegisterNetEvent("d-character:client:spawnPlayer", function(skin, clothing, sex, newPlayer)
	if type(skin) ~= "table" then
		skin = json.decode(skin)
	end

	if type(clothing) ~= "table" then
		clothing = json.decode(clothing)
	end

	CharacterData["Sex"] = sex
	CharacterData["Skin"] = skin
	CharacterData["Clothing"] = clothing

	DoScreenFadeOut(500)
	Wait(1000)

	local model = sex == "Male" and GetHashKey("mp_male") or GetHashKey("mp_female")
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end

	if sex == "Female" then
		SetPedOutfitPreset(PlayerPedId(), 17)
		Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0x9925C067, 0)
		Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)
	else
		SetPedOutfitPreset(PlayerPedId(), 43)
	end

	Citizen.InvokeNative(0xED40380076A31506, PlayerId(), model, false)
	Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 0, 0)

	Citizen.InvokeNative(0x0BFA1BD465CDFEFD, PlayerPedId())
	Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0x1D4C528A, 0)
	Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0x3F1F01E5, 0)
	Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0xDA0E2C55, 0)
	Citizen.InvokeNative(0x704C908E9C405136, PlayerPedId())
	Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)

	if GeneratePlayerModel(PlayerPedId(), sex, skin, clothing) then
		Wait(1000)
		if newPlayer then
			openSpawnMenu()
		else
			local PlayerData = PSRCore.Functions.GetPlayerData()
			local coords = PlayerData.position or openSpawnMenu()

			SetEntityCoords(PlayerPedId(), coords["x"], coords["y"], coords["z"])
			SetEntityHeading(PlayerPedId(), coords["h"])
			FreezeEntityPosition(PlayerPedId(), false)
			TriggerServerEvent("PSRCore:Server:OnPlayerLoaded")
			TriggerEvent("PSRCore:Client:OnPlayerLoaded")

			RenderScriptCams(false, true, 500, true, true)
			SetCamActive(groundCamera, false)
			DestroyCam(groundCamera, true)
			SetCamActive(fixedCamera, false)
			DestroyCam(fixedCamera, true)

			SetEntityVisible(PlayerPedId(), true)
			NetworkSetEntityInvisibleToNetwork(PlayerPedId(), false)
			Wait(500)
			DoScreenFadeIn(250)
		end
	else
		print("Failed to generate player")
	end
end)

CreateThread(function()
	for i = 1, #cloth_hash_names, 1 do
		local v = cloth_hash_names[i]
		if
			v.category_hashname == "BODIES_LOWER"
			or v.category_hashname == "BODIES_UPPER"
			or v.category_hashname == "heads"
			or v.category_hashname == "hair"
			or v.category_hashname == "teeth"
			or v.category_hashname == "eyes"
			or v.category_hashname == "beards_complete"
		then
			if v.ped_type == "female" and v.is_multiplayer and v.hashname ~= "" then
				if Skin["Female"][v.category_hashname] == nil then
					Skin["Female"][v.category_hashname] = {}
				end
				Skin["Female"][v.category_hashname][#Skin["Female"][v.category_hashname] + 1] = v.hash
			elseif v.ped_type == "male" and v.is_multiplayer and v.hashname ~= "" then
				if Skin["Male"][v.category_hashname] == nil then
					Skin["Male"][v.category_hashname] = {}
				end
				Skin["Male"][v.category_hashname][#Skin["Male"][v.category_hashname] + 1] = v.hash
			end
		else
			if v.ped_type == "female" and v.is_multiplayer and v.hashname ~= "" then
				if Clothing["Female"][v.category_hashname] == nil then
					Clothing["Female"][v.category_hashname] = {}
				end
				Clothing["Female"][v.category_hashname][#Clothing["Female"][v.category_hashname] + 1] = v.hash
			elseif v.ped_type == "male" and v.is_multiplayer and v.hashname ~= "" then
				if Clothing["Male"][v.category_hashname] == nil then
					Clothing["Male"][v.category_hashname] = {}
				end
				Clothing["Male"][v.category_hashname][#Clothing["Male"][v.category_hashname] + 1] = v.hash
			end
		end
	end
end)

exports("Character", function()
	return { Skin, Clothing }
end)
