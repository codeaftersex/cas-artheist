CAS = nil
local stolenObjects = {}

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


function RegisterUsableItemsAsync()
    TriggerEvent("vorpCore:registerUsableItem", "lockpick", function(data)
        TriggerClientEvent("cas_artheist:lockpick", data.source)
    end)
end


RegisterNetEvent("artheist:markStolen", function(netId)
    if netId then
        stolenObjects[netId] = true
        TriggerClientEvent("artheist:updateStolenObjects", -1, stolenObjects)
    end
end)


RegisterNetEvent("artheist:pay", function(price)
    local src <const> = source
    CAS.addCurrency(src, 0, price)
end)

RegisterCommand("addlockpick", function(source)
    local src <const> = source
    exports.vorp_inventory:addItem(src, "lockpick", 1)
end)


RegisterCallback("cas:server:HasLockpick?", function(source, cb)
    local src <const> = source
    local hasItem = CAS.getItem(src, Config.RequiredItem)
    if hasItem then
        local deleteLockPickChance = Config.DeleteLockPickChance
        local randomChance = math.random(0, 100) / 100
        if randomChance <= deleteLockPickChance then
            CAS.RemoveItem(src, Config.RequiredItem, 1)
            CAS.notify(src, _L("lockpickBroken"))
        end
        return true
    else
        return false
    end
end)



