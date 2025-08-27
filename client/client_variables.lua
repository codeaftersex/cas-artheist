SELLERSTATS = {
    state = false
}

SELLERSTATS.notify = function(text, nType)
    if Config.CASNotification then
        exports['cas-notification']:addNotification(text, nType, 5000)
    else
        CAS.notify(text)
    end
end