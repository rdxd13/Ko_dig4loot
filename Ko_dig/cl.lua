local digging = false
local digToken = nil

function isPlayerInDigArea()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    for _, location in pairs(Config.DiggingLocations) do
        if #(coords - location) <= Config.DigRadius then
            return true
        end
    end
    return false
end

exports('dig', function()
    local token = math.random(100000, 999999)
    digToken = token
    TriggerServerEvent("digging:registerToken", token)
    TriggerEvent("digging:start")
end)

RegisterNetEvent("digging:start", function()
    if digging then return end

    if not isPlayerInDigArea() then
        lib.notify({
            title = Config.locales.digging,
            description = Config.locales.inarea,
            type = "info"
        })
        return
    end

    local success = lib.skillCheck(
        {'easy', 'easy', {areaSize = 60, speedMultiplier = 1}},
        {'w', 'a', 's', 'd'}
    )

    if not success then
        lib.notify({
            title = Config.locales.digging,
            description = Config.locales.failed,
            type = "error"
        })
        return
    end

    digging = true

    local progress = lib.progressCircle({
        duration = 5000,
        label = Config.locales.digging,
        canCancel = true,
        disable = { car = true, movement = true },
        anim = {
            dict = "random@burial",
            clip = "a_burial",
        },
        prop = {
            model = 'prop_tool_shovel',
            bone = 28422,
            pos = vec3(0.03, 0.01, 0.2),
            rot = vec3(0.0, 0.0, -9.5)
        },
    })

    if progress then
        if digToken then
            TriggerServerEvent("digging:reward", digToken)
            digToken = nil
            lib.notify({
                title = Config.locales.digging,
                description = Config.locales.find,
                type = "success"
            })
        else
            print("[SECURITY] No valid token")
        end
    else
        lib.notify({
            title = Config.locales.digging,
            description = Config.locales.canceled,
            type = "info"
        })
    end

    digging = false
end)

CreateThread(function()
    for _, loc in pairs(Config.DiggingLocations) do
        local blip = AddBlipForCoord(loc)
        SetBlipSprite(blip, 273)
        SetBlipColour(blip, 0)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Kaivuualue')
        EndTextCommandSetBlipName(blip)

        local area = AddBlipForRadius(loc, Config.DigRadius)
        SetBlipSprite(area, 10)
        SetBlipColour(area, 0)
        SetBlipAlpha(area, 120)
    end
end)
