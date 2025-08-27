local attachedProp = nil
local lockpickProp = nil
local ActiveHeistObj = nil
local loadedProps = {}
local stolenObjects = {}
local propHealthData = {}
local currentIndex = 0
local OpenShopPrompt = nil
local ShopGroup = GetRandomIntInRange(0, 0xffffff)
local PutDownPrompt = nil
local PutDownGroup = GetRandomIntInRange(0, 0xffffff)
CAS = nil

CreateThread(function()
    local retries = 50
    while CAS == nil and retries > 0 do
        local success, result = pcall(function()
            return exports["cas_fwlibs"]:MBLFunctions()
        end)
        if success and result then
            CAS = result
            break
        end
        retries = retries - 1
        Wait(100)
    end
    if CAS == nil then
        print("[CAS ERROR] cas_fwlibs export cannot be fetched.")
    end
end)

local function openNuiFrame(pedName)
    if not SendReactMessage then return end
    SendReactMessage('setVisible', {
        pedName = pedName
    })
    SetNuiFocus(true, true)
end

local function toggleNuiFrame(shouldShow)
    SELLERSTATS.state = shouldShow
    print("NUI frame state: " .. tostring(shouldShow))
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
  end
  
  RegisterCommand('boiler', function()
    toggleNuiFrame(true)
    print('Show NUI frame')
  end)
  
RegisterNUICallback('hideFrame', function()
  print("hide framee")
  toggleNuiFrame(false)
end)


function StartPutDownPrompt()
    local shopStr = CreateVarString(10, 'LITERAL_STRING', "Art Heist")
    PutDownPrompt = PromptRegisterBegin()
    PromptSetControlAction(PutDownPrompt, 0x24978A28)
    PromptSetText(PutDownPrompt, shopStr)
    PromptSetVisible(PutDownPrompt, 1)
    PromptSetStandardMode(PutDownPrompt, 1)
    PromptSetHoldMode(PutDownPrompt, 1)
    PromptSetGroup(PutDownPrompt, PutDownGroup)
    PromptRegisterEnd(PutDownPrompt)
end

function StartPrompts()
    local shopStr = CreateVarString(10, 'LITERAL_STRING', "Art Heist")
    OpenShopPrompt = PromptRegisterBegin()
    PromptSetControlAction(OpenShopPrompt, 0x24978A28)
    PromptSetText(OpenShopPrompt, shopStr)
    PromptSetVisible(OpenShopPrompt, 1)
    PromptSetStandardMode(OpenShopPrompt, 1)
    PromptSetHoldMode(OpenShopPrompt, 1)
    PromptSetGroup(OpenShopPrompt, ShopGroup)
    PromptRegisterEnd(OpenShopPrompt)
end

local function loadAnim(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(0)
    end
end

local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end


local function OpenDeliveryArtsUI(pedName)
    openNuiFrame(pedName)
end



local function GetModelNameByHash(modelHash)
    for _, modelName in ipairs(Config.ArtHeistProps) do
        if modelHash == GetHashKey(modelName) then
            return modelName
        end
    end
    return nil 
end


local function HasLockpick()
    local callb = TriggerCallback("cas:server:HasLockpick?")
    if callb then
        return true
    else
        return false
    end
end





local function pedThreads()
    for k,v in pairs(Config.DeliveryLocations) do 
        if not v.ped then
            LoadModel(v.pedModel)
            v.ped = CreatePed(GetHashKey(v.pedModel), v.coords.x, v.coords.y, v.coords.z, v.coords.h, false, true)
            SetEntityHeading(v.ped, v.coords.h)
            SetPedOutfitPreset(v.ped, true, false)
            Citizen.InvokeNative(0x283978A15512B2FE, v.ped, true)
            FreezeEntityPosition(v.ped, true)
            SetEntityInvincible(v.ped, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            if Config.Debug then
                SetEntityCoords(PlayerPedId(), Config.DeliveryLocations[1].coords.x, Config.DeliveryLocations[1].coords.y, Config.DeliveryLocations[1].coords.z + 1.0)
            end
        end
    end
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for k,v in pairs(Config.DeliveryLocations) do
            local dist = #(coords - vector3(v.coords.x, v.coords.y, v.coords.z))
            if dist < 5.0 then
                sleep = 0
                currentIndex = k
                DrawText3D(v.coords.x, v.coords.y, v.coords.z + 1.0, _L("getOfferFor"), {255, 255, 255})
                if IsControlJustPressed(0, 0x760A9C6F) then 
                    OpenDeliveryArtsUI(Config.DeliveryLocations[k].pedName)
                end
            end
        end
        Wait(sleep)
    end
end

CreateThread(function()
    pedThreads()
end)



local function GetFinalOfferPrice(locId, prop, durability)
    local location = Config.DeliveryLocations[locId]
    if not location or not location.offers[prop] then print("kanka no location") return 0 end

    local offer = location.offers[prop]
    local price = math.random(offer.minPrice, offer.maxPrice)

    price = math.floor(price * (durability / 100.0))

    if location.isScam and math.random() < location.scamChance then
        return 0, true
    end

    return price, false
end


local function SetPedDialog(text)
    SendReactMessage("setDialog", text)
    SetNuiFocus(true,true)
end


function InspectProp(npcPed, propEntity, cb)
    local propCoords = GetEntityCoords(propEntity)
    local originalCoords = GetEntityCoords(npcPed)
    local originalHeading = GetEntityHeading(npcPed)

    SetEntityInvincible(npcPed, true)
    FreezeEntityPosition(npcPed, false)

    TaskGoStraightToCoord(npcPed, propCoords.x, propCoords.y, propCoords.z, 1.0, 10000, 0.0, 0.0)

    CreateThread(function()
        while true do
            local npcCoords = GetEntityCoords(npcPed)
            local dist = #(npcCoords - propCoords)

            if dist < 1.5 then
                ClearPedTasks(npcPed)
                local inspectDict ="amb_work@world_human_inspect@male_a@stand_exit"
                loadAnim(inspectDict)
                TaskPlayAnim(npcPed, inspectDict, "exit_frontright", 1.0, -1, -1, 1, 0, false, false, false)
               
                Wait(3000)
                ClearPedTasks(npcPed)
                local netId, durability, price = nil, nil, nil
                if propEntity and DoesEntityExist(propEntity) then
                    netId = NetworkGetNetworkIdFromEntity(propEntity)
                    local modelHash = GetEntityModel(propEntity)
                    local modelName = GetModelNameByHash(modelHash)
                    durability = propHealthData[netId] or 100
                    price = GetFinalOfferPrice(currentIndex, modelName, durability)
                else
                    SetPedDialog(_L("statueNotFound"))
         
                    if cb then cb(0) end
                end
                SetPedDialog(_L("statueInspected"):format(durability, price))


                TaskGoStraightToCoord(npcPed, originalCoords.x, originalCoords.y, originalCoords.z, 1.0, 10000, 0.0, 0.0)
                CreateThread(function()
                    while true do
                        local npcBackCoords = GetEntityCoords(npcPed)
                        local returnDist = #(npcBackCoords - originalCoords)
                        if returnDist < 1.5 then
                            ClearPedTasks(npcPed)
                            SetEntityHeading(npcPed, originalHeading)
                            FreezeEntityPosition(npcPed, true)
                            break
                        end
                        Wait(250)
                    end
                end)

                if cb then cb(price) end
                break
            end

            Wait(200)
        end
    end)
end



RegisterNUICallback("selectOffer", function(data, cb)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    local foundEntity = nil

    for i, entity in ipairs(loadedProps) do
        if DoesEntityExist(entity) then
            local dist = #(GetEntityCoords(entity) - pedCoords)
            if dist < 25.0 then
                foundEntity = entity
                break
            end
        end
    end

    if not foundEntity then
        SetPedDialog(_L("noObjectToDeliver"))
        cb(false)
        return
    end

    local entityModelName = GetModelNameByHash(GetEntityModel(foundEntity))
    if data.offer ~= entityModelName then
        SetPedDialog(_L("objectNotMatch"))
        cb(false)
        return
    end

    InspectProp(Config.DeliveryLocations[currentIndex].ped, foundEntity, function(price)
        local netId = NetworkGetNetworkIdFromEntity(foundEntity)
        local durability = propHealthData[netId] or 100

        if price > 0 then
            SetPedDialog(_L("statueDelivered"):format(price))
            TriggerServerEvent("artheist:pay", price, currentIndex, GetEntityModel(foundEntity), durability)
            cb(true)
        else
            SetPedDialog(_L("scammed"))
            cb(false)
        end

        if DoesEntityExist(foundEntity) then
            DeleteEntity(foundEntity)
            propHealthData[netId] = nil
        end

        for i, ent in ipairs(loadedProps) do
            if ent == foundEntity then
                table.remove(loadedProps, i)
                break
            end
        end
    end)
end)

-- CreateThread(function()
--     while true do
--         if attachedProp then
--             local ped = PlayerPedId()
--             if not IsEntityPlayingAnim(ped, "mech_pickup@camerabag@carried", "grip_lt_arm", 3) then
--                 TaskPlayAnim(ped, "mech_pickup@camerabag@carried", "grip_lt_arm", 1.0, 8.0, -1, 49, 0, false, false, false)
--             end
--         end
--         Wait(1000)
--     end
-- end)



CreateThread(function()
    StartPrompts()
    StartPutDownPrompt()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local closestObj = nil
        local closestModel = nil
        local minDist = 1.5
        
        for _, modelName in ipairs(Config.ArtHeistProps) do
            local propHash = GetHashKey(modelName)
            local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.5, propHash, false)
        
            if obj and DoesEntityExist(obj) then
                if not stolenObjects[netId] then
                    local objCoords = GetEntityCoords(obj)
                    local dist = #(coords - objCoords)
                    if dist < minDist then
                        minDist = dist
                        closestObj = obj
                        closestModel = modelName
                    end
                end
            end
        end
        
        
        if closestObj then
            local objCoords = GetEntityCoords(closestObj)
            sleep = 0
            if IsControlJustPressed(0, 0x760A9C6F) and not attachedProp then
                local hasLockpick = HasLockpick()
                if hasLockpick then
                    local netId = NetworkGetNetworkIdFromEntity(closestObj)
                    if stolenObjects[netId] then
                        SELLERSTATS.notify(_L("alreadyStolenText"), "error")
                        return
                    end

                    local propType = "tablo"
                    if closestModel:find("statue") or closestModel:find("bust") then
                        propType = "heykel"
                    end
                    loadAnim("script_ca@carust@02@ig@ig1_rustlerslockpickingconv01")
                    TaskPlayAnim(
                        ped,
                        "script_ca@carust@02@ig@ig1_rustlerslockpickingconv01",
                        "convo_lockpick_smhthug_01",
                        0.50,
                        1.0,
                        -1,
                        1,
                        0,
                        false, 0, false, 0, false
                    )
                    local model = "p_lockpick01x"
                    LoadModel(model)
                    local coords = GetEntityCoords(ped)
                    lockpickProp = CreateObject(GetHashKey(model), coords.x, coords.y, coords.z, true, true, false)
                    AttachEntityToEntity(
                        lockpickProp,
                        ped,
                        GetPedBoneIndex(ped, 22798),
                        0.12, 0.02, 0.0,
                        -90.0, 0.0, 0.0, 
                        true, true, false, true, 1, true
                    )
                    exports['cas-progressbar']:Progress({
                        name = "art_heist",
                        duration = Config.StealProgBarDuration,
                        label = _L("steal"),
                    }, function(cancelled)
                        ClearPedTasks(ped)
                        if lockpickProp and DoesEntityExist(lockpickProp) then
                            DeleteEntity(lockpickProp)
                        end
                    
                        local chance = math.random()
                        if chance < Config.CutHandsChance then
                        
                            ApplyDamageToPed(ped, Config.CutHandsDamage, false)
                            SELLERSTATS.notify(_L("cutyourhand"), "error")
                        end
                        if not cancelled then
                            ClearPedTasks(ped)
                        
                            if lockpickProp and DoesEntityExist(lockpickProp) then
                                DeleteEntity(lockpickProp)
                            end
                            local model = GetEntityModel(closestObj)
                            local objCoords = GetEntityCoords(closestObj)
                            local objHeading = GetEntityHeading(closestObj)
                            DeleteEntity(closestObj)
                            LoadModel(model)

                            local pedHeading = GetEntityHeading(ped)
                            local dropHeading = pedHeading + 180.0
                            if dropHeading > 360.0 then dropHeading -= 360.0 end

                            local rad = math.rad(dropHeading)
                            local forwardX = math.sin(rad)
                            local forwardY = math.cos(rad)
                            local spawnX = objCoords.x + 0.15 * forwardX
                            local spawnY = objCoords.y + 0.15 * forwardY
                            local spawnZ = objCoords.z + 0.3

                            local newObj = CreateObject(model, spawnX, spawnY, spawnZ, true, true, true)

                            SetEntityAsMissionEntity(newObj, true, true)
                            SetEntityCollision(newObj, true, true)
                            FreezeEntityPosition(newObj, false)
                            SetEntityHeading(newObj, pedHeading)
                            ActiveHeistObj = newObj
                            currentPropType = propType
                            local netId = NetworkGetNetworkIdFromEntity(newObj)
                            stolenObjects[netId] = true


                            CreateThread(function()
                                local height = 0.0
                                local tilt = 0.0
                                local step = 0
                                local totalSteps = 30
                            
                                while step < totalSteps do
                                    local fallSpeed = (step / totalSteps) ^ 2 * 1.0
                                
                                    height += 0.01 + fallSpeed
                                    tilt += 2.5 + (fallSpeed * 4.0)
                                    SetEntityCoords(
                                        newObj,
                                        objCoords.x + (step * 0.003 * forwardX),
                                        objCoords.y + (step * 0.003 * forwardY),
                                        objCoords.z - height
                                    )
                                
                                    SetEntityRotation(newObj, tilt, 0.0, pedHeading, 2, true)
                                
                                    Wait(25)
                                    step += 1
                                end
                            
                                local finalX = objCoords.x + (step * 0.003 * forwardX)
                                local finalY = objCoords.y + (step * 0.003 * forwardY)
                                local success, groundZ = GetGroundZFor_3dCoord(finalX, finalY, objCoords.z, true)
                                if not success then groundZ = objCoords.z - 1.0 end
                                SetEntityCoords(newObj, finalX, finalY, groundZ)
                                SetEntityRotation(newObj, 90.0, 0.0, pedHeading, 2, true)
                                FreezeEntityPosition(newObj, true)
                                SetEntityDynamic(newObj, false)
                                SetEntityCollision(newObj, true, true)
                                local damage = Config.StatueDamage
                                local netId = NetworkGetNetworkIdFromEntity(newObj)
                                propHealthData[netId] = 100 - damage
                                if propHealthData[netId] < 30 then
                                    SELLERSTATS.notify(_L("statueDamaged"), "info")
                                end
                                if propHealthData[netId] <= 0 then
                                    DeleteEntity(newObj)
                                    propHealthData[netId] = nil

                                    SELLERSTATS.notify(_L("statueBroken"), "error")
                                else
                                    SELLERSTATS.notify(_L("statueHealth"):format(propHealthData[netId]), "success")

                                end
                            end)
                        end
                    end)
                else
                    SELLERSTATS.notify(_L("missingitem"), "error")
                end
            end
        end
        if ActiveHeistObj and DoesEntityExist(ActiveHeistObj) then
            local objCoords = GetEntityCoords(ActiveHeistObj)
            local dist = #(coords - objCoords)
            if dist < 5.0 then
                local label = CreateVarString(10, 'LITERAL_STRING', _L("pickup"))
                PromptSetActiveGroupThisFrame(ShopGroup, label)

                if PromptHasHoldModeCompleted(OpenShopPrompt) then
                    local dict = "mech_carry_ped@enters@idle"
                    loadAnim(dict)
                    TaskPlayAnim(ped, dict, "0_close_lf", 1.0, 8.0, 1.0, 25, 0, false, false, false)
                    Wait(2000)
                    local modelHash = GetEntityModel(ActiveHeistObj)
                    LoadModel(modelHash)

                    local spawnCoords = GetEntityCoords(ped)
                    attachedProp = CreateObject(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
                    SetEntityVisible(attachedProp, true)
                    SetEntityAsMissionEntity(attachedProp, true, true)
                    local modelName = GetModelNameByHash(modelHash)
                    local propData = Config.PropsLocationOnHands[modelName]
                    loadAnim("mech_pickup@camerabag@carried")
                    TaskPlayAnim(ped, "mech_pickup@camerabag@carried", "grip_lt_arm", 1.0, 8.0, -1, 25, 0, false, false, false)
                    Wait(100)
                    AttachEntityToEntity(
                        attachedProp,
                        ped,
                        GetPedBoneIndex(ped, 53675), 
                        propData.x, propData.y, propData.z,            
                        propData.xRot, propData.yRot, propData.zRot, 
                        true, true, false, true, 1, true
                    )

                    FreezeEntityPosition(ped, false)
                    DeleteEntity(ActiveHeistObj)
                    ActiveHeistObj = nil
                end
            end
        end
        
        local wagon = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, GetHashKey(Config.WagonModel), 70)
        if DoesEntityExist(wagon) and attachedProp and currentPropType == "heykel" then
            local wagonCoords = GetEntityCoords(wagon)
            local label = CreateVarString(10, 'LITERAL_STRING', _L("putDown"))
            PromptSetActiveGroupThisFrame(PutDownGroup, label)

            if PromptHasHoldModeCompleted(PutDownPrompt) then
                local throwDict = "mech_skin@alligator_s@throw_body"
                loadAnim(throwDict)
                TaskPlayAnim(ped, throwDict, "throw", 1.0, 8.0, -1, 25, 0, false, false, false)
                Wait(2000)
                DetachEntity(attachedProp, true, true)
                local offsetX = 0.0
                local offsetY = -1.5 + (#loadedProps * 0.4)
                local offsetZ = 0.2
    
                SetEntityAsMissionEntity(attachedProp, true, true)
    
                AttachEntityToEntity(
                    attachedProp,
                    wagon,
                    GetEntityBoneIndexByName(wagon, "bodyshell"),
                    offsetX, offsetY, offsetZ,
                    0.0, 0.0, 0.0,
                    true, true, false, true, 1, true
                )
    
                table.insert(loadedProps, attachedProp)
                ClearPedTasksImmediately(ped)
                attachedProp = nil
                ActiveHeistObj = nil
                currentPropType = nil
            end
            
        end

        Wait(sleep)
    end
end)

local testobj 

RegisterCommand("attachtestprop", function()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local model = "p_cherubstatuenbx01x"
    LoadModel(model)
    testobj = CreateObject(GetHashKey(model), pedCoords.x, pedCoords.y, pedCoords.z, true, true, false)
    SetEntityAsMissionEntity(testobj, true, true)
    AttachEntityToEntity(
        testobj,
        ped,
        GetPedBoneIndex(ped, 53675),
        0.4, 0.4, -0.1,
        45.0, -45.0, 0.0,
        true, true, false, true, 1, true
    )
end)


AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if attachedProp and DoesEntityExist(attachedProp) then
            DeleteEntity(attachedProp)
        elseif lockpickProp and DoesEntityExist(lockpickProp) then
            DeleteEntity(lockpickProp)
        end
        for _, prop in ipairs(loadedProps) do
            if DoesEntityExist(prop) then
                DeleteEntity(prop)
            end
        end
        for _, v in pairs(Config.DeliveryLocations) do
            if v.ped and DoesEntityExist(v.ped) then
                DeleteEntity(v.ped)
            end
        end
        if testobj and DoesEntityExist(testobj) then
            DeleteEntity(testobj)
        end
    end
end)

RegisterNetEvent("artheist:updateStolenObjects", function(data)
    stolenObjects = data or {}
end)

function MarkPropAsStolen(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    TriggerServerEvent("artheist:markStolen", netId)
end

function IsPropStolen(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    return stolenObjects[netId] == true
end


function DrawText3D(x, y, z, text, color)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
	local px, py, pz = table.unpack(GetGameplayCamCoord())
	local str = VarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
	if onScreen then
		SetTextScale(0.30, 0.30)
		SetTextFontForCurrentCommand(1)
		SetTextColor(color[1], color[2], color[3], 255)
		SetTextCentre(1)
		DisplayText(str, _x, _y)
		local factor = (string.len(text)) / 225
		DrawSprite("feeds", "hud_menu_4a", _x, _y + 0.0125, 0.015 + factor, 0.03, 0.1, 35, 35, 35, 190, false)
	end
end
