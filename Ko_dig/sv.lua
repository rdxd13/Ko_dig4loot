local activeTokens = {}

RegisterNetEvent("digging:registerToken", function(token)
    local src = source
    activeTokens[src] = token
end)

RegisterNetEvent("digging:reward", function(clientToken)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    if not activeTokens[src] or activeTokens[src] ~= clientToken then
        print(("[EXPLOIT] %s tried to claim digging reward with invalid token."):format(GetPlayerName(src)))
        return
    end

    activeTokens[src] = nil

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local inArea = false

    for _, loc in pairs(Config.DiggingLocations) do
        if #(coords - loc) <= Config.DigRadius then
            inArea = true
            break
        end
    end

    if not inArea then
        print(("[EXPLOIT] %s attempted digging reward outside area!"):format(GetPlayerName(src)))
        return
    end

    -- Tieri
    local tier = getRewardTier()
    local reward = Config.Rewards[tier][math.random(#Config.Rewards[tier])]

    exports.ox_inventory:AddItem(src, reward, 1)
    sendToDiscord(GetPlayerName(src), reward)
end)

function getRewardTier()
    local chance = math.random(100)
    local cumulative = 0

    for tier, percentage in pairs(Config.RarityChances) do
        cumulative = cumulative + percentage
        if chance <= cumulative then
            return tier
        end
    end
    return "common"
end

function sendToDiscord(player, item)
    local data = {
        content = ("**%s** sai esineen **%s** kaivaessa."):format(player, item)
    }

    PerformHttpRequest(
        Config.Webhook,
        function() end,
        "POST",
        json.encode(data),
        { ["Content-Type"] = "application/json" }
    )
end
