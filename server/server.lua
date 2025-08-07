RegisterServerEvent("afk_zone:reward")
AddEventHandler("afk_zone:reward", function(data)
    local src = source

    if not data or not data.rewards or type(data.rewards) ~= "table" then
        print("[aes_afkzone : debug] ❌ ไม่มีข้อมูล reward หรือข้อมูลผิดรูปแบบ")
        return
    end

    local playerName = GetPlayerName(src)
    local logLines = {}
    local messageText = ""

    for _, item in ipairs(data.rewards) do
        if item.item and item.count then
            exports.vorp_inventory:addItem(src, item.item, item.count)
            table.insert(logLines, ("- `%s x%d`"):format(item.item, item.count))
            print(("[aes_afkzone : debug] 🎁 %s ได้รับ: %s x%d"):format(playerName, item.item, item.count))
        end
    end

    if #logLines > 0 then
        messageText = ("**ได้รับของจาก AFK Zone:**\n%s"):format(table.concat(logLines, "\n"))
        sendWebhookLog(playerName, messageText)
    end
end)

function sendWebhookLog(playerName, rewardsText)
    if not Config.WebhookURL or Config.WebhookURL == "" then
        print("[aes_afkzone : debug] ❌ ยังไม่ได้ตั้งค่า Webhook URL ใน Config.lua")
        return
    end

    local payload = {
        username = "aes_afk_zone",
        embeds = {{
            title = "🎉 " .. playerName .. " ",
            description = rewardsText,
            color = 16776960,
            footer = { text = "aes_afk_zone • " .. os.date("%H:%M") },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
        if err ~= 204 and err ~= 200 then
            print("[aes_afkzone : debug] ❌ Webhook Error", err, text)
        else
            print("[aes_afkzone : debug] ✅ Webhook ส่งสำเร็จ")
        end
    end, "POST", json.encode(payload), {
        ["Content-Type"] = "application/json"
    })
end