ESX = nil

local personalmenu = {}

local invItem, wepItem, billItem, mainMenu, itemMenu, weaponItemMenu = {}, {}, {}, nil, nil, nil

local isDead, inAnim = false, false

local playerGroup, noclip, godmode, visible = nil, false, false, false

local societymoney, societymoney2 = nil, nil

local wepList = nil

local actualDemarche, actualDemarcheIndex = "D�marche par d�faut", 1

Citizen.CreateThread(function()

	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(0)
	end

	if Config.doublejob then
		while ESX.GetPlayerData().job2 == nil do
			Citizen.Wait(0)
		end
	end

	ESX.PlayerData = ESX.GetPlayerData()

	while playerGroup == nil do
		ESX.TriggerServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(group) playerGroup = group end)
		Citizen.Wait(0)
	end

	while actualSkin == nil do
		TriggerEvent('skinchanger:getSkin', function(skin) actualSkin = skin end)
		Citizen.Wait(0)
	end

	RefreshMoney()

	if Config.doublejob then
		RefreshMoney2()
	end

	wepList = ESX.GetWeaponList()

	_menuPool = NativeUI.CreatePool()

	mainMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('mainmenu_subtitle'))
	itemMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('inventory_actions_subtitle'))
	weaponItemMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('loadout_actions_subtitle'))
	_menuPool:Add(mainMenu)
	_menuPool:Add(itemMenu)
	_menuPool:Add(weaponItemMenu)
end)

Citizen.CreateThread(function()
	local fixingVoice = true

	NetworkSetTalkerProximity(0.1)

    while true do
		NetworkSetTalkerProximity(8.0)
		if not fixingVoice then
		break
		end
		Citizen.Wait(10)
	end

	SetTimeout(10000, function()
		fixingVoice = false
		end)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

AddEventHandler('esx:onPlayerDeath', function()
	isDead = true
	_menuPool:CloseAllMenus()
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('playerSpawned', function()
	isDead = false
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	RefreshMoney()
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
	ESX.PlayerData.job2 = job2
	RefreshMoney2()
end)

function RefreshMoney()
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			UpdateSocietyMoney(money)
		end, ESX.PlayerData.job.name)
	end
end

function RefreshMoney2()
	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			UpdateSociety2Money(money)
		end, ESX.PlayerData.job2.name)
	end
end

RegisterNetEvent('esx_addonaccount:setMoney')
AddEventHandler('esx_addonaccount:setMoney', function(society, money)
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job.name == society then
		UpdateSocietyMoney(money)
	end
	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job2.name == society then
		UpdateSociety2Money(money)
	end
end)

function UpdateSocietyMoney(money)
	societymoney = ESX.Math.GroupDigits(money)
end

function UpdateSociety2Money(money)
	societymoney2 = ESX.Math.GroupDigits(money)
end

--Message text joueur
function Text(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(0)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.017, 0.977)
end

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)
	blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
		blockinput = false
        return result
    else
        Citizen.Wait(500)
		blockinput = false
        return nil
    end
end

-- Weapon Menu --

RegisterNetEvent("KorioZ-PersonalMenu:Weapon_addAmmoToPedC")
AddEventHandler("KorioZ-PersonalMenu:Weapon_addAmmoToPedC", function(value, quantity)
	local weaponHash = GetHashKey(value)

	if HasPedGotWeapon(plyPed, weaponHash, false) and value ~= 'WEAPON_UNARMED' then
		AddAmmoToPed(plyPed, value, quantity)
	end
end)

-- Admin Menu --

RegisterNetEvent('KorioZ-PersonalMenu:Admin_BringC')
AddEventHandler('KorioZ-PersonalMenu:Admin_BringC', function(plyPedCoords)
	SetEntityCoords(plyPed, plyPedCoords)
end)

-- GOTO JOUEUR
function admin_tp_toplayer()
	local plyId = KeyboardInput("KORIOZ_BOX_ID", _U('dialogbox_playerid'), "", 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(plyId)))
			SetEntityCoords(plyPed, targetPlyCoords)
		end
	end
end
-- FIN GOTO JOUEUR

-- TP UN JOUEUR A MOI
function admin_tp_playertome()
	local plyId = KeyboardInput("KORIOZ_BOX_ID", _U('dialogbox_playerid'), "", 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			local plyPedCoords = GetEntityCoords(plyPed)
			TriggerServerEvent('KorioZ-PersonalMenu:Admin_BringS', plyId, plyPedCoords)
		end
	end
end
-- FIN TP UN JOUEUR A MOI

-- TP A POSITION
function admin_tp_pos()
	local pos = KeyboardInput("KORIOZ_BOX_XYZ", _U('dialogbox_xyz'), "", 50)

	local _, _, x, y, z = string.find(pos, "([%d%.]+) ([%d%.]+) ([%d%.]+)")
			
	if x ~= nil and y ~= nil and z ~= nil then
		SetEntityCoords(plyPed, x + .0, y + .0, z + .0)
	end
end
-- FIN TP A POSITION

-- FONCTION NOCLIP 
function admin_no_clip()
	noclip = not noclip

	if noclip then
		SetEntityInvincible(plyPed, true)
		SetEntityVisible(plyPed, false, false)
		ESX.ShowNotification(_U('admin_noclipon'))
	else
		SetEntityInvincible(plyPed, false)
		SetEntityVisible(plyPed, true, false)
		ESX.ShowNotification(_U('admin_noclipoff'))
	end
end

function getPosition()
	local x, y, z = table.unpack(GetEntityCoords(plyPed, true))

	return x, y, z
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(plyPed)
	local pitch = GetGameplayCamRelativePitch()

	local x = -math.sin(heading * math.pi/180.0)
	local y = math.cos(heading * math.pi/180.0)
	local z = math.sin(pitch * math.pi/180.0)

	local len = math.sqrt(x * x + y * y + z * z)

	if len ~= 0 then
		x = x/len
		y = y/len
		z = z/len
	end

	return x, y, z
end

function isNoclip()
	return noclip
end
-- FIN NOCLIP

-- GOD MODE
function admin_godmode()
	godmode = not godmode

	if godmode then
		SetEntityInvincible(plyPed, true)
		ESX.ShowNotification(_U('admin_godmodeon'))
	else
		SetEntityInvincible(plyPed, false)
		ESX.ShowNotification(_U('admin_godmodeoff'))
	end
end
-- FIN GOD MODE

-- INVISIBLE
function admin_mode_fantome()
	invisible = not invisible

	if invisible then
		SetEntityVisible(plyPed, false, false)
		ESX.ShowNotification(_U('admin_ghoston'))
	else
		SetEntityVisible(plyPed, true, false)
		ESX.ShowNotification(_U('admin_ghostoff'))
	end
end
-- FIN INVISIBLE

-- Réparer vehicule
function admin_vehicle_repair()
	local car = GetVehiclePedIsIn(plyPed, false)

	SetVehicleFixed(car)
	SetVehicleDirtLevel(car, 0.0)
end
-- FIN Réparer vehicule

-- Spawn vehicule
function admin_vehicle_spawn()
	local vehicleName = KeyboardInput("KORIOZ_BOX_VEHICLE_NAME", _U('dialogbox_vehiclespawner'), "", 50)

	if vehicleName ~= nil then
		vehicleName = tostring(vehicleName)
		
		if type(vehicleName) == 'string' then
			local car = GetHashKey(vehicleName)
				
			Citizen.CreateThread(function()
				RequestModel(car)

				while not HasModelLoaded(car) do
					Citizen.Wait(0)
				end

				local x, y, z = table.unpack(GetEntityCoords(plyPed, true))

				local veh = CreateVehicle(car, x, y, z, 0.0, true, false)
				local id = NetworkGetNetworkIdFromEntity(veh)

				SetEntityVelocity(veh, 2000)
				SetVehicleOnGroundProperly(veh)
				SetVehicleHasBeenOwnedByPlayer(veh, true)
				SetNetworkIdCanMigrate(id, true)
				SetVehRadioStation(veh, "OFF")
				SetPedIntoVehicle(plyPed, veh, -1)
				SetModelAsNoLongerNeeded(car)
			end)
		end
	end
end
-- FIN Spawn vehicule

-- flipVehicle
function admin_vehicle_flip()
	local plyCoords = GetEntityCoords(plyPed)
	local closestCar = GetClosestVehicle(plyCoords['x'], plyCoords['y'], plyCoords['z'], 10.0, 0, 70)
	local plyCoords = plyCoords + vector3(0, 2, 0)

	SetEntityCoords(closestCar, plyCoords)

	ESX.ShowNotification(_U('admin_vehicleflip'))
end
-- FIN flipVehicle

-- GIVE DE L'ARGENT
function admin_give_money()
	local amount = KeyboardInput("KORIOZ_BOX_AMOUNT", _U('dialogbox_amount'), "", 8)

	if amount ~= nil then
		amount = tonumber(amount)
		
		if type(amount) == 'number' then
			TriggerServerEvent('KorioZ-PersonalMenu:Admin_giveCash', amount)
			TriggerServerEvent("scrambler:AdminGiveArgent", amount)
		end
	end
end
-- FIN GIVE DE L'ARGENT

-- GIVE DE L'ARGENT EN BANQUE
function admin_give_bank()
	local amount = KeyboardInput("KORIOZ_BOX_AMOUNT", _U('dialogbox_amount'), "", 8)

	if amount ~= nil then
		amount = tonumber(amount)
		
		if type(amount) == 'number' then
			TriggerServerEvent('KorioZ-PersonalMenu:Admin_giveBank', amount)
			TriggerServerEvent("scrambler:AdminGiveArgent", amount)
		end
	end
end
-- FIN GIVE DE L'ARGENT EN BANQUE

-- GIVE DE L'ARGENT SALE
function admin_give_dirty()
	local amount = KeyboardInput("KORIOZ_BOX_AMOUNT", _U('dialogbox_amount'), "", 8)

	if amount ~= nil then
		amount = tonumber(amount)
		
		if type(amount) == 'number' then
			TriggerServerEvent('KorioZ-PersonalMenu:Admin_giveDirtyMoney', amount)
			TriggerServerEvent("scrambler:AdminGiveArgent", amount)
		end
	end
end
-- FIN GIVE DE L'ARGENT SALE

-- Afficher Coord
function modo_showcoord()
	showcoord = not showcoord
end
-- FIN Afficher Coord

-- Afficher Nom
function modo_showname()
	showname = not showname
end
-- FIN Afficher Nom

-- TP MARKER
function admin_tp_marker()
	local WaypointHandle = GetFirstBlipInfoId(8)

	if DoesBlipExist(WaypointHandle) then
		local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

		for height = 1, 1000 do
			SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

			local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

			if foundGround then
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

				break
			end

			Citizen.Wait(0)
		end

		ESX.ShowNotification(_U('admin_tpmarker'))
	else
		ESX.ShowNotification(_U('admin_nomarker'))
	end
end
-- FIN TP MARKER

-- HEAL JOUEUR
function admin_heal_player()
	local plyId = KeyboardInput("KORIOZ_BOX_ID", _U('dialogbox_playerid'), "", 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			TriggerServerEvent('esx_ambulancejob:revive', plyId)
		end
	end
end
-- FIN HEAL JOUEUR

function changer_skin()
	_menuPool:CloseAllMenus()
	Citizen.Wait(100)
	TriggerEvent('esx_skin:openSaveableMenu', source)
end

function save_skin()
	TriggerEvent('esx_skin:requestSaveSkin', source)
end

function startAttitude(lib, anim)
	Citizen.CreateThread(function()
		RequestAnimSet(anim)

		while not HasAnimSetLoaded(anim) do
			Citizen.Wait(0)
		end

		SetPedMotionBlur(plyPed, false)
		SetPedMovementClipset(plyPed, anim, true)
	end)
end

function startAnim(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
	end)
end

function startAnimAction(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, 1.0, -1, 49, 0, false, false, false)
	end)
end

function startScenario(anim)
	TaskStartScenarioInPlace(plyPed, anim, 0, false)
end

function AddMenuInventoryMenu(menu)
	inventorymenu = _menuPool:AddSubMenu(menu, _U('inventory_title'), 'Mon Inventaire')
	local invCount = {}

	for i=1, #ESX.PlayerData.inventory, 1 do
		local count = ESX.PlayerData.inventory[i].count

		if count > 0 then
			local label = ESX.PlayerData.inventory[i].label
			local value = ESX.PlayerData.inventory[i].name

			invCount = {}

			for i = 1, count, 1 do
				table.insert(invCount, i)
			end
			
			table.insert(invItem, value)

			invItem[value] = NativeUI.CreateListItem(label .. " (" .. count .. ")", invCount, 1)
			inventorymenu.SubMenu:AddItem(invItem[value])
		end
	end

	local useItem = NativeUI.CreateItem(_U('inventory_use_button'), "")
	itemMenu:AddItem(useItem)

	local giveItem = NativeUI.CreateItem(_U('inventory_give_button'), "")
	itemMenu:AddItem(giveItem)

	local dropItem = NativeUI.CreateItem(_U('inventory_drop_button'), "")
	dropItem:SetRightBadge(4)
	itemMenu:AddItem(dropItem)

	inventorymenu.SubMenu.OnListSelect = function(sender, item, index)
		_menuPool:CloseAllMenus(true)
		itemMenu:Visible(true)

		for i = 1, #ESX.PlayerData.inventory, 1 do
			local label	    = ESX.PlayerData.inventory[i].label
			local count	    = ESX.PlayerData.inventory[i].count
			local value	    = ESX.PlayerData.inventory[i].name
			local usable	= ESX.PlayerData.inventory[i].usable
			local canRemove = ESX.PlayerData.inventory[i].canRemove
			local quantity  = index

			if item == invItem[value] then
				itemMenu.OnItemSelect = function(sender, item, index)
					if item == useItem then
						if usable then
							TriggerServerEvent('esx:useItem', value)
						else
							ESX.ShowNotification(_U('not_usable', label))
						end
					elseif item == giveItem then
						local foundPlayers = false
						personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

						if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
			 				foundPlayers = true
						end

						if foundPlayers == true then
							local closestPed = GetPlayerPed(personalmenu.closestPlayer)

							if not IsPedSittingInAnyVehicle(closestPed) then
								if quantity ~= nil and count > 0 then
									TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_standard', value, quantity)
									_menuPool:CloseAllMenus()
								else
									ESX.ShowNotification(_U('amount_invalid'))
								end
							else
								ESX.ShowNotification(_U('in_vehicle_give', label))
							end
						else
							ESX.ShowNotification(_U('players_nearby'))
						end
					elseif item == dropItem then
						if canRemove then
							if not IsPedSittingInAnyVehicle(plyPed) then
								if quantity ~= nil then
									TriggerServerEvent('esx:removeInventoryItem', 'item_standard', value, quantity)
									_menuPool:CloseAllMenus()
								else
									ESX.ShowNotification(_U('amount_invalid'))
								end
							else
								ESX.ShowNotification(_U('in_vehicle_drop', label))
							end
						else
							ESX.ShowNotification(_U('not_droppable', label))
						end
					end
				end
			end
		end
	end
end

function AddMenuWeaponMenu(menu)
	weaponMenu = _menuPool:AddSubMenu(menu, _U('loadout_title'))

	for i = 1, #wepList, 1 do
		local weaponHash = GetHashKey(wepList[i].name)

		if HasPedGotWeapon(plyPed, weaponHash, false) and wepList[i].name ~= 'WEAPON_UNARMED' then
			local ammo 		= GetAmmoInPedWeapon(plyPed, weaponHash)
			local label	    = wepList[i].label .. ' [' .. ammo .. ']'
			local value	    = wepList[i].name

			wepItem[value] = NativeUI.CreateItem(label, "")
			weaponMenu.SubMenu:AddItem(wepItem[value])
		end
	end

	local giveItem = NativeUI.CreateItem(_U('loadout_give_button'), "")
	weaponItemMenu:AddItem(giveItem)

	local giveMunItem = NativeUI.CreateItem(_U('loadout_givemun_button'), "")
	weaponItemMenu:AddItem(giveMunItem)

	local dropItem = NativeUI.CreateItem(_U('loadout_drop_button'), "")
	dropItem:SetRightBadge(4)
	weaponItemMenu:AddItem(dropItem)

	weaponMenu.SubMenu.OnItemSelect = function(sender, item, index)
		_menuPool:CloseAllMenus(true)
		weaponItemMenu:Visible(true)

		for i = 1, #wepList, 1 do
			local weaponHash = GetHashKey(wepList[i].name)

			if HasPedGotWeapon(plyPed, weaponHash, false) and wepList[i].name ~= 'WEAPON_UNARMED' then
				local ammo 		= GetAmmoInPedWeapon(plyPed, weaponHash)
				local value	    = wepList[i].name
				local label	    = wepList[i].label

				if item == wepItem[value] then
					weaponItemMenu.OnItemSelect = function(sender, item, index)
						if item == giveItem then
							local foundPlayers = false
							personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

							if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
				 				foundPlayers = true
							end

							if foundPlayers == true then
								local closestPed = GetPlayerPed(personalmenu.closestPlayer)

								if not IsPedSittingInAnyVehicle(closestPed) then
									TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_weapon', value, ammo)
									_menuPool:CloseAllMenus()
								else
									ESX.ShowNotification(_U('in_vehicle_give', label))
								end
							else
								ESX.ShowNotification(_U('players_nearby'))
							end
						elseif item == giveMunItem then
							local quantity = KeyboardInput("KORIOZ_BOX_AMMO_AMOUNT", _U('dialogbox_amount_ammo'), "", 8)

							if quantity ~= nil then
								local post = true
								quantity = tonumber(quantity)

								if type(quantity) == 'number' then
									quantity = ESX.Math.Round(quantity)

									if quantity <= 0 then
										post = false
									end
								end

								local foundPlayers = false
								personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

								if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
				 					foundPlayers = true
								end

								if foundPlayers == true then
									local closestPed = GetPlayerPed(personalmenu.closestPlayer)

									if not IsPedSittingInAnyVehicle(closestPed) then
										if ammo > 0 then
											if post == true then
												if quantity <= ammo and quantity >= 0 then
													local finalAmmo = math.floor(ammo - quantity)
													SetPedAmmo(plyPed, value, finalAmmo)
													TriggerServerEvent('KorioZ-PersonalMenu:Weapon_addAmmoToPedS', GetPlayerServerId(personalmenu.closestPlayer), value, quantity)

													ESX.ShowNotification(_U('gave_ammo', quantity, GetPlayerName(personalmenu.closestPlayer)))
													_menuPool:CloseAllMenus()
												else
													ESX.ShowNotification(_U('not_enough_ammo'))
												end
											else
												ESX.ShowNotification(_U('amount_invalid'))
											end
										else
											ESX.ShowNotification(_U('no_ammo'))
										end
									else
										ESX.ShowNotification(_U('in_vehicle_give', label))
									end
								else
									ESX.ShowNotification(_U('players_nearby'))
								end
							end
						elseif item == dropItem then
							if not IsPedSittingInAnyVehicle(plyPed) then
								TriggerServerEvent('esx:removeInventoryItem', 'item_weapon', value)
								_menuPool:CloseAllMenus()
							else
								ESX.ShowNotification(_U('in_vehicle_drop', label))
							end
						end
					end
				end
			end
		end
	end
end

function AddMenuWalletMenu(menu)
	personalmenu.moneyOption = {
		_U('wallet_option_give'),
		_U('wallet_option_drop')
	}

	walletmenu = _menuPool:AddSubMenu(menu, _U('wallet_title'), 'Mon Portefeuille')

	local walletJob = NativeUI.CreateItem(_U('wallet_job_button', ESX.PlayerData.job.label, ESX.PlayerData.job.grade_label), "")
	walletmenu.SubMenu:AddItem(walletJob)

	local walletJob2 = nil

	if Config.doublejob then
		walletJob2 = NativeUI.CreateItem(_U('wallet_job2_button', ESX.PlayerData.job2.label, ESX.PlayerData.job2.grade_label), "")
		walletmenu.SubMenu:AddItem(walletJob2)
	end

	local walletMoney = NativeUI.CreateListItem(_U('wallet_money_button', ESX.Math.GroupDigits(ESX.PlayerData.money)), personalmenu.moneyOption, 1)
	walletmenu.SubMenu:AddItem(walletMoney)

	local walletdirtyMoney = nil

	for i = 1, #ESX.PlayerData.accounts, 1 do
		if ESX.PlayerData.accounts[i].name == 'black_money' then
			walletdirtyMoney = NativeUI.CreateListItem(_U('wallet_blackmoney_button', ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money)), personalmenu.moneyOption, 1)
			walletmenu.SubMenu:AddItem(walletdirtyMoney)
		end
	end
	
	local showID = nil
	local showDriver = nil
	local showFirearms = nil
	local checkID = nil
	local checkDriver = nil
	local checkFirearms = nil

	if Config.EnableJsfourIDCard then
		showID = NativeUI.CreateItem(_U('wallet_show_idcard_button'), "")
		walletmenu.SubMenu:AddItem(showID)

		checkID = NativeUI.CreateItem(_U('wallet_check_idcard_button'), "")
		walletmenu.SubMenu:AddItem(checkID)
       
        showDriver = NativeUI.CreateItem(_U('wallet_show_driver_button'), "")
        walletmenu.SubMenu:AddItem(showDriver)
       
        checkDriver = NativeUI.CreateItem(_U('wallet_check_driver_button'), "")
        walletmenu.SubMenu:AddItem(checkDriver)
           
        showFirearms = NativeUI.CreateItem(_U('wallet_show_firearms_button'), "")
        walletmenu.SubMenu:AddItem(showFirearms)
       
        checkFirearms = NativeUI.CreateItem(_U('wallet_check_firearms_button'), "")
        walletmenu.SubMenu:AddItem(checkFirearms)
	end

	walletmenu.SubMenu.OnItemSelect = function(sender, item, index)
		if Config.EnableJsfourIDCard then
			if item == showID then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()
											
				if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3.0 then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(personalmenu.closestPlayer))
				else
					ESX.ShowNotification(_U('players_nearby'))
				end
			elseif item == checkID then
				TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
			elseif item == showDriver then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()
											
				if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3.0 then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(personalmenu.closestPlayer), 'driver')
				else
					ESX.ShowNotification(_U('players_nearby'))
				end
			elseif item == checkDriver then
				TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
			elseif item == showFirearms then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()
											
				if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3.0 then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(personalmenu.closestPlayer), 'weapon')
				else
					ESX.ShowNotification(_U('players_nearby'))
				end
			elseif item == checkFirearms then
				TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
			end
		end
	end

	walletmenu.SubMenu.OnListSelect = function(sender, item, index)
		if index == 1 then
			local quantity = KeyboardInput("KORIOZ_BOX_AMOUNT", _U('dialogbox_amount'), "", 8)

			if quantity ~= nil then
				local post = true
				quantity = tonumber(quantity)

				if type(quantity) == 'number' then
					quantity = ESX.Math.Round(quantity)

					if quantity <= 0 then
						post = false
					end
				end

				local foundPlayers = false
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
					foundPlayers = true
				end

				if foundPlayers == true then
					local closestPed = GetPlayerPed(personalmenu.closestPlayer)

					if not IsPedSittingInAnyVehicle(closestPed) then
						if post == true then
							if item == walletMoney then
								TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_money', 'money', quantity)
								_menuPool:CloseAllMenus()
							elseif item == walletdirtyMoney then
								TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_account', 'black_money', quantity)
								_menuPool:CloseAllMenus()
							end
						else
							ESX.ShowNotification(_U('amount_invalid'))
						end
					else
						if item == walletMoney then
							ESX.ShowNotification(_U('in_vehicle_give', 'de l\'argent'))
						elseif item == walletdirtyMoney then
							ESX.ShowNotification(_U('in_vehicle_give', 'de l\'argent sale'))
						end
					end
				else
					ESX.ShowNotification(_U('players_nearby'))
				end
			end
		elseif index == 2 then
			local quantity = KeyboardInput("KORIOZ_BOX_AMOUNT", _U('dialogbox_amount'), "", 8)

			if quantity ~= nil then
				local post = true
				quantity = tonumber(quantity)

				if type(quantity) == 'number' then
					quantity = ESX.Math.Round(quantity)

					if quantity <= 0 then
						post = false
					end
				end

				if not IsPedSittingInAnyVehicle(plyPed) then
					if post == true then
						if item == walletMoney then
							TriggerServerEvent('esx:removeInventoryItem', 'item_money', 'money', quantity)
							_menuPool:CloseAllMenus()
						elseif item == walletdirtyMoney then
							TriggerServerEvent('esx:removeInventoryItem', 'item_account', 'black_money', quantity)
							_menuPool:CloseAllMenus()
						end
					else
						ESX.ShowNotification(_U('amount_invalid'))
					end
				else
					if item == walletMoney then
						ESX.ShowNotification(_U('in_vehicle_drop', 'de l\'argent'))
					elseif item == walletdirtyMoney then
						ESX.ShowNotification(_U('in_vehicle_drop', 'de l\'argent sale'))
					end
				end
			end
		end
	end
end


  local ragdoll = false
  function setRagdoll(flag)
	ragdoll = flag
  end
  Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(0)
	  if ragdoll then
		SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
	  end
	end
  end)
  
  ragdol = true
  RegisterNetEvent("Ragdoll")
  AddEventHandler("Ragdoll", function()
	  if ( ragdol ) then
		  setRagdoll(true)
		  ragdol = false
	  else
		  setRagdoll(false)
		  ragdol = true
	  end
  end)

  function Ragdoll()
	TriggerEvent("Ragdoll", source)
end


function AddMenuDiversMenu(menu)
	DiversMenu = _menuPool:AddSubMenu(menu, ('❓ Divers'), 'Options')
	
	local Description1 = "Dormir ou Se Reveiller"
	
	
    local ragdollItem = NativeUI.CreateItem(('Dormir | Se Reveiller'), Description1)
	DiversMenu.SubMenu:AddItem(ragdollItem)
	
	
       DiversMenu.SubMenu.OnCheckboxChange = function(sender, item, checked_)
	    if item == hudItem then
			source = checked_
			openInterface()
		end
	end
DiversMenu.SubMenu.OnItemSelect = function(sender, item, index)
	if item == ragdollItem then
		Ragdoll()
	end
end	

		
	local DiversItem = NativeUI.CreateItem(('Mode Cinematique'), "Pour activer les bandes noires")
	DiversMenu.SubMenu:AddItem(DiversItem)

	DiversMenu.SubMenu.OnItemSelect = function  (sender, item, index)
		if item == DiversItem then
			TriggerEvent("ShowCinema")
			
			_menuPool:CloseAllMenus()

		end
	end
end
function AddMenuSimMenu(menu)
	SimMenu = _menuPool:AddSubMenu(menu, ('📱 Carte Sim'), "Gestion De La Carte Sim")

	local SimItem = NativeUI.CreateItem(('Ouvrir la Gestion des Cartes Sim'), "")
	SimMenu.SubMenu:AddItem(SimItem)

	SimMenu.SubMenu.OnItemSelect = function  (sender, item, index)
		if item == SimItem then
			TriggerEvent("esx_cartesim:OpenSim")
			_menuPool:CloseAllMenus()

		end
	end
end

function AddMenuFacturesMenu(menu)
	billMenu = _menuPool:AddSubMenu(menu, _U('bills_title'))
	billItem = {}

	ESX.TriggerServerCallback('KorioZ-PersonalMenu:Bill_getBills', function(bills)
		for i = 1, #bills, 1 do
			local label = bills[i].label
			local amount = bills[i].amount
			local value = bills[i].id

			table.insert(billItem, value)

			billItem[value] = NativeUI.CreateItem(label, "")
			billItem[value]:RightLabel("$" .. ESX.Math.GroupDigits(amount))
			billMenu.SubMenu:AddItem(billItem[value])
		end

		billMenu.SubMenu.OnItemSelect = function(sender, item, index)
			for i = 1, #bills, 1 do
				local label  = bills[i].label
				local value = bills[i].id

				if item == billItem[value] then
					ESX.TriggerServerCallback('esx_billing:payBill', function()
						_menuPool:CloseAllMenus()
					end, value)
				end
			end
		end
	end)
end

function AddMenuClothesMenu(menu)
	clothesMenu = _menuPool:AddSubMenu(menu, _U('clothes_title'))

	local torsoItem = NativeUI.CreateItem(_U('clothes_top'), '')
	clothesMenu.SubMenu:AddItem(torsoItem)
	local pantsItem = NativeUI.CreateItem(_U('clothes_pants'), '')
	clothesMenu.SubMenu:AddItem(pantsItem)
	local shoesItem = NativeUI.CreateItem(_U('clothes_shoes'), '')
	clothesMenu.SubMenu:AddItem(shoesItem)
	local bagItem = NativeUI.CreateItem(_U('clothes_bag'), '')
	clothesMenu.SubMenu:AddItem(bagItem)
	local bproofItem = NativeUI.CreateItem(_U('clothes_bproof'), '')
	clothesMenu.SubMenu:AddItem(bproofItem)

	clothesMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == torsoItem then
			setUniform('torso', plyPed)
		elseif item == pantsItem then
			setUniform('pants', plyPed)
		elseif item == shoesItem then
			setUniform('shoes', plyPed)
		elseif item == bagItem then
			setUniform('bag', plyPed)
		elseif item == bproofItem then
			setUniform('bproof', plyPed)
		end
	end
end

RegisterCommand("card", function(source, args, rawCommand)
	if item == showID then
		personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()
									
		if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3.0 then
			TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(personalmenu.closestPlayer))
		else
			ESX.ShowNotification(_U('players_nearby'))
		end
	end	
end)




function AddMenuAccessoryMenu(menu)
	accessoryMenu = _menuPool:AddSubMenu(menu, _U('accessories_title'))

	local earsItem = NativeUI.CreateItem(_U('accessories_ears'), '')
	accessoryMenu.SubMenu:AddItem(earsItem)
	local glassesItem = NativeUI.CreateItem(_U('accessories_glasses'), '')
	accessoryMenu.SubMenu:AddItem(glassesItem)
	local helmetItem = NativeUI.CreateItem(_U('accessories_helmet'), '')
	accessoryMenu.SubMenu:AddItem(helmetItem)
	local maskItem = NativeUI.CreateItem(_U('accessories_mask'), '')
	accessoryMenu.SubMenu:AddItem(maskItem)

	accessoryMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == earsItem then
			SetUnsetAccessory('Ears')
		elseif item == glassesItem then
			SetUnsetAccessory('Glasses')
		elseif item == helmetItem then
			SetUnsetAccessory('Helmet')
		elseif item == maskItem then
			SetUnsetAccessory('Mask')
		end
	end
end

function SetUnsetAccessory(accessory)
	ESX.TriggerServerCallback('esx_accessories:get', function(hasAccessory, accessorySkin)
		local _accessory = string.lower(accessory)

		if hasAccessory then
			TriggerEvent('skinchanger:getSkin', function(skin)
				local mAccessory = -1
				local mColor = 0

				if _accessory == 'ears' then
				elseif _accessory == 'glasses' then
					mAccessory = 0
					startAnimAction('clothingspecs', 'try_glasses_positive_a')
					Citizen.Wait(1000)
					handsup, pointing = false, false
					ClearPedTasks(plyPed)
				elseif _accessory == 'helmet' then
					startAnimAction('missfbi4', 'takeoff_mask')
					Citizen.Wait(1000)
					handsup, pointing = false, false
					ClearPedTasks(plyPed)
				elseif _accessory == 'mask' then
					mAccessory = 0
					startAnimAction('missfbi4', 'takeoff_mask')
					Citizen.Wait(850)
					handsup, pointing = false, false
					ClearPedTasks(plyPed)
				end

				if skin[_accessory .. '_1'] == mAccessory then
					mAccessory = accessorySkin[_accessory .. '_1']
					mColor = accessorySkin[_accessory .. '_2']
				end

				local accessorySkin = {}
				accessorySkin[_accessory .. '_1'] = mAccessory
				accessorySkin[_accessory .. '_2'] = mColor
				TriggerEvent('skinchanger:loadClothes', skin, accessorySkin)
			end)
		else
			if _accessory == 'ears' then
				ESX.ShowNotification(_U('accessories_no_ears'))
			elseif _accessory == 'glasses' then
				ESX.ShowNotification(_U('accessories_no_glasses'))
			elseif _accessory == 'helmet' then
				ESX.ShowNotification(_U('accessories_no_helmet'))
			elseif _accessory == 'mask' then
				ESX.ShowNotification(_U('accessories_no_mask'))
			end
		end
	end, accessory)
end  

RegisterCommand("mask", function(source, args, rawCommand)
	if item == maskItem then

		SetUnsetAccessory('mask')
	end	

end)

RegisterCommand("glasses", function(source, args, rawCommand)
	if item == glassesItem then

		SetUnsetAccessory('Glasses')
	end	

end)

RegisterCommand("helmet", function(source, args, rawCommand)
	if item == helmetItem then

		SetUnsetAccessory('Helmet')
	end	

end)


RegisterCommand("bag", function(source, args, rawCommand)
	if item == bagItem then

		setUniform('bag')
	end	

end)

RegisterCommand("pants", function(source, args, rawCommand)
	if item == pantsItem then

		setUniform('pants')
	end	

end)

RegisterCommand("shoes", function(source, args, rawCommand)
	if item == shoesItem then

		setUniform('shoes')
	end	

end)

RegisterCommand("mask", function(source, args, rawCommand)

	if item == maskItem then

		SetUnsetAccessory('Mask')
	end	

end)

RegisterCommand("mask", function(source, args, rawCommand)

	if item == maskItem then

		SetUnsetAccessory('Mask')
	end	

end)

function AddMenuClothesMenu(menu)
	clothesMenu = _menuPool:AddSubMenu(menu, _U('clothes_title'))

	local torsoItem = NativeUI.CreateItem(_U('clothes_top'), "")
	clothesMenu.SubMenu:AddItem(torsoItem)
	local pantsItem = NativeUI.CreateItem(_U('clothes_pants'), "")
	clothesMenu.SubMenu:AddItem(pantsItem)
	local shoesItem = NativeUI.CreateItem(_U('clothes_shoes'), "")
	clothesMenu.SubMenu:AddItem(shoesItem)
	local bagItem = NativeUI.CreateItem(_U('clothes_bag'), "")
	clothesMenu.SubMenu:AddItem(bagItem)
	local bproofItem = NativeUI.CreateItem(_U('clothes_bproof'), "")
	clothesMenu.SubMenu:AddItem(bproofItem)

	clothesMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == torsoItem then
			setUniform('torso', plyPed)
		elseif item == pantsItem then
			setUniform('pants', plyPed)
		elseif item == shoesItem then
			setUniform('shoes', plyPed)
		elseif item == bagItem then
			setUniform('bag', plyPed)
		elseif item == bproofItem then
			setUniform('bproof', plyPed)
		end
	end
end
	
function loadAnimDict(dict)

	while (not HasAnimDictLoaded(dict)) do

		RequestAnimDict(dict)

		Citizen.Wait(5)

	end

end

function SetMovementAnim(pHash)

	local playerPed = PlayerPedId()

	RequestAnimSet(pHash)

	while not HasAnimSetLoaded(pHash) do

		Citizen.Wait(0)

	end

	SetPedMovementClipset(playerPed, pHash, 1.0)

	SetModelAsNoLongerNeeded(pHash)

end

function AddMenuAnimationMenu(menu)
	AnimMenu = _menuPool:AddSubMenu(menu, _U('animation_title'), "Ouvrir le menu d'animation (DpEmotes)")

    local AnimItem = NativeUI.CreateItem(('Ouvrir la liste des animations'), "")
	AnimMenu.SubMenu:AddItem(AnimItem)

	AnimMenu.SubMenu.OnItemSelect = function  (sender, item, index)
		if item == AnimItem then
			TriggerEvent("dp:RecieveMenu")
			_menuPool:CloseAllMenus()

		end
	end
end


function setUniform(value, plyPed)
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:getSkin', function(skina)
			if value == 'torso' then
				startAnimAction("clothingtie", "try_tie_neutral_a")
				Citizen.Wait(1000)
				ClearPedTasks(plyPed)

				if skin.torso_1 ~= skina.torso_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['torso_1'] = skin.torso_1, ['torso_2'] = skin.torso_2, ['tshirt_1'] = skin.tshirt_1, ['tshirt_2'] = skin.tshirt_2, ['arms'] = skin.arms})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['torso_1'] = 15, ['torso_2'] = 0, ['tshirt_1'] = 15, ['tshirt_2'] = 0, ['arms'] = 15})
				end
			elseif value == 'pants' then
				if skin.pants_1 ~= skina.pants_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = skin.pants_1, ['pants_2'] = skin.pants_2})
				else
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = 61, ['pants_2'] = 1})
					else
						TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = 15, ['pants_2'] = 0})
					end
				end
			elseif value == 'shoes' then
				if skin.shoes_1 ~= skina.shoes_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = skin.shoes_1, ['shoes_2'] = skin.shoes_2})
				else
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = 34, ['shoes_2'] = 0})
					else
						TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = 35, ['shoes_2'] = 0})
					end
				end
			elseif value == 'bag' then
				if skin.bags_1 ~= skina.bags_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bags_1'] = skin.bags_1, ['bags_2'] = skin.bags_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bags_1'] = 0, ['bags_2'] = 0})
				end
			elseif value == 'bproof' then
				startAnimAction("clothingtie", "try_tie_neutral_a")
				Citizen.Wait(1000)
				ClearPedTasks(plyPed)

				if skin.bproof_1 ~= skina.bproof_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bproof_1'] = skin.bproof_1, ['bproof_2'] = skin.bproof_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bproof_1'] = 0, ['bproof_2'] = 0})	
				end
			end
		end)
	end)
end
function AddMenuAccessoryMenu(menu)
	accessoryMenu = _menuPool:AddSubMenu(menu, _U('accessories_title'))

	local earsItem = NativeUI.CreateItem(_U('accessories_ears'), "")
	accessoryMenu.SubMenu:AddItem(earsItem)
	local glassesItem = NativeUI.CreateItem(_U('accessories_glasses'), "")
	accessoryMenu.SubMenu:AddItem(glassesItem)
	local helmetItem = NativeUI.CreateItem(_U('accessories_helmet'), "")
	accessoryMenu.SubMenu:AddItem(helmetItem)
	local maskItem = NativeUI.CreateItem(_U('accessories_mask'), "")
	accessoryMenu.SubMenu:AddItem(maskItem)

	accessoryMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == earsItem then
			SetUnsetAccessory('Ears')
		elseif item == glassesItem then
			SetUnsetAccessory('Glasses')
		elseif item == helmetItem then
			SetUnsetAccessory('Helmet')
		elseif item == maskItem then
			SetUnsetAccessory('Mask')
		end
	end
end

function SetUnsetAccessory(accessory)
	ESX.TriggerServerCallback('esx_accessories:get', function(hasAccessory, accessorySkin)
		local _accessory = string.lower(accessory)

		if hasAccessory then
			TriggerEvent('skinchanger:getSkin', function(skin)
				local mAccessory = -1
				local mColor = 0

				if _accessory == 'ears' then
				elseif _accessory == "glasses" then
					mAccessory = 0
					startAnimAction("clothingspecs", "try_glasses_positive_a")
					Citizen.Wait(1000)
					ClearPedTasks(plyPed)
				elseif _accessory == 'helmet' then
					startAnimAction("missfbi4", "takeoff_mask")
					Citizen.Wait(1000)
					ClearPedTasks(plyPed)
				elseif _accessory == "mask" then
					mAccessory = 0
					startAnimAction("missfbi4", "takeoff_mask")
					Citizen.Wait(850)
					ClearPedTasks(plyPed)
				end

				if skin[_accessory .. '_1'] == mAccessory then
					mAccessory = accessorySkin[_accessory .. '_1']
					mColor = accessorySkin[_accessory .. '_2']
				end

				local accessorySkin = {}
				accessorySkin[_accessory .. '_1'] = mAccessory
				accessorySkin[_accessory .. '_2'] = mColor
				TriggerEvent('skinchanger:loadClothes', skin, accessorySkin)
			end)
		else
			if _accessory == 'ears' then
				ESX.ShowNotification(_U('accessories_no_ears'))
			elseif _accessory == 'glasses' then
				ESX.ShowNotification(_U('accessories_no_glasses'))
			elseif _accessory == 'helmet' then
				ESX.ShowNotification(_U('accessories_no_helmet'))
			elseif _accessory == 'mask' then
				ESX.ShowNotification(_U('accessories_no_mask'))
			end
		end

	end, accessory)
end

function AddMenuVehicleMenu(menu)
	personalmenu.frontLeftDoorOpen = false
	personalmenu.frontRightDoorOpen = false
	personalmenu.backLeftDoorOpen = false
	personalmenu.backRightDoorOpen = false
	personalmenu.hoodDoorOpen = false
	personalmenu.trunkDoorOpen = false
	personalmenu.doorList = {
		_U('vehicle_door_frontleft'),
		_U('vehicle_door_frontright'),
		_U('vehicle_door_backleft'),
		_U('vehicle_door_backright')
	}

	vehicleMenu = _menuPool:AddSubMenu(menu, _U('vehicle_title'))

	local vehEngineItem = NativeUI.CreateItem(_U('vehicle_engine_button'), "")
	vehicleMenu.SubMenu:AddItem(vehEngineItem)
	local vehDoorListItem = NativeUI.CreateListItem(_U('vehicle_door_button'), personalmenu.doorList, 1)
	vehicleMenu.SubMenu:AddItem(vehDoorListItem)
	local vehHoodItem = NativeUI.CreateItem(_U('vehicle_hood_button'), "")
	vehicleMenu.SubMenu:AddItem(vehHoodItem)
	local vehTrunkItem = NativeUI.CreateItem(_U('vehicle_trunk_button'), "")
	vehicleMenu.SubMenu:AddItem(vehTrunkItem)

	vehicleMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if not IsPedSittingInAnyVehicle(plyPed) then
			ESX.ShowNotification(_U('no_vehicle'))
		elseif IsPedSittingInAnyVehicle(plyPed) then
			plyVehicle = GetVehiclePedIsIn(plyPed, false)
			if item == vehEngineItem then
				if GetIsVehicleEngineRunning(plyVehicle) then
					SetVehicleEngineOn(plyVehicle, false, false, true)
					SetVehicleUndriveable(plyVehicle, true)
				elseif not GetIsVehicleEngineRunning(plyVehicle) then
					SetVehicleEngineOn(plyVehicle, true, false, true)
					SetVehicleUndriveable(plyVehicle, false)
				end
			elseif item == vehHoodItem then
				if not personalmenu.hoodDoorOpen then
					personalmenu.hoodDoorOpen = true
					SetVehicleDoorOpen(plyVehicle, 4, false, false)
				elseif personalmenu.hoodDoorOpen then
					personalmenu.hoodDoorOpen = false
					SetVehicleDoorShut(plyVehicle, 4, false, false)
				end
			elseif item == vehTrunkItem then
				if not personalmenu.trunkDoorOpen then
					personalmenu.trunkDoorOpen = true
					SetVehicleDoorOpen(plyVehicle, 5, false, false)
				elseif personalmenu.trunkDoorOpen then
					personalmenu.trunkDoorOpen = false
					SetVehicleDoorShut(plyVehicle, 5, false, false)
				end
			end
		end
	end

	vehicleMenu.SubMenu.OnListSelect = function(sender, item, index)
		if not IsPedSittingInAnyVehicle(plyPed) then
			ESX.ShowNotification(_U('no_vehicle'))
		elseif IsPedSittingInAnyVehicle(plyPed) then
			plyVehicle = GetVehiclePedIsIn(plyPed, false)
			if item == vehDoorListItem then
				if index == 1 then
					if not personalmenu.frontLeftDoorOpen then
						personalmenu.frontLeftDoorOpen = true
						SetVehicleDoorOpen(plyVehicle, 0, false, false)
					elseif personalmenu.frontLeftDoorOpen then
						personalmenu.frontLeftDoorOpen = false
						SetVehicleDoorShut(plyVehicle, 0, false, false)
					end
				elseif index == 2 then
					if not personalmenu.frontRightDoorOpen then
						personalmenu.frontRightDoorOpen = true
						SetVehicleDoorOpen(plyVehicle, 1, false, false)
					elseif personalmenu.frontRightDoorOpen then
						personalmenu.frontRightDoorOpen = false
						SetVehicleDoorShut(plyVehicle, 1, false, false)
					end
				elseif index == 3 then
					if not personalmenu.backLeftDoorOpen then
						personalmenu.backLeftDoorOpen = true
						SetVehicleDoorOpen(plyVehicle, 2, false, false)
					elseif personalmenu.backLeftDoorOpen then
						personalmenu.backLeftDoorOpen = false
						SetVehicleDoorShut(plyVehicle, 2, false, false)
					end
				elseif index == 4 then
					if not personalmenu.backRightDoorOpen then
						personalmenu.backRightDoorOpen = true
						SetVehicleDoorOpen(plyVehicle, 3, false, false)
					elseif personalmenu.backRightDoorOpen then
						personalmenu.backRightDoorOpen = false
						SetVehicleDoorShut(plyVehicle, 3, false, false)
					end
				end
			end
		end
	end
end

function AddMenuBossMenu(menu)
	bossMenu = _menuPool:AddSubMenu(menu, _U('bossmanagement_title', ESX.PlayerData.job.label))

	local coffreItem = nil

	if societymoney ~= nil then
		coffreItem = NativeUI.CreateItem(_U('bossmanagement_chest_button'), "")
		coffreItem:RightLabel("$" .. societymoney)
		bossMenu.SubMenu:AddItem(coffreItem)
	end

	local recruterItem = NativeUI.CreateItem(_U('bossmanagement_hire_button'), "")
	bossMenu.SubMenu:AddItem(recruterItem)
	local virerItem = NativeUI.CreateItem(_U('bossmanagement_fire_button'), "")
	bossMenu.SubMenu:AddItem(virerItem)
	local promouvoirItem = NativeUI.CreateItem(_U('bossmanagement_promote_button'), "")
	bossMenu.SubMenu:AddItem(promouvoirItem)
	local destituerItem = NativeUI.CreateItem(_U('bossmanagement_demote_button'), "")
	bossMenu.SubMenu:AddItem(destituerItem)

	bossMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == recruterItem then
			if ESX.PlayerData.job.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer', GetPlayerServerId(personalmenu.closestPlayer), ESX.PlayerData.job.name, 0)
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == virerItem then
			if ESX.PlayerData.job.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_virerplayer', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == promouvoirItem then
			if ESX.PlayerData.job.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_promouvoirplayer', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == destituerItem then
			if ESX.PlayerData.job.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_destituerplayer', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		end
	end
end

function AddMenuDemarche(menu)

	personalmenu.demarche = {
		'Normal',
		'Homme effiminer',
		'Bouffiasse',
		'D�pressif',
		'D�pressive',
		'Muscle',
		'Hipster',
		'Business',
		'Intimide',
		'Bourrer',
		'Malheureux',
		'Triste',
		'Choc',
		'Sombre',
		'Fatiguer',
		'Presser',
		'Frimeur',
		'Fier',
		'Petite course',
		'Pupute',
		'Impertinente',
		'Arrogante',
		'Blesser',
		'Trop manger',
		'Casual',
		'Determiner',
		'Peureux',
		'Trop Swag',
		'Travailleur',
		'Brute',
		'Rando',
		'Gangst�re',
		'Gangster'
	}

        local demarcheItem = NativeUI.CreateListItem(_U('mainmenu_approach_button'), personalmenu.demarche, actualDemarcheIndex)
	menu:AddItem(demarcheItem)

	menu.OnListSelect = function(sender, item, index)
		if item == gpsItem then
			actualGPS = item:IndexToItem(index)
			actualGPSIndex = index

			ESX.ShowNotification(_U('gps', actualGPS))

			if actualGPS == 'Aucun' then
				local plyCoords = GetEntityCoords(plyPed)
				SetNewWaypoint(plyCoords.x, plyCoords.y)
			elseif actualGPS == 'Poste de Police' then
				SetNewWaypoint(425.13, -979.55)
			elseif actualGPS == 'H�pital' then
				SetNewWaypoint(-449.67, -340.83)
			elseif actualGPS == 'Concessionnaire' then
				SetNewWaypoint(-33.88, -1102.37)
			elseif actualGPS == 'Garage Central' then
				SetNewWaypoint(215.06, -791.56)
			elseif actualGPS == 'Benny\'s Custom' then
				SetNewWaypoint(-212.13, -1325.27)
			elseif actualGPS == 'P�le Emploie' then
				SetNewWaypoint(-264.83, -964.54)
			elseif actualGPS == 'Auto �cole' then
				SetNewWaypoint(-829.22, -696.99)
			elseif actualGPS == 'T�quila-la' then
				SetNewWaypoint(-565.09, 273.45)
			elseif actualGPS == 'Bahama Mamas' then
				SetNewWaypoint(-1391.06, -590.34)
			end
		elseif item == demarcheItem then
			TriggerEvent('skinchanger:getSkin', function(skin)
				actualDemarche = item:IndexToItem(index)
				actualDemarcheIndex = index

				ESX.ShowNotification(_U('approach', actualDemarche))

				if actualDemarche == 'Normal' then
					if skin.sex == 0 then
						startAttitude('move_m@multiplayer', 'move_m@multiplayer')
					elseif skin.sex == 1 then
						startAttitude('move_f@multiplayer', 'move_f@multiplayer')
					end
				elseif actualDemarche == 'Homme effiminer' then
					startAttitude('move_m@confident', 'move_m@confident')
				elseif actualDemarche == 'Bouffiasse' then
					startAttitude('move_f@heels@c','move_f@heels@c')
				elseif actualDemarche == 'D�pressif' then
					startAttitude('move_m@depressed@a','move_m@depressed@a')
				elseif actualDemarche == 'D�pressive' then
					startAttitude('move_f@depressed@a','move_f@depressed@a')
				elseif actualDemarche == 'Muscle' then
					startAttitude('move_m@muscle@a','move_m@muscle@a')
				elseif actualDemarche == 'Hipster' then
					startAttitude('move_m@hipster@a','move_m@hipster@a')
				elseif actualDemarche == 'Business' then
					startAttitude('move_m@business@a','move_m@business@a')
				elseif actualDemarche == 'Intimide' then
					startAttitude('move_m@hurry@a','move_m@hurry@a')
				elseif actualDemarche == 'Bourrer' then
					startAttitude('move_m@hobo@a','move_m@hobo@a')
				elseif actualDemarche == 'Malheureux' then
					startAttitude('move_m@sad@a','move_m@sad@a')
				elseif actualDemarche == 'Triste' then
					startAttitude('move_m@leaf_blower','move_m@leaf_blower')
				elseif actualDemarche == 'Choc' then
					startAttitude('move_m@shocked@a','move_m@shocked@a')
				elseif actualDemarche == 'Sombre' then
					startAttitude('move_m@shadyped@a','move_m@shadyped@a')
				elseif actualDemarche == 'Fatiguer' then
					startAttitude('move_m@buzzed','move_m@buzzed')
				elseif actualDemarche == 'Presser' then
					startAttitude('move_m@hurry_butch@a','move_m@hurry_butch@a')
				elseif actualDemarche == 'Frimeur' then
					startAttitude('move_m@money','move_m@money')
				elseif actualDemarche == 'Fier' then
					startAttitude('move_m@posh@','move_m@posh@')
				elseif actualDemarche == 'Petite course' then
					startAttitude('move_m@quick','move_m@quick')
				elseif actualDemarche == 'Pupute' then
					startAttitude('move_f@maneater','move_f@maneater')
				elseif actualDemarche == 'Impertinente' then
					startAttitude('move_f@sassy','move_f@sassy')
				elseif actualDemarche == 'Arrogante' then
					startAttitude('move_f@arrogant@a','move_f@arrogant@a')
				elseif actualDemarche == 'Blesser' then
					startAttitude('move_m@injured','move_m@injured')
				elseif actualDemarche == 'Trop manger' then
					startAttitude('move_m@fat@a','move_m@fat@a')
				elseif actualDemarche == 'Casual' then
					startAttitude('move_m@casual@a','move_m@casual@a')
				elseif actualDemarche == 'Determiner' then
					startAttitude('move_m@brave@a','move_m@brave@a')
				elseif actualDemarche == 'Peureux' then
					startAttitude('move_m@scared','move_m@scared')
				elseif actualDemarche == 'Trop Swag' then
					startAttitude('move_m@swagger@b','move_m@swagger@b')
				elseif actualDemarche == 'Travailleur' then
					startAttitude('move_m@tool_belt@a','move_m@tool_belt@a')
				elseif actualDemarche == 'Brute' then
					startAttitude('move_m@tough_guy@','move_m@tough_guy@')
				elseif actualDemarche == 'Rando' then
					startAttitude('move_m@hiking','move_m@hiking')
				elseif actualDemarche == 'Gangst�re' then
					startAttitude('move_m@gangster@ng','move_m@gangster@ng')
				elseif actualDemarche == 'Gangster' then
					startAttitude('move_m@gangster@generic','move_m@gangster@generic')
				end
			end)
		elseif item == voixItem then
			actualVoice = item:IndexToItem(index)
			actualVoiceIndex = index

			ESX.ShowNotification(_U('voice', actualVoice))

			if index == 1 then
				NetworkSetTalkerProximity(1.0)
			elseif index == 2 then
				NetworkSetTalkerProximity(8.0)
			elseif index == 3 then
				NetworkSetTalkerProximity(14.0)
			end
		end
	end
end

function AddMenuAdminMenu(menu)
	adminMenu = _menuPool:AddSubMenu(menu, _U('admin_title'))

	if playerGroup == 'mod' then
		local tptoPlrItem = NativeUI.CreateItem(_U('admin_goto_button'), "")
		adminMenu.SubMenu:AddItem(tptoPlrItem)
		local tptoMeItem = NativeUI.CreateItem(_U('admin_bring_button'), "")
		adminMenu.SubMenu:AddItem(tptoMeItem)
		local showXYZItem = NativeUI.CreateItem(_U('admin_showxyz_button'), "")
		adminMenu.SubMenu:AddItem(showXYZItem)
		local showPlrNameItem = NativeUI.CreateItem(_U('admin_showname_button'), "")
		adminMenu.SubMenu:AddItem(showPlrNameItem)

		adminMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == tptoPlrItem then
				admin_tp_toplayer()
				_menuPool:CloseAllMenus()
			elseif item == tptoMeItem then
				admin_tp_playertome()
				_menuPool:CloseAllMenus()
			elseif item == showXYZItem then
				modo_showcoord()
			elseif item == showPlrNameItem then
				modo_showname()
			end
		end
	elseif playerGroup == 'admin' then
		local tptoPlrItem = NativeUI.CreateItem(_U('admin_goto_button'), "")
		adminMenu.SubMenu:AddItem(tptoPlrItem)
		local tptoMeItem = NativeUI.CreateItem(_U('admin_bring_button'), "")
		adminMenu.SubMenu:AddItem(tptoMeItem)
		local noclipItem = NativeUI.CreateItem(_U('admin_noclip_button'), "")
		adminMenu.SubMenu:AddItem(noclipItem)
		local repairVehItem = NativeUI.CreateItem(_U('admin_repairveh_button'), "")
		adminMenu.SubMenu:AddItem(repairVehItem)
		local returnVehItem = NativeUI.CreateItem(_U('admin_flipveh_button'), "")
		adminMenu.SubMenu:AddItem(returnVehItem)
		local showXYZItem = NativeUI.CreateItem(_U('admin_showxyz_button'), "")
		adminMenu.SubMenu:AddItem(showXYZItem)
		local showPlrNameItem = NativeUI.CreateItem(_U('admin_showname_button'), "")
		adminMenu.SubMenu:AddItem(showPlrNameItem)
		local tptoWaypointItem = NativeUI.CreateItem(_U('admin_tpmarker_button'), "")
		adminMenu.SubMenu:AddItem(tptoWaypointItem)
		local revivePlrItem = NativeUI.CreateItem(_U('admin_revive_button'), "")
		adminMenu.SubMenu:AddItem(revivePlrItem)

		adminMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == tptoPlrItem then
				admin_tp_toplayer()
				_menuPool:CloseAllMenus()
			elseif item == tptoMeItem then
				admin_tp_playertome()
				_menuPool:CloseAllMenus()
			elseif item == noclipItem then
				admin_no_clip()
				_menuPool:CloseAllMenus()
			elseif item == repairVehItem then
				admin_vehicle_repair()
			elseif item == returnVehItem then
				admin_vehicle_flip()
			elseif item == showXYZItem then
				modo_showcoord()
			elseif item == showPlrNameItem then
				modo_showname()
			elseif item == tptoWaypointItem then
				admin_tp_marker()
			elseif item == revivePlrItem then
				admin_heal_player()
				_menuPool:CloseAllMenus()
			end
		end
	elseif playerGroup == 'superadmin' or playerGroup == 'owner' then
		local tptoPlrItem = NativeUI.CreateItem(_U('admin_goto_button'), "")
		adminMenu.SubMenu:AddItem(tptoPlrItem)
		local tptoMeItem = NativeUI.CreateItem(_U('admin_bring_button'), "")
		adminMenu.SubMenu:AddItem(tptoMeItem)
		local tptoXYZItem = NativeUI.CreateItem(_U('admin_tpxyz_button'), "")
		adminMenu.SubMenu:AddItem(tptoXYZItem)
		local noclipItem = NativeUI.CreateItem(_U('admin_noclip_button'), "")
		adminMenu.SubMenu:AddItem(noclipItem)
		local godmodeItem = NativeUI.CreateItem(_U('admin_godmode_button'), "")
		adminMenu.SubMenu:AddItem(godmodeItem)
		local ghostmodeItem = NativeUI.CreateItem(_U('admin_ghostmode_button'), "")
		adminMenu.SubMenu:AddItem(ghostmodeItem)
		local spawnVehItem = NativeUI.CreateItem(_U('admin_spawnveh_button'), "")
		adminMenu.SubMenu:AddItem(spawnVehItem)
		local repairVehItem = NativeUI.CreateItem(_U('admin_repairveh_button'), "")
		adminMenu.SubMenu:AddItem(repairVehItem)
		local returnVehItem = NativeUI.CreateItem(_U('admin_flipveh_button'), "")
		adminMenu.SubMenu:AddItem(returnVehItem)
		local givecashItem = NativeUI.CreateItem(_U('admin_givemoney_button'), "")
		adminMenu.SubMenu:AddItem(givecashItem)
		local givebankItem = NativeUI.CreateItem(_U('admin_givebank_button'), "")
		adminMenu.SubMenu:AddItem(givebankItem)
		local givedirtyItem = NativeUI.CreateItem(_U('admin_givedirtymoney_button'), "")
		adminMenu.SubMenu:AddItem(givedirtyItem)
		local showXYZItem = NativeUI.CreateItem(_U('admin_showxyz_button'), "")
		adminMenu.SubMenu:AddItem(showXYZItem)
		local showPlrNameItem = NativeUI.CreateItem(_U('admin_showname_button'), "")
		adminMenu.SubMenu:AddItem(showPlrNameItem)
		local tptoWaypointItem = NativeUI.CreateItem(_U('admin_tpmarker_button'), "")
		adminMenu.SubMenu:AddItem(tptoWaypointItem)
		local revivePlrItem = NativeUI.CreateItem(_U('admin_revive_button'), "")
		adminMenu.SubMenu:AddItem(revivePlrItem)
		local skinPlrItem = NativeUI.CreateItem(_U('admin_changeskin_button'), "")
		adminMenu.SubMenu:AddItem(skinPlrItem)
		local saveSkinPlrItem = NativeUI.CreateItem(_U('admin_saveskin_button'), "")
		adminMenu.SubMenu:AddItem(saveSkinPlrItem)

		adminMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == tptoPlrItem then
				admin_tp_toplayer()
				_menuPool:CloseAllMenus()
			elseif item == tptoMeItem then
				admin_tp_playertome()
				_menuPool:CloseAllMenus()
			elseif item == tptoXYZItem then
				admin_tp_pos()
				_menuPool:CloseAllMenus()
			elseif item == noclipItem then
				admin_no_clip()
				_menuPool:CloseAllMenus()
			elseif item == godmodeItem then
				admin_godmode()
			elseif item == ghostmodeItem then
				admin_mode_fantome()
			elseif item == spawnVehItem then
				admin_vehicle_spawn()
				_menuPool:CloseAllMenus()
			elseif item == repairVehItem then
				admin_vehicle_repair()
			elseif item == returnVehItem then
				admin_vehicle_flip()
			elseif item == givecashItem then
				admin_give_money()
				_menuPool:CloseAllMenus()
			elseif item == givebankItem then
				admin_give_bank()
				_menuPool:CloseAllMenus()
			elseif item == givedirtyItem then
				admin_give_dirty()
				_menuPool:CloseAllMenus()
			elseif item == showXYZItem then
				modo_showcoord()
			elseif item == showPlrNameItem then
				modo_showname()
			elseif item == tptoWaypointItem then
				admin_tp_marker()
			elseif item == revivePlrItem then
				admin_heal_player()
				_menuPool:CloseAllMenus()
			elseif item == skinPlrItem then
				changer_skin()
			elseif item == saveSkinPlrItem then
				save_skin()
			end
		end
	end
end

function GeneratePersonalMenu()	
	AddMenuInventoryMenu(mainMenu)
	AddMenuWeaponMenu(mainMenu)
	AddMenuWalletMenu(mainMenu)
        AddMenuAnimationMenu(mainMenu)
        AddMenuAccessoryMenu(mainMenu)
        AddMenuClothesMenu(mainMenu)
        AddMenuDiversMenu(mainMenu)
		AddMenuSimMenu(mainMenu)

	if IsPedSittingInAnyVehicle(plyPed) then
		if (GetPedInVehicleSeat(GetVehiclePedIsIn(plyPed, false), -1) == plyPed) then
			AddMenuVehicleMenu(mainMenu)
		end
	end

	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
		AddMenuBossMenu(mainMenu)
	end

	AddMenuFacturesMenu(mainMenu)
        AddMenuDemarche(mainMenu)

	if playerGroup ~= nil and (playerGroup == 'mod' or playerGroup == 'admin' or playerGroup == 'superadmin' or playerGroup == 'owner') then
		AddMenuAdminMenu(mainMenu)
	end

	_menuPool:RefreshIndex()
end

Citizen.CreateThread(function()
	while true do
		if IsControlJustReleased(0, Config.Menu.clavier) and not isDead then
			if mainMenu ~= nil and not mainMenu:Visible() then
				ESX.PlayerData = ESX.GetPlayerData()
				GeneratePersonalMenu()
				mainMenu:Visible(true)
				Citizen.Wait(10)
			end
		end
		
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		if _menuPool ~= nil then
			_menuPool:ProcessMenus()
		end
		
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		while _menuPool ~= nil and _menuPool:IsAnyMenuOpen() do
			Citizen.Wait(0)

			if not _menuPool:IsAnyMenuOpen() then
				mainMenu:Clear()
				itemMenu:Clear()
				weaponItemMenu:Clear()

				_menuPool:Clear()
				_menuPool:Remove()

				personalmenu = {}

				invItem = {}
				wepItem = {}
				billItem = {}

				collectgarbage()

				_menuPool = NativeUI.CreatePool()

				mainMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('mainmenu_subtitle'))
				itemMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('inventory_actions_subtitle'))
				weaponItemMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('loadout_actions_subtitle'))
				_menuPool:Add(mainMenu)
				_menuPool:Add(itemMenu)
				_menuPool:Add(weaponItemMenu)
			end
		end

		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		if ESX ~= nil then
			ESX.TriggerServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(group) playerGroup = group end)

			Citizen.Wait(30 * 1000)
		else
			Citizen.Wait(100)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		plyPed = PlayerPedId()
		
		if IsControlJustReleased(0, Config.stopAnim.clavier) and GetLastInputMethod(2) and not isDead then
			ClearPedTasks(plyPed)
		end

		if playerGroup ~= nil and (playerGroup == 'mod' or playerGroup == 'admin' or playerGroup == 'superadmin' or playerGroup == 'owner') then
			if IsControlPressed(1, Config.TPMarker.clavier1) and IsControlJustReleased(1, Config.TPMarker.clavier2) and GetLastInputMethod(2) and not isDead then
				admin_tp_marker()
			end
		end

		if showcoord then
			local playerPos = GetEntityCoords(plyPed)
			local playerHeading = GetEntityHeading(plyPed)
			Text("~r~X~s~: " .. playerPos.x .. " ~b~Y~s~: " .. playerPos.y .. " ~g~Z~s~: " .. playerPos.z .. " ~y~Angle~s~: " .. playerHeading)
		end

		if noclip then
			local x, y, z = getPosition()
			local dx, dy, dz = getCamDirection()
			local speed = Config.noclip_speed

			SetEntityVelocity(plyPed, 0.0001, 0.0001, 0.0001)

			if IsControlPressed(0, 32) then
				x = x + speed * dx
				y = y + speed * dy
				z = z + speed * dz
			end

			if IsControlPressed(0, 269) then
				x = x - speed * dx
				y = y - speed * dy
				z = z - speed * dz
			end

			SetEntityCoordsNoOffset(plyPed, x, y, z, true, true, true)
		end

		if showname then
			for id = 0, 255 do
				if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= plyPed then
					local headId = Citizen.InvokeNative(0xBFEFE3321A3F5015, GetPlayerPed(id), (GetPlayerServerId(id) .. ' - ' .. GetPlayerName(id)), false, false, "", false)
				end
			end
		end
		
		Citizen.Wait(0)
	end
end)