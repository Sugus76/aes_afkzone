local isAFK          = false
local zoneEntered    = false
local activeZone     = nil
local cooldownThread = nil
local createdBlips = {}

function IsThisModelACarriage(model)
    local carriageModels = {
        `cart01`, `cart02`, `cart03`, `cart04`, `cart05`, `cart06`,
        `buggy01`, `buggy02`, `buggy03`, `buggy04`,
        `wagon02x`, `wagon03x`, `wagon04x`, `wagon05x`,
        `wagon06x`, `wagonCircus01x`, `wagonCircus02x`,
        `coach2`, `coach3`, `coach4`, `coach5`, `coach6`,
        `stagecoach001x`, `stagecoach002x`, `stagecoach003x`,
        `chuckwagon000x`, `chuckwagon002x`, `chuckwagon003x`,
        `armySupplyWagon`, `supplywagon`, `logWagon`,
        `oilWagon01x`, `oilWagon02x`, `prisonWagon01x`
    }
    for _, v in ipairs(carriageModels) do
        if model == v then return true end
    end
    return false
end

function IsThisModelAHorse(model)
    return IsModelValid(model) and IsThisModelAHorseNative(model)
end


function IsThisModelAHorseNative(model)
    local minDim, maxDim = vector3(0, 0, 0), vector3(0, 0, 0)
    if GetModelDimensions(model, minDim, maxDim) then
        local height = maxDim.z - minDim.z
        return height > 1.5 and height < 3.5
    end
    return false
end

CreateThread(function()
    Wait(1000)
    if Config.Debug then print("[aes_afkzone : debug] UI hidden on game start") end
    SendNUIMessage({ action = "hideAFK" })
    SendNUIMessage({ action = "hidePressStart" })
end)

function isInsideZone(coords, points, minZ, maxZ)
    local x, y, z = table.unpack(coords)
    local inside = false
    local j = #points
    for i = 1, #points do
        local xi, yi = points[i].x, points[i].y
        local xj, yj = points[j].x, points[j].y
        if ((yi > y) ~= (yj > y)) and
           (x < (xj - xi) * (y - yi) / ((yj - yi) + 0.00001) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside and z >= minZ and z <= maxZ
end

function getCurrentAFKZone(coords)
    for _, zone in ipairs(Config.AFKZones) do
        if isInsideZone(coords, zone.points, zone.minZ, zone.maxZ) then
            if Config.Debug then print("[aes_afkzone : debug] Player inside zone:", zone.name) end
            return zone
        end
    end
    return nil
end

local function CreateBlips()
    if type(Config.AFKZones) ~= "table" then
        print("^1[aes_afkzone] Error: Config.AFKZones is nil or not a table!^7")
        return
    end

    for _, b in ipairs(createdBlips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end
    createdBlips = {}

    for _, zone in ipairs(Config.AFKZones) do
        local c = zone.center or vector3(0,0,0)
        local label = zone.label or "afkzone"
        local blipData = zone.blip or {}
        local sprite = blipData.sprite or -1230993421
        local scale  = blipData.scale  or 0.8
        local style  = blipData.style  or 1664425300

        local blip = N_0x554d9d53f696d002(style, c.x, c.y, c.z)
        if blip then
            SetBlipSprite(blip, sprite, 1)
            SetBlipScale(blip, scale)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, CreateVarString(10, "LITERAL_STRING", label))
            Citizen.InvokeNative(0x662D364ABF16DE2F, blip, 1)
            table.insert(createdBlips, blip)
            if Config.Debug then print("[aes_afkzone : debug] Created blip for:", label) end
        else
            print("^1[aes_afkzone : debug] Failed to create blip for:", label)
        end
    end
end

function startCooldownLoop(seconds, reward)
    cooldownThread = CreateThread(function()
        while isAFK do
            local remaining = seconds
            while remaining > 0 and isAFK do
                Wait(1000)
                remaining = remaining - 1
                SendNUIMessage({
                    action = "updateTimer",
                    time = string.format("%02d:%02d", math.floor(remaining / 60), remaining % 60)
                })
                if Config.Debug then print("[aes_afkzone : debug] Time left:", remaining) end
            end

            if isAFK then
                if Config.Debug then
                    print("[aes_afkzone : debug] Sending rewards:")
                    for _, item in ipairs(reward.items) do
                        print(" -", item.item, "x" .. item.count)
                    end
                end
                
                local itemDescription = ""
                for _, v in ipairs(reward.items) do
                    local name = Config.ItemNames[v.item] or v.item
                    itemDescription = itemDescription .. string.format("• %-25s x%d\n", name, v.count)
                end

                TriggerEvent("bln_notify:send", {
                    title = "~#ffcc00~" .. reward.notify .. "~e~",
                    description = itemDescription,
                    icon = "awards_set_h_012",
                    placement = "middle-left",
                    duration = 10000,
                    progress = {
                        enabled = true,
                        type = 'circle', -- or 'bar'
                        color = '#ffcc00'
                    },
                })

                TriggerServerEvent("afk_zone:reward", {
                    rewards = reward.items,
                    notify = reward.notify
                })
            end
        end
    end)
end

CreateThread(function()
    while true do
        Wait(1500)
        local ped = PlayerPedId()
        if not DoesEntityExist(ped) then goto continue end

        local coords = GetEntityCoords(ped)
        local zone = getCurrentAFKZone(coords)

        if zone and not zoneEntered then
            zoneEntered = true
            activeZone  = zone

            if Config.Debug then print("[aes_afkzone : debug] Entered zone:", zone.name) end
            SetEntityAlpha(ped, Config.PlayerAlpha, false)
            SetPlayerInvincible(PlayerId(), true)
            SendNUIMessage({ action = "showPressStart", cooldown = Config.DefaultCooldown })
            SendNUIMessage({ action = "notify", message = "คุณเข้าสู่โซน AFK แล้วไม่สามารถใช้อาวุธในโซนนี้" })

        elseif not zone and zoneEntered then
            zoneEntered = false
            activeZone  = nil

            ResetEntityAlpha(ped)
            SetPlayerInvincible(PlayerId(), false)

            if isAFK then
                isAFK = false
                SendNUIMessage({ action = "hideAFK" })
                if cooldownThread then TerminateThread(cooldownThread) cooldownThread = nil end
                SendNUIMessage({ action = "notify", message = "ออกจากโหมด AFK เนื่องจากออกจากโซน" })
                if Config.Debug then print("[aes_afkzone : debug] Exited AFK while active") end
            else
                SendNUIMessage({ action = "hidePressStart" })
                SendNUIMessage({ action = "notify", message = "คุณออกจากโซน AFK แล้ว" })
                if Config.Debug then print("[aes_afkzone : debug] Exited zone (no job)") end
            end
        end
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(5000)
        if not zoneEntered or not activeZone then goto skip end

        local ped = PlayerPedId()
        local zone = activeZone

        local mount = GetMount(ped)
        if DoesEntityExist(mount) then
            local coords = GetEntityCoords(mount)
            if isInsideZone(coords, zone.points, zone.minZ, zone.maxZ) then
                DeleteEntity(mount)
                SendNUIMessage({ action = "notify", message = "ลบม้าของคุณที่อยู่ในโซน AFK" })
                if Config.Debug then print("[aes_afkzone : debug] Deleted player horse") end
            end
        end

        local handle, entity = FindFirstVehicle()
        local success = true
        repeat
            if DoesEntityExist(entity) then
                local coords = GetEntityCoords(entity)
                if isInsideZone(coords, zone.points, zone.minZ, zone.maxZ) then
                    local model = GetEntityModel(entity)
                    if IsThisModelAHorse(model) or IsThisModelACarriage(model) then
                        DeleteEntity(entity)
                        SendNUIMessage({ action = "notify", message = "ลบเกวียนของคุณที่อยู่ในโซน AFK" })
                        if Config.Debug then print("[aes_afkzone : debug] Deleted vehicle model:", model) end
                    end
                end
            end
            success, entity = FindNextVehicle(handle)
        until not success
        EndFindVehicle(handle)

        ::skip::
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if zoneEntered and not isAFK then
            if IsControlJustReleased(0, 0xE30CD707) then 
                if Config.Debug then print("[aes_afkzone : debug] Pressed R") end
                ExecuteCommand('startJob')
            end
        end
        if zoneEntered then
            if IsControlJustReleased(0, 0x8CC9CD42) then 
                if Config.Debug then print("[aes_afkzone : debug] Pressed X") end
                ExecuteCommand('cancelJob')
            end
        end
    end
end)

RegisterCommand('startJob', function()
    if zoneEntered and not isAFK then
        isAFK = true
        SendNUIMessage({ action = "hidePressStart" })
        SendNUIMessage({ action = "showAFK", items = activeZone.reward.items })
        SendNUIMessage({
            action  = "notify",
            message = "เริ่มโหมด AFK แล้ว คุณจะได้รับของรางวัลทุก " .. Config.DefaultCooldown .. " วินาที"
        })
        if Config.Debug then
            local h = GetClockHours()
            local m = GetClockMinutes()
            local s = GetClockSeconds()
            print(string.format("[aes_afkzone : debug] Started AFK job at %02d:%02d:%02d", h, m, s))
        end

        startCooldownLoop(Config.DefaultCooldown, activeZone.reward)
    end
end)

RegisterCommand('cancelJob', function()
    local ped = PlayerPedId()
    if zoneEntered and not isAFK then
        zoneEntered = false
        activeZone  = nil
        ResetEntityAlpha(ped)
        SetPlayerInvincible(PlayerId(), false)
        SendNUIMessage({ action = "hidePressStart" })
        if Config.Debug then print("[aes_afkzone : debug] Cancelled job prompt") end

    elseif isAFK then
        isAFK = false
        ResetEntityAlpha(ped)
        SetPlayerInvincible(PlayerId(), false)
        SendNUIMessage({ action = "hideAFK" })
        if cooldownThread then TerminateThread(cooldownThread) cooldownThread = nil end
        SendNUIMessage({
            action  = "notify",
            message = "ยกเลิกงาน AFK"
        })
        if Config.Debug then print("[aes_afkzone : debug] Cancelled AFK job") end
    end
end)

CreateThread(function()
    while true do
        Wait(10)
        if zoneEntered then
            local ped = PlayerPedId()
            SetPlayerInvincible(PlayerId(), true)
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)

            for _, control in ipairs({
                0x07CE1E61, 0xF84FA74F, 0xB238FE0B, 0x1CE6D9EB,
                0xE6F612E4, 0xA1FDE2A6, 0x8F9F9E58, 0xAB62E997,
                0xAB62E997, 0x0F39B3D4, 0x1D073A89, 0xBE9B4EAA,
                0xDB096B85, 0x20F373E0, 0x107C5178
            }) do
                DisableControlAction(0, control, true)
            end
        else
            Wait(500)
        end
    end
end)

CreateThread(function()
    Wait(2000)
    CreateBlips()
end)

RegisterNUICallback('escape', function(_, cb)
    if isAFK then
        isAFK = false
        ResetEntityAlpha(PlayerPedId())
        SetPlayerInvincible(PlayerId(), false)
        if cooldownThread then TerminateThread(cooldownThread) cooldownThread = nil end
        SendNUIMessage({ action = "hideAFK" })
        if Config.Debug then print("[aes_afkzone : debug] ESC → Exit AFK") end
    elseif zoneEntered then
        zoneEntered = false
        activeZone  = nil
        SendNUIMessage({ action = "hidePressStart" })
        if Config.Debug then print("[aes_afkzone : debug] ESC → Exit Prompt") end
    end
    cb('ok')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, b in ipairs(createdBlips) do
            if DoesBlipExist(b) then
                RemoveBlip(b)
                if Config.Debug then print("[aes_afkzone : debug] Removed blip on resource stop") end
            end
        end
        createdBlips = {}
    end
end)