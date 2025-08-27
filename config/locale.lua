

Locales = {
    ["en"] = {
        ["getOffer"] = "Get Offer For",
        ["defaultWelcomeText"] = "I hope you came with beautiful and valuable things in your hands! Be careful not to bring broken pieces! Because they lose value...",
        ["alreadyStolenText"] = "You have already stolen this item!",
        ["cutyourhand"] = "You cut your hands.",
        ["statueDamaged"] = "The statue was damaged, its value decreased.",
        ["statueBroken"] = "The statue is broken, it can no longer be used.",
        ["statueHealth"] = "The statue's durability status: %s",
        ["pickup"] = "Pickup",
        ["putDown"] = "Put Down",
        ["statueNotFound"] = "Statue not found or invalid",
        ["statueInspected"] = "Statue inspected. Health: %d | Offer: $%d",
        ["noObjectToDeliver"] = "No object to deliver soon",
        ["objectNotMatch"] = "Object does not match",
        ["statueDelivered"] = "Statue delivered, the offer you received: $%d",
        ["scammed"] = "You were scammed! The offer is invalid.",
        ["artDealer"] = "Art Dealer",
        ["artHeist"] = "Art Heist",
        ["dealer"] = "Access Dealer",
        ["getOfferFor"] = "Get offer for arts [G]",
        ["missingitem"] = "You are missing the lockpick",
        -- lockpick is broken
        ["lockpickBroken"] = "Your lockpick is broken",
        ["steal"] = "Stealing...",
        ["closemenu"] = "CLOSE MENU",
        ["startfrom"] = "START FROM"
    },
}

function _L(key)
    if Locales[Config.Locale] == nil then
        return "Locale not found"
    end

    if Locales[Config.Locale][key] == nil then
        return "Key not found"
    end

    return Locales[Config.Locale][key]
end


Citizen.CreateThread(function()
    Wait(750)
    if not SendReactMessage then return end
    SendReactMessage("setLocale", Locales[Config.Locale])
end)