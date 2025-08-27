Config.Locale = "en"

Config.LogWebhook = "put your webhook"
Config.WebhookHeader = "Art Heist"
Config.ArtHeistProps = {
    "p_gen_statue02b",
    "p_cherubstatuenbx01x",
    "p_headbust03x"
}



Config.PropsLocationOnHands = {
    ["p_gen_statue02b"] = {
        x = 0.8,
        y = 0.8,
        z = -0.4,
        xRot = 45.0,
        yRot = -45.00,
        zRot = 0.0,
    },
    ["p_headbust03x"] = {
        x = 0.4,
        y = 0.4,
        z = -0.1,
        xRot = 45.0,
        yRot = -45.00,
        zRot = 0.0,
    },
    ["p_cherubstatuenbx01x"] = {
        x = 0.4,
        y = 0.4,
        z = -0.1,
        xRot = 45.0,
        yRot = -45.00,
        zRot = 0.0,
    },
}



Config.Debug = false
Config.CASNotification = false
Config.CutHandsChance = 0.9
Config.CutHandsDamage = 10
Config.RequiredItem = "lockpick"
Config.DeleteLockPickChance = 0.9 -- 0.0 - 1.0
Config.StatueDamage = math.random(1, 100)
Config.StealProgBarDuration = math.random(15000, 30000) -- 15 - 30 seconds
Config.Keys = {
    artDealer = 0x24978A28,
    putDown = 0x24978A28,
    pickup = 0x24978A28,
    steal = 0x760A9C6F
}



Config.DeliveryLocations = {
    [1] = {
        name = "Saint Denis Dealer",
        coords = {x = 2705.594, y = -1105.877, z = 48.415, h = 219.542},
        ped = nil,
        pedModel = "mp_de_u_m_m_aurorabasin_01",
        pedName = "Aurora Basin",
        isScam = true,
        scamChance = 0.9,
        offers = {
            ["p_gen_statue02b"] = { minPrice = 1200, maxPrice = 4800 },
            ["p_cherubstatuenbx01x"] = { minPrice = 800, maxPrice = 2500 },
            ["p_headbust03x"] = { minPrice = 500, maxPrice = 1300 },
        }
    },
}




Citizen.CreateThread(function()
    if IsDuplicityVersion() then return end
    Citizen.Wait(500)
    SendReactMessage('setConfig', Config)
end)
