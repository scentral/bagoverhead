RegisterNetEvent("bag:check")
AddEventHandler("bag:check", function(player, hasBag)
    TriggerClientEvent("bag:check:client", player, hasBag)
end)